/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMStorage.h"
#import "TMAccount.h"
#import "TMSettings.h"
#import "TMApplicationSettings.h"

@implementation TMStorage

@synthesize accounts, account, appSettings;

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
	static NSString *appSettingsPath = @"ApplicationSettings.plist";
	
	self = [super init];
	
	if (self)
	{
		// Get the paths
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		savePath = [documentsDirectory stringByAppendingPathComponent:accountsPath];
		appSettingsPath = [documentsDirectory stringByAppendingPathComponent:appSettingsPath];
		
		[self loadData];
	}
	
	return self;
}

#pragma mark - Data Saving

- (BOOL)saveData {
	// Data
	NSData *accountData = [NSKeyedArchiver archivedDataWithRootObject:accounts];
	NSData *appSettingsData = [NSKeyedArchiver archivedDataWithRootObject:appSettings];
	
	// Write the data
	if ([accountData writeToFile:savePath options:NSDataWritingAtomic error:nil] && [appSettingsData writeToFile:appSettingsSavePath options:NSDataWritingAtomic error:nil]) {
		return true;
	} else {
		return false;
	}
}

- (BOOL)loadData {
	NSData *accountData = [NSData dataWithContentsOfFile:savePath];
	NSData *appSettingsData = [NSData dataWithContentsOfFile:appSettingsSavePath];
	
	bool result = false;
	
	accounts = [NSKeyedUnarchiver unarchiveObjectWithData:accountData];
	appSettings = [NSKeyedUnarchiver unarchiveObjectWithData:appSettingsData];
	if (accounts == nil)
		accounts = [[NSArray alloc] init];
	else
		result = true;
	if (appSettings == nil)
		appSettings = [[TMApplicationSettings alloc] init];
	else
		result = result == false ? false : true;
	
	account = nil;
	
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
