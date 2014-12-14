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

/*
 * Resources
 */

/** Name of the logo for Dogfish Head Alehouse */
static NSString * const kDFHDogfishLogoName = @"dfha_logo";

#endif /* __DHF_CONSTANTS_H__ */
