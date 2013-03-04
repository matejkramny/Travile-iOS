//
//  TTStorage.m
//  Travian Manager
//
//  Created by Matej Kramny on 04/03/2013.
//
//

#import "TTStorage.h"
#import "TMStorage.h"

@interface TTStorage () {
	TMStorage *storage;
}

@end

@implementation TTStorage

- (void)setUpClass {
	storage = [TMStorage sharedStorage];
}

- (void)tearDownClass {
	storage = nil;
}

- (void)testLoading {
	bool loaded = [storage loadData];
	GHAssertTrue(loaded, @"Failed to load data");
}

- (void)testSaving {
	bool saved = [storage saveData];
	GHAssertTrue(saved, @"Failed to save data");
}

@end
