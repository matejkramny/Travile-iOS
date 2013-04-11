/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMDarkImageCell.h"

@implementation TMDarkImageCell

@synthesize indentTitle;

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (!indentTitle)
		return;
	
	// Aligns the text because images have different widths
	CGRect textFrame = CGRectMake(40, self.textLabel.frame.origin.y + 2.5, self.textLabel.frame.size.width, self.textLabel.frame.size.height - 5); // reduce height because stangely the background was black when highlighted..
	self.textLabel.frame = textFrame;
}

@end
