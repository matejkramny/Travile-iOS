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
#import "Building.h"
#import "TravianPages.h"
#import "HeroQuest.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize storage;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	storage = [[Storage alloc] init];
	
	// Auto-build timer
	NSTimer *timer __unused = [NSTimer scheduledTimerWithTimeInterval:390 target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
	
	return YES;
}

- (void)log:(id)sender {
	NSLog(@"Building a building..");
	
	NSArray *bu = [[[[storage account] villages] objectAtIndex:0] buildings];
	bool built = false;
	for (Building *b in bu) {
		if ([b level] < 1 && ([b page] & TPResources) != 0) {
			[b buildFromAccount:[storage account]];
			
			NSLog(@"Building %@", [b name]);
			built = true;
			
			break;
		}
	}
	
	if (!built) {
		NSLog(@"Nothing built");
	}
	
	NSLog(@"Sending hero on adventure");
	[[[[[storage account] hero] quests] objectAtIndex:0] startQuest:[storage account]];
	
}

- (void)refresh:(id)sender {
	
	NSLog(@"Refreshing account");
	[[storage account] refreshAccount];
	
	NSTimer *timer __unused = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(log:) userInfo:nil repeats:NO];
	
}
							
- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[storage saveData];
	
	//As we are going into the background, I want to start a background task to clean up the disk caches
	if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) { //Check if our iOS version supports multitasking I.E iOS 4
		if ([[UIDevice currentDevice] isMultitaskingSupported]) { //Check if device supports mulitasking
			[application beginBackgroundTaskWithExpirationHandler:^ {
				NSLog(@"Went to background");
			}];
		}
	}
}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

@end
