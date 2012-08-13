//
//  PHVOverviewViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 29/07/2012.
//
//

#import <UIKit/UIKit.h>
#import "ODRefreshControl/ODRefreshControl.h"

@interface PHVOverviewViewController : UITableViewController <UITableViewDataSource, ODRefreshControlDelegate>

@property (nonatomic, strong) ODRefreshControl *refreshControl;

- (IBAction)secondTimerFired:(id)sender;

@end
