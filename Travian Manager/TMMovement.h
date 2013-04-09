/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <Foundation/Foundation.h>

// Combine TMMovementTypeAttack | TMMovementTypeIncoming to make IncomingAttack
typedef enum {
	TMMovementTypeAttack = 1 << 0,
	TMMovementTypeReinforcement = 1 << 1,
	TMMovementTypeAdventure = 1 << 2,
	TMMovementTypeIncoming = 1 << 3,
	TMMovementTypeOutgoing = 1 << 4,
	TMMovementTypeSettle = 1 << 5
	// attack on oasis
} TMMovementType;

@interface TMMovement : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name; // Name of the movement
@property (nonatomic, strong) NSDate *finished; // Date when finished
@property (assign) TMMovementType type;

@end
