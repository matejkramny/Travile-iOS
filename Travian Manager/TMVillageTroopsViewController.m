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

#import "TMVillageTroopsViewController.h"
#import "TMStorage.h"
#import "AppDelegate.h"
#import "TMVillage.h"
#import "TMAccount.h"
#import "TMTroop.h"

@interface TMVillageTroopsViewController () {
	TMAccount *account;
}

@end

@implementation TMVillageTroopsViewController

static NSString *viewTitle = @"Troops";

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
	
	[self.navigationItem setTitle:viewTitle];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int c = [[[account village] troops] count];
    return c == 0 ? 1 : c;
}

static NSString *RightDetailCellID = @"RightDetail";
static NSString *NoTroopsCellID = @"NoTroops";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([account.village.troops count] == 0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NoTroopsCellID];
		cell.textLabel.text = NSLocalizedString(@"NoTroops", @"Village contains no troops - shown inside table as a cell");
		
		[AppDelegate setCellAppearance:cell forIndexPath:indexPath];
		
		return cell;
	}
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RightDetailCellID];
    
	TMTroop *troop = [[account.village troops] objectAtIndex:indexPath.row];
	cell.textLabel.text = [troop name];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", troop.count];
	
	[AppDelegate setCellAppearance:cell forIndexPath:indexPath];
	
    return cell;
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
