//
//  Resources.h
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TravianPageParsingProtocol.h"

@class ResourcesProduction;

@interface Resources : NSObject <NSCoding>

@property (assign) float wood;
@property (assign) float clay;
@property (assign) float iron;
@property (assign) float wheat;

- (void)updateResourcesFromProduction:(ResourcesProduction *)production warehouse:(unsigned int)warehouse granary:(unsigned int)granary;

- (bool)hasMoreResourcesThanResource:(Resources *)res;

@end
