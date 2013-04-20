/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMFarmListEntryViewController.h"
#import "TMFarmListEntry.h"
#import "TMFarmListEntryFarm.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface TMFarmListEntryViewController () {
	MBProgressHUD *HUD;
	UITapGestureRecognizer *touchToCancel;
}

@end

@implementation TMFarmListEntryViewController

static UIBarButtonItem *executeButton;

@synthesize farmList;

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
	
}

- (void)viewWillAppear:(BOOL)animated {
	if (!executeButton)
		executeButton = [[UIBarButtonItem alloc] initWithTitle:@"Execute" style:UIBarButtonItemStylePlain target:self action:@selector(executeFarmList:)];
	self.navigationItem.title = farmList.name;
	self.navigationItem.rightBarButtonItem = executeButton;
	
	[self setExecuteButtonEnabled];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)executeFarmList:(id)sender {
	HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	HUD.labelText = [@"Executing " stringByAppendingString:farmList.name];
	HUD.detailsLabelText = @"Tap to hide";
	touchToCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToCancel:)];
	[HUD addGestureRecognizer:touchToCancel];
	
	[farmList executeWithCompletion:^(void) {
		[HUD hide:YES];
		[HUD removeGestureRecognizer:touchToCancel];
		touchToCancel = nil;
		//[self.navigationController popViewControllerAnimated:YES];
	}];
}

- (void)tappedToCancel:(id)sender {
	[HUD hide:YES];
	[HUD removeGestureRecognizer:touchToCancel];
	touchToCancel = nil;
}

- (void)setExecuteButtonEnabled {
	int selectedCount = 0;
	for (TMFarmListEntryFarm *theFarm in farmList.farms) {
		if (theFarm.selected) selectedCount++;
	}
	
	if (selectedCount > 0) {
		[executeButton setEnabled:YES];
	} else {
		[executeButton setEnabled:NO];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return farmList.farms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BasicCheckmark";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	TMFarmListEntryFarm *farm = [[farmList farms] objectAtIndex:indexPath.row];
	cell.textLabel.text = farm.targetName;
	cell.accessoryType = farm.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
	[AppDelegate setCellAppearance:cell forIndexPath:indexPath];
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	TMFarmListEntryFarm *farm = [farmList.farms objectAtIndex:indexPath.row];
	farm.selected = !farm.selected;
	cell.accessoryType = [farm selected] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[self setExecuteButtonEnabled];
}

@end
