//
//  PHMessagesViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 22/07/2012.
//
//

#import "PHMessagesViewController.h"
#import "AppDelegate.h"
#import "Storage.h"
#import "Account.h"
#import "Message.h"
#import "MBProgressHUD.h"
#import "PHOpenMessageViewController.h"
#import "PHMessageCell.h"

@interface PHMessagesViewController () {
	Storage *storage;
	UIAlertView *deleteAlert;
	MBProgressHUD *HUD;
	Message *selectedMessage;
	NSMutableArray *cells;
	UITableViewCell *noMessagesCell;
	
	UIBarButtonItem *newMessageButtonItem;
	UIBarButtonItem *editButtonItem;
	UIBarButtonItem *deleteButtonItem;
	UIBarButtonItem *editDoneButtonItem;
	
	NSMutableArray *deleteArray;
	bool forceZeroRows;
}

- (IBAction)editButtonClicked:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)delete:(id)sender userDidConfirm:(bool)confirmed;
- (IBAction)deleteTask:(id)sender;
- (IBAction)newMessage:(id)sender;
- (void)buildCells;
- (void)setNavigationItems:(BOOL)editing;
- (void)setNavigationItems:(BOOL)editing animated:(BOOL)animated;

@end

@interface PHMessagesViewController (RetrieveMessages)

- (NSArray *)retrieveMessages;

@end

@implementation PHMessagesViewController (RetrieveMessages)

- (NSArray *)retrieveMessages {
	Account *a = [storage account];
	
	return [a messages];
}

@end

@implementation PHMessagesViewController

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
	
	[self setRefreshControl:[[UIRefreshControl alloc] init]];
	[self.refreshControl addTarget:self action:@selector(didBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	
	storage = [Storage sharedStorage];
	[[self tableView] setAllowsSelectionDuringEditing:YES];
	newMessageButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newMessage:)];
	editButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked:)];
	deleteButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(delete:)];
	editDoneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButtonClicked:)];
	
	[self reloadBadgeCount];
	
	forceZeroRows = false;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (selectedMessage != nil)
		return;
	
	[self buildCells];
	[[self tableView] reloadData];
	
	[self setNavigationItems:false animated:false];
	
	[self.tabBarController setTitle:[NSString stringWithFormat:@"Messages"]];
	
	[self reloadBadgeCount];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super setEditing:NO animated:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)setNavigationItems:(BOOL)editing {
	[self setNavigationItems:editing animated:YES];
}
- (void)setNavigationItems:(BOOL)editing animated:(BOOL)animated {
	if (editing) {
		[self.tabBarController.navigationItem setLeftBarButtonItem:editDoneButtonItem animated:animated];
		[self.tabBarController.navigationItem setRightBarButtonItem:deleteButtonItem animated:animated];
	} else {
		[self.tabBarController.navigationItem setRightBarButtonItems:nil animated:animated];
		[self.tabBarController.navigationItem setLeftBarButtonItems:nil animated:animated];
		[self.tabBarController.navigationItem setRightBarButtonItem:newMessageButtonItem animated:animated];
		if ([cells count] != 0) {
			[self.tabBarController.navigationItem setLeftBarButtonItem:editButtonItem animated:animated];
		} else {
			[self.tabBarController.navigationItem setLeftBarButtonItem:nil animated:animated];
		}
	}
}

