//
//  Building.h
//  Travian Manager
//
//  Created by Matej Kramny on 22/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TravianPages.h"
#import "TravianPageParsingProtocol.h"

@class Village;
@class Resources;
@class Account;

@interface Building : NSObject <NSCoding, NSURLConnectionDataDelegate, NSURLConnectionDelegate, TravianPageParsingProtocol>

@property (nonatomic, strong) NSString *bid; // Building ID
@property (nonatomic, strong) NSString *name; // Building Name (localised in browser)
@property (assign) TravianPages page; // TPVillage | TPResource
@property (nonatomic, strong) Resources *resources; // Required resources to build/upgrade this building
@property (assign) int level; // Building level

@property (nonatomic, weak) Village *parent;
@property (nonatomic, strong) NSURLConnection *buildConnection;
@property (nonatomic, strong) NSMutableData *buildData;

- (void)buildFromAccount:(Account *)account;

@end
