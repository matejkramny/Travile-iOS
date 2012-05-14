//
//  TravianPages.h
//  Travian Manager
//
//  Created by Matej Kramny on 13/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Travian_Manager_TravianPages_h
#define Travian_Manager_TravianPages_h

// Uses 'TP' as prefix to any TravianPage

typedef enum {
	TPResources = 1 << 0, // Resources overview
	TPResourceField = 1 << 1, // Resource Building view
	TPVillage = 1 << 2, // Village overview
	TPBuilding = 1 << 3, // Building view
	TPHero = 1 << 4, // Hero view
	TPAdventures = 1 << 5, // List of adventures
	TPProfile = 1 << 6, // Profile view
	TPMap = 1 << 7, // Map view
	TPReports = 1 << 8, // List of reports
	TPReport = 1 << 9, // Report view
	TPMessages = 1 << 10, // List of messages
	TPMessage = 1 << 11, // Message view
	TPNotification = 1 << 12, // Scheduled maintanance. Click ok to continue.
	TPLogin = 1 << 13, // Login page
	TPMaintanance = 1 << 14, // Server is being maintained
	TPStatistics = 1 << 15, // Statistics page
	TPAuction = 1 << 16, // Auctions,
	TPBuildList = 1 << 17, // Page features list of buildings being built
	TPNotFound = -1, // Page unknown
	
	// Masks
	TPMaskUnparseable = TPNotFound | TPLogin | TPMaintanance | TPNotification, // Pages that do not contain relevant information to the account
	TPMaskBasicVillageList = ~(TPMaskUnparseable), // Pages that it does not have basicVillageList then inverted bits
	TPMaskFullVillageList = TPProfile, // Pages with full village list (with population)
	TPMaskConstructionsList = TPResources | TPVillage // Pages that have list of buildings being constructed
} TravianPages;

#endif
