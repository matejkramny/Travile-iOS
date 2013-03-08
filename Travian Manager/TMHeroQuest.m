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

#import "TMHeroQuest.h"
#import "TMAccount.h"
#import "TMHero.h"

@implementation TMHeroQuest

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

- (BOOL)canStartQuest:(TMHero *)hero {
	
	if (![hero isAlive]) // check if hero is dead
		return false;
	
	return true;
	
}

- (BOOL)recommendedToStartQuestWithHero:(TMHero *)hero {
	// TODO: Calculate odds for hero's survival
	
	if (![self canStartQuest:hero])
		return false;
	else if ([hero health] < 50 && difficulty == QD_VERY_HARD)
		return false;
	else if ([hero health] < 10)
		return false;
	
	return true;
	
}

- (void)startQuest:(TMAccount *)account {
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
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}

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
}


@end
