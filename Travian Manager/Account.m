//
//  Account.m
//  Travian Manager
//
//  Created by Matej Kramny on 11/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Account.h"
#import "HTMLParser.h"
#import "HTMLNode.h"

@implementation Account

@synthesize name, username, password, villages, reports, messages, contacts, hero, hasBeginnersProtection;

#pragma mark - TravianPageParsingProtocol

- (void)parsePage:(TravianPages)page fromHTML:(NSString *)html
{
	NSError *error;
	HTMLParser *p = [[HTMLParser alloc] initWithString:html error:&error];
	[self parsePage:page fromHTMLNode:[p body]];
}

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node
{
	
}

#pragma mark - Coders

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	
	name = [coder decodeObjectForKey:@"name"];
	username = [coder decodeObjectForKey:@"username"];
	password = [coder decodeObjectForKey:@"password"];
	villages = [coder decodeObjectForKey:@"villages"];
	reports = [coder decodeObjectForKey:@"reports"];
	messages = [coder decodeObjectForKey:@"messages"];
	contacts = [coder decodeObjectForKey:@"contacts"];
	hero = [coder decodeObjectForKey:@"hero"];
	NSNumber *hasBeginnersProtectionObject = [coder decodeObjectForKey:@"hasBeginnersProtection"];
	hasBeginnersProtection = [hasBeginnersProtectionObject boolValue];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:username forKey:@"username"];
	[coder encodeObject:password forKey:@"password"];
	[coder encodeObject:villages forKey:@"villages"];
	[coder encodeObject:reports forKey:@"reports"];
	[coder encodeObject:messages forKey:@"messages"];
	[coder encodeObject:contacts forKey:@"contacts"];
	[coder encodeObject:hero forKey:@"hero"];
	[coder encodeObject:[NSNumber numberWithBool:hasBeginnersProtection] forKey:@"hasBeginnersProtection"];
}

@end
