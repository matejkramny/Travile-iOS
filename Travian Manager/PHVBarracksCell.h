//
//  PHVBarracksCell.h
//  Travian Manager
//
//  Created by Matej Kramny on 28/08/2012.
//
//

#import <UIKit/UIKit.h>

@class Troop;

@interface PHVBarracksCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UITextField *many;
@property (weak, nonatomic) Troop *troop; // Updates troops count property when user changes value of self.many
@property (weak, nonatomic) IBOutlet UILabel *resources;
@property (weak, nonatomic) IBOutlet UILabel *otherDetails;

- (void)configure;
- (void)updateTextLabels;
- (IBAction)manyEditingChanged:(id)sender;

@end
