//
//  ViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
	
	IBOutlet UILabel *wood;
	IBOutlet UILabel *clay;
	IBOutlet UILabel *iron;
	IBOutlet UILabel *wheat;
	IBOutlet UILabel *granary;
	IBOutlet UILabel *warehouse;
	
	IBOutlet UILabel *vilName;
	IBOutlet UILabel *vilLoyalty;
	IBOutlet UILabel *vilPopulation;
	
	IBOutlet UILabel *troopsHero;
	
	IBOutlet UILabel *consName;
	IBOutlet UILabel *consLevel;
	IBOutlet UILabel *consFinish;
}

- (IBAction)updateView:(id)sender;

@end