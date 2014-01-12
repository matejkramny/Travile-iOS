/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "AppDelegate.h"
#import "TMStorage.h"
#import "TMApplicationSettings.h"
#import "TMAPNService.h"
#import "Flurry.h"

@implementation AppDelegate {
	unsigned int timeAtGoingToInactiveState; // States the time when the app resignsActive
}

@synthesize window = _window;
@synthesize storage;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Sets appearance for UI
	[self customizeAppearance];
	
	// Initialize storage
	[TMStorage sharedStorage].delegate = self;
	storage = [TMStorage sharedStorage];
	
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	
	if (IsFULL) {
		[Flurry startSession:@"N6J2D56H5TFWSNNBKPB4"];
	}
	else {
		[Flurry startSession:@"N87JR8QHVZR8DTDNFTRW"];
	}
	
	[Flurry setDebugLogEnabled:NO];
	[Flurry setCrashReportingEnabled:YES];
	
	// iCloud
	NSFileManager *fileManager = [NSFileManager defaultManager];
	id currentToken = [fileManager ubiquityIdentityToken];
	storage.signedIntoICloud = (currentToken!=nil);
	
	// Expires in 3 days.
	if (storage.appSettings.created > (double)([[NSDate date] timeIntervalSince1970] - 259200.f)) {
		hasExpired = false;
	} else {
		hasExpired = true;
	}
	
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

+ (void)openSupportEmail {
	NSString *url = [[NSString stringWithFormat:SupportEmail] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
}

+ (NSString *)getAppVersion {
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getAppName {
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

static BOOL hasExpired = false;
+ (BOOL)hasExpired {
	return hasExpired;
}

+ (void)displayLiteWarning {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Trial Expired", @"Used as title of popup") message:NSLocalizedString(@"Your 3 day trial has expired. Full version restores all functionality. Click on Buy Now button to purchase on iTunes", @"Text displayed when the user doesn't have the full version of the app") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Buy now", nil), nil];
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.com/apps/Travile"]];
	}
	
	return;
}

@end

@implementation AppDelegate (Appearance)

- (void)customizeAppearance {
	[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
	[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.1f green:0.8f blue:0.2f alpha:1.f]];
	[[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
	return;
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
	return;
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
	return;
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
