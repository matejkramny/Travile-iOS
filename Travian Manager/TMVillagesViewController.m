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

#import "TMVillagesViewController.h"
#import "AppDelegate.h"
#import "TMStorage.h"
#import "TMAccount.h"
#import "TMVillage.h"
#import "TMVillageOverviewViewController.h"
#import "MKModalOverlay.h"
#import "MBProgressHUD.h"

@interface TMVillagesViewController () {
	TMStorage *storage;
	NSIndexPath *selectedVillageIndexPath;
	MKModalOverlay *overlay;
	MBProgressHUD *HUD;
	UITapGestureRecognizer *tapToCancel;
}

- (void)didBeginRefreshing:(id)sender;

@end

@implementation TMVillagesViewController

static NSString *title = @"Villages";

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
	
	[self setRefreshControl:[[UIRefreshControl alloc] init]];
	[self.refreshControl addTarget:self action:@selector(didBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	
	overlay = [[MKModalOverlay alloc] initWithTarget:self.navigationController.tabBarController.view];
	[overlay configureBoundsBottomToTop];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	if (![storage account] || ([storage.account status] & ANotLoggedIn) != 0) {
		[overlay addOverlayAnimated:NO usingAnimationType:OverlayAnimationTypeMove];
		return;
	} else {
		if (selectedVillageIndexPath == nil) {
			[overlay removeOverlayAnimated:NO usingAnimationType:OverlayAnimationTypeComplete];
		} else {
			[overlay removeOverlayAnimated:YES usingAnimationType:OverlayAnimationTypeComplete];
		}
	}
	
	if (selectedVillageIndexPath) {
		[self.tableView selectRowAtIndexPath:selectedVillageIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
		[self.tableView deselectRowAtIndexPath:selectedVillageIndexPath animated:YES];
		selectedVillageIndexPath = nil;
	} else {
		[[self tableView] reloadData];
	}
	
	[self.navigationItem setTitle:title];
	
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	if (![storage account] || ([storage.account status] & ANotLoggedIn) != 0)
		[self performSegueWithIdentifier:@"SelectAccount" sender:self];
	
	[super viewDidAppear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"OpenVillage"]) {
	}
}

- (void)didBeginRefreshing:(id)sender {
	// Reload just village list
	[[storage account] refreshAccountWithMap:ARVillages];
	[storage.account addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == storage.account && [keyPath isEqualToString:@"status"]) {
		if (([[change objectForKey:NSKeyValueChangeNewKey] intValue] & ARefreshed) != 0) {
			// Done refreshing
			[storage.account removeObserver:self forKeyPath:@"status"];
			//[refreshControl endRefreshing];
			[self.refreshControl endRefreshing];
			[self.tableView reloadData];
		}
		// implement other scenarios - cannot log in, connection failure.
	} else if ([object isKindOfClass:[TMVillage class]] && [keyPath isEqualToString:@"hasDownloaded"]) {
		[[storage.account.villages objectAtIndex:selectedVillageIndexPath.row] removeObserver:self forKeyPath:@"hasDownloaded"];
		[HUD removeGestureRecognizer:tapToCancel];
		tapToCancel = nil;
		[HUD hide:YES];
		
		[self tableView:self.tableView didSelectRowAtIndexPath:selectedVillageIndexPath]; // 'Reselect' the table cell
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[storage account] villages] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VillageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	TMVillage *village = [[[storage account] villages] objectAtIndex:indexPath.row];
	cell.textLabel.text = [village name];
	//cell.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:1];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", village.population];
	
	[AppDelegate setCellAppearance:cell forIndexPath:indexPath];
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	TMVillage *village = [[storage account].villages objectAtIndex:indexPath.row];
	selectedVillageIndexPath = indexPath;
	
	if (![village hasDownloaded]) {
		HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.tabBarController.view animated:YES];
		[HUD setLabelText:[NSString stringWithFormat:@"Loading %@", village.name]];
		[HUD setDetailsLabelText:@"Tap to cancel"];
		tapToCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToCancel:)];
		[HUD addGestureRecognizer:tapToCancel];
		[village addObserver:self forKeyPath:@"hasDownloaded" options:NSKeyValueObservingOptionNew context:nil];
		[village downloadAndParse];
		
		return;
	}
	
    [[storage account] setVillage:village];
	
	[self performSegueWithIdentifier:@"OpenVillage" sender:self];
	
	[overlay addOverlayAnimated:TRUE];
}

#pragma mark -

- (void)tappedToCancel:(id)sender {
	[[storage.account.villages objectAtIndex:selectedVillageIndexPath.row] removeObserver:self forKeyPath:@"hasDownloaded"];
	[HUD removeGestureRecognizer:tapToCancel];
	tapToCancel = nil;
	[HUD hide:YES];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

@end
