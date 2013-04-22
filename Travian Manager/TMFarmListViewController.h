/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <UIKit/UIKit.h>

#ifndef Sparrowlike_Constants_h
#define Sparrowlike_Constants_h

#define FAST_ANIMATION_DURATION 0.35
#define SLOW_ANIMATION_DURATION 0.75
#define PAN_CLOSED_X 0
#define PAN_OPEN_X -250

#endif

@interface TMFarmListViewController : UITableViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic) float openCellLastTX;
@property (nonatomic, strong) NSIndexPath *openCellIndexPath;

@end
