//
//  PHVillagesViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 22/07/2012.
//
//

#import "PHVillagesViewController.h"
#import "AppDelegate.h"
#import "Storage.h"
#import "Account.h"
#import "Village.h"
#import "ODRefreshControl/ODRefreshControl.h"
#import "PHVOverviewViewController.h"

@interface PHVillagesViewController () {
	AppDelegate *appDelegate;
	Storage *storage;
	UIView *overlay;
	ODRefreshControl *refreshControl;
	NSArray *oVillageVC;
}

- (void)didBeginRefreshing:(id)sender;

@end

@interface PHVillagesViewController (Overlay)

- (void)addOverlay;
- (void)removeOverlay:(id)sender;
- (void)removeOverlayAfterDelay:(CGFloat)delay;
- (void)updateOverlay;

@end

@implementation PHVillagesViewController (Overlay)

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

@implementation PHVillagesViewController

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
	
	appDelegate = [UIApplication sharedApplication].delegate;
	storage = [appDelegate storage];
	refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
	[refreshControl addTarget:self action:@selector(didBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidUnload
{
	refreshControl = nil;
	
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tabBarController.navigationItem setHidesBackButton:YES];
	[self.tabBarController.navigationItem setRightBarButtonItems:nil];
	[self.tabBarController.navigationItem setRightBarButtonItem:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItem:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItems:nil];
	
	if (![storage account]) {
		[self.tabBarController setTitle:@"Villages"];
		
		[self addOverlay];
		
		return;
	}
	
	if (overlay != nil) {
		[self removeOverlayAfterDelay:0.8];
	}
	
	int c = [[[storage account] villages] count];
	[self.tabBarController setTitle:[NSString stringWithFormat:@"Village%@", c == 1 ? @"" : @"s"]];
	
	[[self tableView] reloadData];
	
	if (oVillageVC) {
		for (id <ODRefreshControlDelegate>vc in oVillageVC) {
			[vc setRefreshControl:nil];
		}
		
		oVillageVC = nil;
	}
}

- (void)viewDidAppear:(BOOL)animated {
	if (![storage account])
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
		UITabBarController *tbc = [segue destinationViewController];
		oVillageVC = [tbc viewControllers];
	}
}

- (void)didBeginRefreshing:(id)sender {
	// Reload just village list
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
    
	Village *village = [[[storage account] villages] objectAtIndex:indexPath.row];
	cell.textLabel.text = [village name];
	cell.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:1];
	
	[appDelegate setCellAppearance:cell forIndexPath:indexPath];
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[storage account] setVillage:[[storage account].villages objectAtIndex:indexPath.row]];
	
	[self performSegueWithIdentifier:@"OpenVillage" sender:self];
}

@end
