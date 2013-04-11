/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <UIKit/UIKit.h>

#ifndef AppDelegate
	#define DEBUG_APP false
	#define DEBUG_ANIMATION false
#endif

#ifdef DEBUG
	#define APN_URL @"http://apn.sandbox.matej.me/" // used when running the app without the distribution prov. profile
#else
	#define APN_URL @"http://apn.matej.me/" // ad-hoc and app store mode.
#endif

#ifndef DEBUG
	#define DEBUG false
#endif

@class TMStorage;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) TMStorage *storage;

@end

@interface AppDelegate (Appearance)

- (void)customizeAppearance;
+ (void)setCellAppearance:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
+ (void)setDarkCellAppearance:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
+ (void)setRoundedCellAppearance:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath forLastRow:(bool)lastRow;
+ (UIView *)setDetailAccessoryViewForTarget:(id)target action:(SEL)selector;

@end
