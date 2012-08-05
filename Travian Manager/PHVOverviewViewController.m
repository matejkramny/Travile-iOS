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
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 2;
	} else if (section == 1) {
		int c = [[village movements] count];
		
		return c == 0 ? 1 : c;
	}
	
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
	} else {
		// Movements
		if ([village.movements count] == 0)
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Basic"];
			
			cell.textLabel.text = @"No movements";
			
			return cell;
		}
		else
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetail"];
			
			Movement *movement = [village.movements objectAtIndex:indexPath.row];
			
			int diff = [movement.finished timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
			
			int hours = diff / (60 * 60);
			NSString *hoursString = hours < 10 ? [NSString stringWithFormat:@"0%d", hours] : [NSString stringWithFormat:@"%d", hours];
			diff -= hours * (60 * 60);
			int minutes = diff / 60;
			NSString *minutesString = minutes < 10 ? [NSString stringWithFormat:@"0%d", minutes] : [NSString stringWithFormat:@"%d", minutes];
			diff -= minutes * 60;
			int seconds = diff;
			NSString *secondsString = seconds < 10 ? [NSString stringWithFormat:@"0%d", seconds] : [NSString stringWithFormat:@"%d", seconds];
			
			cell.textLabel.text = [movement name];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@:%@:%@", hoursString, minutesString, secondsString];
			
			return cell;
		}
	}
}

- (IBAction)secondTimerFired:(id)sender {
	[[self tableView] reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Village";
		case 1:
			return @"Movements";
		default:
			return @"";
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
