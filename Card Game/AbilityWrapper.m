//
//  AbilityWrapper.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-04.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "AbilityWrapper.h"


@implementation AbilityWrapper

@synthesize ability = _ability;
@synthesize element = _element;
@synthesize rarity = _rarity;
@synthesize minPoints = _minPoints;
@synthesize maxPoints = _maxPoints;
@synthesize maxCount = _maxCount;

/** Every AbilityWrapper (i.e. pickable ability) is in this list. */
NSArray *allAbilities;

/** private constructor used by loadAbilities */
-(instancetype)initWithAbility: (Ability*)ability element:(enum CardElement) element rarity:(enum CardRarity) rarity minPoints:(int)minPoints maxPoints:(int)maxPoints maxCount:(int)maxCount
{
    self = [super init];
    
    if (self)
    {
        self.ability = ability;
        self.element = element;
        self.rarity = rarity;
        self.minPoints = minPoints;
        self.maxPoints = maxPoints;
        self.maxCount = maxCount;
        self.enabled = YES;
        
        if (ability.otherValues != nil)
        {
            if ([ability.otherValues[1] integerValue] < 99)
                self.incrementSize = 1;
            else if ([ability.otherValues[1] integerValue] < 999)
                self.incrementSize = 10;
            else
                self.incrementSize = 100;
        }
    }
    
    return self;
}

-(instancetype)initWithAbilityWrapper:(AbilityWrapper*)abilityWraper
{
    self = [self initWithAbility: [[Ability alloc] initWithAbility:abilityWraper.ability] element:abilityWraper.element rarity:abilityWraper.rarity minPoints:abilityWraper.minPoints maxPoints:abilityWraper.maxPoints maxCount:abilityWraper.maxCount];
    
    return self;
}

+(NSString*)abilityToString:(Ability*)ability
{
    return [NSString stringWithFormat:@"%d %@", [AbilityWrapper getIdWithAbility:ability], ability.value];
}

+(Ability*)getAbilityWithString:(NSString*)abilityString
{
    int idNumber;
    NSNumber *value;
    
    NSArray * result = [abilityString componentsSeparatedByString:@" "];
    
    if (result.count < 2)
        return nil;
    
    idNumber = [result[0] intValue];
    
    if ([result[1] isEqualToString:@"nil"])
        value = nil;
    else
        value = [NSNumber numberWithInt:[result[1] intValue]];
    
    return [self getAbilityWithId:idNumber value:value otherValues:nil]; //TODO otherValues not really used right now
}

+(Ability*)getAbilityWithId: (int)idNumber value:(NSNumber*)value otherValues:(NSArray*)otherValues
{
    if (idNumber < 0 || idNumber >= [allAbilities count])
    {
        NSLog(@"WARNING: Tried to request an ability with invalid id: %d.", idNumber);
        return nil;
    }
    
    AbilityWrapper *abilityWrapper = allAbilities[idNumber];
    Ability *newAbility = [[Ability alloc] initWithAbility:abilityWrapper.ability];
    newAbility.value = value;
    newAbility.otherValues = otherValues;
    
    return newAbility;
}

+(Ability*)getAbilityWithPFObject:(PFObject*)abilityPF
{
    NSNumber *abilityID = abilityPF[@"idNumber"];
    Ability*ability = [AbilityWrapper getAbilityWithId:[abilityID intValue] value:abilityPF[@"value"] otherValues:abilityPF[@"otherValues"]];
    
    return ability;
}

+(NSArray*)allAbilities
{
    return allAbilities;
}

+(int)getIdWithAbility:(Ability*)ability
{
    for (int i = 0; i < [allAbilities count]; i++)
    {
        AbilityWrapper* wrapper = allAbilities[i];
        Ability*wrapperAbility = wrapper.ability;
        if ([wrapperAbility isEqualTypeTo:ability])
            return i;
    }
    
    return -1;
}

//TODO needs a way to access allAbilities from the store

