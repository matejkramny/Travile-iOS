/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <UIKit/UIKit.h>

#ifndef AppDelegate
	#define DEBUG_APP false
	#define DEBUG_ANIMATION false
#endif

#ifdef FULL

#if FULL
	#define IsFULL true
#else
	#define IsFULL false
#endif

#else
	#define IsFULL false
#endif

// APN Notification server
#define APN_URL @"http://apn.travileapp.com/"

#ifndef DEBUG
	#define DEBUG false
#endif

#ifndef UserAgent
	#define UserAgent @"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1468.0 Safari/537.36"
#endif

#ifndef SupportEmail
	#define SupportEmail @"mailto:matejkramny@gmail.com?subject=Travile Support"
#endif

@class TMStorage;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) TMStorage *storage;

+ (void)openSupportEmail;
+ (NSString *)getAppVersion;
+ (NSString *)getAppName;

+ (void)displayLiteWarning;

@end

@interface AppDelegate (Appearance)

- (void)customizeAppearance;
+ (void)setCellAppearance:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
+ (void)setDarkCellAppearance:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
+ (void)setRoundedCellAppearance:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath forLastRow:(bool)lastRow;
+ (UIView *)setDetailAccessoryViewForTarget:(id)target action:(SEL)selector;
+ (UIView *)viewForHeaderWithText:(NSString *)text tableView:(UITableView *)tableView;

@end
