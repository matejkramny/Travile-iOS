/* Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 * All rights reserved.
 */

#import "TMAccount.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "TPIdentifier.h"
#import "TMVillage.h"
#import "TMHero.h"
#import "TMMessage.h"
#import "TMReport.h"
#import "TMSettings.h"

@interface TMAccount () {
	AReloadMap reloadMap;

	NSURLConnection *loginConnection; // Login connection
	NSMutableData *loginData; // Login data
	NSURLConnection *reportsConnection;
	NSMutableData *reportsData; // TODO merge reports with reload
	NSURLConnection *reloadConnection; // Connection used for reloading parts of Account
	NSMutableData *reloadData;
}

@end

@interface TMAccount (Parsing)

- (void)parseVillages:(HTMLNode *)node;
- (void)parseReports:(HTMLNode *)node;
- (void)parseMessages:(HTMLNode *)node;

@end

@implementation TMAccount (URLParts)

// Static strings for various Travian url locations
static NSString *profilePage = @"spieler.php";
static NSString *heroInventory = @"hero_inventory.php";
static NSString *heroAdventure = @"hero_adventure.php";
static NSString *reports = @"berichte.php";
static NSString *messages = @"nachrichten.php";
static NSString *resources = @"dorf1.php";
static NSString *village = @"dorf2.php";
static NSString *farmList = @"build.php?tt=99&id=39";
// Getters
+ (NSString *)profilePage { return profilePage; }
+ (NSString *)heroInventory { return heroInventory; }
+ (NSString *)heroAdventure { return heroAdventure; }
+ (NSString *)reports { return reports; }
+ (NSString *)messages { return messages; }
+ (NSString *)resources { return resources; }
+ (NSString *)village { return village; }
+ (NSString *)farmList { return farmList; }

@end

@implementation TMAccount

@synthesize name, username, password, world, server, baseURL, villages, reports, messages, contacts, hero, status, notificationPending, progressIndicator, village, last_updated, settings, cookies;

- (bool)isComplete {
	if ([name length] < 2 || username.length < 2 || world.length < 2 || server.length < 1)
		return NO;
	
	return YES;
}

- (void)skipNotification {
	NSURL *url = [self urlForString:@"dorf1.php?ok"];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	[request setHTTPShouldHandleCookies:YES];
	
	loginConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

#pragma mark - Coders

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	
	settings = [coder decodeObjectForKey:@"settings"];
	name = [coder decodeObjectForKey:@"name"];
	username = [coder decodeObjectForKey:@"username"];
	password = [coder decodeObjectForKey:@"password"];
	world = [coder decodeObjectForKey:@"world"];
	server = [coder decodeObjectForKey:@"server"];
	cookies = [coder decodeObjectForKey:@"cookies"];
	
	if (settings == nil)
		settings = [[TMSettings alloc] init];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:settings forKey:@"settings"];
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:username forKey:@"username"];
	[coder encodeObject:password forKey:@"password"];
	[coder encodeObject:world forKey:@"world"];
	[coder encodeObject:server forKey:@"server"];
	[coder encodeObject:cookies forKey:@"cookies"];
}

- (id)init {
	self = [super init];
	
	if (self) {
		settings = [[TMSettings alloc] init];
	}
	
	return self;
}

#pragma mark -

- (void)activateAccount {
	[self activateAccountWithPassword:password];
}

- (NSURL *)urlForString:(NSString *)append {
	return [self urlForArguments:append, nil];
}

- (NSURL *)urlForArguments:(NSString *)append, ... {
	NSString *builtString = [baseURL stringByAppendingString:append];
	
	NSString *eachObject;
	
	// va_list puts the arguments from elipsis into argList
	va_list argList;
	va_start(argList, append);
	while ((eachObject = va_arg(argList, NSString *)))
		builtString = [builtString stringByAppendingString:eachObject];
	va_end(argList);
	
	return [NSURL URLWithString:builtString];
}

