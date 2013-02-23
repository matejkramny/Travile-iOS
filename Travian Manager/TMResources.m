// This code is distributed under the terms and conditions of the MIT license.

/* * Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial
 * portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
 * OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "TMResources.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "TMResourcesProduction.h"

@interface TMResources () {
	int last_update;
	NSTimer *timer;
}

@end

@implementation TMResources

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

- (void)updateResourcesFromProduction:(TMResourcesProduction *)production warehouse:(unsigned int)warehouse granary:(unsigned int)granary {
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

- (bool)hasMoreResourcesThanResource:(TMResources *)res {
	bool m = false;
	
	if (wood > res.wood && clay > res.clay && iron > res.iron && wheat > res.wheat)
		m = true;
	
	return m;
}

- (int)getPercentageForResource:(float)resource warehouse:(int)warehouse {
	// Calculate time left for this resource
	if (resource >= warehouse)
		return 100;
	
	return (resource / (float)warehouse) * 100;
}

@end
