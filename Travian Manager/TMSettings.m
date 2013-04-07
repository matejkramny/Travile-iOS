/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMSettings.h"

@implementation TMSettings

@synthesize showsDecimalResources, showsResourceProgress, loadsAllDataAtLogin;

- (id)init {
	self = [super init];
	
	if (self) {
		showsDecimalResources = true;
		showsResourceProgress = true;
		loadsAllDataAtLogin = true;
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	
	showsDecimalResources = [aDecoder decodeBoolForKey:@"decimalResources"];
	showsResourceProgress = [aDecoder decodeBoolForKey:@"resourceProgress"];
	loadsAllDataAtLogin = [aDecoder decodeBoolForKey:@"loadsAllDataAtLogin"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeBool:showsDecimalResources forKey:@"decimalResources"];
	[aCoder encodeBool:showsResourceProgress forKey:@"resourceProgress"];
	[aCoder encodeBool:loadsAllDataAtLogin forKey:@"loadsAllDataAtLogin"];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Decimal resources: %d \nResource progress: %d\nLoads all data at login: %d", showsDecimalResources, showsResourceProgress, loadsAllDataAtLogin];
}

@end
