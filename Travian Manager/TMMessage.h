// This code is distributed under the terms and conditions of the MIT license.

/* * Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial
 * portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
 * OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import "TravianPageParsingProtocol.h"

@interface TMMessage : NSObject <TMPageParsingProtocol, NSCoding, NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
	NSURLConnection *messageConnection;
	NSMutableData *messageData;
	NSURLConnection *sendParameterConnection;
	NSMutableData *sendParameterData;
}

@property (nonatomic, strong) NSString *sender; // Sender's name
@property (nonatomic, strong) NSString *title; // Message title
@property (nonatomic, strong) NSString *content; // Message conttent
@property (nonatomic, strong) NSString *href; // Download link
@property (nonatomic, strong) NSString *when; // Date received
@property (assign) bool read; // Flags message status
@property (nonatomic, strong) NSString *accessID; // Unique message ID
@property (nonatomic, strong) NSString *sendParameter; // this is included to POST request data when sending new message
@property (assign) bool sent; // Other objects who want to send message can observe this bool for YES

- (void)downloadAndParse;
- (void)delete;
- (void)send:(NSString *)recipient;
- (void)parseSendParameter:(HTMLNode *)node;

@end
