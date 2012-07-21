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
}

@property (nonatomic, strong) NSString *title; // Message title
@property (nonatomic, strong) NSString *content; // Message conttent
@property (nonatomic, strong) NSString *href; // Download link
@property (nonatomic, strong) NSString *when; // Date received
@property (assign) bool read; // Flags message status

- (void)downloadAndParse;
- (void)delete;
- (void)send:(NSString *)recipient;

@end
