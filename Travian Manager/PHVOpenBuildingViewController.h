//
//  PHVOpenBuildingViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 01/08/2012.
//
//

#import <UIKit/UIKit.h>

@class PHVOpenBuildingViewController;
@class Building;

@protocol PHVOpenBuildingDelegate <NSObject, UITableViewDataSource>

- (void)phvOpenBuildingViewController:(PHVOpenBuildingViewController *)controller didCloseBuilding:(Building *)building;
- (void)phvOpenBuildingViewController:(PHVOpenBuildingViewController *)controller didBuildBuilding:(Building *)building;

@end

@interface PHVOpenBuildingViewController : UITableViewController


@property (nonatomic, weak) id<PHVOpenBuildingDelegate> delegate;
@property (nonatomic, weak) Building *building;

@property (weak, nonatomic) IBOutlet UILabel *level;
@property (weak, nonatomic) IBOutlet UILabel *wood;
@property (weak, nonatomic) IBOutlet UILabel *clay;
@property (weak, nonatomic) IBOutlet UILabel *iron;
@property (weak, nonatomic) IBOutlet UILabel *wheat;

@end
