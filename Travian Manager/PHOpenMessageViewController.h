//
//  PHOpenMessageViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 25/07/2012.
//
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "PHNewMessageViewController.h"

@class Message;
@class PHOpenMessageViewController;

@protocol PHOpenMessageViewControllerDelegate <NSObject>

- (void)openMessageViewController:(PHOpenMessageViewController *)viewController didCloseMessage:(Message *)message;

@end

@interface PHOpenMessageViewController : UITableViewController <PHNewMessageDelegate>

@property (weak, nonatomic) id<PHOpenMessageViewControllerDelegate> delegate;
@property (weak, nonatomic) Message *message;
@property (weak, nonatomic) IBOutlet UILabel *sentBy;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *subject;
@property (weak, nonatomic) IBOutlet UITextView *content;

- (IBAction)return:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)reply:(id)sender;

@end
