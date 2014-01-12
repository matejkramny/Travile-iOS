/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMFarmListViewController.h"
#import "TMStorage.h"
#import "TMVillage.h"
#import "TMAccount.h"
#import "TMFarmList.h"
#import "TMFarmListEntry.h"
#import "TMFarmListEntryFarm.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "TMSwipeableCell.h"
#import "TMDarkImageCell.h"
#import "TMFarmListFarmViewController.h"

@interface TMFarmListViewController () {
	TMStorage *storage;
	TMVillage *village;
	MBProgressHUD *HUD;
	UITapGestureRecognizer *tapToCancel;
	
	NSMutableArray *executionQueue;
	bool cancelledExecution;
	
	NSMutableArray *cells;
	
	NSIndexPath *highlightedFarmIndexPath;
}

@end

@implementation TMFarmListViewController

@synthesize openCellIndexPath, openCellLastTX;

static UIBarButtonItem *executeButton;

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
	
	storage = [TMStorage sharedStorage];
	village = [storage.account village];
	self.navigationItem.title = NSLocalizedString(@"Farm Lists", @"Farm lists view controller title");
	cells = [[NSMutableArray alloc] init];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(loadFarmLists) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (!executeButton)
		executeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Execute", @"Navigation bar button title to execute farm list") style:UIBarButtonItemStylePlain target:self action:@selector(executeFarmList:)];
	
	self.navigationItem.rightBarButtonItem = executeButton;
	
	[self setExecuteButtonEnabled];
	
	[storage.account addObserver:self forKeyPath:@"village" options:NSKeyValueObservingOptionNew context:nil];
	
	if (village != storage.account.village) {
		// Refresh
		village = storage.account.village;
		[self loadFarmLists];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (village.farmList == nil || village.farmList.loaded == false) {
		if (!village.farmList.loading)
			[self loadFarmLists];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	@try {
		[storage.account removeObserver:self forKeyPath:@"village"];
	}
	@catch (id exception) {
		// do nothing.. means it isn't registered as observer
	}
}

- (void)loadFarmLists {
	[self loadFarmLists:YES];
}
- (void)loadFarmLists:(bool)hud {
	if (hud) {
		// Load the farm list.
		HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
		[HUD setLabelText:NSLocalizedString(@"Loading", nil)];
		[HUD setDetailsLabelText:NSLocalizedString(@"Tap to cancel", @"Shown in HUD, informative to cancel the operation")];
		tapToCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToCancel:)];
		[HUD addGestureRecognizer:tapToCancel];
	}
	
	if (!village.farmList) {
		village.farmList = [[TMFarmList alloc] init];
	}
	[village.farmList loadFarmList:^(void) {
		if (HUD) {
			[HUD hide:YES];
			[HUD removeGestureRecognizer:tapToCancel];
			tapToCancel = nil;
			// preload
			//[self preloadCells];
			[self.tableView reloadData];
			
			if ([self.refreshControl isRefreshing])
				[self.refreshControl endRefreshing];
		}
	}];
}

- (void)tappedToCancel:(id)sender {
	[HUD hide:YES];
	[HUD removeGestureRecognizer:tapToCancel];
	tapToCancel = nil;
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.tableView numberOfSections])] withRowAnimation:UITableViewRowAnimationFade];
	
	if ([self.refreshControl isRefreshing])
		[self.refreshControl endRefreshing];
}

- (void)executeFarmList:(id)sender {
	if (!IsFULL && [AppDelegate hasExpired]) {
		[AppDelegate displayLiteWarning];
		
		return;
	}
	
	TMFarmListEntry *selectedEntry = nil;
	int selectedEntrySection = 0;
	for (TMFarmListEntry *entry in village.farmList.farmLists) {
		for (TMFarmListEntryFarm *farm in entry.farms) {
			if (farm.selected) {
				selectedEntry = entry;
				goto foundEntry;
			}
		}
		
		selectedEntrySection++;
	}
foundEntry:;
	
	if (selectedEntry) {
		HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
		HUD.labelText = [NSLocalizedString(@"Executing ", @"Executing farm list.. Eg.. 'Executing Natar farm list'. Farm list name is appended to this string!") stringByAppendingString:[selectedEntry name]];
		HUD.detailsLabelText = NSLocalizedString(@"Tap to hide", @"Shown in HUD, informative to hide the operation");
		tapToCancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToCancel:)];
		[HUD addGestureRecognizer:tapToCancel];
		
		[selectedEntry executeWithCompletion:^{
			[HUD setLabelText:NSLocalizedString(@"Loading Farm List", @"HUD title, loading X")];
			[self loadFarmLists:NO];
			
			for (TMFarmListEntryFarm *farm in selectedEntry.farms) {
				farm.selected = false;
			}
			
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:selectedEntrySection] withRowAnimation:UITableViewRowAnimationFade];
			[self setExecuteButtonEnabled];
		}];
	}
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"village"]) {
		if (village != storage.account.village && storage.account.village != nil) {
			// Refresh
			village = storage.account.village;
			[self loadFarmLists];
		}
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (village.farmList.farmLists.count > 0)
		return village.farmList.farmLists.count;
	
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *farmLists = [village.farmList farmLists];
	if (farmLists.count > 0) {
		TMFarmListEntry *entry = [farmLists objectAtIndex:section];
		if (entry.farms.count > 0) {
			return [[entry farms] count];
		}
	}
	
	return 1;
}

