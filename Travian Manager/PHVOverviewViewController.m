//
//  PHVOverviewViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 29/07/2012.
//
//

#import "PHVOverviewViewController.h"
#import "AppDelegate.h"
#import "Storage.h"
#import "Village.h"
#import "Account.h"
#import "Movement.h"
#import "Construction.h"

@interface PHVOverviewViewController () {
	Storage *storage;
	Village *village;
	NSTimer *secondTimer;
}

@end

@implementation PHVOverviewViewController

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
	
	AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	storage = [appDelegate storage];
	village = [[storage account] village];
	
	int badgeCount = 0;
	badgeCount += [[village movements] count];
	badgeCount += [[village constructions] count];
	if (badgeCount > 0)
		[[self tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d", badgeCount]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tabBarController.navigationItem setRightBarButtonItems:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItems:nil];
	[self.tabBarController.navigationItem setRightBarButtonItem:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItem:nil];
	
	[self.tabBarController setTitle:[NSString stringWithFormat:@"Overview"]];
	
	secondTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(secondTimerFired:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (secondTimer)
		[secondTimer invalidate];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight));
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 2;
	} else if (section == 1) {
		int c = [[village movements] count];
		
		return c == 0 ? 1 : c;
	} else if (section == 2) {
		int c = [[village constructions] count];
		
		return c == 0 ? 1 : c;
	}
	
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *(^calculateRemainingTimeFromDate)(NSDate *) = ^(NSDate *date) {
		int diff = [date timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
		
		int hours = diff / (60 * 60);
		NSString *hoursString = hours < 10 ? [NSString stringWithFormat:@"0%d", hours] : [NSString stringWithFormat:@"%d", hours];
		diff -= hours * (60 * 60);
		int minutes = diff / 60;
		NSString *minutesString = minutes < 10 ? [NSString stringWithFormat:@"0%d", minutes] : [NSString stringWithFormat:@"%d", minutes];
		diff -= minutes * 60;
		int seconds = diff;
		NSString *secondsString = seconds < 10 ? [NSString stringWithFormat:@"0%d", seconds] : [NSString stringWithFormat:@"%d", seconds];
		
		return [NSString stringWithFormat:@"%@:%@:%@", hoursString, minutesString, secondsString];
	};
	
    if (indexPath.section == 0) {
		// Population & Loyalty
		NSString *cellIdentifier = @"RightDetail";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		
		if (indexPath.row == 0)
		{
			cell.textLabel.text = @"Population";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [village population]];
		}
		else {
			cell.textLabel.text = @"Loyalty";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [village loyalty]];
		}
		
		return cell;
	} else if (indexPath.section == 1) {
		// Movements
		if ([village.movements count] == 0)
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
			
			cell.textLabel.text = NSLocalizedString(@"No Movements", @"");
			
			return cell;
		}
		else
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetail"];
			
			Movement *movement = [village.movements objectAtIndex:indexPath.row];
			
			cell.textLabel.text = [movement name];
			cell.detailTextLabel.text = calculateRemainingTimeFromDate(movement.finished);
			
			return cell;
		}
	} else if (indexPath.section == 2) {
		// Constructions
		if ([village.constructions count] == 0) {
			// No movements
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
			cell.textLabel.text = NSLocalizedString(@"No Constructions", @"");
			return cell;
		} else {
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetail"];
			
			Construction *construction = [village.constructions objectAtIndex:indexPath.row];
			
			NSString *name = [NSString stringWithFormat:NSLocalizedString(@"construction lvl to", @"Construction name lvl X"), construction.name, construction.level];
			cell.textLabel.text = name;
			cell.detailTextLabel.text = construction.finishTime;
			
			return cell;
		}
	}
	
	return nil;
}

- (IBAction)secondTimerFired:(id)sender {
	[[self tableView] reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"Village", @"");
		case 1:
			return NSLocalizedString(@"Movements", @"");
		case 2:
			return NSLocalizedString(@"Constructions", @"");
		default:
			return @"";
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
