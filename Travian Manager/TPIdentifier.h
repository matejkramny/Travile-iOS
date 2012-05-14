//
//  TPIdentifier.h
//  Travian Manager
//
//  Created by Matej Kramny on 14/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TravianPages.h"

@class HTMLNode;

@interface TPIdentifier : NSObject

- (TravianPages)identifyPage:(HTMLNode *)body;

@end
