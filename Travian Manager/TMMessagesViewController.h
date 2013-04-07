/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "TMOpenMessageViewController.h"

@interface TMMessagesViewController : UITableViewController <UIAlertViewDelegate, MBProgressHUDDelegate, TMOpenMessageViewControllerDelegate>

- (void)reloadBadgeCount;

@end
