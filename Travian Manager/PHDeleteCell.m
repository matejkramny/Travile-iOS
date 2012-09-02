//
//  PHDeleteCell.m
//  Travian Manager
//
//  Created by Matej Kramny on 31/08/2012.
//
//

#import "PHDeleteCell.h"

@implementation PHDeleteCell

@synthesize button;

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

- (IBAction)buttonTouched:(id)sender {
	
}

- (void)configure {
	[self setBackgroundColor:[UIColor clearColor]];
	UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
	backView.backgroundColor = [UIColor clearColor];
	self.backgroundView = backView;
}

@end
