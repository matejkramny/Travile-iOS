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
	NSArray *selectedBuildings;
	NSArray *otherBuildings;
	MBProgressHUD *HUD;
	NSArray *sections;
	bool openBuilding;
	UITapGestureRecognizer *tapToCancel;
	UITapGestureRecognizer *tapToHide;
}

- (void)loadBuildingsToSections;
- (Building *)getBuildingUsingIndexPath:(NSIndexPath *)indexPath;
- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event;
- (void)tappedToCancel:(id)sender;
- (void)tappedToHide:(id)sender;

@end

@implementation PHVBuildingsViewController

@synthesize refreshControl;

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
	
	account = [[Storage sharedStorage] account];
	
	[self loadBuildingsToSections];
	
	refreshControl = [AppDelegate addRefreshControlTo:self.tableView target:self action:@selector(didBeginRefreshing:)];
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
	
	[self loadBuildingsToSections];
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadBuildingsToSections {
	NSArray *buildings = [[account village] buildings];
	NSMutableDictionary *sec1 = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *sec2 = [[NSMutableDictionary alloc] init];
	NSMutableArray *sec3 = [[NSMutableArray alloc] init]; // secX = sectionX
	
	for (int i = 0; i < [buildings count]; i++) {
		Building *b = [buildings objectAtIndex:i];
		
		if (([b page] & TPResources) != 0) {
			// Add to section 1
			if ([sec1 objectForKey:b.name])
				[[sec1 objectForKey:b.name] addObject:b];
			else
				[sec1 setObject:[[NSMutableArray alloc] initWithObjects:b, nil] forKey:b.name];
			
			continue;
		} else {
			// Add to section 2 or 3
			if ([b level] == 0 && !b.isBeingUpgraded) {
				// Add to section 3
				[sec3 addObject:b];
				continue;
			}
			
			if ([sec2 objectForKey:b.name])
				[[sec2 objectForKey:b.name] addObject:b];
			else
				[sec2 setObject:[[NSMutableArray alloc] initWithObjects:b, nil] forKey:b.name];
		}
	}
	
	NSMutableArray *(^convertDictionaryToArray)(NSDictionary *) = ^(NSDictionary *dict) {
		NSMutableArray *ar = [[NSMutableArray alloc] init];
		for (NSString *key in dict) {
			NSMutableArray *ma = [dict objectForKey:key];
			
			if ([ma count] > 1) {
				// Leave the array
				[ar addObject:ma];
			} else
				[ar addObject:[ma objectAtIndex:0]];
		}
		
		return ar;
	};
	
	NSMutableArray *sec1s = convertDictionaryToArray(sec1);
	NSMutableArray *sec2s = convertDictionaryToArray(sec2);
	
	// Sort the buildings by name
	NSComparisonResult (^compareBuildings)(id a, id b) = ^NSComparisonResult(id a, id b) {
		NSString *first;
		NSString *second;
		
		if ([a isKindOfClass:[NSArray class]])
			first = [(Building *)[(NSArray *)a objectAtIndex:0] name];
		else
			first = [(Building *)a name];
		
		if ([b isKindOfClass:[NSArray class]])
			second = [(Building *)[(NSArray *)b objectAtIndex:0] name];
		else
			second = [(Building *)b name];
		
		return [first compare:second];
	};
	
	sec1s = [[sec1s sortedArrayUsingComparator:compareBuildings] mutableCopy];
	sec2s = [[sec2s sortedArrayUsingComparator:compareBuildings] mutableCopy];
	
	sections = @[ sec1s, sec2s, [[NSMutableArray alloc] initWithObjects:sec3, nil] ];
}

