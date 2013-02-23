// This code is distributed under the terms and conditions of the MIT license.

/* * Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial
 * portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
 * OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>

@class TMAccount;
@class AppDelegate;
@class TMSettings;

@interface TMStorage : NSObject {
	NSString *savePath;
	NSString *settingsSavePath;
}

@property (nonatomic, weak) AppDelegate *delegate;
@property (nonatomic, strong) NSArray *accounts; // List of accounts
@property (nonatomic, weak) TMAccount *account; // Active account
@property (nonatomic, strong) TMSettings *settings;
// game settings?

- (BOOL)saveData;
- (BOOL)loadData;

- (void)setActiveAccount:(TMAccount *)a;
- (void)setActiveAccount:(TMAccount *)a withPassword:(NSString *)password;
- (void)deactivateActiveAccount;

- (NSString *)getSavePath;

+ (TMStorage *)sharedStorage;

@end
