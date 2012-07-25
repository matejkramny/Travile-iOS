//
//  Account.h
//  Travian Manager
//
//  Created by Matej Kramny on 11/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TravianPageParsingProtocol.h"

typedef enum {
	ALoggedIn =  1 << 0,
	ALoggingIn = 1 << 1,
	ACannotLogIn = 1 << 2,
	ANotLoggedIn = 1 << 3
} AccountStatus;

@class Hero;
//@class Profile;

@interface Account : NSObject <NSCoding, TravianPageParsingProtocol, NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
	NSURLConnection *loginConnection; // Login connection
	NSMutableData *loginData; // Login data
	NSURLConnection *reportsConnection;
	NSMutableData *reportsData;
}

@property (nonatomic, strong) NSString *name; // User's account name
@property (nonatomic, strong) NSString *username; // Login - username
@property (nonatomic, strong) NSString *password; // Login - password
@property (nonatomic, strong) NSString *world; // Login - world (e.g. 'ts7')
@property (nonatomic, strong) NSString *server; // Login - server (e.g. 'co.uk')

@property (nonatomic, strong) NSArray *villages; // List of villages
@property (nonatomic, strong) NSArray *reports; // Reports
@property (nonatomic, strong) NSArray *messages; // Messages
@property (nonatomic, strong) NSArray *contacts; // Contact list
//@property (nonatomic, strong) Profile *profile;
@property (nonatomic, strong) Hero *hero; // Hero

@property (assign) AccountStatus status; // Tells other objects the status of this account
@property (assign) bool notificationPending; // There is a notification. Notify user to either skipNotification or view it in safari.
//@property (assign) bool hasFinishedLoading; // When NO, HUD should be up stating the account is loading..
@property (nonatomic, strong) NSString *progressIndicator; // Label on HUD

- (void)activateAccount;
- (void)activateAccountWithPassword:(NSString *)passwd;
- (void)refreshAccount;
- (void)deactivateAccount;

- (void)skipNotification;
- (bool)isComplete; // returns true if all required fields aren't empty

@end
