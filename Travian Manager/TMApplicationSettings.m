/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMApplicationSettings.h"

@implementation TMApplicationSettings

@synthesize ICloud, pushNotifications, created;

- (id)init {
	self = [super init];

	if (self) {
		ICloud = true;
		pushNotifications = false;
		created = [[NSDate date] timeIntervalSince1970];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeBool:ICloud forKey:@"icloud"];
	[aCoder encodeBool:pushNotifications forKey:@"pushNotifications"];
	[aCoder encodeDouble:created forKey:@"createdTimestamp"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	
	ICloud = [aDecoder decodeBoolForKey:@"icloud"];
	pushNotifications = [aDecoder decodeBoolForKey:@"pushNotifications"];
	created = [aDecoder decodeDoubleForKey:@"createdTimestamp"];
	
	if (!created || created == 0.f) {
		created = [[NSDate date] timeIntervalSince1970];
	}
	
	return self;
}

@end
