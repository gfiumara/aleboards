//
//  DFHAleBoardDownloader.h
//  AleBoards
//
//  Created by Greg Fiumara on 12/10/13.
//  Copyright (c) 2013 Greg Fiumara. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kDFHNameKey = @"name";
static NSString * const kDFHPhoneNumberKey = @"phoneNumber";
static NSString * const kDFHAddressKey = @"address";
static NSString * const kDFHWebsite = @"website";
static NSString * const kDFHAleBoardURL = @"aleBoardURL";

@interface DFHAleBoardDownloader : NSObject

@property (nonatomic, strong) NSArray *aleBoardsData;

- (instancetype)init;
- (NSDictionary *)informationAtIndex:(NSUInteger)index;

@end
