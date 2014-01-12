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

#import "TMBarracks.h"
#import "HTMLNode.h"
#import "TMTroop.h"
#import "TMResources.h"
#import "TMStorage.h"
#import "TMAccount.h"

@interface TMBarracks () {
	NSString *postData; // Starts with hidden values from the form
}

- (void)fetchTroopsFromBuildDiv:(HTMLNode *)build;

@end

@implementation TMBarracks

@synthesize troops, researching;

- (void)fetchDescription {
	[super fetchDescription];
	
	[super addObserver:self forKeyPath:@"buildDiv" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)fetchTroopsFromBuildDiv:(HTMLNode *)build {
	// Find form, load available troops into array
	HTMLNode *form = [build findChildTag:@"form"];
	if (!form) return;
	
	// Hidden inputs
	NSArray *hiddenInputs = [form findChildrenWithAttribute:@"type" matchingName:@"hidden" allowPartial:NO];
	postData = @"";
	for (HTMLNode *hiddenInput in hiddenInputs) {
		postData = [postData stringByAppendingFormat:@"%@=%@&", [hiddenInput getAttributeNamed:@"name"], [hiddenInput getAttributeNamed:@"value"]];
	}
	
	// Confirm button
	postData = [postData stringByAppendingString:@"s1=ok&"];
	
	// Troops
	HTMLNode *div = [form findChildOfClass:@"buildActionOverview trainUnits"];
	NSArray *actions = [div findChildrenWithAttribute:@"class" matchingName:@"action" allowPartial:YES];
	
	// Temporary holder for troops array
	NSMutableArray *mtroops = [[NSMutableArray alloc] initWithCapacity:actions.count];
	
	// Loop through html to retrieve troops
	for (HTMLNode *action in actions) {
		TMTroop *troop = [[TMTroop alloc] init];
		
		// Title
		HTMLNode *title = [action findChildOfClass:@"tit"];
		troop.name = [[[title findChildTags:@"a"] lastObject] contents];
		
		// Max
		troop.maxTroops = [[[action findChildWithAttribute:@"onclick" matchingName:@"$(this).getParent('div.details').getElement('input').value=" allowPartial:YES] contents] intValue];
		
		// Input value
		HTMLNode *input = [action findChildTag:@"input"];
		troop.formIdentifier = [input getAttributeNamed:@"name"];
		
		// Resources
		HTMLNode *costs = [action findChildOfClass:@"showCosts"];
		
		NSArray *spans = [costs findChildTags:@"span"];
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
			
			if ([[span getAttributeNamed:@"class"] isEqualToString:@"clocks"])
				[spansParsed addObject:[[[p body] findChildTag:@"span"] contents]];
			else
				[spansParsed addObject:[NSNumber numberWithInt:[[[[[p body] findChildTag:@"span"] contents] stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] intValue]]];
		}
		
		troop.resources = [[TMResources alloc] init];
		
		troop.resources.wood = [[spansParsed objectAtIndex:0] intValue];// Wood
		troop.resources.clay = [[spansParsed objectAtIndex:1] intValue];// Clay
		troop.resources.iron = [[spansParsed objectAtIndex:2] intValue];// Iron
		troop.resources.wheat = [[spansParsed objectAtIndex:3] intValue];// Wheat
		
		// Research time..
		// Parse time from (hh:mm:ss) to seconds
		NSArray *timeSplit = [[spansParsed lastObject] componentsSeparatedByString:@":"];
		int hour = 0, minute = 0, second = 0;
		hour = [[timeSplit objectAtIndex:0] intValue];
		minute = [[timeSplit objectAtIndex:1] intValue];
		second = [[timeSplit objectAtIndex:2] intValue];
		troop.researchTime = hour * 60 * 60 + minute * 60 + second;
		
		[mtroops addObject:troop];
	}
	
	troops = [mtroops copy];
	
	// Troops being trained.
	HTMLNode *table = [build findChildOfClass:@"under_progress"];
	NSMutableDictionary *mresearching = [[NSMutableDictionary alloc] init];
	
	if (table) {
		NSArray *trs = [[table findChildTag:@"tbody"] findChildTags:@"tr"];
		for (HTMLNode *tr in trs) {
			if ([[tr getAttributeNamed:@"class"] isEqualToString:@"next"]) continue;
			
			HTMLNode *desc = [tr findChildOfClass:@"desc"]; // description contains image and text afterwards. HTMLParser cannot retrieve text after the image so we have to do it manually
			
			NSString *img = [[desc findChildTag:@"img"] rawContents];
			NSString *raw = [desc rawContents];
			
			raw = [raw stringByReplacingOccurrencesOfString:img withString:@""];
			
			NSError *error;
			HTMLParser *p = [[HTMLParser alloc] initWithString:raw error:&error];
			if (error) {
				continue;
			}
			
			// Name of troop (e.g. '1 clubswinger')
			NSString *name = [[[[[p body] findChildTag:@"td"] contents] stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
			
			// Removes double spaces
			while ([name rangeOfString:@"  "].location != NSNotFound) {
				name = [name stringByReplacingOccurrencesOfString:@"  " withString:@" "];
			}
			
			// Finish time
			HTMLNode *fin = [tr findChildOfClass:@"fin"];
			NSArray *spans = [fin findChildTags:@"span"];
			NSString *finishTime = [[spans objectAtIndex:0] contents];
			
			[mresearching setObject:finishTime forKey:name];
		}
	}
	
	self.researching = [mresearching copy];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"buildDiv"]) {
		if ([change objectForKey:NSKeyValueChangeNewKey] != nil) {
			[super removeObserver:self forKeyPath:keyPath];
			
			HTMLNode *build = [super buildDiv];
			[self fetchTroopsFromBuildDiv:build];
			[self setSuperFinishedLoading:YES];
		}
	}
}

- (bool)train {
	@autoreleasepool {
		// Check if there is anything to be trained
		NSURL *url = [[TMStorage sharedStorage].account urlForString:@"build.php"];
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60.0f];
		
		// Preserve any cookies received
		[request setHTTPShouldHandleCookies:YES];
		
		NSMutableString *tempPostData = [[NSMutableString alloc] init];
		bool atLeastOneTroop = false;
		for (TMTroop *t in troops) {
			if (t.count > 0) atLeastOneTroop = true;
			
			[tempPostData appendFormat:@"%@=%d&", t.formIdentifier, t.count];
		}
		
		if (!atLeastOneTroop)
			return NO;
		
		tempPostData = [[NSString stringWithFormat:@"%@%@", postData, tempPostData] mutableCopy];
		
		NSData *myRequestData = [NSData dataWithBytes:[tempPostData UTF8String] length:tempPostData.length];
		
		// Set POST HTTP Headers if necessary
		[request setHTTPMethod: @"POST"];
		[request setHTTPBody: myRequestData];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
		
		for (TMTroop *t in troops) {
			[t setCount:0];
		}
		
		__unused NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:nil startImmediately:YES];
		
		return YES;
	}
}

@end
