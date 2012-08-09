//
//  Storage.m
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Storage.h"
#import "Account.h"

@implementation Storage

@synthesize accounts, account;

- (id)init {
	self = [super init];
	
	if (self)
	{
		// Get the paths
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		savePath = [documentsDirectory stringByAppendingPathComponent:@"Accounts.plist"];
		
		[self loadData];
	}
	
	return self;
}

#pragma mark - Data Saving

- (BOOL)saveData {
	
	// Data
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accounts];
	
	NSLog(@"Saving Data");
	
	// Write the data
	if ([data writeToFile:savePath atomically:YES])
		return true;
	else
		NSLog(@"Failed saving data.");
	
	return false;
	
}

- (BOOL)loadData {
	NSData *data = [NSData dataWithContentsOfFile:savePath];
	if (data) {
		accounts = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		account = nil;
		
		NSLog(@"Data loaded");
		
		return true;
	}
	
	NSLog(@"No data loaded");
	
	return false;
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
