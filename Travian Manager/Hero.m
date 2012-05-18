//
//  Hero.m
//  Travian Manager
//
//  Created by Matej Kramny on 12/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Hero.h"
#import "HTMLNode.h"
#import "TravianPages.h"
#import "HeroQuest.h"

@implementation Hero

@synthesize strengthPoints, offBonusPercentage, defBonusPercentage, experience, health, speed, quests, isHidden, resourceProductionBoost, isAlive;

#pragma mark - Page Parsing protocol

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node {
	
	if (![[node tagName] isEqualToString:@"body"])
		return;
	
	if ((page & TPHero) != 0) {
		[self parseHero:node];
	} else if ((page & TPAdventures) != 0) {
		[self parseAdventures:node];
	}
	
}

- (void)parseHero:(HTMLNode *)node {
	
	// strengthPoints
	HTMLNode *attribute = [node findChildWithAttribute:@"id" matchingName:@"attributepower" allowPartial:NO];
	if (!attribute)
		return; // probably not the right page.
	
	NSString *attributeString = [[attribute findChildWithAttribute:@"class" matchingName:@"value" allowPartial:NO] contents];
	strengthPoints = [attributeString intValue];
	
	// offBonusPercentage
	attribute = [node findChildWithAttribute:@"id" matchingName:@"attributeoffBonus" allowPartial:NO];
	attributeString = [[attribute findChildWithAttribute:@"class" matchingName:@"value" allowPartial:NO] contents];
	offBonusPercentage = [attributeString intValue];
	
	// defBonusPercentage
	attribute = [node findChildWithAttribute:@"id" matchingName:@"attributedefBonus" allowPartial:NO];
	attributeString = [[attribute findChildWithAttribute:@"class" matchingName:@"value" allowPartial:NO] contents];
	defBonusPercentage = [attributeString intValue];
	
	// resouceProductionBoost
	attribute = [node findChildWithAttribute:@"id" matchingName:@"setResource" allowPartial:NO];
	NSArray *resourcesArray = [attribute findChildTags:@"div"];
	int activeResource = 0; // Which resource is hero boosting
	int manyResource = 0; // How many resource /hour is hero boosting
	int i = 0;
	for (HTMLNode *resourceNode in resourcesArray) {
		HTMLNode *resourceInput = [resourceNode findChildTag:@"input"];
		
		if (resourceInput == nil) continue; // not an input
		
		NSLog(@"%@", [resourceInput rawContents]);
		
		if ([resourceInput getAttributeNamed:@"checked"]) {
			activeResource = i;
			manyResource = [[[resourceNode findChildTag:@"span"] contents] intValue];
			
			break;
		}
		
		i++;
	}
	
	resourceProductionBoost = [[Resources alloc] init];
	if (activeResource == 0) { // manyResource of Each
		resourceProductionBoost.wood = manyResource;
		resourceProductionBoost.clay = manyResource;
		resourceProductionBoost.iron = manyResource;
		resourceProductionBoost.wheat = manyResource;
	} else if (activeResource == 1) { // wood
		resourceProductionBoost.wood = manyResource;
	} else if (activeResource == 2) { // clay
		resourceProductionBoost.clay = manyResource;
	} else if (activeResource == 3) { // iron
		resourceProductionBoost.iron = manyResource;
	} else { // wheat
		resourceProductionBoost.wheat = manyResource;
	}
	
	// experience
	attribute = [[node findChildWithAttribute:@"id" matchingName:@"attributes" allowPartial:NO] findChildWithAttribute:@"class" matchingName:@"element current powervalue experience points" allowPartial:NO];
	if (attribute) {
		experience = [[attribute contents] intValue];
	}
	
	// health
	attribute = [[node findChildWithAttribute:@"id" matchingName:@"attributes" allowPartial:NO] findChildWithAttribute:@"class" matchingName:@"attribute health tooltip" allowPartial:NO];
	if (attribute) {
		health = [[[attribute findChildWithAttribute:@"class" matchingName:@"value" allowPartial:NO] contents] intValue];
	}
	
	// speed
	attribute = [[node findChildWithAttribute:@"id" matchingName:@"attributes" allowPartial:NO] findChildWithAttribute:@"class" matchingName:@"speed tooltip" allowPartial:NO];
	if (attribute) {
		speed = [[[attribute findChildWithAttribute:@"class" matchingName:@"current" allowPartial:NO] contents] intValue];
	}
	
	// isHidden
	attribute = [node findChildWithAttribute:@"id" matchingName:@"attackBehaviourHide" allowPartial:NO];
	if ([attribute getAttributeNamed:@"checked"])
		isHidden = true;
	else
		isHidden = false;
	
	// isAlive
	attribute = [node findChildWithAttribute:@"id" matchingName:@"attributes" allowPartial:NO];
	if ([[attribute getAttributeNamed:@"class"] isEqualToString:@"hero-alive"])
		isAlive = true;
	else
		isAlive = false;
}

- (void)parseAdventures:(HTMLNode *)node {
	
	HTMLNode *form = [node findChildWithAttribute:@"id" matchingName:@"adventureListForm" allowPartial:NO];
	
	if (!form)
		return; // Wrong page, form doesn't exist!
	
	NSArray *trs = [[form findChildTag:@"tbody"] findChildTags:@"tr"];
	NSMutableArray *adventures = [[NSMutableArray alloc] initWithCapacity:[trs count]];
	
	for (HTMLNode *tr in trs) {
		
		HeroQuest *adventure = [[HeroQuest alloc] init];
		
		// Continue later..
		
	}
}

#pragma mark - Coders

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    
	NSNumber *n = [coder decodeObjectForKey:@"strengthPoints"];
	strengthPoints = [n intValue];
	n = [coder decodeObjectForKey:@"offBonusPercentage"];
	offBonusPercentage = [n intValue];
	n = [coder decodeObjectForKey:@"defBonusPercentage"];
	defBonusPercentage = [n intValue];
	resourceProductionBoost = [coder decodeObjectForKey:@"resourceProductionBoost"];
	n = [coder decodeObjectForKey:@"experience"];
	experience = [n intValue];
	n = [coder decodeObjectForKey:@"health"];
	health = [n intValue];
	n = [coder decodeObjectForKey:@"speed"];
	speed = [n intValue];
	n = [coder decodeObjectForKey:@"isHidden"];
	isHidden = [n boolValue];
	n = [coder decodeObjectForKey:@"isAlive"];
	isAlive = [n boolValue];
	quests = [coder decodeObjectForKey:@"quests"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithInt:strengthPoints] forKey:@"strengthPoints"];
	[coder encodeObject:[NSNumber numberWithInt:offBonusPercentage] forKey:@"offBOnusPercentage"];
	[coder encodeObject:[NSNumber numberWithInt:defBonusPercentage] forKey:@"defBonusPercentage"];
	[coder encodeObject:resourceProductionBoost forKey:@"resourceProductionBoost"];
	[coder encodeObject:[NSNumber numberWithInt:experience] forKey:@"experience"];
	[coder encodeObject:[NSNumber numberWithInt:health] forKey:@"health"];
	[coder encodeObject:[NSNumber numberWithInt:speed] forKey:@"speed"];
	[coder encodeObject:[NSNumber numberWithBool:isHidden] forKey:@"isHidden"];
	[coder encodeObject:[NSNumber numberWithBool:isAlive] forKey:@"isAlive"];
	[coder encodeObject:quests forKey:@"quests"];
}

@end
