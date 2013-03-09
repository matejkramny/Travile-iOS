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

#import "TMNewMessageViewController.h"
#import "AppDelegate.h"
#import "TMStorage.h"
#import "TMMessage.h"
#import "TMMessageContentTextView.h"
#import "TMTextViewCell.h"
#import "TMLabelAndTextFieldCell.h"

@interface TMNewMessageViewController () <TMMessageContentDelegate> {
	TMStorage *storage;
	UIAlertView *continueWithoutSubject;
	MBProgressHUD *HUD;
	TMMessage *sentMessage;
	NSArray *cells;
}

- (void)sendMessage;
- (void)buildCells;

@end

@implementation TMNewMessageViewController

@synthesize sendButton;
@synthesize replyToMessage;
@synthesize forwardMessage;
@synthesize delegate;

static NSString *toCellIdentifier = @"ToCell";
static NSString *subjectCellIdentifier = @"SubjectCell";
static NSString *contentCellIdentifier = @"ContentCell";

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
	[self.tableView setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewDidUnload
{
	[self setSendButton:nil];
	[self setReplyToMessage:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self buildCells];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(willShowKeyboard:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didShowKeyboard:)
												 name:UIKeyboardDidShowNotification
											   object:nil];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.0];
	
	[[[cells objectAtIndex:0] field] becomeFirstResponder];
	[UIView commitAnimations];
	
	if (replyToMessage || forwardMessage) {
		// auto height of textview
		UITextView *textView = [[cells objectAtIndex:2] textView];
		
		CGFloat height = [textView contentSize].height;
		CGRect viewRect = [[self view] frame];
		CGFloat minHeight = viewRect.size.height - kbHeight - 38*2;
		
		if (height < minHeight)
			height = minHeight;
		[textView setFrame:CGRectMake(0, 0, [textView contentSize].width, height)];
	}
}

