//
//  PHVResourcesViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 29/07/2012.
//
//

#import "PHVResourcesViewController.h"
#import "AppDelegate.h"
#import "Village.h"
#import "Storage.h"
#import "Account.h"
#import "Resources.h"
#import "ResourcesProduction.h"

@interface PHVResourcesViewController () {
	Account *account;
}

@end

@implementation PHVResourcesViewController
@synthesize wood;
@synthesize clay;
@synthesize iron;
@synthesize wheat;
@synthesize warehouse;
@synthesize granary;
@synthesize consuming;
@synthesize producing;

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
	
	AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	account = [[appDelegate storage] account];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tabBarController.navigationItem setRightBarButtonItems:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItems:nil];
	[self.tabBarController.navigationItem setRightBarButtonItem:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItem:nil];
	
	[self.tabBarController setTitle:[NSString stringWithFormat:@"Resources"]];
	
	[self refreshResources];
}

- (void)viewDidUnload
{
	[self setWood:nil];
	[self setClay:nil];
	[self setIron:nil];
	[self setWheat:nil];
	[self setWarehouse:nil];
	[self setGranary:nil];
	[self setConsuming:nil];
	[self setProducing:nil];
    [super viewDidUnload];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight));
}

- (void)refreshResources {
	Village *v = [account village];
	Resources *r = [v resources];
	ResourcesProduction *rp = [v resourceProduction];
	
	void (^setFormatToResource)(UILabel *, int, int) = ^(UILabel *l, int rv, int rpv) {
		[l setText:[NSString stringWithFormat:@"%d (%d)", rv, rpv]];
	};
	void (^setSimpleFormatToResource)(UILabel *, int) = ^(UILabel *l, int rv) {
		[l setText:[NSString stringWithFormat:@"%d", rv]];
	};
	
	setFormatToResource(wood, r.wood, rp.wood);
	setFormatToResource(clay, r.clay, rp.clay);
	setFormatToResource(iron, r.iron, rp.iron);
	setFormatToResource(wheat, r.wheat, rp.wheat);
	
	setSimpleFormatToResource(warehouse, v.warehouse);
	setSimpleFormatToResource(granary, v.granary);
	
	setSimpleFormatToResource(consuming, v.consumption);
	setSimpleFormatToResource(producing, rp.wheat);
}

@end
