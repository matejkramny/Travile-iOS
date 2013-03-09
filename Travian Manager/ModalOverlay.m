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

#import "ModalOverlay.h"

@implementation ModalOverlay

@synthesize overlayBounds, overlayBoundsPushed, target;

static CGFloat transDuration = 0.4f;
static CGFloat overlayOpacity = 0.9f;

- (void)addOverlay {
	[self addOverlayAnimated:NO];
}

- (void)addOverlayAnimated:(BOOL)animated {
	[self addOverlayAnimated:animated usingAnimationType:OverlayAnimationTypeComplete];
}

- (void)addOverlayAnimated:(BOOL)animated usingAnimationType:(OverlayAnimationType)animationType {
	if (overlay) {
		[overlay removeFromSuperview];
		overlay = nil;
	}
	
	overlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[target addSubview:overlay];
	
	overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:overlayOpacity];
	
	if (animated) {
		// Reset the view position and alpha before re-animating
		[overlay setAlpha:0];
		[target setBounds:self.overlayBounds];
		
		[UIView beginAnimations:@"AddOverlay" context:nil];
		[UIView setAnimationDuration:transDuration];
		
		if ((animationType & OverlayAnimationTypeShadow) != 0)
			[overlay setAlpha:overlayOpacity];
		if ((animationType & OverlayAnimationTypeMove) != 0)
			[target setBounds:self.overlayBoundsPushed];
		
		[UIView commitAnimations];
	} else {
		if ((animationType & OverlayAnimationTypeMove) != 0)
			[target setBounds:self.overlayBoundsPushed];
		if ((animationType & OverlayAnimationTypeShadow) != 0)
			[overlay setAlpha:overlayOpacity];
	}
}

- (void)removeOverlay:(id)sender {
	[self removeOverlayAnimated:NO];
}

- (void)removeOverlayAnimated:(BOOL)animated {
	[self removeOverlayAnimated:animated usingAnimationType:OverlayAnimationTypeComplete];
}

- (void)removeOverlayAnimated:(BOOL)animated usingAnimationType:(OverlayAnimationType)animationType {
	[overlay setAlpha:0];
	[target setBounds:self.overlayBounds];
	
	if (animated) {
		// Reset the view position and alpha before re-animating
		if ((animationType & OverlayAnimationTypeShadow) != 0)
			[overlay setAlpha:overlayOpacity];
		
		if ((animationType & OverlayAnimationTypeMove) != 0)
			[target setBounds:self.overlayBoundsPushed];
		
		// Animate
		[UIView beginAnimations:@"RemoveOverlay" context:NULL];
		[UIView setAnimationDuration:transDuration];
		
		if ((animationType & OverlayAnimationTypeShadow) != 0)
			[overlay setAlpha:0];
		if ((animationType & OverlayAnimationTypeMove) != 0)
			[target setBounds:self.overlayBounds];
		
		[UIView commitAnimations];
	} else {
		if ((animationType & OverlayAnimationTypeMove) != 0)
			[target setBounds:self.overlayBounds];
		
		if ((animationType & OverlayAnimationTypeShadow) != 0)
			[overlay setAlpha:0];
	}
}

@end
