//
//  Movement.h
//  Travian Manager
//
//  Created by Matej Kramny on 23/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movement : NSObject

@property (nonatomic, strong) NSString *name; // Name of the movement
@property (nonatomic, strong) NSDate *finished; // Date when finished

@end
