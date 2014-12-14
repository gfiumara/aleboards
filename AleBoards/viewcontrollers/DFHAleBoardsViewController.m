/*
 * Copyright (c) 2013, Gregory Fiumara
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIColor+Dogfish.h"
#import "UIFont+Dogfish.h"
#import "DFHAleBoardDownloader.h"
#import "DFHConstants.h"
#import "DFHLocationInformationViewController.h"

#import "DFHAleBoardsViewController.h"

/** Key for the last updated date for the location */
static NSString * const kDFHABVCLastModifiedDateKey = @"lastUpdated";
/** Key for the location's index in the downloader. */
static NSString * const kDFHABVCLocationIndexKey = @"locationIndex";
/** Key for the location's AleBoard UIImage. */
static NSString * const kDFHABVCAleBoardImageKey = @"image";

@interface DFHAleBoardsViewController ()

@property (nonatomic, strong) DFHAleBoardDownloader *downloader;
@property (nonatomic, strong) NSMutableArray *lastRetrievedData;

/* Interface */
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray *venueNameLabels;
@property (nonatomic, strong) NSMutableArray *lastUpdatedLabels;
@property (nonatomic, strong) NSMutableArray *aleBoardImageViews;
@property (nonatomic, strong) NSMutableArray *infoButtons;
/* Dynamic Type */
@property (nonatomic, strong) NSDictionary *venueNameLabelAttributes;
@property (nonatomic, strong) NSDictionary *lastUpdatedLabelAttributes;

@end

@implementation DFHAleBoardsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.downloader = [DFHAleBoardDownloader new];
	if (self.downloader == nil) {
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Couldn't load data alert title")
					    message:NSLocalizedString(@"Could not load information. I'm sure DFH still has something great on tap though!", @"Couldn't load data alert message")
					   delegate:nil
				  cancelButtonTitle:@"Okay"
				  otherButtonTitles:nil] show];
		return;
	}

	[self refreshDynamicType:nil];
	[self autolayout];
	[self refreshLabelsAndImages];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if ([self.downloader.aleBoardsData count] > 1)
		[self.scrollView flashScrollIndicators];
}

- (void)viewWillAppear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDynamicType:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	[self autolayout];
	if ((self.lastRetrievedData == nil) || ([self.lastRetrievedData count] == 0))
		[self refreshLabelsAndImages];
	else
		[self restoreLabelsAndImages];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[UIView animateWithDuration:duration animations:^() {
		self.scrollView.alpha = 0;
	} completion:^(BOOL finished) {
		for (NSUInteger i = 0; i < [self.venueNameLabels count]; i++) {
			[self.venueNameLabels[i] removeFromSuperview];
			[self.lastUpdatedLabels[i] removeFromSuperview];
			[self.infoButtons[i] removeFromSuperview];
			[self.aleBoardImageViews[i] removeFromSuperview];
			[self.pageControl removeFromSuperview];
			[self.scrollView removeFromSuperview];
		}
	}];
}

# pragma mark - Layout

