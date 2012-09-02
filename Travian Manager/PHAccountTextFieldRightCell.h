//
//  PHAccountTextFieldRightCell.h
//  Travian Manager
//
//  Created by Matej Kramny on 30/08/2012.
//
//

#import <UIKit/UIKit.h>

@interface PHAccountTextFieldRightCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;

- (void)configure;

@end
