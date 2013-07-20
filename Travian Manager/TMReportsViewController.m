/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMReportsViewController.h"
#import "AppDelegate.h"
#import "TMStorage.h"
#import "TMAccount.h"
#import "TMReport.h"
#import "MBProgressHUD.h"
#import "TMReportViewController.h"

@interface TMReportsViewController () {
	TMStorage *storage;
	MBProgressHUD *HUD;
	UIAlertView *deleteAllAlert;
	UIBarButtonItem *editButton;
	
	TMReport *selectedReport;
	NSIndexPath *selectedIndexPath;
}

- (IBAction)deleteAll:(id)sender;
- (IBAction)deleteAll:(id)sender userDidConfirm:(bool)confirmed;
- (IBAction)deleteTask:(id)sender;
- (IBAction)editButtonClicked:(id)sender;

@end

@implementation TMReportsViewController

static NSString *viewTitle = @"Reports";

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
	
	storage = [TMStorage sharedStorage];
	//[self.navigationItem setLeftBarButtonItem:editButton animated:NO];
	[self setTitle:viewTitle];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (!editButton) {
		editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked:)];
	}
	
	if (selectedReport) {
		selectedReport = nil;
	} else {
		[self.tableView reloadData];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super setEditing:NO animated:animated];
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
    
	TMReport *r = [[[storage account] reports] objectAtIndex:indexPath.row];
    cell.textLabel.text = [r name];
	cell.detailTextLabel.text = @"";
    
	[AppDelegate setCellAppearance:cell forIndexPath:indexPath];
	
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
	for (TMReport *r in rs) {
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
	selectedIndexPath = indexPath;
	
	selectedReport = [storage.account.reports objectAtIndex:indexPath.row];
	
	if (![selectedReport parsed]) {
		[selectedReport addObserver:self forKeyPath:@"parsed" options:NSKeyValueObservingOptionNew context:nil];
		[selectedReport downloadAndParse];
		
		HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.tabBarController.view animated:YES];
		HUD.labelText = @"Loading report";
		HUD.delegate = self;
	} else {
		[self performSegueWithIdentifier:@"openReport" sender:self];
	}
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

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == selectedReport) {
		if ([keyPath isEqualToString:@"parsed"]) {
			[HUD hide:YES];
			[self performSegueWithIdentifier:@"openReport" sender:self];
		}
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"openReport"]) {
		@try {
			[selectedReport removeObserver:self forKeyPath:@"parsed"];
		}
		@catch (NSException *exception) {
			// Remove observer from report.. If not observing do nothing.. Exception happens but we don't care
		}
		
		TMReportViewController *destination = [segue destinationViewController];
		destination.report = selectedReport;
	}
}

@end
