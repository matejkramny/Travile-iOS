//
//  AppDelegate.m
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Storage.h"

@implementation AppDelegate {
	unsigned int timeAtGoingToInactiveState; // States the time when the app resignsActive
}

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Sets appearance for UI
	[self customizeAppearance];
	
	// Initialize storage
	[Storage sharedStorage].delegate = self;
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	//NSLog(@"Resigning active state");
	timeAtGoingToInactiveState = [[NSDate date] timeIntervalSince1970];
	//NSLog(@"%d", timeAtGoingToInactiveState);
}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {
	//NSLog(@"Not in background anymore.. Entering foreground");
	if (timeAtGoingToInactiveState != 0) {
		
		unsigned int now = [[NSDate date] timeIntervalSince1970];
		NSLog(@"%d", now);
		if (timeAtGoingToInactiveState - now > 5) {
			// 50 second
			[Storage sharedStorage].account = nil;
		}
	}
}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

@end

@implementation AppDelegate (Appearance)

- (void)customizeAppearance {
	// Tiled background image
	UIImage *background = [[UIImage imageNamed:@"UINavigationBar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 0, 31.5, 0)];
	// Landscape
	UIImage *backgroundLandscape = [UIImage imageNamed:@"UINavigationBarLandscape.png"];
	
	// Set background
	[[UINavigationBar appearance] setBackgroundImage:background forBarMetrics:UIBarMetricsDefault];
	[[UINavigationBar appearance] setBackgroundImage:backgroundLandscape forBarMetrics:UIBarMetricsLandscapePhone];
	
	// Set Navigation Bar text
	[[UINavigationBar appearance] setTitleTextAttributes:@{
							   UITextAttributeTextColor : [UIColor colorWithRed:60.0/255.0 green:70.0/255.0 blue:81.0/255.0 alpha:1.0],
						 UITextAttributeTextShadowColor : [UIColor colorWithRed:126.0/255.0 green:126.0/255.0 blue:126.0/255.0 alpha:0.5],
						UITextAttributeTextShadowOffset : [NSValue valueWithCGSize:CGSizeMake(0, -1)],
									UITextAttributeFont : [UIFont fontWithName:@"Arial Rounded MT Bold" size:20.0] }];
	
	// Back Button
	UIImage *backButton = [[UIImage imageNamed:@"BackButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 8)];
	// Landscape
	UIImage *backButtonLandscape = [[UIImage imageNamed:@"BackButtonLandscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 8)];
	
	// Button (normal state)
	UIImage *button = [[UIImage imageNamed:@"ButtonStateNormal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
	// Lanscape
	UIImage *buttonLandscape = [[UIImage imageNamed:@"ButtonStyleNormalLandscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
	
	// Set Button
	[[UIBarButtonItem appearance] setBackgroundImage:button forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[[UIBarButtonItem appearance] setBackgroundImage:buttonLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
	// Set Back Button
	[[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
	
	[[UITableView appearance] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"TMBackground.png"]]];
}

static UIImageView *tableCellSelectedBackground;
static UIImage *detailAccessoryViewImage;

// Set appearance of cell based on indexPath
+ (void)setCellAppearance:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	UIView *bg = [[UIView alloc] init];
	
	// Odd vs even row
	if (indexPath.row % 2)
		[bg setBackgroundColor:[UIColor colorWithWhite:0.98 alpha:0.8]];
	else
		[bg setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
	
	// Background
	cell.backgroundView = bg;
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	
	if (!tableCellSelectedBackground)
		tableCellSelectedBackground = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SelectedCell.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0]];
	
	// Selected background
	cell.selectedBackgroundView = tableCellSelectedBackground;
	cell.textLabel.highlightedTextColor = [UIColor whiteColor];
	cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
}

+ (UIView *)setDetailAccessoryViewForTarget:(id)target action:(SEL)selector {
	// Detail view
	if (!detailAccessoryViewImage)
		detailAccessoryViewImage = [UIImage imageNamed:@"ArrowIcon.png"];
	
	CGRect frame = CGRectMake(0, 0, detailAccessoryViewImage.size.width, detailAccessoryViewImage.size.height);
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	
	[button setFrame:frame];
	[button setBackgroundImage:detailAccessoryViewImage forState:UIControlStateNormal];
	[button setBackgroundColor:[UIColor clearColor]];
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}

@end
