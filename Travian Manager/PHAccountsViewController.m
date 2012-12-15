//
//  PHAccountsViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 21/07/2012.
//
//

#import "PHAccountsViewController.h"
#import "Storage.h"
#import "Account.h"
#import "PHAccountDetailsViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface PHAccountsViewController () {
	Storage *storage;
	Account *selectedAccount;
	UIAlertView *passwordPromptView;
	UIAlertView *passwordRetryView;
	Account *passwordRetryAccount;
	MBProgressHUD *hud;
	UITapGestureRecognizer *tapGestureRecognizer;
}

- (void)logIn:(Account *)a withPasword:(NSString *)password;
- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer;

@end

@interface PHAccountsViewController (ActionButtons)

- (void)editButtonClicked:(id)sender;
- (void)addAccount:(id)sender;
- (void)dismissView;

@end

@implementation PHAccountsViewController (ActionButtons)

- (void)editButtonClicked:(id)sender {
	if ([storage.accounts count] > 0 || [self isEditing])
		[self setEditing:![self isEditing] animated:YES];
}

- (void)addAccount:(id)sender {
	selectedAccount = nil;
	[self performSegueWithIdentifier:@"NewAccount" sender:self];
}

// Overrides setEditing messages to change buttons on Navigation Bar
- (void)setEditing:(BOOL)editing {
	[self setEditing:editing animated:NO];
}
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	if (editing)
		[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButtonClicked:)] animated:animated];
	else
		[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked:)] animated:animated];
}

- (void)dismissView {
//	[self dismissModalViewControllerAnimated:YES];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation PHAccountsViewController

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
	storage = [Storage sharedStorage];
	
	[super viewDidLoad];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked:)]];
	
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAccount:)]];
	
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Normal || Landscape-left || Landscape-right
	return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	return [[storage accounts] count] == 0 ? 1 : [[storage accounts] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"AccountCell";
	static NSString *AddAccountImageIndicatorCell = @"AddAccountImage";
	
	UITableViewCell *cell;
	if ([[storage accounts] count] == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:AddAccountImageIndicatorCell];
		[cell setOpaque:YES];
		[cell setAlpha:1];
		
		[AppDelegate setCellAppearance:cell forIndexPath:indexPath];
	} else {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

		// Configure the cell...
		Account *a = [[storage accounts] objectAtIndex:indexPath.row];
		cell.textLabel.text = [a name];
		cell.detailTextLabel.text = [a username];

		[cell setOpaque:YES];
		[cell setAlpha:1];

		[AppDelegate setCellAppearance:cell forIndexPath:indexPath];
	}
	
	return cell;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	// Move the account in the array
	NSMutableArray *arr = [storage.accounts mutableCopy];
	Account *a = [arr objectAtIndex:fromIndexPath.row];
	[arr removeObjectAtIndex:fromIndexPath.row];
	[arr insertObject:a atIndex:toIndexPath.row];
	storage.accounts = [arr copy];
	
	[storage saveData];
}

