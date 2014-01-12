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

#import "DFHConstants.h"

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

	NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
	self.lastModifiedDateFormatter.locale = enUSPOSIXLocale;
	NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	gregorianCalendar.locale = enUSPOSIXLocale;
	gregorianCalendar.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
	self.lastModifiedDateFormatter.calendar = gregorianCalendar;

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
