//
//  PHVBarracksCell.m
//  Travian Manager
//
//  Created by Matej Kramny on 28/08/2012.
//
//

#import "PHVBarracksCell.h"
#import "Troop.h"
#import "Resources.h"

@interface PHVBarracksCell ()

@end

@implementation PHVBarracksCell
@synthesize resources;
@synthesize otherDetails;

@synthesize name;
@synthesize many;
@synthesize troop;

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
	[self updateTextLabels];
	
	[many setPlaceholder:[NSString stringWithFormat:@"%d", troop.maxTroops]];
	if (troop.count > 0)
		many.text = [NSString stringWithFormat:@"%d", troop.count];
	else
		many.text = @"";
	
	[name setText:troop.name];
	
}

- (void)updateTextLabels {
	int troops = troop.count <= 0 ? 1 : troop.count;
	if (troops > troop.maxTroops) {
		troops = troop.maxTroops;
		[many setText:[NSString stringWithFormat:@"%d", troops]]; // Disallow more troops than able to build
	}
	
	__weak Resources *r = troop.resources;
	[resources setText:[NSString stringWithFormat:@"%.0f Wood %.0f Clay %.0f Iron %.0f Wheat", r.wood * troops, r.clay * troops, r.iron * troops, r.wheat * troops]];
	
	int secs = troop.researchTime * troops;
	int hours = secs / (60 * 60);
	NSString *hoursString = hours < 10 ? [NSString stringWithFormat:@"0%d", hours] : [NSString stringWithFormat:@"%d", hours];
	secs -= hours * (60 * 60);
	int minutes = secs / 60;
	NSString *minutesString = minutes < 10 ? [NSString stringWithFormat:@"0%d", minutes] : [NSString stringWithFormat:@"%d", minutes];
	secs -= minutes * 60;
	int seconds = secs;
	NSString *secondsString = seconds < 10 ? [NSString stringWithFormat:@"0%d", seconds] : [NSString stringWithFormat:@"%d", seconds];
	
	[otherDetails setText:[NSString stringWithFormat:@"%@:%@:%@ hrs to train", hoursString, minutesString, secondsString]];
}

- (IBAction)manyEditingChanged:(id)sender {
	troop.count = [[many text] intValue];
	[self updateTextLabels];
}

@end
