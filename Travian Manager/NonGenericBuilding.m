//
//  NonGenericBuilding.m
//  Travian Manager
//
//  Created by Matej Kramny on 04/09/2012.
//
//

#import "NonGenericBuilding.h"

@implementation NonGenericBuilding

- (id)init {
	self = [super init];
	
	if (self) {
		[super setFinishedLoadingKVOIdentifier:@"superFinishedLoading"];
	}
	
	return self;
}

@end
