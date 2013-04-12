/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "TravianPageParsingProtocol.h"

@class TMResources;
@class TMVillage;
@class TMAccount;

@interface TMReport : NSObject <TMPageParsingProtocol, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSString *name; // Name of the report, as in browser
@property (nonatomic, strong) NSString *when; // When the report happened, as appears in browser
@property (nonatomic, strong) NSString *accessID; // ID|ID of the report
@property (nonatomic, strong) TMResources *bountyResources; // Bounty is usually resources, but can be items like 'cage'
@property (nonatomic, strong) NSString *bounty;
@property (nonatomic, strong) NSString *deleteID; // Integer ID of the report used to delete the Report
@property (nonatomic, strong) NSString *information; // Some information gained on the report..

@property (nonatomic, strong) NSDictionary *attacker; // NSDictionary containing keys 'name', 'troopNames', 'troops' and 'casualties'
@property (nonatomic, strong) NSMutableArray *defenders; // Defenders array. Array contains NSDictionary as attacker above
@property (assign) bool parsed;
@property (nonatomic, strong) NSDictionary *trade;

- (void)downloadAndParse;
- (void)delete;

@end
