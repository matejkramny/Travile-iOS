//
//  HeroQuest.m
//  Travian Manager
//
//  Created by Matej Kramny on 12/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HeroQuest.h"
#import "Account.h"
#import "Hero.h"

@implementation HeroQuest

@synthesize difficulty, duration, expiry, x, y, kid;

#pragma mark - Coders

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    
	NSNumber *n = [coder decodeObjectForKey:@"difficulty"];
	difficulty = [n intValue];
	n = [coder decodeObjectForKey:@"duration"];
	duration = [n intValue];
	expiry = [coder decodeObjectForKey:@"expiry"];
	n = [coder decodeObjectForKey:@"x"];
	x = [n intValue];
	n = [coder decodeObjectForKey:@"y"];
	y = [n intValue];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[NSNumber numberWithInt:difficulty] forKey:@"difficulty"];
	[coder encodeObject:[NSNumber numberWithInt:duration] forKey:@"duration"];
	[coder encodeObject:expiry forKey:@"expiry"];
	[coder encodeObject:[NSNumber numberWithInt:x] forKey:@"x"];
	[coder encodeObject:[NSNumber numberWithInt:y] forKey:@"y"];
}

#pragma mark - Start Quest

- (BOOL)canStartQuest:(Hero *)hero {
	
	if (![hero isAlive]) // check if hero is dead
		return false;
	
	return true;
	
}

- (BOOL)recommendedToStartQuestWithHero:(Hero *)hero {
	// TODO: Calculate odds for hero's survival
	
	if (![self canStartQuest:hero])
		return false;
	else if ([hero health] < 50 && difficulty == QD_VERY_HARD)
		return false;
	else if ([hero health] < 10)
		return false;
	
	return true;
	
}

- (void)startQuest:(Account *)account {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[account urlForString:@"start_adventure.php"] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	NSString *dataString = [NSString stringWithFormat:@"send=1&from=list&kid=%d&a=1&start=start%%20adventure", kid];
	NSData *data = [[NSData alloc] initWithBytes:[dataString UTF8String] length:[dataString length]];
	
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	[request setHTTPBody:data];
	[request setHTTPShouldHandleCookies:YES];
	
	url = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {  }
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection	{	return NO;	}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error { NSLog(@"Connection failed with error: %@. Fix error by: %@", [error localizedFailureReason], [error localizedRecoverySuggestion]); }

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (connection == url)
		[urlData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	if (connection == url)
		urlData = [[NSMutableData alloc] initWithLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	//NSLog(@"Finished loading adventure");
}


@end
