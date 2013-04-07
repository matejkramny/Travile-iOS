/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMApplicationSettings.h"

@implementation TMApplicationSettings

@synthesize ICloud, pushNotifications;

- (id)init {
	self = [super init];

	if (self) {
		ICloud = true;
		pushNotifications = false;
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeBool:ICloud forKey:@"icloud"];
	[aCoder encodeBool:pushNotifications forKey:@"pushNotifications"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	
	ICloud = [aDecoder decodeBoolForKey:@"icloud"];
	pushNotifications = [aDecoder decodeBoolForKey:@"pushNotifications"];
	
	return self;
}

@end
