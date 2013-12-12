//
//  UIFont+Dogfish.m
//  AleBoards
//
//  Created by Greg Fiumara on 12/11/13.
//  Copyright (c) 2013 Greg Fiumara. All rights reserved.
//

#import "UIFont+Dogfish.h"

@implementation UIFont (Dogfish)

+ (UIFont *)preferredDogfishFontForTextStyle:(NSString *)style;
{
	CGFloat fontSize = 16.0;
	NSString *preferredContentSizeCategory = [UIApplication sharedApplication].preferredContentSizeCategory;

	/* 
	 * XXX: Taking a bit of a cheap route out, since we're currently only
	 * using two text styles.
	 */
	if ([style isEqualToString:UIFontTextStyleHeadline]) {
		if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategoryExtraSmall])
			fontSize = 12.0;
		else if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategorySmall])
			fontSize = 14.0;
		else if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategoryMedium])
			fontSize = 16.0;
		else if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategoryLarge])
			fontSize = 18.0;
		else if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategoryExtraLarge])
			fontSize = 20.0;
		else if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategoryExtraExtraLarge])
			fontSize = 22.0;
		else if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge])
			fontSize = 24.0;
	} else if ([style isEqualToString:UIFontTextStyleCaption1]) {
		if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategoryExtraSmall])
			fontSize = 6.0;
		else if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategorySmall])
			fontSize = 8.0;
		else if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategoryMedium])
			fontSize = 10.0;
		else if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategoryLarge])
			fontSize = 12.0;
		else if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategoryExtraLarge])
			fontSize = 14.0;
		else if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategoryExtraExtraLarge])
			fontSize = 16.0;
		else if ([preferredContentSizeCategory isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge])
			fontSize = 18.0;
	}

	return ([UIFont fontWithName:kDFHDogfishFontName size:fontSize]);
}

@end
