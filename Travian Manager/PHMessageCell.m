//
//  PHMessageCell.m
//  Travian Manager
//
//  Created by Matej Kramny on 14/12/2012.
//
//

#import "PHMessageCell.h"
#import "Message.h"

@interface PHMessageCell ()

- (void)loadCheckedDeleteImage;
- (void)loadUncheckedDeleteImage;

@end

@implementation PHMessageCell {
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
