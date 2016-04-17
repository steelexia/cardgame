//
//  SinglePlayerCards.m
//  cardgame
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "SinglePlayerCards.h"

@implementation SinglePlayerCards

/*
 Single player cards notes:
 - Cards with chosable targets must have that ability as the first, and rest must be identical. There cannot be two different chosable targets in one card (players can't do this either anyways)
 
 */

/* Stores NSString as key plus card */
NSMutableDictionary * campaignCards;


+(MonsterCardModel*) getCampaignBossWithID:(NSString*)levelID
{
    MonsterCardModel*monster;
    
    if ([levelID isEqualToString:@"d_1_c_1_l_4"])
    {
        monster = [[MonsterCardModel alloc] initWithIdNumber:1400 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityLegendary;
        monster.element = elementFire;
        monster.name = @"Dragon Boss";
        monster.damage = 4;
        monster.life = monster.maximumLife = 60;
        monster.cost = 10;
        monster.cooldown = monster.maximumCooldown = 2;
        monster.heroic = YES;
        
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityHeroic castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAssassin castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
        
        return monster;
    }
    else if ([levelID isEqualToString:@"d_1_c_2_l_4"])
    {
        monster = [[MonsterCardModel alloc] initWithIdNumber:2400 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityLegendary;
        monster.element = elementNeutral;
        monster.name = @"Skywhale Flagship"; //?
        monster.damage = 0;
        monster.life = monster.maximumLife = 90; //used to be 30k
        monster.cost = 10;
        monster.cooldown = monster.maximumCooldown = 1;
        monster.heroic = YES;
        
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityHeroic castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:[NSNumber numberWithInt:2]]];
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnMove targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
        
        return monster;

    }
    else if ([levelID isEqualToString:@"d_1_c_3_l_4"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_2_c_1_l_4"])
    {
        monster = [[MonsterCardModel alloc] initWithIdNumber:1400 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityLegendary;
        monster.element = elementFire;
        monster.name = @"Dragon Boss";
        monster.damage = 2000;
        monster.life = monster.maximumLife = 30000;
        monster.cost = 10;
        monster.cooldown = monster.maximumCooldown = 1;
        monster.heroic = YES;
        
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityHeroic castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAssassin castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:600]]];
        
        return monster;
    }
    else if ([levelID isEqualToString:@"d_2_c_2_l_4"])
    {
        monster = [[MonsterCardModel alloc] initWithIdNumber:2400 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityLegendary;
        monster.element = elementNeutral;
        monster.name = @"Skywhale Flagship"; //?
        monster.damage = 0;
        monster.life = monster.maximumLife = 41000; //should be ~120
        monster.cost = 10;
        monster.cooldown = monster.maximumCooldown = 1;
        monster.heroic = YES;
        
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityHeroic castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:[NSNumber numberWithInt:2400]]];
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnMove targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:1800]]];
        
        return monster;
    }
    else if ([levelID isEqualToString:@"d_2_c_3_l_4"])
    {
        monster = [[MonsterCardModel alloc] initWithIdNumber:3400 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityLegendary;
        monster.element = elementIce;
        monster.name = @"? Battleship"; //?
        monster.damage = 0;
        monster.life = monster.maximumLife = 140;
        monster.cost = 10;
        monster.cooldown = monster.maximumCooldown = 1;
        monster.heroic = YES;
        
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityHeroic castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        //[monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:[NSNumber numberWithInt:5]]];
        //[monster addBaseAbility: [[Ability alloc] initWithType:abilitySetDamage castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAssassin castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        
        return monster;
    }
    else if ([levelID isEqualToString:@"d_3_c_1_l_4"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_3_c_2_l_4"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_3_c_3_l_4"])
    {
        
    }
    
    monster = [[MonsterCardModel alloc]initWithIdNumber:-1 type:cardTypeSinglePlayer];
    monster.name = @"INCOMPLETE";
    return monster;
}


