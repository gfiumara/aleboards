//
//  DFHAleBoardDownloader.h
//  AleBoards
//
//  Created by Greg Fiumara on 12/10/13.
//  Copyright (c) 2013 Greg Fiumara. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Key for the HTTP header of when the AleBoard image was last modified. */
static NSString * const kDFHLastModifiedKey = @"Last-Modified";

@interface DFHAleBoardDownloader : NSObject

@property (nonatomic, strong) NSArray *aleBoardsData;

- (instancetype)init;
- (NSDictionary *)informationAtIndex:(NSUInteger)index;
- (void)downloadAleBoardAtIndex:(NSUInteger)index completionHandler:(void (^)(UIImage *image, NSDate *lastUpdateDate, NSError *error))completionHandler;


@end
