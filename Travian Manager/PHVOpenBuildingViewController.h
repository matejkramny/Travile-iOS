//
//  PHVOpenBuildingViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 01/08/2012.
//
//

#import <UIKit/UIKit.h>
#import "BuildingMap.h"

@class PHVOpenBuildingViewController;
@class Building;

@protocol PHVOpenBuildingDelegate <NSObject>

- (void)phvOpenBuildingViewController:(PHVOpenBuildingViewController *)controller didCloseBuilding:(Building *)building;
- (void)phvOpenBuildingViewController:(PHVOpenBuildingViewController *)controller didBuildBuilding:(Building *)building;

@end

@interface PHVOpenBuildingViewController : UITableViewController <BuildingMapProtocol, UITableViewDataSource, PHVOpenBuildingDelegate>

@property (nonatomic, weak) id<PHVOpenBuildingDelegate> delegate;
@property (nonatomic, weak) Building *building;
@property (nonatomic, strong) NSArray *buildings;
@property (nonatomic, strong) NSArray *otherBuildings;
@property (assign) bool isBuildingSiteAvailableBuilding;

@end