+(DeckModel*) getCampaignDeckWithID:(NSString*)levelID
{
    DeckModel *deck = [[DeckModel alloc] init];
    
    MonsterCardModel*monster;
    SpellCardModel*spell;
    
    //------------difficulty 1------------//
    //----chapter 1----//
    if ([levelID isEqualToString:@"d_1_c_1_l_1"])
    {
        //NOT SHUFFLED
        
        //turn 1
        //gob fighter
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1000"]]];

        //so the hand appears to be full but won't play any card
        /*
         for (int i = 0; i < 2; i++)
         {
         monster = [[MonsterCardModel alloc] initWithIdNumber:999999 type:cardTypeSinglePlayer];
         monster.name = @"Dummy Card";
         monster.damage = 100;
         monster.life = monster.maximumLife = 100;
         monster.cost = 99;
         monster.cooldown = monster.maximumCooldown = 1;
         
         [deck addCard:monster];
         }*/
        
        //turn 2
        //gob raider
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1003"]]];

        
        //turn 3 shows taunt ability WARNING: do not change ID, do not add another spearman
        //gob spearman
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1002"]]];

        
        //turn 4
        //gob petard
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1004"]]];

        
        //turn 4
        //gob raider
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1003"]]];

        
        //turn 5
        //gob skirm
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1001"]]];

        
        //turn 6
        //gob skirm
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1001"]]];

        
        //turn 6
        //gob commander
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1005"]]];

        
        //turn 7
        //gob shaman
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1006"]]];

        
        //should have finished the AI off at this point, rest are just weak cards
        for (int i = 0; i < 3; i++)
        {
            //gob fighter
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1000"]]];

            //gob skirm
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1001"]]];
            
            //gob raider
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1003"]]];
        }
    }
    else if ([levelID isEqualToString:@"d_1_c_1_l_2"])
    {
        //turn 1
        //gob fighter
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1000"]]];

        
        //so the hand appears to be full but won't play any card
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:999999 type:cardTypeSinglePlayer];
            monster.name = @"Dummy Card";
            monster.damage = 100;
            monster.life = monster.maximumLife = 100;
            monster.cost = 99;
            monster.cooldown = monster.maximumCooldown = 1;
            
            [deck addCard:monster];
        }
        
        //turn 2, teaches spell cards
        //harrassment
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1007"]]];
        
        //turn 3
        //zombie
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1101"]]];
        
        //turn 4
        //oboxinator
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1102"]]];
        
        //turn 5
        //gob raider
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1003"]]];
        
        //turn 5
        //gob skirm
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1101"]]];
        
        //turn 6
        //headslayer
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1100"]]];
        
        //turn 7
        //supply theft
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1008"]]];
        
        //should be over around here, rest are just generic cards
        
        //soul sip
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1103"]]];
        
        //oboxinator
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1102"]]];
        
        //swarm
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1009"]]];
        
        for (int i = 0; i < 3; i++)
        {
            //zombie
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1101"]]];
            
            //gob skirmisher
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1101"]]];
            
            //gob raider
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1003"]]];
        }
    }
    else if ([levelID isEqualToString:@"d_1_c_1_l_3"])
    {
        //no card played on turn 1 just for some variation
        
        for (int i = 0; i < 2; i++)
        {
            //gob raider
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1003"]]];
        }
        
        //dragon 1
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1200"]]];
        
        //dragon 2
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1201"]]];
        
        //gob skirm
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1001"]]];
        
        //gob spearman
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1002"]]];
        
        //gob skirm
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1001"]]];
        
        //swarm
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1009"]]];
        
        //gob commander
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1005"]]];
        
        //harrass
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1007"]]];
        
        //gob spearman
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1002"]]];
        
        //gob commander
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1005"]]];
        
        //harrass
        [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1007"]]];
        
        for (int i = 0; i < 3; i++)
        {
            //gob spearman
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1002"]]];
            
            //gob skirm
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1001"]]];
            
            //gob raider
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1003"]]];
        }
    }
    else if ([levelID isEqualToString:@"d_1_c_1_l_4"])
    {
        for (int i = 0; i < 12; i++)
        {
            //bite
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1401"]]];
        }
        
        for (int i = 0; i < 6; i++)
        {
            //roar
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1402"]]];
        }
        
        for (int i = 0; i < 8; i++)
        {
            //fire breath
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1403"]]];
        }
        
        for (int i = 0; i < 3; i++)
        {
            //fire blast
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_1404"]]];
        }
    }
    //----chapter 2----//
    else if ([levelID isEqualToString:@"d_1_c_2_l_1"])
    {
        //musketeer
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2000"]]];
        
        //duelist
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2001"]]];
        
        //bird charger
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2002"]]];
        
        //NOTE: probably make this guy only in level 1
        for (int i = 0; i < 2; i++)
        {
            //merchant
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2003"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //bazzar arms
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2004"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //point blank
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2005"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //arrest
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2006"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //meronite offensive
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2007"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //elite burial
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2008"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //guard
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2009"]]];
        }
    }
    else if ([levelID isEqualToString:@"d_1_c_2_l_2"])
    {
        for (int i = 0; i < 2; i++)
        {
            //smogland hounds
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2100"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //war mammoth
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2201"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //pikehead charge
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2201"]]];
        }
        
        //musketeer
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2000"]]];
        
        //duelist
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2001"]]];
        
        //bird charger
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2002"]]];
        
        for (int i = 0; i < 2; i++)
        {
            //elite burial
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2008"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //bazzar arms
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2004"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //point blank
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2005"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //arrest
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2006"]]];
        }
    }
    else if ([levelID isEqualToString:@"d_1_c_2_l_3"])
    {
        for (int i = 0; i < 2; i++)
        {
            //cyborg biker
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2200"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //sandbot
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2201"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //skywhale
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2202"]]];
        }
        
        //musketeer
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2000"]]];
        
        //duelist
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2001"]]];
        
        for (int i = 0; i < 2; i++)
        {
            //guard
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2009"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //elite burial
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2008"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //bazzar arms
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2004"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //point blank
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2005"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //arrest
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2006"]]];
        }
    }
    else if ([levelID isEqualToString:@"d_1_c_2_l_4"])
    {
        for (int i = 0; i < 12; i++)
        {
            //culverine
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2300"]]];
        }
        
        for (int i = 0; i < 12; i++)
        {
            //bomb
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2301"]]];
        }
        
        
        for (int i = 0; i < 8; i++)
        {
            //goo cannon
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2302"]]];
        }
        
        for (int i = 0; i < 8; i++)
        {
            //broadside volley
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d1_2303"]]];
        }
    }
    //----chapter 3----//
    else if ([levelID isEqualToString:@"d_1_c_3_l_1"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_1_c_3_l_2"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_1_c_3_l_3"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_1_c_3_l_4"])
    {
        
    }
    //------------difficulty 2------------//
    //----chapter 1----//
    else if ([levelID isEqualToString:@"d_2_c_1_l_1"])
    {
        for (int i = 0; i < 2; i++)
        {
            //goblin fighter
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1000"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gob skirm
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1001"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gob spearman
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1002"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gob raider
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1003"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gob petard
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1004"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gob commander
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1005"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gob shaman
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1006"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //harrassment
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1007"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //supply theft
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1008"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //frenzied swarm
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1009"]]];
        }
    }
    else if ([levelID isEqualToString:@"d_2_c_1_l_2"])
    {
        for (int i = 0; i < 2; i++)
        {
            //goblin fighter
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1000"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gob skirm
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1001"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gob raider
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1003"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gob petard
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1004"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gob shaman
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1006"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //harrassment
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1007"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //headslayer
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1100"]]];
        }
        
        //maybe
        for (int i = 0; i < 2; i++)
        {
            //zombie
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1101"]]];
        }
        
        //taunt for tutorial, really needed
        for (int i = 0; i < 2; i++)
        {
            //oboxinator
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1102"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //soul sip
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1103"]]];
        }
    }
    else if ([levelID isEqualToString:@"d_2_c_1_l_3"])
    {
        for (int i = 0; i < 2; i++)
        {
            //goblin fighter
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1000"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gob skirm
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1001"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gob raider
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1003"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gob petard
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1004"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gob commander
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1005"]]];
        }

        for (int i = 0; i < 2; i++)
        {
            //gob shaman
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1006"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //harrassment
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1007"]]];
        }
        
        //TODO remove this or shaman..
        for (int i = 0; i < 2; i++)
        {
            //supply theft
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1008"]]];
        }
        
        
        for (int i = 0; i < 2; i++)
        {
            //dragon 1
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1200"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //dragon 2
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1201"]]];
        }
    }
    else if ([levelID isEqualToString:@"d_2_c_1_l_4"])
    {
        for (int i = 0; i < 12; i++)
        {
            //bite
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1401"]]];
        }
        
        for (int i = 0; i < 6; i++)
        {
            //roar
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1402"]]];
        }
        
        for (int i = 0; i < 8; i++)
        {
            //fire breath
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1403"]]];
        }
        
        for (int i = 0; i < 3; i++)
        {
            //fire blast
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_1404"]]];
        }
    }
    //----chapter 2----//
    else if ([levelID isEqualToString:@"d_2_c_2_l_1"])
    {
        //musketeer
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2000"]]];
        
        //duelist
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2001"]]];
        
        //bird charger
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2002"]]];
        
        //NOTE: probably make this guy only in level 1
        for (int i = 0; i < 2; i++)
        {
            //merchant
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2003"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //bazzar arms
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2004"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //point blank
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2005"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //arrest
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2006"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //meronite offensive
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2007"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //elite burial
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2008"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //guard
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2009"]]];
        }
    }
    else if ([levelID isEqualToString:@"d_2_c_2_l_2"])
    {
        for (int i = 0; i < 2; i++)
        {
            //smogland hounds
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2100"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //war mammoth
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2201"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //pikehead charge
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2201"]]];
        }
        
        //musketeer
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2000"]]];
        
        //duelist
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2001"]]];
        
        //bird charger
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2002"]]];
        
        for (int i = 0; i < 2; i++)
        {
            //elite burial
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2008"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //bazzar arms
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2004"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //point blank
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2005"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //arrest
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2006"]]];
        }
    }
    else if ([levelID isEqualToString:@"d_2_c_2_l_3"])
    {
        for (int i = 0; i < 2; i++)
        {
            //cyborg biker
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2200"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //sandbot
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2201"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //skywhale
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2202"]]];
        }
        
        //musketeer
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2000"]]];
        
        //duelist
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2001"]]];
        
        for (int i = 0; i < 2; i++)
        {
            //guard
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2009"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //elite burial
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2008"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //bazzar arms
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2004"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //point blank
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2005"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //arrest
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2006"]]];
        }
    }
    else if ([levelID isEqualToString:@"d_2_c_2_l_4"])
    {
        for (int i = 0; i < 12; i++)
        {
            //culverine
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2300"]]];
        }
        
        for (int i = 0; i < 12; i++)
        {
            //bomb
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2301"]]];
        }
        
        for (int i = 0; i < 8; i++)
        {
            //goo cannon
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2302"]]];
        }
        
        for (int i = 0; i < 8; i++)
        {
            //broadside volley
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_2303"]]];
        }
    }
    //----chapter 3----//
    else if ([levelID isEqualToString:@"d_2_c_3_l_1"])
    {
        for (int i = 0; i < 2; i++)
        {
            //imperial infantry
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3000"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //robot with taunt
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3001"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gravity defier II
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3002"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //explorer
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3003"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //armoured barge
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3004"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //battlecruiser
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3005"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //landing +dmg
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3006"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //close air support
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3007"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //UAV recon
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3008"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //resupply
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3009"]]];
        }
        
    }
    else if ([levelID isEqualToString:@"d_2_c_3_l_2"])
    {
        for (int i = 0; i < 2; i++)
        {
            //assassin walker
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3100"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //walker
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3101"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gravity defier II
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3002"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //explorer
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3003"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //armoured barge
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3004"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //walker concept
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3102"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //battlecruiser
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3005"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //landing
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3006"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //close air support
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3007"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //UAV silence
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3008"]]];
        }
        
    }
    else if ([levelID isEqualToString:@"d_2_c_3_l_3"])
    {
        for (int i = 0; i < 2; i++)
        {
            //assassin walker
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3100"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //walker
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3101"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //taunt robot
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3001"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //gravity defier III
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3200"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //battlecruiser
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3005"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //big mech
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3202"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //laser beam
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3103"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //close air support
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3007"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //nuke
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3201"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //UAV silence
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3008"]]];
        }
        
    }
    else if ([levelID isEqualToString:@"d_2_c_3_l_4"])
    {
        for (int i = 0; i < 10; i++)
        {
            //blaster
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3300"]]];
        }
        
        for (int i = 0; i < 4; i++)
        {
            //repair drone
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3301"]]];
        }
        
        for (int i = 0; i < 4; i++)
        {
            //particle beam
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3302"]]];
        }
        
        for (int i = 0; i < 4; i++)
        {
            //fighter dock
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_3303"]]];
        }
    }
    //------------difficulty 3------------//
    //----chapter 1----//
    else if ([levelID isEqualToString:@"d_3_c_1_l_1"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_3_c_1_l_2"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_3_c_1_l_3"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_3_c_1_l_4"])
    {
        
    }
    //----chapter 2----//
    else if ([levelID isEqualToString:@"d_3_c_2_l_1"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_3_c_2_l_2"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_3_c_2_l_3"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_3_c_2_l_4"])
    {
        
    }
    //----chapter 3----//
    else if ([levelID isEqualToString:@"d_3_c_3_l_1"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_3_c_3_l_2"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_3_c_3_l_3"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_3_c_3_l_4"])
    {
        
    }
    
    else if([levelID isEqualToString:@"d_1_c_4_l_1"])
    {
        //Cow Level
        //Chapter 4
        //Cow-4001--3
        //Big BIg Cow--4002-3
        //Charging Bull--4003-2
        //Milk Bag--4004-1
        //Cheese--4005-2
        //Vache--4006-1
        //Udder--4007-1
        //Raging Bull-4008-1
        //Cowbell--4009-1;
        //spells
        //Bullshit--4012-2;
        //Mooo, 4013-1
        //Angry Hamburger 4014-2
        
        //cow
        for (int i = 0; i < 3; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_4001"]]];
        
        //Big Big Cow
        for (int i = 0; i < 3; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_4002"]]];
        
        //Charging Bull
        for (int i = 0; i < 2; i++)
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_4003"]]];
        
       // Milk Bag
        for (int i = 0; i < 1; i++)
        {
            
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_4004"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //Cheese
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_4005"]]];
        }
        
        for (int i = 0; i < 1; i++)
        {
            //Vache
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_4006"]]];
        }
        
        for (int i = 0; i < 1; i++)
        {
            //Udder
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_4007"]]];
        }
        
        for (int i = 0; i < 1; i++)
        {
            //Raging Bull
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_4008"]]];
        }
        
        for (int i = 0; i < 1; i++)
        {
            //Cowbell
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_4009"]]];
        }
        
        for (int i = 0; i < 2; i++)
        {
            //Bullshit
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_4012"]]];
        }
        
        for (int i = 0; i < 1; i++)
        {
            //Moo
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_4013"]]];
        }
        for (int i = 0; i < 2; i++)
        {
            //Angry Hamburger
            [deck addCard:[[CardModel alloc] initWithCardModel:campaignCards[@"d2_4014"]]];
        }

    }
    else
    {
        NSLog(@"WARNING: Invalid Campaign Deck ID: %@", levelID);
    }
    
    return deck;
}

+ (void) loadCampaignCards
{
    campaignCards = [[NSMutableDictionary alloc] init];
    
    //temp variables
    MonsterCardModel*monster;
    SpellCardModel*spell;
    
    //-----------------------------------------DIFFICULTY 1--------------------------------------------//
    //-----------------CHAPTER 1----------------//
    //------LEVEL 1--------//
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1000 type:cardTypeSinglePlayer];
    monster.name = @"Goblin Fighter";
    monster.damage = 3;
    monster.life = monster.maximumLife = 2;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    //NSLog(@"%@", [NSString stringWithFormat:@"d1_%d", monster.idNumber]);
    
    //CardModel*card = campaignCards[@"d1_1000"];
    
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1001 type:cardTypeSinglePlayer];
    monster.name = @"Goblin Skirmisher";
    monster.damage = 2;
    monster.life = monster.maximumLife = 4;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:3]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1002 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityUncommon;
    monster.name = @"Goblin Warden";
    monster.damage = 3;
    monster.life = monster.maximumLife = 9;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1003 type:cardTypeSinglePlayer];
    monster.name = @"Goblin Raider";
    monster.damage = 4;
    monster.life = monster.maximumLife = 4;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1004 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityUncommon;
    monster.name = @"Goblin Petard";
    monster.damage = 1;
    monster.life = monster.maximumLife = 2;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:2]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1005 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityRare;
    monster.name = @"Goblin Commander";
    monster.damage = 4;
    monster.life = monster.maximumLife = 9;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 2;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1006 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityUncommon;
    monster.element = elementLight;
    monster.name = @"Goblin Shaman";
    monster.damage = 5;
    monster.life = monster.maximumLife = 8;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 2;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnMove targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:1007 type:cardTypeSinglePlayer];
    spell.element = elementNeutral;
    spell.name = @"Harrassment";
    spell.cost = 2;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:2]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:1008 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityUncommon;
    spell.element = elementDark;
    spell.name = @"Supply Theft";
    spell.cost = 4;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:8]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:2]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:1009 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementNeutral;
    spell.name = @"Frenzied Swarm";
    spell.cost = 4;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    
    //------LEVEL 2--------//
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1100 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityRare;
    monster.element = elementDark;
    monster.name = @"Headslayer Vanguard"; //TODO name
    monster.damage = 11;
    monster.life = monster.maximumLife = 11;
    monster.cost = 6;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityPierce castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1101 type:cardTypeSinglePlayer];
    monster.element = elementDark;
    monster.name = @"Zombie"; //TODO name
    monster.damage = 4;
    monster.life = monster.maximumLife = 5;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityFracture castType:castOnDeath targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1102 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityUncommon;
    monster.element = elementDark;
    monster.name = @"Obnoxinator"; //TODO name
    monster.damage = 5;
    monster.life = monster.maximumLife = 10;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:1103 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementDark;
    spell.name = @"Soul Sip";
    spell.cost = 7;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:13]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:2]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    //------LEVEL 3--------//
    monster = [[MonsterCardModel alloc] initWithIdNumber:1200 type:cardTypeSinglePlayer];
    monster.element = elementFire;
    monster.rarity = cardRarityRare;
    monster.name = @"Dragon 1";
    monster.damage = 8;
    monster.life = monster.maximumLife = 10;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1201 type:cardTypeSinglePlayer];
    monster.element = elementFire;
    monster.rarity = cardRarityRare;
    monster.name = @"Dragon 2";
    monster.damage = 5;
    monster.life = monster.maximumLife = 16;
    monster.cost = 7;
    monster.cooldown = monster.maximumCooldown = 2;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnHit targetType:targetVictimMinion withDuration:durationForever withValue:[NSNumber numberWithInt:3]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnHit targetType:targetAllEnemy withDuration:durationForever withValue:[NSNumber numberWithInt:2]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    //------LEVEL 4--------//
    spell = [[SpellCardModel alloc] initWithIdNumber:1401 type:cardTypeSinglePlayer];
    spell.element = elementNeutral;
    spell.name = @"Bite";
    spell.cost = 3;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:5]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:1402 type:cardTypeSinglePlayer];
    spell.element = elementNeutral;
    spell.name = @"Roar";
    spell.cost = 5;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:8]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:1403 type:cardTypeSinglePlayer];
    spell.element = elementFire;
    spell.name = @"Fire Breath";
    spell.cost = 7;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:5]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:1404 type:cardTypeSinglePlayer];
    spell.element = elementFire;
    spell.name = @"Dragon Blast";
    spell.cost = 8;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:13]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    //-----------------CHAPTER 2----------------//
    //------LEVEL 1--------//
    monster = [[MonsterCardModel alloc] initWithIdNumber:2000 type:cardTypeSinglePlayer];
    monster.name = @"Musketeer";
    monster.damage = 2;
    monster.life = monster.maximumLife = 4;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnMove targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:2]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2001 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityUncommon;
    monster.name = @"Duelist";
    monster.damage = 9;
    monster.life = monster.maximumLife = 3;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2002 type:cardTypeSinglePlayer];
    monster.name = @"Bird Charger";
    monster.damage = 6;
    monster.life = monster.maximumLife = 5;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2003 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityUncommon;
    monster.name = @"Merchant";
    monster.damage = 4;
    monster.life = monster.maximumLife = 7;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:2004 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementNeutral;
    spell.name = @"Bazaar Arms";
    spell.cost = 2;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:4]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityPierce castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:2005 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementLight;
    spell.name = @"Point Blank";
    spell.cost = 5;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:2006 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityUncommon;
    spell.element = elementNeutral;
    spell.name = @"Arrest";
    spell.cost = 3;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:2]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:2007 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityExceptional;
    spell.element = elementLight;
    spell.name = @"Meronite Offensive";
    spell.cost = 5;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:8]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:3]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:2008 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityUncommon;
    spell.element = elementLight;
    spell.name = @"Elite Burial";
    spell.cost = 2;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:10]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:7]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2009 type:cardTypeSinglePlayer];
    monster.element = elementLight;
    monster.rarity = cardRarityRare;
    monster.name = @"Enerian Guard";
    monster.damage = 8;
    monster.life = monster.maximumLife = 14;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:[NSNumber numberWithInt:6]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    //------LEVEL 2--------//
    monster = [[MonsterCardModel alloc] initWithIdNumber:2100 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityRare;
    monster.name = @"Smogland Hounds";
    monster.damage = 5;
    monster.life = monster.maximumLife = 11;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnEndOfTurn targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:2]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2101 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityExceptional;
    monster.name = @"War Mammoth";
    monster.damage = 8;
    monster.life = monster.maximumLife = 18;
    monster.cost = 6;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:2102 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityExceptional;
    spell.element = elementFire;
    spell.name = @"Pikehead Charge";
    spell.cost = 5;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:3]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationUntilEndOfTurn withValue:[NSNumber numberWithInt:3]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    //------LEVEL 3--------//
    monster = [[MonsterCardModel alloc] initWithIdNumber:2200 type:cardTypeSinglePlayer]; //////////////////////////////////////TODO
    monster.element = elementFire;
    monster.rarity = cardRarityRare;
    monster.name = @"Cyborg Biker";
    monster.damage = 6;
    monster.life = monster.maximumLife = 4;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2201 type:cardTypeSinglePlayer];
    monster.element = elementFire;
    monster.rarity = cardRarityRare;
    monster.name = @"Sandbot";
    monster.damage = 8;
    monster.life = monster.maximumLife = 17;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:3]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2202 type:cardTypeSinglePlayer];
    monster.element = elementNeutral;
    monster.rarity = cardRarityRare;
    monster.name = @"Skywhale";
    monster.damage = 7;
    monster.life = monster.maximumLife = 26;
    monster.cost = 7;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnMove targetType:targetAllFriendlyMinions withDuration:durationUntilEndOfTurn withValue:[NSNumber numberWithInt:5]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    //------LEVEL 4--------//
    spell = [[SpellCardModel alloc] initWithIdNumber:2300 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityCommon;
    spell.element = elementFire;
    spell.name = @"Culverin Shot";
    spell.cost = 2;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetHeroEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:7]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2301 type:cardTypeSinglePlayer];
    monster.element = elementFire;
    monster.rarity = cardRarityUncommon;
    monster.name = @"? Bomb";
    monster.damage = 0;
    monster.life = monster.maximumLife = 5;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 2;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:7]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityKill castType:castOnMove targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d1_%d", monster.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:2302 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityUncommon;
    spell.element = elementLight;
    spell.name = @"Goo Cannon";
    spell.cost = 5;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:2303 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityExceptional;
    spell.element = elementFire;
    spell.name = @"Broadside Volley";
    spell.cost = 6;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:8]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:8]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:8]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d1_%d", spell.idNumber]];
    
    //-----------------CHAPTER 3----------------//
    //------LEVEL 1--------//
    //------LEVEL 2--------//
    //------LEVEL 3--------//
    //------LEVEL 4--------//
    
    //-----------------------------------------DIFFICULTY 2--------------------------------------------//
    //-----------------CHAPTER 1----------------//
    //------LEVEL 1--------//
    monster = [[MonsterCardModel alloc] initWithIdNumber:1000 type:cardTypeSinglePlayer];
    monster.name = @"Goblin Fighter";
    monster.damage = 2200;
    monster.life = monster.maximumLife = 1800;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1001 type:cardTypeSinglePlayer];
    monster.name = @"Goblin Skirmisher";
    monster.damage = 900;
    monster.life = monster.maximumLife = 2200;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1800]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1002 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityUncommon;
    monster.name = @"Goblin Warden";
    monster.damage = 1400;
    monster.life = monster.maximumLife = 4800;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:[NSNumber numberWithInt:3500]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1003 type:cardTypeSinglePlayer];
    monster.name = @"Goblin Raider";
    monster.damage = 2800;
    monster.life = monster.maximumLife = 3100;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddResource castType:castOnHit targetType:targetHeroFriendly withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1004 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityUncommon;
    monster.name = @"Goblin Petard";
    monster.damage = 800;
    monster.life = monster.maximumLife = 1200;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:2000]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1005 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityRare;
    monster.name = @"Goblin Commander";
    monster.damage = 2100;
    monster.life = monster.maximumLife = 3700;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 2;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1000]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1000]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1006 type:cardTypeSinglePlayer];
    monster.element = elementLight;
    monster.rarity = cardRarityUncommon;
    monster.name = @"Goblin Shaman";
    monster.damage = 2100;
    monster.life = monster.maximumLife = 3700;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 2;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnMove targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1000]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:1007 type:cardTypeSinglePlayer];
    spell.element = elementNeutral;
    spell.name = @"Harrassment";
    spell.cost = 2;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1000]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:1008 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityUncommon;
    spell.element = elementDark;
    spell.name = @"Supply Theft";
    spell.cost = 3;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:4200]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1100]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:1009 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementNeutral;
    spell.name = @"Frenzied Swarm";
    spell.cost = 4;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllMinion withDuration:durationUntilEndOfTurn withValue:[NSNumber numberWithInt:2000]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    //------LEVEL 2--------//
    monster = [[MonsterCardModel alloc] initWithIdNumber:1100 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityRare;
    monster.element = elementDark;
    monster.name = @"Headslayer Vanguard"; //TODO name
    monster.damage = 6500;
    monster.life = monster.maximumLife = 6300;
    monster.cost = 6;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityPierce castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1101 type:cardTypeSinglePlayer];
    monster.element = elementDark;
    monster.name = @"Generic Zombie"; //TODO name
    monster.damage = 2600;
    monster.life = monster.maximumLife = 2800;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityFracture castType:castOnDeath targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1102 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityUncommon;
    monster.element = elementDark;
    monster.name = @"Obnoxinator"; //TODO name
    monster.damage = 2800;
    monster.life = monster.maximumLife = 5800;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:1103 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementDark;
    spell.name = @"Soul Sip";
    spell.cost = 6;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:2000]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    //------LEVEL 3--------//
    monster = [[MonsterCardModel alloc] initWithIdNumber:1200 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityRare;
    monster.name = @"Dragon 1";
    monster.damage = 4100;
    monster.life = monster.maximumLife = 4900;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1500]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1201 type:cardTypeSinglePlayer];
    monster.element = elementFire;
    monster.rarity = cardRarityRare;
    monster.name = @"Dragon 2";
    monster.damage = 3900;
    monster.life = monster.maximumLife = 7700;
    monster.cost = 7;
    monster.cooldown = monster.maximumCooldown = 2;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnHit targetType:targetVictimMinion withDuration:durationForever withValue:[NSNumber numberWithInt:2600]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnHit targetType:targetAllEnemy withDuration:durationForever withValue:[NSNumber numberWithInt:2200]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    //------LEVEL 4--------//
    
    spell = [[SpellCardModel alloc] initWithIdNumber:1401 type:cardTypeSinglePlayer];
    spell.element = elementNeutral;
    spell.name = @"Bite";
    spell.cost = 3;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:4200]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    
    spell = [[SpellCardModel alloc] initWithIdNumber:1402 type:cardTypeSinglePlayer];
    spell.element = elementNeutral;
    spell.name = @"Roar";
    spell.cost = 5;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:5600]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1600]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:1403 type:cardTypeSinglePlayer];
    spell.element = elementFire;
    spell.name = @"Fire Breath";
    spell.cost = 7;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:3200]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:1404 type:cardTypeSinglePlayer];
    spell.element = elementFire;
    spell.name = @"Dragon Blast";
    spell.cost = 8;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    //-----------------CHAPTER 2----------------//
    //------LEVEL 1--------//
    monster = [[MonsterCardModel alloc] initWithIdNumber:2000 type:cardTypeSinglePlayer];
    monster.name = @"Musketeer";
    monster.damage = 700;
    monster.life = monster.maximumLife = 1600;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnMove targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:1900]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2001 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityUncommon;
    monster.name = @"Duelist";
    monster.damage = 4200;
    monster.life = monster.maximumLife = 2300;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2002 type:cardTypeSinglePlayer];
    monster.name = @"Bird Charger";
    monster.damage = 2900;
    monster.life = monster.maximumLife = 2400;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2003 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityUncommon;
    monster.name = @"Merchant";
    monster.damage = 1700;
    monster.life = monster.maximumLife = 2700;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:2004 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementNeutral;
    spell.name = @"Bazaar Arms";
    spell.cost = 2;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:2800]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityPierce castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:2005 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementLight;
    spell.name = @"Point Blank";
    spell.cost = 4;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:2006 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityUncommon;
    spell.element = elementNeutral;
    spell.name = @"Arrest";
    spell.cost = 2;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:2]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:2007 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityExceptional;
    spell.element = elementLight;
    spell.name = @"Meronite Offensive";
    spell.cost = 5;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:4200]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1900]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:2008 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityUncommon;
    spell.element = elementLight;
    spell.name = @"Elite Burial";
    spell.cost = 2;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:6200]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:3700]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2009 type:cardTypeSinglePlayer];
    monster.element = elementLight;
    monster.rarity = cardRarityRare;
    monster.name = @"Enerian Guard"; //TODO
    monster.damage = 5300;
    monster.life = monster.maximumLife = 6700;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:[NSNumber numberWithInt:2500]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    //------LEVEL 2--------//
    monster = [[MonsterCardModel alloc] initWithIdNumber:2100 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityRare;
    monster.name = @"Smogland Hounds";
    monster.damage = 2100;
    monster.life = monster.maximumLife = 5200;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnEndOfTurn targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:1300]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2101 type:cardTypeSinglePlayer];
    monster.rarity = cardRarityExceptional;
    monster.name = @"War Mammoth";
    monster.damage = 3700;
    monster.life = monster.maximumLife = 8300;
    monster.cost = 6;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1000]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:2102 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityExceptional;
    spell.element = elementFire;
    spell.name = @"Pikehead Charge";
    spell.cost = 5;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1500]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationUntilEndOfTurn withValue:[NSNumber numberWithInt:1800]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    //------LEVEL 3--------//
    monster = [[MonsterCardModel alloc] initWithIdNumber:2200 type:cardTypeSinglePlayer];
    monster.element = elementFire;
    monster.rarity = cardRarityRare;
    monster.name = @"Cyborg Biker";
    monster.damage = 2300;
    monster.life = monster.maximumLife = 1700;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2201 type:cardTypeSinglePlayer];
    monster.element = elementFire;
    monster.rarity = cardRarityRare;
    monster.name = @"Sandbot";
    monster.damage = 3100;
    monster.life = monster.maximumLife = 6600;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1200]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2202 type:cardTypeSinglePlayer];
    monster.element = elementNeutral;
    monster.rarity = cardRarityRare;
    monster.name = @"Skywhale";
    monster.damage = 3000;
    monster.life = monster.maximumLife = 10200;
    monster.cost = 7;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnMove targetType:targetAllFriendlyMinions withDuration:durationUntilEndOfTurn withValue:[NSNumber numberWithInt:2200]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    //------LEVEL 4--------//
    spell = [[SpellCardModel alloc] initWithIdNumber:2300 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityCommon;
    spell.element = elementFire;
    spell.name = @"Culverin Shot";
    spell.cost = 2;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetHeroEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:2600]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2301 type:cardTypeSinglePlayer];
    monster.element = elementFire;
    monster.rarity = cardRarityUncommon;
    monster.name = @"? Bomb";
    monster.damage = 0;
    monster.life = monster.maximumLife = 2100;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 2;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:2900]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityKill castType:castOnMove targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:2302 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityUncommon;
    spell.element = elementLight;
    spell.name = @"Goo Cannon";
    spell.cost = 5;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:2303 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityExceptional;
    spell.element = elementFire;
    spell.name = @"Broadside Volley";
    spell.cost = 6;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:3200]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:3200]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:3200]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    //-----------------CHAPTER 3----------------//
    //------LEVEL 1--------//
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:3000 type:cardTypeSinglePlayer];
    monster.element = elementLight;
    monster.rarity = cardRarityCommon;
    monster.name = @"Imperial Infantry";
    monster.damage = 4;
    monster.life = monster.maximumLife = 6;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:3001 type:cardTypeSinglePlayer];
    monster.element = elementIce;
    monster.rarity = cardRarityCommon;
    monster.name = @"? Robot"; //big robot
    monster.damage = 2;
    monster.life = monster.maximumLife = 10;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:3]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:3002 type:cardTypeSinglePlayer];
    monster.element = elementLight;
    monster.rarity = cardRarityCommon;
    monster.name = @"Gravity Defier Mk. II"; //support version
    monster.damage = 0;
    monster.life = monster.maximumLife = 13;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnEndOfTurn targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:3003 type:cardTypeSinglePlayer];
    monster.element = elementIce;
    monster.rarity = cardRarityCommon;
    monster.name = @"? Explorer";
    monster.damage = 10;
    monster.life = monster.maximumLife = 9;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:3004 type:cardTypeSinglePlayer];
    monster.element = elementIce;
    monster.rarity = cardRarityUncommon;
    monster.name = @"Armoured Barge";
    monster.damage = 2;
    monster.life = monster.maximumLife = 4;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddResource castType:castOnMove targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnMove targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:3005 type:cardTypeSinglePlayer];
    monster.element = elementLight;
    monster.rarity = cardRarityExceptional;
    monster.name = @"Imperial Battlecruiser";
    monster.damage = 8;
    monster.life = monster.maximumLife = 13;
    monster.cost = 6;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:6]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:2]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:3006 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementLightning;
    spell.name = @"? Landing";
    spell.cost = 2;
    
    //would be cool if had special ability to summon imperial infantry
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationUntilEndOfTurn withValue:[NSNumber numberWithInt:5]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:3007 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementLightning;
    spell.name = @"Close Air Support";
    spell.cost = 3;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:6]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:6]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:3008 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityExceptional;
    spell.element = elementLight;
    spell.name = @"UAV Recon";
    spell.cost = 4;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:3009 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementLight;
    spell.name = @"? Resupply";
    spell.cost = 5;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:6]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:2]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    //------LEVEL 2--------//
    monster = [[MonsterCardModel alloc] initWithIdNumber:3100 type:cardTypeSinglePlayer];
    monster.element = elementLightning;
    monster.rarity = cardRarityCommon;
    monster.name = @"? Walker"; //mech assassin
    monster.damage = 5;
    monster.life = monster.maximumLife = 2;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAssassin castType:castOnSummon targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:3101 type:cardTypeSinglePlayer];
    monster.element = elementFire;
    monster.rarity = cardRarityCommon;
    monster.name = @"Praka Mech"; //mech praca
    monster.damage = 6;
    monster.life = monster.maximumLife = 6;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:3102 type:cardTypeSinglePlayer];
    monster.element = elementFire;
    monster.rarity = cardRarityUncommon;
    monster.name = @"? Walker"; //mech concept
    monster.damage = 9;
    monster.life = monster.maximumLife = 11;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:6]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:3103 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementLight;
    spell.name = @"? Beam";
    spell.cost = 3;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:12]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    //------LEVEL 3--------//
    //give assassin for the insane version
    monster = [[MonsterCardModel alloc] initWithIdNumber:3200 type:cardTypeSinglePlayer];
    monster.element = elementDark;
    monster.rarity = cardRarityCommon;
    monster.name = @"Gravity Defier Mk. III";
    monster.damage = 4;
    monster.life = monster.maximumLife = 14;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnDamaged targetType:targetHeroFriendly withDuration:durationForever withValue:[NSNumber numberWithInt:4]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];

    spell = [[SpellCardModel alloc] initWithIdNumber:3201 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityExceptional;
    spell.element = elementFire;
    spell.name = @"Tactical Nuke";
    spell.cost = 4;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAll withDuration:durationInstant withValue:[NSNumber numberWithInt:10]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];

    monster = [[MonsterCardModel alloc] initWithIdNumber:3202 type:cardTypeSinglePlayer];
    monster.element = elementDark;
    monster.rarity = cardRarityExceptional;
    monster.name = @"? Mech";
    monster.damage = 21;
    monster.life = monster.maximumLife = 19;
    monster.cost = 8;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAll withDuration:durationForever withValue:[NSNumber numberWithInt:5]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnMove targetType:targetHeroEnemy withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    //------LEVEL 4--------//
    
    spell = [[SpellCardModel alloc] initWithIdNumber:3300 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityUncommon;
    spell.element = elementLightning;
    spell.name = @"Proton Blaster";
    spell.cost = 2;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetHeroFriendly withDuration:durationUntilEndOfTurn withValue:[NSNumber numberWithInt:10]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:3301 type:cardTypeSinglePlayer];
    monster.element = elementLight;
    monster.rarity = cardRarityRare;
    monster.name = @"Repair Drones";
    monster.damage = 2;
    monster.life = monster.maximumLife = 15;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 3;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnEndOfTurn targetType:targetHeroFriendly withDuration:durationForever withValue:[NSNumber numberWithInt:6]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityReturnToHand castType:castOnMove targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:3302 type:cardTypeSinglePlayer];
    monster.element = elementIce;
    monster.rarity = cardRarityRare;
    monster.name = @"Particle Beam Cannon";
    monster.damage = 5;
    monster.life = monster.maximumLife = 12;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 2;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnMove targetType:targetHeroEnemy withDuration:durationForever withValue:[NSNumber numberWithInt:20]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityReturnToHand castType:castOnMove targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    int c3FighterDamage = 5;
    int c3FighterLife = 5;
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:3303 type:cardTypeSinglePlayer];
    monster.element = elementLightning;
    monster.rarity = cardRarityExceptional;
    monster.name = @"Fighter Bay";
    monster.damage = 3;
    monster.life = monster.maximumLife = 14;
    monster.cost = 0;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilitySummonFighter castType:castOnMove targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:3304] withOtherValues:@[@(c3FighterDamage),@(c3FighterLife),@(2)]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilitySetCooldown castType:castOnMove targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];

    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    //not summonable
    monster = [[MonsterCardModel alloc] initWithIdNumber:3304 type:cardTypeSinglePlayer];
    monster.element = elementLightning;
    monster.rarity = cardRarityCommon;
    monster.name = @"Escort Fighter";
    monster.damage = c3FighterDamage;
    monster.life = monster.maximumLife = c3FighterLife;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //-----------------------------------------DIFFICULTY 3--------------------------------------------//
    //-----------------CHAPTER 1----------------//
    //------LEVEL 1--------//
    //------LEVEL 2--------//
    //------LEVEL 3--------//
    //------LEVEL 4--------//
    
    //-----------------CHAPTER 2----------------//
    //------LEVEL 1--------//
    //------LEVEL 2--------//
    //------LEVEL 3--------//
    //------LEVEL 4--------//
    
    //-----------------CHAPTER 3----------------//
    //------LEVEL 1--------//
    
    
    
    //------LEVEL 2--------//
    //------LEVEL 3--------//
    //------LEVEL 4--------//
    
    //Brian July 29
    //Cow Level
    //Chapter 4
    //Cow-4001--3
    //Big BIg Cow--4002-3
    //Charging Bull--4003-2
    //Milk Bag--4004-2
    //Cheese--4005-1
    //Vache--4006-1
    //Udder--4007-1
    //Raging Bull-4008-1
    //Cowbell--4009-1;
    //spells
    //Bullshit--4012-2;
    //Mooo, 4013-1
    //Angry Hamburger 4014-2
    //-----------------CHAPTER 3----------------//
    //------LEVEL 1--------//
    monster = [[MonsterCardModel alloc] initWithIdNumber:4001 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityCommon;
    monster.name = @"Cow";
    monster.damage = 1100;
    monster.life = monster.maximumLife = 3000;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:1600]]];
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:4002 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityCommon;
    monster.name = @"Big Big Cow";
    monster.damage = 4000;
    monster.life = monster.maximumLife = 1000;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.flavourText = @"He's so big!";
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:4003 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityCommon;
    monster.name = @"Charging Bull";
    monster.damage = 5000;
    monster.life = monster.maximumLife = 3000;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 0;
    monster.flavourText = @"His cousin is Raging Bull";
     [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnHit targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:2]]];
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:4004 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityCommon;
    monster.name = @"MilkBag";
    monster.damage = 200;
    monster.life = monster.maximumLife = 7000;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 0;
    monster.flavourText = @"It does a body good";
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnStartOfTurn targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:2000]]];
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:4005 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityCommon;
    monster.name = @"Cheese";
    monster.damage = 6000;
    monster.life = monster.maximumLife = 100;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 0;
    monster.flavourText = @"Not even fair.  The 4-pool of creatures.";
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:4006 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityCommon;
    monster.name = @"Vache";
    monster.damage = 5000;
    monster.life = monster.maximumLife = 7500;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 2;
    monster.flavourText = @"Le Cow Francais.  He doesn't move until he's ready.";
    
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:4007 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityCommon;
    monster.name = @"Udder";
    monster.damage = 2000;
    monster.life = monster.maximumLife = 6500;
    monster.cost = 6;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.flavourText = @"Don't talk bad about my Mudder's Udder--Raging Bull";
     [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnStartOfTurn targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:500]]];
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:4008 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityCommon;
    monster.name = @"Raging Bull";
    monster.damage = 1000;
    monster.life = monster.maximumLife = 12500;
    monster.cost = 7;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.flavourText = @"You won't like him when he's angry";
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnMove targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:2500]]];
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:4009 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityCommon;
    monster.name = @"Cowbell";
    monster.damage = 1000;
    monster.life = monster.maximumLife = 1200;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.flavourText = @"For some reason, you feel you need more of this..";
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnMove targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:4012 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementEarth;
    spell.name = @"Bullshit!";
    spell.cost = 3;
    spell.flavourText = @"It's really slippery...eww.";
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:3]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:4013 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementEarth;
    spell.name = @"MooooOOoooo";
    spell.cost = 5;
    spell.flavourText = @"Moo.";
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:4000]]];

    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];

    spell = [[SpellCardModel alloc] initWithIdNumber:4014 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementFire;
    spell.name = @"Angry Hamburger";
    spell.cost = 3;
    spell.flavourText = @"It's really spicy!";
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:9000]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    //Dog Level Brian July 29
    //Dog-2
    //Double Doggen--2
    //Angry Puppy--1
    //Guilty Dog--1
    //Fort Dog--2
    //LEGENDARY DOGE
    
    //Spell-Woof-2
    //Spell-SQUIRREL!--3
    //Spell--Boop--1
    //Spell--Who Let The Dogs Out?--1
    //Spell--To The Moon-2
    //Spell--Much Cards, Such Win
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:4020 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityCommon;
    monster.name = @"Dog";
    monster.damage = 2500;
    monster.life = monster.maximumLife = 2200;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.flavourText = @"Snaaaaarrrrfff.  Wooof.  Snarrrf.";
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:4021 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityCommon;
    monster.name = @"Double Doggen";
    monster.damage = 2500;
    monster.life = monster.maximumLife = 2200;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.flavourText = @"Still less Dogs than a DMX song.";
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityFracture castType:castOnDeath targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:4022 type:cardTypeSinglePlayer];
    monster.element = elementDark;
    monster.rarity = cardRarityCommon;
    monster.name = @"Angry Puppy";
    monster.damage = 6000;
    monster.life = monster.maximumLife = 200;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 0;
    monster.flavourText = @"You done fucked up.";
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetHeroEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:3000]]];
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:4023 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityCommon;
    monster.name = @"Guilty Dog";
    monster.damage = 2000;
    monster.life = monster.maximumLife = 8000;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 0;
    monster.flavourText = @"He's guilty because he wiped himself all over your board =/";
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:5000]]];
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:4024 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityCommon;
    monster.name = @"Dog Fort";
    monster.damage = 2000;
    monster.life = monster.maximumLife = 12000;
    monster.cost = 6;
    monster.cooldown = monster.maximumCooldown = 0;
    monster.flavourText = @"This is Dog Fort, 10-4, Over.";
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:4025 type:cardTypeSinglePlayer];
    monster.element = elementEarth;
    monster.rarity = cardRarityCommon;
    monster.name = @"LEGENDARY DOGE";
    monster.damage = 8000;
    monster.life = monster.maximumLife = 8000;
    monster.cost = 8;
    monster.cooldown = monster.maximumCooldown = 0;
    monster.flavourText = @"Such Card. Much Woof";
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityPierce castType:castOnSummon targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
   [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnStartOfTurn targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:800]]];
    [campaignCards setObject:monster forKey:[NSString stringWithFormat:@"d2_%d", monster.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:4031 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementEarth;
    spell.name = @"WOOF!";
    spell.cost = 2;
    spell.flavourText = @"The bark is worse than the bite.";
   
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:3000]]];
     [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:500]]];
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:4032 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementEarth;
    spell.name = @"SQUIRREL!";
    spell.cost = 2;
    spell.flavourText = @"Inspiration for dogs everywhere.";
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:2000]]];
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:2500]]];
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:4033 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementEarth;
    spell.name = @"Boop";
    spell.cost = 2;
    spell.flavourText = @"Awwwwwww.";
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:4000]]];
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:4]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetOneRandomFriendlyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:4]]];
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];

    spell = [[SpellCardModel alloc] initWithIdNumber:4033 type:cardTypeSinglePlayer];
    spell.rarity = cardRarityRare;
    spell.element = elementEarth;
    spell.name = @"Who Let The Dogs Out?";
    spell.cost = 4;
    spell.flavourText = @"Woof, Wuff Wuffff Woooooof.";
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:3000]]];
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:4]]];
    
    [campaignCards setObject:spell forKey:[NSString stringWithFormat:@"d2_%d", spell.idNumber]];
    
}

