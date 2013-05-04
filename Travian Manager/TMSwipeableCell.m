//
//  TMSwipeableCell.m
//  Travian Manager
//
//  Created by Matej Kramny on 22/04/2013.
//
//

#import "TMSwipeableCell.h"

@implementation TMSwipeableCell

@synthesize backView, frontView, reportStatus, farmName, bountyString, lastAttackDate;

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

- (void)configureReportStatus:(TMFarmListEntryFarmLastReportType)type {
	reportStatus.frame = CGRectMake(0, 0, 5, self.frame.size.height);
	static UIColor *typeLostAllColour;
	static UIColor *typeLostSomeColour;
	static UIColor *typeLostNoneColour;
	
	if (!typeLostAllColour)
		typeLostAllColour = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.3f];
	if (!typeLostSomeColour)
		typeLostSomeColour = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.3f];
	if (!typeLostNoneColour)
		typeLostNoneColour = [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.3f];
	
	if ((type & TMFarmListEntryFarmLastReportTypeLostNone) != 0) {
		reportStatus.backgroundColor = typeLostNoneColour;
	} else if ((type & TMFarmListEntryFarmLastReportTypeLostSome) != 0) {
		reportStatus.backgroundColor = typeLostSomeColour;
	} else if ((type & TMFarmListEntryFarmLastReportTypeLostAll) != 0) {
		reportStatus.backgroundColor = typeLostAllColour;
	}
}

@end
