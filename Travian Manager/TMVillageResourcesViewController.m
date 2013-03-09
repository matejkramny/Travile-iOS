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

#import "TMVillageResourcesViewController.h"
#import "AppDelegate.h"
#import "TMVillage.h"
#import "TMStorage.h"
#import "TMAccount.h"
#import "TMResources.h"
#import "TMResourcesProduction.h"
#import "TMSettings.h"

@interface TMVillageResourcesViewController () {
	TMAccount *account;
	NSTimer *secondTimer;
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

static NSString *viewTitle = @"Resources";

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
	
	account = [[TMStorage sharedStorage] account];
	
	[self setRefreshControl:[[UIRefreshControl alloc] init]];
	[[self refreshControl] addTarget:self action:@selector(didBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	
	[self reloadBadgeCount];
	
	[[self tableView] setBackgroundView:nil];
	[self.navigationItem setTitle:viewTitle];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
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
	TMVillage *v = [account village];
	TMResources *r = [v resources];
	
	unsigned int whouse = v.warehouse;
	unsigned int gran = v.granary;
	if ([r wood] > whouse || [r clay] > whouse || [r iron] > whouse || [r wheat] > gran) {
		[[self tabBarItem] setBadgeValue:@"!"];
	}
}

- (void)timerFired:(id)sender {
	TMVillage *v = [account village];
	[[v resources] updateResourcesFromProduction:[v resourceProduction] warehouse:[v warehouse] granary:[v granary]];
	[self refreshResources];
	[self.tableView reloadData];
}

- (void)refreshResources {
	TMVillage *v = [account village];
	TMResources *r = [v resources];
	TMResourcesProduction *rp = [v resourceProduction];
	bool indicatePercentage = [TMStorage sharedStorage].settings.showsResourceProgress;
	bool decimalResources = [TMStorage sharedStorage].settings.showsDecimalResources;
	
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
