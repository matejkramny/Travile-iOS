/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMFarmListViewController.h"
#import "TMStorage.h"
#import "TMVillage.h"
#import "TMAccount.h"
#import "TMFarmList.h"
#import "TMFarmListEntry.h"
#import "TMFarmListEntryFarm.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "TMFarmListEntryViewController.h"

@interface TMFarmListViewController () {
	TMStorage *storage;
	TMVillage *village;
	MBProgressHUD *HUD;
	UITapGestureRecognizer *tapToCancel;
	TMFarmListEntry *selectedFarmList;
	
	NSMutableArray *executionQueue;
	bool cancelledExecution;
}

@end

@implementation TMFarmListViewController

static UIBarButtonItem *executeButton;

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
	
	storage = [TMStorage sharedStorage];
	village = [storage.account village];
	self.navigationItem.title = @"Farm Lists";
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(loadFarmLists) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (!executeButton)
		executeButton = [[UIBarButtonItem alloc] initWithTitle:@"Execute" style:UIBarButtonItemStylePlain target:self action:@selector(executeFarmList:)];
	
	self.navigationItem.rightBarButtonItem = executeButton;
	
	[self setExecuteButtonEnabled];
	
	if (village != storage.account.village) {
		// Refresh
		village = storage.account.village;
		[self loadFarmLists];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (village.farmList == nil || village.farmList.loaded == false) {
		if (!village.farmList.loading)
			[self loadFarmLists];
	}
}

- (void)loadFarmLists {
	[self loadFarmLists:YES];
}
- (void)loadFarmLists:(bool)hud {
	if (hud) {
		// Load the farm list.
		HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
		[HUD setLabelText:@"Loading"];
		[HUD setDetailsLabelText:@"Tap to cancel"];
		tapToCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToCancel:)];
		[HUD addGestureRecognizer:tapToCancel];
	}
	
	if (!village.farmList) {
		village.farmList = [[TMFarmList alloc] init];
	}
	[village.farmList loadFarmList:^(void) {
		if (HUD) {
			[HUD hide:YES];
			[HUD removeGestureRecognizer:tapToCancel];
			tapToCancel = nil;
			[self.tableView reloadData];
			
			if ([self.refreshControl isRefreshing])
				[self.refreshControl endRefreshing];
		}
	}];
}

- (void)tappedToCancel:(id)sender {
	[HUD hide:YES];
	[HUD removeGestureRecognizer:tapToCancel];
	tapToCancel = nil;
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.tableView numberOfSections])] withRowAnimation:UITableViewRowAnimationFade];
	
	if ([self.refreshControl isRefreshing])
		[self.refreshControl endRefreshing];
}

- (void)executeFarmList:(id)sender {
	TMFarmListEntry *selectedEntry = nil;
	int selectedEntrySection = 0;
	for (TMFarmListEntry *entry in village.farmList.farmLists) {
		for (TMFarmListEntryFarm *farm in entry.farms) {
			if (farm.selected) {
				selectedEntry = entry;
				goto foundEntry;
			}
		}
		
		selectedEntrySection++;
	}
foundEntry:;
	
	if (selectedEntry) {
		HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
		HUD.labelText = [@"Executing " stringByAppendingString:[selectedEntry name]];
		HUD.detailsLabelText = @"Tap to hide";
		tapToCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToCancel:)];
		[HUD addGestureRecognizer:tapToCancel];
		
		[selectedEntry executeWithCompletion:^{
			[HUD setLabelText:@"Loading Farm List"];
			[self loadFarmLists:NO];
			
			for (TMFarmListEntryFarm *farm in selectedEntry.farms) {
				farm.selected = false;
			}
			
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:selectedEntrySection] withRowAnimation:UITableViewRowAnimationFade];
			[self setExecuteButtonEnabled];
		}];
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return village.farmList.farmLists.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[village.farmList.farmLists objectAtIndex:section] farms] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Basic";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	NSArray *farmList = [[village.farmList.farmLists objectAtIndex:indexPath.section] farms];
	TMFarmListEntryFarm *farm = [farmList objectAtIndex:indexPath.row];
    cell.textLabel.text = farm.targetName;
	cell.accessoryType = farm.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	[AppDelegate setCellAppearance:cell forIndexPath:indexPath];
	
	// long-press to select all
	UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTableViewCellLongPress:)];
	[cell addGestureRecognizer:gesture];
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	TMFarmListEntry *entry = [village.farmList.farmLists objectAtIndex:section];
	return entry.name;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (TMFarmListEntry *entry in village.farmList.farmLists) {
		[array addObject:[[entry.name substringToIndex:1] capitalizedString]];
	}
	
	return array;
}

- (void)handleTableViewCellLongPress:(UILongPressGestureRecognizer *)gesture {
	if (gesture.state != UIGestureRecognizerStateBegan)
		return;
	
	UITableViewCell *cell = (UITableViewCell *)gesture.view;
	NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
	TMFarmListEntry *selectedEntry = [village.farmList.farmLists objectAtIndex:cellIndexPath.section];
	// Toggle all on-or off based on this cell
	TMFarmListEntryFarm *selectedFarm = [[selectedEntry farms] objectAtIndex:cellIndexPath.row];
	bool newState = !selectedFarm.selected;
	
	int i = 0;
	for (TMFarmListEntry *entry in village.farmList.farmLists) {
		bool toBeReloaded = false;
		for (TMFarmListEntryFarm *farm in entry.farms) {
			if (i == cellIndexPath.section) {
				farm.selected = newState;
				toBeReloaded = true;
			} else if (newState == true && farm.selected == true) {
				farm.selected = false;
				toBeReloaded = true;
			}
		}
		
		if (toBeReloaded)
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationFade];
		
		i++;
	}
	
	[self setExecuteButtonEnabled];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"OpenFarmList"]) {
		TMFarmListEntryViewController *entryVC = [segue destinationViewController];
		entryVC.farmList = selectedFarmList;
	}
}

- (void)setExecuteButtonEnabled {
	int selectedCount = 0;
	for (TMFarmListEntry *entry in village.farmList.farmLists) {
		for (TMFarmListEntryFarm *farm in entry.farms) {
			if (farm.selected) {
				selectedCount++;
				goto after;
			}
		}
	}
after:;
	
	if (selectedCount > 0) {
		[executeButton setEnabled:YES];
	} else {
		[executeButton setEnabled:NO];
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int i = 0;
	for (TMFarmListEntry *entry in village.farmList.farmLists) {
		if (i == indexPath.section) {
			i++;
			continue;
		}
		
		bool toBeReloaded = false;
		for (TMFarmListEntryFarm *farm in entry.farms) {
			if (farm.selected) {
				farm.selected = false;
				toBeReloaded = true;
			}
		}
		
		if (toBeReloaded)
			[tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationFade];
		
		i++;
	}
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	TMFarmListEntry *farmList = [village.farmList.farmLists objectAtIndex:indexPath.section];
	TMFarmListEntryFarm *farm = [farmList.farms objectAtIndex:indexPath.row];
	farm.selected = !farm.selected;
	cell.accessoryType = [farm selected] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[self setExecuteButtonEnabled];
}

@end
