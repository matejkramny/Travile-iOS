// This code is distributed under the terms and conditions of the MIT license.

/* * Copyright (C) 2013 Matej Kramny <matejkramny@gmail.com>
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

#import "TMAPNService.h"
#import "AppDelegate.h"

@interface TMAPNService () {
	NSString *token;
	NSURLConnection *registerConnection;
	NSMutableData *registerData;
	NSURLConnection *scheduleConnection;
	NSMutableData *scheduleData;
}

@end

@implementation TMAPNService (NSURLConnectionDelegate)

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {  }
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection	{	return NO;	}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (connection == registerConnection)
		[registerData appendData:data];
	else if (connection == scheduleConnection)
		[scheduleData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	if (connection == registerConnection)
		registerData = [[NSMutableData alloc] initWithLength:0];
	else if (connection == scheduleConnection)
		scheduleData = [[NSMutableData alloc] initWithLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (connection == registerConnection) {
		NSString *data = [[NSString alloc] initWithData:registerData encoding:NSASCIIStringEncoding];
		NSLog(@"String DAta %@", data);
	} else if (connection == scheduleConnection) {
		NSString *data = [[NSString alloc] initWithData:scheduleData encoding:NSASCIIStringEncoding];
		NSLog(@"Schedule data %@", data);
	}
}

@end

@implementation TMAPNService

- (void)sendToken:(NSString *)theToken {
	token = [[[theToken stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	NSString *postData = [[NSString alloc] initWithFormat:@"token=%@", token];
	NSData *myRequestData = [NSData dataWithBytes: [postData UTF8String] length: [postData length]];
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", APN_URL, @"register"]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody: myRequestData];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	
	registerConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)scheduleNotification:(NSDate *)date withMessageTitle:(NSString *)title {
	NSString *postData = [[NSString alloc] initWithFormat:@"token=%@&deliveryTime=%d&title=%@", token, (int)[date timeIntervalSince1970], title];
	NSData *myRequestData = [NSData dataWithBytes: [postData UTF8String] length: [postData length]];
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", APN_URL, @"schedule"]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody: myRequestData];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	
	scheduleConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

+ (TMAPNService *)sharedInstance {
	static TMAPNService *instance;
	if (!instance) {
		instance = [[TMAPNService alloc] init];
	}
	
	return instance;
}

@end
