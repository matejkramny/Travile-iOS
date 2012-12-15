//
//  PHVResourcesViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 29/07/2012.
//
//

#import "PHVResourcesViewController.h"
#import "AppDelegate.h"
#import "Village.h"
#import "Storage.h"
#import "Account.h"
#import "Resources.h"
#import "ResourcesProduction.h"
#import "Settings.h"

@interface PHVResourcesViewController () {
	Account *account;
	NSTimer *secondTimer;
}

- (void)timerFired:(id)sender;

@end

@implementation PHVResourcesViewController

@synthesize wood;
@synthesize clay;
@synthesize iron;
@synthesize wheat;
@synthesize warehouse;
@synthesize granary;
@synthesize consuming;
@synthesize producing;

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
	
	[self setRefreshControl:[[UIRefreshControl alloc] init]];
	[[self refreshControl] addTarget:self action:@selector(didBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	
	[self reloadBadgeCount];
	
	[[self tableView] setBackgroundView:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tabBarController.navigationItem setRightBarButtonItems:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItems:nil];
	[self.tabBarController.navigationItem setRightBarButtonItem:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItem:nil];
	
	[self.tabBarController setTitle:[NSString stringWithFormat:@"Resources"]];
	
	if (secondTimer)
		[secondTimer invalidate];
	
	secondTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
	[self timerFired:nil];
	
	[self.tableView reloadData];
	
	[self reloadBadgeCount];
	
	[self timerFired:self];
}

- (void)viewWillDisappear:(BOOL)animated {
	if (secondTimer) {
		[secondTimer invalidate];
		secondTimer = nil;
	}
	
	[super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[self setWood:nil];
	[self setClay:nil];
	[self setIron:nil];
	[self setWheat:nil];
	[self setWarehouse:nil];
	[self setGranary:nil];
	[self setConsuming:nil];
	[self setProducing:nil];
    [super viewDidUnload];
	
	if (secondTimer)
		[secondTimer invalidate];
}

- (void)reloadBadgeCount {
	Village *v = [account village];
	Resources *r = [v resources];
	
	unsigned int whouse = v.warehouse;
	unsigned int gran = v.granary;
	if ([r wood] > whouse || [r clay] > whouse || [r iron] > whouse || [r wheat] > gran) {
		[[self tabBarItem] setBadgeValue:@"!"];
	}
}

- (void)timerFired:(id)sender {
	Village *v = [account village];
	[[v resources] updateResourcesFromProduction:[v resourceProduction] warehouse:[v warehouse] granary:[v granary]];
	[self refreshResources];
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight));
}

- (void)refreshResources {
	Village *v = [account village];
	Resources *r = [v resources];
	ResourcesProduction *rp = [v resourceProduction];
	bool indicatePercentage = [Storage sharedStorage].settings.showsResourceProgress;
	bool decimalResources = [Storage sharedStorage].settings.showsDecimalResources;
	
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
	[account addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
	
	[account refreshAccountWithMap:ARVillage];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"status"]) {
		if (([[change objectForKey:NSKeyValueChangeNewKey] intValue] & ARefreshed) != 0) {
			// Refreshed
			[account removeObserver:self forKeyPath:@"status"];
			[self.refreshControl endRefreshing];
			[[self tableView] reloadData];
		}
	}
}

@end
