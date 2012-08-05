//
//  PHVBuildingDescriptionViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 03/08/2012.
//
//

#import "PHVBuildingDescriptionViewController.h"
#import "Building.h"

@interface PHVBuildingDescriptionViewController ()

@end

@implementation PHVBuildingDescriptionViewController
@synthesize description, building;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
	[self setDescription:nil];
    [super viewDidUnload];
	building = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[self description] setText:[building description]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