- (void)autolayout
{
	NSMutableDictionary *views = [@{} mutableCopy];
	NSUInteger numberOfLocations = [self.downloader.aleBoardsData count];

	UIScrollView *scrollView = [UIScrollView new];
	scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	scrollView.pagingEnabled = YES;
	scrollView.delegate = self;
	[views addEntriesFromDictionary:NSDictionaryOfVariableBindings(scrollView)];
	self.scrollView = scrollView;
	[self.view addSubview:scrollView];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:views]];

	UIPageControl *pageControl = [UIPageControl new];
	pageControl.translatesAutoresizingMaskIntoConstraints = NO;
	pageControl.numberOfPages = numberOfLocations;
	pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
	pageControl.currentPageIndicatorTintColor = [UIColor dogfishGreen];
	[pageControl addTarget:self action:@selector(pageControlChangedPage:) forControlEvents:UIControlEventValueChanged];
	[views addEntriesFromDictionary:NSDictionaryOfVariableBindings(pageControl)];
	self.pageControl = pageControl;
	[self.view addSubview:pageControl];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pageControl]|" options:0 metrics:nil views:views]];

	NSMutableDictionary *metrics = [@{@"SEP" : @(15.0), @"SEP2" : @(30.0)} mutableCopy];
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
		[metrics setObject:@(CGRectGetHeight(self.view.frame) - 30.0) forKey:@"WIDTH"];
	else
		[metrics setObject:@(CGRectGetWidth(self.view.frame) - 30.0) forKey:@"WIDTH"];
	self.venueNameLabels = [NSMutableArray arrayWithCapacity:numberOfLocations];
	self.lastUpdatedLabels = [NSMutableArray arrayWithCapacity:numberOfLocations];
	self.aleBoardImageViews = [NSMutableArray arrayWithCapacity:numberOfLocations];
	self.infoButtons = [NSMutableArray arrayWithCapacity:numberOfLocations];
	for (NSUInteger i = 0; i < numberOfLocations; i++) {
		UILabel *venueNameLabel = [UILabel new];
		venueNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
		self.venueNameLabels[i] = venueNameLabel;
		[views setObject:venueNameLabel forKey:[NSString stringWithFormat:@"venueNameLabel%lu", (long unsigned)i]];
		[scrollView addSubview:venueNameLabel];

		UILabel *lastUpdatedLabel = [UILabel new];
		lastUpdatedLabel.translatesAutoresizingMaskIntoConstraints = NO;
		self.lastUpdatedLabels[i] = lastUpdatedLabel;
		[views setObject:lastUpdatedLabel forKey:[NSString stringWithFormat:@"lastUpdatedLabel%lu", (long unsigned)i]];
		[scrollView addSubview:lastUpdatedLabel];
		[scrollView addConstraint:[NSLayoutConstraint constraintWithItem:venueNameLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:lastUpdatedLabel attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

		UIImageView *aleBoardImageView = [UIImageView new];
		aleBoardImageView.translatesAutoresizingMaskIntoConstraints = NO;
		aleBoardImageView.contentMode = UIViewContentModeScaleAspectFit;
		self.aleBoardImageViews[i] = aleBoardImageView;
		[views setObject:aleBoardImageView forKey:[NSString stringWithFormat:@"aleBoardImageView%lu", (long unsigned)i]];
		[scrollView addSubview:aleBoardImageView];
		[scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[venueNameLabel%lu]-[aleBoardImageView%lu(==200)]-[lastUpdatedLabel%lu]", (long unsigned)i, (long unsigned)i, (long unsigned)i] options:0 metrics:nil views:views]];
		[scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[aleBoardImageView%lu(==WIDTH)]", (long unsigned)i] options:0 metrics:metrics views:views]];
		[scrollView addConstraint:[NSLayoutConstraint constraintWithItem:aleBoardImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

		UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
		infoButton.translatesAutoresizingMaskIntoConstraints = NO;
		infoButton.tag = i;
		self.infoButtons[i] = infoButton;
		[infoButton addTarget:self action:@selector(infoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[views setObject:infoButton forKey:[NSString stringWithFormat:@"infoButton%lu", (long unsigned)i]];
		[scrollView addSubview:infoButton];
		[scrollView addConstraint:[NSLayoutConstraint constraintWithItem:infoButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lastUpdatedLabel attribute:NSLayoutAttributeTop multiplier:1 constant:27]];
		[scrollView addConstraint:[NSLayoutConstraint constraintWithItem:infoButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:aleBoardImageView attribute:NSLayoutAttributeRight multiplier:1 constant:-10]];
	}

	/* 
	 * De-ambiguize the ScrollView.
	 */
	NSMutableString *horizontalImageViewConstraints = [@"H:|-(SEP)-" mutableCopy];
	NSMutableString *horizontalVenueNameConstraints = [@"H:|-(SEP)-" mutableCopy];
	NSMutableString *horizontaLastUpdatedConstraints = [@"H:|-(SEP)-" mutableCopy];
	for (NSUInteger i = 0; i < numberOfLocations; i++) {
		[horizontalImageViewConstraints appendString:[NSString stringWithFormat:@"[aleBoardImageView%lu(==WIDTH)]", (long unsigned)i]];
		[horizontalVenueNameConstraints appendString:[NSString stringWithFormat:@"[venueNameLabel%lu(==WIDTH)]", (long unsigned)i]];
		[horizontaLastUpdatedConstraints appendString:[NSString stringWithFormat:@"[lastUpdatedLabel%lu(==WIDTH)]", (long unsigned)i]];
		if (i == (numberOfLocations - 1)) {
			[horizontalImageViewConstraints appendString:@"-(SEP)-|"];
			[horizontalVenueNameConstraints appendString:@"-(SEP)-|"];
			[horizontaLastUpdatedConstraints appendString:@"-(SEP)-|"];
		} else {
			[horizontalImageViewConstraints appendString:@"-(SEP2)-"];
			[horizontalVenueNameConstraints appendString:@"-(SEP2)-"];
			[horizontaLastUpdatedConstraints appendString:@"-(SEP2)-"];
		}
	}
	[scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalImageViewConstraints options:0 metrics:metrics views:views]];
	[scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalVenueNameConstraints options:0 metrics:metrics views:views]];
	[scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontaLastUpdatedConstraints options:0 metrics:metrics views:views]];
}

- (void)refreshLabelsAndImages
{
	NSUInteger numberOfLocations = [self.downloader.aleBoardsData count];
	self.lastRetrievedData = [@[] mutableCopy];

	for (NSUInteger i = 0; i < numberOfLocations; i++) {
		((UILabel *)self.lastUpdatedLabels[i]).attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Never", @"Last updated label when it has not been updated") attributes:self.lastUpdatedLabelAttributes];

		[self.downloader downloadAleBoardAtIndex:i completionHandler:^(UIImage *image, NSDate *lastModifiedDate, NSError *error) {
			if (error == nil) {
				if ((lastModifiedDate != nil) && (image != nil)) {
					[self.lastRetrievedData addObject:@{kDFHABVCLastModifiedDateKey : lastModifiedDate, kDFHABVCAleBoardImageKey : image, kDFHABVCLocationIndexKey : @(i)}];
					[self performSelectorOnMainThread:@selector(displayLabelsAndImages:) withObject:[self.lastRetrievedData lastObject] waitUntilDone:NO];
				} else
					[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Could not receive data.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Okay", nil) otherButtonTitles:nil] show];
			} else
				[[[UIAlertView alloc] initWithTitle:error.localizedFailureReason message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"Okay", nil) otherButtonTitles:nil] show];
		}];
	}
}

- (void)displayLabelsAndImages:(NSDictionary *)data
{
	static NSDateFormatter *dateFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dateFormatter = [NSDateFormatter new];
		dateFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
		dateFormatter.doesRelativeDateFormatting = YES;
		dateFormatter.dateStyle = NSDateFormatterShortStyle;
		dateFormatter.timeStyle = NSDateFormatterShortStyle;
	});

	NSUInteger location = [data[kDFHABVCLocationIndexKey] unsignedIntegerValue];
	NSDictionary *locationInfo = [self.downloader informationAtIndex:location];
	((UILabel *)self.venueNameLabels[location]).attributedText = [[NSAttributedString alloc] initWithString:locationInfo[kDFHNameKey] attributes:self.venueNameLabelAttributes];
	((UIImageView *)self.aleBoardImageViews[location]).image = data[kDFHABVCAleBoardImageKey];
	((UILabel *)self.lastUpdatedLabels[location]).attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Last Updated", @"Prefix for last updated time"), [dateFormatter stringFromDate:data[kDFHABVCLastModifiedDateKey]]] attributes:self.lastUpdatedLabelAttributes];
}

- (void)restoreLabelsAndImages
{
	for (NSUInteger i = 0; i < [self.lastRetrievedData count]; i++)
		[self displayLabelsAndImages:self.lastRetrievedData[i]];
}

#pragma mark - Actions

- (void)pageControlChangedPage:(UIPageControl *)pageControl
{
	/* Loop back to beginning */
	if (pageControl.currentPage == pageControl.numberOfPages)
		[pageControl setCurrentPage:0];
	[self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * pageControl.currentPage, 0) animated:YES];

	[pageControl updateCurrentPageDisplay];
}

- (void)infoButtonPressed:(UIButton *)sender
{
	DFHLocationInformationViewController *vc = [DFHLocationInformationViewController new];
	vc.locationInformation = self.downloader.aleBoardsData[sender.tag];
	[self presentViewController:vc animated:YES completion:NULL];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	/* Update the page when more than 50% of the previous/next page is visible */
	CGFloat pageWidth = scrollView.frame.size.width;
	NSUInteger page = lroundf(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1);
	self.pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	for (UIButton *button in self.infoButtons)
		[UIView animateWithDuration:0.1 animations:^(){ button.alpha = 0.0; }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	for (UIButton *button in self.infoButtons)
		[UIView animateWithDuration:0.7 animations:^(){ button.alpha = 1.0; }];
}

#pragma mark - Notifications

- (void)refreshDynamicType:(NSNotification *)notification
{
	NSMutableParagraphStyle *centeredParagraphStyle = [[NSMutableParagraphStyle alloc] init];
	centeredParagraphStyle.alignment = NSTextAlignmentCenter;

	self.venueNameLabelAttributes = @{NSFontAttributeName : [UIFont preferredDogfishFontForTextStyle:UIFontTextStyleHeadline], NSParagraphStyleAttributeName : centeredParagraphStyle};
	self.lastUpdatedLabelAttributes = @{NSFontAttributeName : [UIFont preferredDogfishFontForTextStyle:UIFontTextStyleCaption1], NSParagraphStyleAttributeName : centeredParagraphStyle};

	if (notification != nil)
		[self refreshLabelsAndImages];
}

@end