- (void)buildCells {
	TMLabelAndTextFieldCell *toCell = [self.tableView dequeueReusableCellWithIdentifier:toCellIdentifier];
	if (!toCell)
		toCell = [[TMLabelAndTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:toCellIdentifier];
	TMLabelAndTextFieldCell *subjectCell = [self.tableView dequeueReusableCellWithIdentifier:subjectCellIdentifier];
	if (!subjectCell)
		subjectCell = [[TMLabelAndTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subjectCellIdentifier];
	TMTextViewCell *contentCell = [self.tableView dequeueReusableCellWithIdentifier:contentCellIdentifier];
	if (!contentCell)
		contentCell = [[TMTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentCellIdentifier];
	
	if (replyToMessage != nil) {
		[[toCell field] setText:[replyToMessage sender]];
		
		NSString *tit = [replyToMessage title];
		if ([tit length] >= 3 && [[tit substringToIndex:3] isEqualToString:@"RE:"]) {
			tit = [NSString stringWithFormat:@"RE^2:%@", [tit substringFromIndex:3]];
		} else if ([tit length] >= 3 && [[tit substringToIndex:3] isEqualToString:@"RE^"]) {
			int replyTimes = [[[tit substringToIndex:4] substringFromIndex:3] intValue];
			if (replyTimes != 0) {
				tit = [NSString stringWithFormat:@"RE^%d:%@", replyTimes+1, [tit substringFromIndex:4+[[NSString stringWithFormat:@"%d", replyTimes] length]]];
			}
		} else {
			tit = [NSString stringWithFormat:@"RE: %@", tit];
		}
		
		[[subjectCell field] setText:tit];
		[[contentCell textView] setText:[NSString stringWithFormat:@"\n____________\n%@ wrote:\n%@", [replyToMessage sender], [replyToMessage content]]];
	} else if (forwardMessage != nil) {
		NSString *tit = [forwardMessage title];
		if ([tit length] <= 4 || ![[tit substringToIndex:4] isEqualToString:@"FWD "]) {
			tit = [@"FWD " stringByAppendingString:tit];
		}
		
		[[subjectCell field] setText:tit];
		[[contentCell textView] setText:[NSString stringWithFormat:@"Forwarded message from [player]%@[/player] \n\n > ____________\n%@", [forwardMessage sender], [forwardMessage content]]];
	}
	
	TMMessageContentTextView *textView = [contentCell textView];
	
	[textView setMessageDelegate:self];
	[textView setDelegate:[contentCell textView]];
	
	cells = @[toCell, subjectCell, contentCell];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

#pragma mark - Table view delegate

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [cells objectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.row) {
		case 0:
			[[[cells objectAtIndex:0] field] becomeFirstResponder];
			break;
		case 1:
			[[[cells objectAtIndex:1] field] becomeFirstResponder];
			break;
		case 2:
			[[[cells objectAtIndex:2] textView] becomeFirstResponder];
			break;
		default:
			break;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row <= 1)
		return 38;
	else {
		CGFloat height = [[[cells objectAtIndex:2] textView] frame].size.height;
		
		return height;
	}
}

#pragma mark - Other

- (IBAction)sendButtonPressed:(id)sender {
	if ([[[[cells objectAtIndex:0] field] text] length] == 0) {
		return;
	} else if ([[[[cells objectAtIndex:1] field] text] length] == 0) {
		[self closeKeyboard];
		
		continueWithoutSubject = [[UIAlertView alloc] initWithTitle:@"No subject. Send anyway?" message:@"Are you sure you want to send wihtout message subject?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
		[continueWithoutSubject show];
		
		return;
	}
	
	[self sendMessage];
}

- (IBAction)closeView:(id)sender {
	[self closeKeyboard];
//	[self dismissModalViewControllerAnimated:YES];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeKeyboard {
	[[[cells objectAtIndex:0] field] resignFirstResponder];
	[[[cells objectAtIndex:1] field] resignFirstResponder];
	[[[cells objectAtIndex:2] textView] resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView == continueWithoutSubject) {
		if (buttonIndex == 1) {
			[self sendMessage];
			[self closeView:self];
		}
	}
}

- (void)sendMessage {
	sentMessage = [[TMMessage alloc] init];
	sentMessage.title = [[[cells objectAtIndex:1] field] text];
	sentMessage.content = [[[cells objectAtIndex:2] textView] text];
	
	[sentMessage addObserver:self forKeyPath:@"sent" options:NSKeyValueObservingOptionNew context:nil];
	HUD = [MBProgressHUD showHUDAddedTo:[[self navigationController] view] animated:YES];
	HUD.delegate= self;
	HUD.labelText = @"Sending message";
	[self closeKeyboard];
	
	[sentMessage send:[[[cells objectAtIndex:0] field] text]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"sent"]) {
		if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue]) {
			HUD.labelText = @"Sent";
			[HUD hide:YES afterDelay:0.3];
			[sentMessage removeObserver:self forKeyPath:@"sent"];
		}
	} else if ([keyPath isEqualToString:@"text"]) {
		UITextView *textView = [[cells objectAtIndex:2] textView];
		CGRect frame = [textView frame];
		frame.size.height = [textView contentSize].height;
		[textView setFrame:frame];
		[[cells objectAtIndex:2] setFrame:frame];
	}
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	[self closeView:self];
	if ([self delegate])
		[[self delegate] pHNewMessageController:self didSendMessage:sentMessage];
}

#pragma mark - MessageContentDelegate

static CGFloat kbHeight = 216; // Keyboard height
- (void)textView:(UITextView *)textView textChanged:(CGFloat)height {
	CGRect viewRect = [[self view] frame];
	CGFloat minHeight = viewRect.size.height - kbHeight - 38*2;
	
	if (height < minHeight)
		height = minHeight;
	
	CGRect frame = [[[cells objectAtIndex:2] textView] frame];
	[[[cells objectAtIndex:2] textView] setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height)];
	
	[self.tableView beginUpdates];
	//[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	//[self.tableView reloadData];
	[self.tableView endUpdates];
}

#pragma mark -

- (void)willShowKeyboard:(NSNotification *)notification {
	[UIView setAnimationsEnabled:NO];
}

- (void)didShowKeyboard:(NSNotification *)notification {
	[UIView setAnimationsEnabled:YES];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
