//
//  BuildingMap.m
//  Travian Manager
//
//  Created by Matej Kramny on 14/08/2012.
//
//

#import "BuildingMap.h"
#import <QuartzCore/QuartzCore.h>
#import "Building.h"

@interface BuildingMap () {
	__weak NSArray *bs; // Buildings alias
	__weak NSArray *hbs; // Hidden(not selectable but visible) Buildings alias
	NSMutableArray *bsButtons; // Buildings buttons alias
}

- (void)buttonTouched:(id)sender;
- (void)setSelectedButtonAtIndex:(NSInteger)index;

@end

@implementation BuildingMap

@synthesize delegate;

- (id)initWithBuildings:(NSArray *)buildings hideBuildings:(NSArray *)hideBuildings {
	self = [super init];
	if (self) {
		bs = buildings;
		hbs = hideBuildings;
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Constants defining Widths and Heights
const float resWidth = 500.0f;
const float resHeight = 370.0f;
const float vilWidth = 628.0f;
const float vilHeight = 534.0f;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(context, [UIColor colorWithRed:203.0f/255.0f green:244.0f/255.0f blue:178.0f/255.0f alpha:0.5f].CGColor);
	CGContextSetStrokeColorWithColor(context, [UIColor brownColor].CGColor);
	
	// Draw outer ellipse
	CGFloat offset = 5.0f;
	CGContextStrokeEllipseInRect(context, CGRectMake(offset, offset, self.bounds.size.width - offset*2, self.bounds.size.height - offset*2));
	CGContextFillEllipseInRect(context, CGRectMake(offset+1, offset+1, self.bounds.size.width - offset*2 - 2, self.bounds.size.height - offset*2 - 2));
	
	int (^computeCoordinateX)(float, bool) = ^(float coordinate, bool resource) {
		if (coordinate == 0) return 0;
		
		if (resource)
			// Compute Coordinate for resource field
			return (int)((coordinate / resWidth) * 380 - 32) - 3;
		else
			// For village building
			return (int)((coordinate / vilWidth) * 373 - 36) - 3;
	};
	int (^computeCoordinateY)(float, bool) = ^(float coordinate, bool resource) {
		if (coordinate == 0) return 0;
		
		if (resource)
			// Compute Coordinate for resource field
			return (int)((coordinate / resHeight) * 215 - 30) - 3;
		else
			// For village building
			return (int)((coordinate / vilHeight) * 230 - 10) - 3;
	};
	
	void (^drawBuilding)(Building *, bool) = ^(Building *building, bool inactive) {
		// Draw a square in whereabouts of building b
		CGPoint coord = building.coordinates;
		
		int x, y, w = 26, h = 26;
		if ([building page] & TPResources) {
			x = computeCoordinateX(coord.x, true); // Resize the coordinate according to view width and height
			y = computeCoordinateY(coord.y, true);
		} else {
			x = computeCoordinateX(coord.x, false); //320
			y = computeCoordinateY(coord.y, false); // 185
		}
		
		// Check if Rally Point. Rally points don't have coordinates
		if ([building gid] == TBRallyPoint) {
			x = computeCoordinateX(395.0f, false); // 356 origin
			y = computeCoordinateY(200.0f, false); // 171 origin
		} else if ([building gid] == TBCityWall || [building gid] == TBPalisade || [building gid] == TBEarthWall || ([[building bid] isEqualToString:@"40"] && [building level] == 0)) {
			// Walls should be around left-top corner of map
			x = 64;
			y = 7;
		}
		
		UIColor *bg = building.isBeingUpgraded ? [UIColor colorWithRed:253.0f/255.0f green:151.0f/255.0f blue:63.0f/255.0f alpha:1.0f] : [UIColor whiteColor];
		UIColor *stroke = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.5f];
		
		if (inactive) {
			bg = building.isBeingUpgraded ? [UIColor colorWithRed:253.0f/255.0f green:151.0f/255.0f blue:63.0f/255.0f alpha:0.4f] : [UIColor colorWithWhite:1.0 alpha:0.4];
			stroke = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.2f];
			
			CGContextSetFillColorWithColor(context, bg.CGColor);
			CGContextSetStrokeColorWithColor(context, stroke.CGColor);
			CGContextFillEllipseInRect(context, CGRectMake(x, y, w, h));
			CGContextStrokeEllipseInRect(context, CGRectMake(x, y, w, h));
			
			UILabel *label = [[UILabel alloc] init];
			[label setFont:[UIFont systemFontOfSize:13]];
			[label setAlpha:(inactive) ? 0.5f : 1.0f];
			[label setFrame:CGRectMake(x, y, w, h)];
			[label setTextAlignment:UITextAlignmentCenter];
			[label setText:[NSString stringWithFormat:@"%d", building.level]];
			[label setTextColor:[UIColor redColor]];
			[label setShadowColor:[UIColor blackColor]];
			[label setShadowOffset:CGSizeMake(0.5f, 0.5f)];
			[label drawTextInRect:CGRectMake(x, y, w, h)];
		} else {
			UIButton *button = [[UIButton alloc] init];
			[button setBackgroundColor:bg];
			[button setFrame:CGRectMake(x, y, w, h)];
			[button setTitle:[NSString stringWithFormat:@"%d", building.level] forState:UIControlStateNormal];
			[button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
			[[button titleLabel] setFont:[UIFont systemFontOfSize:12]];
			[[button titleLabel] setShadowColor:[UIColor blackColor]];
			[[button titleLabel] setShadowOffset:CGSizeMake(0.5f, 0.5f)];
			[[button layer] setCornerRadius:w/2];
			
			[button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
			
			[self addSubview:button];
			
			CGContextSetStrokeColorWithColor(context, stroke.CGColor);
			CGContextStrokeEllipseInRect(context, CGRectMake(x, y, w, h));
			
			if (!bsButtons)
				bsButtons = [[NSMutableArray alloc] init];
			
			[bsButtons addObject:button];
		}
	};
	
	for (int i = 0; i < [bs count]; i++) {
		Building *building = [bs objectAtIndex:i];
		drawBuilding(building, false);
	}
	
	for (int i = 0; i < [hbs count]; i++) {
		if ([[hbs objectAtIndex:i] isKindOfClass:[NSArray class]]) {
			for (Building *hbuilding in [hbs objectAtIndex:i]) {
				drawBuilding(hbuilding, true);
			}
		} else {
			drawBuilding([hbs objectAtIndex:i], true);
		}
	}
	
	[self setSelectedButtonAtIndex:0];
}

- (void)setSelectedButtonAtIndex:(NSInteger)index {
	// Unselect other buttons at first
	for (int i = 0; i < [bsButtons count]; i++) {
		UIButton *button = [bsButtons objectAtIndex:i];
		
		if (i == index) {
			// Select
			[button setBackgroundColor:[UIColor redColor]];
			[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		} else {
			// Deselect
			[button setBackgroundColor:[UIColor whiteColor]];
			[button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
		}
	}
}

- (void)buttonTouched:(id)sender {
	// identify button, then deal with it
	int index = [bsButtons indexOfObjectIdenticalTo:sender];
	[self setSelectedButtonAtIndex:index];
	[[self delegate] buildingMapSelectedIndexOfBuilding:index];
}

@end
