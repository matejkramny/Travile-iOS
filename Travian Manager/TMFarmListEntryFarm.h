/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

/*
 TMFarmListEntryFarm is a single farm entry in a farm list.
 */

#import <Foundation/Foundation.h>

@interface TMFarmListEntryFarm : NSObject

@property (nonatomic, strong) NSString *postName; // When sending the POST request to travian, this is the name of this farm list entry
@property (nonatomic, strong) NSString *targetName; // Village's name
@property (nonatomic, strong) NSString *targetPopulation; // Village's population
@property (nonatomic, strong) NSString *distance; // Distance to target from this village.
@property (nonatomic, strong) NSArray *troops; // Array of NSDictionaries containing key=value store of troops. Dictionary contains name=troopname count=troopcount(string)
@property (assign) bool selected;

@end
