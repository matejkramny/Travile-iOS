//
//  Barracks.h
//  Travian Manager
//
//  Created by Matej Kramny on 26/08/2012.
//
//

#import "NonGenericBuilding.h"

@interface Barracks : NonGenericBuilding

@property (nonatomic, strong) NSArray *troops;
@property (nonatomic, strong) NSDictionary *researching;

- (bool)train;

@end
