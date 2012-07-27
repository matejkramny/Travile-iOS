//
//  PHNewMessageViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 23/07/2012.
//
//

#import "PHNewMessageViewController.h"
#import "AppDelegate.h"
#import "Storage.h"
#import "Message.h"

@interface PHNewMessageViewController () {
	AppDelegate *appDelegate;
	Storage *storage;
	UIAlertView *continueWithoutSubject;
}

- (void)sendMessage;

@end

@implementation PHNewMessageViewController

@synthesize recipient;
@synthesize subject;
@synthesize content;
@synthesize sendButton;
@synthesize replyToMessage;

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
    [self setRecipient:nil];
    [self setSubject:nil];
    [self setContent:nil];
	[self setSendButton:nil];
	[self setReplyToMessage:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (replyToMessage != nil) {
		[recipient setText:[replyToMessage sender]];
		
		NSString *tit = [replyToMessage title];
		if ([[tit substringToIndex:3] isEqualToString:@"RE:"]) {
			tit = [NSString stringWithFormat:@"RE^2:%@", [tit substringFromIndex:3]];
		} else if ([[tit substringToIndex:3] isEqualToString:@"RE^"]) {
			int replyTimes = [[[tit substringToIndex:4] substringFromIndex:3] intValue];
			if (replyTimes != 0) {
				tit = [NSString stringWithFormat:@"RE^%d:%@", replyTimes+1, [tit substringFromIndex:4+[[NSString stringWithFormat:@"%d", replyTimes] length]]];
			}
		}
		
		[subject setText:tit];
		[content setText:[NSString stringWithFormat:@"\n____________\n%@ wrote:\n%@", [replyToMessage sender], [replyToMessage content]]];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[recipient becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.row) {
		case 0:
			[recipient becomeFirstResponder];
			break;
		case 1:
			[subject becomeFirstResponder];
			break;
		case 2:
			[content becomeFirstResponder];
			break;
		default:
			break;
	}
}

- (IBAction)sendButtonPressed:(id)sender {
	if ([[recipient text] length] == 0) {
		return;
	} else if ([[subject text] length] == 0) {
		[self closeKeyboard];
		
		continueWithoutSubject = [[UIAlertView alloc] initWithTitle:@"No subject. Send anyway?" message:@"Are you sure you want to send wihtout message subject?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
		[continueWithoutSubject show];
		
		return;
	}
	
	[self sendMessage];
	[self closeView:self];
}

- (IBAction)closeView:(id)sender {
	[self closeKeyboard];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)closeKeyboard {
	[recipient resignFirstResponder];
	[subject resignFirstResponder];
	[content resignFirstResponder];
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
	Message *message = [[Message alloc] init];
	message.title = [subject text];
	message.content = [content text];
	
	[message send:[recipient text]];
}

@end
