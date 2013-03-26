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

#import "TMOpenMessageViewController.h"
#import "AppDelegate.h"
#import "TMStorage.h"
#import "TMAccount.h"
#import "TMNewMessageViewController.h"
#import "TMMessageContentCell.h"
#import "AppDelegate.h"
#import "GAI.h"

@interface TMOpenMessageViewController () <UIActionSheetDelegate> {
	bool didCloseReply;
	NSArray *cells;
	UIActionSheet *optionsActionSheet;
}

- (void)buildCells;

@end

@implementation TMOpenMessageViewController

@synthesize message;
@synthesize delegate;

static NSString *trackedViewName = @"Open message";

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
	
	//[self.tableView setBackgroundColor:[UIColor whiteColor]];
	
	cells = @[];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self setTitle:message.title];
	
	[[(AppDelegate *)[UIApplication sharedApplication].delegate tracker] sendView:trackedViewName];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewDidUnload
{
	[self setMessage:nil];
    [super viewDidUnload];
}

- (void)configure {
	[self buildCells];
	[self.tableView reloadData];
}

- (IBAction)menuBarPressed:(id)sender {
	if (!optionsActionSheet) {
		optionsActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Reply", @"Forward", @"Archive", @"Delete", nil];
	}
	
	[optionsActionSheet showFromRect:CGRectMake(0, 0, [self.view frame].size.width, [self.view frame].size.height) inView:self.view animated:YES];
}

static NSString *rightDetailCellIdentifier = @"RightDetailCell";
static NSString *messageContentCellIdentifier = @"MessageContentCell";
static NSString *subjectCellIdentifier = @"SubjectCell";

- (void)buildCells {
	UITableViewCell *fromCell = [self.tableView dequeueReusableCellWithIdentifier:rightDetailCellIdentifier];
	fromCell.textLabel.text = @"Sender";
	fromCell.detailTextLabel.text = [message sender];
	
	UITableViewCell *subjectCell = [self.tableView dequeueReusableCellWithIdentifier:subjectCellIdentifier];
	subjectCell.textLabel.text = [message title];
	subjectCell.detailTextLabel.text = [message when];
	
	TMMessageContentCell *contentCell = [self.tableView dequeueReusableCellWithIdentifier:messageContentCellIdentifier];
	if (!contentCell) {
		contentCell = [[TMMessageContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subjectCellIdentifier];
	}
	[contentCell configure:message];
	
	NSIndexPath *oddPath = [NSIndexPath indexPathForRow:1 inSection:0];
	NSIndexPath *evenPath = [NSIndexPath indexPathForRow:0 inSection:0];
	
	[AppDelegate setCellAppearance:fromCell forIndexPath:evenPath];
	[AppDelegate setCellAppearance:subjectCell forIndexPath:oddPath];
	[AppDelegate setCellAppearance:contentCell forIndexPath:evenPath];
	
	cells = @[fromCell, subjectCell, contentCell];
}

#pragma mark Table Data Source

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [cells count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [cells objectAtIndex:indexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (int)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 0;
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.row) {
		case 0:
		default:
			return 35;
		case 1:
			return 50;
		case 2:
			// Content
			return [(TMMessageContentCell *)[cells objectAtIndex:indexPath.row] getHeight];
	}
}

#pragma mark - IBAction

- (IBAction)deleteMessage:(id)sender {
	[[self message] delete];
	TMAccount *a = [[TMStorage sharedStorage] account];
	NSMutableArray *ar = [[a messages] mutableCopy];
	[ar removeObjectIdenticalTo:message];
	a.messages = [ar copy];
}
- (IBAction)reply:(id)sender {
}

#pragma mark - PrepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			// Reply
			[delegate openMessageViewController:self wantsToReplyToMessage:message];
			break;
		case 1:
			// FWD
			[delegate openMessageViewController:self wantsToForwardMessage:message];
			break;
		case 2:
			// Archive
			[delegate openMessageViewController:self didArchiveMessage:message];
			break;
		case 3:
			// Delete
			[delegate openMessageViewController:self didDeleteMessage:message];
			break;
		default:
			return;
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

@end
