//
//  Message.m
//  Travian Manager
//
//  Created by Matej Kramny on 27/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Message.h"
#import "AppDelegate.h"
#import "Storage.h"
#import "Account.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "TPIdentifier.h"

@implementation Message

@synthesize sender, title, content, href, when, read, accessID;

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node {
	// TODO test this
	HTMLNode *divMessage = [node findChildWithAttribute:@"id" matchingName:@"message" allowPartial:NO];
	if (!divMessage) {
		NSLog(@"No div#message present");
		return;
	}
	
	[self setContent:[divMessage contents]];
}

- (void)downloadAndParse {
	Account *account = [[(AppDelegate *)[UIApplication sharedApplication].delegate storage] account];
	
	NSString *url = [NSString stringWithFormat:@"http://%@.travian.%@/%@", account.world, account.server, href];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	[request setHTTPShouldHandleCookies:YES];
	
	messageConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)delete {
	Account *account = [[(AppDelegate *)[UIApplication sharedApplication].delegate storage] account];
	
	NSString *data = [NSString stringWithFormat:@"delmsg=Delete&s=0&n1=%@", accessID];
	
	NSData *myRequestData = [NSData dataWithBytes: [data UTF8String] length: [data length]];
	NSString *stringUrl = [NSString stringWithFormat:@"http://%@.travian.%@/nachrichten.php", [account world], [account server]];
	NSURL *url = [NSURL URLWithString: stringUrl];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	// Set POST HTTP Headers if necessary
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody: myRequestData];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	
	// Preserve any cookies received
	[request setHTTPShouldHandleCookies:YES];
	
	@autoreleasepool {
		NSURLConnection *c __unused = [[NSURLConnection alloc] initWithRequest:request delegate:nil startImmediately:YES];
	}
}

- (void)send:(NSString *)recipient {
	Account *account = [[(AppDelegate *)[UIApplication sharedApplication].delegate storage] account];
	
	NSString *url = [NSString stringWithFormat:@"http://%@.travian.%@/nachrichten.php", account.world, account.server];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	NSString *postData = [[NSString alloc] initWithFormat:@"an=%@&be=%@&message=%@&c=e8c", recipient, title, content];
	NSData *myRequestData = [NSData dataWithBytes: [postData UTF8String] length: [postData length]];
	
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody: myRequestData];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	
	// Preserve any cookies received
	[request setHTTPShouldHandleCookies:YES];
	
	NSURLConnection *conn __unused = [[NSURLConnection alloc] initWithRequest:request delegate:nil startImmediately:YES];
}

#pragma mark - NSCoder

- (id)initWithCoder:(NSCoder *)aDecoder {
	title = [aDecoder decodeObjectForKey:@"title"];
	content = [aDecoder decodeObjectForKey:@"content"];
	href = [aDecoder decodeObjectForKey:@"href"];
	when = [aDecoder decodeObjectForKey:@"when"];
	NSNumber *n = [aDecoder decodeObjectForKey:@"read"];
	read = [n boolValue];
	accessID = [aDecoder decodeObjectForKey:@"accessID"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:title forKey:@"title"];
	[aCoder encodeObject:content forKey:@"content"];
	[aCoder encodeObject:href forKey:@"href"];
	[aCoder encodeObject:when forKey:@"when"];
	[aCoder encodeObject:[NSNumber numberWithBool:read] forKey:@"read"];
	[aCoder encodeObject:accessID forKey:@"accessID"];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {  }
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection	{	return NO;	}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error { NSLog(@"Report Connection failed %@ - %@ - %@ - %@", [error localizedDescription], [error localizedFailureReason], [error localizedRecoveryOptions], [error localizedRecoverySuggestion]); }

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[messageData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	messageData = [[NSMutableData alloc] initWithLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// Parse data
	if (connection == messageConnection)
	{
		NSError *error;
		HTMLParser *parser = [[HTMLParser alloc] initWithData:messageData error:&error];
		HTMLNode *body = [parser body];
		
		if (!parser) {
			NSLog(@"Cannot parse report data. Reason: %@, recovery options: %@", [error localizedDescription], [error localizedRecoveryOptions]);
			return;
		}
		
		TravianPages travianPage = [TPIdentifier identifyPage:body];
		
		[self parsePage:travianPage fromHTMLNode:body];
	}
}

@end
