/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMMovement.h"

@implementation TMMovement

@synthesize name, finished, type;

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
