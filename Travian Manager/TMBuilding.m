/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMBuilding.h"
#import "TMAccount.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "TPIdentifier.h"
#import "TMVillage.h"
#import "TMResources.h"
#import "TMBuildingAction.h"

@interface TMBuilding () {
	NSURLConnection *buildConnection;
	NSURLConnection *descriptionConnection;
	NSURLConnection *cat2Connection;
	NSURLConnection *cat3Connection;
	NSMutableData *cat2Data;
	NSMutableData *cat3Data;
	NSMutableData *buildData;
	NSMutableData *descriptionData;
	bool wantsToBuild;
}

- (void)buildBuildingsListFromBuildIDNode:(HTMLNode *)node;

@end

@implementation TMBuilding

@synthesize bid, name, page, resources, level, parent, availableBuildings, description, finishedLoading, cannotBuildReason, coordinates, buildConditionsDone, buildConditionsError, isBeingUpgraded, upgradeURLString, gid, properties, actions, buildDiv, finishedLoadingKVOIdentifier;

- (id)init {
	self = [super init];
	
	if (self) {
		finishedLoadingKVOIdentifier = @"finishedLoading";
	}
	
	return self;
}

- (void)buildFromAccount:(TMAccount *)account {
	wantsToBuild = true;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[account urlForArguments:@"build.php?id=", bid, @"&", parent.urlPart, nil] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	// Preserve any cookies received
	[request setHTTPShouldHandleCookies:YES];
	
	buildConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)fetchDescription {
	wantsToBuild = false;
	
	TMAccount *a = [parent getParent];
	
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[a urlForArguments:@"build.php?t=0&tt=0&s=0&id=", bid, @"&", parent.urlPart, nil] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	[req setHTTPShouldHandleCookies:YES];
	
	descriptionConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
}

