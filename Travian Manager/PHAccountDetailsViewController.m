//
//  PHAccountDetailsViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 21/07/2012.
//
//

#import "PHAccountDetailsViewController.h"
#import "Account.h"

@interface PHAccountDetailsViewController ()

@end

@implementation PHAccountDetailsViewController

@synthesize delegate, editingAccount;
@synthesize usernameTextField, passwordTextField, accountNameTextField, worldTextField, domainTextField;

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
	if (self.editingAccount != nil)
	{
		// Editing mode
		[[self navigationItem] setTitle:@"Edit account"];
		
		self.accountNameTextField.text = self.editingAccount.name;
		self.usernameTextField.text = self.editingAccount.username;
		self.passwordTextField.text = self.editingAccount.password;
		self.worldTextField.text = self.editingAccount.world;
		self.domainTextField.text = self.editingAccount.server;
		//self.speedServerSwitch.on = self.editingAccount.speedServer;
	}
	
    [super viewDidLoad];
}

- (void)viewDidUnload
{
	[self setUsernameTextField:nil];
	[self setPasswordTextField:nil];
    [self setAccountNameTextField:nil];
    [self setWorldTextField:nil];
    [self setDomainTextField:nil];
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Cancel and done actions

- (IBAction)cancel:(id)sender
{
	[self.delegate accountDetailsViewControllerDidCancel:self];
}
- (IBAction)done:(id)sender
{
	Account *account = [[Account alloc] init];
	
	//account.speedServer = self.speedServerSwitch.isOn;
	account.name = self.accountNameTextField.text;
	account.username = self.usernameTextField.text;
	account.password = self.passwordTextField.text;
	account.world = self.worldTextField.text;
	account.server = self.domainTextField.text;
	//account.tribe = enumTribe;
	
	if (![account isComplete])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data missing" message:@"Some data in this account is missing." delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles: nil];
		
		[alert show];
		
		return;
	}
	
	if (self.editingAccount == nil)
		[self.delegate accountDetailsViewController:self didAddAccount:account];
	else
		[self.delegate accountDetailsViewController:self didEditAccount:self.editingAccount newAccount:account];
}
- (IBAction)hideKeyboard:(id)sender
{
	[sender resignFirstResponder];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
		case 0:
			[accountNameTextField becomeFirstResponder];
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					[usernameTextField becomeFirstResponder];
					break;
				case 1:
					[passwordTextField becomeFirstResponder];
			}
			break;
		case 2:
			switch (indexPath.row) {
				case 0:
					[worldTextField becomeFirstResponder];
					break;
				case 1:
					[domainTextField becomeFirstResponder];
					break;
			}
		default:
			break;
	}
}

@end
