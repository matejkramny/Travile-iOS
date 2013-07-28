// This code is distributed under the terms and conditions of the MIT license.

/* * Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial
 * portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
 * OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "TMVillageBarracksCell.h"
#import "TMTroop.h"
#import "TMResources.h"

@interface TMVillageBarracksCell ()

@end

@implementation TMVillageBarracksCell
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
	
	__weak TMResources *r = troop.resources;
	[resources setText:[NSString stringWithFormat:@"%.0f %@ %.0f %@ %.0f %@ %.0f %@", r.wood * troops, NSLocalizedString(@"Wood", nil), r.clay * troops, NSLocalizedString(@"Clay", nil), r.iron * troops, NSLocalizedString(@"Iron", nil), r.wheat * troops, NSLocalizedString(@"Wheat", nil)]];
	
	int secs = troop.researchTime * troops;
	int hours = secs / (60 * 60);
	NSString *hoursString = hours < 10 ? [NSString stringWithFormat:@"0%d", hours] : [NSString stringWithFormat:@"%d", hours];
	secs -= hours * (60 * 60);
	int minutes = secs / 60;
	NSString *minutesString = minutes < 10 ? [NSString stringWithFormat:@"0%d", minutes] : [NSString stringWithFormat:@"%d", minutes];
	secs -= minutes * 60;
	int seconds = secs;
	NSString *secondsString = seconds < 10 ? [NSString stringWithFormat:@"0%d", seconds] : [NSString stringWithFormat:@"%d", seconds];
	
	[otherDetails setText:[NSString stringWithFormat:NSLocalizedString(@"%@:%@:%@ hrs to train", @"Shown in barracks, shows hours:minutes:seconds to train a troop"), hoursString, minutesString, secondsString]];
}

- (IBAction)manyEditingChanged:(id)sender {
	troop.count = [[many text] intValue];
	[self updateTextLabels];
}

@end
