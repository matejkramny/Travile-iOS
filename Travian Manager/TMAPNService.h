/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface TMAPNService : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

- (void)sendToken:(NSString *)theToken;
- (void)scheduleNotification:(NSDate *)date withMessageTitle:(NSString *)title;

+ (TMAPNService *)sharedInstance;

@end
