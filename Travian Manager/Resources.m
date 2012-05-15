//
//  Resources.m
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Resources.h"
#import "HTMLParser.h"
#import "HTMLNode.h"

@implementation Resources

@synthesize wood, clay, iron, wheat;

#pragma mark - Coder

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    
	NSNumber *number = [coder decodeObjectForKey:@"wood"];
	wood = [number intValue];
	number = [coder decodeObjectForKey:@"clay"];
	clay = [number intValue];
	number = [coder decodeObjectForKey:@"iron"];
	iron = [number intValue];
	number = [coder decodeObjectForKey:@"wheat"];
	wheat = [number intValue];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithInt:wood] forKey:@"wood"];
	[coder encodeObject:[NSNumber numberWithInt:clay] forKey:@"clay"];
	[coder encodeObject:[NSNumber numberWithInt:iron] forKey:@"iron"];
	[coder encodeObject:[NSNumber numberWithInt:wheat] forKey:@"wheat"];
}

@end
