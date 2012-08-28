//
//  Barracks.m
//  Travian Manager
//
//  Created by Matej Kramny on 26/08/2012.
//
//

#import "Barracks.h"
#import "HTMLNode.h"
#import "Troop.h"
#import "Resources.h"

@interface Barracks () {
	NSString *postData; // Starts with hidden values from the form
}

- (void)fetchTroopsFromBuildDiv:(HTMLNode *)build;

@end

@implementation Barracks

- (void)fetchDescription {
	[super fetchDescription];
	
	[super addObserver:self forKeyPath:@"buildDiv" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)fetchTroopsFromBuildDiv:(HTMLNode *)build {
	// Find form, load available troops into array
	HTMLNode *form = [build findChildTag:@"form"];
	if (!form) return;
	
	// Hidden inputs
	NSArray *hiddenInputs = [form findChildrenWithAttribute:@"type" matchingName:@"hidden" allowPartial:NO];
	postData = @"";
	for (HTMLNode *hiddenInput in hiddenInputs) {
		postData = [postData stringByAppendingFormat:@"%@=%@&", [hiddenInput getAttributeNamed:@"name"], [hiddenInput getAttributeNamed:@"value"]];
	}
	
	// Confirm button
	postData = [postData stringByAppendingString:@"s1=ok&"];
	
	// Troops
	HTMLNode *div = [form findChildOfClass:@"buildActionOverview trainUnits"];
	NSArray *actions = [div findChildrenWithAttribute:@"class" matchingName:@"action" allowPartial:YES];
	
	for (HTMLNode *action in actions) {
		Troop *troop = [[Troop alloc] init];
		
		// Title
		HTMLNode *title = [action findChildOfClass:@"tit"];
		troop.name = [[[title findChildTags:@"a"] lastObject] contents];
		
		// Max
		troop.maxTroops = [[[action findChildWithAttribute:@"onclick" matchingName:@"$(this).getParent('div.details').getElement('input').value=" allowPartial:YES] contents] intValue];
		
		// Input value
		HTMLNode *input = [action findChildTag:@"input"];
		troop.formIdentifier = [input getAttributeNamed:@"name"];
		
		// Resources
		HTMLNode *costs = [action findChildOfClass:@"showCosts"];
		
		NSArray *spans = [costs findChildTags:@"span"];
		NSMutableArray *spansParsed = [[NSMutableArray alloc] initWithCapacity:[spans count]];
		for (int i = 0; i < [spans count]; i++) {
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
			
			if ([[span getAttributeNamed:@"class"] isEqualToString:@"clocks"])
				[spansParsed addObject:[[[p body] findChildTag:@"span"] contents]];
			else
				[spansParsed addObject:[NSNumber numberWithInt:[[[[[p body] findChildTag:@"span"] contents] stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] intValue]]];
		}
		
		troop.resources = [[Resources alloc] init];
		
		troop.resources.wood = [[spansParsed objectAtIndex:0] intValue];// Wood
		troop.resources.clay = [[spansParsed objectAtIndex:1] intValue];// Clay
		troop.resources.iron = [[spansParsed objectAtIndex:2] intValue];// Iron
		troop.resources.wheat = [[spansParsed objectAtIndex:3] intValue];// Wheat
		
		// Research time..
		troop.researchTime = [spansParsed lastObject];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"buildDiv"]) {
		if ([change objectForKey:NSKeyValueChangeNewKey] != nil) {
			[super removeObserver:self forKeyPath:keyPath];
			
			HTMLNode *build = [super buildDiv];
			[self fetchTroopsFromBuildDiv:build];
		}
	}
}

@end
