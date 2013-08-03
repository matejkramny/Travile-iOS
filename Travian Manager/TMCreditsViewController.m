/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMCreditsViewController.h"
#import "AppDelegate.h"

@interface TMCreditsViewController () {
	UILabel *titleLabel;
}

@end

@implementation TMCreditsViewController

@synthesize webView;

- (void)viewDidLoad {
	[super viewDidLoad];
	NSString *version = [AppDelegate getAppVersion];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[@"http://about.travianapp.matej.me/?version=" stringByAppendingString:version]]];
	[webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.navigationItem setTitle:NSLocalizedString(@"Credits", @"Credits button in settings")];
	
	[super viewWillAppear:animated];
}

@end
