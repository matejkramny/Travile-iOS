//
//  PHVBuildingsViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 29/07/2012.
//
//

#import "PHVBuildingsViewController.h"
#import "Account.h"
#import "AppDelegate.h"
#import "Storage.h"
#import "Village.h"
#import "Building.h"

@interface PHVBuildingsViewController () {
	Account *account;
}

@end

@implementation PHVBuildingsViewController

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
	
	AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	account = [[appDelegate storage] account];
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
	
	[self.tabBarController setTitle:[NSString stringWithFormat:@"Buildings"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationLandscapeLeft));
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *buildings = [[account village] buildings];
	
	// Filter by section. 0 - res, 1 - village
	int count = 0;
	TravianPages type = section == 0 ? TPResources : TPVillage;
	
	for (Building *b in buildings)
		if (([b page] & type) != 0)
			count++;
	
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RightDetail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	NSArray *buildings = [[account village] buildings];
	Building *b;
	TravianPages type = indexPath.section == 0 ? TPResources : TPVillage;
	int buildingsInSection = 0;
	
	for (Building *building in buildings) {
		if (([building page] & type) != 0) {
			if (buildingsInSection == indexPath.row) {
				b = building;
				break;
			}
			
			buildingsInSection++;
		}
	}
	
	if (!b) {
		NSLog(@"Building not found!");
		return nil;
	}
	
	cell.textLabel.text = b.name;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", b.level];
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 0 ? @"Resource fields" : @"Village buildings";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Build
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	// View Building in detail
}

@end