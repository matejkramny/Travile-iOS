//
//  Building.m
//  Travian Manager
//
//  Created by Matej Kramny on 22/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Building.h"
#import "Account.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "TPIdentifier.h"
#import "Village.h"

@interface Building () {
	NSURLConnection *buildConnection;
	NSURLConnection *descriptionConnection;
	NSURLConnection *cat2Connection;
	NSURLConnection *cat3Connection;
	NSMutableData *cat2Data;
	NSMutableData *cat3Data;
	NSMutableData *buildData;
	NSMutableData *descriptionData;
}

- (void)buildBuildingsListFromBuildIDNode:(HTMLNode *)node;

@end

@implementation Building

@synthesize bid, name, page, resources, level, parent, availableBuildings, description, finishedLoading, cannotBuildReason;

- (void)buildFromAccount:(Account *)account {
	NSLog(@"Starting build connection");
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@.travian.%@/build.php?id=%@", [account world], [account server], bid]] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	// Preserve any cookies received
	[request setHTTPShouldHandleCookies:YES];
	
	buildConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)fetchDescription {
	if (description != nil)
		return;
	
	Account *a = [parent getParent];
	
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@.travian.%@/build.php?id=%@", a.world, a.server, bid]] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	[req setHTTPShouldHandleCookies:YES];
	
	descriptionConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
}

