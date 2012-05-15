//
//  TPIdentifier.m
//  Travian Manager
//
//  Created by Matej Kramny on 14/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TPIdentifier.h"
#import "HTMLNode.h"

@implementation TPIdentifier

+ (TravianPages)identifyPage:(HTMLNode *)body {
	
	// Looks at whether body node contains login elements, then (from url) identifies page from TravianPages enum
	
	// Need to have body element as root node
	if (![[body tagName] isEqualToString:@"body"])
		return TPNotFound;
	
	NSString *bodyClass = [body getAttributeNamed:@"class"];
	
	// Identify if page is login type
	if ([bodyClass rangeOfString:@"login"].location != NSNotFound)
		return TPLogin;
	
	if ([bodyClass rangeOfString:@"village1"].location != NSNotFound)
		return TPResources | TPBuildList;
	
	if ([bodyClass rangeOfString:@"village2"].location != NSNotFound)
		return TPVillage | TPBuildList;
	
	if ([bodyClass rangeOfString:@"map"].location != NSNotFound)
		return TPMap;
	
	if ([bodyClass rangeOfString:@"statistics"].location != NSNotFound)
		return TPStatistics;
	
	if ([bodyClass rangeOfString:@"reports"].location != NSNotFound)
		return TPReports;
	
	if ([bodyClass rangeOfString:@"messages"].location != NSNotFound)
		return TPMessages;
	
	if ([bodyClass rangeOfString:@"hero_inventory"].location != NSNotFound)
		return TPHero;
	
	if ([bodyClass rangeOfString:@"hero_adventure"].location != NSNotFound)
		return TPAdventures;
	
	if ([bodyClass rangeOfString:@"hero_auction"].location != NSNotFound)
		return TPAuction;
	
	if ([bodyClass rangeOfString:@"map"].location != NSNotFound)
		return TPMap;
	
	if ([bodyClass rangeOfString:@"player"].location != NSNotFound)
		return TPProfile;
	
	if ([bodyClass rangeOfString:@"build"].location != NSNotFound) {
		TravianPages map = TPBuilding;
		
		if ([bodyClass rangeOfString:@"gidRessources"].location != NSNotFound)
			map |= TPResourceField;
		
		return map;
	}
	
	return TPNotFound;
	
}

@end
