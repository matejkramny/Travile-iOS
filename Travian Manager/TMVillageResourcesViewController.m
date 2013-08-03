/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMVillageResourcesViewController.h"
#import "AppDelegate.h"
#import "TMVillage.h"
#import "TMStorage.h"
#import "TMAccount.h"
#import "TMResources.h"
#import "TMResourcesProduction.h"
#import "TMSettings.h"
#import "MBProgressHUD.h"

@interface TMVillageResourcesViewController () {
	TMStorage *storage;
	TMVillage *village;
	NSTimer *secondTimer;
	MBProgressHUD *HUD;
	UITapGestureRecognizer *tapToCancel;
	
	UITableViewCell *wood, *clay, *iron, *wheat, *producing, *consuming, *warehouse, *granary;
}

- (void)timerFired:(id)sender;

@end

@implementation TMVillageResourcesViewController

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
	
	viewTitle = NSLocalizedString(@"Resources", nil);
	
	storage = [TMStorage sharedStorage];
	village = storage.account.village;
	
	[self setRefreshControl:[[UIRefreshControl alloc] init]];
	[[self refreshControl] addTarget:self action:@selector(didBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	
	[[self tableView] setBackgroundView:nil];
	[self.navigationItem setTitle:viewTitle];
	
	wood = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
	clay = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
	iron = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
	wheat = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
	granary = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
	warehouse = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
	consuming = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
	producing = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil];
	
	wood.textLabel.text = NSLocalizedString(@"Wood", nil);
	clay.textLabel.text = NSLocalizedString(@"Clay", nil);
	iron.textLabel.text = NSLocalizedString(@"Iron", nil);
	wheat.textLabel.text = NSLocalizedString(@"Wheat", nil);
	warehouse.textLabel.text = NSLocalizedString(@"Warehouse", nil);
	granary.textLabel.text = NSLocalizedString(@"Granary", nil);
	consuming.textLabel.text = NSLocalizedString(@"Consuming", nil);
	producing.textLabel.text = NSLocalizedString(@"Producing", nil);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[storage account] addObserver:self forKeyPath:@"village" options:NSKeyValueObservingOptionNew context:nil];
	
	if (secondTimer)
		[secondTimer invalidate];
	
	secondTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
	[self timerFired:nil];
	
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
	
	[self timerFired:self];
}

- (void)viewWillDisappear:(BOOL)animated {
	if (secondTimer) {
		[secondTimer invalidate];
		secondTimer = nil;
	}
	
	@try {
		[storage.account removeObserver:self forKeyPath:@"village"];
	}
	@catch (id exception) {
		// do nothing.. means it isn't registered as observer
	}
	
	[super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
    
	@try {
		[storage.account removeObserver:self forKeyPath:@"village"];
	}
	@catch (id exception) {
		// do nothing.. means it isn't registered as observer
	}
	
	if (secondTimer)
		[secondTimer invalidate];
}

- (void)timerFired:(id)sender {
	TMVillage *v = [storage.account village];
	[[v resources] updateResourcesFromProduction:[v resourceProduction] warehouse:[v warehouse] granary:[v granary]];
	[self refreshResources];
	[self.tableView reloadData];
}

- (void)refreshResources {
	TMVillage *v = [storage.account village];
	TMResources *r = [v resources];
	TMResourcesProduction *rp = [v resourceProduction];
	bool indicatePercentage = storage.account.settings.showsResourceProgress;
	bool decimalResources = storage.account.settings.showsDecimalResources;
	
	void (^setFormatToResource)(UITableViewCell *, float, int, int) = ^(UITableViewCell *l, float rv, int rpv, int percentage) {
		if (decimalResources)
			l.detailTextLabel.text = [NSString stringWithFormat:@"%.01f", rv];
		else
			l.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)rv];
		
		l.detailTextLabel.text = [l.detailTextLabel.text stringByAppendingFormat:@" (%d) ", rpv];
		
		if (indicatePercentage)
			l.detailTextLabel.text = [l.detailTextLabel.text stringByAppendingFormat:@"%d%% full", percentage];
	};
	void (^setSimpleFormatToResource)(UITableViewCell *, int) = ^(UITableViewCell *l, int rv) {
		l.detailTextLabel.text = [NSString stringWithFormat:@"%d", rv];
	};
	
	setFormatToResource(wood, r.wood, rp.wood, [r getPercentageForResource:r.wood warehouse:v.warehouse]);
	setFormatToResource(clay, r.clay, rp.clay, [r getPercentageForResource:r.clay warehouse:v.warehouse]);
	setFormatToResource(iron, r.iron, rp.iron, [r getPercentageForResource:r.iron warehouse:v.warehouse]);
	setFormatToResource(wheat, r.wheat, rp.wheat, [r getPercentageForResource:r.wheat warehouse:v.granary]);
	
	setSimpleFormatToResource(warehouse, v.warehouse);
	setSimpleFormatToResource(granary, v.granary);
	
	setSimpleFormatToResource(consuming, v.consumption);
	setSimpleFormatToResource(producing, rp.wheat);
}

- (void)didBeginRefreshing:(id)sender {
	[storage.account addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
	
	[storage.account refreshAccountWithMap:ARVillage];
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

#pragma mark - Table delegation

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 4;
		case 1:
		case 2:
			return 2;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					return wood;
				case 1:
					return clay;
				case 2:
					return iron;
				case 3:
					return wheat;
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					return warehouse;
				case 1:
					return granary;
			}
		case 2:
			switch (indexPath.row) {
				case 0:
					return consuming;
				case 1:
					return producing;
			}
	}
	
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"Resources", @"Sidebar cell text");
		case 1:
			return NSLocalizedString(@"Storage", @"Storage section label in the Village Resource view");
		case 2:
			return NSLocalizedString(@"Consumption", @"Consumption section label in the village Resource view");
	}
	
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return NSLocalizedString(@"Stored now (Produced per hour) Full%", @"Resource section footer label in the Village Resource view. It explains what each cell contains.");
	}
	
	return nil;
}

@end
