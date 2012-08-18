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
	
	refreshControl = [AppDelegate addRefreshControlTo:self.tableView target:self action:@selector(didBeginRefreshing:)];
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
	[self.tableView reloadData];
	
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

- (void)timerFired:(id)sender {
	Village *v = [account village];
	[[v resources] updateResourcesFromProduction:[v resourceProduction] warehouse:[v warehouse] granary:[v granary]];
	[self refreshResources];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight));
}

- (void)refreshResources {
	Village *v = [account village];
	Resources *r = [v resources];
	ResourcesProduction *rp = [v resourceProduction];
	
	void (^setFormatToResource)(UILabel *, float, int) = ^(UILabel *l, float rv, int rpv) {
		[l setText:[NSString stringWithFormat:@"%.01f (%d)", rv, rpv]];
	};
	void (^setSimpleFormatToResource)(UILabel *, int) = ^(UILabel *l, int rv) {
		[l setText:[NSString stringWithFormat:@"%d", rv]];
	};
	
	setFormatToResource(wood, r.wood, rp.wood);
	setFormatToResource(clay, r.clay, rp.clay);
	setFormatToResource(iron, r.iron, rp.iron);
	setFormatToResource(wheat, r.wheat, rp.wheat);
	
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
			[refreshControl endRefreshing];
			[[self tableView] reloadData];
		}
	}
}

@end
