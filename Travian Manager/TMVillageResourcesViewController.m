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
}

- (void)timerFired:(id)sender;

@end

@implementation TMVillageResourcesViewController

@synthesize wood;
@synthesize clay;
@synthesize iron;
@synthesize wheat;
@synthesize warehouse;
@synthesize granary;
@synthesize consuming;
@synthesize producing;

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
	
	[self setWood:nil];
	[self setClay:nil];
	[self setIron:nil];
	[self setWheat:nil];
	[self setWarehouse:nil];
	[self setGranary:nil];
	[self setConsuming:nil];
	[self setProducing:nil];
    
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
	
	void (^setFormatToResource)(UILabel *, float, int, int) = ^(UILabel *l, float rv, int rpv, int percentage) {
		if (decimalResources)
			[l setText:[NSString stringWithFormat:@"%.01f", rv]];
		else
			[l setText:[NSString stringWithFormat:@"%d", (int)rv]];
		
		[l setText:[[l text] stringByAppendingFormat:@" (%d) ", rpv]];
		
		if (indicatePercentage)
			[l setText:[[l text] stringByAppendingFormat:@"%d%% full", percentage]];
	};
	void (^setSimpleFormatToResource)(UILabel *, int) = ^(UILabel *l, int rv) {
		[l setText:[NSString stringWithFormat:@"%d", rv]];
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

@end
