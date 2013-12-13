//
//  DFHLocationInformationViewController.h
//  AleBoards
//
//  Created by Greg Fiumara on 12/11/13.
//  Copyright (c) 2013 Greg Fiumara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFHLocationInformationViewController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, strong) NSDictionary *locationInformation;

- (instancetype)initWithLocationInformation:(NSDictionary *)locationInformation;

@end
