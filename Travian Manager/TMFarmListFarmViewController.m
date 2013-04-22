/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMFarmListFarmViewController.h"

@interface TMFarmListFarmViewController ()

@end

@implementation TMFarmListFarmViewController

@synthesize farm;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.tableView.backgroundView = nil;
	self.navigationItem.title = farm.targetName;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) return 2;
	return [farm.troops count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *DetailIdentifier = @"Detail";
	static NSString *RightDetailIdentifier = @"RightDetail";
	
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
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:RightDetailIdentifier forIndexPath:indexPath];
		NSDictionary *troop = [farm.troops objectAtIndex:indexPath.row];
		cell.textLabel.text = [troop objectForKey:@"name"];
		cell.detailTextLabel.text = [troop objectForKey:@"count"];
	}
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return farm.targetName;
	} else {
		return @"Troops";
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return [NSString stringWithFormat:@"%d troop type%@", farm.troops.count, farm.troops.count == 1 ? @"" : @"s"];
	}
	
	return nil;
}

@end
