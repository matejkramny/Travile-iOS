//
//  Report.m
//  Travian Manager
//
//  Created by Matej Kramny on 27/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Report.h"
#import "TravianPages.h"
#import "Resources.h"
#import "Village.h"
#import "Account.h"
#import "HTMLNode.h"
#import "AppDelegate.h"
#import "Storage.h"
#import "TPIdentifier.h"

@implementation Report

@synthesize name, when, accessID, bounty, deleteID, attacker, attackerVillage, attackerTroops, defender, defenderVillage, defenderTroops, bountyName;

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node {
	
	// Not a report or not a body tag.
	if (page != TPReport || ![[node tagName] isEqualToString:@"body"]) return;
	
	HTMLNode *report_surround = [node findChildWithAttribute:@"id" matchingName:@"report_surround" allowPartial:NO];
	if (!report_surround) {
		NSLog(@"table#report_surround not found");
		return;
	}
	
	HTMLNode *report_content = [report_surround findChildWithAttribute:@"class" matchingName:@"report_content" allowPartial:NO];
	
	NSArray *tables = [report_content findChildTags:@"table"];
	
	for (HTMLNode *table in tables) {
		
		if ([table getAttributeNamed:@"id"] && [[table getAttributeNamed:@"id"] isEqualToString:@"attacker"]) {
			
			// Attacker
			
		}
		
	}
	
}

- (void)downloadAndParse {
	
	Account *account = [[(AppDelegate *)[UIApplication sharedApplication].delegate storage] account];
	
	NSString *url = [NSString stringWithFormat:@"http://%@.travian.%@/berichte.php?id=%@&t=", account.world, account.server, [accessID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	[request setHTTPShouldHandleCookies:YES];
	
	reportConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
}

- (void)delete {
	Account *account = [[(AppDelegate *)[UIApplication sharedApplication].delegate storage] account];
	
	NSString *url = [NSString stringWithFormat:@"http://%@.travian.%@/berichte.php?n1=%@&del=1&%@", account.world, account.server, deleteID,[accessID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	[request setHTTPShouldHandleCookies:YES];
	
	NSURLConnection *conn __unused = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

#pragma mark - NSCoder

- (id)initWithCoder:(NSCoder *)aDecoder {
	
	name = [aDecoder decodeObjectForKey:@"name"];
	when = [aDecoder decodeObjectForKey:@"when"];
	accessID = [aDecoder decodeObjectForKey:@"accessID"];
	bounty = [aDecoder decodeObjectForKey:@"bounty"];
	bountyName = [aDecoder decodeObjectForKey:@"bountyName"];
	deleteID = [aDecoder decodeObjectForKey:@"deleteID"];
	
	attacker = [aDecoder decodeObjectForKey:@"attacker"];
	attackerVillage = [aDecoder decodeObjectForKey:@"attackerVillage"];
	attackerTroops = [aDecoder decodeObjectForKey:@"attackerTroops"];
	defender = [aDecoder decodeObjectForKey:@"defender"];
	defenderVillage = [aDecoder decodeObjectForKey:@"defenderVillage"];
	defenderTroops = [aDecoder decodeObjectForKey:@"defenderTroops"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:name forKey:@"name"];
	[aCoder encodeObject:when forKey:@"when"];
	[aCoder encodeObject:accessID forKey:@"accessID"];
	[aCoder encodeObject:bounty forKey:@"bounty"];
	[aCoder encodeObject:bountyName forKey:@"bountyName"];
	[aCoder encodeObject:deleteID forKey:@"deleteID"];
	
	[aCoder encodeObject:attacker forKey:@"attacker"];
	[aCoder encodeObject:attackerVillage forKey:@"attackerVillage"];
	[aCoder encodeObject:attackerTroops forKey:@"attackerTroops"];
	[aCoder encodeObject:defender forKey:@"defender"];
	[aCoder encodeObject:defenderVillage forKey:@"defenderVillage"];
	[aCoder encodeObject:defenderTroops forKey:@"defenderTroops"];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {  }
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection	{	return NO;	}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error { NSLog(@"Report Connection failed %@ - %@ - %@ - %@", [error localizedDescription], [error localizedFailureReason], [error localizedRecoveryOptions], [error localizedRecoverySuggestion]); }

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[reportData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	reportData = [[NSMutableData alloc] initWithLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	
	// Parse data
	if (connection == reportConnection)
	{
		NSError *error;
		HTMLParser *parser = [[HTMLParser alloc] initWithData:reportData error:&error];
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
