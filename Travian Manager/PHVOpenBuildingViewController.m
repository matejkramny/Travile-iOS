//
//  PHVOpenBuildingViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 01/08/2012.
//
//

#import "PHVOpenBuildingViewController.h"
#import "Building.h"
#import "Resources.h"
#import "PHVBuildingDescriptionViewController.h"

@interface PHVOpenBuildingViewController ()

@end

@implementation PHVOpenBuildingViewController
@synthesize level;
@synthesize wood;
@synthesize clay;
@synthesize iron;
@synthesize wheat;
@synthesize building;

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
	[super viewWillAppear:animated];
	
	void (^setIntToLabel)(UILabel *, int) = ^(UILabel *l, int val) {
		[l setText:[NSString stringWithFormat:@"%d", val]];
	};
	
	[[self navigationItem] setTitle:[building name]];
	
	setIntToLabel(level, building.level);
	setIntToLabel(wood, building.resources.wood);
	setIntToLabel(clay, building.resources.clay);
	setIntToLabel(iron, building.resources.iron);
	setIntToLabel(wheat, building.resources.wheat);
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[self delegate] phvOpenBuildingViewController:self didCloseBuilding:building];
}

- (void)viewDidUnload
{
	[self setLevel:nil];
	[self setWood:nil];
	[self setClay:nil];
	[self setIron:nil];
	[self setWheat:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if ([building level] == 0 && (([building page] & TPVillage) != 0))
		return 2;
	
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
		case 0:
			return [building description] == nil ? 1 : 2;
		case 1:
			if ([building level] == 0 && (([building page] & TPVillage) != 0))
				return 1;
			else
				return 4;
		case 2:
			return 1; // Build button
		default:
			return 0;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int sec = indexPath.section, row = indexPath.row;
	
	UITableViewCell *cell;
	
	if (sec == 0) {
		if ((row == 0 && [building description] == nil) || row == 1) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetail"];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [building level]];
			cell.textLabel.text = @"Level";
		} else if (row == 0) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"BasicSelectable"];
			cell.textLabel.text = @"Description";
		}
	} else if (sec == 1) {
		if ([building level] == 0 && (([building page] & TPVillage) != 0)) {
			cell = [tableView dequeueReusableCellWithIdentifier:@"BasicSelectable"];
			cell.textLabel.text = [NSString stringWithFormat:@"Build to level %d", [building level]+1];
		} else {
			// Resources
			cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetail"];
			switch (row) {
				case 0:
					cell.textLabel.text = @"Wood";
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [[building resources] wood]];
					break;
				case 1:
					cell.textLabel.text = @"Clay";
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [[building resources] clay]];
					break;
				case 2:
					cell.textLabel.text = @"Iron";
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [[building resources] iron]];
					break;
				case 3:
					cell.textLabel.text = @"Wheat";
					cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [[building resources] wheat]];
					break;
			}
		}
	} else if (sec == 2) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"BasicSelectable"];
		cell.textLabel.text = [NSString stringWithFormat:@"Build to level %d", [building level]+1];
	}
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Details";
		case 1:
			return [building level] == 0 && (([building page] & TPVillage) != 0) ? @"Actions" : @"Resources needed for next level";
		case 2:
			return @"Actions";
	}
	
	return @"";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
		// Description
		[self performSegueWithIdentifier:@"OpenDescription" sender:self];
	} else if (indexPath.section == 1 || indexPath.section == 2) {
		// Build button
		[[self delegate] phvOpenBuildingViewController:self didBuildBuilding:building];
	}
}

#pragma mark - Prepare for segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"OpenDescription"]) {
		PHVBuildingDescriptionViewController *vc = [segue destinationViewController];
		
		vc.building = building;
	}
}

@end
