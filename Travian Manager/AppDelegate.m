/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "AppDelegate.h"
#import "TMStorage.h"
#import "TMAPNService.h"
#import "Flurry.h"
#import "FlurryAds.h"

@implementation AppDelegate {
	unsigned int timeAtGoingToInactiveState; // States the time when the app resignsActive
}

@synthesize window = _window;
@synthesize storage;

void uncaughtExceptionHandler(NSException *exception) {
	[Flurry logError:@"Uncaught" message:@"Crashed!" exception:exception];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	
	// Sets appearance for UI
	[self customizeAppearance];
	
	// Initialize storage
	[TMStorage sharedStorage].delegate = self;
	storage = [TMStorage sharedStorage];
	
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	
	[Flurry startSession:@"N6J2D56H5TFWSNNBKPB4"];
	[Flurry setDebugLogEnabled:NO];
	[FlurryAds initialize:self.window.rootViewController];
	
	// iCloud
	NSFileManager *fileManager = [NSFileManager defaultManager];
	id currentToken = [fileManager ubiquityIdentityToken];
	storage.signedIntoICloud = (currentToken!=nil);
	
	return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSString *token = [deviceToken description];
	[[TMAPNService sharedInstance] sendToken:token];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	//NSLog(@"Hey I just received a remote notification");
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	timeAtGoingToInactiveState = [[NSDate date] timeIntervalSince1970];
	[storage saveData];
}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {
	if (timeAtGoingToInactiveState != 0) {
		
		unsigned int now = [[NSDate date] timeIntervalSince1970];
		
		if (timeAtGoingToInactiveState - now > 5) {
			// 5 second
			// TODO Ask to log back in
		}
	}
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}
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
	
	// SegmentedControl
	[[UISegmentedControl appearance] setBackgroundImage:button forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	//[[UISegmentedControl appearance] setDividerImage:background forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault]; // Requires its own image.. This is for segmented control's middle gap image.
	
	// Table background
	[[UITableView appearance] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"TMBackground.png"]]];
	[[UITableView appearance] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

static UIImage *tableCellSelectedBackgroundImage;
static UIImageView *roundedTableCellSelectedBackgroundTopBottom;
static UIImageView *roundedTableCellSelectedBackgroundTop;
static UIImageView *roundedTableCellSelectedBackgroundBottom;
static UIImageView *roundedTableCellSelectedBackgroundMiddle;
static UIImage *detailAccessoryViewImage;
static UIImageView *darkCellSelectedBackground;
static UIImage *darkSelecedCellImage;
static UIImage *cellOddBackground;
static UIImage *cellEvenBackground;

// Set appearance of cell based on indexPath
+ (void)setCellAppearance:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	UIView *bg = [[UIView alloc] init];
	
	if (!cellOddBackground)
		cellOddBackground = [[UIImage imageNamed:@"CellOdd.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
	if (!cellEvenBackground)
		cellEvenBackground = [[UIImage imageNamed:@"CellEven.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
	
	// Odd vs even row
	if (indexPath.row % 2)
		bg = [[UIImageView alloc] initWithImage:cellOddBackground];
	else
		bg = [[UIImageView alloc] initWithImage:cellEvenBackground];
	
	// Background
	cell.backgroundView = bg;
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	
	if (!tableCellSelectedBackgroundImage)
		tableCellSelectedBackgroundImage = [UIImage imageNamed:@"SelectedCell.png"];
	
	// Selected background
	cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[tableCellSelectedBackgroundImage stretchableImageWithLeftCapWidth:0 topCapHeight:0]];
	cell.textLabel.highlightedTextColor = [UIColor whiteColor];
	cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
}
+ (void)setDarkCellAppearance:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	if (!darkCellSelectedBackground) {
		darkSelecedCellImage = [[UIImage imageNamed:@"DarkSelectedCell.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
		darkCellSelectedBackground = [[UIImageView alloc] initWithImage:darkSelecedCellImage];
	}
	
	// Background
	cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"DarkCell.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0]];
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.detailTextLabel.textColor = [UIColor whiteColor];
	
	// Selected background
	cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:darkSelecedCellImage];
	cell.textLabel.highlightedTextColor = [UIColor whiteColor];
	cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
}
// Set appearance of a rounded cell (so UITableView style is not 'Plain')
+ (void)setRoundedCellAppearance:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath forLastRow:(bool)lastRow {
	// Background
	__weak UIImageView *selectedBackground;
	
	UIImageView *(^getImageForName)(NSString *) = ^(NSString *imageName) {
		return [[UIImageView alloc] initWithImage:[[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
	};
	if (indexPath.row == 0 && lastRow) {
		// Rounded top and bottom
		if (!roundedTableCellSelectedBackgroundTopBottom)
			roundedTableCellSelectedBackgroundTopBottom = getImageForName(@"SelectedCellRoundedTopBottom.png");
		
		selectedBackground = roundedTableCellSelectedBackgroundTopBottom;
	} else if (indexPath.row == 0) {
		// Rounded top
		if (!roundedTableCellSelectedBackgroundTop)
			roundedTableCellSelectedBackgroundTop = getImageForName(@"SelectedCellRoundedTop.png");
		
		selectedBackground = roundedTableCellSelectedBackgroundTop;
	} else if (indexPath.row > 0 && !lastRow) {
		// Middle - no rounded edges
		if (!roundedTableCellSelectedBackgroundMiddle)
			roundedTableCellSelectedBackgroundMiddle = getImageForName(@"SelectedCellRoundedMiddle.png");
		
		selectedBackground = roundedTableCellSelectedBackgroundMiddle;
	} else if (indexPath.row > 0 && lastRow) {
		// Bottom rounded edges
		if (!roundedTableCellSelectedBackgroundBottom)
			roundedTableCellSelectedBackgroundBottom = getImageForName(@"SelectedCellRoundedBottom.png");
		
		selectedBackground = roundedTableCellSelectedBackgroundBottom;
	}
	
	cell.backgroundColor = [UIColor whiteColor];
	// Selected background
	cell.selectedBackgroundView = selectedBackground;
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

// Table Header view
+ (UIView *)viewForHeaderWithText:(NSString *)text tableView:(UITableView *)tableView {
	static UIColor *backgroundColor;
	if (!backgroundColor)
		backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"Section.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0]];
	
	UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
	
	[header setBackgroundColor:backgroundColor];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, header.frame.size.width-10, header.frame.size.height)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor blackColor];
	
	label.text = text;
	
	[header addSubview:label];
	
	return header;
}

@end
