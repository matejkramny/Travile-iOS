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
	CGFloat textX = 45.f;
	CGRect textFrame = CGRectMake(textX, self.textLabel.frame.origin.y + 2.5, self.textLabel.frame.size.width, self.textLabel.frame.size.height - 5); // reduce height because stangely the background was black when highlighted..
	self.textLabel.frame = textFrame;
	
	CGRect imageFrame;
	CGFloat actualWidth = self.imageView.frame.size.width;
	CGFloat newImageX = (textX / 2) - (actualWidth / 2); // centers the image so it doesn't look messy (with image + text..)
	
	CGRect currentImageFrame = self.imageView.frame;
	imageFrame = CGRectMake(newImageX, currentImageFrame.origin.y, currentImageFrame.size.width, currentImageFrame.size.height);
	
	self.imageView.frame = imageFrame;
}

@end
