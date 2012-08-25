//
//  BuildingActions.m
//  Travian Manager
//
//  Created by Matej Kramny on 22/08/2012.
//
//

#import "BuildingAction.h"
#import "HTMLNode.h"
#import "Resources.h"
#import "Storage.h"
#import "Account.h"

@interface BuildingAction ()

- (void)fetchFromResearchDiv:(HTMLNode *)research;

@end

@implementation BuildingAction

@synthesize name, resources, url;

- (id)initWithResearchDiv:(HTMLNode *)research {
	self = [super init];
	if (self) {
		[self fetchFromResearchDiv:research];
	}
	
	return self;
}

- (void)fetchFromResearchDiv:(HTMLNode *)research {
	HTMLNode *inf = [research findChildOfClass:@"information"];
	
	name = [[[[inf findChildOfClass:@"title"] findChildTags:@"a"] lastObject] contents];
	
	resources = [[Resources alloc] init];
	NSArray *spans = [[inf findChildOfClass:@"costs"] findChildTags:@"span"];
	NSMutableArray *spansParsed = [[NSMutableArray alloc] initWithCapacity:4];
	for (int i = 0; i < 4; i++) {
		HTMLNode *span = [spans objectAtIndex:i];
		
		NSString *img = [[span findChildTag:@"img"] rawContents];
		NSString *raw = [span rawContents];
		
		raw = [raw stringByReplacingOccurrencesOfString:img withString:@""];
		
		NSError *error;
		HTMLParser *p = [[HTMLParser alloc] initWithString:raw error:&error];
		if (error) {
			NSLog(@"Cannot parse resource %@ %@", [error localizedDescription], [error localizedRecoverySuggestion]);
			continue;
		}
		
		[spansParsed addObject:[NSNumber numberWithInt:[[[[[p body] findChildTag:@"span"] contents] stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] intValue]]];
	}
	
	resources.wood = [[spansParsed objectAtIndex:0] intValue];// Wood
	resources.clay = [[spansParsed objectAtIndex:1] intValue];// Clay
	resources.iron = [[spansParsed objectAtIndex:2] intValue];// Iron
	resources.wheat = [[spansParsed objectAtIndex:3] intValue];// Wheat
	
	HTMLNode *button = [[inf findChildOfClass:@"contractLink"] findChildTag:@"button"];
	if (button) {
		url = [[[button getAttributeNamed:@"onclick"] stringByReplacingOccurrencesOfString:@"window.location.href = '" withString:@""] stringByReplacingOccurrencesOfString:@"'; return false;" withString:@""];
	} else
		url = nil;
}

- (void)research {
	if (url == nil)
		return;
	
	@autoreleasepool {
		NSURL *URL = [[[Storage sharedStorage] account] urlForString:url];
		NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:URL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
		
		[req setHTTPShouldHandleCookies:YES];
		__unused NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:nil startImmediately:YES];
	}
}

@end
