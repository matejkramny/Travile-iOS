//
//  Storage.h
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Account;
@class AppDelegate;
@class Settings;

@interface Storage : NSObject {
	NSString *savePath;
	NSString *settingsSavePath;
}

@property (nonatomic, weak) AppDelegate *delegate;
@property (nonatomic, strong) NSArray *accounts; // List of accounts
@property (nonatomic, weak) Account *account; // Active account
@property (nonatomic, strong) Settings *settings;
// game settings?

- (BOOL)saveData;
- (BOOL)loadData;

- (void)setActiveAccount:(Account *)a;
- (void)setActiveAccount:(Account *)a withPassword:(NSString *)password;
- (void)deactivateActiveAccount;

- (NSString *)getSavePath;

+ (Storage *)sharedStorage;

@end
