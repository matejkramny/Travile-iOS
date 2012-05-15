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

@implementation Village

@synthesize resources, resourceProduction, troops, movements, name;
@synthesize urlPart, loyalty, population, warehouse, granary, consumption, x, y;
@synthesize villageConnection, villageData;

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

- (void)parsePage:(TravianPages)page fromHTML:(NSString *)html
{
	NSError *error;
	HTMLParser *p = [[HTMLParser alloc] initWithString:html error:&error];
	[self parsePage:page fromHTMLNode:[p body]];
}

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node
{
	// Do not parse unparseable pages || tagName must be body - root element
	if ((page & TPMaskUnparseable) != 0 || ![[node tagName] isEqualToString:@"body"])
		return;
	
	if ((page & TPResources) != 0) {
		NSArray *woodRaw = [[[node findChildWithAttribute:@"id" matchingName:@"l1" allowPartial:NO] contents] componentsSeparatedByString:@"/"];
		
		warehouse = [[woodRaw objectAtIndex:1] intValue];
		
		if (!resources)
			resources = [[Resources alloc] init];
		
		[resources setWood:[[woodRaw objectAtIndex:0] intValue]];
		resources.clay = [[[[[node findChildWithAttribute:@"id" matchingName:@"l2" allowPartial:NO] contents] componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
		resources.iron = [[[[[node findChildWithAttribute:@"id" matchingName:@"l3" allowPartial:NO] contents] componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
		
		NSArray *rawWheat = [[[node findChildWithAttribute:@"id" matchingName:@"l4" allowPartial:NO] contents] componentsSeparatedByString:@"/"];
		granary = [[rawWheat objectAtIndex:1] intValue];
		[resources setWheat:[[rawWheat objectAtIndex:0] intValue]];
		consumption = [[[[[node findChildWithAttribute:@"id" matchingName:@"l5" allowPartial:NO] contents] componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
		
		[resourceProduction parsePage:page fromHTMLNode:node];
		// get basic troops
		// get basic movements
	} else if ((page & TPBuildList) != 0) {
		// get construction list
	} else if ((page & TPBuilding) != 0) {
		[self parseBuilding:node];
		// get comprehensive info about troops
		// get all movements
	} else {
		
	}
	
	// get loyalty
}

- (void)parseBuilding:(HTMLNode *)body {
	// check if the building is a rally point to update troops
	
	
}

#pragma mark - Coders

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    
	resources = [coder decodeObjectForKey:@"resources"];
	resourceProduction = [coder decodeObjectForKey:@"resourceProduction"];
	troops = [coder decodeObjectForKey:@"troops"];
	movements = [coder decodeObjectForKey:@"movements"];
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
		
		[self parsePage:page fromHTMLNode:body];
		
		if ((page & TPResources) != 0)
		{
			// Make another request for village rally point
			Account *account = [[(AppDelegate *)[UIApplication sharedApplication].delegate storage] account]; // This village's owner
			
			NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@.travian.%@/build.php?tt=1&id=39", account.world, account.server]] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60]; // Building Spot # 39 & 1st tab (Overview)
			[request setHTTPShouldHandleCookies:YES];
			
			villageConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
		}
	}
	
}

@end
