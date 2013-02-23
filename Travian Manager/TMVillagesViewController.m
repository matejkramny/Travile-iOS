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
//#import "ODRefreshControl/ODRefreshControl.h"
#import "TMVillageOverviewViewController.h"

@interface TMVillagesViewController () {
	TMStorage *storage;
	UIView *overlay;
	BOOL beenPushed;
}

- (void)didBeginRefreshing:(id)sender;

@end

@interface TMVillagesViewController (Overlay)

- (void)addOverlay;
- (void)removeOverlay:(id)sender;
- (void)removeOverlayAfterDelay:(CGFloat)delay;
- (void)updateOverlay;

@end

@implementation TMVillagesViewController (Overlay)

- (void)addOverlay {
	if (overlay)
		[self removeOverlay:self];
	
	overlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
	
	[self updateOverlay];
	
	[self.tabBarController.navigationController.view addSubview:overlay];
}

- (void)removeOverlay:(id)sender {
	[self updateOverlay];
	
	[overlay removeFromSuperview];
	overlay = nil;
}

- (void)removeOverlayAfterDelay:(CGFloat)delay {
	[self updateOverlay];
	
	// Remove the overlay
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:delay];
	[overlay setAlpha:0];
	[UIView commitAnimations];
	
	// Set timer to remove the overlay form superview and set overlay to nil
	[NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(removeOverlay:) userInfo:nil repeats:NO];
}

// Sets the correct width and height according to device's orientation
- (void)updateOverlay {
	CGRect bounds = [[UIScreen mainScreen] bounds];
	
	UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
		CGFloat h = bounds.size.height;
		CGFloat w = bounds.size.width;
		// Swap width with height to tell overlay orientation is landscape
		bounds.size.height = w;
		bounds.size.width = h;
	}
	
	[overlay setFrame:bounds];
}

@end

@implementation TMVillagesViewController

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
	beenPushed = false;
}

- (void)viewDidUnload
{
	//refreshControl = nil;
	
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tabBarController.navigationItem setHidesBackButton:YES];
	[self.tabBarController.navigationItem setRightBarButtonItems:nil];
	[self.tabBarController.navigationItem setRightBarButtonItem:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItem:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItems:nil];
	
	if (![storage account] || ([storage.account status] & ANotLoggedIn) != 0) {
		[self.tabBarController setTitle:@"Villages"];
		
		[self addOverlay];
		
		return;
	}
	
	if (overlay != nil) {
		[self removeOverlayAfterDelay:0.8];
	}
	
	int c = [[[storage account] villages] count];
	[self.tabBarController setTitle:[NSString stringWithFormat:@"Village%@", c == 1 ? @"" : @"s"]];

	if (!beenPushed) {
		[[self tableView] reloadData];
	}
	beenPushed = false;
}

- (void)viewDidAppear:(BOOL)animated {
	if (![storage account] || ([storage.account status] & ANotLoggedIn) != 0)
		[self performSegueWithIdentifier:@"SelectAccount" sender:self];
	
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	// If overlay exists resize its frame to fit new orientation..
	if (overlay) {
		[self updateOverlay];
	}
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
	if ([keyPath isEqualToString:@"status"]) {
		if (([[change objectForKey:NSKeyValueChangeNewKey] intValue] & ARefreshed) != 0) {
			// Done refreshing
			[storage.account removeObserver:self forKeyPath:@"status"];
			//[refreshControl endRefreshing];
			[self.refreshControl endRefreshing];
			[self.tableView reloadData];
		}
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
	cell.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:1];
	
	[AppDelegate setCellAppearance:cell forIndexPath:indexPath];
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[storage account] setVillage:[[storage account].villages objectAtIndex:indexPath.row]];
	
	[self performSegueWithIdentifier:@"OpenVillage" sender:self];
	
	beenPushed = true;
}

@end
