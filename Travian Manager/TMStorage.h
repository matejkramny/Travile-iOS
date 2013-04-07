/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <Foundation/Foundation.h>

@class TMAccount;
@class AppDelegate;
@class TMSettings;
@class TMApplicationSettings;

@interface TMStorage : NSObject {
	NSString *savePath;
	NSString *appSettingsSavePath;
}

@property (nonatomic, weak) AppDelegate *delegate;
@property (nonatomic, strong) NSArray *accounts; // List of accounts
@property (nonatomic, weak) TMAccount *account; // Active account
@property (nonatomic, strong) TMApplicationSettings *appSettings; // Application settings
@property (assign) bool signedIntoICloud;

- (BOOL)saveData;
- (BOOL)loadData;

- (void)setActiveAccount:(TMAccount *)a;
- (void)setActiveAccount:(TMAccount *)a withPassword:(NSString *)password;
- (void)deactivateActiveAccount;

- (NSString *)getSavePath;

+ (TMStorage *)sharedStorage;

@end
