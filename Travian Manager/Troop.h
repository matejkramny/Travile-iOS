//
//  Troop.h
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Resources;

@interface Troop : NSObject <NSCoding>

@property (strong, nonatomic) NSString *name; // As appears in browser
@property (assign) int count; // Number of troops with name ^

// Used with Barracks to research troops
@property (strong, nonatomic) Resources *resources; // Resources required to build one troop
@property (assign) int researchTime; // Time it takes to research one troop
@property (strong, nonatomic) NSString *formIdentifier; // This troop's name=value in post request
@property (assign) int maxTroops; // Maximum number of troops that can be trained (taken from html not calculated)
@property (strong, nonatomic) NSDate *researchDone; // Future date

@end