- (void)reloadBadgeCount {
	if (cells == nil) {
		[self buildCells];
	}
	
	int unread = 0;
	for (Message *m in storage.account.messages) {
		if (![m read]) unread++;
	}
	
	if (unread != 0) {
		[[self tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d", unread]];
	} else {
		[[self tabBarItem] setBadgeValue:nil];
	}
}

- (void)buildCells {
	cells = [[NSMutableArray alloc] initWithCapacity:[storage.account.messages count]];
	
	if ([storage.account.messages count] == 0) {
		if (!noMessagesCell) {
			noMessagesCell = [self.tableView dequeueReusableCellWithIdentifier:noMessagesCellIdentifier];
			[AppDelegate setCellAppearance:noMessagesCell forIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		}
		
		return;
	}
	
	int i = 0;
	for (Message *m in storage.account.messages) {
		PHMessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (!cell) {
			cell = [[PHMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		
		Message *m = [storage.account.messages objectAtIndex:i];
		
		[AppDelegate setCellAppearance:cell forIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		
		[cell setMessage:m];
		[cell configure];
		
		[cells addObject:cell];
		
		i++;
	}
}

- (void)didBeginRefreshing:(id)sender {
	[[storage account] refreshAccountWithMap:ARMessagesInbox];
	[storage.account addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (forceZeroRows)
		return 0;
	
	return cells.count || 1;
}

static NSString *CellIdentifier = @"MessageCell";
static NSString *noMessagesCellIdentifier = @"NoMessagesCell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!cells) {
		[self buildCells];
	}
	
	if ([cells count] == 0)
		return noMessagesCell;
	
	return [cells objectAtIndex:indexPath.row];
}

- (IBAction)editButtonClicked:(id)sender {
	[self setEditing:![self isEditing] animated:YES];
}

- (IBAction)delete:(id)sender {
	deleteArray = [[NSMutableArray alloc] initWithCapacity:[cells count]]; // Empty array
	for (PHMessageCell *cell in cells) {
		if ([cell isMarkedForDelete]) {
			[deleteArray addObject:[cell message]];
		}
	}
	
	deleteAlert = [[UIAlertView alloc] initWithTitle:@"Delete messages?" message:[NSString stringWithFormat:@"Are you sure you want to delete %d messages?", [deleteArray count]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
	[deleteAlert show];
}

- (IBAction)delete:(id)sender userDidConfirm:(bool)confirmed {
	if (!confirmed) {
		[self delete:sender];
		return;
	}
	
	if ([deleteArray count] == 0)
		return;
	
	int total = deleteArray.count;
	
	HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.navigationController.view];
	[self.tabBarController.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = [NSString stringWithFormat:@"Deleted %d Messages", total];
	
	[HUD show:YES];
	[self deleteTask:sender];
	
	NSMutableArray *rowCollection = [[NSMutableArray alloc] initWithCapacity:total];
	
	for (Message *m in deleteArray) {
		int index = [storage.account.messages indexOfObjectIdenticalTo:m];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
		
		// Remove the cell
		[cells removeObjectAtIndex:index - [rowCollection count]]; // index - rowCollection.count | necessary because there might have been a cell deleted before this cell (which may have caused array out of bounds exc..)
		
		[rowCollection addObject:indexPath];
	}
	
	// Remove the messages from messages collection
	NSMutableArray *newMsgs = [storage.account.messages mutableCopy];
	[newMsgs removeObjectsInArray:deleteArray];
	storage.account.messages = newMsgs;
	
	[HUD hide:YES afterDelay:0.5f];
	[self setEditing:NO animated:YES];
	
	if ([cells count] == 0)
		forceZeroRows = true;
	// Create the deleting effect..
	[[self tableView] deleteRowsAtIndexPaths:rowCollection withRowAnimation:UITableViewRowAnimationFade];
	
	if ([cells count] == 0) {
		// Build cells ("No Messages cell")
		forceZeroRows = false;
		[self buildCells];
		[[self tableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
	}
}

- (IBAction)deleteTask:(id)sender {
	if ([deleteArray count] == 0)
		return;
	
	NSString *data = @"delmsg=Delete&s=0";
	int nth = 1;
	for (Message *m in deleteArray) {
		data = [data stringByAppendingFormat:@"&n%d=%@", nth++, [m accessID]];
	}
	
	NSData *myRequestData = [NSData dataWithBytes: [data UTF8String] length: [data length]];
	NSString *stringUrl = [[storage.account baseURL] stringByAppendingString:[Account messages]];
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

- (IBAction)newMessage:(id)sender {
	[self performSegueWithIdentifier:@"NewMessage" sender:self];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	[self setNavigationItems:editing];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([cells count] == 0)
		return NO;
	
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([cells count] == 0)
		return NO;
	
	return YES;
}

- (int)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([cells count] == 0) {
		return 40;
	}
	
    return 49;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView == deleteAlert) {
		if (buttonIndex == 1) {
			[self delete:self userDidConfirm:YES];
		}
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([cells count] == 0) {
		return;
	}
	
	if (self.editing) {
		PHMessageCell *cell __weak = (PHMessageCell *)[tableView cellForRowAtIndexPath:indexPath];
		[cell wasSelectedWhileEditing];
		
		[tableView deselectRowAtIndexPath:indexPath animated:NO];
		
		return;
	}
	
	selectedMessage = [storage.account.messages objectAtIndex:indexPath.row];
	
	if ([selectedMessage content] == nil) {
		// Load the message
		[selectedMessage addObserver:self forKeyPath:@"content" options:NSKeyValueObservingOptionNew context:NULL];
		[selectedMessage downloadAndParse];
				
		HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.navigationController.view];
		[self.tabBarController.navigationController.view addSubview:HUD];
		HUD.delegate = self;
		HUD.labelText = [NSString stringWithFormat:@"Downloading message"];
		
		[HUD show:YES];
		
		return;
	}
	
	[self performSegueWithIdentifier:@"OpenMessage" sender:self];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
	[hud removeFromSuperview];
	HUD = nil;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == selectedMessage && [keyPath isEqualToString:@"content"]) {
		[HUD hide:YES];
		
		[selectedMessage setRead:YES];
		
		[self performSegueWithIdentifier:@"OpenMessage" sender:self];
	} else if ([keyPath isEqualToString:@"status"]) {
		if (([[change objectForKey:NSKeyValueChangeNewKey] intValue] & ARefreshed) != 0) {
			// Done refreshing
			[storage.account removeObserver:self forKeyPath:@"status"];
			//[refreshControl endRefreshing];
			[self.refreshControl endRefreshing];
			[self buildCells];
			[self.tableView reloadData];
			[self reloadBadgeCount];
			[self setNavigationItems:self.isEditing];
		}
	}
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"OpenMessage"]) {
		UINavigationController *nc = [segue destinationViewController];
		PHOpenMessageViewController *vc = [[nc viewControllers] objectAtIndex:0];
		
		vc.message = selectedMessage;
		vc.delegate = self;
	}
}

#pragma mark - PHOpenMessageViewControllerDelegate

- (void)openMessageViewController:(PHOpenMessageViewController *)viewController didCloseMessage:(Message *)message {
	[self dismissViewControllerAnimated:YES completion:nil];
	selectedMessage = nil;
	
	[self viewWillAppear:YES];
}

@end
