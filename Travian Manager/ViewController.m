//
//  ViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Storage.h"
#import "Account.h"
#import "Village.h"
#import "Resources.h"
#import "Troop.h"
#import "Construction.h"
#import "Hero.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

- (IBAction)updateView:(id)sender {
	NSLog(@"Update view");
	
	Account *a = [[(AppDelegate *)[UIApplication sharedApplication].delegate storage] account];
	Village *v = [[a villages] objectAtIndex:0];
	
	[warehouse setText:[NSString stringWithFormat:@"%d", v.warehouse]];
	[granary setText:[NSString stringWithFormat:@"%d", v.granary]];
	
	Resources *r = [v resources];
	[wood setText:[NSString stringWithFormat:@"%d", r.wood]];
	[clay setText:[NSString stringWithFormat:@"%d", r.clay]];
	[iron setText:[NSString stringWithFormat:@"%d", r.iron]];
	[wheat setText:[NSString stringWithFormat:@"%d", r.wheat]];
	
	[vilName setText:v.name];
	[vilLoyalty setText:[NSString stringWithFormat:@"%d", v.loyalty]];
	[vilPopulation setText:[NSString stringWithFormat:@"%d", v.population]];
	
	if (v.troops && [v.troops count] > 0)
		[troopsHero setText:[NSString stringWithFormat:@"%d", [[v.troops objectAtIndex:0] count]]];
	
	if (v.constructions && [v.constructions count] > 0) {
		Construction *c = [v.constructions objectAtIndex:0];
		
		[consName setText:[c name]];
		[consLevel setText:[NSString stringWithFormat:@"%d", [c level]]];
		[consFinish setText:[c finishTime]];
	}
	
	// Hero
	Hero *h = a.hero;
	
	[heroStrength setText:[NSString stringWithFormat:@"%d", h.strengthPoints]];
	[heroOff setText:[NSString stringWithFormat:@"%d%%", h.offBonusPercentage]];
	[heroDef setText:[NSString stringWithFormat:@"%d%%", h.defBonusPercentage]];
	[heroExp setText:[NSString stringWithFormat:@"%d", h.experience]];
	[heroHealth setText:[NSString stringWithFormat:@"%d%%", h.health]];
	[heroisHiding setText:h.isHidden ? @"YES" : @"NO"];
	[heroisAlive setText:h.isAlive ? @"YES" : @"NO"];
	[heroWood setText:[NSString stringWithFormat:@"%d", h.resourceProductionBoost.wood]];
	[heroClay setText:[NSString stringWithFormat:@"%d", h.resourceProductionBoost.clay]];
	[heroIron setText:[NSString stringWithFormat:@"%d", h.resourceProductionBoost.iron]];
	[heroWheat setText:[NSString stringWithFormat:@"%d", h.resourceProductionBoost.wheat]];
}

@end
