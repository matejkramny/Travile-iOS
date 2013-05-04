/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

/*
 TMFarmListEntryFarm is a single farm entry in a farm list.
 */

#import <Foundation/Foundation.h>

typedef enum {
	TMFarmListEntryFarmLastReportTypeLostSome = 1 << 1,
	TMFarmListEntryFarmLastReportTypeLostNone = 1 << 2,
	TMFarmListEntryFarmLastReportTypeLostAll = 1 << 3,
	TMFarmListEntryFarmLastReportTypeBountyNone = 1 << 4,
	TMFarmListEntryFarmLastReportTypeBountyPartial = 1 << 5,
	TMFarmListEntryFarmLastReportTypeBountyFull = 1 << 6
} TMFarmListEntryFarmLastReportType;

@interface TMFarmListEntryFarm : NSObject

@property (nonatomic, strong) NSString *postName; // When sending the POST request to travian, this is the name of this farm list entry
@property (nonatomic, strong) NSString *targetName; // Village's name
@property (nonatomic, strong) NSString *targetPopulation; // Village's population
@property (nonatomic, strong) NSString *distance; // Distance to target from this village.
@property (nonatomic, strong) NSArray *troops; // Array of NSDictionaries containing key=value store of troops. Dictionary contains name=troopname count=troopcount(string)
@property (assign) bool selected;
@property (assign) TMFarmListEntryFarmLastReportType lastReport;
@property (nonatomic, strong) NSString *lastReportBounty; // Bounty string from last report
@property (nonatomic, strong) NSString *lastReportTime; // Last attack time
@property (nonatomic, strong) NSString *lastReportURL; // loading url of the report.

@end
