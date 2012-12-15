//
//  PHAccountDetailsViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 21/07/2012.
//
//

#import "PHAccountDetailsViewController.h"
#import "Account.h"
#import "PHAccountTextFieldCell.h"
#import "PHAccountTextFieldRightCell.h"
#import "PHDeleteCell.h"
#import "Storage.h"

@interface PHAccountDetailsViewController () {
	UITableViewCell __weak *usernameCell, __weak *passwordCell, __weak *nameCell, __weak *serverCell, __weak *worldCell; // Text Cells
}

@end

@implementation PHAccountDetailsViewController

@synthesize delegate, editingAccount;

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
	}
	
	[[self tableView] setBackgroundView:nil];
	
	[super viewDidLoad];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - TableView Data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.editingAccount == nil ? 3 : 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 1;
		case 1:
		case 2:
			return 2;
		case 3:
			return 1;
	}
	
	return 0;
}

static NSString *textFieldCellID = @"TextField";
static NSString *textFieldRightCellID = @"TextFieldRight";
static NSString *deleteButtonCellID = @"DeleteButton";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (nameCell == nil) {
			PHAccountTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:textFieldCellID];
			if (!cell)
				cell = [[PHAccountTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textFieldCellID];
		
			cell.textField.placeholder = @"Something meaningful";
		
			if (self.editingAccount != nil)
				cell.textField.text = editingAccount.name;
			
			nameCell = cell;
			
			[cell configure];
			
			[cell.textField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
			[cell.textField setAutocorrectionType:UITextAutocorrectionTypeYes];
		}
		
		return nameCell;
	} else if (indexPath.section == 1) {
		if ((indexPath.row == 0 && usernameCell == nil) || (indexPath.row == 1 && passwordCell == nil)) {
			PHAccountTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:textFieldCellID];
			if (!cell)
				cell = [[PHAccountTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textFieldCellID];
			
			if (indexPath.row == 0) {
				cell.textField.placeholder = @"Username or email";
				
				if (editingAccount != nil)
					cell.textField.text = editingAccount.username;
				
				usernameCell = cell;
			} else {
				cell.textField.placeholder = @"Password";
				
				if (editingAccount != nil)
					cell.textField.text = editingAccount.password;
				
				[cell.textField setSecureTextEntry:YES];
				
				passwordCell = cell;
			}
			
			[cell configure];
			
			[cell.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
			[cell.textField setAutocorrectionType:UITextAutocorrectionTypeNo];
		}
		
		return indexPath.row == 0 ? usernameCell : passwordCell;
	} else if (indexPath.section == 2) {
		if ((indexPath.row == 0 && worldCell == nil) || (indexPath.row == 1 && serverCell == nil)) {
			PHAccountTextFieldRightCell *cell = [tableView dequeueReusableCellWithIdentifier:textFieldRightCellID];
			if (!cell)
				cell = [[PHAccountTextFieldRightCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textFieldRightCellID];
			
			if (indexPath.row == 0) {
				cell.textField.placeholder = @"ts1";
				cell.label.text = @"World";
				
				if (editingAccount != nil)
					cell.textField.text = editingAccount.world;
				
				worldCell = cell;
			} else {
				cell.textField.placeholder = @"com";
				cell.label.text = @"Server";
				
				if (editingAccount != nil)
					cell.textField.text = editingAccount.server;
				
				serverCell = cell;
			}
			
			[cell configure];
			
			[cell.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
			[cell.textField setAutocorrectionType:UITextAutocorrectionTypeNo];
		}
		
		return indexPath.row == 0 ? worldCell : serverCell;
	} else {
		// Delete button
		PHDeleteCell *cell = [tableView dequeueReusableCellWithIdentifier:deleteButtonCellID];
		if (!cell)
			cell = [[PHDeleteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deleteButtonCellID];
		
		[cell configure];
		
		return cell;
	}
}

#pragma mark UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) // 0 = delete button
		[self.delegate accountDetailsViewController:self didDeleteAccount:self.editingAccount];
}

#pragma mark - Cancel and done actions

- (IBAction)cancel:(id)sender
{
	[self.delegate accountDetailsViewControllerDidCancel:self];
}

- (IBAction)delete:(id)sender {
	// Add method to delegate
	
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this account?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
	[sheet showInView:self.navigationController.view];
}

- (IBAction)done:(id)sender
{
	Account *account;
	if (self.editingAccount != nil)
		account = editingAccount;
	else
		account = [[Account alloc] init];
	
	account.name = [(PHAccountTextFieldCell *)nameCell textField].text;
	account.password = [(PHAccountTextFieldCell *)passwordCell textField].text;
	account.username = [(PHAccountTextFieldCell *)usernameCell textField].text;
	account.world = [(PHAccountTextFieldRightCell *)worldCell textField].text;
	account.server = [(PHAccountTextFieldRightCell *)serverCell textField].text;
	
	if (![account isComplete])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data missing" message:@"Some data in this account is missing." delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles: nil];
		
		[alert show];
		
		return;
	}
	
	if (self.editingAccount == nil)
		[self.delegate accountDetailsViewController:self didAddAccount:account];
	else
		[self.delegate accountDetailsViewController:self didEditAccount:self.editingAccount];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	switch (indexPath.section) {
		case 0:
			cell = nameCell;
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					cell = usernameCell;
					break;
				case 1:
					cell = passwordCell;
					break;
			}
			break;
		case 2:
			switch (indexPath.row) {
				case 0:
					cell = worldCell;
					break;
				case 1:
					cell = serverCell;
					break;
			}
			break;
		case 3:
			return;
	}
	
	if ([cell isKindOfClass:[PHAccountTextFieldCell class]])
		[[(PHAccountTextFieldCell *)cell textField] becomeFirstResponder];
	else if ([cell isKindOfClass:[PHAccountTextFieldRightCell class]])
		[[(PHAccountTextFieldRightCell *)cell textField] becomeFirstResponder];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Account name";
		case 1:
			return @"Login details";
		case 2:
			return @"Travian server";
		default:
			return @"";
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
		case 1:
			return @"Leave password field empty to be asked every time";
		default:
			return @"";
	}
}

@end
