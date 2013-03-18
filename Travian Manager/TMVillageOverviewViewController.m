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

#import "TMVillageOverviewViewController.h"
#import "AppDelegate.h"
#import "TMStorage.h"
#import "TMVillage.h"
#import "TMAccount.h"
#import "TMMovement.h"
#import "TMConstruction.h"
#import <QuartzCore/QuartzCore.h>

@interface TMVillageOverviewViewController () {
	TMStorage *storage;
	TMVillage *village;
	NSTimer *secondTimer;
	UISegmentedControl *navControl;
	UIBarButtonItem *navButton;
}

- (void)reloadBadgeCount;
- (void)back:(id)sender;

@end

@interface TMVillageOverviewViewController (Notifications)

// Future of notifications.. get asked, indicate if this is getting notified
- (void)scheduleConstruction:(TMConstruction *)construction;
- (void)scheduleConstruction:(TMConstruction *)construction confirmed:(BOOL)confirmed;
- (void)scheduleMovement:(TMMovement *)movement;
- (void)scheduleMovement:(TMMovement *)movement confirmed:(BOOL)confirmed;

@end

@implementation TMVillageOverviewViewController (Notifications)

- (void)scheduleConstruction:(TMConstruction *)construction {
	[self scheduleConstruction:construction confirmed:NO];
}

- (void)scheduleConstruction:(TMConstruction *)construction confirmed:(BOOL)confirmed {
	
}

- (void)scheduleMovement:(TMMovement *)movement {
	[self scheduleMovement:movement confirmed:NO];
}

