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

@implementation Building

@synthesize bid, name, page, resources, level, buildData, buildConnection, parent;

- (void)buildFromAccount:(Account *)account {
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@.travian.%@/build.php?id=%@", [account world], [account server], bid]] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	// Preserve any cookies received
	[request setHTTPShouldHandleCookies:YES];
	
	buildConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
}

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node {
	
	HTMLNode *idContract = [node findChildWithAttribute:@"id" matchingName:@"contract" allowPartial:NO];
	if (!idContract) {
		NSLog(@"Cannot find div#contract");
		return;
	}
	
	HTMLNode *button = [idContract findChildTag:@"button"];
	if (!button) {
		NSLog(@"Cannot build/upgrade");
		return;
	}
	
	NSString *onclickAttr = [button getAttributeNamed:@"onclick"];
	NSString *url = [[onclickAttr stringByReplacingOccurrencesOfString:@"window.location.href = '" withString:@""] stringByReplacingOccurrencesOfString:@"'; return false;" withString:@""];
	
	NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@.travian.%@/%@", [[parent getParent] world], [[parent getParent] server], url]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60.0];
	
	[request setHTTPShouldHandleCookies:YES];
	
	buildConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
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
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error { NSLog(@"Connection failed with error: %@. Fix error by: %@", [error localizedFailureReason], [error localizedRecoverySuggestion]); }

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[buildData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	buildData = [[NSMutableData alloc] initWithLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	
	// Parse data
	if (connection == buildConnection)
	{
		NSError *error;
		HTMLParser *parser = [[HTMLParser alloc] initWithData:buildData error:&error];
		HTMLNode *body = [parser body];
		
		if (!parser) {
			NSLog(@"Cannot parse build data. Reason: %@, recovery options: %@", [error localizedDescription], [error localizedRecoveryOptions]);
			return;
		}
		
		TravianPages travianPage = [TPIdentifier identifyPage:body];
		
		if ((travianPage & TPBuilding) != 0) // Parse only Building page
			[self parsePage:travianPage fromHTMLNode:body];
	}
	
}


@end
