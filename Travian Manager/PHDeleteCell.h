//
//  PHDeleteCell.h
//  Travian Manager
//
//  Created by Matej Kramny on 31/08/2012.
//
//

#import <UIKit/UIKit.h>

@interface PHDeleteCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *button;

- (IBAction)buttonTouched:(id)sender;
- (void)configure;

@end
