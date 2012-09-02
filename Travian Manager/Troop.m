//
//  Troop.m
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Troop.h"

@implementation Troop

@synthesize name, count, researchTime, resources, formIdentifier, maxTroops, researchDone;

#pragma mark - Coders

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    
	name = [coder decodeObjectForKey:@"name"];
	NSNumber *countObj = [coder decodeObjectForKey:@"count"];
	count = [countObj intValue];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:[NSNumber numberWithInt:count] forKey:@"count"];
}

@end
