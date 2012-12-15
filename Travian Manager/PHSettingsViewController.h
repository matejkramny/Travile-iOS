//
//  PHSettingsViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 28/07/2012.
//
//

#import <UIKit/UIKit.h>

@class Settings;

@interface PHSettingsViewController : UITableViewController

@property (nonatomic, weak) Settings *settings;
@property (nonatomic, weak) IBOutlet UISwitch *decimalResources;
@property (nonatomic, weak) IBOutlet UISwitch *warehouseIndicator;

- (IBAction)changedDecimalResources:(id)sender;
- (IBAction)changedWarehouseIndicator:(id)sender;

@end
