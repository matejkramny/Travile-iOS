//
//  PHNewMessageViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 23/07/2012.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class Message;
@class PHNewMessageViewController;

@protocol PHNewMessageDelegate <NSObject>

- (void)pHNewMessageController:(PHNewMessageViewController *)controller didSendMessage:(Message *)message;

@end

@interface PHNewMessageViewController : UITableViewController <UIAlertViewDelegate, MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UITextField *recipient;
@property (weak, nonatomic) IBOutlet UITextField *subject;
@property (weak, nonatomic) IBOutlet UITextView *content;
@property (weak, nonatomic) IBOutlet UITableViewCell *contentCell;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) Message *replyToMessage;
@property (weak, nonatomic) id <PHNewMessageDelegate> delegate;

- (void)closeKeyboard;
- (IBAction)sendButtonPressed:(id)sender;
- (IBAction)closeView:(id)sender;

@end
