//
//  Resources.h
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TravianPageParsingProtocol.h"

@interface Resources : NSObject <NSCoding, TravianPageParsingProtocol>

@property (assign) unsigned int wood;
@property (assign) unsigned int clay;
@property (assign) unsigned int iron;
@property (assign) unsigned int wheat;

@end
