//
//  Troop.h
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Troop : NSObject <NSCoding>

@property (strong, nonatomic) NSString *name; // As appears in browser
@property (assign) int count; // Number of troops with name ^

@end