- (void)scheduleMovement:(TMMovement *)movement confirmed:(BOOL)confirmed {
	
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

- (void)viewDidLoad {
	storage = [TMStorage sharedStorage];
	village = [[storage account] village];
	
	[self setRefreshControl:[[UIRefreshControl alloc] init]];
	[[self refreshControl] addTarget:self action:@selector(didBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	
	[self reloadBadgeCount];
	
	[[self tableView] setBackgroundView:nil];
	[self.navigationItem setTitle:viewTitle];
	[self.navigationItem setHidesBackButton:NO];
	[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Villages" style:UIBarButtonItemStyleBordered target:self action:@selector(back:)]];
	
	[super setTrackedViewName:viewTitle];
	
	// Watch for village changes..
	[[storage account] addObserver:self forKeyPath:@"village" options:NSKeyValueObservingOptionNew context:nil];
	[AppDelegate addVillageNavigationButtonsToNavigationItem:self.navigationItem];
	
	[super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	secondTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(secondTimerFired:) userInfo:nil repeats:YES];
	[[self tableView] reloadData];
	[self reloadBadgeCount];
	
	[self.navigationItem setTitle:village.name];
	
	//[self updateNavigationButtons];
	
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	if (secondTimer)
		[secondTimer invalidate];
	
	//[[storage account] removeObserver:self forKeyPath:@"village" context:nil];
	
	[super viewWillDisappear:animated];
}

- (void)didBeginRefreshing:(id)sender {
	[[storage account] addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
	
	[[storage account] refreshAccountWithMap:ARVillage];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"status"]) {
		if (([[change objectForKey:NSKeyValueChangeNewKey] intValue] & ARefreshed) != 0) {
			// Refreshed
			[[storage account] removeObserver:self forKeyPath:@"status"];
			[self.refreshControl endRefreshing];
			// Reload data
			[[self tableView] reloadData];
			[self reloadBadgeCount];
		}
	} else if (object == storage.account && [keyPath isEqualToString:@"village"]) {
		village = [[storage account] village];
		[self reloadBadgeCount];
		[self.tableView reloadData];
	}
}

#pragma mark - UITabBarBadgeCountDelegate

- (void)reloadBadgeCount {
	int badgeCount = 0;
	badgeCount += [[village movements] count];
	badgeCount += [[village constructions] count];
	
	if (badgeCount > 0)
		[[self tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d", badgeCount]];
	else
		[[self tabBarItem] setBadgeValue:NULL];
}

#pragma mark -

- (void)updateNavigationButtons {
	if (!navControl) {
		navControl = [[UISegmentedControl alloc] initWithItems:@[@" \U000025B2 ", @" \U000025BC "]]; // ASCII codes for arrow up and down
		[navControl setSegmentedControlStyle:UISegmentedControlStyleBar];
		[navControl setMomentary:YES];
		
		[navControl addTarget:self action:@selector(didPressNavControl:) forControlEvents:UIControlEventValueChanged];
		
		navButton = [[UIBarButtonItem alloc] initWithCustomView:navControl];
	}
	
	if ([storage.account.villages count] > 1) {
		// get index of current villages
		int index = [storage.account.villages indexOfObjectIdenticalTo:village];
		if (index == 0)
			[navControl setEnabled:NO forSegmentAtIndex:0];
		else if (index == [storage.account.villages count]-1)
			[navControl setEnabled:NO forSegmentAtIndex:1];
		else {
			[navControl setEnabled:YES forSegmentAtIndex:0];
			[navControl setEnabled:YES forSegmentAtIndex:1];
		}
	} else {
		[navControl setEnabled:NO forSegmentAtIndex:0];
		[navControl setEnabled:NO forSegmentAtIndex:1];
	}
	
	[self.navigationItem setRightBarButtonItem:navButton animated:NO];
}

- (void)didPressNavControl:(id)sender {
	static const CGFloat animationSpeed = DEBUG_ANIMATION ? 2 : 0.5;
	
	int index = [navControl selectedSegmentIndex];
	int villageIndex = [storage.account.villages indexOfObjectIdenticalTo:village];
	
	// Animates the tableview reload
	CATransition *transition = [CATransition animation];
	[transition setType:kCATransitionPush];
	[transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[transition setFillMode:kCAFillModeForwards];
	[transition setDuration:animationSpeed];
	
	if (index == 0) {
		// up
		villageIndex--;
		// transition move from bottom
		[transition setSubtype:kCATransitionFromBottom];
	} else {
		// down
		villageIndex++;
		// transition move from top
		[transition setSubtype:kCATransitionFromTop];
	}
	
	if (villageIndex < 0 || villageIndex > storage.account.villages.count-1) {
		// array out of bounds prevention
		[self updateNavigationButtons];
		return;
	}
	
	village = [storage.account.villages objectAtIndex:villageIndex];
	[storage.account setVillage:village];
	
	[self.tableView reloadData];
	[[self.tableView layer] addAnimation:transition forKey:@"UITableViewReloadDataAnimationKey"];
	
	[self reloadBadgeCount];
	[self.navigationItem setTitle:village.name];
	[self updateNavigationButtons];
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
			
			cell.textLabel.text = [movement name];
			cell.detailTextLabel.text = calculateRemainingTimeFromDate(movement.finished);
			
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
			return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Village", @""), village.name];
		case 1:
			return NSLocalizedString(@"Movements", @"");
		case 2:
			return NSLocalizedString(@"Constructions", @"");
		default:
			return @"";
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1) {
		// Movements
		if ([village.movements count] > 0) {
			// Select row
			TMMovement *movement = [village.movements objectAtIndex:indexPath.row];
			
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			if (DEBUG_APP) {
				NSDate *finish = [NSDate dateWithTimeIntervalSinceNow:10];
				[notification setFireDate:finish];
			} else
				[notification setFireDate:movement.finished];
			[notification setAlertAction:[NSString stringWithFormat:@"open village %@", village.name]];
			[notification setAlertBody:[NSString stringWithFormat:@"%@ happened on village %@ from account %@", movement.name, village.name, storage.account.name]];
			
			[[UIApplication sharedApplication] scheduleLocalNotification:notification];
		} else {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			return;
		}
	} else if (indexPath.section == 2) {
		// Construction
		if ([village.constructions count] > 0) {
			TMConstruction *construction = [village.constructions objectAtIndex:indexPath.row];
			
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			if (DEBUG_APP) {
				NSDate *finish = [NSDate dateWithTimeIntervalSinceNow:10];
				[notification setFireDate:finish];
			} else {
				[notification setFireDate:construction.finishTime];
			}
			[notification setAlertAction:[NSString stringWithFormat:@"open village %@", village.name]];
			[notification setAlertBody:[NSString stringWithFormat:@"%@ constructed on village %@ from account %@", construction.name, village.name, storage.account.name]];
			
			[[UIApplication sharedApplication] scheduleLocalNotification:notification];
		}
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Back button

- (void)back:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
