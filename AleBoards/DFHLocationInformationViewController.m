//
//  DFHLocationInformationViewController.m
//  AleBoards
//
//  Created by Greg Fiumara on 12/11/13.
//  Copyright (c) 2013 Greg Fiumara. All rights reserved.
//

#import "UIColor+Dogfish.h"
#import "UIFont+Dogfish.h"
#import "DFHConstants.h"
#import "DFHLocationInformationViewController.h"

@interface DFHLocationInformationViewController ()

@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *addressLabel;
@property (nonatomic, weak) UILabel *phoneNumberLabel;
@property (nonatomic, weak) UIButton *closeButton;

/* Dynamic Type */
@property (nonatomic, strong) NSDictionary *nameLabelAttributes;
@property (nonatomic, strong) NSDictionary *detailsAttributes;
@property (nonatomic, strong) NSDictionary *detailsAttributesSelected;
@property (nonatomic, strong) NSDictionary *closeButtonAttributes;

/* Action Sheet */
@property (nonatomic, assign) NSUInteger googleMapsActionSheetIndex;
@property (nonatomic, assign) NSUInteger appleMapsActionSheetIndex;

@end

@implementation DFHLocationInformationViewController

#pragma mark - Instantiation

- (instancetype)initWithLocationInformation:(NSDictionary *)locationInformation
{
	self = [super init];
	if (self == nil)
		return (nil);

	self.locationInformation = locationInformation;

	return (self);
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self refreshDynamicType:nil];
	[self autolayout];
}

- (void)viewWillAppear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDynamicType:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

#pragma mark - Layout

- (void)autolayout
{
	self.view.backgroundColor = [UIColor whiteColor];

	UILabel *nameLabel = [UILabel new];
	nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
	nameLabel.attributedText = [[NSAttributedString alloc] initWithString:self.locationInformation[kDFHNameKey] attributes:self.nameLabelAttributes];
	self.nameLabel = nameLabel;
	[self.view addSubview:nameLabel];

	UILabel *addressLabel = [UILabel new];
	addressLabel.translatesAutoresizingMaskIntoConstraints = NO;
	addressLabel.attributedText = [[NSAttributedString alloc] initWithString:self.locationInformation[kDFHAddressKey] attributes:self.detailsAttributes];
	addressLabel.numberOfLines = 0;
	[addressLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAddressTap)]];
	addressLabel.userInteractionEnabled = YES;
	self.addressLabel = addressLabel;
	[self.view addSubview:addressLabel];

	UILabel *phoneNumberLabel = [UILabel new];
	phoneNumberLabel.translatesAutoresizingMaskIntoConstraints = NO;
	phoneNumberLabel.attributedText = [[NSAttributedString alloc] initWithString:self.locationInformation[kDFHPhoneNumberKey] attributes:self.detailsAttributes];
	[phoneNumberLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePhoneNumberTap)]];
	phoneNumberLabel.userInteractionEnabled = YES;
	self.phoneNumberLabel = phoneNumberLabel;
	[self.view addSubview:phoneNumberLabel];

	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
	closeButton.translatesAutoresizingMaskIntoConstraints = NO;
	[closeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Done", @"Caption for close button on location information") attributes:self.closeButtonAttributes] forState:UIControlStateNormal];
	[closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.closeButton = closeButton;
	[self.view addSubview:closeButton];

	NSDictionary *views = NSDictionaryOfVariableBindings(nameLabel, addressLabel, phoneNumberLabel, closeButton);

	/* Centering */
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:addressLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:phoneNumberLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

	/* Vertical center of address label */
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:addressLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[nameLabel]" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[phoneNumberLabel]-[closeButton]-|" options:0 metrics:nil views:views]];
}

#pragma mark - Actions

- (void)closeButtonPressed:(UIButton *)sender
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)textPressed:(UILabel *)sender
{
	sender.attributedText = [[NSAttributedString alloc] initWithString:sender.attributedText.string attributes:self.detailsAttributesSelected];
}

- (void)textReleased:(UILabel *)sender
{
	sender.attributedText = [[NSAttributedString alloc] initWithString:sender.attributedText.string attributes:self.detailsAttributes];
}

