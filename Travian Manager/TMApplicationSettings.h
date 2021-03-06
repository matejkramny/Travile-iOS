/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface TMApplicationSettings : NSObject <NSCoding>

@property (assign) bool ICloud;
@property (assign) bool pushNotifications;
@property (assign) double created; // UNIX timestamp, time of the creation of this object.

@end
