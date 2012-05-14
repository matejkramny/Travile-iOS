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
	
	[storage setActiveAccount:[[storage accounts] objectAtIndex:0]];
	
	return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[storage saveData];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

@end
