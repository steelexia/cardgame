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


+(MonsterCardModel*) getCampaignBossWithID:(NSString*)levelID
{
    MonsterCardModel*monster;
    
    if ([levelID isEqualToString:@"d_1_c_1_l_4"])
    {
        monster = [[MonsterCardModel alloc] initWithIdNumber:1400 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityLegendary;
        monster.element = elementFire;
        monster.name = @"Dragon Boss";
        monster.damage = 1600;
        monster.life = monster.maximumLife = 25000;
        monster.cost = 10;
        monster.cooldown = monster.maximumCooldown = 2;
        monster.heroic = YES;
        
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityHeroic castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAssassin castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:200]]];
        
        return monster;
    }
    else if ([levelID isEqualToString:@"d_1_c_2_l_4"])
    {
        
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
    }
    else if ([levelID isEqualToString:@"d_2_c_2_l_4"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_2_c_3_l_4"])
    {
        
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
        monster = [[MonsterCardModel alloc] initWithIdNumber:1000 type:cardTypeSinglePlayer];
        monster.name = @"Goblin Fighter";
        monster.damage = 1200;
        monster.life = monster.maximumLife = 900;
        monster.cost = 1;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
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
        
        //turn 2
        monster = [[MonsterCardModel alloc] initWithIdNumber:1003 type:cardTypeSinglePlayer];
        monster.name = @"Goblin Raider";
        monster.damage = 1600;
        monster.life = monster.maximumLife = 1400;
        monster.cost = 2;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
        //turn 3 shows taunt ability
        monster = [[MonsterCardModel alloc] initWithIdNumber:1002 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityUncommon;
        monster.name = @"Goblin Spearman";
        monster.damage = 900;
        monster.life = monster.maximumLife = 3800;
        monster.cost = 3;
        monster.cooldown = monster.maximumCooldown = 1;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        
        [deck addCard:monster];

        //turn 4
        monster = [[MonsterCardModel alloc] initWithIdNumber:1001 type:cardTypeSinglePlayer];
        monster.name = @"Goblin Skirmisher";
        monster.damage = 600;
        monster.life = monster.maximumLife = 1800;
        monster.cost = 2;
        monster.cooldown = monster.maximumCooldown = 1;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1200]]];
        
        [deck addCard:monster];
        
        //turn 4
        monster = [[MonsterCardModel alloc] initWithIdNumber:1003 type:cardTypeSinglePlayer];
        monster.name = @"Goblin Raider";
        monster.damage = 1600;
        monster.life = monster.maximumLife = 1400;
        monster.cost = 2;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
        //turn 5
        monster = [[MonsterCardModel alloc] initWithIdNumber:1004 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityUncommon;
        monster.name = @"Goblin Petard";
        monster.damage = 600;
        monster.life = monster.maximumLife = 1000;
        monster.cost = 4;
        monster.cooldown = monster.maximumCooldown = 1;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:600]]];
        
        [deck addCard:monster];

        //turn 6
        monster = [[MonsterCardModel alloc] initWithIdNumber:1001 type:cardTypeSinglePlayer];
        monster.name = @"Goblin Skirmisher";
        monster.damage = 600;
        monster.life = monster.maximumLife = 1800;
        monster.cost = 2;
        monster.cooldown = monster.maximumCooldown = 1;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1200]]];
        
        [deck addCard:monster];
        
        //turn 6
        monster = [[MonsterCardModel alloc] initWithIdNumber:1005 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityRare;
        monster.name = @"Goblin Commander";
        monster.damage = 1800;
        monster.life = monster.maximumLife = 3000;
        monster.cost = 5;
        monster.cooldown = monster.maximumCooldown = 2;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:500]]];
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:500]]];
        
        [deck addCard:monster];
        
        //turn 7
        monster = [[MonsterCardModel alloc] initWithIdNumber:1006 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityUncommon;
        monster.element = elementLight;
        monster.name = @"Goblin Shaman";
        monster.damage = 1800;
        monster.life = monster.maximumLife = 3200;
        monster.cost = 5;
        monster.cooldown = monster.maximumCooldown = 2;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnMove targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:500]]];
        
        [deck addCard:monster];
        
        //should have finished the AI off at this point, rest are just weak cards
        for (int i = 0; i < 3; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1000 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Fighter";
            monster.damage = 1200;
            monster.life = monster.maximumLife = 900;
            monster.cost = 1;
            monster.cooldown = monster.maximumCooldown = 1;
            
            [deck addCard:monster];
            
            monster = [[MonsterCardModel alloc] initWithIdNumber:1001 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Skirmisher";
            monster.damage = 600;
            monster.life = monster.maximumLife = 1800;
            monster.cost = 2;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1200]]];
            
            [deck addCard:monster];
            
            monster = [[MonsterCardModel alloc] initWithIdNumber:1003 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Raider";
            monster.damage = 1600;
            monster.life = monster.maximumLife = 1400;
            monster.cost = 2;
            monster.cooldown = monster.maximumCooldown = 1;
            
            [deck addCard:monster];
        }
    }
    else if ([levelID isEqualToString:@"d_1_c_1_l_2"])
    {
        //turn 1
        monster = [[MonsterCardModel alloc] initWithIdNumber:1000 type:cardTypeSinglePlayer];
        monster.name = @"Goblin Fighter";
        monster.damage = 1200;
        monster.life = monster.maximumLife = 900;
        monster.cost = 1;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
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
        spell = [[SpellCardModel alloc] initWithIdNumber:1007 type:cardTypeSinglePlayer];
        spell.element = elementNeutral;
        spell.name = @"Harrassment";
        spell.cost = 2;
        
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:800]]];
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
        
        [deck addCard:spell];
        
        //turn 3
        monster = [[MonsterCardModel alloc] initWithIdNumber:1101 type:cardTypeSinglePlayer];
        monster.element = elementDark;
        monster.name = @"Generic Zombie"; //TODO name
        monster.damage = 1600;
        monster.life = monster.maximumLife = 1800;
        monster.cost = 3;
        monster.cooldown = monster.maximumCooldown = 1;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityFracture castType:castOnDeath targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
        
        [deck addCard:monster];
        
        //turn 4
        monster = [[MonsterCardModel alloc] initWithIdNumber:1102 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityUncommon;
        monster.element = elementDark;
        monster.name = @"Obnoxinator"; //TODO name
        monster.damage = 2200;
        monster.life = monster.maximumLife = 4000;
        monster.cost = 4;
        monster.cooldown = monster.maximumCooldown = 1;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        
        [deck addCard:monster];
        
        //turn 5
        monster = [[MonsterCardModel alloc] initWithIdNumber:1003 type:cardTypeSinglePlayer];
        monster.name = @"Goblin Raider";
        monster.damage = 1600;
        monster.life = monster.maximumLife = 1400;
        monster.cost = 2;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
        //turn 5
        monster = [[MonsterCardModel alloc] initWithIdNumber:1001 type:cardTypeSinglePlayer];
        monster.name = @"Goblin Skirmisher";
        monster.damage = 600;
        monster.life = monster.maximumLife = 1800;
        monster.cost = 2;
        monster.cooldown = monster.maximumCooldown = 1;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1200]]];
        
        //turn 6
        monster = [[MonsterCardModel alloc] initWithIdNumber:1100 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityRare;
        monster.element = elementDark;
        monster.name = @"Headslayer"; //TODO name
        monster.damage = 4500;
        monster.life = monster.maximumLife = 4300;
        monster.cost = 6;
        monster.cooldown = monster.maximumCooldown = 1;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityPierce castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        
        [deck addCard:monster];
        
        //turn 7
        spell = [[SpellCardModel alloc] initWithIdNumber:1008 type:cardTypeSinglePlayer];
        spell.rarity = cardRarityUncommon;
        spell.element = elementDark;
        spell.name = @"Supply Theft";
        spell.cost = 4;
        
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:3200]]];
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:800]]];
        
        [deck addCard:spell];
        
        //should be over around here, rest are just generic cards
        
        spell = [[SpellCardModel alloc] initWithIdNumber:1103 type:cardTypeSinglePlayer];
        spell.rarity = cardRarityRare;
        spell.element = elementDark;
        spell.name = @"Soul Sip";
        spell.cost = 7;
        
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:5000]]];
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:500]]];
        
        [deck addCard:spell];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:1102 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityUncommon;
        monster.element = elementDark;
        monster.name = @"Obnoxinator"; //TODO name
        monster.damage = 2200;
        monster.life = monster.maximumLife = 4000;
        monster.cost = 4;
        monster.cooldown = monster.maximumCooldown = 1;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        
        [deck addCard:monster];
        
        spell = [[SpellCardModel alloc] initWithIdNumber:1009 type:cardTypeSinglePlayer];
        spell.rarity = cardRarityRare;
        spell.element = elementNeutral;
        spell.name = @"Frenzied Swarm";
        spell.cost = 4;
        
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
        
        [deck addCard:spell];
        
        for (int i = 0; i < 3; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1101 type:cardTypeSinglePlayer];
            monster.element = elementDark;
            monster.name = @"Generic Zombie"; //TODO name
            monster.damage = 1600;
            monster.life = monster.maximumLife = 1800;
            monster.cost = 3;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityFracture castType:castOnDeath targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
            
            [deck addCard:monster];
            
            monster = [[MonsterCardModel alloc] initWithIdNumber:1001 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Skirmisher";
            monster.damage = 600;
            monster.life = monster.maximumLife = 1800;
            monster.cost = 2;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1200]]];
            
            [deck addCard:monster];
            
            monster = [[MonsterCardModel alloc] initWithIdNumber:1003 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Raider";
            monster.damage = 1600;
            monster.life = monster.maximumLife = 1400;
            monster.cost = 2;
            monster.cooldown = monster.maximumCooldown = 1;
            
            [deck addCard:monster];
        }
    }
    else if ([levelID isEqualToString:@"d_1_c_1_l_3"])
    {
        //no card played on turn 1 just for some variation
        
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1003 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Raider";
            monster.damage = 1600;
            monster.life = monster.maximumLife = 1400;
            monster.cost = 2;
            monster.cooldown = monster.maximumCooldown = 1;
            
            [deck addCard:monster];
        }
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:1200 type:cardTypeSinglePlayer];
        monster.element = elementFire;
        monster.rarity = cardRarityRare;
        monster.name = @"Dragon 1";
        monster.damage = 3100;
        monster.life = monster.maximumLife = 4200;
        monster.cost = 5;
        monster.cooldown = monster.maximumCooldown = 1;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:500]]];
        
        [deck addCard:monster];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:1201 type:cardTypeSinglePlayer];
        monster.element = elementFire;
        monster.rarity = cardRarityRare;
        monster.name = @"Dragon 2";
        monster.damage = 1900;
        monster.life = monster.maximumLife = 6200;
        monster.cost = 7;
        monster.cooldown = monster.maximumCooldown = 2;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnHit targetType:targetVictimMinion withDuration:durationForever withValue:[NSNumber numberWithInt:1200]]];
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnHit targetType:targetAllEnemy withDuration:durationForever withValue:[NSNumber numberWithInt:800]]];
        
        [deck addCard:monster];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:1001 type:cardTypeSinglePlayer];
        monster.name = @"Goblin Skirmisher";
        monster.damage = 600;
        monster.life = monster.maximumLife = 1800;
        monster.cost = 2;
        monster.cooldown = monster.maximumCooldown = 1;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1200]]];
        
        [deck addCard:monster];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:1002 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityUncommon;
        monster.name = @"Goblin Spearman";
        monster.damage = 900;
        monster.life = monster.maximumLife = 3800;
        monster.cost = 3;
        monster.cooldown = monster.maximumCooldown = 1;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        
        [deck addCard:monster];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:1001 type:cardTypeSinglePlayer];
        monster.name = @"Goblin Skirmisher";
        monster.damage = 600;
        monster.life = monster.maximumLife = 1800;
        monster.cost = 2;
        monster.cooldown = monster.maximumCooldown = 1;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1200]]];
        
        [deck addCard:monster];
        
        spell = [[SpellCardModel alloc] initWithIdNumber:1009 type:cardTypeSinglePlayer];
        spell.rarity = cardRarityRare;
        spell.element = elementNeutral;
        spell.name = @"Frenzied Swarm";
        spell.cost = 4;
        
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
        
        [deck addCard:spell];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:1005 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityRare;
        monster.name = @"Goblin Commander";
        monster.damage = 1800;
        monster.life = monster.maximumLife = 3000;
        monster.cost = 5;
        monster.cooldown = monster.maximumCooldown = 2;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:500]]];
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:500]]];
        
        [deck addCard:monster];
        
        spell = [[SpellCardModel alloc] initWithIdNumber:1007 type:cardTypeSinglePlayer];
        spell.element = elementNeutral;
        spell.name = @"Harrassment";
        spell.cost = 2;
        
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:800]]];
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
        
        [deck addCard:spell];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:1002 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityUncommon;
        monster.name = @"Goblin Spearman";
        monster.damage = 900;
        monster.life = monster.maximumLife = 3800;
        monster.cost = 3;
        monster.cooldown = monster.maximumCooldown = 1;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
        
        [deck addCard:monster];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:1005 type:cardTypeSinglePlayer];
        monster.rarity = cardRarityRare;
        monster.name = @"Goblin Commander";
        monster.damage = 1800;
        monster.life = monster.maximumLife = 3000;
        monster.cost = 5;
        monster.cooldown = monster.maximumCooldown = 2;
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:500]]];
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:500]]];
        
        [deck addCard:monster];
        
        spell = [[SpellCardModel alloc] initWithIdNumber:1007 type:cardTypeSinglePlayer];
        spell.element = elementNeutral;
        spell.name = @"Harrassment";
        spell.cost = 2;
        
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:800]]];
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
        
        [deck addCard:spell];
        
        for (int i = 0; i < 3; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1002 type:cardTypeSinglePlayer];
            monster.rarity = cardRarityUncommon;
            monster.name = @"Goblin Spearman";
            monster.damage = 900;
            monster.life = monster.maximumLife = 3800;
            monster.cost = 3;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
            
            [deck addCard:monster];
            
            monster = [[MonsterCardModel alloc] initWithIdNumber:1001 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Skirmisher";
            monster.damage = 600;
            monster.life = monster.maximumLife = 1800;
            monster.cost = 2;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1200]]];
            
            [deck addCard:monster];
            
            monster = [[MonsterCardModel alloc] initWithIdNumber:1003 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Raider";
            monster.damage = 1600;
            monster.life = monster.maximumLife = 1400;
            monster.cost = 2;
            monster.cooldown = monster.maximumCooldown = 1;
            
            [deck addCard:monster];
        }
    }
    else if ([levelID isEqualToString:@"d_1_c_1_l_4"])
    {
        for (int i = 0; i < 12; i++)
        {
            spell = [[SpellCardModel alloc] initWithIdNumber:1401 type:cardTypeSinglePlayer];
            spell.element = elementNeutral;
            spell.name = @"Bite";
            spell.cost = 3;
            
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:1900]]];
            
            [deck addCard:spell];
        }
        
        for (int i = 0; i < 6; i++)
        {
            spell = [[SpellCardModel alloc] initWithIdNumber:1402 type:cardTypeSinglePlayer];
            spell.element = elementNeutral;
            spell.name = @"Roar";
            spell.cost = 5;
            
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:3000]]];
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:500]]];
            
            [deck addCard:spell];
        }
        
        for (int i = 0; i < 8; i++)
        {
            spell = [[SpellCardModel alloc] initWithIdNumber:1403 type:cardTypeSinglePlayer];
            spell.element = elementFire;
            spell.name = @"Fire Breath";
            spell.cost = 7;
            
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:1900]]];
            
            [deck addCard:spell];
        }
        
        for (int i = 0; i < 3; i++)
        {
            spell = [[SpellCardModel alloc] initWithIdNumber:1404 type:cardTypeSinglePlayer];
            spell.element = elementFire;
            spell.name = @"Dragon Blast";
            spell.cost = 8;
            
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:5100]]];
            
            [deck addCard:spell];
        }
    }
    //----chapter 2----//
    else if ([levelID isEqualToString:@"d_1_c_2_l_1"])
    {
    }
    else if ([levelID isEqualToString:@"d_1_c_2_l_2"])
    {
    }
    else if ([levelID isEqualToString:@"d_1_c_2_l_3"])
    {
    }
    else if ([levelID isEqualToString:@"d_1_c_2_l_4"])
    {
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
    if ([levelID isEqualToString:@"d_2_c_1_l_1"])
    {
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1000 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Fighter";
            monster.damage = 2200;
            monster.life = monster.maximumLife = 1800;
            monster.cost = 1;
            monster.cooldown = monster.maximumCooldown = 1;
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1001 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Skirmisher";
            monster.damage = 900;
            monster.life = monster.maximumLife = 2200;
            monster.cost = 2;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1800]]];
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1002 type:cardTypeSinglePlayer];
            monster.rarity = cardRarityUncommon;
            monster.name = @"Goblin Spearman";
            monster.damage = 1400;
            monster.life = monster.maximumLife = 4800;
            monster.cost = 3;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:[NSNumber numberWithInt:3500]]];
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1003 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Raider";
            monster.damage = 2800;
            monster.life = monster.maximumLife = 3100;
            monster.cost = 3;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddResource castType:castOnHit targetType:targetHeroFriendly withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1004 type:cardTypeSinglePlayer];
            monster.rarity = cardRarityUncommon;
            monster.name = @"Goblin Petard";
            monster.damage = 800;
            monster.life = monster.maximumLife = 1200;
            monster.cost = 4;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:2000]]];
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1005 type:cardTypeSinglePlayer];
            monster.rarity = cardRarityRare;
            monster.name = @"Goblin Commander";
            monster.damage = 2100;
            monster.life = monster.maximumLife = 3700;
            monster.cost = 5;
            monster.cooldown = monster.maximumCooldown = 2;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1000]]];
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1000]]];
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
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
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
            spell = [[SpellCardModel alloc] initWithIdNumber:1007 type:cardTypeSinglePlayer];
            spell.element = elementNeutral;
            spell.name = @"Harrassment";
            spell.cost = 2;
            
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1000]]];
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
            
            [deck addCard:spell];
        }
        
        for (int i = 0; i < 2; i++)
        {
            spell = [[SpellCardModel alloc] initWithIdNumber:1008 type:cardTypeSinglePlayer];
            spell.rarity = cardRarityUncommon;
            spell.element = elementDark;
            spell.name = @"Supply Theft";
            spell.cost = 3;
            
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:4200]]];
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1100]]];
            
            [deck addCard:spell];
        }
        
        for (int i = 0; i < 2; i++)
        {
            spell = [[SpellCardModel alloc] initWithIdNumber:1009 type:cardTypeSinglePlayer];
            spell.rarity = cardRarityRare;
            spell.element = elementNeutral;
            spell.name = @"Frenzied Swarm";
            spell.cost = 4;
            
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllMinion withDuration:durationUntilEndOfTurn withValue:[NSNumber numberWithInt:2000]]];
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
            
            
            [deck addCard:spell];
        }
    }
    else if ([levelID isEqualToString:@"d_2_c_1_l_2"])
    {
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1000 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Fighter";
            monster.damage = 2200;
            monster.life = monster.maximumLife = 1800;
            monster.cost = 1;
            monster.cooldown = monster.maximumCooldown = 1;
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1001 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Skirmisher";
            monster.damage = 900;
            monster.life = monster.maximumLife = 2200;
            monster.cost = 2;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1800]]];
            
            [deck addCard:monster];
        }
        
        /*
         for (int i = 0; i < 2; i++)
         {
         monster = [[MonsterCardModel alloc] initWithIdNumber:1002 type:cardTypeSinglePlayer];
         monster.name = @"Goblin Spearman";
         monster.damage = 1400;
         monster.life = monster.maximumLife = 4800;
         monster.cost = 3;
         monster.cooldown = monster.maximumCooldown = 1;
         [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:[NSNumber numberWithInt:3500]]];
         
         [deck addCard:monster];
         }
         */
        
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1003 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Raider";
            monster.damage = 2800;
            monster.life = monster.maximumLife = 3100;
            monster.cost = 3;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddResource castType:castOnHit targetType:targetHeroFriendly withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1004 type:cardTypeSinglePlayer];
            monster.rarity = cardRarityUncommon;
            monster.name = @"Goblin Petard";
            monster.damage = 800;
            monster.life = monster.maximumLife = 1200;
            monster.cost = 4;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:2000]]];
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
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
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
            spell = [[SpellCardModel alloc] initWithIdNumber:1007 type:cardTypeSinglePlayer];
            spell.element = elementNeutral;
            spell.name = @"Harrassment";
            spell.cost = 2;
            
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1000]]];
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
            
            [deck addCard:spell];
        }
        
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1100 type:cardTypeSinglePlayer];
            monster.rarity = cardRarityRare;
            monster.element = elementDark;
            monster.name = @"Headslayer"; //TODO name
            monster.damage = 6500;
            monster.life = monster.maximumLife = 6300;
            monster.cost = 6;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityPierce castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
            
            [deck addCard:monster];
        }
        
        //maybe
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1101 type:cardTypeSinglePlayer];
            monster.element = elementDark;
            monster.name = @"Generic Zombie"; //TODO name
            monster.damage = 2600;
            monster.life = monster.maximumLife = 2800;
            monster.cost = 4;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityFracture castType:castOnDeath targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
            
            [deck addCard:monster];
        }
        
        //taunt for tutorial, really needed
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1102 type:cardTypeSinglePlayer];
            monster.rarity = cardRarityUncommon;
            monster.element = elementDark;
            monster.name = @"Obnoxinator"; //TODO name
            monster.damage = 2800;
            monster.life = monster.maximumLife = 5800;
            monster.cost = 4;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
            spell = [[SpellCardModel alloc] initWithIdNumber:1103 type:cardTypeSinglePlayer];
            spell.rarity = cardRarityRare;
            spell.element = elementDark;
            spell.name = @"Soul Sip";
            spell.cost = 6;
            
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:2000]]];
            
            [deck addCard:spell];
        }
    }
    else if ([levelID isEqualToString:@"d_2_c_1_l_3"])
    {
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1000 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Fighter";
            monster.damage = 2200;
            monster.life = monster.maximumLife = 1800;
            monster.cost = 1;
            monster.cooldown = monster.maximumCooldown = 1;
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1001 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Skirmisher";
            monster.damage = 900;
            monster.life = monster.maximumLife = 2200;
            monster.cost = 2;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1800]]];
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1003 type:cardTypeSinglePlayer];
            monster.name = @"Goblin Raider";
            monster.damage = 2800;
            monster.life = monster.maximumLife = 3100;
            monster.cost = 3;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddResource castType:castOnHit targetType:targetHeroFriendly withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1004 type:cardTypeSinglePlayer];
            monster.rarity = cardRarityUncommon;
            monster.name = @"Goblin Petard";
            monster.damage = 800;
            monster.life = monster.maximumLife = 1200;
            monster.cost = 4;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:2000]]];
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1005 type:cardTypeSinglePlayer];
            monster.rarity = cardRarityRare;
            monster.name = @"Goblin Commander";
            monster.damage = 2100;
            monster.life = monster.maximumLife = 3700;
            monster.cost = 5;
            monster.cooldown = monster.maximumCooldown = 2;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1000]]];
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1000]]];
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
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
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
            spell = [[SpellCardModel alloc] initWithIdNumber:1007 type:cardTypeSinglePlayer];
            spell.element = elementNeutral;
            spell.name = @"Harrassment";
            spell.cost = 2;
            
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1000]]];
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
            
            [deck addCard:spell];
        }
        
        for (int i = 0; i < 2; i++)
        {
            spell = [[SpellCardModel alloc] initWithIdNumber:1008 type:cardTypeSinglePlayer];
            spell.rarity = cardRarityUncommon;
            spell.element = elementDark;
            spell.name = @"Supply Theft";
            spell.cost = 3;
            
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:4200]]];
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1100]]];
            
            [deck addCard:spell];
        }
        
        
        for (int i = 0; i < 2; i++)
        {
            monster = [[MonsterCardModel alloc] initWithIdNumber:1200 type:cardTypeSinglePlayer];
            monster.element = elementFire;
            monster.rarity = cardRarityRare;
            monster.name = @"Dragon 1";
            monster.damage = 4100;
            monster.life = monster.maximumLife = 4900;
            monster.cost = 5;
            monster.cooldown = monster.maximumCooldown = 1;
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
            [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1500]]];
            
            [deck addCard:monster];
        }
        
        for (int i = 0; i < 2; i++)
        {
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
            
            [deck addCard:monster];
        }
    }
    else if ([levelID isEqualToString:@"d_2_c_1_l_4"])
    {
        for (int i = 0; i < 12; i++)
        {
            spell = [[SpellCardModel alloc] initWithIdNumber:1401 type:cardTypeSinglePlayer];
            spell.element = elementNeutral;
            spell.name = @"Bite";
            spell.cost = 3;
            
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:4200]]];
            
            [deck addCard:spell];
        }
        
        for (int i = 0; i < 6; i++)
        {
            spell = [[SpellCardModel alloc] initWithIdNumber:1402 type:cardTypeSinglePlayer];
            spell.element = elementNeutral;
            spell.name = @"Roar";
            spell.cost = 5;
            
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:5600]]];
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1600]]];
            
            [deck addCard:spell];
        }
        
        for (int i = 0; i < 8; i++)
        {
            spell = [[SpellCardModel alloc] initWithIdNumber:1403 type:cardTypeSinglePlayer];
            spell.element = elementFire;
            spell.name = @"Fire Breath";
            spell.cost = 7;
            
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:3200]]];
            
            [deck addCard:spell];
        }
        
        for (int i = 0; i < 3; i++)
        {
            spell = [[SpellCardModel alloc] initWithIdNumber:1404 type:cardTypeSinglePlayer];
            spell.element = elementFire;
            spell.name = @"Dragon Blast";
            spell.cost = 8;
            
            [spell addBaseAbility: [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
            
            [deck addCard:spell];
        }
    }
    //----chapter 2----//
    else if ([levelID isEqualToString:@"d_2_c_2_l_1"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_2_c_2_l_2"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_2_c_2_l_3"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_2_c_2_l_4"])
    {
        
    }
    //----chapter 3----//
    else if ([levelID isEqualToString:@"d_2_c_3_l_1"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_2_c_3_l_2"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_2_c_3_l_3"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_2_c_3_l_4"])
    {
        
    }
    //------------difficulty 3------------//
    //----chapter 1----//
    if ([levelID isEqualToString:@"d_3_c_1_l_1"])
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
    else
    {
        NSLog(@"WARNING: Invalid Campaign Deck ID.");
    }
    
    return deck;
}

+(DeckModel*) getPlayerCampaignDeckWithID:(NSString*)levelID
{
    DeckModel *deck = [[DeckModel alloc] init];
    
    MonsterCardModel*monster;
    SpellCardModel*spell;
    
    //----chapter 1----//
    if ([levelID isEqualToString:@"d_1_c_1_l_1"])
    {
        monster = [[MonsterCardModel alloc] initWithIdNumber:900000 type:cardTypeSinglePlayer];
        monster.name = @"Custom Card";
        monster.damage = 1400;
        monster.life = monster.maximumLife = 2600;
        monster.cost = 1;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:900002 type:cardTypeSinglePlayer];
        monster.name = @"Card 1";
        monster.damage = 2100;
        monster.life = monster.maximumLife = 2900;
        monster.cost = 2;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:900003 type:cardTypeSinglePlayer];
        monster.name = @"Card 2";
        monster.damage = 3900;
        monster.life = monster.maximumLife = 3000;
        monster.cost = 3;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:900004 type:cardTypeSinglePlayer];
        monster.name = @"Card 3";
        monster.damage = 4100;
        monster.life = monster.maximumLife = 4700;
        monster.cost = 4;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:900005 type:cardTypeSinglePlayer];
        monster.name = @"Card 4";
        monster.damage = 4800;
        monster.life = monster.maximumLife = 5600;
        monster.cost = 5;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:900006 type:cardTypeSinglePlayer];
        monster.name = @"Card 5";
        monster.damage = 2500;
        monster.life = monster.maximumLife = 6100;
        monster.cost = 4;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
    }
    else if ([levelID isEqualToString:@"d_1_c_1_l_2"])
    {
        monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
        monster.name = @"Custom Card Stats Vary";
        monster.damage = 6000;
        monster.life = monster.maximumLife = 6000;
        monster.cost = 5;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:900001 type:cardTypeSinglePlayer];
        monster.name = @"Card 0";
        monster.damage = 1200;
        monster.life = monster.maximumLife = 1800;
        monster.cost = 1;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:900002 type:cardTypeSinglePlayer];
        monster.name = @"Card 1";
        monster.damage = 2100;
        monster.life = monster.maximumLife = 2900;
        monster.cost = 2;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:900005 type:cardTypeSinglePlayer];
        monster.name = @"Card 4";
        monster.damage = 4800;
        monster.life = monster.maximumLife = 5600;
        monster.cost = 5;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:900006 type:cardTypeSinglePlayer];
        monster.name = @"Card 5";
        monster.damage = 2500;
        monster.life = monster.maximumLife = 6100;
        monster.cost = 4;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
        spell = [[SpellCardModel alloc] initWithIdNumber:1404 type:cardTypeSinglePlayer];
        spell.name = @"Spell";
        spell.cost = 3;
        
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:3200]]];
        
        [deck addCard:spell];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:900003 type:cardTypeSinglePlayer];
        monster.name = @"Card 2";
        monster.damage = 3900;
        monster.life = monster.maximumLife = 3000;
        monster.cost = 3;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
        monster = [[MonsterCardModel alloc] initWithIdNumber:900004 type:cardTypeSinglePlayer];
        monster.name = @"Card 3";
        monster.damage = 4100;
        monster.life = monster.maximumLife = 4700;
        monster.cost = 4;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
        spell = [[SpellCardModel alloc] initWithIdNumber:1404 type:cardTypeSinglePlayer];
        spell.name = @"Spell";
        spell.cost = 2;
        
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:1700]]];
        [spell addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
        
        [deck addCard:spell];
    }
    else if ([levelID isEqualToString:@"d_1_c_1_l_3"])
    {
        
    }
    else if ([levelID isEqualToString:@"d_1_c_1_l_4"])
    {
        
    }
    else
        return nil;
    
    return deck;
}

