// This code is distributed under the terms and conditions of the MIT license.

/* * Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial
 * portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
 * OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "TMHero.h"
#import "HTMLNode.h"
#import "TravianPages.h"
#import "TMHeroQuest.h"

@implementation TMHero

@synthesize strengthPoints, offBonusPercentage, defBonusPercentage, resourceProductionPoints, experience, health, speed, quests, isHidden, resourceProductionBoost, isAlive;

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
	
	attribute = [node findChildWithAttribute:@"id" matchingName:@"attributeproductionPoints" allowPartial:NO];
	attributeString = [[attribute findChildWithAttribute:@"class" matchingName:@"value" allowPartial:NO] contents];
	resourceProductionPoints = [attributeString intValue];
	
	// resouceProductionBoost
	attribute = [node findChildWithAttribute:@"id" matchingName:@"setResource" allowPartial:NO];
	NSArray *resourcesArray = [attribute findChildTags:@"div"];
	int activeResource = 0; // Which resource is hero boosting
	int manyResource = 0; // How many resource /hour is hero boosting
	int i = 0;
	for (HTMLNode *resourceNode in resourcesArray) {
		HTMLNode *resourceInput = [resourceNode findChildTag:@"input"];
		
		if (resourceInput == nil) continue; // not an input
		
		if ([resourceInput getAttributeNamed:@"checked"]) {
			activeResource = i;
			manyResource = [[[resourceNode findChildTag:@"span"] contents] intValue];
			
			break;
		}
		
		i++;
	}
	
	resourceProductionBoost = [[TMResources alloc] init];
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
		
		if ([tr findChildOfClass:@"noData"]) {
			continue;
		}
		
		TMHeroQuest *adventure = [[TMHeroQuest alloc] init];
		
		// ID & URL
		adventure.kid = [[[tr getAttributeNamed:@"id"] stringByReplacingOccurrencesOfString:@"adventure" withString:@""] intValue]; // tr#adventureXXXXX (XXXXX = id of the adventure)
		
		// X, Y
		// Strip "(" and ")" from coordinates
		NSString *coordinateX = [[[tr findChildWithAttribute:@"class" matchingName:@"coordinateX" allowPartial:NO] contents] stringByReplacingOccurrencesOfString:@"(" withString:@""];
		NSString *coordinateY = [[[tr findChildWithAttribute:@"class" matchingName:@"coordinateY" allowPartial:NO] contents] stringByReplacingOccurrencesOfString:@")" withString:@""];
		// Parse them as integers & put them into adventure object
		adventure.x = [coordinateX intValue];
		adventure.y = [coordinateY intValue];
		
		// Duration
		NSString *rawTime = [[[tr findChildWithAttribute:@"class" matchingName:@"moveTime" allowPartial:NO] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSArray *rawTimeSplit = [rawTime componentsSeparatedByString:@":"];
		if ([rawTimeSplit count] == 3) {
			// Hour, Minute, Second
			int hour, minute, second;
			
			hour = [[rawTimeSplit objectAtIndex:0] intValue];
			minute = [[rawTimeSplit objectAtIndex:1] intValue];
			second = [[rawTimeSplit objectAtIndex:2] intValue];
			
			adventure.duration = hour * 60 * 60 + minute * 60 + second;
		}
		
		// Expiry
		rawTime = [[[tr findChildWithAttribute:@"class" matchingName:@"timeLeft" allowPartial:NO] findChildTag:@"span"] contents];
		rawTimeSplit = [rawTime componentsSeparatedByString:@":"];
		int hour = 0, minute = 0, second = 0;
		hour = [[rawTimeSplit objectAtIndex:0] intValue];
		minute = [[rawTimeSplit objectAtIndex:1] intValue];
		second = [[rawTimeSplit objectAtIndex:2] intValue];
		int timestamp = [[NSDate date] timeIntervalSince1970]; // Now date
		timestamp += hour * 60 * 60 + minute * 60 + second; // Now date + hour:minute:second
		adventure.expiry = [NSDate dateWithTimeIntervalSince1970:timestamp]; // Future date
		
		// Difficulty
		NSString *difficulty = [[[tr findChildWithAttribute:@"class" matchingName:@"adventureDifficulty" allowPartial:YES] getAttributeNamed:@"class"] stringByReplacingOccurrencesOfString:@"adventureDifficulty" withString:@""];
		int difficultyInt = [difficulty intValue];
		// Difficulty with value 1 or higher is still in DQ_NORMAL
		if (difficultyInt > 1) difficultyInt = 1;
		
		adventure.difficulty = difficultyInt;
		
		[adventures addObject:adventure];
		
	}
	
	quests = adventures;
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
