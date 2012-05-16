//
//  ResourcesProduction.m
//  Travian Manager
//
//  Created by Matej Kramny on 16/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResourcesProduction.h"
#import "HTMLParser.h"
#import "HTMLNode.h"

@implementation ResourcesProduction

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
		NSLog(@"Cannot find table#production");
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
