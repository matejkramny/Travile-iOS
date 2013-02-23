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

#import "TMVillageOpenBuildingViewController.h"
#import "TMBuilding.h"
#import "TMResources.h"
#import "TMBuildingMap.h"
#import "TMStorage.h"
#import "TMAccount.h"
#import "TMVillage.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "TMBuildingAction.h"
#import "TMVillageResearchViewController.h"
#import "TMBarracks.h"
#import "TMStable.h"
#import "TMTroop.h"
#import "TMVillageBarracksCell.h"

@interface TMVillageOpenBuildingViewController () {
	TMBuildingMap *buildingMap;
	TMBuilding *selectedBuilding;
	TMBuildingAction *selectedAction;
	NSArray *sections;
	NSArray *sectionTitles;
	NSArray *sectionFooters;
	NSArray *sectionCellTypes; // Section types
	NSIndexPath *buildActionIndexPath;
	int researchActionSection;
	int barracksSection;
	MBProgressHUD *HUD;
	UITapGestureRecognizer *tapToHide;
	UITapGestureRecognizer *tapToHideKeyboard;
}

- (void)buildSections;
- (void)reloadSelectedBuilding;
- (void)tappedToHide:(id)sender;
- (void)tappedToHideKeyboard:(id)sender;

@end

@implementation TMVillageOpenBuildingViewController
@synthesize buildings;
@synthesize otherBuildings;
@synthesize isBuildingSiteAvailableBuilding;

