//
//  PHOpenMessageViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 25/07/2012.
//
//

#import <UIKit/UIKit.h>
#import "Message.h"

@class Message;

@interface PHOpenMessageViewController : UITableViewController

@property (weak, nonatomic) Message *message;
@property (weak, nonatomic) IBOutlet UILabel *sentBy;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *subject;
@property (weak, nonatomic) IBOutlet UITextView *content;

- (IBAction)return:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)reply:(id)sender;

@end
