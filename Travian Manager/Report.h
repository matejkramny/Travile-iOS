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

@interface Report : NSObject <TravianPageParsingProtocol, NSCoding>

@property (nonatomic, strong) NSString *name; // Name of the report, as in browser
@property (nonatomic, strong) NSDate *when; // When the report happened
@property (nonatomic, strong) NSString *accessID; // ID of the report
@property (nonatomic, strong) Resources *bounty; // Bounty is usually resources, but can be items like 'cage'
@property (nonatomic, strong) NSString *bountyName;


@property (nonatomic, strong) Account *attacker; // Attacker's account
@property (nonatomic, strong) Village *attackerVillage; // Attacker's village
@property (nonatomic, strong) NSArray *attackerTroops; // Troops used in attack
@property (nonatomic, weak) Account *defender; // Defender's account
@property (nonatomic, weak) Village *defenderVillage; // Defender's village
@property (nonatomic, strong) NSArray *defenderTroops; // Troops used to defend

@end
