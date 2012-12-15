//
//  PHMessageCell.h
//  Travian Manager
//
//  Created by Matej Kramny on 14/12/2012.
//
//

#import <UIKit/UIKit.h>

@class Message;

@interface PHMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *unreadImage;
@property (weak, nonatomic) IBOutlet UIImageView *deleteCheckboxImage;
@property (weak, nonatomic) Message *message;

- (void)configure;
- (void)wasSelectedWhileEditing;
- (BOOL)isMarkedForDelete;

@end
