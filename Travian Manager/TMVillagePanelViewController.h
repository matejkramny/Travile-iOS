/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"

@interface TMVillagePanelViewController : JASidePanelController

@property (nonatomic, strong, getter = getVillageOverview) UIViewController *villageOverview;
@property (nonatomic, strong, getter = getVillageResources) UIViewController *villageResources;
@property (nonatomic, strong, getter = getVillageTroops) UIViewController *villageTroops;
@property (nonatomic, strong, getter = getVillageBuildings) UIViewController *villageBuildings;
@property (nonatomic, strong, getter = getFarmList) UIViewController *villageFarmlist;

@property (nonatomic, strong, getter = getMessages) UIViewController *messages;
@property (nonatomic, strong, getter = getReports) UIViewController *reports;
@property (nonatomic, strong, getter = getHero) UIViewController *hero;
@property (nonatomic, strong, getter = getSettings) UIViewController *settings;

+ (TMVillagePanelViewController *)sharedInstance;

@end
