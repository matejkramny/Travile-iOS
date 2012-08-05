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
}

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
    return (interfaceOrientation == (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationLandscapeLeft));
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *buildings = [[account village] buildings];
	
	// Filter by section. 0 - res, 1 - village
	int count = 0;
	TravianPages type = section == 0 ? TPResources : TPVillage;
	
	for (Building *b in buildings)
		if (([b page] & type) != 0)
			count++;
	
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RightDetail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	NSArray *buildings = [[account village] buildings];
	Building *b;
	TravianPages type = indexPath.section == 0 ? TPResources : TPVillage;
	int buildingsInSection = 0;
	
	for (Building *building in buildings) {
		if (([building page] & type) != 0) {
			if (buildingsInSection == indexPath.row) {
				b = building;
				break;
			}
			
			buildingsInSection++;
		}
	}
	
	if (!b) {
		NSLog(@"Building not found!");
		return nil;
	}
	
	cell.textLabel.text = b.name;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", b.level];
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 0 ? @"Resource fields" : @"Village buildings";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Build
	
	NSArray *buildings = [[account village] buildings];
	Building *b;
	TravianPages type = indexPath.section == 0 ? TPResources : TPVillage;
	int buildingsInSection = 0;
	
	for (Building *bu in buildings) {
		if (([bu page] & type) != 0) {
			if (buildingsInSection == indexPath.row) {
				b = bu;
				break;
			}
			buildingsInSection++;
		}
	}
	
	if (b) {
		selectedBuilding = b;
		[b addObserver:self forKeyPath:@"finishedLoading" options:NSKeyValueObservingOptionNew context:nil];
		[b buildFromAccount:account];
		HUD = [MBProgressHUD showHUDAddedTo:self.tabBarController.navigationController.view animated:YES];
		HUD.labelText = @"Building";
	}
	
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
	NSArray *buildings = [[account village] buildings];
	Building *b;
	TravianPages type = indexPath.section == 0 ? TPResources : TPVillage;
	int buildingsInSection = 0;
	
	for (Building *bu in buildings) {
		if (([bu page] & type) != 0) {
			if (buildingsInSection == indexPath.row) {
				b = bu;
				break;
			}
			buildingsInSection++;
		}
	}
	
	if (b) {
		selectedBuilding = b;
		if ([selectedBuilding description] == nil && !([selectedBuilding level] == 0 && (([selectedBuilding page] & TPVillage) != 0))) {
			[selectedBuilding addObserver:self forKeyPath:@"description" options:NSKeyValueObservingOptionNew context:nil];
			HUD = [MBProgressHUD showHUDAddedTo:self.tabBarController.navigationController.view animated:YES];
			HUD.labelText = @"Fetching Description";
			
			[selectedBuilding fetchDescription];
		} else {
			[self performSegueWithIdentifier:@"OpenBuilding" sender:self];
		}
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
