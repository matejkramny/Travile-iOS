//
//  HeroQuest.h
//  Travian Manager
//
//  Created by Matej Kramny on 12/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Account;
@class Hero;

// QD = QuestDifficulty
typedef enum {
	QD_NORMAL = 1,
	QD_VERY_HARD = 0
} questDifficulty;

@interface HeroQuest : NSObject <NSCoding, NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
	NSURLConnection *url; // URL to start adventure
	NSMutableData *urlData; // Stores HTML downloaded
}

@property (assign) questDifficulty difficulty; // Defines how difficult quest is
@property (assign) int duration; // How long the quest is (in seconds)
@property (strong, nonatomic) NSDate *expiry; // When the quest expires
@property (assign) int x; // Where the quest is on X axis
@property (assign) int y; // Where the quest is on Y axis
@property (assign) int kid; // ID of the Quest

- (BOOL)canStartQuest:(Hero *)account;
- (BOOL)recommendedToStartQuestWithHero:(Hero *)hero;
- (void)startQuest:(Account *)account;

@end
