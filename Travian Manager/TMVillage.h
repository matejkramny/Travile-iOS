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

#import <Foundation/Foundation.h>
#import "TravianPageParsingProtocol.h"

@class TMResources;
@class TMResourcesProduction;
@class HTMLNode;
@class TMAccount;

@interface TMVillage : NSObject <NSCoding, TMPageParsingProtocol, NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
	__weak TMAccount *parent;
}

@property (nonatomic, strong) TMResources *resources; // Village resources
@property (nonatomic, strong) TMResourcesProduction *resourceProduction; // Village resource production / hour
@property (nonatomic, strong) NSArray *troops; // Village troops
@property (nonatomic, strong) NSArray *movements; // Village movements
@property (nonatomic, strong) NSMutableArray *buildings; // Buildings (including resource fields)
@property (nonatomic, strong) NSArray *constructions; // Construction list
@property (nonatomic, strong) NSString *name; // Village's name
@property (nonatomic, strong) NSString *urlPart; // Village ID required for switching villages in url
@property (assign) int population; // Village population
@property (assign) int loyalty; // Village loyalty
@property (assign) unsigned int warehouse; // Max storage of resources (other than wheat)
@property (assign) unsigned int granary; // Max storage wheat
@property (assign) unsigned int consumption; // Consuming / hour
@property (assign) int x; // Location X
@property (assign) int y; // Location Y

- (void)setAccountParent:(TMAccount *)newParent;
- (TMAccount *)getParent;
- (void)downloadAndParse;
- (void)parseTroops:(HTMLNode *)node;
- (void)parseResources:(HTMLNode *)body;
- (void)parseMovements:(HTMLNode *)body;
- (void)parseBuildingsPage:(TravianPages)page fromNode:(HTMLNode *)node;
- (void)parseConstructions:(HTMLNode *)node;

@end
