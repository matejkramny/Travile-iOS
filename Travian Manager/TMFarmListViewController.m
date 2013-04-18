/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMFarmListViewController.h"
#import "TMStorage.h"
#import "TMVillage.h"
#import "TMAccount.h"
#import "TMFarmList.h"
#import "TMFarmListEntry.h"
#import "TMFarmListEntryFarm.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "TMFarmListEntryViewController.h"

@interface TMFarmListViewController () {
	TMStorage *storage;
	TMVillage *village;
	MBProgressHUD *HUD;
	UITapGestureRecognizer *tapToCancel;
	TMFarmListEntry *selectedFarmList;
}

@end

@implementation TMFarmListViewController

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
	village = [storage.account village];
	self.navigationItem.title = @"Farm Lists";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (village != storage.account.village) {
		// Refresh
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (village.farmList == nil || village.farmList.loaded == false) {
		// Load the farm list.
		HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
		[HUD setLabelText:@"Loading Farm List"];
		[HUD setDetailsLabelText:@"Tap to cancel"];
		tapToCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToCancel:)];
		[HUD addGestureRecognizer:tapToCancel];
		
		if (!village.farmList) {
			village.farmList = [[TMFarmList alloc] init];
		}
		[village.farmList loadFarmList:^(void) {
			if (HUD) {
				[HUD hide:YES];
				[HUD removeGestureRecognizer:tapToCancel];
				tapToCancel = nil;
				[self.tableView reloadData];
			}
		}];
	}
}

- (void)tappedToCancel:(id)sender {
	[HUD hide:YES];
	[HUD removeGestureRecognizer:tapToCancel];
	tapToCancel = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return village.farmList.farmLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BasicSelectable";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	NSArray *farmLists = village.farmList.farmLists;
	TMFarmListEntry *entry = [farmLists objectAtIndex:indexPath.row];
    cell.textLabel.text = entry.name;
	
	[AppDelegate setCellAppearance:cell forIndexPath:indexPath];
	
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"OpenFarmList"]) {
		TMFarmListEntryViewController *entryVC = [segue destinationViewController];
		entryVC.farmList = selectedFarmList;
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	selectedFarmList = [village.farmList.farmLists objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"OpenFarmList" sender:self];
}

@end
