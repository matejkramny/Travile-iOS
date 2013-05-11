/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMSidePanelViewController.h"
#import "TMVillageOverviewViewController.h"
#import "TMVillageResourcesViewController.h"
#import "TMVillageTroopsViewController.h"
#import "TMVillageBuildingsViewController.h"

@interface TMSidePanelViewController () {
}

@end

@implementation TMSidePanelViewController

@synthesize villageOverview, villageResources, villageTroops, villageBuildings, villageFarmlist, messages, reports, hero, settings;

static NSString *villageOverviewIdentifier = @"villageOverview";
static NSString *villageResourcesIdentifier = @"villageResources";
static NSString *villageTroopsIdentifier = @"villageTroops";
static NSString *villageBuildingsIdentifier = @"villageBuildings";
static NSString *villageFarmlistIdentifier = @"villageFarmList";
static NSString *messagesIdentifier = @"messages";
static NSString *reportsIdentifier = @"reports";
static NSString *heroIdentifier = @"hero";
static NSString *settingsIdentifier = @"settings";

static TMSidePanelViewController *instance;

- (void)awakeFromNib {
	instance = self;
	
	[self setShouldResizeLeftPanel:NO];
	[self setBounceOnSidePanelOpen:NO];
	[self setBounceOnSidePanelClose:NO];
	[self setAllowLeftOverpan:NO];
	[self setBounceOnCenterPanelChange:NO];
	
	[self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"sidebarVillage"]];
	[self setCenterPanel:[self getSettings]];
}

+ (TMSidePanelViewController *)sharedInstance {
	return instance;
}

- (void)dealloc {
	villageOverview = nil;
	villageResources = nil;
	villageTroops = nil;
	villageBuildings = nil;
	villageFarmlist = nil;
}

- (UIViewController *)getMessages {
	if (!messages) messages = [self.storyboard instantiateViewControllerWithIdentifier:messagesIdentifier];
	
	return messages;
}

- (UIViewController *)getReports {
	if (!reports) reports = [self.storyboard instantiateViewControllerWithIdentifier:reportsIdentifier];
	
	return reports;
}

- (UIViewController *)getHero {
	if (!hero) hero = [self.storyboard instantiateViewControllerWithIdentifier:heroIdentifier];
	
	return hero;
}

- (UIViewController *)getSettings {
	if (!settings) settings = [self.storyboard instantiateViewControllerWithIdentifier:settingsIdentifier];
	
	return settings;
}

- (UIViewController *)getVillageOverview {
	if (!villageOverview) villageOverview = [self.storyboard instantiateViewControllerWithIdentifier:villageOverviewIdentifier];
	
	return villageOverview;
}

- (UIViewController *)getVillageResources {
	if (!villageResources) villageResources = [self.storyboard instantiateViewControllerWithIdentifier:villageResourcesIdentifier];
	
	return villageResources;
}

- (UIViewController *)getVillageTroops {
	if (!villageTroops) villageTroops = [self.storyboard instantiateViewControllerWithIdentifier:villageTroopsIdentifier];
	
	return villageTroops;
}

- (UIViewController *)getVillageBuildings {
	if (!villageBuildings) villageBuildings = [self.storyboard instantiateViewControllerWithIdentifier:villageBuildingsIdentifier];
	
	return villageBuildings;
}

- (UIViewController *)getFarmList {
	if (!villageFarmlist) villageFarmlist = [self.storyboard instantiateViewControllerWithIdentifier:villageFarmlistIdentifier];
	
	return villageFarmlist;
}

@end
