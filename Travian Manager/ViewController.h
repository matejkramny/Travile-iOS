//
//  ViewController.h
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate> {
	
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
	
	IBOutlet UILabel *heroStrength;
	IBOutlet UILabel *heroOff;
	IBOutlet UILabel *heroDef;
	IBOutlet UILabel *heroExp;
	IBOutlet UILabel *heroHealth;
	IBOutlet UILabel *heroisHiding;
	IBOutlet UILabel *heroisAlive;
	IBOutlet UILabel *heroWood;
	IBOutlet UILabel *heroClay;
	IBOutlet UILabel *heroIron;
	IBOutlet UILabel *heroWheat;
	
	IBOutlet UILabel *heroAdventures;
	
	IBOutlet UITableView *BuildingsTable;
	
	IBOutlet UILabel *mov1Name;
	IBOutlet UILabel *mov1Time;
	IBOutlet UILabel *mov2Name;
	IBOutlet UILabel *mov2Time;
}

- (IBAction)updateView:(id)sender;
- (IBAction)reloadData:(id)sender;

@end