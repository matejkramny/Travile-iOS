//
//  PHOpenMessageViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 25/07/2012.
//
//

#import "PHOpenMessageViewController.h"

@interface PHOpenMessageViewController ()

@end

@implementation PHOpenMessageViewController
@synthesize sentBy;
@synthesize time;
@synthesize subject;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[self navigationController] setToolbarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[self navigationController] setToolbarHidden:YES animated:YES];
}

- (void)viewDidUnload
{
    [self setSentBy:nil];
    [self setTime:nil];
    [self setSubject:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
