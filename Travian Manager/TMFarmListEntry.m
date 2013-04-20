/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMFarmListEntry.h"
#import "TMFarmListEntryFarm.h"
#import "TMAccount.h"
#import "TMStorage.h"

@interface TMFarmListEntry () {
	void (^executeCompletion)();
}

@end

@implementation TMFarmListEntry

@synthesize farms, name, postData;

- (void)executeWithCompletion:(void (^)())completion {
	// Build the POST request data
	NSMutableString *data = [[NSMutableString alloc] initWithString:postData];
	bool atLeastOneSelected = false;
	for (TMFarmListEntryFarm *farm in farms) {
		if (farm.selected) {
			atLeastOneSelected = true;
			[data appendFormat:@"%@=on&", farm.postName];
			
			// Deselect it now
			farm.selected = false;
		}
	}
	
	executeCompletion = completion;
	
	if (atLeastOneSelected) {
		// At least one farm is on
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[TMStorage sharedStorage].account urlForString:@"build.php?gid=16&tt=99"] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
		
		// Set POST HTTP Headers if necessary
		[request setHTTPMethod: @"POST"];
		[request setHTTPBody: [NSData dataWithBytes: [data UTF8String] length: [data length]]];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
		
		// Preserve any cookies received
		[request setHTTPShouldHandleCookies:YES];
		
		__unused NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	} else {
		if (completion) {
			completion();
		}
	}
}

#pragma mark - NSURLConnectionDataDelegate, NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {  }
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection	{	return NO;	}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if (executeCompletion) executeCompletion();
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (executeCompletion) executeCompletion();
}

@end
