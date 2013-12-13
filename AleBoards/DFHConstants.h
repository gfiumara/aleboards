//
//  DFHConstants.h
//  AleBoards
//
//  Created by Greg Fiumara on 12/11/13.
//  Copyright (c) 2013 Greg Fiumara. All rights reserved.
//

#ifndef __DHF_CONSTANTS_H__
#define __DHF_CONSTANTS_H__

/*
 * Keys
 */

/** Key for location name in all dictionaries. */
static NSString * const kDFHNameKey = @"name";
/** Key for the unformatted string of the location phone number name in all dictionaries. */
static NSString * const kDFHPhoneNumberKey = @"phoneNumber";
/** Key for the multiline string of the location address in all dictionaries. */
static NSString * const kDFHAddressKey = @"address";
/** Key for string of the URL to the location's website in all dictionaries. */
static NSString * const kDFHWebsite = @"website";
/** Key for string of the URL to the AleBoard image in all dictionaries. */
static NSString * const kDFHAleBoardURL = @"aleBoardURL";
/** Key for latitude decimal number of the location. */
static NSString * const kDFHLocationLatitude = @"latitude";
/** Key for longitude decimal number of the location. */
static NSString * const kDFHLocationLongitude = @"longitude";

#endif /* __DHF_CONSTANTS_H__ */
