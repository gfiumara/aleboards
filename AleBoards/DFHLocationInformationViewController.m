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
@property (nonatomic, weak) UIButton *addressLabel;
@property (nonatomic, weak) UIButton *phoneNumberLabel;
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

	UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
	logoButton.translatesAutoresizingMaskIntoConstraints = NO;
	[logoButton addTarget:self action:@selector(openWebsite:) forControlEvents:UIControlEventTouchUpInside];
	[logoButton setImage:[UIImage imageNamed:kDFHDogfishLogoName] forState:UIControlStateNormal];
	[self.view addSubview:logoButton];

	UILabel *nameLabel = [UILabel new];
	nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
	nameLabel.attributedText = [[NSAttributedString alloc] initWithString:self.locationInformation[kDFHNameKey] attributes:self.nameLabelAttributes];
	self.nameLabel = nameLabel;
	[self.view addSubview:nameLabel];

	UIButton *addressLabel = [UIButton buttonWithType:UIButtonTypeCustom];
	addressLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[addressLabel setAttributedTitle:[[NSAttributedString alloc] initWithString:self.locationInformation[kDFHAddressKey] attributes:self.detailsAttributes] forState:UIControlStateNormal];
	[addressLabel setAttributedTitle:[[NSAttributedString alloc] initWithString:self.locationInformation[kDFHAddressKey] attributes:self.detailsAttributesSelected] forState:UIControlStateHighlighted];
	addressLabel.titleLabel.numberOfLines = 0;
	[addressLabel addTarget:self action:@selector(handleAddressTap) forControlEvents:UIControlEventTouchUpInside];
	self.addressLabel = addressLabel;
	[self.view addSubview:addressLabel];

	UIButton *phoneNumberLabel = [UIButton buttonWithType:UIButtonTypeCustom];
	phoneNumberLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[phoneNumberLabel setAttributedTitle:[[NSAttributedString alloc] initWithString:[DFHLocationInformationViewController formatPhoneNumber:self.locationInformation[kDFHPhoneNumberKey]] attributes:self.detailsAttributes] forState:UIControlStateNormal];
	[phoneNumberLabel setAttributedTitle:[[NSAttributedString alloc] initWithString:[DFHLocationInformationViewController formatPhoneNumber:self.locationInformation[kDFHPhoneNumberKey]] attributes:self.detailsAttributesSelected] forState:UIControlStateHighlighted];
	[phoneNumberLabel addTarget:self action:@selector(handlePhoneNumberTap) forControlEvents:UIControlEventTouchUpInside];
	phoneNumberLabel.titleLabel.numberOfLines = 0;
	self.phoneNumberLabel = phoneNumberLabel;
	[self.view addSubview:phoneNumberLabel];

	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
	closeButton.translatesAutoresizingMaskIntoConstraints = NO;
	[closeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Done", @"Caption for close button on location information") attributes:self.closeButtonAttributes] forState:UIControlStateNormal];
	[closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.closeButton = closeButton;
	[self.view addSubview:closeButton];

	NSDictionary *views = NSDictionaryOfVariableBindings(nameLabel, addressLabel, phoneNumberLabel, closeButton, logoButton);

	/* Centering */
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:logoButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:addressLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:phoneNumberLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

	/* Vertical center of address label */
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:addressLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[logoButton(==105)]" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[logoButton(==60)]-[nameLabel]" options:0 metrics:nil views:views]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[phoneNumberLabel]-[closeButton]-|" options:0 metrics:nil views:views]];
}

+ (NSString *)formatPhoneNumber:(NSString *)unformattedPhoneNumber
{
	if ([unformattedPhoneNumber length] != 10)
		return (unformattedPhoneNumber);

	return ([NSString stringWithFormat:@"(%@) %@-%@", [unformattedPhoneNumber substringWithRange:NSMakeRange(0, 3)], [unformattedPhoneNumber substringWithRange:NSMakeRange(3, 3)], [unformattedPhoneNumber substringWithRange:NSMakeRange(6, 4)]]);
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

- (void)openWebsite:(UIButton *)sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.locationInformation[kDFHWebsite]]];
}

- (void)handlePhoneNumberTap
{
	if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]])
		return;

	UIActionSheet *actionSheet = [UIActionSheet new];
	actionSheet.tag = kDFHActionSheetTagPhone;
	actionSheet.delegate = self;
	[actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@ %@...", NSLocalizedString(@"Call", @"Prefix for ActionSheet button to call location"), self.phoneNumberLabel.titleLabel.text]];
	actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"Title for Cancel button on ActionSheet")];
	[actionSheet showInView:self.view];
}

- (void)callLocation
{
	NSURL *telephoneNumber = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", self.locationInformation[kDFHPhoneNumberKey]]];
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
	self.detailsAttributes = @{NSFontAttributeName : [UIFont preferredDogfishFontForTextStyle:UIFontTextStyleHeadline], NSParagraphStyleAttributeName : centeredParagraphStyle};
	self.detailsAttributesSelected = @{NSFontAttributeName : [UIFont preferredDogfishFontForTextStyle:UIFontTextStyleHeadline], NSParagraphStyleAttributeName : centeredParagraphStyle, NSForegroundColorAttributeName : [UIColor dogfishGreen]};
	self.closeButtonAttributes = @{NSFontAttributeName : [UIFont preferredDogfishFontForTextStyle:UIFontTextStyleCaption1]};

	if (notification != nil) {
		self.nameLabel.attributedText = [[NSAttributedString alloc] initWithString:self.nameLabel.attributedText.string attributes:self.nameLabelAttributes];
		[self.addressLabel setAttributedTitle:[[NSAttributedString alloc] initWithString:self.addressLabel.titleLabel.text attributes:self.detailsAttributes] forState:UIControlStateNormal];
		[self.addressLabel setAttributedTitle:[[NSAttributedString alloc] initWithString:self.addressLabel.titleLabel.text attributes:self.detailsAttributesSelected] forState:UIControlStateHighlighted];
		[self.phoneNumberLabel setAttributedTitle:[[NSAttributedString alloc] initWithString:self.phoneNumberLabel.titleLabel.text attributes:self.detailsAttributes] forState:UIControlStateNormal];
		[self.phoneNumberLabel setAttributedTitle:[[NSAttributedString alloc] initWithString:self.phoneNumberLabel.titleLabel.text attributes:self.detailsAttributesSelected] forState:UIControlStateHighlighted];
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
