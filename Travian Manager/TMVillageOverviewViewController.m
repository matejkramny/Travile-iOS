/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMVillageOverviewViewController.h"
#import "AppDelegate.h"
#import "TMStorage.h"
#import "TMVillage.h"
#import "TMAccount.h"
#import "TMMovement.h"
#import "TMConstruction.h"
#import <QuartzCore/QuartzCore.h>
#import "TMAPNService.h"
#import "TestFlight.h"
#import "TMApplicationSettings.h"

@interface TMVillageOverviewViewController () {
	TMStorage *storage;
	TMVillage *village;
	NSTimer *secondTimer;
	int constructionRows;
	int movementRows;
}

@end

@implementation TMVillageOverviewViewController

static NSString *viewTitle = @"Overview";

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
	storage = [TMStorage sharedStorage];
	village = [[storage account] village];
	
	[self setRefreshControl:[[UIRefreshControl alloc] init]];
	[[self refreshControl] addTarget:self action:@selector(didBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	
	[[self tableView] setBackgroundView:nil];
	[self.navigationItem setTitle:viewTitle];
	//[self.navigationItem setHidesBackButton:NO];
	//[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Villages" style:UIBarButtonItemStyleBordered target:self action:@selector(back:)]];
	
	[super viewDidLoad];
}

- (void)viewDidUnload
{	
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	secondTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(secondTimerFired:) userInfo:nil repeats:YES];
	[[self tableView] reloadData];
	
	[self.navigationItem setTitle:viewTitle];
	
	if (village != storage.account.village) {
		// Village changed..
		village = storage.account.village;
		[self.tableView reloadData];
	}
	
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	if (secondTimer)
		[secondTimer invalidate];
	
	@try {
		[storage.account removeObserver:self forKeyPath:@"status"];
		[self.refreshControl endRefreshing];
	}
	@catch (id exception) {
		// do nothing.. means it isn't registered as observer
	}
	
	[super viewWillDisappear:animated];
}

- (void)didBeginRefreshing:(id)sender {
	[[storage account] addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
	
	[[storage account] refreshAccountWithMap:ARVillage];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"status"]) {
		if (([[change objectForKey:NSKeyValueChangeNewKey] intValue] & ARefreshed) != 0) {
			// Refreshed
			[[storage account] removeObserver:self forKeyPath:@"status"];
			[self.refreshControl endRefreshing];
			// Reload data
			[[self tableView] reloadData];
		}
	}
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
		
		movementRows = c == 0 ? 1 : c;
		return movementRows;
	} else if (section == 2) {
		int c = [[village constructions] count];
		
		constructionRows = c == 0 ? 1 : c;
		return constructionRows;
	}
	
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *(^calculateRemainingTimeFromDate)(NSDate *) = ^(NSDate *date) {
		if (date == nil)
			return [NSString stringWithString:NSLocalizedString(@"Event Pending", @"Pending event message")];
		
		int diff = [date timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
		
		if (diff <= 0) {
			// Event happened..
			return [NSString stringWithString:NSLocalizedString(@"Event Happened", @"Timer has reached < 0 seconds")];
		}
		
		int hours = diff / (60 * 60);
		NSString *hoursString = hours < 10 ? [NSString stringWithFormat:@"0%d", hours] : [NSString stringWithFormat:@"%d", hours];
		diff -= hours * (60 * 60);
		int minutes = diff / 60;
		NSString *minutesString = minutes < 10 ? [NSString stringWithFormat:@"0%d", minutes] : [NSString stringWithFormat:@"%d", minutes];
		diff -= minutes * 60;
		int seconds = diff;
		NSString *secondsString = seconds < 10 ? [NSString stringWithFormat:@"0%d", seconds] : [NSString stringWithFormat:@"%d", seconds];
		
		if (hours > 0)
			return [NSString stringWithFormat:@"%@:%@:%@ %@", hoursString, minutesString, secondsString, NSLocalizedString(@"hrs", @"Timers suffix (hours remaining)")];
		else if (minutes > 0)
			return [NSString stringWithFormat:@"%@:%@ %@", minutesString, secondsString, NSLocalizedString(@"min", @"Timers suffix (minutes remaining)")];
		else
			return [NSString stringWithFormat:@"%@ %@", secondsString, NSLocalizedString(@"sec", @"Timers suffix (seconds remaining)")];
	};
	
	static NSString *rightDetailCellIdentifier = @"RightDetail";
	static NSString *rightDetailSelectableCellIdentifier = @"RightDetailSelectable";
	static NSString *basicCellIdentifier = @"Basic";
	__unused static NSString *basicSelectableCellIdentifier = @"BasicSelectable";
	
    if (indexPath.section == 0) {
		// Population & Loyalty
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rightDetailCellIdentifier];
		
		if (indexPath.row == 0)
		{
			cell.textLabel.text = @"Population";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [village population]];
			[AppDelegate setRoundedCellAppearance:cell forIndexPath:indexPath forLastRow:false];
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
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:basicCellIdentifier];
			
			cell.textLabel.text = NSLocalizedString(@"No Movements", @"");
			
			return cell;
		}
		else
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rightDetailSelectableCellIdentifier];
			
			TMMovement *movement = [village.movements objectAtIndex:indexPath.row];
			
			NSString *type = @"";
			if ((movement.type & TMMovementTypeIncoming) != 0)
				type = @"<";
			else if ((movement.type & TMMovementTypeOutgoing) != 0)
				type = @">";
			
			cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", type, [movement name]];
			cell.detailTextLabel.text = calculateRemainingTimeFromDate(movement.finished);
			
			[AppDelegate setRoundedCellAppearance:cell forIndexPath:indexPath forLastRow:indexPath.row+1 == movementRows];
			
			return cell;
		}
	} else if (indexPath.section == 2) {
		// Constructions
		if ([village.constructions count] == 0) {
			// No constructions
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:basicCellIdentifier];
			cell.textLabel.text = NSLocalizedString(@"No Constructions", @"");
			return cell;
		} else {
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rightDetailSelectableCellIdentifier];
			
			TMConstruction *construction = [village.constructions objectAtIndex:indexPath.row];
			
			NSString *name = [NSString stringWithFormat:NSLocalizedString(@"construction lvl to", @"Construction name lvl X"), construction.name, construction.level];
			cell.textLabel.text = name;
			cell.detailTextLabel.text = calculateRemainingTimeFromDate(construction.finishTime);
			
			[AppDelegate setRoundedCellAppearance:cell forIndexPath:indexPath forLastRow:indexPath.row+1 == constructionRows];
			
			return cell;
		}
	}
	
	return nil;
}

