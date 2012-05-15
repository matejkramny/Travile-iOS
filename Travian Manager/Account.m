//
//  Account.m
//  Travian Manager
//
//  Created by Matej Kramny on 11/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Account.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "TPIdentifier.h"
#import "Village.h"

@implementation Account

@synthesize name, username, password, world, server, villages, reports, messages, contacts, hero, hasBeginnersProtection, status;

#pragma mark - TravianPageParsingProtocol

- (void)parsePage:(TravianPages)page fromHTML:(NSString *)html
{
	NSError *error;
	HTMLParser *p = [[HTMLParser alloc] initWithString:html error:&error];
	[self parsePage:page fromHTMLNode:[p body]];
}

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node
{
	// Parses the HTML Body of the Page, and adds data to villages, messages etc
	
	if ((page & TPMaskUnparseable) != 0 || ![[node tagName] isEqualToString:@"body"])
		return; // Can't do anything with unparseable pages or non-body nodes
	
	// Villages
	if (page == TPProfile) {
		
		// Find each village's population & x, y coordinates
		HTMLNode *idVillages = [node findChildWithAttribute:@"id" matchingName:@"villages" allowPartial:NO];
		if (!idVillages) { NSLog (@"Did not find div#villages"); return; }
		// Table > tr (village)
		NSArray *villageList = [[idVillages findChildTag:@"tbody"] findChildTags:@"tr"];
		NSMutableArray *tempVillages = [[NSMutableArray alloc] initWithCapacity:[villageList count]];
		
		for (HTMLNode *villageNode in villageList) {
			Village *tempVillage = [[Village alloc] init];
			
			tempVillage.name = [[[villageNode findChildWithAttribute:@"class" matchingName:@"name" allowPartial:NO] findChildTag:@"a"] contents];
			tempVillage.population = [[[villageNode findChildWithAttribute:@"class" matchingName:@"inhabitants" allowPartial:NO] contents] intValue];
			// x & y
			
			[tempVillages addObject:tempVillage];
		}
		
		// Now find their urlPart
		// Get div with ID 'villageList'
		HTMLNode *villagesList = [node findChildWithAttribute:@"id" matchingName:@"villageList" allowPartial:NO];
		if (!villagesList) { NSLog(@"Did not get div#villageList"); return; }
		// Get div#villageList div.list
		HTMLNode *villageList_div_List = [villagesList findChildWithAttribute:@"class" matchingName:@"list" allowPartial:NO];
		if (!villageList_div_List) { NSLog(@"No div#villageList div.list"); return; }
		
		// List of villages in <li> tags
		NSArray *divList_li = [villageList_div_List findChildTags:@"li"];
		
		for (int i = 0; i < [divList_li count]; i++) {
			HTMLNode *li = [divList_li objectAtIndex:i];
			Village *tempVillage = [[Village alloc] init];
			tempVillage.name = [[li findChildTag:@"a"] contents];
			
			int index = -1;
			for (int ii = 0; ii < [tempVillages count]; ii++) {
				if ([[(Village *)[tempVillages objectAtIndex:ii] name] isEqualToString:tempVillage.name]) {
					index = ii;
					break;
				}
			}
			
			if (index == -1) continue;
			
			tempVillage = [tempVillages objectAtIndex:index];
			
			tempVillage.urlPart = [[li findChildTag:@"a"] getAttributeNamed:@"href"];
		}
		
		// Empty local villages and replace them with tempVillages
		villages = tempVillages;
		
		for (Village *vil in villages) {
			NSLog(@"Village named: %@ has %d population and is accessed by this url: %@", vil.name, vil.population, vil.urlPart);
			[vil downloadAndParse]; // Tell each village to download its data
		}
		
	}
}

#pragma mark - Coders

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	
	name = [coder decodeObjectForKey:@"name"];
	username = [coder decodeObjectForKey:@"username"];
	password = [coder decodeObjectForKey:@"password"];
	world = [coder decodeObjectForKey:@"world"];
	server = [coder decodeObjectForKey:@"server"];
	villages = [coder decodeObjectForKey:@"villages"];
	reports = [coder decodeObjectForKey:@"reports"];
	messages = [coder decodeObjectForKey:@"messages"];
	contacts = [coder decodeObjectForKey:@"contacts"];
	hero = [coder decodeObjectForKey:@"hero"];
	NSNumber *hasBeginnersProtectionObject = [coder decodeObjectForKey:@"hasBeginnersProtection"];
	hasBeginnersProtection = [hasBeginnersProtectionObject boolValue];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:username forKey:@"username"];
	[coder encodeObject:password forKey:@"password"];
	[coder encodeObject:world forKey:@"world"];
	[coder encodeObject:server forKey:@"server"];
	[coder encodeObject:villages forKey:@"villages"];
	[coder encodeObject:reports forKey:@"reports"];
	[coder encodeObject:messages forKey:@"messages"];
	[coder encodeObject:contacts forKey:@"contacts"];
	[coder encodeObject:hero forKey:@"hero"];
	[coder encodeObject:[NSNumber numberWithBool:hasBeginnersProtection] forKey:@"hasBeginnersProtection"];
}

- (void)activateAccount {
	
	// Start connection
	NSString *postData = [[NSString alloc] initWithFormat:@"name=%@&password=%@&s1=Login&w=%@&login=%d", username, password, @"640:960", [[NSDate date] timeIntervalSince1970]];
	NSData *myRequestData = [NSData dataWithBytes: [postData UTF8String] length: [postData length]];
	NSString *stringUrl = [NSString stringWithFormat:@"http://%@.travian.%@/dorf1.php", self.world, self.server];
	NSURL *url = [NSURL URLWithString: stringUrl];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	// Set POST HTTP Headers if necessary
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody: myRequestData];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	
	// Preserve any cookies received
	[request setHTTPShouldHandleCookies:YES];
	
	status = ANotLoggedIn | ALoggingIn;
	
	loginConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
}

- (void)deactivateAccount {
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@.travian.%@/logout.php"]] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	[request setHTTPShouldHandleCookies:YES];
	
	status = ANotLoggedIn;
	
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {  }
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection	{	return NO;	}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error { NSLog(@"Connection failed with error: %@. Fix error by: %@", [error localizedFailureReason], [error localizedRecoverySuggestion]); }

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (connection == loginConnection)
		[loginData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	if (connection == loginConnection)
		loginData = [[NSMutableData alloc] initWithLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// Parse data
	
	if (connection == loginConnection)
	{
		NSError *error;
		HTMLParser *parser = [[HTMLParser alloc] initWithData:loginData error:&error];
		
		if (error) {
			NSLog(@"Error parsing html! %@\n\n%@", [error localizedDescription], [error localizedRecoverySuggestion]);
			return;
		}
		
		TravianPages page = [TPIdentifier identifyPage:[parser body]];
		
		if ((page & (TPLogin | TPNotFound)) != 0) {
			// Still at login page.
			status = ANotLoggedIn | ACannotLogIn;
			return;
		} else if (page & TPResources) {
			NSLog(@"Loading profile");
			
			NSString *stringUrl = [NSString stringWithFormat:@"http://%@.travian.%@/spieler.php", self.world, self.server];
			NSURL *url = [NSURL URLWithString: stringUrl];
			
			NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
			
			// Preserve any cookies received
			[request setHTTPShouldHandleCookies:YES];
			
			loginConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
			
			return;
		}
		
		// Parse the page
		[self parsePage:page fromHTMLNode:[parser body]];
		
		status = ALoggedIn;
		
	}
	
}

@end
