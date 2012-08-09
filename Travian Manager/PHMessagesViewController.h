//
//  PHMessagesViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 22/07/2012.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "PHOpenMessageViewController.h"

@interface PHMessagesViewController : UITableViewController <UIAlertViewDelegate, MBProgressHUDDelegate, PHOpenMessageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)segmentedControlValueChanged:(id)sender;

@end