+(DeckModel*) getPlayerCampaignDeckWithID:(NSString*)levelID
{
    DeckModel *deck = [[DeckModel alloc] init];
    
    DeckModel *starterDeck = [self getStartingDeck];
    
    //----chapter 1----//
    if ([levelID isEqualToString:@"d_1_c_1_l_1"])
    {
        [deck addCard:starterDeck.cards[1]];
        [deck addCard:starterDeck.cards[2]];
        [deck addCard:starterDeck.cards[3]];
        [deck addCard:starterDeck.cards[4]];
        [deck addCard:starterDeck.cards[5]];
    }
    else if ([levelID isEqualToString:@"d_1_c_1_l_2"])
    {
        [deck addCard:starterDeck.cards[0]];
        [deck addCard:starterDeck.cards[1]];
        [deck addCard:starterDeck.cards[4]];
        [deck addCard:starterDeck.cards[6]];
        [deck addCard:starterDeck.cards[5]];
        [deck addCard:starterDeck.cards[2]];
        [deck addCard:starterDeck.cards[7]];
        [deck addCard:starterDeck.cards[3]];
        [deck addCard:starterDeck.cards[8]];
        [deck addCard:starterDeck.cards[9]];
    }
    else if ([levelID isEqualToString:@"d_1_c_1_l_3"])
    {
        [deck addCard:starterDeck.cards[8]];
        [deck addCard:starterDeck.cards[10]];
        [deck addCard:starterDeck.cards[16]];
        [deck addCard:starterDeck.cards[0]];
        [deck addCard:starterDeck.cards[7]];
        [deck addCard:starterDeck.cards[2]];
        [deck addCard:starterDeck.cards[19]];
        [deck addCard:starterDeck.cards[14]];
        [deck addCard:starterDeck.cards[1]];
        [deck addCard:starterDeck.cards[15]];
        [deck addCard:starterDeck.cards[17]];
        [deck addCard:starterDeck.cards[9]];
        [deck addCard:starterDeck.cards[18]];
        [deck addCard:starterDeck.cards[11]];
        [deck addCard:starterDeck.cards[13]];
        [deck addCard:starterDeck.cards[12]];
    }
    else if ([levelID isEqualToString:@"d_1_c_1_l_4"])
    {
        [deck addCard:starterDeck.cards[0]];
        [deck addCard:starterDeck.cards[9]];
        [deck addCard:starterDeck.cards[17]];
        [deck addCard:starterDeck.cards[12]];
        [deck addCard:starterDeck.cards[7]];
        [deck addCard:starterDeck.cards[1]];
        [deck addCard:starterDeck.cards[8]];
        [deck addCard:starterDeck.cards[2]];
        [deck addCard:starterDeck.cards[4]];
        [deck addCard:starterDeck.cards[19]];
        [deck addCard:starterDeck.cards[10]];
        [deck addCard:starterDeck.cards[15]];
        [deck addCard:starterDeck.cards[6]];
        [deck addCard:starterDeck.cards[11]];
        [deck addCard:starterDeck.cards[5]];
        [deck addCard:starterDeck.cards[14]];
        [deck addCard:starterDeck.cards[18]];
        [deck addCard:starterDeck.cards[3]];
    }
    else
        return nil;
    
    return deck;
}

