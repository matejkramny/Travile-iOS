/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMFarmList.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "TPIdentifier.h"
#import "TMFarmListEntry.h"
#import "TMFarmListEntryFarm.h"
#import "NSString+HTML.h"
#import "TMAccount.h"
#import "TMStorage.h"

@interface TMFarmList () {
	void (^loadCompletion)(); // not sure if a good idea.. unusable with multiple objects trying to get the status of the farm list.
	NSURLConnection *loadConnection;
	NSMutableData *loadData;
}

@end

@implementation TMFarmList

@synthesize farmLists, loaded;

- (void)loadFarmList:(void (^)())completion {
	loadCompletion = completion;
	loaded = false;
	
	// Get request to farm list url..
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[TMStorage sharedStorage].account urlForString:[TMAccount farmList]] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60.0];
	
	[request setHTTPShouldHandleCookies:YES];
	
	loadConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

#pragma mark - TMPageParsingProtocol

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node {
	if (!((page & TPBuilding) != 0)) {
		return;
	}
	
	HTMLNode *divRaidList = [node findChildWithAttribute:@"id" matchingName:@"raidList" allowPartial:NO];
	if (divRaidList) {
		NSArray *lists = [divRaidList findChildrenWithAttribute:@"id" matchingName:@"list" allowPartial:YES];
		NSMutableArray *mutableFarmLists = [[NSMutableArray alloc] init];
		for (HTMLNode *list in lists) {
			// Find the form tag.
			HTMLNode *form = [list findChildTag:@"form"];
			if (!form) {
				continue;
			}
			// Check if list belongs to this village.. They are hidden when they belong to another village.
			HTMLNode *listContent = [list findChildWithAttribute:@"class" matchingName:@"listContent" allowPartial:YES];
			if ([[listContent getAttributeNamed:@"class"] rangeOfString:@"hide"].location != NSNotFound) {
				continue;
			}
			
			TMFarmListEntry *entry = [[TMFarmListEntry alloc] init];
			
			// Collect input[type='hidden'] tags.
			NSMutableString *postData = [[NSMutableString alloc] init];
			NSArray *hiddenInputs = [list findChildrenWithAttribute:@"type" matchingName:@"hidden" allowPartial:NO];
			for (HTMLNode *hiddenInput in hiddenInputs) {
				NSString *name = [hiddenInput getAttributeNamed:@"name"];
				NSString *value = [hiddenInput getAttributeNamed:@"value"];
				if (!name || !value) continue;
				
				[postData appendFormat:@"%@=%@&", name, value];
			}
			
			entry.postData = postData;
			
			HTMLNode *listTitle = [list findChildWithAttribute:@"class" matchingName:@"listTitleText" allowPartial:NO];
			NSArray *listTitleChildren = [listTitle children];
			NSString *listName = [[[[listTitleChildren objectAtIndex:listTitleChildren.count-2] rawContents] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
			
			entry.name = listName;
			
			// Actual rows of farms
			NSArray *slotRows = [listContent findChildrenWithAttribute:@"class" matchingName:@"slotRow" allowPartial:NO];
			NSMutableArray *listFarms = [[NSMutableArray alloc] initWithCapacity:slotRows.count];
			for (HTMLNode *slotRow in slotRows) {
				TMFarmListEntryFarm *entry = [[TMFarmListEntryFarm alloc] init];
				
				// POST name
				HTMLNode *checkbox = [slotRow findChildWithAttribute:@"type" matchingName:@"checkbox" allowPartial:NO];
				entry.postName = [checkbox getAttributeNamed:@"name"];
				
				// Target Village Name
				HTMLNode *target = [[slotRow findChildWithAttribute:@"class" matchingName:@"village" allowPartial:NO] findChildTag:@"label"];
				entry.targetName = [target contents];
				
				// Population
				HTMLNode *population = [slotRow findChildWithAttribute:@"class" matchingName:@"ew" allowPartial:NO];
				entry.targetPopulation = [[population contents] stringByRemovingNewLinesAndWhitespace];
				
				// Distance to target
				HTMLNode *distance = [slotRow findChildWithAttribute:@"class" matchingName:@"distance" allowPartial:NO];
				entry.distance = [[distance contents] stringByRemovingNewLinesAndWhitespace];
				
				// List of troops
				HTMLNode *troops = [slotRow findChildWithAttribute:@"class" matchingName:@"troops" allowPartial:NO];
				if (troops) {
					NSArray *troopIcons = [troops findChildrenWithAttribute:@"class" matchingName:@"troopIcon" allowPartial:NO];
					NSMutableArray *troopsArray = [[NSMutableArray alloc] initWithCapacity:troopIcons.count];
					for (HTMLNode *troopIcon in troopIcons) {
						HTMLNode *img = [troopIcon findChildTag:@"img"];
						NSString *troopName = @"";
						if (img) {
							troopName = [img getAttributeNamed:@"alt"];
						}
						
						NSString *troopCount = @"";
						HTMLNode *span = [troopIcon findChildTag:@"span"];
						if (span) {
							troopCount = [span contents];
						}
						
						[troopsArray addObject:@{@"name": troopName, @"count": troopCount}];
					}
					
					entry.troops = troopsArray;
				}
				
				[listFarms addObject:entry];
			}
			
			entry.farms = listFarms;
			[mutableFarmLists addObject:entry];
		}
		
		farmLists = mutableFarmLists;
	}
}

#pragma mark - NSURLConnectionDataDelegate, NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {  }
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection	{	return NO;	}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	loadCompletion();
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[loadData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
	loadData = [[NSMutableData alloc] initWithLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSError *error = nil;
	HTMLParser *parser = [[HTMLParser alloc] initWithData:loadData error:&error];
	HTMLNode *body = [parser body];
	
	TravianPages page = [TPIdentifier identifyPage:body];
	
	[self parsePage:page fromHTMLNode:body];
	
	[self setLoaded:YES];
	if (loadCompletion) {
		loadCompletion();
	}
}

@end
