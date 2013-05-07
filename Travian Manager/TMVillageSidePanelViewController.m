/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMVillageSidePanelViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "TMVillagePanelViewController.h"
#import "TMStorage.h"
#import "TMAccount.h"
#import "TMVillage.h"
#import "AppDelegate.h"
#import "TMMovement.h"
#import "TMConstruction.h"
#import "TMDarkImageCell.h"
#import <QuartzCore/QuartzCore.h>

@interface TMVillageSidePanelViewController () {
	__weak TMStorage *storage;
	UIViewController *currentViewController;
	NSIndexPath *currentViewControllerIndexPath;
	bool showsVillages;
	bool showsVillage;
}

@end

@implementation TMVillageSidePanelViewController

@synthesize headerTable, contentTable;

static bool firstTime = true;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	static UIColor *backgroundImage;
	
	if (!backgroundImage) {
		backgroundImage = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TMDarkBackground.png"]];
	}
	
	[self.view setBackgroundColor:backgroundImage];
	
	showsVillages = false;
	[headerTable setBackgroundColor:backgroundImage];
	[contentTable setBackgroundColor:backgroundImage];
	
	[headerTable setFrame:CGRectMake(0, 0, 256, 44)];
	[contentTable setFrame:CGRectMake(0, 88, 256, 372)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	storage = [TMStorage sharedStorage];
	
	if (firstTime) {
		firstTime = false;
		currentViewControllerIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		currentViewController = [[TMVillagePanelViewController sharedInstance] getReports];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (tableView == headerTable)
		return 1;
	
	if (showsVillages)
		return 1;
	else if (showsVillage)
		return storage.account.village.movements.count == 0 && storage.account.village.constructions.count == 0 ? 1 : 2;
	else
		return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == headerTable)
		return 2;
	
	if (showsVillages)
		return storage.account.villages.count;
	
	if (showsVillage) {		
		if (section == 0)
			return 5;
		else if (section == 1) {
			TMVillage *village = [storage account].village;
			int count = 0;
			if (village.movements && [village.movements count] > 0)
				count += [village.movements count];
			if (village.constructions)
				count += [village.constructions count];
			
			return count;
		}
	} else {
		if (section == 0) {
			return 4;
		} else {
			return storage.account.villages.count;
		}
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *BasicCellIdentifier = @"Basic";
	static NSString *BasicSelectableCellIdentifier = @"BasicSelectable";
	static UIImage *overviewImage;
	static UIImage *resourcesImage;
	static UIImage *troopsImage;
	static UIImage *buildingsImage;
	static UIImage *villagesImage;
	static UIImage *farmlistImage;
	static UIImage *accountImage;
	static UIImage *messagesImage;
	static UIImage *reportsImage;
	static UIImage *settingsImage;
	static UIImage *heroImage;
	
	if (!overviewImage) {
		overviewImage = [UIImage imageNamed:@"53-house-white.png"];
		resourcesImage = [UIImage imageNamed:@"48-fork-and-knife-white.png"];
		troopsImage = [UIImage imageNamed:@"115-bow-and-arrow-white.png"];
		buildingsImage = [UIImage imageNamed:@"177-building-white.png"];
		villagesImage = [UIImage imageNamed:@"60-signpost-white.png"];
		farmlistImage = [UIImage imageNamed:@"134-viking-white.png"];
		accountImage = [UIImage imageNamed:@"21-skull-white.png"];
		heroImage = [UIImage imageNamed:@"108-badge.png"];
		messagesImage = [UIImage imageNamed:@"18-envelope-white.png"];
		reportsImage = [UIImage imageNamed:@"16-line-chart.png"];
		settingsImage = [UIImage imageNamed:@"20-gear2.png"];
	}
	
	if (tableView == headerTable) {
		TMDarkImageCell *cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier forIndexPath:indexPath];
		if (!cell)
			cell = [[TMDarkImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BasicCellIdentifier];
		
		cell.indentTitle = YES;
		
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Account";
			cell.imageView.image = accountImage;
		} else {
			cell.textLabel.text = showsVillages ? @"To Village" : @"Switch Villages";
			cell.imageView.image = villagesImage;
		}
		
		[AppDelegate setDarkCellAppearance:cell forIndexPath:indexPath];
		
		return cell;
	}
	
	// contentTable
	
	TMDarkImageCell *cell = [tableView dequeueReusableCellWithIdentifier:BasicSelectableCellIdentifier forIndexPath:indexPath];
	if (!cell)
		cell = [[TMDarkImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BasicSelectableCellIdentifier];
	NSString *text;
	
	if (showsVillages) {
		TMVillage *village = [storage.account.villages objectAtIndex:indexPath.row];
		text = village.name;
		[cell.imageView setImage:nil];
		[cell setIndentTitle:NO];
		
		if (village == storage.account.village) {
			[tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
		}
	} else if (showsVillage) {
		[cell setIndentTitle:YES];
		
		if (indexPath.section == 0) {
			switch (indexPath.row) {
				case 0:
					text = @"Overview";
					cell.imageView.image = overviewImage;
					break;
				case 1:
					text = @"Resources";
					cell.imageView.image = resourcesImage;
					break;
				case 2:
					text = @"Troops";
					cell.imageView.image = troopsImage;
					break;
				case 3:
					text = @"Buildings";
					cell.imageView.image = buildingsImage;
					break;
				case 4:
					text = @"Farm List";
					cell.imageView.image = farmlistImage;
					break;
			}
		} else {
			// Movements & constructions section / events
			TMVillage *village = [storage account].village;
			if (village.movements && [village.movements count] > 0 && indexPath.row < [village.movements count]) {
				text = [(TMMovement *)[village.movements objectAtIndex:indexPath.row] name];
			} else {
				int row = indexPath.row;
				if (village.movements)
					row -= village.movements.count;
				
				text = [(TMConstruction *)[village.constructions objectAtIndex:row] name];
			}
			[cell setIndentTitle:NO];
		}
	} else {
		[cell setIndentTitle:YES];
		if (indexPath.section == 0) {
			switch (indexPath.row) {
				case 0:
					text = @"Messages";
					cell.imageView.image = messagesImage;
					break;
				case 1:
					text = @"Reports";
					cell.imageView.image = reportsImage;
					break;
				case 2:
					text = @"Hero";
					cell.imageView.image = heroImage;
					break;
				case 3:
					text = @"Settings";
					cell.imageView.image = settingsImage;
					break;
			}
		} else {
			text = [[storage.account.villages objectAtIndex:indexPath.row] name];
		}
	}
	
	cell.textLabel.text = text;
	
	[AppDelegate setDarkCellAppearance:cell forIndexPath:indexPath];
	
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	static UIColor *backgroundColor;
	if (!backgroundColor)
		backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"DarkSection.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0]];
	
	UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 35)];
	
	if (tableView == contentTable) {
		[header setBackgroundColor:backgroundColor];
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, header.frame.size.width-10, header.frame.size.height)];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor whiteColor];
		label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
		
		if (showsVillages) {
			label.text = [storage.account.username stringByAppendingString:@"'s Villages"];
		} else if (showsVillage) {
			if (section == 0) {
				label.text = [@"Village " stringByAppendingString:storage.account.village.name];
			} else {
				label.text = @"Village Events";
			}
		} else {
			label.text = @"Account";
		}
		
		[header addSubview:label];
	} else {
		[header setBackgroundColor:[UIColor clearColor]];
	}
	
	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (tableView == contentTable && (section == 0 || section == 1)) {
		return 35;
	}
	
	return 0;
}

