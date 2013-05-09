/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMSettingsViewController.h"
#import "TMStorage.h"
#import "TMAccount.h"
#import "MBProgressHUD.h"
#import "TMSettings.h"
#import "AppDelegate.h"
#import "TMBasicToggleCell.h"

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
	[loadAllAtOnce setOn:settings.fastLogin];
	
	if ([self.tableView indexPathForSelectedRow] != nil) {
		[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
	} else {
		[self.tableView reloadData];
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
	[settings setFastLogin:loadAllAtOnce.isOn];
	[[TMStorage sharedStorage] saveData];
	[self.tableView reloadData];
}

#pragma mark - Table view delegate

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 3;
		case 1:
		case 2:
			return 2;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *basicCellIdentifier = @"BasicCell";
	static NSString *basicCellSelectableIdentifier = @"BasicCellSelectable";
	static NSString *basicToggleCellIdentifier = @"BasicToggle";
	
	if (indexPath.section == 0) {
		TMBasicToggleCell *cell = [tableView dequeueReusableCellWithIdentifier:basicToggleCellIdentifier];
		if (!cell) {
			cell = [[TMBasicToggleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:basicToggleCellIdentifier];
		}
		
		if (indexPath.row == 0) {
			cell.title.text = @"Decimal Resources";
			[cell.toggle setOn:settings.showsDecimalResources];
			[cell.toggle addTarget:self action:@selector(changedDecimalResources:) forControlEvents:UIControlEventTouchUpInside];
			decimalResources = cell.toggle;
		} else if (indexPath.row == 1) {
			cell.title.text = @"Warehouse Indicator";
			[cell.toggle setOn:settings.showsResourceProgress];
			[cell.toggle addTarget:self action:@selector(changedWarehouseIndicator:) forControlEvents:UIControlEventTouchUpInside];
			warehouseIndicator = cell.toggle;
		} else if (indexPath.row == 2) {
			cell.title.text = @"Fast login";
			[cell.toggle setOn:settings.fastLogin];
			[cell.toggle addTarget:self action:@selector(loadAllAtOnce:) forControlEvents:UIControlEventTouchUpInside];
			loadAllAtOnce = cell.toggle;
		}
		
		return cell;
	} else if (indexPath.section == 1) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:basicCellSelectableIdentifier];
		
		if (indexPath.row == 0)
			cell.textLabel.text = @"Credits";
		else
			cell.textLabel.text = @"Contact Support";
		
		[AppDelegate setRoundedCellAppearance:cell forIndexPath:indexPath forLastRow:indexPath.row == 1];
		
		[cell.textLabel setBackgroundColor:[UIColor clearColor]];
		
		return cell;
	} else if (indexPath.section == 2) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:basicCellSelectableIdentifier];
		
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Browse in Safari";
		} else {
			cell.textLabel.text = @"Browse in Google Chrome";
		}
		
		[AppDelegate setRoundedCellAppearance:cell forIndexPath:indexPath forLastRow:indexPath.row == 1];
		
		return cell;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1) {
		if (indexPath.row == 0)
			[self performSegueWithIdentifier:@"OpenCredits" sender:self];
		else {
			[AppDelegate openSupportEmail];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
	} else if (indexPath.section == 2) {
		TMAccount *a = [TMStorage sharedStorage].account;
		NSString *url = [[NSString stringWithFormat:@"http://%@.travian.%@/%@", a.world, a.server, [TMAccount resources]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		
		if (indexPath.row == 0) {
			// Open in safari
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Account Settings";
		default:
			return nil;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	static NSString *selectedText = @"App will only load a list of villages and unread messages count. This is the fastest and safest method.";
	static NSString *notSelectedText = @"App will load all villages at login time. This takes a bit longer depending on how many villages you have. Not recommended for players with many villages.";
	if (section != 0) return nil;
	
	if (settings.fastLogin) {
		return selectedText;
	}
	else {
		return notSelectedText;
	}
}

@end
