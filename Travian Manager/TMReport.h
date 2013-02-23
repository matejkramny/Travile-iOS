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
@class TMVillage;
@class TMAccount;

@interface TMReport : NSObject <TMPageParsingProtocol, NSCoding, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSString *name; // Name of the report, as in browser
@property (nonatomic, strong) NSString *when; // When the report happened, as appears in browser
@property (nonatomic, strong) NSString *accessID; // ID|ID of the report
@property (nonatomic, strong) TMResources *bounty; // Bounty is usually resources, but can be items like 'cage'
@property (nonatomic, strong) NSString *bountyName;
@property (nonatomic, strong) NSString *deleteID; // Integer ID of the report used to delete the Report

@property (nonatomic, strong) TMAccount *attacker; // Attacker's account
@property (nonatomic, strong) TMVillage *attackerVillage; // Attacker's village
@property (nonatomic, strong) NSArray *attackerTroops; // Troops used in attack
@property (nonatomic, weak) TMAccount *defender; // Defender's account
@property (nonatomic, weak) TMVillage *defenderVillage; // Defender's village
@property (nonatomic, strong) NSArray *defenderTroops; // Troops used to defend

- (void)downloadAndParse;
- (void)delete;

@end