- (void)handlePhoneNumberTap
{
	if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]])
		return;

	UIActionSheet *actionSheet = [UIActionSheet new];
	actionSheet.tag = kDFHActionSheetTagPhone;
	actionSheet.delegate = self;
	[actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@ %@...", NSLocalizedString(@"Call", @"Prefix for ActionSheet button to call location"), self.phoneNumberLabel.text]];
	actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"Title for Cancel button on ActionSheet")];
	[actionSheet showInView:self.view];
}

- (void)callLocation
{
	NSURL *telephoneNumber = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", self.phoneNumberLabel.text]];
	if ([[UIApplication sharedApplication] canOpenURL:telephoneNumber])
		[[UIApplication sharedApplication] openURL:telephoneNumber];
}

- (void)mapLocationInAppleMaps
{
	NSString *addressString = [[self.locationInformation[kDFHAddressKey] stringByReplacingOccurrencesOfString:@"\n" withString:@", "] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@&ll=%@,%@", addressString, [self.locationInformation[kDFHLocationLatitude] stringValue], [self.locationInformation[kDFHLocationLongitude] stringValue]]]];
}

- (BOOL)googleMapsInstalled
{
	return ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]);
}

- (void)mapLocationInGoogleMaps
{
	if (![self googleMapsInstalled])
		return;

	NSString *addressString = [[self.locationInformation[kDFHAddressKey] stringByReplacingOccurrencesOfString:@"\n" withString:@", "] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps:///?daddr=%@&center=%@,%@", addressString, [self.locationInformation[kDFHLocationLatitude] stringValue], [self.locationInformation[kDFHLocationLongitude] stringValue]]]];
}

#pragma mark - Notifications

- (void)refreshDynamicType:(NSNotification *)notification
{
	NSMutableParagraphStyle *centeredParagraphStyle = [[NSMutableParagraphStyle alloc] init];
	centeredParagraphStyle.alignment = NSTextAlignmentCenter;
	
	self.nameLabelAttributes = @{NSFontAttributeName : [UIFont preferredDogfishFontForTextStyle:UIFontTextStyleHeadline]};
	self.detailsAttributes = @{NSFontAttributeName : [UIFont preferredDogfishFontForTextStyle:UIFontTextStyleCaption1], NSParagraphStyleAttributeName : centeredParagraphStyle};
	self.detailsAttributesSelected = @{NSFontAttributeName : [UIFont preferredDogfishFontForTextStyle:UIFontTextStyleCaption1], NSForegroundColorAttributeName : [UIColor dogfishGreen]};
	self.closeButtonAttributes = @{NSFontAttributeName : [UIFont preferredDogfishFontForTextStyle:UIFontTextStyleCaption1]};

	if (notification != nil) {
		self.nameLabel.attributedText = [[NSAttributedString alloc] initWithString:self.nameLabel.attributedText.string attributes:self.nameLabelAttributes];
		self.addressLabel.attributedText = [[NSAttributedString alloc] initWithString:self.addressLabel.attributedText.string attributes:self.detailsAttributes];
		self.phoneNumberLabel.attributedText = [[NSAttributedString alloc] initWithString:self.phoneNumberLabel.attributedText.string attributes:self.detailsAttributes];
		[self.closeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:[self.closeButton attributedTitleForState:UIControlStateNormal].string attributes:self.closeButtonAttributes] forState:UIControlStateNormal];
	}
}

#pragma mark - Maps Action Sheet

- (void)handleAddressTap
{
	if (![self googleMapsInstalled])
		[self mapLocationInAppleMaps];
	else {
		UIActionSheet *actionSheet = [UIActionSheet new];
		actionSheet.delegate = self;
		actionSheet.tag = kDFHActionSheetTagMaps;
		self.googleMapsActionSheetIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Google Maps...", @"Title for button to open map in Google Maps")];
		self.appleMapsActionSheetIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Apple Maps...", @"Title for button to open map in Apple Maps")];
		actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"Title for Cancel button on ActionSheet")];
		[actionSheet showInView:self.view];
	}
}

static const NSUInteger kDFHActionSheetTagMaps = 1;
static const NSUInteger kDFHActionSheetTagPhone = 2;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.cancelButtonIndex)
		return;
	switch (actionSheet.tag) {
	case kDFHActionSheetTagMaps:
		if (buttonIndex == self.googleMapsActionSheetIndex)
			[self mapLocationInGoogleMaps];
		else if (buttonIndex == self.appleMapsActionSheetIndex)
			[self mapLocationInAppleMaps];
		break;
	case kDFHActionSheetTagPhone:
		[self callLocation];
		break;
	}
}

@end
