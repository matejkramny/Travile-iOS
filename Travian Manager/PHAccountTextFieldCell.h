//
//  PHAccountTextFieldCell.h
//  Travian Manager
//
//  Created by Matej Kramny on 30/08/2012.
//
//

#import <UIKit/UIKit.h>

@interface PHAccountTextFieldCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;

- (void)configure;

@end
