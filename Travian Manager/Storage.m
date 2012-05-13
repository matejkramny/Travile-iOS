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
	}
	
	return self;
}

- (BOOL)saveData {
	
	// Data
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accounts];
	
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
		
		return true;
	}
	
	return false;
	
}

@end
