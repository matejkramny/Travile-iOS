/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMVillage.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "TMResources.h"
#import "TMResourcesProduction.h"
#import "TMStorage.h"
#import "TMAccount.h"
#import "TPIdentifier.h"
#import "TMConstruction.h"
#import "TMTroop.h"
#import "TMHero.h"
#import "TMBuilding.h"
#import "TMMovement.h"
#import "TMBarracks.h"
#import "TMStable.h"
#import "TMWorkshop.h"
#import "TMTrapper.h"
#import "TMResidence.h"

@interface TMVillage () {
	NSURLConnection *villageConnection; // Village connection
	NSMutableData *villageData; // Village data
}

- (void)validateConstructions;

@end

@interface TMVillage (ResourceUpdates)

- (void)updateResources:(id)sender;

@end

@implementation TMVillage (ResourceUpdates)

- (void)updateResources:(id)sender {
	
}

@end

@implementation TMVillage

@synthesize resources, resourceProduction, troops, movements, constructions, buildings, name;
@synthesize urlPart, loyalty, population, warehouse, granary, consumption, x, y;
@synthesize hasDownloaded;

- (id)init {
	self = [super init];
	
	if (self) {
		hasDownloaded = NO;
	}
	
	return self;
}

- (void)setAccountParent:(TMAccount *)newParent {
	parent = newParent;
}

- (TMAccount *)getParent {
	return parent;
}

#pragma mark - Custom messages

- (void)downloadAndParse
{
	TMAccount *account = [[TMStorage sharedStorage] account]; // This village's owner
	
	// Start a request containing Resources, ResourceProduction, and troops
	NSURL *url = [account urlForArguments:[TMAccount resources], @"?", urlPart, nil];
	
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
			resourceProduction = [[TMResourcesProduction alloc] init];
		
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
	} else {
		// T4.2 version?
		HTMLNode *loy_4_2 = [node findChildWithAttribute:@"id" matchingName:@"sidebarBoxActiveVillage" allowPartial:NO];
		if (loy_4_2 != nil) {
			loyalty = [[[[loy_4_2 findChildWithAttribute:@"class" matchingName:@"loyalty" allowPartial:YES] findChildTag:@"span"] contents] intValue];
		}
	}
	
	if (page & TPVillage) {
		[self validateConstructions];
	}
}

- (void)parseTroops:(HTMLNode *)node {
	
	if (![[node tagName] isEqualToString:@"body"])
		return;
	
	HTMLNode *tableTroops = [node findChildWithAttribute:@"id" matchingName:@"troops" allowPartial:NO];
	if (!tableTroops) {
		return;
	}
	
	NSArray *trs = [[tableTroops findChildTag:@"tbody"] findChildTags:@"tr"];
	NSMutableArray *troopsTemp = [[NSMutableArray alloc] initWithCapacity:[trs count]];
	
	for (HTMLNode *tr in trs) {
		TMTroop *troop = [[TMTroop alloc] init];
		
		HTMLNode *num = [tr findChildWithAttribute:@"class" matchingName:@"num" allowPartial:NO];
		if (!num) {
			// Not a troop
			continue;
		}
		
		troop.count = [[num contents] intValue];
		troop.name = [[tr findChildWithAttribute:@"class" matchingName:@"un" allowPartial:NO] contents];
		
		[troopsTemp addObject:troop];
	}
	
	troops = troopsTemp;
	
}

