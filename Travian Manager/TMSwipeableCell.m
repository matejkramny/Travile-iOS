//
//  TMSwipeableCell.m
//  Travian Manager
//
//  Created by Matej Kramny on 22/04/2013.
//
//

#import "TMSwipeableCell.h"

@implementation TMSwipeableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
