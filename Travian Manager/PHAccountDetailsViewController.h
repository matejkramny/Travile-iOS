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
- (void)accountDetailsViewController:(PHAccountDetailsViewController *)controller didEditAccount:(Account *)oldAccount newAccount:(Account *)newAccount;
@end

@interface PHAccountDetailsViewController : UITableViewController

@property (nonatomic, weak) id <PHAccountDetailsViewControllerDelegate> delegate;
@property (nonatomic, weak) Account *editingAccount;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *accountNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *worldTextField;
@property (strong, nonatomic) IBOutlet UITextField *domainTextField;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)hideKeyboard:(id)sender;

@end