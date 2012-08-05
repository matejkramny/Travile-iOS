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

@interface PHVBuildingsViewController : UITableViewController <UITableViewDataSource, PHVOpenBuildingDelegate, PHVBuildingListDelegate>

@end
