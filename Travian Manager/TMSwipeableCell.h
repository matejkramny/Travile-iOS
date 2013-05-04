//
//  TMSwipeableCell.h
//  Travian Manager
//
//  Created by Matej Kramny on 22/04/2013.
//
//

#import <UIKit/UIKit.h>
#import "TMFarmListEntryFarm.h"

@interface TMSwipeableCell : UITableViewCell

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *frontView;
@property (weak, nonatomic) IBOutlet UIView *reportStatus;
@property (weak, nonatomic) IBOutlet UILabel *farmName;
@property (weak, nonatomic) IBOutlet UILabel *bountyString;
@property (weak, nonatomic) IBOutlet UILabel *lastAttackDate;

- (void)configureReportStatus:(TMFarmListEntryFarmLastReportType)type;

@end
