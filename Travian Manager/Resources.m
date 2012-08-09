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
#import "ResourcesProduction.h"

@interface Resources () {
	int last_update;
	NSTimer *timer;
}

@end

@implementation Resources

@synthesize wood, clay, iron, wheat;

#pragma mark - Coder

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    
	NSNumber *number = [coder decodeObjectForKey:@"wood"];
	wood = [number floatValue];
	number = [coder decodeObjectForKey:@"clay"];
	clay = [number floatValue];
	number = [coder decodeObjectForKey:@"iron"];
	iron = [number floatValue];
	number = [coder decodeObjectForKey:@"wheat"];
	wheat = [number floatValue];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithFloat:wood] forKey:@"wood"];
	[coder encodeObject:[NSNumber numberWithFloat:clay] forKey:@"clay"];
	[coder encodeObject:[NSNumber numberWithFloat:iron] forKey:@"iron"];
	[coder encodeObject:[NSNumber numberWithFloat:wheat] forKey:@"wheat"];
}

- (void)updateResourcesFromProduction:(ResourcesProduction *)production warehouse:(unsigned int)warehouse granary:(unsigned int)granary {
	if (!last_update) {
		last_update = [[NSDate date] timeIntervalSince1970];
		return;
	}
	
	int elapsed = [[NSDate date] timeIntervalSince1970] - last_update;
	
	if (elapsed > 0) {
		// Calculate generated resources per second
		float (^calculateResPerSecond)(float, float, int) = ^(float rp, float r, int el) {
			
			// Division by 0 prevention
			if (rp == 0)
				return r;
			float oneSec = (rp / 60.0f) / 60.0f;
			
			return oneSec * el + r;
		};
		
		if (wood < warehouse)
			wood = calculateResPerSecond(production.wood, wood, elapsed);
		if (clay < warehouse)
			clay = calculateResPerSecond(production.clay, clay, elapsed);
		if (iron < warehouse)
			iron = calculateResPerSecond(production.iron, iron, elapsed);
		if (wheat < granary)
			wheat = calculateResPerSecond(production.wheat, wheat, elapsed);
		
		last_update = [[NSDate date] timeIntervalSince1970];
	}
}

@end