static NSString *rightDetailCellID = @"RightDetail";
static NSString *basicSelectableCellID = @"BasicSelectable";
static NSString *basicCellID = @"Basic";
static NSString *barracksCellID = @"Barracks";

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
	
	[[self tableView] setBackgroundView:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (!selectedBuilding) {
		selectedBuilding = [buildings objectAtIndex:0];
		[self buildSections];
		[self.tableView reloadData];
	}
	
	[[self navigationItem] setTitle:[selectedBuilding name]];
	
	if (!isBuildingSiteAvailableBuilding) {
		[self setRefreshControl:[[UIRefreshControl alloc] init]];
		[[self refreshControl] addTarget:self action:@selector(didBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	}
	
	tapToHideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToHideKeyboard:)];
	[self.tableView addGestureRecognizer:tapToHideKeyboard];
	[tapToHideKeyboard setNumberOfTapsRequired:1];
	[tapToHideKeyboard setNumberOfTouchesRequired:1];
	[tapToHideKeyboard setCancelsTouchesInView:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[self delegate] phvOpenBuildingViewController:self didCloseBuilding:selectedBuilding];
		
	tapToHideKeyboard = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)buildSections {
	NSMutableArray *secs = [[NSMutableArray alloc] init];
	NSMutableArray *titles = [[NSMutableArray alloc] init];
	NSMutableArray *footers = [[NSMutableArray alloc] init];
	NSMutableArray *types = [[NSMutableArray alloc] init];
	
	[secs addObject:[NSArray array]]; // BuildingMap section
	[titles addObject:[NSNull null]]; // no title..
	[footers addObject:@""]; // no footer..
	[types addObject:[NSNull null]]; // Never used
	
	bool buildingSite = [selectedBuilding level] == 0 && (([selectedBuilding page] & TPVillage) != 0) && !selectedBuilding.isBeingUpgraded && !isBuildingSiteAvailableBuilding;
	
	if (buildingSite) {
		// List available buildings
		if ([selectedBuilding availableBuildings].count > 0) {
			NSMutableArray *upgradeable = [[NSMutableArray alloc] init];
			NSMutableArray *nonupgradeable = [[NSMutableArray alloc] init];
			
			for (TMBuilding *b in selectedBuilding.availableBuildings) {
				if (b.upgradeURLString)
					[upgradeable addObject:b.name];
				else
					[nonupgradeable addObject:b.name];
			}
			
			if (upgradeable.count > 0) {
				[secs addObject:[upgradeable copy]];
				[titles addObject:@"Available Buildings"];
				[footers addObject:@"Select a building to open it."];
				[types addObject:basicSelectableCellID];
			}
			
			if (nonupgradeable.count > 0) {
				[secs addObject:[nonupgradeable copy]];
				[titles addObject:@"Unavailable Buildings"];
				[footers addObject:@"These buildings cannot be built because they have unmet requirements"];
				[types addObject:basicSelectableCellID];
			}
		} else {
			[secs addObject:@"No buildings available"];
			[titles addObject:@"Buildings"];
			[footers addObject:@""];
			[types addObject:basicCellID];
		}
	} else {
		// Details
		[secs addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", [selectedBuilding level]], @"Level", nil]]; // level
		[titles addObject:@"Details"];
		[footers addObject:selectedBuilding.description != nil ? selectedBuilding.description : @""];
		[types addObject:rightDetailCellID];
		
		// Properties
		if ([[selectedBuilding properties] count] > 0) {
			[secs addObject:[selectedBuilding properties]];
			[titles addObject:@"Properties"];
			[footers addObject:@""];
			[types addObject:rightDetailCellID];
		}
		
		// Resources
		if ([selectedBuilding resources]) {
			TMResources *res = [selectedBuilding resources];
			[secs addObject:@{ @"Wood" : [NSString stringWithFormat:@"%d", (int)res.wood],
			 @"Clay" : [NSString stringWithFormat:@"%d", (int)res.clay],
			 @"Iron" : [NSString stringWithFormat:@"%d", (int)res.iron],
			 @"Wheat" : [NSString stringWithFormat:@"%d", (int)res.wheat]
			 }];
			
			if (isBuildingSiteAvailableBuilding)
				[titles addObject:NSLocalizedString(@"Resources required build", @"Resources required to build")];
			else
				[titles addObject:NSLocalizedString(@"Resources required", @"Resources required to upgrade building to next level")];
			
			if ([[selectedBuilding.parent resources] hasMoreResourcesThanResource:selectedBuilding.resources])
				[footers addObject:@"You have enough resources"];
			else
				[footers addObject:@"You do not have enough resources"];
			
			[types addObject:rightDetailCellID];
		}
		
		// Actions
		if ([[selectedBuilding actions] count] > 0) {
			NSMutableArray *strings = [[NSMutableArray alloc] initWithCapacity:[selectedBuilding.actions count]];
			for (TMBuildingAction *action in selectedBuilding.actions) {
				[strings addObject:action.name];
			}
			
			[secs addObject:strings];
			[titles addObject:@"Research"];
			[footers addObject:@""];
			[types addObject:basicSelectableCellID];
			
			researchActionSection = [secs count]-1;
		}
		
		// Special building actions
		// Barracks
		if ([selectedBuilding isKindOfClass:[TMBarracks class]]) {
			TMBarracks *barracks = (TMBarracks *)selectedBuilding;
			
			if (barracks.researching && barracks.researching.count > 0) {
				[secs addObject:barracks.researching];
				[titles addObject:@"Training"];
				[footers addObject:@"These troops are being trained"];
				[types addObject:rightDetailCellID];
			}
			
			if (barracks.troops && barracks.troops.count > 0) {
				NSMutableArray *sec = [[NSMutableArray alloc] initWithCapacity:barracks.troops.count+1]; // +1 for 'Train' button
				for (TMTroop *troop in barracks.troops) {
					[sec addObject:troop];
				}
				[sec addObject:@"Train"];
				
				[secs addObject:[sec copy]];
				[titles addObject:@"Train troops"];
				[footers addObject:@""];
				[types addObject:barracksCellID];
				
				barracksSection = [secs count]-1;
			}
		}
		
		// Conditions
		if ([[selectedBuilding buildConditionsDone] count] > 0) {
			[secs addObject:selectedBuilding.buildConditionsDone];
			[titles addObject:@"Accomplished build conditions"];
			[footers addObject:@""];
			[types addObject:basicCellID];
		}
		if ([[selectedBuilding buildConditionsError] count] > 0) {
			[secs addObject:selectedBuilding.buildConditionsError];
			[titles addObject:@"Build conditions"];
			[footers addObject:@"Upgrade buildings listed in order to build"];
			[types addObject:basicCellID];
		}
		if ([selectedBuilding cannotBuildReason] != nil) {
			[secs addObject:selectedBuilding.cannotBuildReason];
			[titles addObject:@"Cannot build"];
			[footers addObject:@""];
			[types addObject:basicCellID];
		}
		
		// Buttons
		if ([[selectedBuilding buildConditionsError] count] == 0 && ![selectedBuilding cannotBuildReason]) {
			if (isBuildingSiteAvailableBuilding) {
				if (selectedBuilding.upgradeURLString) {
					[secs addObject:[NSString stringWithFormat:NSLocalizedString(@"Build", @"Build building site object"), selectedBuilding.name]];
					[titles addObject:@"Build"];
					[footers addObject:@""];
					[types addObject:basicSelectableCellID];
					buildActionIndexPath = [NSIndexPath indexPathForRow:0 inSection:[secs count]-1];
				}
			} else {
				// Upgrade button
				[secs addObject:[NSString stringWithFormat:@"Upgrade to level %d", [selectedBuilding level]+1]];
				[titles addObject:@"Actions"];
				[footers addObject:@""];
				[types addObject:basicSelectableCellID];
				buildActionIndexPath = [NSIndexPath indexPathForRow:0 inSection:[secs count]-1];
			}
		}
	}
	
	sections = [secs copy];
	sectionTitles = [titles copy];
	sectionFooters = [footers copy];
	sectionCellTypes = [types copy];
}

- (void)reloadSelectedBuilding {
	[selectedBuilding addObserver:self forKeyPath:[selectedBuilding finishedLoadingKVOIdentifier] options:NSKeyValueObservingOptionNew context:nil];
	[selectedBuilding fetchDescription];
	
	HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	HUD.labelText = @"Loading";
	HUD.detailsLabelText = @"Tap to hide";
	tapToHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToHide:)];
	[HUD addGestureRecognizer:tapToHide];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"OpenResearch"]) {
		TMVillageResearchViewController *rvc = segue.destinationViewController;
		rvc.action = selectedAction;
	}
}