static TMDarkImageCell *backCell; // shared

- (void)buildBackCell {
	if (!backCell) {
		static UIColor *backViewColour;
		static NSString *BackCellIdentifier = @"DarkCell";
		if (!backViewColour) {
			backViewColour = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TMDarkBackground.png"]];
		}
		
		backCell = [self.tableView dequeueReusableCellWithIdentifier:BackCellIdentifier forIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		if (!backCell) {
			backCell = [[TMDarkImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BackCellIdentifier];
		}
		[AppDelegate setDarkCellAppearance:backCell forIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		
		[backCell setFrame:CGRectMake(320, 0, 320, 44)];
		[backCell setIndentTitle:NO];
		[backCell textLabel].text = NSLocalizedString(@"Pull to open", @"Farm list cell, shown while swiping the cell to the left.");
		[backCell setBackgroundView:nil];
		[backCell setBackgroundColor:backViewColour];
		UIView *backCellTextBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		[backCellTextBackgroundView setTag:22];
		[backCell addSubview:backCellTextBackgroundView];
		//[backCell sendSubviewToBack:backCellTextBackgroundView];
		[backCellTextBackgroundView addSubview:backCell.textLabel];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *BasicCellIdentifier = @"Basic";
	static NSString *SwipeableCellidentifier = @"Swipeable";
	
	NSArray *lists = [village.farmList farmLists];
	if (lists.count == 0 || [[lists objectAtIndex:indexPath.section] farms].count == 0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier];
		
		// Return no farms found || no farms in farm list
		if (lists.count == 0) {
			cell.textLabel.text = NSLocalizedString(@"No Farm lists found", @"No farm lists found informative text when no farm lists exist in the village");
		} else {
			cell.textLabel.text = NSLocalizedString(@"No Farms found", @"no farms found in the current farm list");
		}
		[AppDelegate setCellAppearance:cell forIndexPath:indexPath];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		return cell;
	}
	
	TMSwipeableCell *cell = [tableView dequeueReusableCellWithIdentifier:SwipeableCellidentifier forIndexPath:indexPath];
	if (!cell) {
		cell = [[TMSwipeableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SwipeableCellidentifier];
	}
	
	// Set the frontCell's content
	NSArray *farmList = [[village.farmList.farmLists objectAtIndex:indexPath.section] farms];
	TMFarmListEntryFarm *farm = [farmList objectAtIndex:indexPath.row];
	cell.farmName.text = farm.targetName;
	cell.accessoryType = farm.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.bountyString.text = farm.lastReportBounty;
	cell.lastAttackDate.text = farm.lastReportTime;
	cell.distanceLabel.text = [farm.distance stringByAppendingString:@" sq"];
	[cell configureReportStatus:farm.lastReport attacking:farm.attackInProgress];
	
	// Set the appearance of the cells
	[AppDelegate setCellAppearance:cell forIndexPath:indexPath];
	
	if (farm.attackInProgress) {
		cell.backgroundColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:0.8f];
	}
	
	//[cell addSubview:cell.frontView];
	
	cell.frontView = cell;
	
	// long-press to select all
	UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTableViewCellLongPress:)];
	[cell addGestureRecognizer:gesture];
	
	// swipe to reveal gesture
	UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[panGestureRecognizer setDelegate:self];
	[cell addGestureRecognizer:panGestureRecognizer];
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([village.farmList.farmLists count] == 0) return nil;
	
	TMFarmListEntry *entry = [village.farmList.farmLists objectAtIndex:section];
	return entry.name;
}

- (void)handleTableViewCellLongPress:(UILongPressGestureRecognizer *)gesture {
	if (gesture.state != UIGestureRecognizerStateBegan)
		return;
	
	UITableViewCell *cell = (UITableViewCell *)gesture.view;
	highlightedFarmIndexPath = [self.tableView indexPathForCell:cell];
	
	UIActionSheet *stateActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Nothing", @"Do nothing button") destructiveButtonTitle:NSLocalizedString(@"Deactivate farms", @"deactivate selected farms button") otherButtonTitles:NSLocalizedString(@"Activate farms", @"Activate selected farms button"), NSLocalizedString(@"Activate good farms", @"Activate only 'good' farms. These farms had no damage in previous report"), NSLocalizedString(@"Activate full-bounty farms", @"Button activates farms that returned with full bounty"), nil];
	[stateActionSheet showFromRect:self.view.frame inView:self.view animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"OpenFarm"]) {
		TMFarmListFarmViewController *farmVC = [segue destinationViewController];
		TMFarmListEntry *entry = [village.farmList.farmLists objectAtIndex:openCellIndexPath.section];
		TMFarmListEntryFarm *farm = [entry.farms objectAtIndex:openCellIndexPath.row];
		farmVC.farm = farm;
	}
}

