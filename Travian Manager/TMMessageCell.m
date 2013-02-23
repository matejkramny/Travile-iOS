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

#import "TMMessageCell.h"
#import "TMMessage.h"

@interface TMMessageCell ()

- (void)loadCheckedDeleteImage;
- (void)loadUncheckedDeleteImage;

@end

@implementation TMMessageCell {
	bool deleteButtonChecked;
	UIView *originalSelectedBackgroundView;
	UIView *originalBackgroundView;
	UIView *deleteBackgroundView;
}

@synthesize senderLabel, subjectLabel, dateLabel, unreadImage, message, deleteCheckboxImage;

static UIImage *uncheckedDeleteImage;
static UIImage *checkedDeleteImage;
static UIColor *highlightedColor;
static UIView *noneSelectedBackgroundView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		deleteButtonChecked = false;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	if (!self.editing)
		[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configure {
	[senderLabel setText:[message sender]];
	[subjectLabel setText:[message title]];
	[dateLabel setText:[message when]];
	if ([message read]) {
		[unreadImage setAlpha:0];
	} else {
		[unreadImage setAlpha:1];
	}
	
	originalSelectedBackgroundView = [super selectedBackgroundView];
	originalBackgroundView = [super backgroundView];
	deleteBackgroundView = [[UIView alloc] init];
	[deleteBackgroundView setBackgroundColor:[UIColor colorWithRed:0.833 green:0.933 blue:1 alpha:0.9]];
	
	if (!noneSelectedBackgroundView) {
		noneSelectedBackgroundView = [[UIView alloc] init];
		[noneSelectedBackgroundView setBackgroundColor:[UIColor clearColor]];
	}
	if (!highlightedColor) {
		highlightedColor = [UIColor whiteColor];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (self.editing) {
		[deleteCheckboxImage setAlpha:1];
		if (deleteButtonChecked) {
			if (!checkedDeleteImage)
				[self loadCheckedDeleteImage];
			[deleteCheckboxImage setImage:checkedDeleteImage];
		} else {
			if (!uncheckedDeleteImage)
				[self loadUncheckedDeleteImage];
			[deleteCheckboxImage setImage:uncheckedDeleteImage];
		}
	} else {
		[deleteCheckboxImage setAlpha:0];
	}
}

- (void)wasSelectedWhileEditing {
	if (self.editing)
		[self setDeleteButtonChecked:!deleteButtonChecked];
}

- (void)setEditing:(BOOL)editing {
	[self setEditing:editing animated:NO];
}
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	if (editing) {
		[[self senderLabel] setHighlightedTextColor:senderLabel.textColor];
		[[self subjectLabel] setHighlightedTextColor:subjectLabel.textColor];
		[[self dateLabel] setHighlightedTextColor:dateLabel.textColor];
		[super setSelectedBackgroundView:noneSelectedBackgroundView];
	} else {
		[[self senderLabel] setHighlightedTextColor:highlightedColor];
		[[self subjectLabel] setHighlightedTextColor:highlightedColor];
		[[self dateLabel] setHighlightedTextColor:highlightedColor];
		[super setSelectedBackgroundView:originalSelectedBackgroundView];
		
		[self setDeleteButtonChecked:NO];
	}
}

- (void)setDeleteButtonChecked:(BOOL)checked {
	if (checked == deleteButtonChecked)
		return;
	
	deleteButtonChecked = checked;
	
	if (checked) {
		[super setBackgroundView:deleteBackgroundView];
	} else {
		[super setBackgroundView:originalBackgroundView];
	}
}

- (void)loadCheckedDeleteImage {
	checkedDeleteImage = [UIImage imageNamed:@"checkBoxDelete.png"];
}
- (void)loadUncheckedDeleteImage {
	uncheckedDeleteImage = [UIImage imageNamed:@"checkBoxBlank.png"];
}

- (BOOL)isMarkedForDelete {
	return deleteButtonChecked;
}

@end
