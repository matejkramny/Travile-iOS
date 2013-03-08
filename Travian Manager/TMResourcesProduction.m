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

#import "TMResourcesProduction.h"
#import "HTMLParser.h"
#import "HTMLNode.h"

@implementation TMResourcesProduction

- (void)parsePage:(TravianPages)page fromHTML:(NSString *)html
{
	NSError *error;
	HTMLParser *p = [[HTMLParser alloc] initWithString:html error:&error];
	[self parsePage:page fromHTMLNode:[p body]];
}

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node
{
	if (![[node tagName] isEqualToString:@"body"])
		return;
	
	HTMLNode *tableProduction = [node findChildWithAttribute:@"id" matchingName:@"production" allowPartial:NO];
	if (!tableProduction) {
		return;
	}
	
	NSArray *tr = [[tableProduction findChildTag:@"tbody"] findChildTags:@"tr"];
	NSMutableArray *strings = [[NSMutableArray alloc] initWithCapacity:[tr count]];
	for (int i = 0; i < [tr count]; i++) {
		HTMLNode *no = [tr objectAtIndex:i];
		NSString *string = [[[no findChildWithAttribute:@"class" matchingName:@"num" allowPartial:NO] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		[strings addObject:string];
	}
	
	self.wood = [[strings objectAtIndex:0] intValue];
	self.clay = [[strings objectAtIndex:1] intValue];
	self.iron = [[strings objectAtIndex:2] intValue];
	self.wheat = [[strings objectAtIndex:3] intValue];
}

#pragma mark - Coder

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
}


@end
