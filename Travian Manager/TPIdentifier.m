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

#import "TPIdentifier.h"
#import "HTMLNode.h"

@implementation TPIdentifier

+ (TravianPages)identifyPage:(HTMLNode *)body {
	
	// Looks at whether body node contains login elements, then (from url) identifies page from TravianPages enum
	
	// Need to have body element as root node
	if (![[body tagName] isEqualToString:@"body"])
		return TPNotFound;
	
	if ([body findChildWithAttribute:@"id" matchingName:@"sysmsg" allowPartial:NO])
		return TPNotification;
	
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

+ (TravianBuildings)identifyBuilding:(HTMLNode *)body {
	
	if (![[body tagName] isEqualToString:@"body"])
		return TBNotFound;
	
	TravianBuildings building = TBNotFound;
	
	HTMLNode *buildingId = [body findChildWithAttribute:@"id" matchingName:@"build" allowPartial:NO];
	if (!buildingId)
		return TBNotFound;
	
	NSString *class = [buildingId getAttributeNamed:@"class"];
	if ([class rangeOfString:@"gid"].location == NSNotFound)
		return TBNotFound;
	
	class = [class stringByReplacingOccurrencesOfString:@"gid" withString:@""];
	
	building = [class intValue];
	
	return building;
}

@end
