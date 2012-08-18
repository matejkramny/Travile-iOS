//
//  PHVOpenBuildingViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 01/08/2012.
//
//

#import "PHVOpenBuildingViewController.h"
#import "Building.h"
#import "Resources.h"
#import "BuildingMap.h"
#import "Storage.h"
#import "Account.h"
#import "Village.h"
#import "MBProgressHUD.h"
#import "ODRefreshControl/ODRefreshControl.h"
#import "AppDelegate.h"

@interface PHVOpenBuildingViewController () {
	BuildingMap *buildingMap;
	Building *selectedBuilding;
	NSArray *sections;
	NSArray *sectionTitles;
	NSArray *sectionFooters;
	MBProgressHUD *HUD;
	ODRefreshControl *refreshControl;
}

- (void)buildSections;
- (void)reloadSelectedBuilding;

@end

@implementation PHVOpenBuildingViewController
@synthesize buildings;
@synthesize otherBuildings;

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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	selectedBuilding = [buildings objectAtIndex:0];
	[self buildSections];
	[self.tableView reloadData];
	[[self navigationItem] setTitle:[selectedBuilding name]];
	refreshControl = [AppDelegate addRefreshControlTo:self.tableView target:self action:@selector(didBeginRefreshing:)];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	refreshControl = nil;
	[[self delegate] phvOpenBuildingViewController:self didCloseBuilding:selectedBuilding];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)buildSections {
	NSMutableArray *secs = [[NSMutableArray alloc] init];
	NSMutableArray *titles = [[NSMutableArray alloc] init];
	NSMutableArray *footers = [[NSMutableArray alloc] init];
	
	[secs addObject:[NSArray array]]; // BuildingMap section
	[titles addObject:[NSNull null]]; // no title..
	[footers addObject:@""]; // no footer..
	
	bool buildingSite = [selectedBuilding level] == 0 && (([selectedBuilding page] & TPVillage) != 0);
	
	if (buildingSite) {
		// List available buildings
		if ([selectedBuilding availableBuildings].count > 0) {
			NSMutableArray *upgradeable = [[NSMutableArray alloc] init];
			NSMutableArray *nonupgradeable = [[NSMutableArray alloc] init];
			
			for (Building *b in selectedBuilding.availableBuildings) {
				if (b.upgradeURLString)
					[upgradeable addObject:b.name];
				else
					[nonupgradeable addObject:b.name];
			}
			
			if (upgradeable.count > 0) {
				[secs addObject:[upgradeable copy]];
				[titles addObject:@"Available Buildings"];
				[footers addObject:@"Select a building to open it."];
			}
			
			if (nonupgradeable.count > 0) {
				[secs addObject:[nonupgradeable copy]];
				[titles addObject:@"Unavailable Buildings"];
				[footers addObject:@"These buildings cannot be built because they have unmet requirements"];
			}
		} else {
			[secs addObject:@"No buildings available"];
			[titles addObject:@"Buildings"];
			[footers addObject:@""];
		}
	} else {
		// Details
		[secs addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", [selectedBuilding level]], @"Level", nil]]; // level
		[titles addObject:@"Details"];
		[footers addObject:selectedBuilding.description != nil ? selectedBuilding.description : @""];
		
		// Properties
		if ([[selectedBuilding properties] count] > 0) {
			[secs addObject:[selectedBuilding properties]];
			[titles addObject:@"Properties"];
			[footers addObject:@""];
		}
		
		// Resources
		if ([selectedBuilding resources]) {
			Resources *res = [selectedBuilding resources];
			[secs addObject:@{ @"Wood" : [NSString stringWithFormat:@"%d", (int)res.wood],
			 @"Clay" : [NSString stringWithFormat:@"%d", (int)res.clay],
			 @"Iron" : [NSString stringWithFormat:@"%d", (int)res.iron],
			 @"Wheat" : [NSString stringWithFormat:@"%d", (int)res.wheat]
			 }];
			
			[titles addObject:NSLocalizedString(@"Resources required", @"Resources required to upgrade building to next level")];
			[footers addObject:@""];
		}
		
		// Upgrade button
		[secs addObject:[NSString stringWithFormat:@"Upgrade to level %d", [selectedBuilding level]+1]];
		[titles addObject:@"Actions"];
		[footers addObject:@""];
	}
	
	sections = [secs copy];
	sectionTitles = [titles copy];
	sectionFooters = [footers copy];
}

- (void)reloadSelectedBuilding {
	[selectedBuilding addObserver:self forKeyPath:@"finishedLoading" options:NSKeyValueObservingOptionNew context:nil];
	[selectedBuilding fetchDescription];
	
	HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	HUD.labelText = @"Loading";
}

#pragma mark refreshControl did begin refreshing

- (void)didBeginRefreshing:(id)sender {
	[self reloadSelectedBuilding];
	[refreshControl endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id sec = [sections objectAtIndex:section];
	
	if ([sec isKindOfClass:[NSString class]])
		return 1;
	
    return [sec count];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

static NSString *rightDetailCellID = @"RightDetail";
static NSString *basicSelectableCellID = @"BasicSelectable";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	id sec = [sections objectAtIndex:indexPath.section];
	
	UITableViewCell *cell;
	if ([sec isKindOfClass:[NSString class]]) {
		cell = [tableView dequeueReusableCellWithIdentifier:basicSelectableCellID];
		cell.textLabel.text = sec;
	} else if ([sec isKindOfClass:[NSArray class]]) {
		cell = [tableView dequeueReusableCellWithIdentifier:basicSelectableCellID];
		cell.textLabel.text = [sec objectAtIndex:indexPath.row];
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:rightDetailCellID];
		NSString *key = [[(NSDictionary *)sec allKeys] objectAtIndex:indexPath.row];
		cell.textLabel.text = key;
		cell.detailTextLabel.text = [(NSDictionary *)sec objectForKey:key];
	}
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [sectionTitles objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return [sectionFooters objectAtIndex:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		if (!buildingMap) {
			buildingMap = [[BuildingMap alloc] initWithBuildings:buildings hideBuildings:otherBuildings];
			
			buildingMap.delegate = self;
			buildingMap.backgroundColor = [UIColor clearColor];
		}
		
		return buildingMap;
	}
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0)
		return 185.0f;
	
	return 44.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1 || indexPath.section == 2) {
		// Build button
		[[self delegate] phvOpenBuildingViewController:self didBuildBuilding:selectedBuilding];
	}
}

#pragma mark - BuildingMapDelegate

- (void)buildingMapSelectedIndexOfBuilding:(NSInteger)index {
	selectedBuilding = [buildings objectAtIndex:index];
	bool buildingSite = selectedBuilding.level == 0 && selectedBuilding.page & TPVillage;
	if ((buildingSite && !selectedBuilding.availableBuildings) || (!buildingSite && ![selectedBuilding description])) {
		// Fetch
		[self reloadSelectedBuilding];
		
		return;
	}
	
	[self buildSections];
	[self.tableView reloadData];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == selectedBuilding && [keyPath isEqualToString:@"finishedLoading"]) {
		[selectedBuilding removeObserver:self forKeyPath:@"finishedLoading"];
		[self buildSections];
		[self.tableView reloadData];
		[HUD hide:YES];
	}
}

@end
