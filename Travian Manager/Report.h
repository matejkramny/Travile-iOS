//
//  Report.h
//  Travian Manager
//
//  Created by Matej Kramny on 27/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TravianPageParsingProtocol.h"

@class Resources;
@class Village;
@class Account;

@interface Report : NSObject <TravianPageParsingProtocol, NSCoding, NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
	NSURLConnection *reportConnection;
	NSMutableData *reportData;
}

@property (nonatomic, strong) NSString *name; // Name of the report, as in browser
@property (nonatomic, strong) NSDate *when; // When the report happened
@property (nonatomic, strong) NSString *accessID; // ID|ID of the report
@property (nonatomic, strong) Resources *bounty; // Bounty is usually resources, but can be items like 'cage'
@property (nonatomic, strong) NSString *bountyName;
@property (nonatomic, strong) NSString *deleteID; // Integer ID of the report used to delete the Report

@property (nonatomic, strong) Account *attacker; // Attacker's account
@property (nonatomic, strong) Village *attackerVillage; // Attacker's village
@property (nonatomic, strong) NSArray *attackerTroops; // Troops used in attack
@property (nonatomic, weak) Account *defender; // Defender's account
@property (nonatomic, weak) Village *defenderVillage; // Defender's village
@property (nonatomic, strong) NSArray *defenderTroops; // Troops used to defend

- (void)downloadAndParse;
- (void)delete;

@end
