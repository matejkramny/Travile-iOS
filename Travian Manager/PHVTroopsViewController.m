//
//  PHVTroopsViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 29/07/2012.
//
//

#import "PHVTroopsViewController.h"
#import "Storage.h"
#import "AppDelegate.h"
#import "Village.h"
#import "Account.h"
#import "Troop.h"

@interface PHVTroopsViewController () {
	Account *account;
	AppDelegate *appDelegate;
}

@end

@implementation PHVTroopsViewController

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
	
	appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	account = [[appDelegate storage] account];
	
	refreshControl = [AppDelegate addRefreshControlTo:self.tableView target:self action:@selector(didBeginRefreshing:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tabBarController.navigationItem setRightBarButtonItems:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItems:nil];
	[self.tabBarController.navigationItem setRightBarButtonItem:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItem:nil];
	
	[self.tabBarController setTitle:[NSString stringWithFormat:@"Troops"]];
	
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight));
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
		
		[appDelegate setCellAppearance:cell forIndexPath:indexPath];
		
		return cell;
	}
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RightDetailCellID];
    
	Troop *troop = [[account.village troops] objectAtIndex:indexPath.row];
	cell.textLabel.text = [troop name];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", troop.count];
	
	[appDelegate setCellAppearance:cell forIndexPath:indexPath];
	
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
			[refreshControl endRefreshing];
			[[self tableView] reloadData];
		}
	}
}

@end