/** All players have these cards */
+(DeckModel*)getStartingDeck
{
    DeckModel *deck = [[DeckModel alloc] init];
    
    MonsterCardModel* monster;
    SpellCardModel* spell;
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:1 type:cardTypeStandard];
    monster.name = @"Foxy"; //?
    monster.damage = 3;
    monster.life = monster.maximumLife = 5;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.adminPhotoCheck = 1;
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:2 type:cardTypeStandard];
    monster.name = @"Pigman Chief";
    monster.damage = 5;
    monster.life = monster.maximumLife = 8;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.adminPhotoCheck = 1;
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:3 type:cardTypeStandard];
    monster.name = @"Ratmen";
    monster.damage = 10;
    monster.life = monster.maximumLife = 7;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.adminPhotoCheck = 1;
    
    [deck addCard:monster];
    
    //unique, neutral with charge
    monster = [[MonsterCardModel alloc] initWithIdNumber:4 type:cardTypeStandard];
    monster.name = @"Boreal Harpy";
    monster.damage = 7;
    monster.life = monster.maximumLife = 5;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.adminPhotoCheck = 1;
    monster.rarity = cardRarityUncommon;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    //monster.flavourText = @"Testing a flavour text of the foxy card.";
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:5 type:cardTypeStandard];
    monster.name = @"Sand Dragon Summoner";
    monster.damage = 12;
    monster.life = monster.maximumLife = 14;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.adminPhotoCheck = 1;
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:6 type:cardTypeStandard];
    monster.name = @"Swampling";
    monster.damage = 6;
    monster.life = monster.maximumLife = 13;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 2;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:8]]];
    monster.adminPhotoCheck = 1;
    
    [deck addCard:monster];
    
    //unique deal damage to any target (neutral only can target minion)
    spell = [[SpellCardModel alloc] initWithIdNumber:7 type:cardTypeStandard];
    spell.name = @"Slash";
    spell.cost = 2;
    spell.rarity = cardRarityUncommon;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:6]]];
    spell.adminPhotoCheck = 1;
    [deck addCard:spell];
    
    //2 abilities, uncommon card, unique for draw card, 84.6% efficiency of common card
    spell = [[SpellCardModel alloc] initWithIdNumber:8 type:cardTypeStandard];
    spell.name = @"Fountain of Youth";
    spell.cost = 2;
    spell.rarity = cardRarityUncommon;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:4]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    spell.adminPhotoCheck = 1;
    [deck addCard:spell];
    
    //uncommon ability
    monster = [[MonsterCardModel alloc] initWithIdNumber:9 type:cardTypeStandard];
    monster.name = @"Venom Sorceress";
    monster.damage = 8;
    monster.life = monster.maximumLife = 4;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.rarity = cardRarityUncommon;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:3]]];
    monster.adminPhotoCheck = 1;
    
    [deck addCard:monster];
    
    //uncommon ability
    spell = [[SpellCardModel alloc] initWithIdNumber:10 type:cardTypeStandard];
    spell.name = @"Migration";
    spell.cost = 1;
    spell.rarity = cardRarityUncommon;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    spell.adminPhotoCheck = 1;
    [deck addCard:spell];
    
    //unique dark ability
    monster = [[MonsterCardModel alloc] initWithIdNumber:11 type:cardTypeStandard];
    monster.name = @"Redbeard Shaman";
    monster.damage = 6;
    monster.life = monster.maximumLife = 5;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.rarity = cardRarityUncommon;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:6]]];
    monster.adminPhotoCheck = 1;
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:12 type:cardTypeStandard];
    monster.name = @"Fenlong";
    monster.damage = 8;
    monster.life = monster.maximumLife = 12;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    monster.adminPhotoCheck = 1;
    
    [deck addCard:monster];
    
    //unique for having two abilities, one from ice, 83.4% point efficiency
    monster = [[MonsterCardModel alloc] initWithIdNumber:13 type:cardTypeStandard];
    monster.name = @"Water Colossus";
    monster.damage = 6;
    monster.life = monster.maximumLife = 14;
    monster.cost = 6;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.rarity = cardRarityRare;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:5]]];
    monster.adminPhotoCheck = 1;
    
    [deck addCard:monster];
    
    //unique ability target both hero and minion, 80% efficiency
    spell = [[SpellCardModel alloc] initWithIdNumber:14 type:cardTypeStandard];
    spell.name = @"Leviathan Returns";
    spell.cost = 5;
    spell.rarity = cardRarityUncommon;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:12]]];
    spell.adminPhotoCheck = 1;
    [deck addCard:spell];
    
    //unique +damage to all, 79.2% efficiency
    spell = [[SpellCardModel alloc] initWithIdNumber:15 type:cardTypeStandard];
    spell.name = @"Last Stand";
    spell.rarity = cardRarityUncommon;
    spell.cost = 4;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationUntilEndOfTurn withValue:[NSNumber numberWithInt:6]]];
    spell.adminPhotoCheck = 1;
    [deck addCard:spell];
    
    //unique rare ability, 83.5% efficiency
    monster = [[MonsterCardModel alloc] initWithIdNumber:16 type:cardTypeStandard];
    monster.name = @"Gugu";
    monster.damage = 0;
    monster.life = monster.maximumLife = 13;
    monster.cost = 3;
    monster.rarity = cardRarityRare;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnMove targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:5]]];
    monster.adminPhotoCheck = 1;
    
    [deck addCard:monster];
    
    //85% effiency, no special ability
    monster = [[MonsterCardModel alloc] initWithIdNumber:17 type:cardTypeStandard];
    monster.name = @"Fireball Slinger";
    monster.damage = 3;
    monster.life = monster.maximumLife = 7;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:7]]];
    monster.adminPhotoCheck = 1;
    
    [deck addCard:monster];
    
    //unique exceptional ability, 75% efficiency
    monster = [[MonsterCardModel alloc] initWithIdNumber:18 type:cardTypeStandard];
    monster.name = @"Shrimpman";
    monster.damage = 3;
    monster.life = monster.maximumLife = 7;
    monster.cost = 3;
    monster.rarity = cardRarityExceptional;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddResource castType:castOnHit targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    monster.adminPhotoCheck = 1;
    
    [deck addCard:monster];
    
    //unique for 7 cost (uncommon at least)
    monster = [[MonsterCardModel alloc] initWithIdNumber:19 type:cardTypeStandard];
    monster.name = @"Deity of Magic";
    monster.damage = 12;
    monster.life = monster.maximumLife = 17;
    monster.cost = 7;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.rarity = cardRarityExceptional;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnHit targetType:targetHeroEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:6]]];
    monster.adminPhotoCheck = 1;
    
    [deck addCard:monster];
    
    //unique earth ability, 60% efficiency pretty bad
    spell = [[SpellCardModel alloc] initWithIdNumber:20 type:cardTypeStandard];
    spell.name = @"Hariya's Curse";
    spell.cost = 2;
    spell.rarity = cardRarityUncommon;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
    spell.adminPhotoCheck = 1;
    
    [deck addCard:spell];
    
    return deck;
}


