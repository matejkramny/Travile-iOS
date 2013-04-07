/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <UIKit/UIKit.h>

@class TMSettings;

@interface TMSettingsViewController : UITableViewController

@property (nonatomic, weak) TMSettings *settings;
@property (nonatomic, weak) IBOutlet UISwitch *decimalResources;
@property (nonatomic, weak) IBOutlet UISwitch *warehouseIndicator;
@property (nonatomic, weak) IBOutlet UISwitch *loadAllAtOnce;

- (IBAction)changedDecimalResources:(id)sender;
- (IBAction)changedWarehouseIndicator:(id)sender;
- (IBAction)loadAllAtOnce:(id)sender;

@end
