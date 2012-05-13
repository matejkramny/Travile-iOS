//
//  AppDelegate.m
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Account.h"
#import "Storage.h"
#import "Village.h"
#import "Hero.h"
#import "Resources.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize storage;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	storage = [[Storage alloc] init];
	
	Account *account = [[Account alloc] init];
	Village *village = [[Village alloc] init];
	Hero *hero = [[Hero alloc] init];
	Resources *resources = [[Resources alloc] init];
	Resources *resourcesProduction = [[Resources alloc] init];
	[resources setWood:200]; [resources setClay:200]; [resources setIron:200]; [resources setWheat:100];
	[resourcesProduction setWood:5]; [resourcesProduction setClay:5]; [resourcesProduction setIron:5]; [resourcesProduction setWheat:5];
	[hero setSpeed:4];
	[hero setStrengthPoints:80];
	[hero setOffBonusPercentage:2];
	[hero setDefBonusPercentage:2];
	[hero setIsHidden:YES];
	
	[village setResources:resources];
	[village setResourceProduction:resourcesProduction];
	
	[account setVillages:[NSArray arrayWithObjects:village, nil]];
	[account setName:@"Something personalised"];
	[account setHero:hero];
	
	NSArray *arr = [[NSArray alloc] initWithObjects:account, nil];
	
	[storage setAccounts:arr];
	[storage setAccount:[arr objectAtIndex:0]];
	
	[storage saveData];
	
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