- (void)activateAccountWithPassword:(NSString *)passwd {
	baseURL = [NSString stringWithFormat:@"http://%@.travian.%@/", world, server]; // Set up shared base URL
	// Check if our cookie jar is empty.. If it is, we haven't logged in for a long time.
	if (cookies == nil || cookies.count == 0) {
		[self performLoginWithPassword:passwd];
	} else {
		// Probably valid cookies?
		[self refreshAccountWithMap:ARAccount];
	}
}

- (void)performLoginWithPassword:(NSString *)passwd {
	// Start connection
	NSString *postData = [[NSString alloc] initWithFormat:@"name=%@&password=%@&s1=Login&w=%@&login=%f", username, passwd, @"640:960", [[NSDate date] timeIntervalSince1970]];
	NSData *myRequestData = [NSData dataWithBytes: [postData UTF8String] length: [postData length]];
	NSURL *url = [self urlForString:@"dorf1.php"];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	// Set POST HTTP Headers if necessary
	[request setHTTPMethod: @"POST"];
	[request setHTTPBody: myRequestData];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	
	// Preserve any cookies received
	[request setHTTPShouldHandleCookies:YES];
	
	status = ANotLoggedIn | ALoggingIn;
	
	loginConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)refreshAccountWithMap:(AReloadMap)map {
	NSString *mapUrl;
	reloadMap = map;
	
	if ((map & ARVillage) != 0)
		mapUrl = [[TMAccount resources] stringByAppendingFormat:@"?%@", village.urlPart];
	else if ((map & ARVillages) != 0)
		mapUrl = [TMAccount profilePage];
	else if ((map & ARReports) != 0)
		mapUrl = [TMAccount reports];
	else if ((map & ARMessagesInbox) != 0)
		mapUrl = [TMAccount messages];
	else if ((map & ARHero) != 0)
		mapUrl = [TMAccount heroInventory];
	else if ((map & ARAdventures) != 0)
		mapUrl = [TMAccount heroAdventure];
	else {
		mapUrl = [TMAccount profilePage];
		reloadMap = ARAccount;
	}
	
	NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[self urlForString:mapUrl] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60.0];
	
	[req setHTTPShouldHandleCookies:YES];
	
	[self setStatus:ARefreshing];
	
	reloadConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
}

- (void)deactivateAccount {
	// A logout effectively..
	if ((status & ANotLoggedIn) != 0) { // Already logged out?
		[self setStatus:ANotLoggedIn];
		return;
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self urlForString:@"logout.php"] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
	
	[request setHTTPShouldHandleCookies:YES];
	
	[self setStatus:ANotLoggedIn];
	
	last_updated = [[NSDate date] timeIntervalSince1970];
	
	NSURLConnection *conn __unused = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
	// Allow ARC to deallocate these.
	village = nil;
	villages = nil;
	messages = nil;
	hero = nil;
	reports = nil;
	contacts = nil;
}

#pragma mark - TravianPageParsingProtocol

