//
//  BuildingAction.h
//  Travian Manager
//
//  Created by Matej Kramny on 22/08/2012.
//
//

#import <Foundation/Foundation.h>

@class Resources;
@class HTMLNode;

@interface BuildingAction : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) Resources *resources;
@property (nonatomic, strong) NSString *url;

- (id)initWithResearchDiv:(HTMLNode *)research;
- (void)research;

@end
