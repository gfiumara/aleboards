//
//  DFHAleBoardsViewController.m
//  AleBoards
//
//  Created by Greg Fiumara on 12/10/13.
//  Copyright (c) 2013 Greg Fiumara. All rights reserved.
//

#import "UIColor+Dogfish.h"
#import "UIFont+Dogfish.h"
#import "DFHAleBoardDownloader.h"

#import "DFHAleBoardsViewController.h"

static NSString * const kDFHLocationIndexKey = @"locationIndex";
static NSString * const kDFHAleBoardImageKey = @"image";

@interface DFHAleBoardsViewController ()

@property (nonatomic, strong) DFHAleBoardDownloader *downloader;

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

	NSDictionary *metrics = @{@"WIDTH" : @(CGRectGetHeight(self.view.frame) - 30.0), @"SEP" : @(15.0), @"SEP2" : @(30.0)};
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
	for (NSUInteger i = 0; i < numberOfLocations; i++) {
		NSDictionary *locationInfo = [self.downloader informationAtIndex:i];
		((UILabel *)self.venueNameLabels[i]).attributedText = [[NSAttributedString alloc] initWithString:locationInfo[kDFHNameKey] attributes:self.venueNameLabelAttributes];
		((UILabel *)self.lastUpdatedLabels[i]).attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Never", @"Last updated label when it has not been updated") attributes:self.lastUpdatedLabelAttributes];

		[self.downloader downloadAleBoardAtIndex:i completionHandler:^(UIImage *image, NSDate *lastModifiedDate, NSError *error) {
			if (error == nil) {
				NSDictionary *data = @{kDFHLastModifiedKey : lastModifiedDate, kDFHAleBoardImageKey : image, kDFHLocationIndexKey : @(i)};
				[self performSelectorOnMainThread:@selector(displayLabelsAndImages:) withObject:data waitUntilDone:NO];
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

	NSUInteger location = [data[kDFHLocationIndexKey] unsignedIntegerValue];
	((UIImageView *)self.aleBoardImageViews[location]).image = data[kDFHAleBoardImageKey];
	((UILabel *)self.lastUpdatedLabels[location]).attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Last Updated", @"Prefix for last updated time"), [dateFormatter stringFromDate:data[kDFHLastModifiedKey]]] attributes:self.lastUpdatedLabelAttributes];
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

}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	/* Update the page when more than 50% of the previous/next page is visible */
	CGFloat pageWidth = self.scrollView.frame.size.width;
	NSUInteger page = lroundf(floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1);
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
