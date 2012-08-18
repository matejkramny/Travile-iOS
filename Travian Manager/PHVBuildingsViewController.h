//
//  PHVBuildingsViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 29/07/2012.
//
//

#import <UIKit/UIKit.h>
#import "PHVOpenBuildingViewController.h"
#import "ODRefreshControl/ODRefreshControl.h"

@interface PHVBuildingsViewController : UITableViewController <UITableViewDataSource, PHVOpenBuildingDelegate, UIActionSheetDelegate, ODRefreshControlDelegate>

@property (strong, nonatomic) ODRefreshControl *refreshControl;

@end
