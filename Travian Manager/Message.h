//
//  Message.h
//  Travian Manager
//
//  Created by Matej Kramny on 27/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TravianPageParsingProtocol.h"

@interface Message : NSObject <TravianPageParsingProtocol, NSCoding, NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
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
