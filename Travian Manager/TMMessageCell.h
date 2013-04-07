/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <UIKit/UIKit.h>

@class TMMessage;

@interface TMMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *unreadImage;
@property (weak, nonatomic) IBOutlet UIImageView *deleteCheckboxImage;
@property (weak, nonatomic) TMMessage *message;

- (void)configure;
- (void)wasSelectedWhileEditing;
- (BOOL)isMarkedForDelete;

@end
