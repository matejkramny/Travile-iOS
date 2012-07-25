//
//  Storage.h
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Account;

@interface Storage : NSObject {
	NSString *savePath;
}

@property (nonatomic, strong) NSArray *accounts; // List of accounts
@property (nonatomic, weak) Account *account; // Active account
// game settings?

- (BOOL)saveData;
- (BOOL)loadData;

- (void)setActiveAccount:(Account *)a;
- (void)setActiveAccount:(Account *)a withPassword:(NSString *)password;
- (void)deactivateActiveAccount;

@end
