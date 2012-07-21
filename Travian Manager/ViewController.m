//
//  ViewController.m
//  Travian Manager
//
//  Created by Matej Kramny on 10/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Storage.h"
#import "Account.h"
#import "Village.h"
#import "Resources.h"
#import "ResourcesProduction.h"
#import "Troop.h"
#import "Construction.h"
#import "Hero.h"
#import "HeroQuest.h"
#import "Building.h"
#import "Movement.h"
#import "Message.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
	[self reloadData:self];
	
    [super viewDidLoad];
}

- (void)viewDidUnload
{
	wood = clay = iron = wheat = granary = warehouse = vilName = vilLoyalty = vilPopulation = troopsHero = consName = consLevel = consFinish = heroStrength = heroOff = heroDef = heroExp = heroHealth = heroisHiding = heroisAlive = heroWood = heroClay = heroIron = heroWheat = heroAdventures = nil;
	
	BuildingsTable = nil;
	mov1Name = nil;
	mov1Time = nil;
	mov2Name = nil;
	mov2Time = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

- (IBAction)updateView:(id)sender {
	NSLog(@"Update view");
	
	Account *a = [[(AppDelegate *)[UIApplication sharedApplication].delegate storage] account];
	Village *v = [[a villages] objectAtIndex:0];
	
	[warehouse setText:[NSString stringWithFormat:@"%d", v.warehouse]];
	[granary setText:[NSString stringWithFormat:@"%d", v.granary]];
	
	Resources *r = [v resources];
	ResourcesProduction *rp = [v resourceProduction];
	[wood setText:[NSString stringWithFormat:@"%d (%d)", r.wood, rp.wood]];
	[clay setText:[NSString stringWithFormat:@"%d (%d)", r.clay, rp.clay]];
	[iron setText:[NSString stringWithFormat:@"%d (%d)", r.iron, rp.iron]];
	[wheat setText:[NSString stringWithFormat:@"%d (%d)", r.wheat, rp.wheat]];
	
	[vilName setText:v.name];
	[vilLoyalty setText:[NSString stringWithFormat:@"%d", v.loyalty]];
	[vilPopulation setText:[NSString stringWithFormat:@"%d", v.population]];
	
	if (v.troops && [v.troops count] > 0)
		[troopsHero setText:[NSString stringWithFormat:@"%d", [[v.troops objectAtIndex:0] count]]];
	
	if (v.constructions && [v.constructions count] > 0) {
		Construction *c = [v.constructions objectAtIndex:0];
		
		[consName setText:[c name]];
		[consLevel setText:[NSString stringWithFormat:@"%d", [c level]]];
		[consFinish setText:[c finishTime]];
	}
	
	// Hero
	Hero *h = a.hero;
	
	[heroStrength setText:[NSString stringWithFormat:@"%d", h.strengthPoints]];
	[heroOff setText:[NSString stringWithFormat:@"%d%%", h.offBonusPercentage]];
	[heroDef setText:[NSString stringWithFormat:@"%d%%", h.defBonusPercentage]];
	[heroExp setText:[NSString stringWithFormat:@"%d", h.experience]];
	[heroHealth setText:[NSString stringWithFormat:@"%d%%", h.health]];
	[heroisHiding setText:h.isHidden ? @"YES" : @"NO"];
	[heroisAlive setText:h.isAlive ? @"YES" : @"NO"];
	[heroWood setText:[NSString stringWithFormat:@"%d", h.resourceProductionBoost.wood]];
	[heroClay setText:[NSString stringWithFormat:@"%d", h.resourceProductionBoost.clay]];
	[heroIron setText:[NSString stringWithFormat:@"%d", h.resourceProductionBoost.iron]];
	[heroWheat setText:[NSString stringWithFormat:@"%d", h.resourceProductionBoost.wheat]];
	[heroAdventures setText:[NSString stringWithFormat:@"%d", [h.quests count]]];
	
	// Buildings
	[BuildingsTable reloadData];
	
	// Movements
	if ([v movements] && [[v movements] count] > 0) {
		
		Movement *mov = [[v movements] objectAtIndex:0];
		
		mov1Name.text = mov.name;
		mov1Time.text = [mov.finished descriptionWithLocale:[NSLocale currentLocale]];
		
		if ([[v movements] count] > 1) {
			mov = [[v movements] objectAtIndex:1];
			
			mov2Name.text = mov.name;
			mov2Time.text = [mov.finished descriptionWithLocale:[NSLocale currentLocale]];
		}
		
	}
}

- (IBAction)reloadData:(id)sender {
	
	Account *a = [[(AppDelegate *)[UIApplication sharedApplication].delegate storage] account];
	
	[a refreshAccount];
	
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	Account *a = [[(AppDelegate *)[UIApplication sharedApplication].delegate storage] account];
	Village *v = [[a villages] objectAtIndex:0];
	
	return [[v buildings] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BuildingCell"];
	
	Account *a = [[(AppDelegate *)[UIApplication sharedApplication].delegate storage] account];
	Village *v = [[a villages] objectAtIndex:0];
	
	Building *building = [[v buildings] objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [NSString stringWithFormat:@"%@ %d",building.name, building.level];
	cell.detailTextLabel.text = building.bid;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	Account *a = [[(AppDelegate *)[UIApplication sharedApplication].delegate storage] account];
	Village *v = [[a villages] objectAtIndex:0];
	
	Building *b = [[v buildings] objectAtIndex:indexPath.row];
	
	[b buildFromAccount:a];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}

@end
