//
//  DFHAleBoardDownloader.m
//  AleBoards
//
//  Created by Greg Fiumara on 12/10/13.
//  Copyright (c) 2013 Greg Fiumara. All rights reserved.
//

#import "DFHAleBoardDownloader.h"

@implementation DFHAleBoardDownloader

static NSString * const kDFHAleboardsPlist = @"aleboards";

- (instancetype)init
{
	self = [super init];
	if (self == nil)
		return (nil);

	if (![self loadLocationInformation])
		return (nil);

	return (self);
}

#pragma mark - Information I/O

/** @return YES if data could be loaded, NO otherwise */
- (BOOL)loadLocationInformation
{
	/* TODO: Download remote plist */
	self.aleBoardsData = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kDFHAleboardsPlist ofType:@"plist"]];
	return (self.aleBoardsData != nil);
}

- (NSDictionary *)informationAtIndex:(NSUInteger)index
{
	if (index >= [self.aleBoardsData count])
		return (nil);

	return (self.aleBoardsData[index]);
}

@end