- (void)setExecuteButtonEnabled {
	int selectedCount = 0;
	for (TMFarmListEntry *entry in village.farmList.farmLists) {
		for (TMFarmListEntryFarm *farm in entry.farms) {
			if (farm.selected) {
				selectedCount++;
			}
		}
	}
	
	if (selectedCount > 0) {
		[executeButton setEnabled:YES];
		[executeButton setTitle:[NSLocalizedString(@"Execute ", @"Execute farm list button. Farm name is appended to this string.") stringByAppendingFormat:@"%d", selectedCount]];
	} else {
		[executeButton setEnabled:NO];
		[executeButton setTitle:NSLocalizedString(@"Execute", nil)];
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (village.farmList.farmLists.count == 0 || [[village.farmList.farmLists objectAtIndex:indexPath.section] farms].count == 0) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}
	
	int i = 0;
	for (TMFarmListEntry *entry in village.farmList.farmLists) {
		if (i == indexPath.section) {
			i++;
			continue;
		}
		
		bool toBeReloaded = false;
		for (TMFarmListEntryFarm *farm in entry.farms) {
			if (farm.selected) {
				farm.selected = false;
				toBeReloaded = true;
			}
		}
		
		if (toBeReloaded)
			[tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationFade];
		
		i++;
	}
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	TMFarmListEntry *farmList = [village.farmList.farmLists objectAtIndex:indexPath.section];
	TMFarmListEntryFarm *farm = [farmList.farms objectAtIndex:indexPath.row];
	farm.selected = !farm.selected;
	cell.accessoryType = [farm selected] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[self setExecuteButtonEnabled];
}

#pragma mark - Gesture recognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
	TMSwipeableCell *cell = (TMSwipeableCell *)[panGestureRecognizer view];
	CGPoint translation = [panGestureRecognizer translationInView:[cell superview] ];
	return (fabs(translation.x) / fabs(translation.y) > 1) ? YES : NO;
}

#pragma mark - Gesture handlers

