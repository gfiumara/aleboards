//
//  DFHAleBoardDownloader.m
//  AleBoards
//
//  Created by Greg Fiumara on 12/10/13.
//  Copyright (c) 2013 Greg Fiumara. All rights reserved.
//

#import "DFHAleBoardDownloader.h"

@interface DFHAleBoardDownloader()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSDateFormatter *lastModifiedDateFormatter;

@end

@implementation DFHAleBoardDownloader

static NSString * const kDFHAleboardsPlist = @"aleboards";

- (instancetype)init
{
	self = [super init];
	if (self == nil)
		return (nil);

	if (![self loadLocationInformation])
		return (nil);

	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	configuration.URLCache = nil;
	configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	self.session = [NSURLSession sessionWithConfiguration:configuration];

	self.lastModifiedDateFormatter = [[NSDateFormatter alloc] init];
	self.lastModifiedDateFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
	self.lastModifiedDateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z";

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

- (void)downloadAleBoardAtIndex:(NSUInteger)index completionHandler:(void (^)(UIImage *image, NSDate *lastUpdatedDate, NSError *error))completionHandler
{
	if (index >= [self.aleBoardsData count])
		return;

	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.aleBoardsData[index][kDFHAleBoardURL]]];
	[[self.session dataTaskWithRequest:request completionHandler:^(NSData *data,  NSURLResponse *response, NSError *error) {
		if (completionHandler == nil)
			return;

		if (error == nil)
			completionHandler([UIImage imageWithData:data], [self.lastModifiedDateFormatter dateFromString:((NSHTTPURLResponse *)response).allHeaderFields[kDFHLastModifiedKey]], error);
		else
			completionHandler(nil, nil, error);
	}] resume];
}


@end
