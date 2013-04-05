// This code is distributed under the terms and conditions of the MIT license.

/* * Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial
 * portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
 * OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "TMReportsViewController.h"
#import "AppDelegate.h"
#import "TMStorage.h"
#import "TMAccount.h"
#import "TMReport.h"
#import "MBProgressHUD.h"

@interface TMReportsViewController () {
	TMStorage *storage;
	MBProgressHUD *HUD;
	UIAlertView *deleteAllAlert;
	UIBarButtonItem *editButton;
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
	[self.navigationItem setLeftBarButtonItem:editButton animated:NO];
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
	
	[self.tableView reloadData];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not supported" message:@"Reports are not supported yet." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
	[alert show];
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
