//
//  PHVBuildingListViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 01/08/2012.
//
//

#import "PHVBuildingListViewController.h"
#import "Building.h"

@interface PHVBuildingListViewController () {
	Building *selectedBuilding;
}

- (int)getNonUpgradeableBuildings;

@end

@implementation PHVBuildingListViewController

@synthesize delegate, buildings;

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
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	PHVOpenBuildingViewController *vc = [segue destinationViewController];
	[[vc navigationItem] setPrompt:@"Nothing built on this location"];
	vc.delegate = self;
	vc.building = selectedBuilding;
}

- (int)getNonUpgradeableBuildings {
	int nonupgradeable = 0;
	for (Building *b in buildings) {
		if ([b upgradeURLString] == nil) {
			// Non-upgradeable
			nonupgradeable++;
		}
	}
	
	return nonupgradeable;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	int nonupgradeable = [self getNonUpgradeableBuildings];
	
	if (nonupgradeable == [buildings count] || nonupgradeable == 0) {
		// If all buildings are non-upgradeable or no upgradeable buildings
		return 1;
	} else
		return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int nonupgradeable = [self getNonUpgradeableBuildings];
	
	// No upgradeable buildings or section=section for unupgradeable buildings
	if ((section == 0 && nonupgradeable == [buildings count]) || section == 1) {
		return nonupgradeable;
	} else {
		return [buildings count] - nonupgradeable;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int nonUpgradeableCount = [self getNonUpgradeableBuildings];
	NSMutableArray *upgradeable = [[NSMutableArray alloc] initWithCapacity:[buildings count] - nonUpgradeableCount];
	NSMutableArray *nonUpgradeable = [[NSMutableArray alloc] initWithCapacity:nonUpgradeableCount];
	
	for (int i = 0; i < [buildings count]; i++) {
		Building *b = [buildings objectAtIndex:i];
		
		if ([b upgradeURLString] == nil) {
			[nonUpgradeable addObject:b];
		} else {
			[upgradeable addObject:b];
		}
	}
	
	UITableViewCell *cell;
	Building *b;
	if ((indexPath.section == 0 && nonUpgradeableCount == [buildings count]) || indexPath.section == 1) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"NonUpBuild"];
		
		b = [nonUpgradeable objectAtIndex:indexPath.row];
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:@"Build"];
		
		b = [upgradeable objectAtIndex:indexPath.row];
	}
	
	cell.textLabel.text = b.name;
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	int nonupgradeable = [self getNonUpgradeableBuildings];
	if ((section == 0 && nonupgradeable == [buildings count]) || section == 1) {
		return @"Non-upgradeable buildings";
	} else {
		return @"";
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int nonupgradeable = [self getNonUpgradeableBuildings];
	if (indexPath.section == 0 && nonupgradeable != [buildings count]) {
		[self dismissViewControllerAnimated:YES completion:nil];
		
		NSMutableArray *upgradeableBuildings = [[NSMutableArray alloc] init];
		for (int i = 0; i < [buildings count]; i++) {
			Building *b = [buildings objectAtIndex:i];
			if ([b upgradeURLString] != nil) {
				[upgradeableBuildings addObject:b];
			}
		}
		
		[[self delegate] phvBuildingListViewController:self didSelectBuilding:[upgradeableBuildings objectAtIndex:indexPath.row]];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	selectedBuilding = [buildings objectAtIndex:indexPath.row];
	[self performSegueWithIdentifier:@"OpenBuilding" sender:self];
}

#pragma mark - PHVOpenBuildingDelegate

- (void)phvOpenBuildingViewController:(PHVOpenBuildingViewController *)controller didCloseBuilding:(Building *)building {}

- (void)phvOpenBuildingViewController:(PHVOpenBuildingViewController *)controller didBuildBuilding:(Building *)building {
	[self dismissViewControllerAnimated:YES completion:nil];
	[[self delegate] phvBuildingListViewController:self didSelectBuilding:building];
}

- (IBAction)cancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

@end
