//
//  Village.m
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Village.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "Resources.h"

@implementation Village

@synthesize resources, resourceProduction, troops, movements;
@synthesize id, loyalty, population, warehouse, granary, consumption, x, y;
@synthesize villageConnection, villageData;

#pragma mark - Page parsing

- (void)parsePage:(TravianPages)page fromHTML:(NSString *)html
{
	NSError *error;
	HTMLParser *p = [[HTMLParser alloc] initWithString:html error:&error];
	[self parsePage:page fromHTMLNode:[p body]];
}

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node
{
	switch (page) {
		case TPResources:
			[resources parsePage:page fromHTMLNode:node];
			[resourceProduction parsePage:page fromHTMLNode:node];
			break;
			
		default:
			break;
	}
}

#pragma mark - Coders

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    
	resources = [coder decodeObjectForKey:@"resources"];
	resourceProduction = [coder decodeObjectForKey:@"resourceProduction"];
	troops = [coder decodeObjectForKey:@"troops"];
	movements = [coder decodeObjectForKey:@"movements"];
	NSNumber *numberObject = [coder decodeObjectForKey:@"villageID"];
	self.id = [numberObject intValue];
	numberObject = [coder decodeObjectForKey:@"population"];
	population = [numberObject intValue];
	numberObject = [coder decodeObjectForKey:@"loyalty"];
	loyalty = [numberObject intValue];
	numberObject = [coder decodeObjectForKey:@"warehouse"];
	warehouse = [numberObject intValue];
	numberObject = [coder decodeObjectForKey:@"granary"];
	granary = [numberObject intValue];
	numberObject = [coder decodeObjectForKey:@"consumption"];
	consumption = [numberObject intValue];
	numberObject = [coder decodeObjectForKey:@"villageX"];
	x = [numberObject intValue];
	numberObject = [coder decodeObjectForKey:@"villageY"];
	y = [numberObject intValue];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:resources forKey:@"resources"];
	[coder encodeObject:resourceProduction forKey:@"resourceProduction"];
	[coder encodeObject:troops forKey:@"troops"];
	[coder encodeObject:movements forKey:@"movements"];
	[coder encodeObject:[NSNumber numberWithInt:self.id] forKey:@"villageID"];
	[coder encodeObject:[NSNumber numberWithInt:population] forKey:@"population"];
	[coder encodeObject:[NSNumber numberWithInt:loyalty] forKey:@"loyalty"];
	[coder encodeObject:[NSNumber numberWithInt:warehouse] forKey:@"warehouse"];
	[coder encodeObject:[NSNumber numberWithInt:granary] forKey:@"granary"];
	[coder encodeObject:[NSNumber numberWithInt:x] forKey:@"villageX"];
	[coder encodeObject:[NSNumber numberWithInt:y] forKey:@"villageY"];
}

@end
