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
#import "Flurry.h"

@interface TMReport () {
	NSURLConnection *deleteConnection;
	NSURLConnection *reportConnection;
	NSMutableData *reportData;
}

@end

@implementation TMReport

@synthesize name, when, accessID, bounty, deleteID, attacker, defenders, bountyResources, parsed, information, trade;

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node {
	@try {
		// Not a report or not a body tag.
		if (page != TPReports || ![[node tagName] isEqualToString:@"body"]) return;
		
		HTMLNode *report_surround = [node findChildWithAttribute:@"id" matchingName:@"report_surround" allowPartial:NO];
		if (!report_surround) {
			[self setParsed:NO];
			return;
		}
		
		HTMLNode *report_content = [report_surround findChildWithAttribute:@"class" matchingName:@"report_content" allowPartial:NO];
		if (!report_content) {
			report_content = [report_surround findChildWithAttribute:@"id" matchingName:@"message" allowPartial:NO];
			if (!report_content) {
				[self setParsed:NO];
				return;
			}
		}
		
		HTMLNode *subject = [node findChildWithAttribute:@"id" matchingName:@"subject" allowPartial:NO];
		if (subject) {
			name = [[subject findChildWithAttribute:@"class" matchingName:@"text" allowPartial:YES] contents];
		}
		
		HTMLNode *time = [node findChildWithAttribute:@"id" matchingName:@"time" allowPartial:NO];
		if (time) {
			when = [[time findChildWithAttribute:@"class" matchingName:@"text" allowPartial:YES] contents];
		}
		
		NSArray *tables = [report_content findChildTags:@"table"];
		
		for (HTMLNode *table in tables) {
			
			NSString *_id = [table getAttributeNamed:@"id"];
			if ([[table getAttributeNamed:@"class"] isEqualToString:@"tbg support"]) continue; // unusable
			
			if ([_id isEqualToString:@"trade"]) {
				HTMLNode *thead = [table findChildTag:@"thead"];
				HTMLNode *troopHeadline = [thead findChildWithAttribute:@"class" matchingName:@"troopHeadline" allowPartial:NO];
				NSArray *headlineChildren = [troopHeadline children];
				NSMutableString *header = [[NSMutableString alloc] init];
				for (HTMLNode *headlineChild in headlineChildren) {
					if ([[headlineChild tagName] isEqualToString:@"a"]) {
						[header appendString:[headlineChild contents]];
					} else {
						[header appendString:[[[[headlineChild rawContents] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""]];
					}
				}
				
				NSArray *resourcesArray = [table findChildrenWithAttribute:@"class" matchingName:@"rArea" allowPartial:NO];
				TMResources *tradeResources = [[TMResources alloc] init];
				
				int _i = 0;
				for (HTMLNode *resource in resourcesArray) {
					NSArray *spanChildren = [resource children];
					HTMLNode *lastSpanContents = [spanChildren objectAtIndex:spanChildren.count-1];
					
					if (lastSpanContents) {
						NSString *resourceString = [[[[lastSpanContents rawContents] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
						
						if (_i == 0) {
							// Wood
							tradeResources.wood = [resourceString intValue];
						} else if (_i == 1) {
							// Clay
							tradeResources.clay = [resourceString intValue];
						} else if (_i == 2) {
							// Iron
							tradeResources.iron = [resourceString intValue];
						} else {
							// wheat
							tradeResources.wheat = [resourceString intValue];
						}
					}
					
					_i++;
				}
				
				NSArray *clockChildren = [[[table findChildWithAttribute:@"class" matchingName:@"clock" allowPartial:NO] parent] children];
				NSString *duration = [[[[[clockChildren objectAtIndex:clockChildren.count-1] rawContents] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
				
				trade = @{@"duration": duration,
				 @"resources": tradeResources,
				 @"header": header};
				
				break;
			}
			
			if ([_id isEqualToString:@"attacker"] || _id == nil) {
				
				if ([table findChildTags:@"tbody"].count == 0) continue;
				
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
					
					content = [[[content stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
					
					[tblName appendString:content];
				}
				
				NSArray *units = [table findChildrenWithAttribute:@"class" matchingName:@"units" allowPartial:YES];
				int units_i = 0;
				for (HTMLNode *unit in units) {
					NSArray *tds = [unit findChildTags:@"td"];
					for (HTMLNode *td in tds) {
						if (units_i == 0) {
							// Unit icons.. Get names from ALT
							[troopNames addObject:[[td findChildTag:@"img"] getAttributeNamed:@"alt"]];
						} else if ([[td getAttributeNamed:@"class"] rangeOfString:@"unit"].location != NSNotFound) {
							// Actual units
							// casualties or sent troops?
							NSString *content = [td contents] == nil ? @"0" : [td contents];
							if (units_i == 2) {
								// Casualties
								[casualties addObject:content];
							} else if (units_i == 1) {
								// Troops
								[troops addObject:content];
							}
						}
					}
					units_i++;
				}
				
				HTMLNode *infosTable = [table findChildWithAttribute:@"class" matchingName:@"infos" allowPartial:NO];
				if (infosTable) {
					HTMLNode *dropItemsTd = [infosTable findChildWithAttribute:@"class" matchingName:@"dropItems" allowPartial:NO];
					NSArray *childrenInfos = [dropItemsTd children];
					NSMutableString *infos = [[NSMutableString alloc] init];
					int childCount = 0;
					for (HTMLNode *child in childrenInfos) {
						if ([[child tagName] isEqualToString:@"img"]) {
							[infos appendFormat:@"%@ ", [child getAttributeNamed:@"alt"]];
						} else {
							[infos appendString:[[[[child rawContents] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""]];
						}
						
						if (childCount < childrenInfos.count-1 && childCount > 0 && childCount % 2 == 0) {
							[infos appendString:@"\n"];
						}
						
						childCount++;
					}
					
					information = infos;
				}
				
				HTMLNode *bountyTable = [table findChildWithAttribute:@"class" matchingName:@"goods" allowPartial:NO];
				if (bountyTable) {
					HTMLNode *td = [bountyTable findChildWithAttribute:@"colspan" matchingName:@"11" allowPartial:NO];
					if (td) {
						HTMLNode *res = [td findChildWithAttribute:@"class" matchingName:@"res" allowPartial:NO];
						if (res) {
							// Parse the resources as bounty
							bountyResources = [[TMResources alloc] init];
							NSArray *spans = [res findChildTags:@"span"];
							if (!spans || spans.count == 0) {
								spans = [res findChildrenWithAttribute:@"class" matchingName:@"rArea" allowPartial:NO];
							}
							int span_i = 0;
							for (HTMLNode *span in spans) {
								NSArray *spanChildren = [span children];
								HTMLNode *lastSpanContents = [spanChildren objectAtIndex:spanChildren.count-1];
								
								if (lastSpanContents) {
									NSString *resource = [[[[lastSpanContents rawContents] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
									
									if (span_i == 0) {
										// Wood
										bountyResources.wood = [resource intValue];
									} else if (span_i == 1) {
										// Clay
										bountyResources.clay = [resource intValue];
									} else if (span_i == 2) {
										// Iron
										bountyResources.iron = [resource intValue];
									} else {
										// wheat
										bountyResources.wheat = [resource intValue];
									}
								}
								
								span_i++;
							}
						}
						
						HTMLNode *carry = [td findChildWithAttribute:@"class" matchingName:@"carry" allowPartial:NO];
						if (carry) {
							HTMLNode *img = [carry findChildTag:@"img"];
							if (img) {
								// Parse the counterpart of res
								NSString *alt = [img getAttributeNamed:@"alt"];
								NSArray *childrenTd = [carry children];
								HTMLNode *lastTd = [childrenTd objectAtIndex:childrenTd.count-1];
								NSString *lastTdContents = [[[[lastTd rawContents] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
								
								if ([lastTdContents isEqualToString:alt]) {
									bounty = alt;
								} else {
									bounty = [@"Bounty " stringByAppendingString:lastTdContents];
								}
							}
						}
						
						if (!res && !carry) {
							// Just an item -- adventure?
							HTMLNode *img = [td findChildTag:@"img"];
							if (img) {
								// parse it
								NSString *alt = [img getAttributeNamed:@"alt"];
								NSArray *childrenTd = [td children];
								HTMLNode *lastTd = [childrenTd objectAtIndex:childrenTd.count-1];
								NSString *lastTdContents = [[[[lastTd rawContents] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
								
								if ([lastTdContents isEqualToString:alt]) {
									bounty = alt;
								} else {
									bounty = [alt stringByAppendingFormat:@" %@", lastTdContents];
								}
							}
						}
					}
				}
				
				if (casualties.count == 0) {
					for (int i = 0; i < troops.count; i++) {
						[casualties addObject:@"0"];
					}
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
	} @catch (NSException *exception) {
		// Prevents app from crashing (we don't want that!)
		NSLog(@"Exception parsing report! %@", [exception description]);
		[Flurry logError:@"Report Parsing" message:@"Exception parsing report." exception:exception]; // Log it
		[self setParsed:NO];
	}
	
	[self setParsed:YES];
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
		NSString *dataString = [[[NSString alloc] initWithData:reportData encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"</table><table cellpadding=\"0\" cellspacing=\"0\"><table" withString:@"</table><table"];
		HTMLParser *parser = [[HTMLParser alloc] initWithString:dataString error:&error];
		HTMLNode *body = [parser body];
		
		if (!parser) {
			return;
		}
		
		TravianPages travianPage = [TPIdentifier identifyPage:body];
		
		[self parsePage:travianPage fromHTMLNode:body];
	}
	
}

@end
