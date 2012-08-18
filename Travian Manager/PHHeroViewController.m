//
//  PHHeroViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 27/07/2012.
//
//

#import "PHHeroViewController.h"
#import "AppDelegate.h"
#import "Storage.h"
#import "Account.h"
#import "Resources.h"
#import "Hero.h"
#import "HeroQuest.h"

@interface PHHeroViewController () {
	Hero *hero;
	bool viewingMoreQuests;
}

@end

@implementation PHHeroViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	Account *a = [[Storage sharedStorage] account];
	hero = [a hero];
	viewingMoreQuests = false;
}

- (void)viewDidUnload
{
	hero = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tabBarController.navigationItem setRightBarButtonItems:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItems:nil];
	[self.tabBarController.navigationItem setRightBarButtonItem:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItem:nil];
	
	[self.tabBarController setTitle:[NSString stringWithFormat:@"Hero"]];
	
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int qsc;
	switch (section) {
		case 0:
			// Facts
			return 4;
		case 1:
			// Attributes
			return 4;
		case 2:
			// Adventures
			qsc = [[hero quests] count];
			//return viewingMoreQuests ? qsc+1 : qsc >= 3 ? 4 : qsc+1;
			//return viewingMoreQuests ? qsc+1 : qsc < 4 ? qsc : qsc+1;
			
			if (viewingMoreQuests)
				return qsc+1; // Quests + button
			else if (qsc == 0)
				return 1; // Label showing no adventures
			else if (qsc < 4)
				return qsc; // Quests
			else if (qsc > 3)
				return 4; // Quests + button
			else
				return qsc+1;
		case 3:
			// Resources
			return 4;
	}
	
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	
	int qsc;
	switch (indexPath.section) {
		case 0:
			// Facts
			switch (indexPath.row) {
				case 0:
					cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetailCell"];
					cell.textLabel.text = @"Hero hiding";
					cell.detailTextLabel.text = [hero isHidden] ? @"YES" : @"NO";
					break;
				case 1:
					cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetailCell"];
					cell.textLabel.text = @"Experience";
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [hero experience]];
					break;
				case 2:
					cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetailCell"];
					cell.textLabel.text = @"Speed";
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [hero speed]];
					break;
				case 3:
					cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetailCell"];
					cell.textLabel.text = @"Health";
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [hero health]];
					break;
			}
			break;
		case 1:
			// Attributes
			switch (indexPath.row) {
				case 0:
					cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetailCell"];
					cell.textLabel.text = @"Strength";
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [hero strengthPoints]];
					break;
				case 1:
					cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetailCell"];
					cell.textLabel.text = @"Off Bonus";
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%d%%", [hero offBonusPercentage]];
					break;
				case 2:
					cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetailCell"];
					cell.textLabel.text = @"Def Bonus";
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%d%%", [hero defBonusPercentage]];
					break;
				case 3:
					cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetailCell"];
					cell.textLabel.text = @"Resource Bonus pts";
					cell.detailTextLabel.text = @"?";
					break;
			}
			break;
		case 2:
			// Adventures
			qsc = [[hero quests] count];
			
			if (qsc == 0) {
				cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
				cell.textLabel.text = @"No adventures";
			} else if (indexPath.row+1 == (viewingMoreQuests ? qsc+1 : 4)) {
				// Button comes last
				cell = [tableView dequeueReusableCellWithIdentifier:@"BasicSelectableCell"];
				cell.textLabel.text = viewingMoreQuests ? @"View less" : [NSString stringWithFormat:@"View more (%d total)", qsc];
			} else {
				cell = [tableView dequeueReusableCellWithIdentifier:@"BasicSelectableCell"];
				NSString *difficulty = @"Normal";
				HeroQuest *quest = [[hero quests] objectAtIndex:indexPath.row];
				if ([quest difficulty] == QD_VERY_HARD)
					difficulty = @"VHard";
				
				cell.textLabel.text = [NSString stringWithFormat:@"[%@] %ds", difficulty, [quest duration]];
			}
			
			break;
		case 3:
			// Resources boost
			cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetailCell"];
			NSString *tL = @"", *dL = @""; // textLabel, detailLabel
			Resources *r = [hero resourceProductionBoost];
			switch (indexPath.row) {
				case 0:
					tL = @"Wood";
					dL = [NSString stringWithFormat:@"%f", r.wood];
					break;
				case 1:
					tL = @"Clay";
					dL = [NSString stringWithFormat:@"%f", r.clay];
					break;
				case 2:
					tL = @"Iron";
					dL = [NSString stringWithFormat:@"%f", r.iron];
					break;
				case 3:
					tL = @"Wheat";
					dL = [NSString stringWithFormat:@"%f", r.wheat];
					break;
			}
			
			cell.textLabel.text = tL;
			cell.detailTextLabel.text = dL;
			
			break;
	}
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Facts";
		case 1:
			return @"Attributes";
		case 2:
			return @"Adventures";
		case 3:
			return @"Resources boost";
	}
	
	return @"";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 2) {
		// Check if adventure click or View More button
		int qsc = [[hero quests] count];
		if (indexPath.row+1 == (viewingMoreQuests ? qsc+1 : qsc >= 3 ? 4 : qsc+1)) {
			// View More button click
			if (viewingMoreQuests) {
				// View less
				viewingMoreQuests = false;
				[tableView reloadData];
			} else {
				// view more
				viewingMoreQuests = true;
				[tableView reloadData];
			}
		} else {
			// Start an adventure
			Account *a = [Storage sharedStorage].account;
			[[[hero quests] objectAtIndex:indexPath.row] startQuest:a];
			
			NSMutableArray *ar = [[hero quests] mutableCopy];
			[ar removeObjectAtIndex:indexPath.row];
			[hero setQuests:[ar copy]];
			
			[tableView reloadData];
		}
	}
}

@end
