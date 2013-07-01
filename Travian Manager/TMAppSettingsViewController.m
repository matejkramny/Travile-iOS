/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMAppSettingsViewController.h"
#import "TMApplicationSettings.h"
#import "TMBasicToggleCell.h"
#import "TMStorage.h"
#import "AppDelegate.h"

@interface TMAppSettingsViewController () {
	TMApplicationSettings *settings;
	UISwitch *icloudSwitch;
	UISwitch *pushNotificationSwitch;
}

@end

@implementation TMAppSettingsViewController

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
	[[self tableView] setBackgroundView:nil];
	
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	settings = [TMStorage sharedStorage].appSettings;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"BasicToggle";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	if (!cell) {
		cell = [[TMBasicToggleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	if (indexPath.section == 1) {
		[[(TMBasicToggleCell *)cell title] setText:@"iCloud"];
		icloudSwitch = [(TMBasicToggleCell *)cell toggle];
		[icloudSwitch setOn:settings.ICloud];
		[icloudSwitch addTarget:self action:@selector(icloudSwitchToggled:) forControlEvents:UIControlEventValueChanged];
	} else {
		[[(TMBasicToggleCell *)cell title] setText:@"Push Notifications"];
		pushNotificationSwitch = [(TMBasicToggleCell *)cell toggle];
		[pushNotificationSwitch setOn:settings.pushNotifications];
		[pushNotificationSwitch addTarget:self action:@selector(pushNotificationSwitchToggled:) forControlEvents:UIControlEventValueChanged];
	}
	
	[AppDelegate setRoundedCellAppearance:cell forIndexPath:indexPath forLastRow:NO];
	
	return cell;
}

- (void)icloudSwitchToggled:(id)sender {
	settings.ICloud = [icloudSwitch isOn];
}
- (void)pushNotificationSwitchToggled:(id)sender {
	settings.pushNotifications = [pushNotificationSwitch isOn];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	static NSString *icloud = @"Enable saving documents to iCloud";
	static NSString *pushNotifications = @"Receive scheduled push notifications";
	
	if (section == 1) {
		return [@"Travian Reader\nv" stringByAppendingFormat:@"%@\n© 2013 Matej Kramny", [AppDelegate getAppVersion]];
	}
	
	if (section == 2)
		return icloud;
	else
		return pushNotifications;
}

#pragma mark - Table view delegate

- (IBAction)returnToAccounts:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
