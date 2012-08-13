//
//  PHVTroopsViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 29/07/2012.
//
//

#import <UIKit/UIKit.h>
#import "ODRefreshControl/ODRefreshControl.h"

@interface PHVTroopsViewController : UITableViewController <ODRefreshControlDelegate>

@property (strong, nonatomic) ODRefreshControl *refreshControl;

@end