- (void)logIn:(Account *)a withPasword:(NSString *)password {
	// Check if we need to be prompted for password
	
	// Activate the account
	[storage setActiveAccount:a withPassword:password];
	[[storage account] addObserver:self forKeyPath:@"notificationPending" options:NSKeyValueObservingOptionNew context:NULL]; // Notification pending bool
	[[storage account] addObserver:self forKeyPath:@"progressIndicator" options:NSKeyValueObservingOptionNew context:NULL]; // Progress Indication for HUD
	[[storage account] addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL]; // Watch for account status
	
	hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud.labelText = NSLocalizedString(@"Logging In", @"");
	hud.detailsLabelText = NSLocalizedString(@"Tap to cancel", @"Shown on Progress HUD");
	hud.dimBackground = YES;
	
	// Cancel tap Gesture recognizer
	tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
	[tapGestureRecognizer setNumberOfTapsRequired:1];
	[tapGestureRecognizer setNumberOfTouchesRequired:1];
	[hud addGestureRecognizer:tapGestureRecognizer];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
	[hud hide:YES];
	[hud removeGestureRecognizer:tapGestureRecognizer];
	tapGestureRecognizer = nil;
	[storage.account removeObserver:self forKeyPath:@"notificationPending"];
	[storage.account removeObserver:self forKeyPath:@"progressIndicator"];
	[storage.account removeObserver:self forKeyPath:@"status"];
	
	[storage deactivateActiveAccount];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([storage.accounts count] == 0) {
		[self performSegueWithIdentifier:@"NewAccount" sender:self];
		return;
	}
	
	selectedAccount = [storage.accounts objectAtIndex:indexPath.row];
	
	if ([self isEditing])
	{
		// Editing account
		[self performSegueWithIdentifier:@"NewAccount" sender:self];
	}
	else
	{
		// Open selected account
		Account *a = [[storage accounts] objectAtIndex:indexPath.row];
		
		if ([[a password] length] == 0) {
			passwordPromptView = [[UIAlertView alloc] initWithTitle:@"Password required" message:[NSString stringWithFormat:@"Please enter password for account %@", [a name]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
			[passwordPromptView setAlertViewStyle:UIAlertViewStyleSecureTextInput];
			[passwordPromptView show];
			
			return;
		}
		
		[self logIn:a withPasword:[a password]];
	}
}

#pragma mark - Key-Value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"notificationPending"]) {
		NSNumber *n = [change objectForKey:NSKeyValueChangeNewKey];
		if ([n boolValue] == YES) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification pending" message:@"There is a Travian notification pending review." delegate:self cancelButtonTitle:@"Proceed" otherButtonTitles:@"View", nil];
			[alert show];
		}
	} else if ([keyPath isEqualToString:@"progressIndicator"]) {
		// Shows progress
		hud.labelText = [change objectForKey:NSKeyValueChangeNewKey];
	} else if ([keyPath isEqualToString:@"status"]) {
		// Checks for change of account status
		AccountStatus stat = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
		if ((stat & (ACannotLogIn)) != 0) {
			// Cannot log in.
			// Display Alert - Cancel - Retry with new password
			
			[storage.account removeObserver:self forKeyPath:@"notificationPending"];
			[storage.account removeObserver:self forKeyPath:@"progressIndicator"];
			[storage.account removeObserver:self forKeyPath:@"status"];
			[hud hide:YES];
			[hud removeGestureRecognizer:tapGestureRecognizer];
			tapGestureRecognizer = nil;
			
			passwordRetryAccount = storage.account;
			passwordRetryView = [[UIAlertView alloc] initWithTitle:@"Cannot log in" message:@"TM cannot log in. Enter your password to retry." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
			[passwordRetryView setAlertViewStyle:UIAlertViewStyleSecureTextInput];
			[passwordRetryView show];
		} else if ((stat & ARefreshed) != 0) {
			[hud setLabelText:@"Done"];
			[hud setDetailsLabelText:@""];
			[hud removeGestureRecognizer:tapGestureRecognizer];
			tapGestureRecognizer = nil;
			[hud setCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]]];
			[hud setMode:MBProgressHUDModeCustomView];
			
			[hud hide:YES afterDelay:0.6];
			
			[storage.account removeObserver:self forKeyPath:@"notificationPending"];
			[storage.account removeObserver:self forKeyPath:@"progressIndicator"];
			[storage.account removeObserver:self forKeyPath:@"status"];
			
			[[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:YES];
			
			[self performSelector:@selector(dismissView) withObject:self afterDelay:0.6];
		}
	}
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView == passwordPromptView) {
		if (buttonIndex == 0) {
			[[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:YES];
		} else {
			[self logIn:[[storage accounts] objectAtIndex:[[self tableView] indexPathForSelectedRow].row] withPasword:[[alertView textFieldAtIndex:0] text]];
		}
		return;
	} else if (alertView == passwordRetryView) {
		if (buttonIndex == 0) {
			[[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:YES];
		}
		else {
			[self logIn:passwordRetryAccount withPasword:[[alertView textFieldAtIndex:0] text]];
		}
		
		return;
	}
	
	[[storage account] removeObserver:self forKeyPath:@"notificationPending"];
	
	if (buttonIndex == 1) {
		// View
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@.travian.%@/dorf1.php", [[storage account] world], [[storage account] server]]];
		[[UIApplication sharedApplication] openURL:url];
		// Cancel log in
		[hud hide:YES];
		
		[storage.account removeObserver:self forKeyPath:@"notificationPending"];
		[storage.account removeObserver:self forKeyPath:@"progressIndicator"];
		[storage.account removeObserver:self forKeyPath:@"status"];
		
		[[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:YES];
	} else if (buttonIndex == 0) {
		// Proceed
		[[storage account] skipNotification];
	}
}

#pragma mark - prepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"NewAccount"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
		PHAccountDetailsViewController *advc = [[navigationController viewControllers] objectAtIndex:0];
		
		advc.delegate = self;
		advc.editingAccount = selectedAccount;
	}
}

#pragma mark - PHAccountDetailsViewControllerDelegate

- (void)accountDetailsViewController:(PHAccountDetailsViewController *)controller didAddAccount:(Account *)account
{
	// Add the account
	if (storage.accounts == nil)
		storage.accounts = [[NSArray alloc] init];
	storage.accounts = [storage.accounts arrayByAddingObject:account];
	
	// Dismiss the view
	[self dismissViewControllerAnimated:YES completion:nil];
	
	if ([storage.accounts count]-1 == 0) {
		// First account created..
		[self.tableView reloadData];
	} else {
		// Tell table to add row
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[storage.accounts count] - 1 inSection:0];
		[self.tableView insertRowsAtIndexPaths: [NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
	}
	
	selectedAccount = nil;
	[self setEditing:NO];
	
	[storage saveData];
}
- (void)accountDetailsViewController:(PHAccountDetailsViewController *)controller didEditAccount:(Account *)oldAccount
{
	// Dismiss view
	[self dismissViewControllerAnimated:YES completion:nil];
	
	selectedAccount = nil;
	[self setEditing:NO];
	
	[self.tableView reloadData];
	
	[storage saveData];
}
- (void)accountDetailsViewControllerDidCancel:(PHAccountDetailsViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
	selectedAccount = nil;
	[self setEditing:NO];
}
- (void)accountDetailsViewController:(PHAccountDetailsViewController *)controller didDeleteAccount:(Account *)account {
	int location = [storage.accounts indexOfObjectIdenticalTo:account];
	if(location != NSNotFound)
	{
		// Replace old account with new
		NSMutableArray *arr = [storage.accounts mutableCopy];
		[arr removeObjectAtIndex:location];
		storage.accounts = [arr copy];
		
		// Reload table source
		[self.tableView reloadData];
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
	[self setEditing:NO];
	selectedAccount = nil;
	
	[self.tableView reloadData];
	
	[storage saveData];
}

@end
