/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMReportViewController.h"
#import "TMReport.h"
#import "TMResources.h"

@interface TMReportViewController () {
	NSMutableArray *sections;
}

@end

@implementation TMReportViewController

@synthesize report;

static NSString *BasicCell = @"Basic";
static NSString *RightDetailCell = @"RightDetail";

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self) {
	}
	return self;
}

- (void)viewDidLoad
{
	[self buildCells];
	
	[super viewDidLoad];
	[[self tableView] setBackgroundView:nil];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
	self.navigationItem.title = report.name;
}

- (NSArray *)getTroopCells:(NSDictionary *)dict {
	NSArray *troopNames = [dict objectForKey:@"troopNames"];
	NSArray *troops = [dict objectForKey:@"troops"];
	NSArray *troopCasualties = [dict objectForKey:@"casualties"];
	
	NSMutableArray *indexes = [[NSMutableArray alloc] init];
	int index = 0;
	for (NSString *troop in troops) {
		if (![troop isEqualToString:@"0"]) {
			[indexes addObject:[NSNumber numberWithInt:index]];
		}
		index++;
	}
	
	NSMutableArray *cells = [[NSMutableArray alloc] init];
	
	for (NSNumber *index in indexes) {
		UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:RightDetailCell];
		cell.textLabel.text = [troopNames objectAtIndex:[index intValue]];
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ sent %@ died", [troops objectAtIndex:[index intValue]], [troopCasualties objectAtIndex:[index intValue]]];
		
		[cells addObject:cell];
	}
	
	if ([indexes count] == 0) {
		UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:BasicCell];
		cell.textLabel.text = @"No troops";
		[cells addObject:cell];
	}
	
	return cells;
}

- (void)buildCells {
	NSArray *(^buildResourceCells)(TMResources *) = ^(TMResources *resources) {
		NSMutableArray *cells = [[NSMutableArray alloc] init];
		if (resources) {
			UITableViewCell *cell;
			TMResources *res = resources;
			
			cell = [self.tableView dequeueReusableCellWithIdentifier:RightDetailCell];
			cell.textLabel.text = @"Wood";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)res.wood];
			[cells addObject:cell];
			
			cell = [self.tableView dequeueReusableCellWithIdentifier:RightDetailCell];
			cell.textLabel.text = @"Clay";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)res.clay];
			[cells addObject:cell];
			
			cell = [self.tableView dequeueReusableCellWithIdentifier:RightDetailCell];
			cell.textLabel.text = @"Iron";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)res.iron];
			[cells addObject:cell];
			
			cell = [self.tableView dequeueReusableCellWithIdentifier:RightDetailCell];
			cell.textLabel.text = @"Wheat";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)res.wheat];
			[cells addObject:cell];
		}
		
		return cells;
	};
	
	sections = [[NSMutableArray alloc] init];
	
	if (report.trade) {
		// Trade scenario
		[sections addObject:@{
		 @"header": @"Trade",
		 @"footer": [report.trade objectForKey:@"header"],
		 @"cells": buildResourceCells([report.trade objectForKey:@"resources"])
		 }];
		[sections addObject:@{@"header": @"",
		 @"footer": [report.trade objectForKey:@"duration"],
		 @"cells": [NSArray array]}];
		return;
	}
	
	// Attacker
	[sections addObject:@{@"header": @"Attacker",
	 @"footer": [report.attacker objectForKey:@"name"],
	 @"cells": [self getTroopCells:report.attacker]}];
	 
	// bounty
	if (report.bounty || report.bountyResources) {
		[sections addObject:@{@"header": @"Bounty",
		 @"footer": report.bounty == nil ? @"" : report.bounty,
		 @"cells": buildResourceCells(report.bountyResources)}];
	}
	
	// information
	if (report.information && report.information.length > 0) {
		[sections addObject:@{@"header": @"",
		 @"footer": report.information,
		 @"cells": [NSArray array]}];
	}
	
	// Defenders
	int count = 0;
	for (NSDictionary *defender in report.defenders) {
		[sections addObject:@{@"header": count == 0 ? @"Defender" : @"",
		 @"footer": [defender objectForKey:@"name"],
		 @"cells": [self getTroopCells:defender]}];
		
		count++;
	}
	
	// Time of the report
	[sections addObject:@{@"header": @"",
	 @"footer": report.when,
	 @"cells": [NSArray array]}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[sections objectAtIndex:section] objectForKey:@"cells"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [[[sections objectAtIndex:indexPath.section] objectForKey:@"cells"] objectAtIndex:indexPath.row];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[sections objectAtIndex:section] objectForKey:@"header"];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return [[sections objectAtIndex:section] objectForKey:@"footer"];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{}

@end
