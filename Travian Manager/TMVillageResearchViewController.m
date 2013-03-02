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

#import "TMVillageResearchViewController.h"
#import "TMBuildingAction.h"
#import "TMResources.h"
#import "MBProgressHUD.h"

@interface TMVillageResearchViewController () {
	MBProgressHUD *HUD;
}

- (void)closeView:(id)sender;

@end

@implementation TMVillageResearchViewController

@synthesize action;

static NSString *viewTitle = @"Research";

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
	
	[self.tableView setBackgroundView:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationItem setTitle:viewTitle];
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
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:NO];
	[HUD setMode:MBProgressHUDModeCustomView];
	[HUD setCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]]];
	[HUD setLabelText:@"Done"];
	[HUD hide:YES afterDelay:0.7];
	
	[self performSelector:@selector(closeView:) withObject:self afterDelay:1.2];
}

- (void)closeView:(id)sender {
	[[self navigationController] popViewControllerAnimated:YES];
}

@end
