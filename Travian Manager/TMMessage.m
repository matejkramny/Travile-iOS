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

#import "TMMessage.h"
#import "TMStorage.h"
#import "TMAccount.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "TPIdentifier.h"
#import "NSString+HTML.h"

@interface TMMessage () {
	NSString *tempRecipient; // Temporary recipient holder while sendParameter is being retrieved
}

@end

@implementation TMMessage

@synthesize sender, title, content, href, when, read, accessID, sendParameter, sent;

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node {
	// TODO test this
	HTMLNode *divMessage = [node findChildWithAttribute:@"id" matchingName:@"message" allowPartial:NO];
	if (!divMessage) {
		return;
	}
	
	NSString *raw = [[divMessage rawContents] substringFromIndex:[@"<div id=\"message\">" length]];
	raw = [[[[[raw substringToIndex:[raw length]-6] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"] stringByDecodingHTMLEntities];
	
	[self setContent:raw];
}

- (void)parseSendParameter:(HTMLNode *)node {
	HTMLNode *idSend = [node findChildWithAttribute:@"id" matchingName:@"send" allowPartial:NO];
	if (idSend) {
		HTMLNode *input = [idSend findChildTag:@"input"];
		[self setSendParameter:[input getAttributeNamed:@"value"]];
	}
}

- (void)downloadAndParse {
	TMAccount *account = [[TMStorage sharedStorage] account];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[account urlForString:href] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	[request setHTTPShouldHandleCookies:YES];
	
	messageConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)delete {
	TMAccount *account = [[TMStorage sharedStorage] account];
	
	NSString *data = [NSString stringWithFormat:@"delmsg=Delete&s=0&n1=%@", accessID];
	
	NSData *myRequestData = [NSData dataWithBytes: [data UTF8String] length: [data length]];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [account urlForString:[TMAccount messages]] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	// Set POST HTTP Headers if necessary
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody: myRequestData];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	
	// Preserve any cookies received
	[request setHTTPShouldHandleCookies:YES];
	
	@autoreleasepool {
		NSURLConnection *c __unused = [[NSURLConnection alloc] initWithRequest:request delegate:nil startImmediately:YES];
	}
}

- (void)send:(NSString *)recipient {
	TMAccount *account = [[TMStorage sharedStorage] account];
	[self setSent:NO];
	
	if (!sendParameter) {
		// Retrieve it
		NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[account urlForArguments:[TMAccount messages], @"?t=1", nil]];
		[req setHTTPShouldHandleCookies:YES];
		sendParameterConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
		
		tempRecipient = recipient;
		[self addObserver:self forKeyPath:@"sendParameter" options:NSKeyValueObservingOptionNew context:nil];
		
		return;
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[account urlForString:[TMAccount messages]] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	NSString *postData = [[NSString alloc] initWithFormat:@"an=%@&be=%@&message=%@&s1=send&c=%@", recipient, title, content, sendParameter];
	NSData *myRequestData = [NSData dataWithBytes: [postData UTF8String] length: [postData length]];
	
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody: myRequestData];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	
	// Preserve any cookies received
	[request setHTTPShouldHandleCookies:YES];
	
	NSURLConnection *conn __unused = [[NSURLConnection alloc] initWithRequest:request delegate:nil startImmediately:YES];
	
	[self setSent:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"sendParameter"]) {
		if ([change objectForKey:NSKeyValueChangeNewKey] != nil) {
			[self removeObserver:self forKeyPath:@"sendParameter"];
			[self send:tempRecipient];
		}
	}
}

#pragma mark - NSCoder

- (id)initWithCoder:(NSCoder *)aDecoder {
	title = [aDecoder decodeObjectForKey:@"title"];
	content = [aDecoder decodeObjectForKey:@"content"];
	href = [aDecoder decodeObjectForKey:@"href"];
	when = [aDecoder decodeObjectForKey:@"when"];
	NSNumber *n = [aDecoder decodeObjectForKey:@"read"];
	read = [n boolValue];
	accessID = [aDecoder decodeObjectForKey:@"accessID"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:title forKey:@"title"];
	[aCoder encodeObject:content forKey:@"content"];
	[aCoder encodeObject:href forKey:@"href"];
	[aCoder encodeObject:when forKey:@"when"];
	[aCoder encodeObject:[NSNumber numberWithBool:read] forKey:@"read"];
	[aCoder encodeObject:accessID forKey:@"accessID"];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {  }
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection	{	return NO;	}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (connection == messageConnection)
		[messageData appendData:data];
	else if (connection == sendParameterConnection)
		[sendParameterData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	if (connection == messageConnection)
		messageData = [[NSMutableData alloc] initWithLength:0];
	else if (connection == sendParameterConnection)
		sendParameterData = [[NSMutableData alloc] initWithLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// Parse data
	if (connection == messageConnection || connection == sendParameterConnection)
	{
		NSError *error;
		NSData *data;
		
		if (connection == messageConnection)
			data = messageData;
		else if (connection == sendParameterConnection)
			data = sendParameterData;
		
		HTMLParser *parser = [[HTMLParser alloc] initWithData:data error:&error];
		HTMLNode *body = [parser body];
		
		if (!parser) {
			return;
		}
		
		TravianPages travianPage = [TPIdentifier identifyPage:body];
		
		if (connection == messageConnection)
			[self parsePage:travianPage fromHTMLNode:body];
		else if (connection == sendParameterConnection)
			[self parseSendParameter:body];
	}
}

@end