+(DeckModel*) getDeckOne
{
    DeckModel *deck = [[DeckModel alloc] init];
    
    //WARNING: for convenience right now, all cards' abilities array stores PFObjects for testing stuff
    
    MonsterCardModel* monster;
    SpellCardModel* spell;
    
    /*
     for (int i = 0; i < 10; i++)
     {
     monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
     monster.name = @"Monster";
     monster.life = monster.maximumLife = 1500;
     monster.damage = 1000;
     monster.cost = 1;
     monster.cooldown = monster.maximumCooldown = 1;
     
     [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt
     castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
     
     [deck addCard:monster];
     
     monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
     monster.name = @"Monster";
     monster.life = monster.maximumLife = 1500;
     monster.damage = 1000;
     monster.cost = 1;
     monster.cooldown = monster.maximumCooldown = 1;
     
     [deck addCard:monster];
     
     spell = [[SpellCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
     spell.name = @"Spell";
     spell.cost = 1;
     
     [spell.abilities addObject: [[Ability alloc] initWithType:abilityAddLife
     castType:castOnSummon targetType:targetOneFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:5000]]];
     
     [deck addCard:spell];
     }
     */
    /*
    for (int i = 0; i < 10; i++){
        monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
        monster.name = @"Monster";
        monster.life = monster.maximumLife = 1500;
        monster.damage = 1800;
        monster.cost = 2;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [monster addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnDeath targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
        
        [deck addCard:monster];
    }*/
    
    //---minions---//
    //cost 1
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10000 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 800;
    monster.damage = 1200;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10001 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 1500;
    monster.damage = 1500;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10002 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 2200;
    monster.damage = 3000;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:3000]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10003 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 500;
    monster.damage = 1200;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10004 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 500;
    monster.damage = 3000;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 2;
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10005 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 1500;
    monster.damage = 800;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:1000]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10006 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 800;
    monster.damage = 1400;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10007 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 4000;
    monster.damage = 0;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [deck addCard:monster];
    
    //cost 2
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10008 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 2000;
    monster.damage = 3200;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10009 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 1500;
    monster.damage = 1800;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnDeath targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10010 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 800;
    monster.damage = 3000;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10011 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 2100;
    monster.damage = 1200;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnDeath targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10012 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 2500;
    monster.damage = 3500;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10013 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 1000;
    monster.damage = 2000;
    monster.cost = 2;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAssassin castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard:monster];
    
    //cost 3
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10014 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 3500;
    monster.damage = 2500;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10015 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 2200;
    monster.damage = 1800;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1000]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10016 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 3500;
    monster.damage = 2500;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 2;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:1000]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:1000]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10017 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 1000;
    monster.damage = 5000;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10018 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 4000;
    monster.damage = 2500;
    monster.cost = 3;
    monster.cooldown = monster.maximumCooldown = 2;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1000]]];
    
    [deck addCard:monster];

    //cost 4
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10019 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 5500;
    monster.damage = 4000;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10020 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 4000;
    monster.damage = 3500;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1500]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10021 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 6500;
    monster.damage = 2500;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 2;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10022 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 2600;
    monster.damage = 2000;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:500]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:2000]]];
    
    [deck addCard:monster];
    
    //cost 5
    monster = [[MonsterCardModel alloc] initWithIdNumber:10023 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 4500;
    monster.damage = 4800;
    monster.cost = 4;
    monster.cooldown = monster.maximumCooldown = 2;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAll withDuration:durationInstant withValue:[NSNumber numberWithInt:2000]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10024 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 5200;
    monster.damage = 4800;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 2;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetAllFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:2500]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10025 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 7500;
    monster.damage = 1200;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:2500]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10026 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 4500;
    monster.damage = 5500;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 2;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAssassin castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [deck addCard:monster];
    
    //cost 6
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10027 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 7800;
    monster.damage = 5500;
    monster.cost = 6;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10028 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 5200;
    monster.damage = 4400;
    monster.cost = 6;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10029 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 5500;
    monster.damage = 0;
    monster.cost = 6;
    monster.cooldown = monster.maximumCooldown = 2;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnMove targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnMove targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:1500]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10030 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 8500;
    monster.damage = 1000;
    monster.cost = 6;
    monster.cooldown = monster.maximumCooldown = 2;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityKill castType:castOnHit targetType:targetVictimMinion withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard:monster];
    
    //cost 7
    monster = [[MonsterCardModel alloc] initWithIdNumber:10031 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 4500;
    monster.damage = 4600;
    monster.cost = 7;
    monster.cooldown = monster.maximumCooldown = 2;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:5000]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10032 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 7800;
    monster.damage = 3500;
    monster.cost = 7;
    monster.cooldown = monster.maximumCooldown = 2;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnHit targetType:targetAllEnemy withDuration:durationForever withValue:[NSNumber numberWithInt:1500]]];
    
    [deck addCard:monster];
    
    //cost 8
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10033 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 6800;
    monster.damage = 6500;
    monster.cost = 8;
    monster.cooldown = monster.maximumCooldown = 2;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnEndOfTurn targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1000]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnEndOfTurn targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1000]]];
    
    [deck addCard:monster];
    
    //cost 9
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10034 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 12000;
    monster.damage = 9000;
    monster.cost = 9;
    monster.cooldown = monster.maximumCooldown = 2;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetAllMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:3]]];
    
    [deck addCard:monster];
    
    
    //spell cards
    
    //cost 0
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10035 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 0;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddResource castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:2]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10036 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 0;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:2]]];
    
    [deck addCard: spell];
    
    //cost 1
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10037 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 1;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:1000]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:1500]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10038 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 1;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:2]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10039 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 1;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:2000]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10040 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 1;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:2]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10041 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 1;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetHeroEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:3000]]];
    
    [deck addCard: spell];

    spell = [[SpellCardModel alloc] initWithIdNumber:10042 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 1;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:3000]]];
    
    [deck addCard: spell];
    
    //cost 2
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10043 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 2;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:5000]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10044 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 2;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1000]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10045 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 2;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:2000]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:1500]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10046 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 2;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:3000]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10047 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 2;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1000]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10048 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 2;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:5000]]];
    
    [deck addCard: spell];
    
    //cost 3
    spell = [[SpellCardModel alloc] initWithIdNumber:10049 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 3;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10050 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 3;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationUntilEndOfTurn withValue:[NSNumber numberWithInt:2000]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10051 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 3;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:2]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10052 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 3;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:8000]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10053 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 3;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetAllMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard: spell];
    
    //cost 4
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10054 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 4;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10055 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 4;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneAny withDuration:durationInstant withValue:[NSNumber numberWithInt:6000]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10056 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 4;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAll withDuration:durationInstant withValue:[NSNumber numberWithInt:3000]]];
    
    [deck addCard: spell];
    
    //cost 5
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10057 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 5;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10058 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 5;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard: spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:10059 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 5;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:8000]]];
    
    [deck addCard: spell];
    
    //cost 6
    spell = [[SpellCardModel alloc] initWithIdNumber:10060 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 6;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetAllFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:3000]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:2]]];
    
    [deck addCard: spell];
    
    //cost 7
    spell = [[SpellCardModel alloc] initWithIdNumber:10061 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 7;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnSummon targetType:targetAllMinion withDuration:durationForever withValue:[NSNumber numberWithInt:2]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:2000]]];
    
    [deck addCard: spell];
    
    //cost 8
    spell = [[SpellCardModel alloc] initWithIdNumber:10062 type:cardTypeSinglePlayer];
    spell.name = @"Spell";
    spell.cost = 8;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetAllMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    
    [deck addCard: spell];
    
    return deck;
}



//just a temp funciton for now
+(void)uploadPlayerDeck
{
    DeckModel *deck = [[DeckModel alloc] init];
    deck = [self getDeckOne];
    
    MonsterCardModel* monster;
    SpellCardModel* spell;
    PFObject *ability;
    
    /*
    for (int i = 0; i < 10; i++)
    {
        monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
        monster.name = @"Monster";
        monster.life = monster.maximumLife = 1500;
        monster.damage = 1000;
        monster.cost = 1;
        monster.cooldown = monster.maximumCooldown = 1;
        
        [deck addCard:monster];
        
        spell = [[SpellCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
        spell.name = @"Spell";
        spell.cost = 1;
        
        //[spell.abilities addObject: [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetOneFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
        PFObject *ability = [PFObject objectWithClassName:@"Ability"];
        ability[@"idNumber"] = @0;
        ability[@"value"] = @1000;
        [spell.abilities addObject:ability];
        
        [deck addCard:spell];
    }*/
    
    //NOTE: since this is code only for testing, the abilities are not actually abilities, but instead PFObjects.
    
}

@end
