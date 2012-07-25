//
//  Village.m
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Village.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "Resources.h"
#import "ResourcesProduction.h"
#import "AppDelegate.h"
#import "Storage.h"
#import "Account.h"
#import "TPIdentifier.h"
#import "Construction.h"
#import "Troop.h"
#import "Hero.h"
#import "Building.h"
#import "Movement.h"

@implementation Village

@synthesize resources, resourceProduction, troops, movements, constructions, buildings, name;
@synthesize urlPart, loyalty, population, warehouse, granary, consumption, x, y;
@synthesize villageConnection, villageData;

- (void)setAccountParent:(Account *)newParent {
	parent = newParent;
}

- (Account *)getParent {
	return parent;
}

#pragma mark - Custom messages

- (void)downloadAndParse
{
	Account *account = [[(AppDelegate *)[UIApplication sharedApplication].delegate storage] account]; // This village's owner
	
	// Start a request containing Resources, ResourceProduction, and troops
	NSString *stringUrl = [NSString stringWithFormat:@"http://%@.travian.%@/dorf1.php", account.world, account.server];
	NSURL *url = [NSURL URLWithString: stringUrl];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	// Preserve any cookies received
	[request setHTTPShouldHandleCookies:YES];
	
	villageConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
}

#pragma mark - Page parsing

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node
{
	// Do not parse unparseable pages || tagName must be body - root element
	if ((page & TPMaskUnparseable) != 0 || ![[node tagName] isEqualToString:@"body"])
		return;
	
	if ((page & TPResources) != 0) {
		[self parseResources:node];
		
		if (!resourceProduction)
			resourceProduction = [[ResourcesProduction alloc] init];
		
		[parent setProgressIndicator:@"Loading Resources"];
		
		[resourceProduction parsePage:page fromHTMLNode:node];
		[self parseTroops:node];
		[self parseMovements:node];
		[self parseBuildingsPage:page fromNode:node];
	} else if ((page & TPBuilding) != 0) {
		//[self parseBuilding:node];
	} else if ((page & TPHero) != 0) {
		[parent.hero parsePage:page fromHTMLNode:node];
	} else if ((page & TPVillage) != 0) {
		[parent setProgressIndicator:@"Loading Village"];
		[self parseBuildingsPage:page fromNode:node];
	}
	
	if ((page & TPBuildList) != 0) {
		[self parseConstructions:node];
	}
	
	// get loyalty
	HTMLNode *villageName = [node findChildWithAttribute:@"id" matchingName:@"villageName" allowPartial:NO];
	if (villageName) {
		NSString *span = [[[villageName findChildWithAttribute:@"class" matchingName:@"loyalty" allowPartial:YES] contents] stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
		loyalty = [span intValue];
	}
}

- (void)parseTroops:(HTMLNode *)node {
	
	if (![[node tagName] isEqualToString:@"body"])
		return;
	
	HTMLNode *tableTroops = [node findChildWithAttribute:@"id" matchingName:@"troops" allowPartial:NO];
	if (!tableTroops) {
		NSLog(@"Did not find table#troops");
		return;
	}
	
	NSArray *trs = [[tableTroops findChildTag:@"tbody"] findChildTags:@"tr"];
	NSMutableArray *troopsTemp = [[NSMutableArray alloc] initWithCapacity:[trs count]];
	
	for (HTMLNode *tr in trs) {
		Troop *troop = [[Troop alloc] init];
		
		troop.count = [[[tr findChildWithAttribute:@"class" matchingName:@"num" allowPartial:NO] contents] intValue];
		troop.name = [[tr findChildWithAttribute:@"class" matchingName:@"un" allowPartial:NO] contents];
		
		[troopsTemp addObject:troop];
	}
	
	troops = troopsTemp;
	
}

- (void)parseResources:(HTMLNode *)body {
	NSArray *woodRaw = [[[body findChildWithAttribute:@"id" matchingName:@"l1" allowPartial:NO] contents] componentsSeparatedByString:@"/"];
	
	warehouse = [[woodRaw objectAtIndex:1] intValue];
	
	// Resources object might be nil
	if (!resources)
		resources = [[Resources alloc] init];
	
	resources.wood = [[woodRaw objectAtIndex:0] intValue];
	resources.clay = [[[[[body findChildWithAttribute:@"id" matchingName:@"l2" allowPartial:NO] contents] componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
	resources.iron = [[[[[body findChildWithAttribute:@"id" matchingName:@"l3" allowPartial:NO] contents] componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
	
	NSArray *rawWheat = [[[body findChildWithAttribute:@"id" matchingName:@"l4" allowPartial:NO] contents] componentsSeparatedByString:@"/"];
	granary = [[rawWheat objectAtIndex:1] intValue];
	resources.wheat =[[rawWheat objectAtIndex:0] intValue];
	consumption = [[[[[body findChildWithAttribute:@"id" matchingName:@"l5" allowPartial:NO] contents] componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
}

- (void)parseMovements:(HTMLNode *)body {
	
	HTMLNode *idMovements = [body findChildWithAttribute:@"id" matchingName:@"movements" allowPartial:NO];
	
	if (!idMovements) {
		// No movements
		movements = [[NSArray alloc] init];
		return;
	}
	
	NSArray *tds = [idMovements findChildTags:@"tr"];
	NSMutableArray *tempMovements = [[NSMutableArray alloc] init];
	for (HTMLNode *td in tds) {
		
		HTMLNode *divMov = [td findChildWithAttribute:@"class" matchingName:@"mov" allowPartial:NO];
		HTMLNode *timer = [td findChildWithAttribute:@"id" matchingName:@"timer" allowPartial:YES];
		// Not containing name or duration
		if (!divMov | !timer)
			continue;
		
		Movement *movement = [[Movement alloc] init];
		
		movement.name = [[divMov findChildTag:@"span"] contents];
		
		NSArray *timeSplit = [[timer contents] componentsSeparatedByString:@":"];
		int hour = 0, minute = 0, second = 0;
		hour = [[timeSplit objectAtIndex:0] intValue];
		minute = [[timeSplit objectAtIndex:1] intValue];
		second = [[timeSplit objectAtIndex:2] intValue];
		int timestamp = [[NSDate date] timeIntervalSince1970]; // Now date
		timestamp += hour * 60 * 60 + minute * 60 + second; // Now date + hour:minute:second
		movement.finished = [NSDate dateWithTimeIntervalSince1970:timestamp]; // Future date
		
		[tempMovements addObject:movement];
		
	}
	
	movements = [tempMovements copy];
	
}

- (void)parseBuildingsPage:(TravianPages)page fromNode:(HTMLNode *)node {
	
	HTMLNode *idContent = [node findChildWithAttribute:@"id" matchingName:@"content" allowPartial:NO];
	if (!idContent) { NSLog(@"Cannot find id#content"); return; }
	
	NSArray *areas = [idContent findChildTags:@"area"];
	if (!areas) { NSLog(@"No areas in id#content!"); return; }
	
	if (!buildings)
		buildings = [[NSMutableArray alloc] init];
	
	for (HTMLNode *area in areas) {
		
		if ([[area getAttributeNamed:@"href"] isEqualToString:@"dorf2.php"]) continue; // Village Centre
		
		Building *building = [[Building alloc] init];
		
		NSString *title = [area getAttributeNamed:@"title"];
		building.bid = [[area getAttributeNamed:@"href"] stringByReplacingOccurrencesOfString:@"build.php?id=" withString:@""];
		
		NSError *error;
		HTMLParser *p = [[HTMLParser alloc] initWithString:title error:&error];
		if (error) { NSLog(@"Unparseable HTMLParser error %@ %@", [error localizedDescription], [error localizedRecoverySuggestion]); return; }
		
		HTMLNode *body = [p body];
		
		// check if body contains costs required to upgrade
		HTMLNode *div;
		if ((div = [body findChildTag:@"div"])) {
			Resources *res = [[Resources alloc] init];
			
			NSArray *spans = [div findChildTags:@"span"];
			NSMutableArray *spansParsed = [[NSMutableArray alloc] initWithCapacity:[spans count]];
			for (int i = 0; i < [spans count]; i++) {
				HTMLNode *span = [spans objectAtIndex:i];
				
				NSString *img = [[span findChildTag:@"img"] rawContents];
				NSString *raw = [span rawContents];
				
				raw = [raw stringByReplacingOccurrencesOfString:img withString:@""];
				
				NSError *error;
				HTMLParser *p = [[HTMLParser alloc] initWithString:raw error:&error];
				if (error) {
					NSLog(@"Cannot parse resource %@ %@", [error localizedDescription], [error localizedRecoverySuggestion]);
					continue;
				}
				
				[spansParsed addObject:[NSNumber numberWithInt:[[[[[p body] findChildTag:@"span"] contents] stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] intValue]]];
			}
			
			res.wood = [[spansParsed objectAtIndex:0] intValue];
			res.clay = [[spansParsed objectAtIndex:1] intValue];
			res.iron = [[spansParsed objectAtIndex:2] intValue];
			res.wheat = [[spansParsed objectAtIndex:3] intValue];
			
			building.resources = res;
		}
		
		building.level = [[[[[body findChildTag:@"p"] findChildTag:@"span"] contents] stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] intValue];
		building.name = [[body findChildTag:@"p"] contents];
		building.page = page;
		building.parent = self;
		
		bool foundExistingBuilding = false;
		for (int i = 0; i < [buildings count]; i++) {
			Building *exBu = [buildings objectAtIndex:i];
			if (!exBu) continue;
			
			if ([[exBu bid] isEqualToString:building.bid]) {
				
				foundExistingBuilding = true;
				
				// Update building object
				[buildings replaceObjectAtIndex:i withObject:building];
				
				break;
			}
		}
		
		if (!foundExistingBuilding) {
			[buildings addObject:building];
		}
	}
}

- (void)parseConstructions:(HTMLNode *)node {
	
	// get construction list
	
	HTMLNode *building_contract = [node findChildWithAttribute:@"id" matchingName:@"building_contract" allowPartial:NO];
	NSMutableArray *tempConstructions = [[NSMutableArray alloc] init];
	if (building_contract) {
		NSArray *trs = [[building_contract findChildTag:@"tbody"] findChildTags:@"tr"];
		
		for (HTMLNode *tr in trs) {
			Construction *construction = [[Construction alloc] init];
			NSArray *tds = [tr findChildTags:@"td"];
			
			NSString *conName = [[tds objectAtIndex:1] contents];
			NSString *conLevel = [[[tds objectAtIndex:1] findChildTag:@"span"] contents];
			NSString *conFinishTime = [[tds objectAtIndex:2] rawContents];
			NSString *conFInishTimeSpan = [[[tds objectAtIndex:2] findChildTag:@"span"] rawContents];
			conFinishTime = [conFinishTime stringByReplacingOccurrencesOfString:conFInishTimeSpan withString:@""];
			
			NSError *error;
			HTMLParser *parser = [[HTMLParser alloc] initWithString:conFinishTime error:&error];
			if (error) {
				conFinishTime = @"Undetectable";
				NSLog(@"Unparseable construciton");
				
				continue;
			}
			
			conFinishTime = [[[[parser body] findChildTag:@"td"] contents] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
			NSString *ampm = [conFinishTime stringByReplacingCharactersInRange:NSMakeRange(0, [conFinishTime length] - 2) withString:@""];
			conFinishTime = [conFinishTime stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
			
			NSString *ampmFormattedString = @"";
			if ([ampm isEqualToString:@"am"]) {
				ampmFormattedString = @" AM";
			} else if ([ampm isEqualToString:@"pm"]) {
				ampmFormattedString = @" PM";
			}
			
			construction.name = [conName stringByReplacingOccurrencesOfString:conLevel withString:@""];
			construction.level = [[conLevel stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] intValue];
			construction.finishTime = [conFinishTime stringByAppendingString:ampmFormattedString];
			
			[tempConstructions addObject:construction];
		}
		
		constructions = tempConstructions;
	} else
		constructions = [[NSArray alloc] init];
	
}

#pragma mark - Coders

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    
	resources = [coder decodeObjectForKey:@"resources"];
	resourceProduction = [coder decodeObjectForKey:@"resourceProduction"];
	troops = [coder decodeObjectForKey:@"troops"];
	movements = [coder decodeObjectForKey:@"movements"];
	buildings = [coder decodeObjectForKey:@"buildings"];
	urlPart = [coder decodeObjectForKey:@"villageID"];
		NSNumber *numberObject;
	numberObject = [coder decodeObjectForKey:@"population"];
	population = [numberObject intValue];
	numberObject = [coder decodeObjectForKey:@"loyalty"];
	loyalty = [numberObject intValue];
	numberObject = [coder decodeObjectForKey:@"warehouse"];
	warehouse = [numberObject intValue];
	numberObject = [coder decodeObjectForKey:@"granary"];
	granary = [numberObject intValue];
	numberObject = [coder decodeObjectForKey:@"consumption"];
	consumption = [numberObject intValue];
	numberObject = [coder decodeObjectForKey:@"villageX"];
	x = [numberObject intValue];
	numberObject = [coder decodeObjectForKey:@"villageY"];
	y = [numberObject intValue];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:resources forKey:@"resources"];
	[coder encodeObject:resourceProduction forKey:@"resourceProduction"];
	[coder encodeObject:troops forKey:@"troops"];
	[coder encodeObject:movements forKey:@"movements"];
	[coder encodeObject:buildings forKey:@"buildings"];
	[coder encodeObject:urlPart forKey:@"villageID"];
	[coder encodeObject:[NSNumber numberWithInt:population] forKey:@"population"];
	[coder encodeObject:[NSNumber numberWithInt:loyalty] forKey:@"loyalty"];
	[coder encodeObject:[NSNumber numberWithInt:warehouse] forKey:@"warehouse"];
	[coder encodeObject:[NSNumber numberWithInt:granary] forKey:@"granary"];
	[coder encodeObject:[NSNumber numberWithInt:x] forKey:@"villageX"];
	[coder encodeObject:[NSNumber numberWithInt:y] forKey:@"villageY"];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {  }
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection	{	return NO;	}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error { NSLog(@"Connection failed with error: %@. Fix error by: %@", [error localizedFailureReason], [error localizedRecoverySuggestion]); }

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[villageData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	villageData = [[NSMutableData alloc] initWithLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	
	// Parse data
	if (connection == villageConnection)
	{
		NSError *error;
		HTMLParser *parser = [[HTMLParser alloc] initWithData:villageData error:&error];
		HTMLNode *body = [parser body];
		
		if (!parser) {
			NSLog(@"Cannot parse village data. Reason: %@, recovery options: %@", [error localizedDescription], [error localizedRecoveryOptions]);
			return;
		}
		
		TravianPages page = [TPIdentifier identifyPage:body];
		
		if ((page & TPResources) != 0) {
			// Village overview
			
			NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@.travian.%@/dorf2.php", [parent world], [parent server]]] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
			[request setHTTPShouldHandleCookies:YES];
			
			villageConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
		}
		
		[self parsePage:page fromHTMLNode:body];
	}
}

@end
