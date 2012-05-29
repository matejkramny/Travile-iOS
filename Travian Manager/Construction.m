//
//  Construction.m
//  Travian Manager
//
//  Created by Matej Kramny on 16/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Construction.h"

@implementation Construction

@synthesize name, level, finishTime;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	
	name = [aDecoder decodeObjectForKey:@"name"];
	NSNumber *n = [aDecoder decodeObjectForKey:@"level"];
	level = [n intValue];
	finishTime = [aDecoder decodeObjectForKey:@"finishTime"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:name forKey:@"name"];
	[aCoder encodeObject:[NSNumber numberWithInt:level] forKey:@"level"];
	[aCoder encodeObject:finishTime forKey:@"finishTime"];
}

@end
