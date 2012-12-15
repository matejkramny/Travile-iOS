//
//  Settings.m
//  Travian Manager
//
//  Created by Matej Kramny on 10/11/2012.
//
//

#import "Settings.h"

@implementation Settings

@synthesize showsDecimalResources, showsResourceProgress;

- (id)init {
	self = [super init];
	
	if (self) {
		showsDecimalResources = true;
		showsResourceProgress = true;
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	
	showsDecimalResources = [aDecoder decodeBoolForKey:@"decimalResources"];
	showsResourceProgress = [aDecoder decodeBoolForKey:@"resourceProgress"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeBool:showsDecimalResources forKey:@"decimalResources"];
	[aCoder encodeBool:showsResourceProgress forKey:@"resourceProgress"];
}

@end
