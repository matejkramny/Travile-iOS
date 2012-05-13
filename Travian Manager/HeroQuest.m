//
//  HeroQuest.m
//  Travian Manager
//
//  Created by Matej Kramny on 12/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HeroQuest.h"

@implementation HeroQuest

@synthesize difficulty, x, y;

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    
	NSNumber *n = [coder decodeObjectForKey:@"difficulty"];
	difficulty = [n intValue];
	n = [coder decodeObjectForKey:@"x"];
	x = [n intValue];
	n = [coder decodeObjectForKey:@"y"];
	y = [n intValue];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithInt:difficulty] forKey:@"difficulty"];
	[coder encodeObject:[NSNumber numberWithInt:x] forKey:@"x"];
	[coder encodeObject:[NSNumber numberWithInt:y] forKey:@"y"];
}

@end
