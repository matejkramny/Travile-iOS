/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMSidePanelLeftViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"
#import "TMSidePanelViewController.h"
#import "TMStorage.h"
#import "TMAccount.h"
#import "TMVillage.h"
#import "AppDelegate.h"
#import "TMMovement.h"
#import "TMConstruction.h"
#import "TMDarkImageCell.h"
#import <QuartzCore/QuartzCore.h>

@interface TMSidePanelLeftViewController () {
	__weak TMStorage *storage;
	UIViewController *currentViewController;
	NSIndexPath *currentViewControllerIndexPath;
	bool showsVillage;
	NSIndexPath *currentVillageIndexPath; // indexpath of active village
	NSIndexPath *lastVillageIndexPath;
}

@end

@implementation TMSidePanelLeftViewController

static bool firstTime = true;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	static UIColor *backgroundImage;
	
	if (!backgroundImage) {
		backgroundImage = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TMDarkBackground.png"]];
	}
	
	showsVillage = false;
	
	[self.view setBackgroundColor:backgroundImage];
	[self.tableView setBackgroundColor:backgroundImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	storage = [TMStorage sharedStorage];
	[self.tableView setFrame:CGRectMake(0, 0, 256, 460)];
	
	if (firstTime) {
		firstTime = false;
		currentViewControllerIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
		currentViewController = [[TMSidePanelViewController sharedInstance] getMessages];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (showsVillage)
		return storage.account.village.movements.count == 0 && storage.account.village.constructions.count == 0 ? 2 : 3;
	else
		return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (showsVillage) {
		if (section == 0)
			return 1;
		else if (section == 1)
			return 5;
		else if (section == 2) {
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
			return 1;
		} else if (section == 1) {
			return 4;
		} else {
			return storage.account.villages.count;
		}
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
		heroImage = [UIImage imageNamed:@"108-badge-white.png"];
		messagesImage = [UIImage imageNamed:@"18-envelope-white.png"];
		reportsImage = [UIImage imageNamed:@"16-line-chart-white.png"];
		settingsImage = [UIImage imageNamed:@"20-gear2-white.png"];
	}
	
	TMDarkImageCell *cell = [tableView dequeueReusableCellWithIdentifier:BasicSelectableCellIdentifier forIndexPath:indexPath];
	if (!cell)
		cell = [[TMDarkImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BasicSelectableCellIdentifier];
	NSString *text;
	
	if (showsVillage) {
		[cell setIndentTitle:NO];
		if (indexPath.section == 0) {
			text = @"To Account";
			cell.imageView.image = nil;
		} else if (indexPath.section == 1) {
			[cell setIndentTitle:YES];
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
		}
	} else {
		if (indexPath.section == 0) {
			[cell setIndentTitle:NO];
			text = @"Logout";
			cell.imageView.image = nil;
		} else if (indexPath.section == 1) {
			[cell setIndentTitle:YES];
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
			[cell setIndentTitle:NO];
			text = [[storage.account.villages objectAtIndex:indexPath.row] name];
			cell.imageView.image = nil;
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
	
	[header setBackgroundColor:backgroundColor];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, header.frame.size.width-10, header.frame.size.height)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
	
	if (showsVillage) {
		if (section == 0) {
			return nil;
		} else if (section == 1) {
			label.text = [@"Village " stringByAppendingString:storage.account.village.name];
		} else {
			label.text = @"Village Events";
		}
	} else if (section == 0) {
		return nil;
	} else if (section == 1) {
		label.text = @"Account";
	} else if (section == 2) {
		label.text = @"Villages";
	}
	
	[header addSubview:label];
	
	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if ((showsVillage && (section == 1 || section == 2)) || (!showsVillage && (section == 1 || section == 2))) {
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
	
	if (showsVillage) {
		[transition setSubtype:kCATransitionFromRight];
	} else {
		[transition setSubtype:kCATransitionFromLeft];
	}
	
	[tableView reloadData];
	
	if (!showsVillage && storage.account.village != nil) {
		// Not showing village and village is still active
	}
	
	[[tableView layer] addAnimation:transition forKey:@"UITableViewReloadDataAnimationKey"];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	TMSidePanelViewController *panel = [TMSidePanelViewController sharedInstance];
	UIViewController *newVC = nil;
	NSIndexPath *path = indexPath;
	
	if (showsVillage) {
		if (indexPath.section == 0) {
			showsVillage = false;
			[storage.account setVillage:nil];
			[self transitionTableContent:tableView];
			[tableView selectRowAtIndexPath:currentVillageIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
			return;
		} else if (indexPath.section == 1) {
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
			lastVillageIndexPath = indexPath;
		} else {
			// Movements & constructions / events
			newVC = [panel getVillageOverview];
			path = [NSIndexPath indexPathForRow:0 inSection:0];
			[tableView deselectRowAtIndexPath:indexPath animated:NO];
			[tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
		}
	} else {
		if (indexPath.section == 0) {
			[storage.account deactivateAccount];
			
			firstTime = YES;
			
			// Close the left panel
			[self.sidePanelController toggleLeftPanel:self];
			
			// Dismiss the view *after* the left panel closes
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.2f * NSEC_PER_SEC);
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				[self dismissViewControllerAnimated:YES completion:nil];
			});
			
			return;
		} else if (indexPath.section == 1) {
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
		} else {
			showsVillage = true;
			[storage.account setVillage:[storage.account.villages objectAtIndex:indexPath.row]];
			currentVillageIndexPath = indexPath;
			[self transitionTableContent:tableView];
			[tableView selectRowAtIndexPath:lastVillageIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
			return;
		}
	}
	
	currentViewController = newVC;
	currentViewControllerIndexPath = path;
	[self.sidePanelController setCenterPanel:newVC];
}

#pragma mark -

- (void)didBecomeActiveAsPanelAnimated:(BOOL)animated {
	[self.tableView reloadData];
	
	if (!currentViewController) {
		currentViewController = [TMSidePanelViewController sharedInstance].villageOverview;
	}
	if (!currentViewControllerIndexPath) {
		currentViewControllerIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	}
	
	[self.tableView selectRowAtIndexPath:currentViewControllerIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

@end
