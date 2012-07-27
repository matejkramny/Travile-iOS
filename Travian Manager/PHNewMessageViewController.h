//
//  PHNewMessageViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 23/07/2012.
//
//

#import <UIKit/UIKit.h>

@class Message;

@interface PHNewMessageViewController : UITableViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *recipient;
@property (weak, nonatomic) IBOutlet UITextField *subject;
@property (weak, nonatomic) IBOutlet UITextView *content;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) Message *replyToMessage;

- (void)closeKeyboard;
- (IBAction)sendButtonPressed:(id)sender;
- (IBAction)closeView:(id)sender;

@end