- (void)fetchDescriptionFromNode:(HTMLNode *)node {
	HTMLNode *buildID = [node findChildWithAttribute:@"id" matchingName:@"build"allowPartial:NO];
	if (!buildID) return;
	
	HTMLNode *build_desc = [buildID findChildWithAttribute:@"class" matchingName:@"build_desc" allowPartial:NO];
	
	// Description
	NSString *aTagRaw = [[build_desc findChildTag:@"a"] rawContents];
	NSString *desc = [[[[[[build_desc rawContents] stringByReplacingOccurrencesOfString:aTagRaw withString:@""] stringByReplacingOccurrencesOfString:@"<div class=\"build_desc\">" withString:@""] stringByReplacingOccurrencesOfString:@"</div>" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
	
	[self setDescription:desc];
}

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node {
	NSLog(@"Parsing build");
	
	HTMLNode *build = [node findChildWithAttribute:@"id" matchingName:@"build" allowPartial:NO];
	if ([[build getAttributeNamed:@"class"] isEqualToString:@"gid0"]) {
		// Nothing built on this location
		
		if (availableBuildings == nil) {
			// Load other catogories
			
			Account *a = [parent getParent];
			
			NSString *base = [NSString stringWithFormat:@"http://%@.travian.%@/build.php?id=%@&category=", a.world, a.server, bid];
			
			NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[base stringByAppendingString:@"2"]] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
			[req setHTTPShouldHandleCookies:YES];
			cat2Connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
		}
		[self buildBuildingsListFromBuildIDNode:build];
		
		NSLog(@"Nothing built on this location.");
		
		return;
	}
	
	HTMLNode *idContract = [node findChildWithAttribute:@"id" matchingName:@"contract" allowPartial:NO];
	if (!idContract) {
		NSLog(@"Cannot find div#contract");
		return;
	}
	
	HTMLNode *button = [idContract findChildTag:@"button"];
	if (!button) {
		NSLog(@"Cannot build/upgrade");
		
		HTMLNode *contractLink = [idContract findChildWithAttribute:@"class" matchingName:@"contractLink" allowPartial:NO];
		HTMLNode *messageSpan = [contractLink findChildTag:@"span"];
		
		[self setFinishedLoading:YES];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Error building " stringByAppendingFormat:@"%@", name] message:[messageSpan contents] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		
		return;
	}
	
	NSString *onclickAttr = [button getAttributeNamed:@"onclick"];
	NSString *url = [[onclickAttr stringByReplacingOccurrencesOfString:@"window.location.href = '" withString:@""] stringByReplacingOccurrencesOfString:@"'; return false;" withString:@""];
	
	NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@.travian.%@/%@", [[parent getParent] world], [[parent getParent] server], url]];
	[self buildFromURL:URL];
	
	[self setFinishedLoading:YES];
}

- (void)buildFromURL:(NSURL *)url {
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
	NSArray *contracts = [node findChildrenWithAttribute:@"id" matchingName:@"contract" allowPartial:NO];
	
	for (int i = 0; i < [titles count]; i++) {
		Building *b = [[Building alloc] init];
		HTMLNode *title = [titles objectAtIndex:i];
		HTMLNode *desc = [descs objectAtIndex:i];
		HTMLNode *contract = [contracts objectAtIndex:i];
		
		// Title
		b.name = [title contents];
		// Description
		NSString *aTagRaw = [[desc findChildTag:@"a"] rawContents];
		b.description = [[[[[[desc rawContents] stringByReplacingOccurrencesOfString:aTagRaw withString:@""] stringByReplacingOccurrencesOfString:@"<div class=\"build_desc\">" withString:@""] stringByReplacingOccurrencesOfString:@"</div>" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
		// Contract
		HTMLNode *button = [contract findChildTag:@"button"];
		if (!button) {
			// Cannot build this
			
			// Reason
			HTMLNode *spanNone = [contract findChildOfClass:@"none"];
			
			if (!spanNone) {
				// Check if there are Build conditions
				NSArray *conditions = [contract findChildrenWithAttribute:@"class" matchingName:@"buildingCondition" allowPartial:YES];
				NSMutableArray *conditions_strings = [[NSMutableArray alloc] initWithCapacity:[conditions count]];
				for (HTMLNode *n in conditions) {
					HTMLNode *a = [n findChildTag:@"a"];
					HTMLNode *span = [n findChildTag:@"span"];
					
					if ([[n getAttributeNamed:@"class"] rangeOfString:@"error"].location != NSNotFound) {
						// Unfulfilled condition
						NSString *s = [NSString stringWithFormat:@"%@ %@", [a contents], [span contents]];
						
						[conditions_strings addObject:s];
					}
				}
			} else
				cannotBuildReason = [spanNone contents];
		} else
			b.upgradeURLString = [[[button getAttributeNamed:@"onclick"] stringByReplacingOccurrencesOfString:@"window.location.href = '" withString:@""] stringByReplacingOccurrencesOfString:@"'; return false;" withString:@""];
		
		[bs addObject:b];
	}
	
	if (availableBuildings)
		availableBuildings = [availableBuildings arrayByAddingObjectsFromArray:bs];
	else
		availableBuildings = [bs copy];
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
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error { NSLog(@"Building Connection failed with error: %@. Fix error by: %@", [error localizedFailureReason], [error localizedRecoverySuggestion]); }

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
			NSLog(@"HTML Parser error");
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
			
			Account *a = [parent getParent];
			
			NSString *base = [NSString stringWithFormat:@"http://%@.travian.%@/build.php?id=%@&category=", a.world, a.server, bid];
			
			NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[base stringByAppendingString:@"3"]] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
			[req setHTTPShouldHandleCookies:YES];
			cat3Connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
		}
		else if (connection == cat3Connection)
			data = cat3Data;
		
		NSError *error;
		HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
		HTMLNode *body = [parser body];
		
		if (!parser) {
			NSLog(@"Cannot parse build data. Reason: %@, recovery options: %@", [error localizedDescription], [error localizedRecoveryOptions]);
			return;
		}
		
		TravianPages travianPage = [TPIdentifier identifyPage:body];
		
		if ((travianPage & TPBuilding) != 0) // Parse only Building page
			[self parsePage:travianPage fromHTMLNode:body];
		
		if (connection == cat3Connection) {
			// Finished loading list of buildings
			NSLog(@"Finished loading list of buildings");
			[self setFinishedLoading:YES];
		}
	}
	
}


@end
