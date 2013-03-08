// This code is distributed under the terms and conditions of the MIT license.

/* * Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial
 * portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
 * OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "TMReport.h"
#import "TMPages.h"
#import "TMResources.h"
#import "TMVillage.h"
#import "TMAccount.h"
#import "HTMLNode.h"
#import "TMStorage.h"
#import "TPIdentifier.h"

@interface TMReport () {
	NSURLConnection *deleteConnection;
	NSURLConnection *reportConnection;
	NSMutableData *reportData;
}

@end

@implementation TMReport

@synthesize name, when, accessID, bounty, deleteID, attacker, attackerVillage, attackerTroops, defender, defenderVillage, defenderTroops, bountyName;

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node {
	
	// Not a report or not a body tag.
	if (page != TPReport || ![[node tagName] isEqualToString:@"body"]) return;
	
	HTMLNode *report_surround = [node findChildWithAttribute:@"id" matchingName:@"report_surround" allowPartial:NO];
	if (!report_surround) {
		return;
	}
	
	HTMLNode *report_content = [report_surround findChildWithAttribute:@"class" matchingName:@"report_content" allowPartial:NO];
	
	NSArray *tables = [report_content findChildTags:@"table"];
	
	for (HTMLNode *table in tables) {
		
		if ([table getAttributeNamed:@"id"] && [[table getAttributeNamed:@"id"] isEqualToString:@"attacker"]) {
			
			// Attacker
			// TODO this
			
		}
		
	}
	
}

- (void)downloadAndParse {
	
	TMAccount *account = [[TMStorage sharedStorage] account];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[account urlForArguments:[TMAccount reports], @"?id=", [accessID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"&t=", nil] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	[request setHTTPShouldHandleCookies:YES];
	
	reportConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
}

- (void)delete {
	TMAccount *account = [[TMStorage sharedStorage] account];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[account urlForArguments:[TMAccount reports], @"?n1=", deleteID, @"&del=1&", nil] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	[request setHTTPShouldHandleCookies:YES];
	
	deleteConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
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
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}

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
			return;
		}
		
		TravianPages travianPage = [TPIdentifier identifyPage:body];
		
		[self parsePage:travianPage fromHTMLNode:body];
	}
	
}

@end
