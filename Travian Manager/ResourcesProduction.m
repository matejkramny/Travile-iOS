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
