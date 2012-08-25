//
//  PHVResearchViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 24/08/2012.
//
//

#import "PHVResearchViewController.h"
#import "BuildingAction.h"
#import "Resources.h"
#import "MBProgressHUD.h"

@interface PHVResearchViewController () {
	MBProgressHUD *HUD;
}

- (void)closeView:(id)sender;

@end

@implementation PHVResearchViewController

@synthesize action;

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

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationItem setTitle:@"Research"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [action url] == nil ? 2 : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return 1;
		case 1:
			return 4;
		case 2:
			return 1;
		default:
			return 0;
	}
}

static NSString *basicCellID = @"Basic";
static NSString *selectableCellID = @"Selectable";
static NSString *resourceCellID = @"Resource";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
	
	switch (indexPath.section) {
		case 0:
			cell = [tableView dequeueReusableCellWithIdentifier:basicCellID];
			cell.textLabel.text = action.name;
			break;
		case 1:
			cell = [tableView dequeueReusableCellWithIdentifier:resourceCellID];
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Wood";
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", action.resources.wood];
					break;
				case 1:
					cell.textLabel.text = @"Clay";
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", action.resources.clay];
					break;
				case 2:
					cell.textLabel.text = @"Iron";
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", action.resources.iron];
					break;
				case 3:
					cell.textLabel.text = @"Wheat";
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", action.resources.wheat];
					break;
			}
			break;
		case 2:
			cell = [tableView dequeueReusableCellWithIdentifier:selectableCellID];
			cell.textLabel.text = @"Research";
			break;
	}
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Details";
		case 1:
			return @"Required resources";
		default:
			return @"";
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section != 2)
		return;
	
	// Research
	[action research];
	
	HUD = [MBProgressHUD showHUDAddedTo:self.tabBarController.navigationController.view animated:NO];
	[HUD setMode:MBProgressHUDModeCustomView];
	[HUD setCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]]];
	[HUD setLabelText:@"Done"];
	[HUD hide:YES afterDelay:1];
	
	[self performSelector:@selector(closeView:) withObject:self afterDelay:1.5];
}

- (void)closeView:(id)sender {
	[[self navigationController] popViewControllerAnimated:YES];
}

@end
