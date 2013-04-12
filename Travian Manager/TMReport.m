/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
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

@synthesize name, when, accessID, bounty, deleteID, attacker, defenders, bountyName, parsed;

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node {
	
	// Not a report or not a body tag.
	if (page != TPReports || ![[node tagName] isEqualToString:@"body"]) return;
	
	HTMLNode *report_surround = [node findChildWithAttribute:@"id" matchingName:@"report_surround" allowPartial:NO];
	if (!report_surround) {
		return;
	}
	
	HTMLNode *report_content = [report_surround findChildWithAttribute:@"class" matchingName:@"report_content" allowPartial:NO];
	if (!report_content) {
		report_content = [report_surround findChildWithAttribute:@"id" matchingName:@"message" allowPartial:NO];
		if (!report_content) {
			return;
		}
	}
	
	NSArray *tables = [report_content findChildTags:@"table"];
	
	for (HTMLNode *table in tables) {
		
		NSString *_id = [table getAttributeNamed:@"id"];
		if ([_id isEqualToString:@"attacker"] || _id == nil) {
			
			// covers adventures, troop attacks
			NSMutableString *tblName = [[NSMutableString alloc] init];
			NSMutableArray *troopNames = [[NSMutableArray alloc] initWithCapacity:10];
			NSMutableArray *troops = [[NSMutableArray alloc] initWithCapacity:10];
			NSMutableArray *casualties = [[NSMutableArray alloc] initWithCapacity:10];
			
			HTMLNode *node_troopHeadline_p = [[table findChildWithAttribute:@"class" matchingName:@"troopHeadline" allowPartial:NO] findChildTag:@"p"];
			NSArray *children = [node_troopHeadline_p children];
			for (HTMLNode *child in children) {
				NSString *content = [child contents];
				if (content == nil)
					content = [child rawContents];
				
				[tblName appendString:content];
			}
			
			NSArray *units = [table findChildrenWithAttribute:@"class" matchingName:@"units" allowPartial:YES];
			int units_i = 0;
			for (HTMLNode *unit in units) {
				NSArray *tds = [unit findChildTags:@"td"];
				for (HTMLNode *td in tds) {
					if ([[td getAttributeNamed:@"class"] rangeOfString:@"uniticon"].location != NSNotFound) {
						// Unit icons.. Get names from ALT
						[troopNames addObject:[[td findChildTag:@"img"] getAttributeNamed:@"alt"]];
					} else if ([[td getAttributeNamed:@"class"] rangeOfString:@"unit"].location != NSNotFound) {
						// Actual units
						// casualties or sent troops?
						if (units_i == 2) {
							// Casualties
							[casualties addObject:[td contents]];
						} else {
							// Troops
							[troops addObject:[td contents]];
						}
					}
				}
				units_i++;
			}
			
			NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:tblName, @"name",
								  troopNames, @"troopNames",
								  troops, @"troops",
								  casualties, @"casualties",
								  nil];
			if ([_id isEqualToString:@"attacker"]) {
				attacker = dict;
			} else {
				if (!defenders) {
					defenders = [[NSMutableArray alloc] init];
				}
				[defenders addObject:dict];
			}
		}
		
	}
	
	parsed = YES;
	
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
