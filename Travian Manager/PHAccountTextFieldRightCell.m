//
//  PHAccountTextFieldRightCell.m
//  Travian Manager
//
//  Created by Matej Kramny on 30/08/2012.
//
//

#import "PHAccountTextFieldRightCell.h"

@implementation PHAccountTextFieldRightCell
@synthesize label;
@synthesize textField;

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

- (void)configure {
	textField.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    return NO;
}

@end
