/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "TravianPageParsingProtocol.h"

@class TMResources;
@class TMResourcesProduction;
@class HTMLNode;
@class TMAccount;
@class TMFarmList;

@interface TMVillage : NSObject <NSCoding, TMPageParsingProtocol, NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
	__weak TMAccount *parent;
}

@property (nonatomic, strong) TMResources *resources; // Village resources
@property (nonatomic, strong) TMResourcesProduction *resourceProduction; // Village resource production / hour
@property (nonatomic, strong) NSArray *troops; // Village troops
@property (nonatomic, strong) NSArray *movements; // Village movements
@property (nonatomic, strong) NSMutableArray *buildings; // Buildings (including resource fields)
@property (nonatomic, strong) NSArray *constructions; // Construction list
@property (nonatomic, strong) NSString *name; // Village's name
@property (nonatomic, strong) NSString *urlPart; // Village ID required for switching villages in url
@property (assign) int population; // Village population
@property (assign) int loyalty; // Village loyalty
@property (assign) unsigned int warehouse; // Max storage of resources (other than wheat)
@property (assign) unsigned int granary; // Max storage wheat
@property (assign) unsigned int consumption; // Consuming / hour
@property (assign) int x; // Location X
@property (assign) int y; // Location Y
@property (nonatomic, strong) TMFarmList *farmList; // Farm List object

@property (assign) bool hasDownloaded; // Has downloaded property (used with loadallatonce property of TMSettings)

- (void)setAccountParent:(TMAccount *)newParent;
- (TMAccount *)getParent;
- (void)downloadAndParse;
- (void)parseTroops:(HTMLNode *)node;
- (void)parseResources:(HTMLNode *)body;
- (void)parseMovements:(HTMLNode *)body;
- (void)parseBuildingsPage:(TravianPages)page fromNode:(HTMLNode *)node;
- (void)parseConstructions:(HTMLNode *)node;

@end
