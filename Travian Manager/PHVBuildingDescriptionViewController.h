//
//  PHVBuildingDescriptionViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 03/08/2012.
//
//

#import <UIKit/UIKit.h>

@class Building;

@interface PHVBuildingDescriptionViewController : UIViewController

@property (weak, nonatomic) Building *building;
@property (weak, nonatomic) IBOutlet UITextView *description;

@end
