/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMVillageSidePanelViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "TMVillagePanelViewController.h"
#import "TMStorage.h"
#import "TMAccount.h"
#import "TMVillage.h"
#import "AppDelegate.h"
#import "TMMovement.h"
#import "TMConstruction.h"

@interface TMVillageSidePanelViewController () {
	__weak TMStorage *storage;
	UIViewController *currentViewController;
	NSIndexPath *currentViewControllerIndexPath;
}

@end

@implementation TMVillageSidePanelViewController

@synthesize headerTable, contentTable;

static bool firstTime = true;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	static UIColor *backgroundImage;
	
	if (!backgroundImage) {
		backgroundImage = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TMDarkBackground.png"]];
	}
	
	[headerTable setBackgroundColor:backgroundImage];
	[headerTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[contentTable setBackgroundColor:backgroundImage];
	[contentTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	storage = [TMStorage sharedStorage];
	
	if (self.navigationItem != nil)
		self.navigationItem.title = storage.account.village.name;
	
	[contentTable reloadData];
	
	if (firstTime) {
		firstTime = false;
		currentViewControllerIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	}
	[contentTable selectRowAtIndexPath:currentViewControllerIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone]; // select Overview
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (tableView == headerTable)
		return 1;
	
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == headerTable)
		return 1;
	
	if (section == 0)
		return 4;
	else if (section == 1) {
		TMVillage *village = [storage account].village;
		int count = 0;
		if (village.movements && [village.movements count] > 0)
			count += [village.movements count];
		if (village.constructions)
			count += [village.constructions count];
		
		return count;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *BasicCellIdentifier = @"Basic";
	static NSString *BasicSelectableCellIdentifier = @"BasicSelectable";
	static UIImage *overviewImage;
	static UIImage *resourcesImage;
	static UIImage *troopsImage;
	static UIImage *buildingsImage;
	static UIImage *villagesImage;
	
	if (!overviewImage) {
		overviewImage = [UIImage imageNamed:@"53-house.png"];
		resourcesImage = [UIImage imageNamed:@"48-fork-and-knife.png"];
		troopsImage = [UIImage imageNamed:@"115-bow-and-arrow.png"];
		buildingsImage = [UIImage imageNamed:@"177-building.png"];
		villagesImage = [UIImage imageNamed:@"60-signpost.png"];
	}
	
	if (tableView == headerTable) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier forIndexPath:indexPath];
		cell.textLabel.text = @"Villages";
		cell.imageView.image = villagesImage;
		
		[AppDelegate setDarkCellAppearance:cell forIndexPath:indexPath];
		
		return cell;
	}
	
	// contentTable
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BasicSelectableCellIdentifier forIndexPath:indexPath];
	NSString *text;
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				text = @"Overview";
				cell.imageView.image = overviewImage;
				break;
			case 1:
				text = @"Resources";
				cell.imageView.image = resourcesImage;
				break;
			case 2:
				text = @"Troops";
				cell.imageView.image = troopsImage;
				break;
			case 3:
				text = @"Buildings";
				cell.imageView.image = buildingsImage;
				break;
		}
	} else {
		// Movements & constructions section / events
		TMVillage *village = [storage account].village;
		if (village.movements && [village.movements count] > 0 && indexPath.row < [village.movements count]) {
			text = [(TMMovement *)[village.movements objectAtIndex:indexPath.row] name];
		} else {
			int row = indexPath.row;
			if (village.movements)
				row -= village.movements.count;
			
			text = [(TMConstruction *)[village.constructions objectAtIndex:row] name];
		}
	}
	
	cell.textLabel.text = text;
	
	[AppDelegate setDarkCellAppearance:cell forIndexPath:indexPath];
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 11) {
		return @"Sections";
	}
	
	return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	TMVillagePanelViewController *panel = [TMVillagePanelViewController sharedInstance];
	UIViewController *newVC = nil;
	NSIndexPath *path = indexPath;
	
	if (tableView == headerTable) {
		[self.sidePanelController showCenterPanelAnimated:YES];
		
		// Hide the modal when the sidePanel shows center panel.. animation takes 0.2s
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
			[self dismissViewControllerAnimated:YES completion:nil];
		});
		
		firstTime = true;
		return;
	} else if (indexPath.section == 0) {
		if (indexPath.row == 0)
			newVC = [panel villageOverview];
		else if (indexPath.row == 1)
			newVC = [panel villageResources];
		else if (indexPath.row == 2)
			newVC = [panel villageTroops];
		else
			newVC = [panel villageBuildings];
	} else {
		// Movements & constructions / events
		newVC = [panel villageOverview];
		path = [NSIndexPath indexPathForRow:0 inSection:0];
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		[tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
	
	currentViewController = newVC;
	currentViewControllerIndexPath = path;
	[self.sidePanelController setCenterPanel:newVC];
}

@end