- (Building *)getBuildingUsingIndexPath:(NSIndexPath *)indexPath {
	return [[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

- (void)didBeginRefreshing:(id)sender {
	[account addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
	
	[account refreshAccountWithMap:ARVillage];
}

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event {
	NSLog(@"Accessory button tapped?");
}

- (void)tappedToCancel:(id)sender {
	[HUD hide:YES];
	[HUD removeGestureRecognizer:tapToCancel];
	tapToCancel = nil;
	
	[[selectedBuildings objectAtIndex:0] removeObserver:self forKeyPath:@"finishedLoading"];
	
	NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
	if (selectedPath)
		[self.tableView deselectRowAtIndexPath:selectedPath animated:YES];
}

- (void)tappedToHide:(id)sender {
	[HUD hide:YES];
	[HUD removeGestureRecognizer:tapToHide];
	tapToHide = nil;
	
	[[selectedBuildings objectAtIndex:0] removeObserver:self forKeyPath:@"finishedLoading"];
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
	static NSString *BuildingSiteCellID = @"RightDetailBuildingSite";
	
	UITableViewCell *cell;
	if ([[[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isKindOfClass:[NSArray class]]) {
		NSArray *arr = [[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		
		cell = [tableView dequeueReusableCellWithIdentifier:BuildingSiteCellID];
		cell.textLabel.text = [NSString stringWithFormat:@"%@s", [[arr objectAtIndex:0] name]];
	} else {
		Building *b = [self getBuildingUsingIndexPath:indexPath];
		
		cell = [tableView dequeueReusableCellWithIdentifier:BuildingSiteCellID];
		cell.textLabel.text = [b name];
	}
	
	[AppDelegate setCellAppearance:cell forIndexPath:indexPath];
	
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
	void (^setOtherBuildings)(void) = ^ {
		NSMutableArray *otherBuildings_temp = [[sections objectAtIndex:indexPath.section] mutableCopy];
		[otherBuildings_temp removeObjectAtIndex:indexPath.row];
		otherBuildings = (NSArray *)otherBuildings_temp;
		if (indexPath.section == 1) {
			// Section 2. merge section 3 here too
			otherBuildings = [otherBuildings arrayByAddingObjectsFromArray:[sections objectAtIndex:indexPath.section+1]];
		} else if (indexPath.section == 2) {
			// Section 3. Merge section 2
			otherBuildings = [otherBuildings arrayByAddingObjectsFromArray:[sections objectAtIndex:indexPath.section-1]];
		}
	};
	
	if ([[[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isKindOfClass:[NSArray class]]) {
		selectedBuildings = [[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	} else {
		selectedBuildings = @[ [[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] ];
	}
	
	setOtherBuildings();
	Building *b = [selectedBuildings objectAtIndex:0];
	// Check if we need to load the building
	bool buildingSite = b.level == 0 && b.page & TPVillage && !b.isBeingUpgraded;
	if ((!b.description && !buildingSite) || (buildingSite && !b.availableBuildings)) {
		openBuilding = true;
		[b addObserver:self forKeyPath:@"finishedLoading" options:NSKeyValueObservingOptionNew context:nil];
		[b fetchDescription];
		HUD = [MBProgressHUD showHUDAddedTo:self.tabBarController.navigationController.view animated:YES];
		HUD.labelText = @"Loading";
		HUD.detailsLabelText = @"Tap to cancel";
		tapToCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToCancel:)];
		[HUD addGestureRecognizer:tapToCancel];
	} else {
		// Continue
		[self performSegueWithIdentifier:@"OpenBuilding" sender:self];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"finishedLoading"]) {
		if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue]) {
			[[selectedBuildings objectAtIndex:0] removeObserver:self forKeyPath:@"finishedLoading"];
			
			[HUD hide:YES];
			[HUD removeGestureRecognizer:tapToCancel];
			tapToCancel = nil;
			
			if (openBuilding)
				[self performSegueWithIdentifier:@"OpenBuilding" sender:self];
			else
				[[self tableView] deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
		}
	} else if (object == account && [keyPath isEqualToString:@"status"]) {
		if (([[change objectForKey:NSKeyValueChangeNewKey] intValue] & ARefreshed) != 0) {
			// Refreshed
			[account removeObserver:self forKeyPath:@"status"];
			[refreshControl endRefreshing];
			[[self tableView] reloadData];
		}
	}
}

#pragma mark Prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	NSString *iden = [segue identifier];
	
	if ([iden isEqualToString:@"OpenBuilding"]) {
		PHVOpenBuildingViewController *vc = [segue destinationViewController];
		
		vc.delegate = self;
		vc.buildings = selectedBuildings;
		
		vc.otherBuildings = otherBuildings;
	}
}

#pragma mark - PHVOpenBuildingDelegate

- (void)phvOpenBuildingViewController:(PHVOpenBuildingViewController *)controller didCloseBuilding:(Building *)building {
	NSLog(@"Closed building %@", [building name]);
}

- (void)phvOpenBuildingViewController:(PHVOpenBuildingViewController *)controller didBuildBuilding:(Building *)building {
	NSLog(@"Built building %@ to level %d", [building name], [building level]);
	[controller.navigationController popViewControllerAnimated:YES];
	
	selectedBuildings = @[ building ];
	[[selectedBuildings objectAtIndex:0] addObserver:self forKeyPath:@"finishedLoading" options:NSKeyValueObservingOptionNew context:nil];
	openBuilding = false;
	[[selectedBuildings objectAtIndex:0] buildFromAccount:account];
	
	HUD = [MBProgressHUD showHUDAddedTo:self.tabBarController.navigationController.view animated:YES];
	HUD.labelText = @"Building";
	HUD.detailsLabelText = @"Tap to hide";
	tapToHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToHide:)];
	[HUD addGestureRecognizer:tapToHide];
}

@end
