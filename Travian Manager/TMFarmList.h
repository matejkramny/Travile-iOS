/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

/*
 loads the farm list
 */

#import <Foundation/Foundation.h>
#import "TravianPageParsingProtocol.h"

@interface TMFarmList : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate, TMPageParsingProtocol>

@property (nonatomic, strong) NSArray *farmLists;
@property (assign) bool loaded;
@property (assign) bool loading;

- (void)loadFarmList:(void (^)())completion;

@end