+(void)loadAllAbilities
{
    /* 
     IMPORTANT: 
     Add additional abilities at the end of the list. DO NOT reorder the abilities, or add new abilities in middle of the list, since their index acts as an ID.
     Almost all abilities should not use withValue, and instead provide the range of values in withOtherValues as an array, in the form of [value1min, value1max, value2min, value2max...]. Only abilities without values, or a single static value use withValue. 
     Use the constructor with withDescription if a custom description is used. When using this, use %1, %2... to represent value1, value2, etc., as they will be replaced later on. TODO this is not finished yet.
     For now, put all min and max points as 1. Their exact values can be changed later.
     If value is not nil, otherValues ___MUST___ have at least two elements, being its min and max values. Even if the ability's range is 1, it still must store 1,1 in min and max.
     **/
    allAbilities = @[
                     //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     
                     //---direct damage---//
                     //direct damage one character
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneAny withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@8000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:4],
                     //direct damage one enemy character
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemy withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@8000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:4],
                     //direct damage one minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@8000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:4],
                     //direct damage one enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@8000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:4],
                     //direct damage all enemy
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemy withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@4000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //direct damage all enemy minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@5000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //direct damage all characters
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAll withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@6000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //direct damage to enemy hero
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetHeroEnemy withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@5000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //direct damage to friendly hero
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@5000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //direct damage to self
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetSelf withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@5000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //direct damage to one random enemy
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemy withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@8000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //reflect damage back to attacker
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:0 withOtherValues:@[@1000,@5000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //damage attacker on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAttacker withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@5000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //damage all enemy minions on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@5000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //damage all minions on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@5000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],//damage all minions on death
                     //damage all on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAll withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@6000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //damage all enemy minions on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnMove targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //damage one random enemy on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnMove targetType:targetOneRandomEnemy withDuration:durationForever withValue:0 withOtherValues:@[@1000,@6000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //damage all enemy minions on attack
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnHit targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1000,@2000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //damage all enemy characters on attack
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnHit targetType:targetAllEnemy withDuration:durationForever withValue:0 withOtherValues:@[@1000,@2000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //damage enemy hero on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnHit targetType:targetHeroEnemy withDuration:durationForever withValue:0 withOtherValues:@[@1000,@2000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     
                     //---heal---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //heal 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@6000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //heal 1 friendly minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@6000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //heal all friendly
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetAllFriendly withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@4000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //heal all characters
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetAll withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@8000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //heal hero
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:0 withOtherValues:@[@1000,@8000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //heal on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1000,@4000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //heal on damage taken
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@500,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //heal hero on damage taken
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnDamaged targetType:targetHeroFriendly withDuration:durationForever withValue:0 withOtherValues:@[@1000,@5000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //heal self on end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnEndOfTurn targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //heal all friendly minion on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnMove targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     
                     //---add max life---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //add to 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1000,@8000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //add to 1 friendly minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1000,@8000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //add to all friendly minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //add to all enemy minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //add on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1000,@4000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@500,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to random friendly minion on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnDamaged targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to all friendly minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnDeath targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to 1 random friendly minion on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnMove targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to self on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnMove targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to self on end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnEndOfTurn targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1000,@2000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     
                     //---kill---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //kill 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //kill a minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //kill all friendly minions on summon
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //kill 1 random enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //kill 1 random minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneRandomMinion withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //kill attacker on death (this would work when attacking although it would be sort of "weird" to use this with charge, since it's same as kill one any minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnDeath targetType:targetAttacker withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //kill all minions on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnDeath targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //kill all friendly minions on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnDeath targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //kill attacker on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //kill victim on hit (won't work on hero)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnHit targetType:targetVictimMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],

                     //---taunt---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //minion with taunt
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:4],
                     //give taunt to a minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //give taunt to a friendly minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //give taunt to a random minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetOneRandomMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //give taunt to all friendly minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //give taunt to a random minion on end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityTaunt castType:castOnEndOfTurn targetType:targetOneRandomMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //give taunt to self on damage taken (very cheap ability)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityTaunt castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //give taunt to a random friendly minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityTaunt castType:castOnDeath targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     
                     //---draw card---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //draw x cards immediately
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:0 withOtherValues:@[@1,@5] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //draw x cards for enemy immediately
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroEnemy withDuration:durationInstant withValue:0 withOtherValues:@[@1,@5] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //draw x cards for all immediately
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetAll withDuration:durationInstant withValue:0 withOtherValues:@[@1,@5] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //draw x cards on damage
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnDamaged targetType:targetHeroFriendly withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //draw x cards on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnHit targetType:targetHeroFriendly withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //draw x cards on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnDeath targetType:targetHeroFriendly withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //draw 1 card on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnMove targetType:targetHeroFriendly withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //draw 1 card for enemey on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnMove targetType:targetHeroEnemy withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     
                     //---add damage---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //add to 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1000,@6000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //add to 1 friendly minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1000,@6000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //add to 1 minion until end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationUntilEndOfTurn withValue:0 withOtherValues:@[@1000,@10000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //add to 1 friendly minion until end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationUntilEndOfTurn withValue:0 withOtherValues:@[@1000,@10000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //add to all friendly
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1000,@2000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //add to all friendly until end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationUntilEndOfTurn withValue:0 withOtherValues:@[@1000,@5000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //add to all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllMinion withDuration:durationForever withValue:0 withOtherValues:@[@1000,@4000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //add on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1000,@4000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to victim on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnHit targetType:targetVictimMinion withDuration:durationForever withValue:0 withOtherValues:@[@1000,@4000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to a random friendly on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnHit targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to random friendly minion on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnDamaged targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to all friendly minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnDeath targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to 1 random friendly minion on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnMove targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to all friendly minion on move until end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnMove targetType:targetAllFriendlyMinions withDuration:durationUntilEndOfTurn withValue:0 withOtherValues:@[@1000,@6000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to self on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnMove targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to self on end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnEndOfTurn targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1000,@2000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     
                     //---lose damage---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //lose to 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1000,@6000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //lose to 1 enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1000,@6000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //lose to all enemy
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //lose to all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetAllMinion withDuration:durationForever withValue:0 withOtherValues:@[@1000,@4000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //lose on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@500,@4000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //victim lose on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnHit targetType:targetVictimMinion withDuration:durationForever withValue:0 withOtherValues:@[@500,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //attacker lose on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnHit targetType:targetAttacker withDuration:durationForever withValue:0 withOtherValues:@[@500,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //lose on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@500,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //lose to random friendly minion on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnDamaged targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@500,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //lose to all friendly minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnDeath targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@500,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //lose to all enemy minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1000,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //lose to 1 random enemy minion on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnMove targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[@500,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //lose to self on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnMove targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@500,@3000] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     
                     //---set cooldown---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //start with 0 cooldown (charge)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetSelf withDuration:durationInstant withValue:0 withOtherValues:@[@0,@0] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //set for 1 minion (from values 0 to 2 the cost is the same, 0 = good, 2 = bad, depending on target cooldown)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@0,@2] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //set for all friendly minion to 0
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:0 withOtherValues:@[@0,@0] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //set for all minions, again values same for 0-2
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:@[@0,@2] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //set a random friendly minion to 0 on end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilitySetCooldown castType:castOnEndOfTurn targetType:targetOneFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@0,@0] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //set all random friendly minion to 0 on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilitySetCooldown castType:castOnDeath targetType:targetOneFriendlyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@0,@0] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     
                     
                     //---add cooldown---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //add for 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //add for 1 enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //add for all enemy minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add for all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to victim on hit (very expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnHit targetType:targetVictimMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to self on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to attacker on damage
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to attacker on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnDeath targetType:targetAttacker withDuration:durationInstant withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to all enemy on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationInstant withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to one random enemy on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnDeath targetType:targetOneEnemyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to all minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnDeath targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to random enemy minion on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnMove targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to all enemy minions on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnMove targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     
                     //---lose cooldown---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //lose for 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@4] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //lose for 1 friendly minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@4] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //lose for all friendly minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //lose for all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //lose on damage taken
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //lose to all friendly minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnDeath targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //lose to all minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnDeath targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //lose to all friendly on turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnEndOfTurn targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     
                     //---add max cooldown---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //add for 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //add for 1 enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //add for 1 enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //add for all enemy minions (very very expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add for all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnSummon targetType:targetAllMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to victim on hit (very very very expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnHit targetType:targetVictimMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to self on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to attacker on damage (very expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to attacker on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnDeath targetType:targetAttacker withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to all enemy on death (very expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to random enemy on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnDeath targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to all minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnDeath targetType:targetAllMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //add to random enemy on move (very expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnMove targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     
                     //---lose max cooldown---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //lose for 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseMaxCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //lose for 1 friendly minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseMaxCooldown castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //lose for all friendly minions (very very expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseMaxCooldown castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //lose for all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseMaxCooldown castType:castOnSummon targetType:targetAllMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //lose to all friendly minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseMaxCooldown castType:castOnDeath targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //lose to all minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseMaxCooldown castType:castOnDeath targetType:targetAllMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     
                     //---assassin---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //minion with assassin
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAssassin castType:castAlways targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //give assassin to a minion (pretty OP)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAssassin castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //give assassin to a random minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAssassin castType:castOnSummon targetType:targetOneRandomMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //give assassin to a random friendly minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAssassin castType:castOnDeath targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     
                     //---remove abilities---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //minion with no abilities, but cannot receive debuffs
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castAlways targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //silence a minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //silence an enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //silence all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetAllMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //silence all enemy minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //silence random minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetOneRandomMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //silence attacker on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //silence victim on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnHit targetType:targetVictim withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //silence one random minion every end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnEndOfTurn targetType:targetOneRandomMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //silence one random enemy minion every end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnEndOfTurn targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //silence random enemy minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnDeath targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //silence all enemy minions on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     
                     //---gain resource---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //gain x resources immediately (mostly for spell cards, such as gain 2 resource for 0 cost)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddResource castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:0 withOtherValues:@[@1,@5] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //gain x resources on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddResource castType:castOnHit targetType:targetHeroFriendly withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //gain 1 resource on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddResource castType:castOnMove targetType:targetHeroFriendly withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     
                     //---return to hand---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //return 1 friendly minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //return 1 minion (much more expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //return all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnSummon targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //return all friendly minions on summon
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //return 1 random enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //return 1 random minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnSummon targetType:targetOneRandomMinion withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //return attacker on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnDeath targetType:targetAttacker withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //return self on death (very expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnDeath targetType:targetSelf withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //return victim on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnHit targetType:targetVictim withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //return attacker on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //return all minions on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnDeath targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //return all friendly minions on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnDeath targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //return all enemy minions on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationInstant withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     
                     //---fracture---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //fracture on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityFracture castType:castOnDeath targetType:targetSelf withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2], //note that costs don't change
                     //fracture on damaged (EXTREMELY expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityFracture castType:castOnDamaged targetType:targetSelf withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1], //note that costs don't change
                     //fracture on move (EXTREMELY expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityFracture castType:castOnMove targetType:targetSelf withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1], //note that costs don't change
                     //fracture on move (EXTREMELY expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityFracture castType:castOnEndOfTurn targetType:targetSelf withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1], //note that costs don't change
                     
                     //---pierce---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //minion with pierce
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityPierce castType:castAlways targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:2],
                     //give pierce to a minion (pretty OP)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityPierce castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //give pierce to a random minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityPierce castType:castOnSummon targetType:targetOneRandomMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     //give pierce to a random friendly minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityPierce castType:castOnDeath targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:nil withDescription:nil] element:elementNeutral rarity:cardRarityCommon minPoints:1 maxPoints:1 maxCount:1],
                     
                     //ADD ADDITIONAL ABILITIES HERE, DO NOT INSERT IN MIDDLE!!!
    ];
    
    //use this to print out all abilities for temp card design
    
    /*
    for (int i = 0; i < [allAbilities count]; i++)
    {
        AbilityWrapper *wrapper = allAbilities[i];
        NSLog(@"%d %d %d %d", i, wrapper.ability.abilityType, wrapper.ability.castType, wrapper.ability.targetType);
    }
     */
}



@end
