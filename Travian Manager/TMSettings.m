/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMSettings.h"

@implementation TMSettings

@synthesize showsDecimalResources, showsResourceProgress, fastLogin;

- (id)init {
	self = [super init];
	
	if (self) {
		showsDecimalResources = true;
		showsResourceProgress = true;
		fastLogin = false;
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	
	showsDecimalResources = [aDecoder decodeBoolForKey:@"decimalResources"];
	showsResourceProgress = [aDecoder decodeBoolForKey:@"resourceProgress"];
	fastLogin = [aDecoder decodeBoolForKey:@"loadsAllDataAtLogin"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeBool:showsDecimalResources forKey:@"decimalResources"];
	[aCoder encodeBool:showsResourceProgress forKey:@"resourceProgress"];
	[aCoder encodeBool:fastLogin forKey:@"loadsAllDataAtLogin"];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Decimal resources: %d \nResource progress: %d\nLoads all data at login: %d", showsDecimalResources, showsResourceProgress, fastLogin];
}

@end
