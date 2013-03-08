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

#import "TMBuildingAction.h"
#import "HTMLNode.h"
#import "TMResources.h"
#import "TMStorage.h"
#import "TMAccount.h"

@interface TMBuildingAction ()

- (void)fetchFromResearchDiv:(HTMLNode *)research;

@end

@implementation TMBuildingAction

@synthesize name, resources, url;

- (id)initWithResearchDiv:(HTMLNode *)research {
	self = [super init];
	if (self) {
		[self fetchFromResearchDiv:research];
	}
	
	return self;
}

- (void)fetchFromResearchDiv:(HTMLNode *)research {
	HTMLNode *inf = [research findChildOfClass:@"information"];
	
	name = [[[[inf findChildOfClass:@"title"] findChildTags:@"a"] lastObject] contents];
	
	resources = [[TMResources alloc] init];
	NSArray *spans = [[inf findChildOfClass:@"costs"] findChildTags:@"span"];
	NSMutableArray *spansParsed = [[NSMutableArray alloc] initWithCapacity:4];
	for (int i = 0; i < 4; i++) {
		HTMLNode *span = [spans objectAtIndex:i];
		
		NSString *img = [[span findChildTag:@"img"] rawContents];
		NSString *raw = [span rawContents];
		
		raw = [raw stringByReplacingOccurrencesOfString:img withString:@""];
		
		NSError *error;
		HTMLParser *p = [[HTMLParser alloc] initWithString:raw error:&error];
		if (error) {
			continue;
		}
		
		[spansParsed addObject:[NSNumber numberWithInt:[[[[[p body] findChildTag:@"span"] contents] stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] intValue]]];
	}
	
	resources.wood = [[spansParsed objectAtIndex:0] intValue];// Wood
	resources.clay = [[spansParsed objectAtIndex:1] intValue];// Clay
	resources.iron = [[spansParsed objectAtIndex:2] intValue];// Iron
	resources.wheat = [[spansParsed objectAtIndex:3] intValue];// Wheat
	
	HTMLNode *button = [[inf findChildOfClass:@"contractLink"] findChildTag:@"button"];
	if (button) {
		url = [[[button getAttributeNamed:@"onclick"] stringByReplacingOccurrencesOfString:@"window.location.href = '" withString:@""] stringByReplacingOccurrencesOfString:@"'; return false;" withString:@""];
	} else
		url = nil;
}

- (void)research {
	if (url == nil)
		return;
	
	@autoreleasepool {
		NSURL *URL = [[[TMStorage sharedStorage] account] urlForString:url];
		NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:URL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
		
		[req setHTTPShouldHandleCookies:YES];
		__unused NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:nil startImmediately:YES];
	}
}

@end