/** All players have these cards */
+(DeckModel*)getElementDeck: (enum CardElement) element;
{
    DeckModel *deck = [[DeckModel alloc] init];
    
    MonsterCardModel* monster;
    SpellCardModel* spell;
    
    //ID 100 to 199
    if (element == elementFire)
    {
        //basic card, 93% efficiency
        monster = [[MonsterCardModel alloc] initWithIdNumber:100 type:cardTypeStandard];
        monster.name = @"Shadow Hunter";
        monster.element = elementFire;
        monster.damage = 4;
        monster.life = monster.maximumLife = 2;
        monster.cost = 2;
        monster.cooldown = monster.maximumCooldown = 1;
        monster.rarity = cardRarityCommon;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:4]]];
        monster.adminPhotoCheck = 1;
        [deck addCard:monster];
        
        //basic signature card, practically 100% efficiency for common
        spell = [[SpellCardModel alloc] initWithIdNumber:101 type:cardTypeStandard];
        spell.name = @"Lampad's Breath";
        spell.element = elementFire;
        spell.rarity = cardRarityCommon;
        spell.cost = 2;
        
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:7]]];
        spell.adminPhotoCheck = 1;
        [deck addCard:spell];
        
        //~96% efficiency and regular ability
        monster = [[MonsterCardModel alloc] initWithIdNumber:102 type:cardTypeStandard];
        monster.name = @"Pryodemon";
        monster.element = elementFire;
        monster.damage = 9;
        monster.life = monster.maximumLife = 9;
        monster.cost = 4;
        monster.cooldown = monster.maximumCooldown = 1;
        monster.rarity = cardRarityCommon;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:5]]];
        monster.adminPhotoCheck = 1;
        [deck addCard:monster];
        
        //unique version of ability, which allows decks to have additional pierce cards, basically 100% efficiency of common, unique for having 2 abilities
        spell = [[SpellCardModel alloc] initWithIdNumber:103 type:cardTypeStandard];
        spell.name = @"Searing Decree";
        spell.element = elementFire;
        spell.rarity = cardRarityCommon;
        spell.cost = 1;
        
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityPierce castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationUntilEndOfTurn withValue:[NSNumber numberWithInt:3]]];
        spell.adminPhotoCheck = 1;
        [deck addCard:spell];
        
        //unique ability but poor stats distribution, lightning as similar (perma attack+)
        monster = [[MonsterCardModel alloc] initWithIdNumber:104 type:cardTypeStandard];
        monster.name = @"Hellfire Lumberjack";
        monster.element = elementFire;
        monster.damage = 4;
        monster.life = monster.maximumLife = 2;
        monster.cost = 1;
        monster.cooldown = monster.maximumCooldown = 1;
        monster.rarity = cardRarityUncommon;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnHit targetType:targetOneFriendlyMinion withDuration:durationUntilEndOfTurn withValue:[NSNumber numberWithInt:4]]];
        monster.adminPhotoCheck = 1;
        [deck addCard:monster];
        
        //unique target enemy only kill, would be 104% efficiency of common if target any, basically dark card
        spell = [[SpellCardModel alloc] initWithIdNumber:105 type:cardTypeStandard];
        spell.name = @"Reckoning";
        spell.element = elementFire;
        spell.rarity = cardRarityUncommon;
        spell.cost = 4;
        
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:7]]];
        spell.adminPhotoCheck = 1;
        [deck addCard:spell];
        
        //very poor stats distribution, but powerful unique ability
        monster = [[MonsterCardModel alloc] initWithIdNumber:106 type:cardTypeStandard];
        monster.name = @"Kindler Bowman";
        monster.element = elementFire;
        monster.damage = 6;
        monster.life = monster.maximumLife = 3;
        monster.cost = 3;
        monster.cooldown = monster.maximumCooldown = 1;
        monster.rarity = cardRarityUncommon;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnEndOfTurn targetType:targetOneEnemy withDuration:durationForever withValue:[NSNumber numberWithInt:6]]];
        monster.adminPhotoCheck = 1;
        [deck addCard:monster];
        
        //100% common efficiency, unique ability although equal to two light abilities (uncommon and exceptional), used to synergize with the fact that most fire cards have low health and high damage
        monster = [[MonsterCardModel alloc] initWithIdNumber:107 type:cardTypeStandard];
        monster.name = @"Flame Pheonix";
        monster.element = elementFire;
        monster.damage = 12;
        monster.life = monster.maximumLife = 7;
        monster.cost = 5;
        monster.cooldown = monster.maximumCooldown = 1;
        monster.rarity = cardRarityRare;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetAllMinion withDuration:durationForever withValue:[NSNumber numberWithInt:5]]];
        monster.adminPhotoCheck = 1;
        [deck addCard:monster];
        
        //106% efficiency of common, basically lightning card
        spell = [[SpellCardModel alloc] initWithIdNumber:108 type:cardTypeStandard];
        spell.name = @"Immolation";
        spell.element = elementFire;
        spell.rarity = cardRarityExceptional;
        spell.cost = 7;
        
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:14]]];

        spell.adminPhotoCheck = 1;
        [deck addCard:spell];
        
        //100% common efficiency, ice ability so won't count towards fire's max
        monster = [[MonsterCardModel alloc] initWithIdNumber:109 type:cardTypeStandard];
        monster.name = @"Inferno Lord";
        monster.element = elementFire;
        monster.damage = 20;
        monster.life = monster.maximumLife = 12;
        monster.cost = 9;
        monster.cooldown = monster.maximumCooldown = 1;
        monster.rarity = cardRarityRare;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnHit targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:8]]];
        monster.adminPhotoCheck = 1;
        [deck addCard:monster];
    }
    //ID 200 to 299
    else if (element == elementIce)
    {
        monster = [[MonsterCardModel alloc] initWithIdNumber:200 type:cardTypeStandard];
        monster.name = @"Ice Elf";
        monster.element = elementIce;
        monster.damage = 3;
        monster.life = monster.maximumLife = 5;
        monster.cost = 2;
        monster.cooldown = monster.maximumCooldown = 1;
        monster.rarity = cardRarityCommon;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
        monster.adminPhotoCheck = 1;
        [deck addCard:monster];
        
        spell = [[SpellCardModel alloc] initWithIdNumber:201 type:cardTypeStandard];
        spell.name = @"Glacial Twister";
        spell.element = elementIce;
        spell.rarity = cardRarityCommon;
        spell.cost = 3;
        
        //TODO maybe flip this with fire so they become unique cards
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:15]]];
        spell.adminPhotoCheck = 1;
        [deck addCard:spell];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:202 type:cardTypeStandard];
        monster.name = @"Kryocrius";
        monster.element = elementIce;
        monster.damage = 5;
        monster.life = monster.maximumLife = 13;
        monster.cost = 4;
        monster.cooldown = monster.maximumCooldown = 1;
        monster.rarity = cardRarityCommon;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:4]]];
        
        monster.adminPhotoCheck = 1;
        [deck addCard:monster];
        
        //unique for common to have 2 abilities
        spell = [[SpellCardModel alloc] initWithIdNumber:203 type:cardTypeStandard];
        spell.name = @"Noble Retainer";
        spell.element = elementIce;
        spell.rarity = cardRarityCommon;
        spell.cost = 1;
        
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:5]]];
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        
        spell.adminPhotoCheck = 1;
        [deck addCard:spell];
        
        //unique thunder ability, but relatively poor stat distribution
        monster = [[MonsterCardModel alloc] initWithIdNumber:204 type:cardTypeStandard];
        monster.name = @"Frost Panther";
        monster.element = elementIce;
        monster.damage = 4;
        monster.life = monster.maximumLife = 4;
        monster.cost = 1;
        monster.cooldown = monster.maximumCooldown = 1;
        monster.rarity = cardRarityUncommon;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAssassin castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        
        monster.adminPhotoCheck = 1;
        [deck addCard:monster];
        
        //effectively 100% efficiency for an uncommon card (extra points cant be used)
        spell = [[SpellCardModel alloc] initWithIdNumber:205 type:cardTypeStandard];
        spell.name = @"Arctic Tomb";
        spell.element = elementIce;
        spell.rarity = cardRarityUncommon;
        spell.cost = 4;
   
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:2]]];
        
        spell.adminPhotoCheck = 1;
        [deck addCard:spell];
        
        //exceptional ability on uncommon card
        monster = [[MonsterCardModel alloc] initWithIdNumber:206 type:cardTypeStandard];
        monster.name = @"Tundra Troll";
        monster.element = elementIce;
        monster.damage = 8;
        monster.life = monster.maximumLife = 9;
        monster.cost = 3;
        monster.cooldown = monster.maximumCooldown = 1;
        monster.rarity = cardRarityUncommon;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnHit targetType:targetVictimMinion withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
        
        monster.adminPhotoCheck = 1;
        [deck addCard:monster];
        
        //with non existing ability, deal damage to friendly hero on death
        monster = [[MonsterCardModel alloc] initWithIdNumber:207 type:cardTypeStandard];
        monster.name = @"Titanic Tortoise";
        monster.element = elementIce;
        monster.damage = 6;
        monster.life = monster.maximumLife = 21;
        monster.cost = 5;
        monster.cooldown = monster.maximumCooldown = 1;
        monster.rarity = cardRarityRare;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetHeroFriendly withDuration:durationForever withValue:[NSNumber numberWithInt:10]]];
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityKill castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        
        monster.adminPhotoCheck = 1;
        [deck addCard:monster];
        
        //poor efficiency, but unique earth ability for extra +cooldown stacking in a deck
        spell = [[SpellCardModel alloc] initWithIdNumber:208 type:cardTypeStandard];
        spell.name = @"Elf Wizards' Blessing";
        spell.element = elementIce;
        spell.rarity = cardRarityExceptional;
        spell.cost = 6;
        
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        
        spell.adminPhotoCheck = 1;
        [deck addCard:spell];
        
        //non existing ability (although roughly equal to +cd on summon with +cd on move), good point efficiency, but poor stat distribution
        monster = [[MonsterCardModel alloc] initWithIdNumber:209 type:cardTypeStandard];
        monster.name = @"Empress of Ice";
        monster.element = elementIce;
        monster.damage = 12;
        monster.life = monster.maximumLife = 8;
        monster.cost = 9;
        monster.cooldown = monster.maximumCooldown = 1;
        monster.rarity = cardRarityLegendary;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnEndOfTurn targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
        
        monster.adminPhotoCheck = 1;
        [deck addCard:monster];
    }
    
    return deck;
}

+(CardModel*) getCampaignCardWithFullID:(NSString*)cardID
{
    return [[CardModel alloc] initWithCardModel:campaignCards[cardID]];
}

@end
