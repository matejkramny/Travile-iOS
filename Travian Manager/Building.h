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

@property (nonatomic, strong) NSString *bid; // Building access ID
@property (assign) TravianBuildings gid; // Building GID
@property (nonatomic, strong) NSString *name; // Building Name (localised in browser)
@property (nonatomic, strong) NSString *description; // What building does (^)
@property (assign) TravianPages page; // TPVillage | TPResource
@property (nonatomic, strong) Resources *resources; // Required resources to build/upgrade this building
@property (assign) int level; // Building level
@property (nonatomic, strong) NSArray *availableBuildings; // When user wants to build something on empty spot (gid0) then this array is used as a list of what user can build on that location. List contains objects typeof Building
@property (assign) bool finishedLoading;
@property (nonatomic, strong) NSString *upgradeURLString; // Serves as container for contract link
@property (nonatomic, strong) NSString *cannotBuildReason; // Reason we cannot build
@property (nonatomic, strong) NSArray *buildConditions; // List of build conditions

@property (nonatomic, weak) Village *parent;

- (void)buildFromAccount:(Account *)account;
- (void)fetchDescription;
- (void)fetchDescriptionFromNode:(HTMLNode *)node;
- (void)buildFromURL:(NSURL *)url;

@end
