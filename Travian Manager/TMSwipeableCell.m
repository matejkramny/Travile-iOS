//
//  TMSwipeableCell.m
//  Travian Manager
//
//  Created by Matej Kramny on 22/04/2013.
//
//

#import "TMSwipeableCell.h"

@implementation TMSwipeableCell

@synthesize backView, frontView, reportStatus, farmName, bountyString, lastAttackDate, reportBountyStatus, reportBountyStatusOverlay, attackingIndicator;

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

- (void)configureReportStatus:(TMFarmListEntryFarmLastReportType)type attacking:(bool)isAttacking {
	//reportStatus.frame = CGRectMake(0, 0, 5, self.frame.size.height);
	static UIColor *typeLostAllColour;
	static UIColor *typeLostSomeColour;
	static UIColor *typeLostNoneColour;
	static UIColor *typeLostUnknownColour;
	static UIColor *typeBountyAllColour;
	static UIColor *typeBountyHalfColour;
	static UIColor *typeBountyNoneColour;
	
	if (!typeLostAllColour)
		typeLostAllColour = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.3f];
	if (!typeLostSomeColour)
		typeLostSomeColour = [UIColor colorWithRed:239.0/255.0 green:156.0f/255.0f blue:8.0f/255.0f alpha:0.3f];
	if (!typeLostNoneColour)
		typeLostNoneColour = [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.3f];
	if (!typeLostUnknownColour)
		typeLostUnknownColour = [UIColor colorWithWhite:0.3f alpha:0.3f];
	
	if (!typeBountyAllColour)
		typeBountyAllColour = [UIColor colorWithWhite:0.4 alpha:0.3f];
	if (!typeBountyHalfColour)
		typeBountyHalfColour = [UIColor colorWithWhite:0.6 alpha:0.3f];
	if (!typeBountyNoneColour)
		typeBountyNoneColour = [UIColor colorWithWhite:0.8 alpha:0.3f];
	
	if ((type & TMFarmListEntryFarmLastReportTypeLostNone) != 0) {
		reportStatus.backgroundColor = typeLostNoneColour;
	} else if ((type & TMFarmListEntryFarmLastReportTypeLostSome) != 0) {
		reportStatus.backgroundColor = typeLostSomeColour;
	} else if ((type & TMFarmListEntryFarmLastReportTypeLostAll) != 0) {
		reportStatus.backgroundColor = typeLostAllColour;
	} else {
		reportStatus.backgroundColor = typeLostUnknownColour;
	}
	
	reportBountyStatus.backgroundColor = typeBountyNoneColour;
	if ((type & TMFarmListEntryFarmLastReportTypeBountyFull) != 0) {
		reportBountyStatusOverlay.backgroundColor = typeBountyAllColour;
		reportBountyStatusOverlay.frame = CGRectMake(5, 0, 5, self.frame.size.height);
	} else if ((type & TMFarmListEntryFarmLastReportTypeBountyPartial) != 0) {
		reportBountyStatusOverlay.backgroundColor = typeBountyHalfColour;
		reportBountyStatusOverlay.frame = CGRectMake(5, self.frame.size.height/2, 5, self.frame.size.height/2);
	} else {
		reportBountyStatusOverlay.frame = CGRectMake(5, 0, 5, 0);
	}
	
	if (isAttacking) {
		attackingIndicator.backgroundColor = typeLostSomeColour;
	} else {
		attackingIndicator.backgroundColor = [UIColor clearColor];
	}
}

@end
