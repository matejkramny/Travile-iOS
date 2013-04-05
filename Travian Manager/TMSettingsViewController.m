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

#import "TMSettingsViewController.h"
#import "TMStorage.h"
#import "TMAccount.h"
#import "MBProgressHUD.h"
#import "TMSettings.h"

@interface TMSettingsViewController ()

@end

@implementation TMSettingsViewController

@synthesize settings, decimalResources, warehouseIndicator, loadAllAtOnce;

static NSString *viewTitle = @"Settings";

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
	
	[[self tableView] setBackgroundView:nil];

	[self.navigationItem setTitle:viewTitle];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	settings = [TMStorage sharedStorage].account.settings;

	[decimalResources setOn:settings.showsDecimalResources];
	[warehouseIndicator setOn:settings.showsResourceProgress];
	[loadAllAtOnce setOn:settings.loadsAllDataAtLogin];
	
	if ([self.tableView indexPathForSelectedRow] != nil) {
		[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
	}
	
	[super viewWillAppear:animated];
}

- (IBAction)changedDecimalResources:(id)sender {
	[settings setShowsDecimalResources:[decimalResources isOn]];
	[[TMStorage sharedStorage] saveData];
}
- (IBAction)changedWarehouseIndicator:(id)sender {
	[settings setShowsResourceProgress:[warehouseIndicator isOn]];
	[[TMStorage sharedStorage] saveData];
}
- (IBAction)loadAllAtOnce:(id)sender {
	[settings setLoadsAllDataAtLogin:loadAllAtOnce.isOn];
	[[TMStorage sharedStorage] saveData];
	[self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0 && indexPath.row == 0) {
		// Reload data
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	} else if (indexPath.section == 0 && indexPath.row == 1) {
		// Logout
		[[TMStorage sharedStorage].account deactivateAccount];
		[self.tabBarController setSelectedIndex:0];
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	} else if (indexPath.section == 1 && indexPath.row == 3) {
		//[tracker sendView:@"Credits"]; // Tell analytics we are viewing credits screen
	} else if (indexPath.section == 2) {
		TMAccount *a = [TMStorage sharedStorage].account;
		NSString *url = [[NSString stringWithFormat:@"http://%@.travian.%@/%@", a.world, a.server, [TMAccount resources]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		if (indexPath.row == 0) {
			// Open in safari
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"http://" stringByAppendingString:url]]];
		} else {
			// Open in chrome
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]]) {
				if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome-x-callback://"]]) {
					// Callback
					NSString *callbackUrl = [NSString stringWithFormat:@"googlechrome-x-callback://x-callback-url/open/?x-source=%@&x-success=%@&url=%@&create-new-tab",
									 @"TM", @"travian%3A%2F%2F", url];
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:callbackUrl]];
				} else {
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"googlechrome://" stringByAppendingString:url]]];
				}
			} else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/chrome/id535886823"]]; // Install Chrome
			}
		}
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	static NSString *notSelectedText = @"TM will only load a list of villages and unread messages count. This is the fastest and safest method.";
	static NSString *selectedText = @"TM will load all villages at login time. This takes a bit longer depending on how many villages you have. Not recommended for players with many villages.";
	if (section != 1) return nil;
	
	if (loadAllAtOnce.isOn) {
		return selectedText;
	}
	else {
		return notSelectedText;
	}
}

@end