- (void)back:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view delegate

- (void)transitionTableContent:(UITableView *)tableView {
	// Animates the tableview reload
	CATransition *transition = [CATransition animation];
	[transition setType:kCATransitionPush];
	[transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[transition setFillMode:kCAFillModeBoth];
	[transition setDuration:0.2];
	
	if (showsVillages) {
		[transition setSubtype:kCATransitionFromLeft];
	} else {
		[transition setSubtype:kCATransitionFromRight];
	}
	
	[tableView reloadData];
	[[tableView layer] addAnimation:transition forKey:@"UITableViewReloadDataAnimationKey"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	TMVillagePanelViewController *panel = [TMVillagePanelViewController sharedInstance];
	UIViewController *newVC = nil;
	NSIndexPath *path = indexPath;
	
	if (tableView == headerTable) {
		if (indexPath.row == 0) {
			// To account
			[self back:nil];
			return;
		}
		
		showsVillages = !showsVillages;
		
		[self transitionTableContent:contentTable];
		[self transitionTableContent:headerTable];
		if (!showsVillages)
			[contentTable selectRowAtIndexPath:currentViewControllerIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
		
		[headerTable deselectRowAtIndexPath:indexPath animated:YES];
		
		return;
	} else if (showsVillages) {
		// Switch to the village.
		TMVillage *village = [storage.account.villages objectAtIndex:indexPath.row];
		[storage.account setVillage:village];
		
		showsVillages = false;
		path = currentViewControllerIndexPath;
		newVC = currentViewController;
		
		if (newVC == nil) {
			newVC = [panel getVillageOverview];
			path = [NSIndexPath indexPathForRow:0 inSection:0];
		}
		
		self.navigationItem.title = village.name;
		[newVC viewWillAppear:NO]; // Simulate appearance
		[newVC viewDidAppear:NO];
		
		[self transitionTableContent:contentTable];
		[self transitionTableContent:headerTable];
	} else if (showsVillage) {
		if (indexPath.section == 0) {
			if (indexPath.row == 0)
				newVC = [panel getVillageOverview];
			else if (indexPath.row == 1)
				newVC = [panel getVillageResources];
			else if (indexPath.row == 2)
				newVC = [panel getVillageTroops];
			else if (indexPath.row == 3)
				newVC = [panel getVillageBuildings];
			else if (indexPath.row == 4)
				newVC = [panel getFarmList];
		} else {
			// Movements & constructions / events
			newVC = [panel getVillageOverview];
			path = [NSIndexPath indexPathForRow:0 inSection:0];
			[tableView deselectRowAtIndexPath:indexPath animated:NO];
			[tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
		}
	} else {
		if (indexPath.section == 0) {
			switch (indexPath.row) {
				case 0:
					newVC = [panel getMessages];
					break;
				case 1:
					newVC = [panel getReports];
					break;
				case 2:
					newVC = [panel getHero];
					break;
				case 3:
					newVC = [panel getSettings];
					break;
			}
		}
	}
	
	currentViewController = newVC;
	currentViewControllerIndexPath = path;
	[self.sidePanelController setCenterPanel:newVC];
}

#pragma mark - JASidePanelDelegate

- (void)didBecomeActiveAsPanelAnimated:(BOOL)animated withBounce:(BOOL)withBounce {
	[contentTable reloadData];
	
	if (!currentViewController) {
		currentViewController = [TMVillagePanelViewController sharedInstance].villageOverview;
	}
	if (!currentViewControllerIndexPath) {
		currentViewControllerIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	}
	
	[contentTable selectRowAtIndexPath:currentViewControllerIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

@end
