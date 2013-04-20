/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

/*
 TMFarmListEntry is liek a farm list in travian.. It holds TMFarmListEntryFarms
*/

#import <Foundation/Foundation.h>

@interface TMFarmListEntry : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) NSString *name; // Name of the farm list
@property (nonatomic, strong) NSString *postData; // POST data (from hidden inputs)
@property (nonatomic, strong) NSArray *farms; // container with TMFarmListEntryFarms

- (void)executeWithCompletion:(void (^)())completion;

@end
