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

@interface PHMessagesViewController () {
	Storage *storage;
	UIAlertView *deleteAllAlert;
	MBProgressHUD *HUD;
	Message *selectedMessage;
	NSDictionary *messages;
}

- (IBAction)editButtonClicked:(id)sender;
- (IBAction)deleteAll:(id)sender;
- (IBAction)deleteAll:(id)sender userDidConfirm:(bool)confirmed;
- (IBAction)deleteTask:(id)sender;
- (IBAction)newMessage:(id)sender;

@end

@interface PHMessagesViewController (RetrieveMessages)

- (NSDictionary *)retrieveMessages;

@end

@implementation PHMessagesViewController (RetrieveMessages)

- (NSDictionary *)retrieveMessages {
	Account *a = [storage account];
	NSMutableArray *read = [[NSMutableArray alloc] init];
	NSMutableArray *uread = [[NSMutableArray alloc] init];
	
	for (Message *m in [a messages]) {
		if ([m read])
			[read addObject:m];
		else
			[uread addObject:m];
	}
	
	return @{ @"read" : read, @"unread" : uread };
}

@end

@implementation PHMessagesViewController
@synthesize segmentedControl;

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
	
	storage = [Storage sharedStorage];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (selectedMessage != nil)
		return;
	
	[self.tabBarController.navigationItem setRightBarButtonItems:nil];
	[self.tabBarController.navigationItem setLeftBarButtonItems:nil];
	[self.tabBarController.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newMessage:)]];
	[self.tabBarController.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked:)]];
	
	[self.tabBarController setTitle:[NSString stringWithFormat:@"Messages"]];
	
	[segmentedControl setSegmentedControlStyle:7];
	
	messages = [self retrieveMessages];
	[[self tableView] reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super setEditing:NO animated:animated];
}

- (void)viewDidUnload
{
	[self setSegmentedControl:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (IBAction)segmentedControlValueChanged:(id)sender {
	[[self tableView] reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) // Unread
		return [[messages objectForKey:@"unread"] count];
	else if (section == 1) // Read
		return [[messages objectForKey:@"read"] count];
	
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	NSArray *ms = [messages objectForKey:indexPath.section == 0 ? @"unread" : @"read"];
	Message *m = [ms objectAtIndex:indexPath.row];
	
    cell.textLabel.text = [m title];
	
	[AppDelegate setCellAppearance:cell forIndexPath:indexPath];
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 0 ? @"Unread messages" : @"Read messages";
}

- (IBAction)editButtonClicked:(id)sender {
	[self setEditing:![self isEditing] animated:YES];
}

- (IBAction)deleteAll:(id)sender {
	if ([[[storage account] messages] count] == 0) {
		@autoreleasepool {
			UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"No messages" message:@"There are no messages that can be deleted" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
			[a show];
		}
		
		return;
	}
	
	deleteAllAlert = [[UIAlertView alloc] initWithTitle:@"Delete all?" message:@"Are you sure you want to delete all messages?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
	[deleteAllAlert show];
}

- (IBAction)deleteAll:(id)sender userDidConfirm:(bool)confirmed {
	if (!confirmed) {
		[self deleteAll:sender];
		return;
	}
	
	int total = [[[storage account] messages] count];
	
	HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.navigationController.view];
	[self.tabBarController.navigationController.view addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = [NSString stringWithFormat:@"Deleted %d Messages", total];
	
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
	[storage account].messages = [[NSArray alloc] init];
	[[self tableView] deleteRowsAtIndexPaths:rowCollection withRowAnimation:UITableViewRowAnimationFade];
}

- (IBAction)deleteTask:(id)sender {
	NSArray *rs = [[storage account] messages];
	
	NSString *data = @"delmsg=Delete&s=0";
	int nth = 1;
	for (Message *m in rs) {
		data = [data stringByAppendingFormat:@"&n%d=%@", nth++, [m accessID]];
	}
	
	NSData *myRequestData = [NSData dataWithBytes: [data UTF8String] length: [data length]];
	NSString *stringUrl = [NSString stringWithFormat:@"http://%@.travian.%@/nachrichten.php", [[storage account] world], [[storage account] server]];
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
	
	if (editing) {
		[self.tabBarController.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButtonClicked:)] animated:YES];
		[self.tabBarController.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAll:)] animated:YES];
	} else {
		[self.tabBarController.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked:)] animated:YES];
		[self.tabBarController.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newMessage:)] animated:YES];
	}
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		NSMutableArray *ms = [storage.account.messages mutableCopy];
		[[ms objectAtIndex:indexPath.row] delete];
		[ms removeObjectAtIndex:indexPath.row];
		storage.account.messages = [ms copy];
		
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView == deleteAllAlert) {
		if (buttonIndex == 1) {
			[self deleteAll:self userDidConfirm:YES];
		}
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
		
		[self performSegueWithIdentifier:@"OpenMessage" sender:self];
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
}

@end
