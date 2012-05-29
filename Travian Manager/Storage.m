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
	
	Account *a = [[Account alloc] init];
	a.username = @"matejkramny";
	a.password = @"temp0rary";
	a.world = @"ts6";
	a.server = @"co.uk";
	
	accounts = [NSArray arrayWithObject:a];
	
	NSLog(@"No data loaded");
	
	return false;
	
}

#pragma mark - Active Account

- (void)setActiveAccount:(Account *)a {
	self.account = a;
	
	[self.account activateAccount];
}

- (void)deactivateActiveAccount {
	if (account)
		[account deactivateAccount];
	
	account = nil;
}

@end
