/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMVillagePanelViewController.h"
#import "TMVillageOverviewViewController.h"
#import "TMVillageResourcesViewController.h"
#import "TMVillageTroopsViewController.h"
#import "TMVillageBuildingsViewController.h"

@interface TMVillagePanelViewController () {
}

@end

@implementation TMVillagePanelViewController

@synthesize villageOverview, villageResources, villageTroops, villageBuildings;

static NSString *villageOverviewIdentifier = @"villageOverview";
static NSString *villageResourcesIdentifier = @"villageResources";
static NSString *villageTroopsIdentifier = @"villageTroops";
static NSString *villageBuildingsIdentifier = @"villageBuildings";

static TMVillagePanelViewController *instance;

- (void)awakeFromNib {
	instance = self;
	
	[self setShouldResizeLeftPanel:YES];
	[self setBounceOnSidePanelOpen:NO];
	[self setBounceOnSidePanelClose:NO];
	[self setAllowLeftOverpan:NO];
	[self setBounceOnCenterPanelChange:NO];
	
	villageOverview = [self.storyboard instantiateViewControllerWithIdentifier:villageOverviewIdentifier];
	villageResources = [self.storyboard instantiateViewControllerWithIdentifier:villageResourcesIdentifier];
	villageTroops = [self.storyboard instantiateViewControllerWithIdentifier:villageTroopsIdentifier];
	villageBuildings = [self.storyboard instantiateViewControllerWithIdentifier:villageBuildingsIdentifier];
	
	[self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"sidebarVillage"]];
	[self setCenterPanel:villageOverview];
}

+ (TMVillagePanelViewController *)sharedInstance {
	return instance;
}

- (void)dealloc {
	villageOverview = nil;
	villageResources = nil;
	villageTroops = nil;
	villageBuildings = nil;
}

@end