- (void)fetchDescriptionFromNode:(HTMLNode *)node {
	HTMLNode *buildID = [node findChildWithAttribute:@"id" matchingName:@"build" allowPartial:NO];
	if (!buildID) return;
	
	HTMLNode *build_desc = [buildID findChildWithAttribute:@"class" matchingName:@"build_desc" allowPartial:NO];
	
	// Description
	NSString *aTagRaw = [[build_desc findChildTag:@"a"] rawContents];
	NSString *desc = [[[[[[build_desc rawContents] stringByReplacingOccurrencesOfString:aTagRaw withString:@""] stringByReplacingOccurrencesOfString:@"<div class=\"build_desc\">" withString:@""] stringByReplacingOccurrencesOfString:@"</div>" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
	
	// Properties
	NSMutableDictionary *props = [[NSMutableDictionary alloc] initWithCapacity:3];
	HTMLNode *build_value = [buildID findChildWithAttribute:@"id" matchingName:@"build_value" allowPartial:NO];
	NSArray *trs = [build_value findChildTags:@"tr"];
	for (HTMLNode *tr in trs) {
		NSString *th = [[tr findChildTag:@"th"] contents];
		NSString *span = [[[tr findChildTag:@"td"] findChildTag:@"span"] contents];
		
		if ([th length] && [span length]) { // Checks if prop not empty
			if ([th hasSuffix:@":"])
				th = [th substringToIndex:[th length]-1];
			
			if (self.gid == TBCranny && [[tr getAttributeNamed:@"class"] isEqualToString:@"overall"]) {
				th = NSLocalizedString(@"Cranny Overall", @"Overall string is too long in cranny building. This is a short-text like 'All Resoruces Hidden'");
			}
			
			[props setObject:span forKey:th];
		}
	}
	
	[self setProperties:[props copy]];
	[self setDescription:desc];
	
	HTMLNode *contract = [buildID findChildWithAttribute:@"id" matchingName:@"contract" allowPartial:YES];
	
	[self fetchContractConditionsFromContractID:contract];
	[self fetchResourcesFromContract:contract];
	
	bool gid0 = [[buildID getAttributeNamed:@"class"] isEqualToString:@"gid0"];
	if (gid0 && availableBuildings)
		availableBuildings = nil;
	
	if (gid == TBAcademy || gid == TBForge || gid == TBCityHall) {
		// Parse research
		[self fetchActionsFromIDBuild:buildID];
	}
	
	[self setBuildDiv:buildID]; // Allow objects that inherit from Building to fetch properties
	
	[self parsePage:page fromHTMLNode:node];
}

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node {
	HTMLNode *build = [node findChildWithAttribute:@"id" matchingName:@"build" allowPartial:NO];
	if ([[build getAttributeNamed:@"class"] isEqualToString:@"gid0"]) {
		// Nothing built on this location
		
		if (availableBuildings == nil) {
			// Load other catogories
			
			TMAccount *a = [parent getParent];
			
			NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[a urlForArguments:@"build.php?id=", bid, @"&category=2", @"&", parent.urlPart, nil] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
			[req setHTTPShouldHandleCookies:YES];
			cat2Connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
		}
		[self buildBuildingsListFromBuildIDNode:build];
		
		return;
	}
	
	if (!wantsToBuild) {
		[self setFinishedLoading:YES];
		return;
	}
	
	HTMLNode *idContract = [node findChildWithAttribute:@"id" matchingName:@"contract" allowPartial:NO];
	if (!idContract) {
		return;
	}
	
	HTMLNode *button = [idContract findChildWithAttribute:@"class" matchingName:@"build" allowPartial:YES];
	if (!button) {
		HTMLNode *contractLink = [idContract findChildWithAttribute:@"class" matchingName:@"contractLink" allowPartial:NO];
		HTMLNode *messageSpan = [contractLink findChildTag:@"span"];
		
		[self setFinishedLoading:YES];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Error building " stringByAppendingFormat:@"%@", name] message:[messageSpan contents] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		
		return;
	}
	
	NSString *onclickAttr = [button getAttributeNamed:@"onclick"];
	NSString *url = [[onclickAttr stringByReplacingOccurrencesOfString:@"window.location.href = '" withString:@""] stringByReplacingOccurrencesOfString:@"'; return false;" withString:@""];
	
	NSURL *URL = [[parent getParent] urlForString:url];
	[self buildFromURL:URL];
	
	[self setFinishedLoading:YES];
}

- (void)buildFromURL:(NSURL *)url {
	wantsToBuild = true;
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60.0];
	
	[request setHTTPShouldHandleCookies:YES];
	
	buildConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)buildBuildingsListFromBuildIDNode:(HTMLNode *)node {
	// node is currently scoped in <div id="build" class="gid0">
	/* The source has no tabular structure.. It is as follows:
	 <parent>
	 <h2>title</h2>
	 <div class="build_desc">
	 <a></a>
	 ...desc
	 </div>
	 <div id="contract"></div>
	 <h2>title2</h2>
	 ... repeats
	 </parent>
	 */
	
	NSMutableArray *bs = [[NSMutableArray alloc] init];
	
	NSArray *titles = [node findChildTags:@"h2"];
	NSArray *descs = [node findChildrenWithAttribute:@"class" matchingName:@"build_desc" allowPartial:NO];
	NSArray *contracts = [node findChildrenWithAttribute:@"id" matchingName:@"contract" allowPartial:YES];
	
	for (int i = 0; i < [titles count]; i++) {
		TMBuilding *b = [[TMBuilding alloc] init];
		HTMLNode *title = [titles objectAtIndex:i];
		HTMLNode *desc = [descs objectAtIndex:i];
		HTMLNode *contract = [contracts objectAtIndex:i];
		
		// Title
		b.name = [title contents];
		// Resources
		[b fetchResourcesFromContract:contract];
		// Description
		NSString *aTagRaw = [[desc findChildTag:@"a"] rawContents];
		b.description = [[[[[[desc rawContents] stringByReplacingOccurrencesOfString:aTagRaw withString:@""] stringByReplacingOccurrencesOfString:@"<div class=\"build_desc\">" withString:@""] stringByReplacingOccurrencesOfString:@"</div>" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
		
		// GID?
		
		// Contract
		HTMLNode *button = [contract findChildWithAttribute:@"class" matchingName:@"new" allowPartial:YES];
		if (!button) {
			// Cannot build this
			
			[b fetchContractConditionsFromContractID:contract];
		} else
			b.upgradeURLString = [[[button getAttributeNamed:@"onclick"] stringByReplacingOccurrencesOfString:@"window.location.href = '" withString:@""] stringByReplacingOccurrencesOfString:@"'; return false;" withString:@""];
		
		b.parent = self.parent;
		
		// Inherits some properties from this building
		b.page = self.page;
		b.bid = self.bid;
		
		[bs addObject:b];
	}
	
	if (availableBuildings)
		availableBuildings = [availableBuildings arrayByAddingObjectsFromArray:bs];
	else
		availableBuildings = [bs copy];
}

- (void)fetchContractConditionsFromContractID:(HTMLNode *)contract {
	// Reason
	HTMLNode *spanNone = [contract findChildOfClass:@"none"];
	
	if ([contract findChildTag:@"button"] || !spanNone) {
		// Check if there are Build conditions
		NSArray *conditions = [contract findChildrenWithAttribute:@"class" matchingName:@"buildingCondition" allowPartial:YES];
		NSMutableArray *undone_conditions = [[NSMutableArray alloc] init];
		NSMutableArray *done_conditions = [[NSMutableArray alloc] init];
		for (HTMLNode *n in conditions) {
			HTMLNode *a = [n findChildTag:@"a"];
			HTMLNode *span = [n findChildTag:@"span"];
			
			if (!span || !a)
				// continue - not enough details
				continue;
			
			NSString *s = [NSString stringWithFormat:@"%@ %@", [a contents], [span contents]];
			
			if ([[n getAttributeNamed:@"class"] rangeOfString:@"error"].location != NSNotFound) {
				// Unfulfilled condition
				[undone_conditions addObject:s];
			} else {
				// Completed condition
				[done_conditions addObject:s];
			}
		}
		
		buildConditionsDone = [done_conditions copy];
		buildConditionsError = [undone_conditions copy];
	} else
		cannotBuildReason = [spanNone contents];
}

- (void)fetchResourcesFromContract:(HTMLNode *)contract {
	TMResources *res = [[TMResources alloc] init];
	
	NSAssert(contract != nil, @"HTMLNode contract nil!");
	
	HTMLNode *div;
	if ([[contract getAttributeNamed:@"id"] rangeOfString:@"contract"].location != NSNotFound) {
		div = [[contract findChildWithAttribute:@"class" matchingName:@"contractCosts" allowPartial:NO] findChildWithAttribute:@"class" matchingName:@"showCosts" allowPartial:NO];
	} else {
		div = contract;
	}
	
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
			continue;
		}
		
		[spansParsed addObject:[NSNumber numberWithInt:[[[[[p body] findChildTag:@"span"] contents] stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] intValue]]];
	}
	
	if ([spansParsed count] >= 4) {
		res.wood = [[spansParsed objectAtIndex:0] intValue];// Wood
		res.clay = [[spansParsed objectAtIndex:1] intValue];// Clay
		res.iron = [[spansParsed objectAtIndex:2] intValue];// Iron
		res.wheat = [[spansParsed objectAtIndex:3] intValue];// Wheat
		
		resources = res;
	}
}

- (void)fetchActionsFromIDBuild:(HTMLNode *)buildID {
	HTMLNode *build_details = [buildID findChildOfClass:@"build_details researches"];
	if (!build_details)
		return;
	
	NSArray *researches = [build_details findChildrenOfClass:@"research"];
	NSMutableArray *actions_raw = [[NSMutableArray alloc] initWithCapacity:[researches count]];
	
	for (HTMLNode *research in researches) {
		[actions_raw addObject:[[TMBuildingAction alloc] initWithResearchDiv:research]];
	}
	
	actions = [actions_raw copy];
	actions_raw = nil;
}

#pragma mark - Coders

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    
	resources = [coder decodeObjectForKey:@"resources"];
	bid = [coder decodeObjectForKey:@"bid"];
	name = [coder decodeObjectForKey:@"name"];
	NSNumber *n = [coder decodeObjectForKey:@"page"];
	page = [n intValue];
	n = [coder decodeObjectForKey:@"level"];
	level = [n intValue];
	parent = [coder decodeObjectForKey:@"parent"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:resources forKey:@"resources"];
	[coder encodeObject:bid forKey:@"bid"];
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:[NSNumber numberWithInt:page] forKey:@"page"];
	[coder encodeObject:[NSNumber numberWithInt:level] forKey:@"level"];
	[coder encodeObject:parent forKey:@"parent"];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {  }
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection	{	return NO;	}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (connection == buildConnection)
		[buildData appendData:data];
	else if (connection == cat2Connection)
		[cat2Data appendData:data];
	else if (connection == cat3Connection)
		[cat3Data appendData:data];
	else if (connection == descriptionConnection)
		[descriptionData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	if (connection == buildConnection)
		buildData = [[NSMutableData alloc] initWithLength:0];
	else if (connection == cat2Connection)
		cat2Data = [[NSMutableData alloc] initWithLength:0];
	else if (connection == cat3Connection)
		cat3Data = [[NSMutableData alloc] initWithLength:0];
	else if (connection == descriptionConnection)
		descriptionData = [[NSMutableData alloc] initWithLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (connection == descriptionConnection) {
		NSError *error;
		HTMLParser *parser = [[HTMLParser alloc] initWithData:descriptionData error:&error];
		
		if (error) {
			return;
		}
		
		TravianPages travianPage = [TPIdentifier identifyPage:[parser body]];
		if ((travianPage & TPBuilding) != 0) // Parse only Building page
			[self fetchDescriptionFromNode:[parser body]];
	}
	
	
	// Parse data
	if (connection == buildConnection || connection == cat2Connection || connection == cat3Connection)
	{
		if (connection == buildConnection) {
			availableBuildings = nil;
			[self setFinishedLoading:NO];
		}
		
		NSData *data;
		if (connection == buildConnection)
			data = buildData;
		else if (connection == cat2Connection) {
			data = cat2Data;
			
			TMAccount *a = [parent getParent];
			
			NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[a urlForArguments:@"build.php?id=", bid, @"&category=3", @"&", parent.urlPart, nil] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
			[req setHTTPShouldHandleCookies:YES];
			cat3Connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
		}
		else if (connection == cat3Connection)
			data = cat3Data;
		
		NSError *error;
		HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
		HTMLNode *body = [parser body];
		
		if (!parser) {
			return;
		}
		
		TravianPages travianPage = [TPIdentifier identifyPage:body];
		
		if ((travianPage & TPBuilding) != 0) // Parse only Building page
			[self parsePage:travianPage fromHTMLNode:body];
		
		if (connection == cat3Connection) {
			// Finished loading list of buildings
			[self setFinishedLoading:YES];
		}
	}
}

@end
