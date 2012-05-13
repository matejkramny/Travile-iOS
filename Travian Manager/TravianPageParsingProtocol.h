//
//  TravianPageParsingProtocol.h
//  Travian Manager
//
//  Created by Matej Kramny on 13/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Travian_Manager_TravianPageParsingProtocol_h
#define Travian_Manager_TravianPageParsingProtocol_h

#import "TravianPages.h"
@class HTMLNode;

@protocol TravianPageParsingProtocol <NSObject>

- (void)parsePage:(TravianPages)page fromHTML:(NSString *)html;
- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node;

@end

#endif
