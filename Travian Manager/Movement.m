//
//  Movement.m
//  Travian Manager
//
//  Created by Matej Kramny on 23/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Movement.h"

@implementation Movement

@synthesize name, finished;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	
	name = [aDecoder decodeObjectForKey:@"name"];
	finished = [aDecoder decodeObjectForKey:@"finished"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:name forKey:@"name"];
	[aCoder encodeObject:finished forKey:@"finished"];
}

@end
