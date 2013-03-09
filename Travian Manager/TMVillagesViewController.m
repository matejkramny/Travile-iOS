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

@interface TMVillagesViewController () {
	TMStorage *storage;
	UIView *overlay;
	BOOL beenPushed;
	NSArray *timers;
	CGRect navbarBounds;
	CGRect navbarBoundsPushed;
}

typedef enum {
	AnimationTypeOverlay = 1 << 1,
	AnimationTypeFromBottom = 1 << 2,
	AnimationTypeComplete = AnimationTypeOverlay | AnimationTypeFromBottom
} AnimationType;

- (void)didBeginRefreshing:(id)sender;

@end

@interface TMVillagesViewController (Overlay)

- (void)addOverlay;
- (void)addOverlayAnimated:(BOOL)animated;
- (void)addOverlayAnimated:(BOOL)animated usingAnimationType:(AnimationType)animationType;
- (void)removeOverlay:(id)sender;
- (void)removeOverlayAnimated:(BOOL)animated;
- (void)removeOverlayAnimated:(BOOL)animated usingAnimationType:(AnimationType)animationType;

@end

@implementation TMVillagesViewController (Overlay)

static CGFloat transDuration = 0.4f;
static CGFloat overlayOpacity = 0.9f;

- (void)addOverlay {
	[self addOverlayAnimated:NO];
}

- (void)addOverlayAnimated:(BOOL)animated {
	[self addOverlayAnimated:animated usingAnimationType:AnimationTypeComplete];
}

- (void)addOverlayAnimated:(BOOL)animated usingAnimationType:(AnimationType)animationType {
	if (overlay) {
		[overlay removeFromSuperview];
		overlay = nil;
	}
	
	overlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[self.navigationController.tabBarController.view addSubview:overlay];
	
	overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:overlayOpacity];
	
	if (animated) {
		// Reset the view position and alpha before re-animating
		[overlay setAlpha:0];
		[self.navigationController.tabBarController.view setBounds:navbarBounds];
		
		[UIView beginAnimations:@"AddOverlay" context:nil];
		[UIView setAnimationDuration:transDuration];
		
		if ((animationType & AnimationTypeOverlay) != 0)
			[overlay setAlpha:overlayOpacity];
		if ((animationType & AnimationTypeFromBottom) != 0)
			[self.navigationController.tabBarController.view setBounds:navbarBoundsPushed];
		
		[UIView commitAnimations];
	} else {
		if ((animationType & AnimationTypeFromBottom) != 0)
			[self.navigationController.tabBarController.view setBounds:navbarBoundsPushed];
		if ((animationType & AnimationTypeOverlay) != 0)
			[overlay setAlpha:overlayOpacity];
	}
}

- (void)removeOverlay:(id)sender {
	[self removeOverlayAnimated:NO];
}

- (void)removeOverlayAnimated:(BOOL)animated {
	[self removeOverlayAnimated:animated usingAnimationType:AnimationTypeComplete];
}

- (void)removeOverlayAnimated:(BOOL)animated usingAnimationType:(AnimationType)animationType {
	[overlay setAlpha:0];
	[self.navigationController.tabBarController.view setBounds:navbarBounds];
	
	if (animated) {
		// Reset the view position and alpha before re-animating
		if ((animationType & AnimationTypeOverlay) != 0)
			[overlay setAlpha:overlayOpacity];
		
		if ((animationType & AnimationTypeFromBottom) != 0)
			[self.navigationController.tabBarController.view setBounds:navbarBoundsPushed];
		
		// Animate
		[UIView beginAnimations:@"RemoveOverlay" context:NULL];
		[UIView setAnimationDuration:transDuration];
		
		if ((animationType & AnimationTypeOverlay) != 0)
			[overlay setAlpha:0];
		if ((animationType & AnimationTypeFromBottom) != 0)
			[self.navigationController.tabBarController.view setBounds:navbarBounds];
		
		[UIView commitAnimations];
	} else {
		if ((animationType & AnimationTypeFromBottom) != 0)
			[self.navigationController.tabBarController.view setBounds:navbarBounds];
		
		if ((animationType & AnimationTypeOverlay) != 0)
			[overlay setAlpha:0];
	}
	
	//[overlay removeFromSuperview]; //not required?
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
	
	navbarBounds = self.navigationController.tabBarController.view.bounds;
	navbarBoundsPushed = CGRectMake(navbarBounds.origin.x, navbarBounds.origin.y + navbarBounds.size.height / 3, navbarBounds.size.width, navbarBounds.size.height); // +44
}

- (void)viewDidUnload
{
	//refreshControl = nil;
	
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (![storage account] || ([storage.account status] & ANotLoggedIn) != 0) {
		[self addOverlayAnimated:NO usingAnimationType:AnimationTypeOverlay];
		return;
	} else if (overlay != nil) {
		if (!beenPushed) {
			[self removeOverlayAnimated:NO usingAnimationType:AnimationTypeComplete];
		} else {
			[self removeOverlayAnimated:YES usingAnimationType:AnimationTypeComplete];
		}
	}
	
	static NSString *title = @"Villages";
	[self.navigationItem setTitle:title];
	
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
		// implement other scenarios - cannot log in, connection failure.
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
	
	if (!DEBUG_ANIMATION)
		[self performSegueWithIdentifier:@"OpenVillage" sender:self];
	else
		[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(viewWillAppear:) userInfo:nil repeats:NO]; // to debug animations..
	
	[self addOverlayAnimated:TRUE];
	
	beenPushed = true;
}

@end
