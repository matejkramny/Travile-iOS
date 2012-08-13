//
//  PHVBuildingsViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 29/07/2012.
//
//

#import <UIKit/UIKit.h>
#import "PHVOpenBuildingViewController.h"
#import "PHVBuildingListViewController.h"
#import "ODRefreshControl/ODRefreshControl.h"

@interface PHVBuildingsViewController : UITableViewController <UITableViewDataSource, PHVOpenBuildingDelegate, PHVBuildingListDelegate, UIActionSheetDelegate, ODRefreshControlDelegate>

@property (strong, nonatomic) ODRefreshControl *refreshControl;

@end
