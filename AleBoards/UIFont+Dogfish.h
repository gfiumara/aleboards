//
//  UIFont+Dogfish.h
//  AleBoards
//
//  Created by Greg Fiumara on 12/11/13.
//  Copyright (c) 2013 Greg Fiumara. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kDFHDogfishFontName = @"dogfish";

@interface UIFont (Dogfish)

+ (UIFont *)preferredDogfishFontForTextStyle:(NSString *)style;

@end