- (IBAction)secondTimerFired:(id)sender {
	[self.tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return village.name;
		case 1:
			return NSLocalizedString(@"Movements", @"");
		case 2:
			return NSLocalizedString(@"Constructions", @"");
		default:
			return @"";
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 2)
		return @"Tap on a construction or movement to schedule a notification";
	
	return @"";
}

#pragma mark - Table view delegate

static NSDate *notificationDate;
static NSString *notificationTitle;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1) {
		// Movements
		if ([village.movements count] > 0) {
			// Select row
			TMMovement *movement = [village.movements objectAtIndex:indexPath.row];
			
			NSDate *finish = movement.finished;
			if (DEBUG_APP)
				finish = [NSDate dateWithTimeIntervalSinceNow:10];
			
			notificationTitle = [NSString stringWithFormat:@"%@ happened on village %@ from account %@", movement.name, village.name, storage.account.name];
			notificationDate = [movement finished];
		} else {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			return;
		}
	} else if (indexPath.section == 2) {
		// Construction
		if ([village.constructions count] > 0) {
			TMConstruction *construction = [village.constructions objectAtIndex:indexPath.row];
			
			NSDate *finish = construction.finishTime;
			if (DEBUG_APP)
				finish = [NSDate dateWithTimeIntervalSinceNow:10];
			
			notificationTitle = [NSString stringWithFormat:@"%@ constructed on village %@ from account %@", construction.name, village.name, storage.account.name];
			notificationDate = [construction finishTime];
		}
	} else {
		return;
	}
	
	if (storage.appSettings.pushNotifications) {
		[[TMAPNService sharedInstance] scheduleNotification:notificationDate withMessageTitle:notificationTitle];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Push Notifications?" message:@"Push notifications are not enabled right now." delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:@"Enable", nil];
		[alert show];
	}
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		// Enable
		storage.appSettings.pushNotifications = true;
		[[TMAPNService sharedInstance] scheduleNotification:notificationDate withMessageTitle:notificationTitle];
		[storage saveData];
	}
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

@end
