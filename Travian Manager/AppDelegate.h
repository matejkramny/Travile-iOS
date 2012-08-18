//
//  AppDelegate.h
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Storage;
@class ViewController;
@class ODRefreshControl;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

@interface AppDelegate (Appearance)

- (void)customizeAppearance;
+ (void)setCellAppearance:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
+ (UIView *)setDetailAccessoryViewForTarget:(id)target action:(SEL)selector;
+ (ODRefreshControl *)addRefreshControlTo:(UIScrollView *)scrollView target:(id)target action:(SEL)selector;

@end