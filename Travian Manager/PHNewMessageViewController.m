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
	MBProgressHUD *HUD;
	Message *sentMessage;
}

- (void)sendMessage;

@end

@implementation PHNewMessageViewController

@synthesize recipient;
@synthesize subject;
@synthesize content;
@synthesize contentCell;
@synthesize sendButton;
@synthesize replyToMessage;
@synthesize delegate;

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
	[self setContentCell:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (replyToMessage != nil) {
		[recipient setText:[replyToMessage sender]];
		
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
		
		[subject setText:tit];
		[content setText:[NSString stringWithFormat:@"\n____________\n%@ wrote:\n%@", [replyToMessage sender], [replyToMessage content]]];
	}
	
	//[content addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
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
	sentMessage = [[Message alloc] init];
	sentMessage.title = [subject text];
	sentMessage.content = [content text];
	
	[sentMessage addObserver:self forKeyPath:@"sent" options:NSKeyValueObservingOptionNew context:nil];
	HUD = [MBProgressHUD showHUDAddedTo:[[self navigationController] view] animated:YES];
	HUD.delegate= self;
	HUD.labelText = @"Sending message";
	[self closeKeyboard];
	
	[sentMessage send:[recipient text]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"sent"]) {
		if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue]) {
			HUD.labelText = @"Sent";
			[HUD hide:YES afterDelay:0.3];
			[sentMessage removeObserver:self forKeyPath:@"sent"];
		}
	} else if ([keyPath isEqualToString:@"text"]) {
		CGRect frame = [content frame];
		frame.size.height = [content contentSize].height;
		[content setFrame:frame];
		[contentCell setFrame:frame];
	}
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	[self closeView:self];
	if ([self delegate])
		[[self delegate] pHNewMessageController:self didSendMessage:sentMessage];
}

@end
