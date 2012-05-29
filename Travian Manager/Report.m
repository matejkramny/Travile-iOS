//
//  Report.m
//  Travian Manager
//
//  Created by Matej Kramny on 27/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Report.h"
#import "TravianPages.h"
#import "Resources.h"
#import "Village.h"
#import "Account.h"
#import "HTMLNode.h"

@implementation Report

@synthesize name, when, accessID, bounty, attacker, attackerVillage, attackerTroops, defender, defenderVillage, defenderTroops, bountyName;

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node {
	
	// Not a report or not a body tag.
	if (page != TPReport || ![[node tagName] isEqualToString:@"body"]) return;
	
	HTMLNode *report_surround = [node findChildWithAttribute:@"id" matchingName:@"report_surround" allowPartial:NO];
	if (!report_surround) {
		NSLog(@"table#report_surround not found");
		return;
	}
	
	HTMLNode *report_content = [report_surround findChildWithAttribute:@"class" matchingName:@"report_content" allowPartial:NO];
	
	NSArray *tables = [report_content findChildTags:@"table"];
	
	for (HTMLNode *table in tables) {
		
		if ([table getAttributeNamed:@"id"] && [[table getAttributeNamed:@"id"] isEqualToString:@"attacker"]) {
			
			// Attacker
			
		}
		
	}
	
}

#pragma mark - NSCoder

- (id)initWithCoder:(NSCoder *)aDecoder {
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	
}


@end
