//
//  PHOpenMessageViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 25/07/2012.
//
//

#import <UIKit/UIKit.h>
#import "Message.h"

@class PHOpenMessageViewController;

@protocol PHOpenMessageDelegate <NSObject>

- (void)openMessageControllerDidCloseMessage:(PHOpenMessageViewController *)controller;

@end

@interface PHOpenMessageViewController : UITableViewController

@property (strong, nonatomic) Message *message;
@property (weak, nonatomic) IBOutlet UILabel *sentBy;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *subject;

@end
