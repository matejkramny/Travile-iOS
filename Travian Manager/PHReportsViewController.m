//
//  PHReportsViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 22/07/2012.
//
//

#import "PHReportsViewController.h"
#import "AppDelegate.h"
#import "Storage.h"
#import "Account.h"
#import "Report.h"
#import "MBProgressHUD.h"

@interface PHReportsViewController () {
	AppDelegate *appDelegate;
	Storage *storage;
	MBProgressHUD *HUD;
	UIAlertView *deleteAllAlert;
}

- (IBAction)deleteAll:(id)sender;
- (IBAction)deleteAll:(id)sender userDidConfirm:(bool)confirmed;
- (IBAction)deleteTask:(id)sender;
- (IBAction)editButtonClicked:(id)sender;

@end

@implementation PHReportsViewController

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
	
	appDelegate = [UIApplication sharedApplication].delegate;
	storage = [appDelegate storage];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.tabBarController setTitle:@"Reports"];
	[self.tabBarController.navigationItem setRightBarButtonItems:nil];
	[self.tabBarController.navigationItem setRightBarButtonItem:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItems:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked:)] animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super setEditing:NO animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[storage account] reports] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReportCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	Report *r = [[[storage account] reports] objectAtIndex:indexPath.row];
    cell.textLabel.text = [r name];
	cell.detailTextLabel.text = @"";
    
	[appDelegate setCellAppearance:cell forIndexPath:indexPath];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		// Make Mutable copy
		NSMutableArray *a = [[[storage account] reports] mutableCopy];
		// Delete the report (from Travian)
		[[a objectAtIndex:indexPath.row] delete];
		// Remove Object from Array
		[a removeObjectAtIndex:indexPath.row];
		// Put back immutable copy of the array
		[storage account].reports = [a copy];
		
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[tableView reloadData]; // Refresh data source
    }
}

- (IBAction)deleteAll:(id)sender {
	if ([[[storage account] reports] count] == 0) {
		@autoreleasepool {
			UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"No reports" message:@"There are no reports that can be deleted" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
			[a show];
		}
		
		[self setEditing:NO animated:YES];
		
		return;
	}
	
	deleteAllAlert = [[UIAlertView alloc] initWithTitle:@"Delete all?" message:@"Are you sure you want to delete all reports?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
	[deleteAllAlert show];
}

- (IBAction)deleteAll:(id)sender userDidConfirm:(bool)confirmed {
	if (!confirmed) {
		[self deleteAll:sender];
		return;
	}
	
	int total = [[[storage account] reports] count];
	
	HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.navigationController.view];
	[self.tabBarController.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = [NSString stringWithFormat:@"Deleted %d Reports", total];
	
	[HUD show:YES];
	[self deleteTask:sender];
	
	NSMutableArray *rowCollection = [[NSMutableArray alloc] initWithCapacity:total];
	for (int i = 0; i < total; i++) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
		[rowCollection addObject:indexPath];
	}
	
	[HUD hide:YES afterDelay:0.5f];
	[self setEditing:NO animated:YES];
	
	// Create the deleting effect..
	[storage account].reports = [NSArray array];
	[[self tableView] deleteRowsAtIndexPaths:rowCollection withRowAnimation:UITableViewRowAnimationFade];
}

- (IBAction)deleteTask:(id)sender {
	NSArray *rs = [[storage account] reports];
	
	NSString *data = @"del=Delete&s=0";
	int nth = 1;
	for (Report *r in rs) {
		data = [data stringByAppendingFormat:@"&n%d=%@", nth++, [r deleteID]];
	}
	
	NSData *myRequestData = [NSData dataWithBytes: [data UTF8String] length: [data length]];
	NSString *stringUrl = [NSString stringWithFormat:@"http://%@.travian.%@/berichte.php", [[storage account] world], [[storage account] server]];
	NSURL *url = [NSURL URLWithString: stringUrl];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	// Set POST HTTP Headers if necessary
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody: myRequestData];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	
	// Preserve any cookies received
	[request setHTTPShouldHandleCookies:YES];
	
	@autoreleasepool {
		NSURLConnection *c __unused = [[NSURLConnection alloc] initWithRequest:request delegate:nil startImmediately:YES];
	}
}

- (IBAction)editButtonClicked:(id)sender {
	[self setEditing:![self isEditing] animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	if (editing) {
		[self.tabBarController.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButtonClicked:)] animated:YES];
		[self.tabBarController.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAll:)] animated:YES];
	} else {
		[self.tabBarController.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked:)] animated:YES];
		[self.tabBarController.navigationItem setRightBarButtonItem:nil animated:YES];
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidden
	[hud removeFromSuperview];
	HUD = nil;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView == deleteAllAlert) {
		if (buttonIndex == 1) {
			// Selected Yes
			[self deleteAll:self userDidConfirm:YES];
		} else {
			[self setEditing:NO animated:YES];
		}
	}
}

@end
