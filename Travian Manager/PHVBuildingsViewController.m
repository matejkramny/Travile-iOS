//
//  PHVBuildingsViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 29/07/2012.
//
//

#import "PHVBuildingsViewController.h"
#import "Account.h"
#import "AppDelegate.h"
#import "Storage.h"
#import "Village.h"
#import "Building.h"
#import "MBProgressHUD.h"

@interface PHVBuildingsViewController () {
	Account *account;
	Building *selectedBuilding;
	MBProgressHUD *HUD;
	NSArray *sections;
}

- (void)loadBuildingsToSections;
- (Building *)getBuildingUsingIndexPath:(NSIndexPath *)indexPath;

@end

@implementation PHVBuildingsViewController

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
	account = [[appDelegate storage] account];
	
	[self loadBuildingsToSections];
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
	
	[self.tabBarController setTitle:[NSString stringWithFormat:@"Buildings"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadBuildingsToSections {
	NSArray *buildings = [[account village] buildings];
	NSMutableArray *sec1 = [[NSMutableArray alloc] init];
	NSMutableArray *sec2 = [[NSMutableArray alloc] init];
	NSMutableArray *sec3 = [[NSMutableArray alloc] init]; // secX = sectionX
	
	for (int i = 0; i < [buildings count]; i++) {
		Building *b = [buildings objectAtIndex:i];
		
		NSMutableArray *sec __weak; // temporary secX holder
		
		if (([b page] & TPResources) != 0) {
			// Add to section 1
			sec = sec1;
		} else {
			// Add to section 2 or 3
			sec = sec2;
			if ([b level] == 0) {
				// Add to section 3
				sec = sec3;
			}
		}
		
		[sec addObject:b];
	}
	
	// Sort the buildings by name
	NSComparisonResult (^compareBuildings)(id a, id b) = ^NSComparisonResult(id a, id b) {
		NSString *first = [(Building *)a name];
		NSString *second = [(Building *)b name];
		return [first compare:second];
	};
	
	sec1 = [[sec1 sortedArrayUsingComparator:compareBuildings] mutableCopy];
	sec2 = [[sec2 sortedArrayUsingComparator:compareBuildings] mutableCopy];
	
	sections = @[ sec1, sec2, sec3 ];
}

- (Building *)getBuildingUsingIndexPath:(NSIndexPath *)indexPath {
	return [[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[sections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	Building *b = [self getBuildingUsingIndexPath:indexPath];
	
	static NSString *RightDetailCellID = @"RightDetail";
	static NSString *BuildingSiteCellID = @"RightDetailBuildingSite";
	UITableViewCell *cell;
	
	if (indexPath.section == 0 || indexPath.section == 1) {
		cell = [tableView dequeueReusableCellWithIdentifier:RightDetailCellID];
		cell.textLabel.text = [b name];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"level %d", [b level]];
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:BuildingSiteCellID];
		cell.textLabel.text = [b name];
	}
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Resource fields";
		case 1:
			return @"Village buildings";
		case 2:
			return @"Building sites";
		default:
			return @"";
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Build
	selectedBuilding = [self getBuildingUsingIndexPath:indexPath];
	[selectedBuilding addObserver:self forKeyPath:@"finishedLoading" options:NSKeyValueObservingOptionNew context:nil];
	[selectedBuilding buildFromAccount:account];
	HUD = [MBProgressHUD showHUDAddedTo:self.tabBarController.navigationController.view animated:YES];
	HUD.labelText = @"Building";
	
	[[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == selectedBuilding && [keyPath isEqualToString:@"finishedLoading"]) {
		// Show modal view of available buildings
		if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue]) {
			[selectedBuilding removeObserver:self forKeyPath:@"finishedLoading"];
			[HUD hide:YES];
			
			if ([selectedBuilding availableBuildings]) {
				NSLog(@"Available buildings: %d", [[selectedBuilding availableBuildings] count]);
				[self performSegueWithIdentifier:@"BuildingList" sender:self];
			}
		}
	} else if (object == selectedBuilding && [keyPath isEqualToString:@"description"]) {
		[HUD hide:YES];
		[self performSegueWithIdentifier:@"OpenBuilding" sender:self];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	// View Building in detail
	selectedBuilding = [self getBuildingUsingIndexPath:indexPath];
	if ([selectedBuilding description] == nil && !([selectedBuilding level] == 0 && (([selectedBuilding page] & TPVillage) != 0))) {
		[selectedBuilding addObserver:self forKeyPath:@"description" options:NSKeyValueObservingOptionNew context:nil];
		HUD = [MBProgressHUD showHUDAddedTo:self.tabBarController.navigationController.view animated:YES];
		HUD.labelText = @"Fetching Description";
		
		[selectedBuilding fetchDescription];
	} else {
		[self performSegueWithIdentifier:@"OpenBuilding" sender:self];
	}
}

#pragma mark Prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	NSString *iden = [segue identifier];
	
	if ([iden isEqualToString:@"BuildingList"]) {
		UINavigationController *nc = [segue destinationViewController];
		PHVBuildingListViewController *vc = [[nc viewControllers] objectAtIndex:0];
		
		vc.delegate = self;
		vc.buildings = [selectedBuilding availableBuildings];
	} else if ([iden isEqualToString:@"OpenBuilding"]) {
		PHVOpenBuildingViewController *vc = [segue destinationViewController];
		
		vc.delegate = self;
		vc.building = selectedBuilding;
	}
}

#pragma mark - PHVOpenBuildingDelegate

- (void)phvOpenBuildingViewController:(PHVOpenBuildingViewController *)controller didCloseBuilding:(Building *)building {
	NSLog(@"Closed building %@", [building name]);
}

- (void)phvOpenBuildingViewController:(PHVOpenBuildingViewController *)controller didBuildBuilding:(Building *)building {
	NSLog(@"Built building %@ to level %d", [building name], [building level]);
	[controller.navigationController popViewControllerAnimated:YES];
	
	selectedBuilding = building;
	[selectedBuilding addObserver:self forKeyPath:@"finishedLoading" options:NSKeyValueObservingOptionNew context:nil];
	[selectedBuilding buildFromAccount:account];
	HUD = [MBProgressHUD showHUDAddedTo:self.tabBarController.navigationController.view animated:YES];
	HUD.labelText = @"Building";
}

#pragma mark - PHVBuildingListDelegate

- (void)phvBuildingListViewController:(PHVBuildingListViewController *)controller didSelectBuilding:(Building *)building {
	if ([building upgradeURLString] == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot build" message:[NSString stringWithFormat:@"Cannot build %@ because %@", [building name], [building cannotBuildReason]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
	}
	else
		[selectedBuilding buildFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@.travian.%@/%@", account.world, account.server, [building upgradeURLString]]]];
}

@end
