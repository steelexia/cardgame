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
