//
//  Construction.h
//  Travian Manager
//
//  Created by Matej Kramny on 16/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Construction : NSObject

@property (strong, nonatomic) NSString *name; // As it appears in browser
@property (assign) int level; // ^ same as above
@property (strong, nonatomic) NSString *finishTime; // ^

@end
