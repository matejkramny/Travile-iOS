/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMVillageTroopsViewController.h"
#import "TMStorage.h"
#import "AppDelegate.h"
#import "TMVillage.h"
#import "TMAccount.h"
#import "TMTroop.h"
#import "MBProgressHUD.h"

@interface TMVillageTroopsViewController () {
	TMStorage *storage;
	TMVillage *village;
	MBProgressHUD *HUD;
	UITapGestureRecognizer *tapToCancel;
}

@end

@implementation TMVillageTroopsViewController

static NSString *viewTitle;

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
	
	viewTitle = NSLocalizedString(@"Troops", @"View title for Troops");
	
	storage = [TMStorage sharedStorage];
	village = storage.account.village;
	
	[self setRefreshControl:[[UIRefreshControl alloc] init]];
	[[self refreshControl] addTarget:self action:@selector(didBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	
	[self.navigationItem setTitle:viewTitle];
}

- (void)viewDidUnload
{
	@try {
		[storage.account removeObserver:self forKeyPath:@"village"];
	}
	@catch (id exception) {
		// do nothing.. means it isn't registered as observer
	}
	
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[storage account] addObserver:self forKeyPath:@"village" options:NSKeyValueObservingOptionNew context:nil];
	
	if (village != storage.account.village) {
		village = storage.account.village;
		
		if (!village.hasDownloaded) {
			// Download the village.
			HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
			[HUD setLabelText:[NSString stringWithFormat:NSLocalizedString(@"Loading %@", @"Shown in HUD when loading a village"), village.name]];
			[HUD setDetailsLabelText:NSLocalizedString(@"Tap to cancel", @"Shown in HUD, informative to cancel the operation")];
			tapToCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToCancel:)];
			[HUD addGestureRecognizer:tapToCancel];
			[village addObserver:self forKeyPath:@"hasDownloaded" options:NSKeyValueObservingOptionNew context:nil];
			[village downloadAndParse];
		}
		
		[self.tableView reloadData];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	@try {
		[storage.account removeObserver:self forKeyPath:@"village"];
	}
	@catch (id exception) {
		// do nothing.. means it isn't registered as observer
	}
	
	[super viewWillDisappear:animated];
}

- (void)finishedLoadingVillageWithHUD {
	@try {
		[village removeObserver:self forKeyPath:@"hasDownloaded"];
		[HUD removeGestureRecognizer:tapToCancel];
		tapToCancel = nil;
		[HUD hide:YES];
	}
	@catch (NSException *exception) {
	}
	@finally {
		[self.tableView reloadData];
	}
}

- (void)tappedToCancel:(id)sender {
	[self finishedLoadingVillageWithHUD];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int c = [[village troops] count];
    return c == 0 ? 1 : c;
}

static NSString *RightDetailCellID = @"RightDetail";
static NSString *NoTroopsCellID = @"NoTroops";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([village.troops count] == 0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NoTroopsCellID];
		cell.textLabel.text = NSLocalizedString(@"NoTroops", @"Village contains no troops - shown inside table as a cell");
		
		[AppDelegate setCellAppearance:cell forIndexPath:indexPath];
		
		return cell;
	}
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RightDetailCellID];
    
	TMTroop *troop = [[village troops] objectAtIndex:indexPath.row];
	cell.textLabel.text = [troop name];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", troop.count];
	
	[AppDelegate setCellAppearance:cell forIndexPath:indexPath];
	
    return cell;
}

- (void)didBeginRefreshing:(id)sender {
	[storage.account addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
	
	[storage.account refreshAccountWithMap:ARVillage];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"status"]) {
		if (([[change objectForKey:NSKeyValueChangeNewKey] intValue] & ARefreshed) != 0) {
			// Refreshed
			[storage.account removeObserver:self forKeyPath:@"status"];
			[self.refreshControl endRefreshing];
			[[self tableView] reloadData];
		}
	} else if ([keyPath isEqualToString:@"hasDownloaded"]) {
		[self finishedLoadingVillageWithHUD];
	} else if ([keyPath isEqualToString:@"village"]) {
		if (village != storage.account.village && storage.account.village != nil) {
			village = storage.account.village;
			
			if (!village.hasDownloaded) {
				// Download the village.
				HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
				[HUD setLabelText:[NSString stringWithFormat:NSLocalizedString(@"Loading %@", @"Shown in HUD when loading a village"), village.name]];
				[HUD setDetailsLabelText:NSLocalizedString(@"Tap to cancel", @"Shown in HUD, informative to cancel the operation")];
				tapToCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToCancel:)];
				[HUD addGestureRecognizer:tapToCancel];
				[village addObserver:self forKeyPath:@"hasDownloaded" options:NSKeyValueObservingOptionNew context:nil];
				[village downloadAndParse];
			}
			
			[self.tableView reloadData];
		}
	}
}

@end
