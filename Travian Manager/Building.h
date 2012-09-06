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

@class BuildingAction;
@class Village;
@class Resources;
@class Account;
@class Coordinate;
@class HTMLNode;

@interface Building : NSObject <NSCoding, NSURLConnectionDataDelegate, NSURLConnectionDelegate, TravianPageParsingProtocol>

@property (nonatomic, strong) NSString *bid; // Building access ID
@property (assign) TravianBuildings gid; // Building GID
@property (nonatomic, strong) NSString *name; // Building Name (localised in browser)
@property (nonatomic, strong) NSString *description; // What building does (^)
@property (nonatomic, strong) NSDictionary *properties; // Building properties.
@property (assign) TravianPages page; // TPVillage | TPResource
@property (nonatomic, strong) Resources *resources; // Required resources to build/upgrade this building
@property (assign) int level; // Building level
@property (nonatomic, strong) NSArray *availableBuildings; // When user wants to build something on empty spot (gid0) then this array is used as a list of what user can build on that location. List contains objects typeof Building
@property (assign) bool finishedLoading;
@property (nonatomic, strong) NSString *upgradeURLString; // Serves as container for contract link
@property (nonatomic, strong) NSString *cannotBuildReason; // Reason we cannot build
@property (nonatomic, strong) NSArray *buildConditionsDone; // List of build conditions
@property (nonatomic, strong) NSArray *buildConditionsError; // Errorneous build conditons (unfulfilled)
@property (assign) CGPoint coordinates; // Where the building is on a visual map
@property (assign) bool isBeingUpgraded; // Indicates whether this building is being currently upgraded.
@property (nonatomic, strong) NSArray *actions; // Building Actions - such as Research a troop
@property (nonatomic, strong) HTMLNode *buildDiv; // Contract HTMLNode

// Building in what village?
@property (nonatomic, weak) Village *parent;

@property (nonatomic, strong) NSString *finishedLoadingKVOIdentifier; // Holds value that tells other objects what key to observe if they want to check whether the object has finished loading

- (void)buildFromAccount:(Account *)account;
- (void)fetchDescription;
- (void)fetchDescriptionFromNode:(HTMLNode *)node;
- (void)buildFromURL:(NSURL *)url;
- (void)fetchContractConditionsFromContractID:(HTMLNode *)contract;
- (void)fetchResourcesFromContract:(HTMLNode *)contract;
- (void)fetchActionsFromIDBuild:(HTMLNode *)buildID;

@end
