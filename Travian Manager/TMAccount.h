/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "TravianPageParsingProtocol.h"

typedef enum {
	ALoggedIn =  1 << 0,
	ALoggingIn = 1 << 1,
	ACannotLogIn = 1 << 2,
	ANotLoggedIn = 1 << 3,
	ARefreshing = 1 << 4,
	ARefreshed = 1 << 5,
	AConnectionFailed = 1 << 6
} AccountStatus;

typedef enum {
	ARAccount = 1 << 0,
	ARVillage = 1 << 1,
	ARVillages = 1 << 2,
	ARReports = 1 << 3,
	ARMessagesInbox = 1 << 4,
	ARMessagesOutbox = 1 << 5,
	ARHero = 1 << 6,
	ARAdventures = 1 << 7
} AReloadMap;

@class TMHero;
@class TMVillage;
//@class Profile;
@class TMSettings;

@interface TMAccount : NSObject <NSCoding, TMPageParsingProtocol, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) TMSettings *settings;

@property (nonatomic, strong) NSString *name; // User's account name
@property (nonatomic, strong) NSString *username; // Login - username
@property (nonatomic, strong) NSString *password; // Login - password
@property (nonatomic, strong) NSString *world; // Login - world (e.g. 'ts7')
@property (nonatomic, strong) NSString *server; // Login - server (e.g. 'co.uk')
@property (nonatomic, strong) NSString *baseURL; // e.g. http://world.travian.co.uk

@property (nonatomic, weak) TMVillage *village; // Village being viewed (viewed by viewcontrollers)
@property (nonatomic, strong) NSArray *villages; // List of villages
@property (nonatomic, strong) NSArray *reports; // Reports
@property (nonatomic, strong) NSArray *messages; // Messages
@property (nonatomic, strong) NSArray *contacts; // Contact list
@property (nonatomic, strong) TMHero *hero; // Hero

@property (assign) AccountStatus status; // Tells other objects the status of this account
@property (assign) bool notificationPending; // There is a notification. Notify user to either skipNotification or view it in safari.
@property (nonatomic, strong) NSString *progressIndicator; // Label on HUD

@property (assign) long last_updated; // UNIX timestamp tells when last refreshed..

@property (nonatomic, strong) NSArray *cookies; // cookies store. Preserved in the storage to avoid logging in multiple times.

- (void)activateAccount;
- (void)activateAccountWithPassword:(NSString *)passwd;
- (void)refreshAccountWithMap:(AReloadMap)map;
- (void)deactivateAccount;

- (void)skipNotification;
- (bool)isComplete; // returns true if all required fields aren't empty

- (NSURL *)urlForString:(NSString *)append;
- (NSURL *)urlForArguments:(NSString *)append, ...;

@end

@interface TMAccount (URLParts)

+ (NSString *)profilePage;
+ (NSString *)heroInventory;
+ (NSString *)heroAdventure;
+ (NSString *)reports;
+ (NSString *)messages;
+ (NSString *)resources;
+ (NSString *)village;
+ (NSString *)farmList;

@end