-(void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer
{
	float threshold = -90;
	float vX = 0.0;
	float compare;
	NSIndexPath *indexPath = [self.tableView indexPathForCell:(TMSwipeableCell *)[panGestureRecognizer view] ];
	UIView *view = ((TMSwipeableCell *)panGestureRecognizer.view).frontView;
	
	TMSwipeableCell *cell = (TMSwipeableCell *)panGestureRecognizer.view;
	
	if (!backCell) [self buildBackCell];
	cell.backView = backCell;
	
	UITableViewCell *backCell = (UITableViewCell *)cell.backView;
	UIView *backCellTextBackgroundView = [backCell viewWithTag:22];
	
	void (^removeSubview)(void) = ^(void){
		[backCell removeFromSuperview];
	};
	switch ([panGestureRecognizer state]) {
		case UIGestureRecognizerStateBegan:
			if (self.openCellIndexPath.section != indexPath.section || self.openCellIndexPath.row != indexPath.row) {
				// set the text to Pull to open
			}
			[self snapView:backCellTextBackgroundView toX:0 animated:NO];
			[cell addSubview:backCell];
			
			break;
		case UIGestureRecognizerStateEnded:
			vX = (FAST_ANIMATION_DURATION/2.0)*[panGestureRecognizer velocityInView:self.view].x;
			compare = view.transform.tx + vX;
			
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, FAST_ANIMATION_DURATION * NSEC_PER_SEC);
			if (view.transform.tx > threshold) {
				// move back to PAN_CLOSED_X
				// do nothing
				[self snapView:backCellTextBackgroundView toX:100 animated:YES];
			} else {
				// open segue after the cell goes back to X 0
				dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
					[self performSegueWithIdentifier:@"OpenFarm" sender:nil];
					[self setOpenCellIndexPath:nil];
					[self setOpenCellLastTX:0];
					[self snapView:backCellTextBackgroundView toX:100 animated:NO];
				});
				[self snapView:backCellTextBackgroundView toX:0 animated:NO];
			}
			
			[self snapView:view toX:PAN_CLOSED_X animated:YES];
			
			dispatch_after(popTime, dispatch_get_main_queue(), removeSubview);
			
			[(TMSwipeableCell *)panGestureRecognizer.view setSelectionStyle:UITableViewCellSelectionStyleBlue];
			
			break;
		case UIGestureRecognizerStateChanged:
			compare = self.openCellLastTX+[panGestureRecognizer translationInView:self.view].x;
			if (compare > PAN_CLOSED_X) {
				compare = PAN_CLOSED_X;
			} else if (compare < PAN_OPEN_X) {
				compare = PAN_OPEN_X;
			}
			
			if (compare > threshold) {
				// text = pull to open
				backCell.textLabel.text = NSLocalizedString(@"Pull", @"Used to show the user to keep pulling (a cell in farm list)");
				//[backCell.textLabel setTransform:CGAffineTransformMakeTranslation(threshold*-1 + compare, 0)];
				[UIView animateWithDuration:FAST_ANIMATION_DURATION animations:^{
					[backCellTextBackgroundView setBackgroundColor:[UIColor colorWithRed:150.f/255.f green:180.f/255.f blue:56.f/255.f alpha:1.f]];
				} completion:nil];
				float newX = threshold * -1 + compare;
				if (newX < 0) newX = 0;
				
				[backCellTextBackgroundView setTransform:CGAffineTransformMakeTranslation(newX, 0)];
			} else {
				compare = threshold - ((threshold - compare) / 4); // Friction
				// text = release to open
				backCell.textLabel.text = NSLocalizedString(@"Release", @"Used to show the user that they can release the cell they are pulling");
				//[backCell.textLabel setFrame:CGRectMake(10, backCell.bounds.origin.y, backCell.bounds.size.width, backCell.bounds.size.height)];
				[UIView animateWithDuration:FAST_ANIMATION_DURATION animations:^{
					[backCellTextBackgroundView setBackgroundColor:[UIColor colorWithRed:126.f/255.f green:155.f/255.f blue:40.f/255.f alpha:1.f]];
				} completion:NULL];
				[backCellTextBackgroundView setFrame:CGRectMake(0, backCellTextBackgroundView.bounds.origin.y, backCellTextBackgroundView.bounds.size.width, backCellTextBackgroundView.bounds.size.height)];
			}
			
			openCellIndexPath = indexPath;
			
			[view setTransform:CGAffineTransformMakeTranslation(compare, 0)];
			
			break;
		default:
			break;
	}
}

-(void)snapView:(UIView *)view toX:(float)x animated:(BOOL)animated {
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:FAST_ANIMATION_DURATION];
	}
	
	[view setTransform:CGAffineTransformMakeTranslation(x, 0)];
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (openCellIndexPath) {
		TMSwipeableCell *cell = (TMSwipeableCell *)[self.tableView cellForRowAtIndexPath:openCellIndexPath];
		
		[self snapView:cell toX:0 animated:YES];
		
		[self setOpenCellIndexPath:nil];
		[self setOpenCellLastTX:0];
	}
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0 || buttonIndex == 1) {
		bool newState = (bool)buttonIndex;
		
		int i = 0;
		for (TMFarmListEntry *entry in village.farmList.farmLists) {
			bool toBeReloaded = false;
			for (TMFarmListEntryFarm *farm in entry.farms) {
				if (i == highlightedFarmIndexPath.section) {
					farm.selected = newState;
					toBeReloaded = true;
				} else if (newState == true && farm.selected == true) {
					farm.selected = false;
					toBeReloaded = true;
				}
			}
			
			if (toBeReloaded)
				[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationFade];
			
			i++;
		}
	} else if (buttonIndex == 2) {
		int i = 0;
		for (TMFarmListEntry *entry in village.farmList.farmLists) {
			bool toBeReloaded = false;
			for (TMFarmListEntryFarm *farm in entry.farms) {
				if (i == highlightedFarmIndexPath.section && (farm.lastReport & TMFarmListEntryFarmLastReportTypeLostNone) != 0) {
					farm.selected = true;
					toBeReloaded = true;
				} else if (farm.selected == true) {
					farm.selected = false;
					toBeReloaded = true;
				}
			}
			
			if (toBeReloaded)
				[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationFade];
			
			i++;
		}
	} else if (buttonIndex == 3) {
		int i = 0;
		for (TMFarmListEntry *entry in village.farmList.farmLists) {
			bool toBeReloaded = false;
			for (TMFarmListEntryFarm *farm in entry.farms) {
				if (i == highlightedFarmIndexPath.section && (farm.lastReport & TMFarmListEntryFarmLastReportTypeBountyFull) != 0) {
					farm.selected = true;
					toBeReloaded = true;
				} else if (farm.selected == true) {
					farm.selected = false;
					toBeReloaded = true;
				}
			}
			
			if (toBeReloaded)
				[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationFade];
			
			i++;
		}
	}
	
	
	[self setExecuteButtonEnabled];
}

@end