- (void)parseResources:(HTMLNode *)body {
	NSArray *woodRaw = [[[body findChildWithAttribute:@"id" matchingName:@"l1" allowPartial:NO] contents] componentsSeparatedByString:@"/"];
	
	HTMLNode *wh_4_2 = [body findChildWithAttribute:@"id" matchingName:@"stockBarWarehouse" allowPartial:NO];
	if (wh_4_2 != nil) {
		warehouse = [[wh_4_2 contents] intValue];
	} else {
		warehouse = [[woodRaw objectAtIndex:1] intValue];
	}
	
	// Resources object might be nil
	if (!resources)
		resources = [[TMResources alloc] init];
	
	resources.wood = [[woodRaw objectAtIndex:0] intValue];
	resources.clay = [[[[[body findChildWithAttribute:@"id" matchingName:@"l2" allowPartial:NO] contents] componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
	resources.iron = [[[[[body findChildWithAttribute:@"id" matchingName:@"l3" allowPartial:NO] contents] componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
	
	NSArray *rawWheat = [[[body findChildWithAttribute:@"id" matchingName:@"l4" allowPartial:NO] contents] componentsSeparatedByString:@"/"];
	
	HTMLNode *gr_4_2 = [body findChildWithAttribute:@"id" matchingName:@"stockBarGranary" allowPartial:NO];
	if (gr_4_2 != nil) {
		granary = [[gr_4_2 contents] intValue];
	} else {
		granary = [[rawWheat objectAtIndex:1] intValue];
	}
	
	resources.wheat =[[rawWheat objectAtIndex:0] intValue];
	
	HTMLNode *consumption_4_2 = [body findChildWithAttribute:@"id" matchingName:@"stockBarFreeCrop" allowPartial:NO];
	if (consumption_4_2 != nil) {
		consumption = [[consumption_4_2 contents] intValue];
	} else {
		consumption = [[[[[body findChildWithAttribute:@"id" matchingName:@"l5" allowPartial:NO] contents] componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
	}
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
		
		TMMovement *movement = [[TMMovement alloc] init];
		
		movement.name = [[divMov findChildTag:@"span"] contents];
		
		NSArray *timeSplit = [[timer contents] componentsSeparatedByString:@":"];
		int hour = 0, minute = 0, second = 0;
		hour = [[timeSplit objectAtIndex:0] intValue];
		minute = [[timeSplit objectAtIndex:1] intValue];
		second = [[timeSplit objectAtIndex:2] intValue];
		int timestamp = [[NSDate date] timeIntervalSince1970]; // Now date
		timestamp += hour * 60 * 60 + minute * 60 + second; // Now date + hour:minute:second
		movement.finished = [NSDate dateWithTimeIntervalSince1970:timestamp]; // Future date
		
		// Movement type!
		NSString *type = [[divMov findChildTag:@"span"] getAttributeNamed:@"class"];
		if ([type isEqualToString:@"a1"])
			// Incoming attack
			movement.type = TMMovementTypeAttack | TMMovementTypeIncoming;
		else if ([type isEqualToString:@"a2"])
			// Outgoing attack
			movement.type = TMMovementTypeAttack | TMMovementTypeOutgoing;
		else if ([type isEqualToString:@"d1"])
			// Incoming reinforcement
			movement.type = TMMovementTypeReinforcement | TMMovementTypeIncoming;
		else if ([type isEqualToString:@"d2"])
			// Outgoing reinforcements
			movement.type = TMMovementTypeReinforcement | TMMovementTypeOutgoing;
		else if ([type isEqualToString:@"adventure"])
			// adventure
			movement.type = TMMovementTypeAdventure | TMMovementTypeOutgoing;
		// others.
		
		[tempMovements addObject:movement];
	}
	
	movements = [tempMovements copy];
	
}

- (void)parseBuildingsPage:(TravianPages)page fromNode:(HTMLNode *)node {
	
	HTMLNode *idContent = [node findChildWithAttribute:@"id" matchingName:@"content" allowPartial:NO];
	if (!idContent) {
		return;
	}
	
	NSArray *areas = [idContent findChildTags:@"area"];
	NSArray *vmap = [[idContent findChildWithAttribute:@"id" matchingName:@"village_map" allowPartial:NO] findChildTags:((page & TPVillage) != 0) ? @"img" : @"div"];
	if (!areas) {
		return;
	}
	
	if (!buildings)
		buildings = [[NSMutableArray alloc] init];
	
	int i = 0;
	for (HTMLNode *area in areas) {
		
		if ([[area getAttributeNamed:@"href"] isEqualToString:[TMAccount village]]) continue; // Village Centre area
		
		int gid;
		
		// Coordinates
		CGPoint coord;
		NSString *style = [[vmap objectAtIndex:i] getAttributeNamed:@"style"];
		NSString *raw = [[[style stringByReplacingOccurrencesOfString:((page & TPVillage) != 0) ? @"left:" : @"left: " withString:@""] stringByReplacingOccurrencesOfString:@"px; top:" withString:@":"] stringByReplacingOccurrencesOfString:@"px;" withString:@":"];
		NSArray *split = [raw componentsSeparatedByString:@":"];
		coord.x = [[split objectAtIndex:0] intValue];
		coord.y = [[split objectAtIndex:1] intValue];
		
		// GID
		if ((page & TPVillage) != 0) {
			// Adjust coordinates for village
			coord.x += 51;
			coord.y += 51;
			
			// Parse Building Identifier
			NSString *class = [[vmap objectAtIndex:i] getAttributeNamed:@"class"];
			
			gid = 0;
			// Test if building site..
			if ([class rangeOfString:@"building iso"].location != NSNotFound) {
				// It is building site
				gid = TBList; // list = buildingsite
			} else {
				gid = [[class stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] intValue]; // class="building g10"
				// Test if wall. Walls don't have coordinates
				if (gid == TBCityWall || gid == TBEarthWall || gid == TBPalisade) {
					coord.x = 0;
					coord.y = 0;
				}
			}
			// Set building gid
			gid = gid;
		} else {
			gid = TBNotKnown;
		}
		
		TMBuilding *building;
		if (gid == TBBarracks) {
			building = [[TMBarracks alloc] init]; // can check if is barracks by calling isKindOfClass: on the building
		} else if (gid == TBStable) {
			building = [[TMStable alloc] init];
		} else if (gid == TBWorkshop) {
			building = [[TMWorkshop alloc] init];
		} else if (gid == TBTrapper) {
			building = [[TMTrapper alloc] init];
		} else if (gid == TBResidence || gid == TBPalace) {
			building = [[TMResidence alloc] init];
		} else { // Do marketplace and main building tooo
			building = [[TMBuilding alloc] init];
		}
		
		building.gid = gid;
		
		NSString *title = [area getAttributeNamed:@"title"];
		building.bid = [[area getAttributeNamed:@"href"] stringByReplacingOccurrencesOfString:@"build.php?id=" withString:@""];
		
		NSError *error;
		HTMLParser *p = [[HTMLParser alloc] initWithString:title error:&error];
		if (error) {
			return;
		}
		
		HTMLNode *body = [p body];
		
		// check if body contains costs required to upgrade
		HTMLNode *div;
		if ((div = [body findChildTag:@"div"])) {
			[building fetchResourcesFromContract:div];
		}
		
		// being upgraded notification for Village buildings
		if ([body findChildWithAttribute:@"class" matchingName:@"notice" allowPartial:NO] && page & TPVillage) {
			building.isBeingUpgraded = true;
		}
		
		// Level
		building.level = [[[[[body findChildTag:@"p"] findChildTag:@"span"] contents] stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] intValue];
		// Building name
		building.name = [[body findChildTag:@"p"] contents];
		// Remove trailing space
		if ([building.name hasSuffix:@" "])
			building.name = [building.name substringToIndex:[building.name length]-1];
		
		// Set page
		building.page = page;
		// Village this building belongs to
		building.parent = self;
		
		// Set coordinates
		building.coordinates = coord;
		
		// is being upgraded? (resource fields are 100%, village buildings have span class="notice" that contains the notification of being built)
		if (page & TPResources) {
			NSString *class = [[vmap objectAtIndex:i] getAttributeNamed:@"class"];
			if ([class rangeOfString:@"underConstruction"].location != NSNotFound) {
				building.isBeingUpgraded = true;
			}
		}
		
		// Finish
		// Finds existing buildings with same id and replaces them.
		bool foundExistingBuilding = false;
		for (int i = 0; i < [buildings count]; i++) {
			TMBuilding *exBu = [buildings objectAtIndex:i];
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
		
		i++;
	}
}

- (void)parseConstructions:(HTMLNode *)node {
	// get construction list
	constructions = [[NSArray alloc] init];
	
	HTMLNode *building_contract = [node findChildWithAttribute:@"id" matchingName:@"building_contract" allowPartial:NO];
	// Temporary mutable place for construction
	NSMutableArray *tempConstructions = [[NSMutableArray alloc] init];
	
	// Test if any constructions
	if (building_contract) {
		NSArray *trs = [[building_contract findChildTag:@"tbody"] findChildTags:@"tr"];
		
		for (HTMLNode *tr in trs) {
			TMConstruction *construction = [[TMConstruction alloc] init];
			NSArray *tds = [tr findChildTags:@"td"];
			
			NSString *conName = [[tds objectAtIndex:1] contents];
			NSString *conLevel = [[[tds objectAtIndex:1] findChildTag:@"span"] contents];
			if ([[tds objectAtIndex:1] findChildOfClass:@"inactive"] != nil) {
				conName = [[[tds objectAtIndex:1] findChildOfClass:@"inactive"] contents];
				conLevel = [[[tds objectAtIndex:1] findChildOfClass:@"lvl inactive"] contents];
			}
			NSString *finishTime = @"";
			if ([tds count] >= 3)
				finishTime = [[[tds objectAtIndex:2] findChildTag:@"span"] contents];
			
			if ([finishTime length] != 0) {
				// Parse time from (hh:mm:ss) to NSDate
				NSArray *timeSplit = [finishTime componentsSeparatedByString:@":"];
				int hour = 0, minute = 0, second = 0;
				hour = [[timeSplit objectAtIndex:0] intValue];
				minute = [[timeSplit objectAtIndex:1] intValue];
				second = [[timeSplit objectAtIndex:2] intValue];
				int timestamp = [[NSDate date] timeIntervalSince1970]; // Now date
				timestamp += hour * 60 * 60 + minute * 60 + second; // Now date + hour:minute:second
				construction.finishTime = [NSDate dateWithTimeIntervalSince1970:timestamp]; // Future date
			}
			
			// Set name. Level is inside the name label
			construction.name = [conName stringByReplacingOccurrencesOfString:conLevel withString:@""];
			if ([construction.name hasSuffix:@" "])
				construction.name = [construction.name substringToIndex:[construction.name length] -1];
			construction.level = [[conLevel stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] intValue];
			
			[tempConstructions addObject:construction];
		}
		
		constructions = tempConstructions;
	} else {
		// T4.2 version
		HTMLNode *classBuildingList = [node findChildWithAttribute:@"class" matchingName:@"boxes buildingList" allowPartial:YES];
		if (classBuildingList) {
			NSArray *lis = [classBuildingList findChildTags:@"li"];
			for (HTMLNode *li in lis) {
				TMConstruction *construction = [[TMConstruction alloc] init];
				
				HTMLNode *nameNode = [li findChildWithAttribute:@"class" matchingName:@"name" allowPartial:NO];
				NSString *conName = [[[nameNode contents] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
				
				int level = [[[[nameNode findChildWithAttribute:@"class" matchingName:@"lvl" allowPartial:NO] contents] stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] intValue];
				
				NSString *finishTime = [[li findChildWithAttribute:@"id" matchingName:@"timer" allowPartial:YES] contents];
				if ([finishTime length] != 0) {
					// Parse time from (hh:mm:ss) to NSDate
					NSArray *timeSplit = [finishTime componentsSeparatedByString:@":"];
					int hour = 0, minute = 0, second = 0;
					hour = [[timeSplit objectAtIndex:0] intValue];
					minute = [[timeSplit objectAtIndex:1] intValue];
					second = [[timeSplit objectAtIndex:2] intValue];
					int timestamp = [[NSDate date] timeIntervalSince1970]; // Now date
					timestamp += hour * 60 * 60 + minute * 60 + second; // Now date + hour:minute:second
					construction.finishTime = [NSDate dateWithTimeIntervalSince1970:timestamp]; // Future date
				}
				
				construction.name = conName;
				construction.level = level;
				
				[tempConstructions addObject:construction];
			}
			
			constructions = tempConstructions;
		}
	}
}

- (void)validateConstructions {
	// Checks constructions if they match each building's isBeingUpgraded state
	if (!buildings || !constructions)
		return;
	
	for (int i = 0; i < buildings.count; i++) {
		TMBuilding *b = [buildings objectAtIndex:i];
		
		if (b.isBeingUpgraded) {
			TMConstruction *match;
			for (int ii = 0; ii < constructions.count; ii++) {
				TMConstruction *c = [constructions objectAtIndex:ii];
				
				if ([c.name isEqualToString:b.name] && b.level+1 == c.level) {
					match = c;
					break;
				}
			}
			
			if (!match) {
				b.isBeingUpgraded = false;
			}
		}
	}
}

#pragma mark - Coders

// Loads objects from NSCoder
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

// Saves objects to NSCoder
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
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	// failed - do semething clever
}

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
			return;
		}
		
		TravianPages page = [TPIdentifier identifyPage:body];
		
		if ((page & TPResources) != 0) {
			// Village overview
			
			NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[parent urlForArguments:[TMAccount village], @"?", urlPart, nil] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
			[request setHTTPShouldHandleCookies:YES];
			
			villageConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
		}
		
		[self parsePage:page fromHTMLNode:body];
		[self setHasDownloaded:YES];
	}
}

#pragma mark -

@end
