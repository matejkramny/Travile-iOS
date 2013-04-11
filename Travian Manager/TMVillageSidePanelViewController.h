/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"

@interface TMVillageSidePanelViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, JASidePanel>

@property (weak, nonatomic) IBOutlet UITableView *headerTable;
@property (weak, nonatomic) IBOutlet UITableView *contentTable;

@end
