//
//  PHAccountDetailsViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 21/07/2012.
//
//

#import <UIKit/UIKit.h>

@class PHAccountDetailsViewController;
@class Account;

@protocol PHAccountDetailsViewControllerDelegate <NSObject>
- (void)accountDetailsViewControllerDidCancel:(PHAccountDetailsViewController *)controller;
- (void)accountDetailsViewController:(PHAccountDetailsViewController *)controller didAddAccount:(Account *)account;
- (void)accountDetailsViewController:(PHAccountDetailsViewController *)controller didEditAccount:(Account *)oldAccount;
- (void)accountDetailsViewController:(PHAccountDetailsViewController *)controller didDeleteAccount:(Account *)account;
@end

@interface PHAccountDetailsViewController : UITableViewController <UIActionSheetDelegate>

@property (nonatomic, weak) id <PHAccountDetailsViewControllerDelegate> delegate;
@property (nonatomic, weak) Account *editingAccount;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)delete:(id)sender;

@end