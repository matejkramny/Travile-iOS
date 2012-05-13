//
//  Hero.m
//  Travian Manager
//
//  Created by Matej Kramny on 12/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Hero.h"

@implementation Hero

@synthesize strengthPoints, offBonusPercentage, defBonusPercentage, experience, health, speed, quests, isHidden, resourcePoints, resourceProductionBoost;

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    
	NSNumber *n = [coder decodeObjectForKey:@"strengthPoints"];
	strengthPoints = [n intValue];
	n = [coder decodeObjectForKey:@"offBonusPercentage"];
	offBonusPercentage = [n intValue];
	n = [coder decodeObjectForKey:@"defBonusPercentage"];
	defBonusPercentage = [n intValue];
	n = [coder decodeObjectForKey:@"resourcePoints"];
	resourcePoints = [n intValue];
	resourceProductionBoost = [coder decodeObjectForKey:@"resourceProductionBoost"];
	n = [coder decodeObjectForKey:@"experience"];
	experience = [n intValue];
	n = [coder decodeObjectForKey:@"health"];
	health = [n intValue];
	n = [coder decodeObjectForKey:@"speed"];
	speed = [n intValue];
	n = [coder decodeObjectForKey:@"isHidden"];
	isHidden = [n boolValue];
	quests = [coder decodeObjectForKey:@"quests"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithInt:strengthPoints] forKey:@"strengthPoints"];
	[coder encodeObject:[NSNumber numberWithInt:offBonusPercentage] forKey:@"offBOnusPercentage"];
	[coder encodeObject:[NSNumber numberWithInt:defBonusPercentage] forKey:@"defBonusPercentage"];
	[coder encodeObject:[NSNumber numberWithInt:resourcePoints] forKey:@"resourcePoints"];
	[coder encodeObject:resourceProductionBoost forKey:@"resourceProductionBoost"];
	[coder encodeObject:[NSNumber numberWithInt:experience] forKey:@"experience"];
	[coder encodeObject:[NSNumber numberWithInt:health] forKey:@"health"];
	[coder encodeObject:[NSNumber numberWithInt:speed] forKey:@"speed"];
	[coder encodeObject:[NSNumber numberWithBool:isHidden] forKey:@"isHidden"];
	[coder encodeObject:quests forKey:@"quests"];
}

@end
