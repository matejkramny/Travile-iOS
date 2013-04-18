/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"

@interface TMVillagePanelViewController : JASidePanelController

@property (nonatomic, strong) UIViewController *villageOverview;
@property (nonatomic, strong) UIViewController *villageResources;
@property (nonatomic, strong) UIViewController *villageTroops;
@property (nonatomic, strong) UIViewController *villageBuildings;
@property (nonatomic, strong) UIViewController *villageFarmlist;

+ (TMVillagePanelViewController *)sharedInstance;

@end
