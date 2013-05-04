/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMFarmListFarmViewController.h"
#import "AppDelegate.h"
#import "TMReport.h"
#import "TMReportViewController.h"
#import "MBProgressHUD.h"

@interface TMFarmListFarmViewController () {
	MBProgressHUD *HUD;
	UITapGestureRecognizer *tapToCancel;
}

@end

@implementation TMFarmListFarmViewController

@synthesize farm;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.tableView.backgroundView = nil;
	self.navigationItem.title = farm.targetName;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) return 2;
	if (section == 1) {
		return 2;
	}
	
	return [farm.troops count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *DetailIdentifier = @"Detail";
	static NSString *RightDetailIdentifier = @"RightDetail";
	static NSString *SelectableCellIdentifier = @"Selectable";
	
	UITableViewCell *cell;
	if (indexPath.section == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:DetailIdentifier forIndexPath:indexPath];
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Population";
			cell.detailTextLabel.text = farm.targetPopulation;
		} else {
			cell.textLabel.text = @"Distance";
			int squares = [farm.distance intValue];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ square%@", farm.distance, squares == 1 ? @"" : @"s"];
		}
	} else if (indexPath.section == 1) {
		
		if (indexPath.row == 0) {
			cell = [tableView dequeueReusableCellWithIdentifier:DetailIdentifier forIndexPath:indexPath];
			cell.textLabel.text = @"Time";
			cell.detailTextLabel.text = farm.lastReportTime;
		} else {
			cell = [tableView dequeueReusableCellWithIdentifier:SelectableCellIdentifier forIndexPath:indexPath];
			cell.textLabel.text = @"Open Report";
		}
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:RightDetailIdentifier forIndexPath:indexPath];
		NSDictionary *troop = [farm.troops objectAtIndex:indexPath.row];
		cell.textLabel.text = [troop objectForKey:@"name"];
		cell.detailTextLabel.text = [troop objectForKey:@"count"];
	}
	
	[AppDelegate setRoundedCellAppearance:cell forIndexPath:indexPath forLastRow:[tableView numberOfRowsInSection:indexPath.section]-1 == indexPath.row];
	
	return cell;
}

static TMReport *report;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1 && indexPath.row == 1) {
		// Open report
		if (farm.lastReportURL == nil) {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			return;
		}
		
		report = [[TMReport alloc] init];
		report.accessID = farm.lastReportURL;
		report.when = farm.lastReportTime;
		[report addObserver:self forKeyPath:@"parsed" options:NSKeyValueObservingOptionNew context:nil];
		[report downloadAndParse];
		HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
		HUD.labelText = @"Loading Report";
		HUD.detailsLabelText = @"Tap to Cancel";
		tapToCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToCancel:)];
		[HUD addGestureRecognizer:tapToCancel];
	} else {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == report) {
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
		TMReportViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"reportView"];
		[report removeObserver:self forKeyPath:@"parsed"];
		vc.report = report;
		[HUD hide:YES];
		[self.navigationController pushViewController:vc animated:YES];
	}
}

- (void)tappedToCancel:(id)sender {
	[HUD hide:YES];
	[report removeObserver:self forKeyPath:@"parsed"];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return farm.targetName;
	} else if (section == 1) {
		return @"Last Report";
	} else {
		return @"Troops";
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return farm.lastReportBounty;
	}
	if (section == 2) {
		return [NSString stringWithFormat:@"%d troop type%@", farm.troops.count, farm.troops.count == 1 ? @"" : @"s"];
	}
	
	return nil;
}

@end
