//
//  BuildingMap.h
//  Travian Manager
//
//  Created by Matej Kramny on 14/08/2012.
//
//

#import <UIKit/UIKit.h>

@class Building;

@protocol BuildingMapProtocol <NSObject>

- (void)buildingMapSelectedIndexOfBuilding:(NSInteger)index;

@end

@interface BuildingMap : UIView

- (id)initWithBuildings:(NSArray *)buildings hideBuildings:(NSArray *)hideBuildings;

@property (weak, nonatomic) id <BuildingMapProtocol>delegate;

@end
