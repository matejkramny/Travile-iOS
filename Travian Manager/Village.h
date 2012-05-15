//
//  Village.h
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TravianPageParsingProtocol.h"

@class Resources;
@class HTMLNode;

@interface Village : NSObject <NSCoding, TravianPageParsingProtocol, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) Resources *resources; // Village resources
@property (nonatomic, strong) Resources *resourceProduction; // Village resource production / hour
@property (nonatomic, strong) NSArray *troops; // Village troops
@property (nonatomic, strong) NSArray *movements; // Village movements
@property (nonatomic, strong) NSString *name; // Village's name
@property (nonatomic, strong) NSString *urlPart; // Village ID required for switching villages in url
@property (assign) int population; // Village population
@property (assign) int loyalty; // Village loyalty
@property (assign) unsigned int warehouse; // Max storage of resources (other than wheat)
@property (assign) unsigned int granary; // Max storage wheat
@property (assign) unsigned int consumption; // Consuming / hour
@property (assign) int x; // Location X
@property (assign) int y; // Location Y

@property (nonatomic, strong) NSURLConnection *villageConnection; // Village connection
@property (nonatomic, strong) NSMutableData *villageData; // Village data

- (void)downloadAndParse;

@end
