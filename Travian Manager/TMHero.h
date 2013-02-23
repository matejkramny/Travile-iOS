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
#import "TMResources.h"

@interface TMHero : NSObject <NSCoding, TMPageParsingProtocol>

@property (assign) int strengthPoints; // Attribute - Strength
@property (assign) int offBonusPercentage; // Attribute - Offence bonus (%)
@property (assign) int defBonusPercentage; // Attribute - Defence bonus (%)
@property (assign) int resourceProductionPoints;
@property (strong, nonatomic) TMResources *resourceProductionBoost; // Defines what resources are being boosted by hero
@property (assign) int experience; // Hero experience
@property (assign) int health; // Health of the hero (%)
@property (assign) int speed; // Fields / hour
@property (assign) bool isHidden; // Whether hero is hidden when village is attacked
@property (assign) bool isAlive; // Hero alive/dead true/false
@property (nonatomic, strong) NSArray *quests; // Array of quests available

- (void)parseHero:(HTMLNode *)node;
- (void)parseAdventures:(HTMLNode *)node;

@end
