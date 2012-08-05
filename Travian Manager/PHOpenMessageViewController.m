//
//  PHOpenMessageViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 25/07/2012.
//
//

#import "PHOpenMessageViewController.h"
#import "AppDelegate.h"
#import "Storage.h"
#import "Account.h"
#import "PHNewMessageViewController.h"

@interface PHOpenMessageViewController ()

@end

@implementation PHOpenMessageViewController
@synthesize sentBy;
@synthesize time;
@synthesize subject;
@synthesize content;
@synthesize message;
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
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self setTitle:message.title];
	
	[sentBy setText:message.sender];
	[time setText:message.when];
	[subject setText:message.title];
	[content setText:message.content];
}

- (void)viewDidUnload
{
    [self setSentBy:nil];
    [self setTime:nil];
    [self setSubject:nil];
	[self setContent:nil];
	[self setMessage:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)return:(id)sender {
	//[self dismissModalViewControllerAnimated:YES];
	[delegate openMessageViewController:self didCloseMessage:message];
}

- (IBAction)delete:(id)sender {
	[[self message] delete];
	Account *a = [[(AppDelegate *)[UIApplication sharedApplication].delegate storage] account];
	NSMutableArray *ar = [[a messages] mutableCopy];
	[ar removeObjectIdenticalTo:message];
	a.messages = [ar copy];
	
	[self return:sender];
}
- (IBAction)reply:(id)sender {
	[self performSegueWithIdentifier:@"MessageReply" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"MessageReply"]) {
		UINavigationController *nc = [segue destinationViewController];
		PHNewMessageViewController *nmvc = [[nc viewControllers] objectAtIndex:0];
		nmvc.replyToMessage = message;
	}
}


@end
