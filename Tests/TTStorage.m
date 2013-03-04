//
//  TTStorage.m
//  Travian Manager
//
//  Created by Matej Kramny on 04/03/2013.
//
//

#import "TTStorage.h"
#import "TMStorage.h"
#import "TMSettings.h"

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
	// Test if loads data from file
	bool loaded = [storage loadData];
	GHAssertTrue(loaded, @"Failed to load data");
}

- (void)testData {
	// Test settings - should be auto-generated if not present
	GHAssertNotNil(storage.settings, @"Settings is NULL");
	GHTestLog([storage.settings description]);
}

- (void)testSaving {
	bool saved = [storage saveData];
	GHAssertTrue(saved, @"Failed to save data");
}

@end
