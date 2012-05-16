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
	
	Village *v = [[[[(AppDelegate *)[UIApplication sharedApplication].delegate storage] account] villages] objectAtIndex:0];
	
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
}

@end
