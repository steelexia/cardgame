//
//  SinglePlayerCards.m
//  cardgame
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "SinglePlayerCards.h"

@implementation SinglePlayerCards

+(DeckModel*) getDeckOne
{
    DeckModel *deck = [[DeckModel alloc] init];
    
    MonsterCardModel* monster;
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 1500;
    monster.damage = 1000;
    monster.cost = 1;
    monster.cooldown = 1;
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 1000;
    monster.damage = 600;
    monster.cost = 1;
    monster.cooldown = 1;
    
    [monster.abilities addObject: [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetOneFriendly withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 2000;
    monster.damage = 900;
    monster.cost = 1;
    monster.cooldown = 1;
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 1200;
    monster.damage = 2000;
    monster.cost = 2;
    monster.cooldown = 1;
    [monster.abilities addObject: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:750]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 1500;
    monster.damage = 4200;
    monster.cost = 2;
    monster.cooldown = 2;
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 2000;
    monster.damage = 4100;
    monster.cost = 2;
    monster.cooldown = 2;
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 2000;
    monster.damage = 3000;
    monster.cost = 3;
    monster.cooldown = 1;
    
    [monster.abilities addObject: [[Ability alloc] initWithType:abilityLoseLife castType:castOnHit targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:1000]]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 3500;
    monster.damage = 1000;
    monster.cost = 3;
    monster.cooldown = 1;
    
    [monster.abilities addObject: [[Ability alloc] initWithType:abilityAddDamage castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:1000]]];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 2500;
    monster.damage = 5500;
    monster.cost = 4;
    monster.cooldown = 2;
    
    [monster.abilities addObject: [[Ability alloc] initWithType:abilityAddDamage castType:castOnDeath targetType:targetAllFriendlyMinions withDuration:durationUntilEndOfTurn withValue:[NSNumber numberWithInt:2000]]]; //NOT WORKING
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 5000;
    monster.damage = 2500;
    monster.cost = 4;
    monster.cooldown = 2;
    
    [monster.abilities addObject: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:[NSNumber numberWithInt:800]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 5500;
    monster.damage = 1500;
    monster.cost = 4;
    monster.cooldown = 2;
    
    [monster.abilities addObject: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnHit targetType:targetVictim withDuration:durationInstant withValue:[NSNumber numberWithInt:1]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 6000;
    monster.damage = 3000;
    monster.cost = 5;
    monster.cooldown = 2;
    
    [monster.abilities addObject: [[Ability alloc] initWithType:abilityAddLife castType:castOnMove targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1000]]];
    
    [deck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 8000;
    monster.damage = 5000;
    monster.cost = 6;
    monster.cooldown = 2;
    
    [monster.abilities addObject: [[Ability alloc] initWithType:abilityLoseLife castType:castOnHit targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:500]]];
    
    [deck addCard:monster];
    
    return deck;
}

@end
