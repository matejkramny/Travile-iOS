//
//  PHVBuildingListViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 01/08/2012.
//
//

#import <UIKit/UIKit.h>
#import "PHVOpenBuildingViewController.h"

@class PHVBuildingListViewController;
@class Building;

@protocol PHVBuildingListDelegate <NSObject>

- (void)phvBuildingListViewController:(PHVBuildingListViewController *)controller didSelectBuilding:(Building *)building;

@end

@interface PHVBuildingListViewController : UITableViewController <PHVOpenBuildingDelegate, UITableViewDataSource>

@property (weak, nonatomic) id<PHVBuildingListDelegate> delegate;
@property (weak, nonatomic) NSArray *buildings;

- (IBAction)cancel:(id)sender;

@end
