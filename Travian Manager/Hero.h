//
//  Hero.h
//  Travian Manager
//
//  Created by Matej Kramny on 12/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TravianPageParsingProtocol.h"

@interface Hero : NSObject <NSCoding, TravianPageParsingProtocol>

@property (assign) int strengthPoints; // Attribute - Strength
@property (assign) int offBonusPercentage; // Attribute - Offence bonus (%)
@property (assign) int defBonusPercentage; // Attribute - Defence bonus (%)
@property (assign) int resourcePoints; // Attribute - resources
@property (assign) NSDictionary *resourceProductionBoost; // Dictionary for resource production bonus // X all // X wood etc
@property (assign) int experience; // Hero experience
@property (assign) int health; // Health of the hero (%)
@property (assign) int speed; // Fields / hour
@property (assign) bool isHidden; // Whether hero is hidden when village is attacked
@property (assign) NSArray *quests; // Array of quests available

- (void)parseHero:(HTMLNode *)node;
- (void)parseAdventures:(HTMLNode *)node;

@end
