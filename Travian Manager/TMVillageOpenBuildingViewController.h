/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "TMBuildingMap.h"

@class TMVillageOpenBuildingViewController;
@class TMBuilding;

@protocol TMVillageOpenBuildingDelegate <NSObject>

- (void)phvOpenBuildingViewController:(TMVillageOpenBuildingViewController *)controller didCloseBuilding:(TMBuilding *)building;
- (void)phvOpenBuildingViewController:(TMVillageOpenBuildingViewController *)controller didBuildBuilding:(TMBuilding *)building;

@end

@interface TMVillageOpenBuildingViewController : UITableViewController <TMBuildingMapProtocol, UITableViewDataSource, TMVillageOpenBuildingDelegate>

@property (nonatomic, weak) id<TMVillageOpenBuildingDelegate> delegate;
@property (nonatomic, weak) TMBuilding *building;
@property (nonatomic, strong) NSArray *buildings;
@property (nonatomic, strong) NSArray *otherBuildings;
@property (assign) bool isBuildingSiteAvailableBuilding;

@end