- (void)tappedToHide:(id)sender {
	[HUD hide:YES];
	[HUD removeGestureRecognizer:tapToHide];
	tapToHide = nil;
	
	[selectedBuilding removeObserver:self forKeyPath:[selectedBuilding finishedLoadingKVOIdentifier]];
}

- (void)tappedToHideKeyboard:(id)sender {
	[self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self.view endEditing:YES];
}

#pragma mark refreshControl did begin refreshing

- (void)didBeginRefreshing:(id)sender {
	[self reloadSelectedBuilding];
	[[self refreshControl] endRefreshing];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	id sec = [sections objectAtIndex:indexPath.section];

	if (indexPath.section == barracksSection && [selectedBuilding isKindOfClass:[TMBarracks class]]) {
		if ([[sec objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
			// Train button
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:basicSelectableCellID];
			cell.textLabel.text = @"Train";
			return cell;
		} else {
			TMVillageBarracksCell *cell = [tableView dequeueReusableCellWithIdentifier:barracksCellID];
			TMTroop *troop = [sec objectAtIndex:indexPath.row];
			if (cell == nil) {
				cell = [[TMVillageBarracksCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:barracksCellID];
			}
			cell.troop = troop;
			
			[cell configure];
			
			return cell;
		}
	}
	
	UITableViewCell *cell;
	if ([sec isKindOfClass:[NSString class]]) {
		cell = [tableView dequeueReusableCellWithIdentifier:[sectionCellTypes objectAtIndex:indexPath.section]];
		cell.textLabel.text = sec;
	} else if ([sec isKindOfClass:[NSArray class]]) {
		cell = [tableView dequeueReusableCellWithIdentifier:[sectionCellTypes objectAtIndex:indexPath.section]];
		cell.textLabel.text = [sec objectAtIndex:indexPath.row];
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:[sectionCellTypes objectAtIndex:indexPath.section]];
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
			buildingMap = [[TMBuildingMap alloc] initWithBuildings:buildings hideBuildings:otherBuildings];
			
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == barracksSection && [selectedBuilding isKindOfClass:[TMBarracks class]] && [[[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isKindOfClass:[TMTroop class]]) {
		return 90.0f;
	}
	
	return 44.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (selectedBuilding.level == 0 && selectedBuilding.page & TPVillage && !isBuildingSiteAvailableBuilding) {
		// Building site. Click to first or second section opens a building
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
		TMVillageOpenBuildingViewController *ob = (TMVillageOpenBuildingViewController *)[storyboard instantiateViewControllerWithIdentifier:@"openBuildingView"];
		
		ob.delegate = self;
		
		TMBuilding *building;
		NSString *name = [[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		for (TMBuilding *b in selectedBuilding.availableBuildings) {
			if ([b.name isEqualToString:name]) {
				building = b;
				break;
			}
		}
		
		if (!building) return;
		
		building.coordinates = selectedBuilding.coordinates;
		ob.buildings = @[ building ];
		
		NSMutableArray *others = [[NSMutableArray alloc] initWithArray:otherBuildings];
		others = [[others arrayByAddingObjectsFromArray:buildings] mutableCopy];
		[others removeObjectIdenticalTo:selectedBuilding];
		
		ob.otherBuildings = others;
		ob.isBuildingSiteAvailableBuilding = YES;
		
		[[self navigationController] pushViewController:ob animated:YES];
	} else if ([indexPath compare:buildActionIndexPath] == NSOrderedSame) {
		// Build
		[[self delegate] phvOpenBuildingViewController:self didBuildBuilding:selectedBuilding];
		
		[[self navigationController] popViewControllerAnimated:YES];
	} else if (researchActionSection > 0 && indexPath.section == researchActionSection) {
		// Push view controller for research
		selectedAction = [[selectedBuilding actions] objectAtIndex:indexPath.row];
		[self performSegueWithIdentifier:@"OpenResearch" sender:self];
	} else if (barracksSection == indexPath.section && [[[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
		// Train button
		if ([(TMBarracks *)selectedBuilding train]) {
			[self reloadSelectedBuilding];
		}
		
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	}
}

#pragma mark - BuildingMapDelegate

- (void)buildingMapSelectedIndexOfBuilding:(NSInteger)index {
	selectedBuilding = [buildings objectAtIndex:index];
	bool buildingSite = selectedBuilding.level == 0 && selectedBuilding.page & TPVillage && !selectedBuilding.isBeingUpgraded;
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
	if (object == selectedBuilding && [keyPath isEqualToString:[selectedBuilding finishedLoadingKVOIdentifier]]) {
		[selectedBuilding removeObserver:self forKeyPath:[selectedBuilding finishedLoadingKVOIdentifier]];
		[self buildSections];
		[self.tableView reloadData];
		[HUD hide:YES];
		[HUD removeGestureRecognizer:tapToHide];
		tapToHide = nil;
	}
}

#pragma mark - PHVOpenBuildingDelegate

- (void)phvOpenBuildingViewController:(TMVillageOpenBuildingViewController *)controller didBuildBuilding:(TMBuilding *)building {
	[building buildFromURL:[[TMStorage sharedStorage].account urlForString:building.upgradeURLString]];
}

- (void)phvOpenBuildingViewController:(TMVillageOpenBuildingViewController *)controller didCloseBuilding:(TMBuilding *)building {
	
}

@end