- (void)parsePage:(TravianPages)page fromHTMLNode:(HTMLNode *)node
{
	// Parses the HTML Body of the Page, and adds data to villages, messages etc
	if ((page & TPNotification) != 0) {
		// Notification pending view
		[self setProgressIndicator:NSLocalizedString(@"Found notification", @"Shown when loading account")];
		//[self setHasFinishedLoading:YES];
		
		[self setNotificationPending:YES];
		
		return;
	}
	
	if ((page & TPMaskUnparseable) != 0 || ![[node tagName] isEqualToString:@"body"]) {
		[self setProgressIndicator:NSLocalizedString(@"Cannot load", @"Shown when loading account - canot load")];
		
		[self setStatus:ACannotLogIn | ARefreshed];
		
		return; // Can't do anything with unparseable pages or non-body nodes
	}
	
	// Villages
	if ((page & TPProfile) != 0) {
		
		[self setProgressIndicator:NSLocalizedString(@"Loading villages", @"Shown when loading account - villages")];
		[self parseVillages:node];
		
	} else if ((page & (TPHero | TPAdventures | TPAuction)) != 0) {
		if (!hero)
			hero = [[TMHero alloc] init];
		
		[self setProgressIndicator:NSLocalizedString(@"Loading hero", @"Shown when loading account - hero")];
		[hero parsePage:page fromHTMLNode:node];
		
	} else if ((page & TPReports) != 0) {
		
		[self setProgressIndicator:NSLocalizedString(@"Loading reports", @"Shown when loading account - reports")];
		[self parseReports:node];
		
	} else if ((page & TPMessages) != 0) {
		
		[self setProgressIndicator:NSLocalizedString(@"Loading messages", @"Shown when loading account - messages")];
		[self parseMessages:node];
		
		// Finished
		[self setStatus:ALoggedIn | ARefreshed];
	}
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {  }
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection	{	return NO;	}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self setStatus:(AConnectionFailed | ANotLoggedIn | ACannotLogIn)];
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (connection == loginConnection)
		[loginData appendData:data];
	else if (connection == reportsConnection)
		[reportsData appendData:data];
	else if (connection == reloadConnection)
		[reloadData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
	if (connection == loginConnection)
		loginData = [[NSMutableData alloc] initWithLength:0];
	else if (connection == reportsConnection)
		reportsData = [[NSMutableData alloc] initWithLength:0];
	else if (connection == reloadConnection)
		reloadData = [[NSMutableData alloc] initWithLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// Parse data
	NSURLConnection *(^urlConnectionForURL)(NSString *) = ^(NSString *part) {
		NSURL *url = [self urlForString:part];
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
		
		// Preserve any cookies received
		[request setHTTPShouldHandleCookies:YES];
		
		return [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	};
	
	cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[self urlForString:@""]];
	
	if (connection == loginConnection || (connection == reloadConnection && ((reloadMap & ARAccount) != 0 || (reloadMap & ARVillages) != 0)))
	{
		NSError *error;
		HTMLParser *parser = [[HTMLParser alloc] initWithData:connection == loginConnection ? loginData : reloadData error:&error];
		
		if (error) {
			return;
		}
		
		TravianPages page = [TPIdentifier identifyPage:[parser body]];
		
		if ((page & (TPLogin | TPNotFound)) != 0) {
			// Still at login page.
			if (connection == reloadConnection) {
				// Login
				reloadMap = 0;
				cookies = nil;
				[self activateAccount];
			} else {
				[self setStatus:(ANotLoggedIn | ACannotLogIn)];
			}
			
			return;
		}
		
		[self setStatus:(ALoggedIn | ARefreshing)];
		
		// Parse the page
		[self parsePage:page fromHTMLNode:[parser body]];
		
		// Login Connections chain
		
		if ((page & TPResources) != 0) {
			// load profile
			loginConnection = urlConnectionForURL([TMAccount profilePage]);
			
		} else if ((page & TPProfile) != 0) {
			// If loadAllAtOnce is off stop here. Rest will be downloaded later.
			if (connection == loginConnection && settings.fastLogin) {
				[self setStatus:ALoggedIn | ARefreshed];
				return;
			}
			
			// load hero
			// Make another request for hero
			
			loginConnection = urlConnectionForURL([TMAccount heroInventory]);
		} else if ((page & TPHero) != 0) {
			// Next download adventures
			
			loginConnection = urlConnectionForURL([TMAccount heroAdventure]);
		} else if ((page & TPAdventures) != 0) {
			// Load Reports
			
			loginConnection = urlConnectionForURL([TMAccount reports]);
		} else if ((page & TPReports) != 0) {
			// Load Messages
			
			loginConnection = urlConnectionForURL([TMAccount messages]);
		} else if ((page & TPMessages) != 0) {
			// Tell other objects that loading is finished.
			[self setStatus:ALoggedIn | ARefreshed];
			
			last_updated = [[NSDate date] timeIntervalSince1970];
		}
		
	} else if (connection == reportsConnection) {
		NSError *error;
		HTMLParser *parser = [[HTMLParser alloc] initWithData:reportsData error:&error];
		if (error) {
			return;
		}
		HTMLNode *body = [parser body];
		
		TravianPages page = [TPIdentifier identifyPage:body];
		
		[self parsePage:page fromHTMLNode:body];
	} else if (connection == reloadConnection) {
		NSError *error;
		HTMLParser *parser = [[HTMLParser alloc] initWithData:reloadData error:&error];
		if (error) {
			return;
		}
		HTMLNode *body = [parser body];
		
		TravianPages page = [TPIdentifier identifyPage:body];
		
		if ((page & (TPLogin | TPNotFound)) != 0) {
			// Still at login page.
			
			// Login
			reloadMap = 0;
			cookies = nil;
			[self activateAccount];
			
			return;
		}
		
		if ((reloadMap & ARVillage) != 0) {
			[[self village] parsePage:page fromHTMLNode:body];
			
			if ((page & TPResources) != 0)
				reloadConnection = urlConnectionForURL([NSString stringWithFormat:@"%@?%@", [TMAccount village], [village urlPart]]); // Loaded resources, now load village
			else {
				[self setStatus:ARefreshed];
				
				last_updated = [[NSDate date] timeIntervalSince1970];
			}
		} else {
			[self parsePage:page fromHTMLNode:body];
			[self setStatus:ARefreshed];
			
			last_updated = [[NSDate date] timeIntervalSince1970];
		}
	}
}

@end

@implementation TMAccount (Parsing)

- (void)parseVillages:(HTMLNode *)node {
	
	// Find each village's population & x, y coordinates
	HTMLNode *idVillages = [node findChildWithAttribute:@"id" matchingName:@"villages" allowPartial:NO];
	if (!idVillages) {
		return;
	}
	// Table > tr (village)
	NSArray *villageList = [[idVillages findChildTag:@"tbody"] findChildTags:@"tr"];
	NSMutableArray *tempVillages = [[NSMutableArray alloc] initWithCapacity:[villageList count]];
	
	for (HTMLNode *villageNode in villageList) {
		TMVillage *tempVillage = [[TMVillage alloc] init];
		
		tempVillage.name = [[[villageNode findChildWithAttribute:@"class" matchingName:@"name" allowPartial:NO] findChildTag:@"a"] contents];
		NSString *inhabitants = [[[villageNode findChildWithAttribute:@"class" matchingName:@"inhabitants" allowPartial:NO] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		tempVillage.population = [inhabitants intValue];
		// x & y
		
		[tempVillages addObject:tempVillage];
	}
	
	// Now find their urlPart
	// Get div with ID 'villageList'
	HTMLNode *villagesList = [node findChildWithAttribute:@"id" matchingName:@"villageList" allowPartial:NO];
	if (!villagesList) {
		villagesList = [node findChildWithAttribute:@"id" matchingName:@"sidebarBoxVillagelist" allowPartial:NO]; // T4.2
		
		if (!villagesList)
			return;
	}
	// Get div#villageList div.list
	HTMLNode *villageList_div_List = [villagesList findChildWithAttribute:@"class" matchingName:@"list" allowPartial:NO];
	if (!villageList_div_List) {
		villageList_div_List = [villagesList findChildWithAttribute:@"class" matchingName:@"innerBox content" allowPartial:NO]; // T4.2
		
		if (!villageList_div_List)
			return;
	}
	
	// List of villages in <li> tags
	NSArray *divList_li = [villageList_div_List findChildTags:@"li"];
	
	for (int i = 0; i < [divList_li count]; i++) {
		HTMLNode *li = [divList_li objectAtIndex:i];
		TMVillage *tempVillage = [[TMVillage alloc] init];

		HTMLNode *aTag = [li findChildTag:@"a"];
		NSString *villageName = [aTag contents];
		HTMLNode *v4_2 = [aTag findChildWithAttribute:@"class" matchingName:@"name" allowPartial:NO];
		if (v4_2 != nil) {
			// Try 4.2 version
			villageName = [v4_2 contents];
		}
		tempVillage.name = villageName;
		
		int index = -1;
		for (int ii = 0; ii < [tempVillages count]; ii++) {
			if ([[(TMVillage *)[tempVillages objectAtIndex:ii] name] isEqualToString:tempVillage.name]) {
				index = ii;
				break;
			}
		}
		
		if (index == -1) continue;
		
		tempVillage = [tempVillages objectAtIndex:index];
		
		// Removes junk after & in the url
		NSString *identifier = [[li findChildTag:@"a"] getAttributeNamed:@"href"];
		NSRange location = [identifier rangeOfString:@"&"];
		if (location.location != NSNotFound)
			identifier = [identifier substringToIndex:location.location];
		
		// Remove ? from url
		identifier = [identifier substringFromIndex:1];
		
		tempVillage.urlPart = identifier;
		
		[tempVillage setAccountParent:self];
	}
	
	// Empty local villages and replace them with tempVillages
	villages = tempVillages;
	
	if (!settings.fastLogin) {
		for (TMVillage *vil in villages) {
			[vil downloadAndParse]; // Tell each village to download its data
		}
	}
}

- (void)parseReports:(HTMLNode *)node {
	
	HTMLNode *table = [node findChildWithAttribute:@"id" matchingName:@"overview" allowPartial:NO];
	if (!table) {
		return;
	}
	
	HTMLNode *tbody = [table findChildTag:@"tbody"];
	NSArray *trs = [tbody findChildTags:@"tr"];
	NSMutableArray *tempReports = [[NSMutableArray alloc] initWithCapacity:[trs count]];
	
    // Table with list of reports
	for (HTMLNode *tr in trs) {
		// Check if tr contains td.noData
		if ([[[tr findChildTag:@"td"] getAttributeNamed:@"class"] isEqualToString:@"noData"])
		{
			reports = [[NSArray alloc] init];
			return;
		}
		
		TMReport *report = [[TMReport alloc] init];
		
		HTMLNode *aTag = [tr findChildWithAttribute:@"href" matchingName:@"berichte.php?id=" allowPartial:YES];
		
		if ([[aTag getAttributeNamed:@"class"] isEqualToString:@"adventure"]) {
			NSString *coordText = [[aTag findChildWithAttribute:@"class" matchingName:@"coordText" allowPartial:NO] contents];
			NSString *coordinates = [[NSString alloc] initWithFormat:@"%@|%@",
									 [[aTag findChildWithAttribute:@"class" matchingName:@"coordinateX" allowPartial:NO] contents],
									 [[aTag findChildWithAttribute:@"class" matchingName:@"coordinateY" allowPartial:NO] contents]];
			report.name = [NSString stringWithFormat:@"%@ %@", coordText, coordinates];
		}
		else {
			report.name = [aTag contents];
		}
		
		report.accessID = [[[aTag getAttributeNamed:@"href"] stringByReplacingOccurrencesOfString:@"berichte.php?id=" withString:@""] stringByReplacingOccurrencesOfString:@"&t=" withString:@""];
		report.deleteID = [[tr findChildTag:@"input"] getAttributeNamed:@"value"];
		
		// Parse the date - remove \t and \n from string
		report.when = [[[[tr findChildWithAttribute:@"class" matchingName:@"dat" allowPartial:NO] contents] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		
		[tempReports addObject:report];
	}
	
    HTMLNode *paginator = [[table parent] findChildWithAttribute:@"class" matchingName:@"paginator" allowPartial:NO];
    
	// Check if on 1st page. If on first page, erase previous reports to avoid duplicity.
	if (!reports || [paginator findChildWithAttribute:@"class" matchingName:@"previous disabled" allowPartial:NO] != NULL) {
		reports = [[NSArray alloc] init];
	}
	
	// 'Merge' the arrays
	reports = [reports arrayByAddingObjectsFromArray:tempReports];
	
	/*
	HTMLNode *nextPage = [paginator findChildWithAttribute:@"class" matchingName:@"next" allowPartial:NO];
	if (nextPage && ![paginator findChildWithAttribute:@"class" matchingName:@"next disabled" allowPartial:NO]) {
		// There is another page
		
		NSString *nextPageHref = [nextPage getAttributeNamed:@"href"];
		
		// Load next page
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self urlForString:nextPageHref] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
		[request setHTTPShouldHandleCookies:YES];
		
		reportsConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	}*/
}

- (void)parseMessages:(HTMLNode *)node {
	
	HTMLNode *table = [node findChildWithAttribute:@"id" matchingName:@"overview" allowPartial:NO];
	if (!table) {
		return;
	}
	
	HTMLNode *tbody = [table findChildTag:@"tbody"];
	NSArray *trs = [tbody findChildTags:@"tr"];
	NSMutableArray *tempMessages = [[NSMutableArray alloc] initWithCapacity:[trs count]];
	
	// Table with list of messages
	for (HTMLNode *tr in trs) {
		// Check if tr contains td.noData
		if ([[[tr findChildTag:@"td"] getAttributeNamed:@"class"] isEqualToString:@"noData"])
		{
			messages = [[NSArray alloc] init];
			return;
		}
		
		// Allocate new message object
		TMMessage *message = [[TMMessage alloc] init];
		
		// Parse available data into message
		HTMLNode *subjectWrapper = [tr findChildWithAttribute:@"class" matchingName:@"subjectWrapper" allowPartial:NO];
		
		// Check if message has been read
		message.read = false;
		if ([subjectWrapper findChildWithAttribute:@"class" matchingName:@"messageStatusRead" allowPartial:YES] != NULL) {
			message.read = true;
		}
		
		// Retrieve message Title
		HTMLNode *link = [subjectWrapper findChildTag:@"a"];
		message.title = [[[link contents] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		// Href - nachrichten.php?id=accessID
		message.href = [link getAttributeNamed:@"href"];
		
		message.accessID = [message.href stringByReplacingOccurrencesOfString:@"nachrichten.php?id=" withString:@""];
		
		// Retrieve date - remove tabs and newlines
		message.when = [[[[tr findChildWithAttribute:@"class" matchingName:@"dat" allowPartial:NO] contents] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		// message.accessID = message.href without nachrichten.php?id=
		
		// Sender name
		HTMLNode *senderHyperlink = [[tr findChildWithAttribute:@"class" matchingName:@"send" allowPartial:NO] findChildTag:@"a"];
		if ([senderHyperlink findChildTag:@"u"])
			senderHyperlink = [senderHyperlink findChildTag:@"u"];
		message.sender = [senderHyperlink contents];
		if ([message.sender length] == 0) {
			// Blank message sender
			message.sender = @"Uknown sender?";
		}
		
		[tempMessages addObject:message];
	}
	
    HTMLNode *paginator = [[table parent] findChildWithAttribute:@"class" matchingName:@"paginator" allowPartial:NO];
    
	// Check if on 1st page. If on first page, erase previous reports to avoid duplicity.
	if (!messages || [paginator findChildWithAttribute:@"class" matchingName:@"previous disabled" allowPartial:NO] != NULL) {
		messages = [[NSArray alloc] init];
	}
	
	// 'Merge' the arrays
	messages = [messages arrayByAddingObjectsFromArray:tempMessages];
	
	/*
	HTMLNode *nextPage = [paginator findChildWithAttribute:@"class" matchingName:@"next" allowPartial:NO];
	if (nextPage && ![paginator findChildWithAttribute:@"class" matchingName:@"next disabled" allowPartial:NO]) {
		// There is another page
		
		NSString *nextPageHref = [nextPage getAttributeNamed:@"href"];
		
		// Load next page
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self urlForString:nextPageHref] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60];
		[request setHTTPShouldHandleCookies:YES];
		
		reportsConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	}*/
}

@end
