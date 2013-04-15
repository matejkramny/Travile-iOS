/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <UIKit/UIKit.h>

@interface TMVillageResourcesViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *wood;
@property (weak, nonatomic) IBOutlet UILabel *clay;
@property (weak, nonatomic) IBOutlet UILabel *iron;
@property (weak, nonatomic) IBOutlet UILabel *wheat;
@property (weak, nonatomic) IBOutlet UILabel *warehouse;
@property (weak, nonatomic) IBOutlet UILabel *granary;
@property (weak, nonatomic) IBOutlet UILabel *consuming;
@property (weak, nonatomic) IBOutlet UILabel *producing;

- (void)refreshResources;

@end
