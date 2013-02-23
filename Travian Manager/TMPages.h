// This code is distributed under the terms and conditions of the MIT license.

/* * Copyright (C) 2011 - 2013 Matej Kramny <matejkramny@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial
 * portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
 * OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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
	TPNotification = 1 << 12, // Scheduled maintanance. Click dorf.php?ok ok to continue.
	TPLogin = 1 << 13, // Login page
	TPMaintanance = 1 << 14, // Server is being maintained
	TPStatistics = 1 << 15, // Statistics page
	TPAuction = 1 << 16, // Auctions,
	TPBuildList = 1 << 17, // Page features list of buildings being built
	TPNotFound = 1 << 18, // Page unknown
	
	// Masks
	TPMaskUnparseable = TPNotFound | TPLogin | TPMaintanance, // Pages that do not contain relevant information to the account
	//TPMaskBasicVillageList = ~(TPMaskUnparseable), // Pages that it does not have basicVillageList then inverted bits
	//TPMaskFullVillageList = TPProfile, // Pages with full village list (with population)
	TPMaskConstructionsList = TPResources | TPVillage // Pages that have list of buildings being constructed
} TravianPages;

// e.g. 0 = 'gid0' <- building identifier
typedef enum {
	TBList = 0, // No building, just a list of buildings that can be built
	TBWoodCutter = 1, // Woodcutter
	TBClayPit = 2, // Clay Pit
	TBIronMine = 3, // Iron Mine
	TBWheatField = 4, // Wheat Field
	TBSawMill = 5, // Saw Mill
	TBBrickWorks = 6, // Brick Works
	TBIronFoundry = 7, // Iron Foundry
	TBFlourMill = 8, // Flour Mill
	TBBakery = 9, // Bakery
	TBWarehouse = 10, // Warehouse
	TBGranary = 11, // Granary
	
	TBForge = 13, // Forge
	TBTournamentSquare = 14, // Tournament Square
	TBMainBuilding = 15, // Main Building
	TBRallyPoint = 16, // Rally Point
	
	TBEmbassy = 18, // Embassy
	TBBarracks = 19, // Barracks
	TBStable = 20, // Stable
	TBWorkshop = 21, // Siege Workshop
	TBAcademy = 22, // Academy
	TBCranny = 23, // Cranny
	TBCityHall = 24, // City Hall
	TBResidence = 25, // Residence
	TBPalace = 26, // Palace
	TBTreasureChamber = 27, // Treasure Chamber
	TBTradeOffice = 28, // Trading office
	TBGreatBarracks = 29, // Great Barracks
	TBGreatStable = 30, // Great Stable
	TBCityWall = 31, // City Wall - Roman
	TBEarthWall = 32, // Earth wall - Teuton
	TBPalisade = 33, // Palisade - Gaul
	TBStonemason = 34, // Stonemason
	TBBrewery = 35, // Brewery
	TBTrapper = 36, // Trapper - Gaul
	TBHeroMansion = 37, // Hero's mansion
	TBGreatWarehouse = 38, // Great Warehouse
	TBGreatGranary = 39, // Great Granary
	TBWonderOfTheWorld = 40, // The Wonder of the World
	
	TBNotFound = -1, /// Building not found
	TBNotKnown = -2, /// Uknown
} TravianBuildings;

#endif
