//
//  Storage.m
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Storage.h"
#import "Account.h"
#import "Settings.h"

@implementation Storage

@synthesize accounts, account, settings;

// Singleton
+ (Storage *)sharedStorage {
	static Storage *sharedStorage;
	
	@synchronized(self)
	{
		if (!sharedStorage)
			sharedStorage = [[Storage alloc] init];
		
		return sharedStorage;
	}
}

- (id)init {
	self = [super init];
	
	if (self)
	{
		// Get the paths
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		savePath = [documentsDirectory stringByAppendingPathComponent:@"Accounts.plist"];
		settingsSavePath = [documentsDirectory stringByAppendingPathComponent:@"Settings.plist"];
		
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
		settings = [[Settings alloc] init];
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

- (void)setActiveAccount:(Account *)a {
	[self setActiveAccount:a withPassword:[a password]];
}

- (void)setActiveAccount:(Account *)a withPassword:(NSString *)password {
	self.account = a;
	
	[self.account activateAccountWithPassword:password];
}

- (void)deactivateActiveAccount {
	if (account)
		[account deactivateAccount];
	
	account = nil;
}

@end
