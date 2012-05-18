//
//  HeroQuest.h
//  Travian Manager
//
//  Created by Matej Kramny on 12/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	NORMAL,
	VERY_HARD
} questDifficulty;

@interface HeroQuest : NSObject <NSCoding>

@property (assign) questDifficulty difficulty; // Defines how difficult quest is
@property (assign) int duration; // How long the quest is (in seconds)
@property (strong, nonatomic) NSDate *expiry; // When the quest expires
@property (assign) int x; // Where the quest is on X axis
@property (assign) int y; // Where the quest is on Y axis
@property (nonatomic, strong) NSString *urlPart; // URL to access the adventure

@end
