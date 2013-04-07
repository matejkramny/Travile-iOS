/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface TMSettings : NSObject <NSCoding>

@property (assign) bool showsResourceProgress;
@property (assign) bool showsDecimalResources;
@property (assign) bool loadsAllDataAtLogin; // Boolean sets if TM loads all villages etc when logging in.

@end
