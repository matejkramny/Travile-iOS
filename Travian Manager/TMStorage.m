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

#import "TMStorage.h"
#import "TMAccount.h"
#import "TMSettings.h"

@implementation TMStorage

@synthesize accounts, account, settings;

// Singleton
+ (TMStorage *)sharedStorage {
	static TMStorage *sharedStorage;
	
	@synchronized(self)
	{
		if (!sharedStorage)
			sharedStorage = [[TMStorage alloc] init];
		
		return sharedStorage;
	}
}

- (id)init {
	static NSString *accountsPath = @"Accounts.plist";
	static NSString *settingsPath = @"Settings.plist";
	
	self = [super init];
	
	if (self)
	{
		// Get the paths
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		savePath = [documentsDirectory stringByAppendingPathComponent:accountsPath];
		settingsSavePath = [documentsDirectory stringByAppendingPathComponent:settingsPath];
		
		[self loadData];
	}
	
	return self;
}

#pragma mark - Data Saving

- (BOOL)saveData {
	
	// Data
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accounts];
	NSData *settingsData = [NSKeyedArchiver archivedDataWithRootObject:settings];
	
	// Write the data
	NSError *error;
	NSError *errorSettings;
	if ([data writeToFile:savePath options:NSDataWritingAtomic error:&error] &&
		[settingsData writeToFile:settingsSavePath options:NSDataWritingAtomic error:&errorSettings]) {
		NSLog(@"Data and Settings saved");
		return true;
	} else {
		if (error)
			NSLog(@"Failed saving data. %@ - %@", [error localizedFailureReason], [error localizedDescription]);
		if (errorSettings)
			NSLog(@"Failed saving settings. %@ - %@", [error localizedFailureReason], [error localizedDescription]);
	}
	
	return false;
	
}

- (BOOL)loadData {
	NSData *data = [NSData dataWithContentsOfFile:savePath];
	NSData *settingsData = [NSData dataWithContentsOfFile:settingsSavePath];
	
	bool result = false;
	
	accounts = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	if (accounts == nil)
		accounts = [[NSArray alloc] init];
	else
		result = true;
	
	account = nil;
	
	settings = [NSKeyedUnarchiver unarchiveObjectWithData:settingsData];
	if (settings == nil) {
		settings = [[TMSettings alloc] init];
		result = false;
	} else {
		result = true;
	}
	
	return result;
}

- (NSString *)getSavePath {
	return savePath;
}

#pragma mark - Active Account

- (void)setActiveAccount:(TMAccount *)a {
	[self setActiveAccount:a withPassword:[a password]];
}

- (void)setActiveAccount:(TMAccount *)a withPassword:(NSString *)password {
	self.account = a;
	
	[self.account activateAccountWithPassword:password];
}

- (void)deactivateActiveAccount {
	if (account)
		[account deactivateAccount];
	
	account = nil;
}

@end
