//
//  AbilityWrapper.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-04.
//  Copyright (c) 2014 Content Games. All rights reserved.
//



#import "AbilityWrapper.h"
#import "Ability.h"

@implementation AbilityWrapper

@synthesize ability = _ability;
@synthesize elements = _elements;
@synthesize rarity = _rarity;
@synthesize minPoints = _minPoints;
@synthesize maxPoints = _maxPoints;
@synthesize maxCount = _maxCount;
@synthesize minCost = _minCost;
@synthesize currentPoints = _currentPoints;

/** Every AbilityWrapper (i.e. pickable ability) is in this list. */
NSArray *allAbilities;

/** private constructor used by loadAbilities */
-(instancetype)initWithAbility: (Ability*)ability elements:(NSArray*) elements rarity:(enum CardRarity) rarity minPoints:(int)minPoints maxPoints:(int)maxPoints maxCount:(int)maxCount minCost:(int)minCost
{
    self = [super init];
    
    if (self)
    {
        self.ability = ability;
        self.elements = elements;
        self.rarity = rarity;
        self.minPoints = minPoints;
        self.maxPoints = maxPoints;
        self.maxCount = maxCount;
        self.minCost = minCost;
        self.enabled = YES;
        
        if (ability.otherValues != nil && ability.otherValues.count == 2)
        {
            //note that now all abilities should have increment size of 1
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

-(instancetype)initWithAbilityWrapper:(AbilityWrapper*)abilityWrapper
{
    self = [self initWithAbility: [[Ability alloc] initWithAbility:abilityWrapper.ability] elements:abilityWrapper.elements rarity:abilityWrapper.rarity minPoints:abilityWrapper.minPoints maxPoints:abilityWrapper.maxPoints maxCount:abilityWrapper.maxCount minCost:abilityWrapper.minCost];
    
    return self;
}

-(BOOL)isCompatibleWithElement:(enum CardElement)element
{
    for (NSNumber*number in self.elements)
    {
        if ([number intValue] == element)
            return YES;
    }
    return NO;
}

-(BOOL)isCompatibleWithCardModel:(CardModel*)card
{
    BOOL isSpellCard = [card isKindOfClass:[SpellCardModel class]];
    
    if(![self isCompatibleWithElement:card.element]) //element is not correct
        return NO;
    
#ifndef DEBUG_COST
    if (self.rarity > card.rarity) //rarity is not enough
        return NO;
#endif
    
    if (isSpellCard && self.ability.castType != castOnSummon) //spell card must have castOnSummon
        return NO;
    
    if (isSpellCard && self.ability.targetType == targetSelf) //spell card cannot target self
        return NO;
    
    for (Ability*cardAbility in card.abilities)
    {
        if (cardAbility.expired)
            continue;
        
        //cannot have same card
        if (cardAbility != self.ability && ![cardAbility isCompatibleTo:self.ability])
            return NO;
    }
    
    return YES;
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

+(AbilityWrapper*)getWrapperWithId:(int)idNumber
{
    if (idNumber >= 0 && idNumber < allAbilities.count)
        return [[AbilityWrapper alloc] initWithAbilityWrapper:allAbilities[idNumber]];
    
    return nil;
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
     
     //Element organization//
     ===Neutral=== (all round)
     add resource, draw card
     
     ---------------------------------------------
     ===Fire=== (offensive)
     cast on summon lose life
     cast on hit (oppo of ice)
     cast on summon lose cooldown?
     pierce & give pierce
     AOE
     
     ===Ice=== (defensive)
     cast on summon cooldown increase
     cast on damaged (oppo of fire)
     add max life
     fracture on damaged
     give taunt
     AOE
     
     ---------------------------------------------
     ===Thunder=== (off)
     cast on move (opposite of earth)
     cast on summon set cooldown, lose MAX cooldown (most - cooldowns are here to counter earth)
     target random
     assassin?
     pierce & give pierce
     fracture on end of turn
     
     ===Earth=== (def)
     cast on end of turn (growth) (add max life, add damage)
     add max cooldown
     draw card
     give taunt
     add resource
     
     ---------------------------------------------
     ===Light=== (def)
     target friendly
     add life
     return to hand
     draw card
     mute
     give taunt
     direct add damage
     
     ===Dark=== (off)
     target any
     cast on death
     kill
     fracture on death
     add resource
     pierce & give pierce
     direct lose damage
     
     ---------------------------------------------
     
     
     
     **/
    allAbilities = @[
                     //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     
                     //---direct damage---//
                     //direct damage one character
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneAny withDuration:durationInstant withValue:0 withOtherValues:@[@1,@20] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityCommon minPoints:20 maxPoints:400 maxCount:2 minCost:0],
                     //direct damage one enemy character
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemy withDuration:durationInstant withValue:0 withOtherValues:@[@1,@20] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityCommon minPoints:20 maxPoints:400 maxCount:2 minCost:1],
                     //direct damage one minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@30] withDescription:nil] elements:@[DEFENSIVE_ELEMENTS] rarity:cardRarityCommon minPoints:15 maxPoints:360 maxCount:2 minCost:1],
                     //direct damage one enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@30] withDescription:nil] elements:@[ELEMENT_NEUTRAL] rarity:cardRarityCommon minPoints:15 maxPoints:360 maxCount:1 minCost:1],
                     //direct damage all enemy
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemy withDuration:durationInstant withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[FIRE_AND_ICE] rarity:cardRarityCommon minPoints:45 maxPoints:525 maxCount:2 minCost:1],
                     //direct damage all enemy minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:0 withOtherValues:@[@1,@20] withDescription:nil] elements:@[ELEMENT_NEUTRAL, LIGHTNING_AND_EARTH, LIGHT_AND_DARK] rarity:cardRarityUncommon minPoints:40 maxPoints:600 maxCount:1 minCost:2],
                     //direct damage all characters
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAll withDuration:durationInstant withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_FIRE, ELEMENT_DARK] rarity:cardRarityUncommon minPoints:30 maxPoints:400 maxCount:2 minCost:3], //TODO not sure if min cost 3 is good
                     //direct damage to enemy hero
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetHeroEnemy withDuration:durationInstant withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[OFFENSIVE_ELEMENTS] rarity:cardRarityCommon minPoints:10 maxPoints:150 maxCount:2 minCost:0],
                     //direct damage to friendly hero
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityCommon minPoints:-6 maxPoints:-60 maxCount:2 minCost:1], //?uncommon, minCost 1 or 2?
                     //direct damage to one random enemy
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemy withDuration:durationInstant withValue:0 withOtherValues:@[@1,@20] withDescription:nil] elements:@[ELEMENT_NEUTRAL] rarity:cardRarityCommon minPoints:10 maxPoints:200 maxCount:2 minCost:0],
                     //direct damage to one random enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@20] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityCommon minPoints:14 maxPoints:280 maxCount:2 minCost:1],
                     //direct damage to one random friendly minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneRandomFriendlyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityUncommon minPoints:-8 maxPoints:-50 maxCount:2 minCost:3],
                     //reflect damage back to attacker (note that this will not cause loop since the reflected damage is an ability, thus have no attacker and cannot be further reflected)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:0 withOtherValues:@[@1,@25] withDescription:nil] elements:@[ALL_ELEMENTS] rarity:cardRarityUncommon minPoints:5 maxPoints:65 maxCount:4 minCost:1],
                     //damage attacker on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAttacker withDuration:durationInstant withValue:0 withOtherValues:@[@1,@25] withDescription:nil] elements:@[DEFENSIVE_ELEMENTS] rarity:cardRarityExceptional minPoints:4 maxPoints:100 maxCount:2 minCost:2],
                     //damage all enemy minions on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationInstant withValue:0 withOtherValues:@[@1,@20] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityUncommon minPoints:40 maxPoints:600 maxCount:1 minCost:2], //should this be cheaper than direct?
                     //damage all minions on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@20] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityRare minPoints:20 maxPoints:360 maxCount:1 minCost:2],//damage all minions on death
                     //damage all on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAll withDuration:durationInstant withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityRare minPoints:22 maxPoints:300 maxCount:1 minCost:2],
                     //damage all enemy minions on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnMove targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_FIRE, ELEMENT_EARTH] rarity:cardRarityRare minPoints:32 maxPoints:280 maxCount:1 minCost:2],
                     //damage one random enemy on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnMove targetType:targetOneRandomEnemy withDuration:durationForever withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityCommon minPoints:12 maxPoints:180 maxCount:1 minCost:2],
                     //damage all enemy minions on attack
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnHit targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_ICE] rarity:cardRarityCommon minPoints:25 maxPoints:220 maxCount:1 minCost:3],
                     //damage all enemy characters on attack
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnHit targetType:targetAllEnemy withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityLegendary minPoints:28 maxPoints:240 maxCount:1 minCost:3],
                     //damage enemy hero on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnHit targetType:targetHeroEnemy withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_FIRE] rarity:cardRarityRare minPoints:8 maxPoints:80 maxCount:1 minCost:1],
                     //NOTE: a direct damage to self on summon taken out due to being too exploitable
                     
                     //---heal---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //heal 1 any
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetOneAny withDuration:durationInstant withValue:0 withOtherValues:@[@1,@25] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityCommon minPoints:5 maxPoints:240 maxCount:3 minCost:0], //much better than other elements
                     //heal 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@25] withDescription:nil] elements:@[ELEMENT_NEUTRAL] rarity:cardRarityCommon minPoints:5 maxPoints:240 maxCount:2 minCost:0],
                     //heal 1 friendly minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@25] withDescription:nil] elements:@[ELEMENT_ICE, ELEMENT_EARTH] rarity:cardRarityCommon minPoints:5 maxPoints:240 maxCount:2 minCost:0],
                     //heal all friendly
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetAllFriendly withDuration:durationInstant withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[DEFENSIVE_ELEMENTS] rarity:cardRarityUncommon minPoints:14 maxPoints:240 maxCount:2 minCost:1],
                     //heal all characters
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetAll withDuration:durationInstant withValue:0 withOtherValues:@[@1,@40] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityCommon minPoints:5 maxPoints:500 maxCount:2 minCost:1],
                     //heal hero
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:0 withOtherValues:@[@1,@40] withDescription:nil] elements:@[ELEMENT_NEUTRAL, DEFENSIVE_ELEMENTS] rarity:cardRarityCommon minPoints:6 maxPoints:600 maxCount:2 minCost:0],
                     //heal on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[FIRE_AND_ICE] rarity:cardRarityUncommon minPoints:10 maxPoints:150 maxCount:1 minCost:1],
                     //heal on damage taken
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[FIRE_AND_ICE] rarity:cardRarityCommon minPoints:10 maxPoints:150 maxCount:1 minCost:1],
                     //heal hero on damage taken
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnDamaged targetType:targetHeroFriendly withDuration:durationForever withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityRare minPoints:8 maxPoints:250 maxCount:1 minCost:1],
                     //heal self on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnMove targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityUncommon minPoints:8 maxPoints:120 maxCount:1 minCost:1],
                     //heal all friendly minion on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnMove targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityRare minPoints:10 maxPoints:150 maxCount:1 minCost:0],
                     //heal all friendly minion on end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnEndOfTurn targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_ICE, ELEMENT_EARTH] rarity:cardRarityRare minPoints:10 maxPoints:150 maxCount:1 minCost:0],

                     //---add max life---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //add to 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@20] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityCommon minPoints:12 maxPoints:250 maxCount:2 minCost:0], //more flexible than other
                     //add to 1 friendly minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@20] withDescription:nil] elements:@[ELEMENT_ICE, ELEMENT_EARTH] rarity:cardRarityCommon minPoints:12 maxPoints:250 maxCount:2 minCost:0],
                     //add to all friendly minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityUncommon minPoints:30 maxPoints:450 maxCount:2 minCost:1],
                     //add to all enemy minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityExceptional minPoints:-10 maxPoints:-80 maxCount:2 minCost:3],
                     //add on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityCommon minPoints:15 maxPoints:225 maxCount:1 minCost:1],
                     //add on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_NEUTRAL, DEFENSIVE_ELEMENTS] rarity:cardRarityUncommon minPoints:15 maxPoints:225 maxCount:1 minCost:1],
                     //add to random friendly minion on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnDamaged targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityExceptional minPoints:12 maxPoints:180 maxCount:1 minCost:1],
                     //add to all friendly minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnDeath targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@20] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityExceptional minPoints:20 maxPoints:400 maxCount:1 minCost:1],
                     //add to 1 random friendly minion on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnMove targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityRare minPoints:10 maxPoints:150 maxCount:1 minCost:1],
                     //add to self on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnMove targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityUncommon minPoints:12 maxPoints:120 maxCount:1 minCost:1],
                     //add to self on end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnEndOfTurn targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityCommon minPoints:12 maxPoints:120 maxCount:2 minCost:0],
    
                     //---kill---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //kill 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[OFFENSIVE_ELEMENTS] rarity:cardRarityUncommon minPoints:290 maxPoints:290 maxCount:1 minCost:1],
                     //kill all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityLegendary minPoints:440 maxPoints:440 maxCount:1 minCost:6],
                     //kill all friendly minions on summon
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[OFFENSIVE_ELEMENTS] rarity:cardRarityLegendary minPoints:-120 maxPoints:-120 maxCount:1 minCost:4], //exact minCost need adjustment, although when high the points can also be rewarding
                     //kill 1 random enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_DARK] rarity:cardRarityUncommon minPoints:180 maxPoints:180 maxCount:1 minCost:1],
                     //kill 1 random minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneRandomMinion withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityUncommon minPoints:140 maxPoints:140 maxCount:1 minCost:1], //minCost used to be 4
                     //kill attacker on death (this would work when attacking although it would be sort of "weird" to use this with charge, since it's same as kill one any minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnDeath targetType:targetAttacker withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityRare minPoints:110 maxPoints:110 maxCount:1 minCost:1],
                     //kill all minions on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnDeath targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[OFFENSIVE_ELEMENTS] rarity:cardRarityLegendary minPoints:380 maxPoints:380 maxCount:1 minCost:1],
                     //kill all friendly minions on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnDeath targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityExceptional minPoints:-50 maxPoints:-50 maxCount:1 minCost:5],
                     //kill attacker on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ALL_ELEMENTS] rarity:cardRarityRare minPoints:70 maxPoints:70 maxCount:1 minCost:1], //maybe not all elements?
                     //kill victim on hit (won't work on hero)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnHit targetType:targetVictimMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[OFFENSIVE_ELEMENTS] rarity:cardRarityRare minPoints:80 maxPoints:80 maxCount:1 minCost:4],
                     //kill 1 random enemy minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityKill castType:castOnDeath targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityExceptional minPoints:80 maxPoints:80 maxCount:1 minCost:1], //this is really cheap vs OnSummon, need check balance
                     
                     //---taunt---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //minion with taunt
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityTaunt castType:castAlways targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ALL_ELEMENTS] rarity:cardRarityCommon minPoints:0 maxPoints:0 maxCount:4 minCost:1], //NOTE: points is based on minion's stats
                     //give taunt to a minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[DEFENSIVE_ELEMENTS] rarity:cardRarityUncommon minPoints:30 maxPoints:30 maxCount:2 minCost:1],
                     //give taunt to a friendly minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_NEUTRAL] rarity:cardRarityUncommon minPoints:30 maxPoints:30 maxCount:1 minCost:1],
                     //give taunt to a random minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetOneRandomMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityUncommon minPoints:20 maxPoints:20 maxCount:2 minCost:1],//should be high rarity
                     //give taunt to all friendly minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityTaunt castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[DEFENSIVE_ELEMENTS] rarity:cardRarityExceptional minPoints:60 maxPoints:60 maxCount:1 minCost:0], //0 mana legendary
                     //give taunt to a random friendly minion on end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityTaunt castType:castOnEndOfTurn targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityRare minPoints:50 maxPoints:50 maxCount:1 minCost:1],
                     //give taunt to self on damage taken (very cheap ability)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityTaunt castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_ICE] rarity:cardRarityRare minPoints:10 maxPoints:10 maxCount:2 minCost:1],
                     //give taunt to a random friendly minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityTaunt castType:castOnDeath targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[DEFENSIVE_ELEMENTS] rarity:cardRarityRare minPoints:10 maxPoints:10 maxCount:2 minCost:1],
                     
                     //---draw card---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //draw x cards immediately
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:0 withOtherValues:@[@1,@4] withDescription:nil] elements:@[DEFENSIVE_ELEMENTS] rarity:cardRarityCommon minPoints:90 maxPoints:420 maxCount:2 minCost:0], //note this these immediate draws should avoid overlapping in elements
                     //draw x cards for enemy immediately
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetHeroEnemy withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityUncommon minPoints:-40 maxPoints:-150 maxCount:2 minCost:1], //max num from 3 to 2
                     //draw x cards for all immediately
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnSummon targetType:targetAll withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] elements:@[ELEMENT_NEUTRAL] rarity:cardRarityRare minPoints:50 maxPoints:200 maxCount:2 minCost:1],
                     //draw x cards on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnDamaged targetType:targetHeroFriendly withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] elements:@[ELEMENT_ICE] rarity:cardRarityRare minPoints:100 maxPoints:100 maxCount:1 minCost:1],
                     //draw x cards on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnHit targetType:targetHeroFriendly withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityExceptional minPoints:80 maxPoints:80 maxCount:1 minCost:2],
                     //draw x cards on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnDeath targetType:targetHeroFriendly withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityCommon minPoints:60 maxPoints:160 maxCount:2 minCost:1],
                     //draw 1 card on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnMove targetType:targetHeroFriendly withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityUncommon minPoints:100 maxPoints:100 maxCount:1 minCost:1],
                     //draw 1 card for enemey on end of turn (used to be on move)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnEndOfTurn targetType:targetHeroEnemy withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_DARK] rarity:cardRarityLegendary minPoints:-60 maxPoints:-60 maxCount:2 minCost:1],
                     
                     //---add damage---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //add to 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityCommon minPoints:17 maxPoints:170 maxCount:2 minCost:1],
                     //add to 1 friendly minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityUncommon minPoints:17 maxPoints:170 maxCount:2 minCost:1],
                     //add to 1 minion until end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationUntilEndOfTurn withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_FIRE, ELEMENT_LIGHTNING] rarity:cardRarityCommon minPoints:12 maxPoints:180 maxCount:2 minCost:1],
                     //add to 1 friendly minion until end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationUntilEndOfTurn withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_NEUTRAL] rarity:cardRarityCommon minPoints:12 maxPoints:180 maxCount:2 minCost:1], //this can have lower maxCount or low max damge if becoming too op
                     //add to all friendly
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityUncommon minPoints:70 maxPoints:400 maxCount:1 minCost:2], //might be too expensive?
                     //add to all friendly until end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationUntilEndOfTurn withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[OFFENSIVE_ELEMENTS] rarity:cardRarityRare minPoints:50 maxPoints:315 maxCount:1 minCost:1],
                     //add to all enemy minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_LIGHTNING, ELEMENT_DARK] rarity:cardRarityExceptional minPoints:-10 maxPoints:-80 maxCount:1 minCost:3],
                     //add to all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetAllMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityExceptional minPoints:40 maxPoints:320 maxCount:1 minCost:1],
                     //add on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@7] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityCommon minPoints:12 maxPoints:84 maxCount:2 minCost:1],
                     //add to victim on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnHit targetType:targetVictimMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@7] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityExceptional minPoints:-5 maxPoints:-30 maxCount:1 minCost:1],
                     //add to a random friendly on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnHit targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@7] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityUncommon minPoints:12 maxPoints:84 maxCount:2 minCost:1],
                     //add on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@7] withDescription:nil] elements:@[ELEMENT_ICE] rarity:cardRarityRare minPoints:10 maxPoints:70 maxCount:2 minCost:1],
                     //add to random friendly minion on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnDamaged targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@7] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityRare minPoints:10 maxPoints:70 maxCount:1 minCost:1],
                     //add to all friendly minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnDeath targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_LIGHT] rarity:cardRarityLegendary minPoints:37 maxPoints:350 maxCount:1 minCost:2],
                     //add to 1 random friendly minion on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnMove targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@7] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityUncommon minPoints:15 maxPoints:105 maxCount:1 minCost:1],
                     //add to all friendly minion on move until end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnMove targetType:targetAllFriendlyMinions withDuration:durationUntilEndOfTurn withValue:0 withOtherValues:@[@1,@7] withDescription:nil] elements:@[FIRE_AND_ICE] rarity:cardRarityRare minPoints:50 maxPoints:350 maxCount:1 minCost:2], //note that this is very close to "add x damage to all friendly if the caster is alive, probably don't need to remove as can modify to that if implemented
                     //add to random friendly minion on end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnEndOfTurn targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@7] withDescription:nil] elements:@[LIGHTNING_AND_EARTH] rarity:cardRarityRare minPoints:19 maxPoints:133 maxCount:1 minCost:2],
                     //add to self on end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddDamage castType:castOnEndOfTurn targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@7] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityCommon minPoints:25 maxPoints:175 maxCount:1 minCost:2],
                     
                     //---lose damage---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //lose to 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@25] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityCommon minPoints:17 maxPoints:350 maxCount:2 minCost:0],
                     //lose to 1 minion until end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationUntilEndOfTurn withValue:0 withOtherValues:@[@1,@25] withDescription:nil] elements:@[DEFENSIVE_ELEMENTS] rarity:cardRarityUncommon minPoints:12 maxPoints:250 maxCount:3 minCost:0],
                     //lose to 1 enemy minion until end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationUntilEndOfTurn withValue:0 withOtherValues:@[@1,@25] withDescription:nil] elements:@[ELEMENT_NEUTRAL] rarity:cardRarityUncommon minPoints:12 maxPoints:250 maxCount:2 minCost:0],
                     //lose to all enemy minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[DEFENSIVE_ELEMENTS] rarity:cardRarityUncommon minPoints:35 maxPoints:450 maxCount:1 minCost:1],
                     //lose to all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetAllMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityUncommon minPoints:24 maxPoints:320 maxCount:1 minCost:3],
                     //lose on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@7] withDescription:nil] elements:@[LIGHT_AND_DARK] rarity:cardRarityExceptional minPoints:-5 maxPoints:-35 maxCount:2 minCost:1], //capped by base damage. bass damage less than this caps the points
                     //victim lose on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnHit targetType:targetVictimMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[OFFENSIVE_ELEMENTS] rarity:cardRarityRare minPoints:15 maxPoints:150 maxCount:1 minCost:1],
                     //attacker lose on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:0 withOtherValues:@[@1,@7] withDescription:nil] elements:@[DEFENSIVE_ELEMENTS] rarity:cardRarityUncommon minPoints:25 maxPoints:175 maxCount:1 minCost:1],
                     //lose on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_LIGHT] rarity:cardRarityExceptional minPoints:-6 maxPoints:-60 maxCount:1 minCost:1],
                     //lose to random friendly minion on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnDamaged targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@7] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityExceptional minPoints:-10 maxPoints:-70 maxCount:1 minCost:2],
                     //lose to all friendly minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnDeath targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityRare minPoints:-10 maxPoints:-70 maxCount:1 minCost:3],
                     //lose to all enemy minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[DEFENSIVE_ELEMENTS] rarity:cardRarityLegendary minPoints:25 maxPoints:320 maxCount:1 minCost:1],
                     //lose to 1 random enemy minion on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnMove targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@7] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityRare minPoints:17 maxPoints:122 maxCount:1 minCost:1],
                     //lose to self on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseDamage castType:castOnMove targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@7] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityExceptional minPoints:-14 maxPoints:-98 maxCount:1 minCost:1], //capped by damage, note that this actually gives less damage even if it's only casted once. probably will become OP for minions with little damage if it gives too much points
                     
                     //---set cooldown---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //start with 0 cooldown (charge)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetSelf withDuration:durationInstant withValue:0 withOtherValues:@[@0,@0] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityCommon minPoints:0 maxPoints:0 maxCount:3 minCost:1],
                     //set for 1 minion, no setting to 0 since that would be insanely OP
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] elements:@[DEFENSIVE_ELEMENTS] rarity:cardRarityRare minPoints:90 maxPoints:90 maxCount:2 minCost:1], //TODO this is very troublesome, since its effect will -1 when cast on enemies, making 1 only castable on friendly, 3 only castable on enemy, 2 being a weird one that kind of cant really be cast on either? or maybe 2 is OK because its like flexible in a high cd deck
                     //set for all friendly minion to 1
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:0 withOtherValues:@[@1,@1] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityExceptional minPoints:150 maxPoints:150 maxCount:1 minCost:1], //TODO need testing, potentially OP as hell, or useless as hell
                     //set for all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityExceptional minPoints:150 maxPoints:320 maxCount:1 minCost:4], //TODO might want to remove this, 2 is very weird, maybe split into 1 and 3
                     //set a random enemy minion on end of turn (will be -1 on enemy turn)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilitySetCooldown castType:castOnEndOfTurn targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[@2,@3] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityExceptional minPoints:100 maxPoints:250 maxCount:1 minCost:4],
                     //set a random friendly minion to 0 on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilitySetCooldown castType:castOnDeath targetType:targetOneRandomFriendlyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@0,@1] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityExceptional minPoints:200 maxPoints:60 maxCount:1 minCost:5], //might be too OP (for the set to 0), hopefully minCost makes it less. Note that this requires a 3 card combo (this card with low life + direct damage to kill it + a high cd high damage or high effect card and clean board) set to 1 would be identical to 0 if died on enemy's turn
                     
                     //---add cooldown---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //add for 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] elements:@[ELEMENT_ICE] rarity:cardRarityCommon minPoints:60 maxPoints:180 maxCount:3 minCost:0], //signature ability for ice
                     //add for 1 enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityUncommon minPoints:60 maxPoints:180 maxCount:1 minCost:0],
                     //add for 1 random enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityCommon minPoints:50 maxPoints:150 maxCount:2 minCost:2], //high min cost makes it worse than ice's
                     //add for all enemy minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_ICE] rarity:cardRarityUncommon minPoints:180 maxPoints:360 maxCount:1 minCost:3],
                     //add for all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityRare minPoints:140 maxPoints:280 maxCount:1 minCost:3],
                     //add to victim on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnHit targetType:targetVictimMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_ICE] rarity:cardRarityExceptional minPoints:25 maxPoints:60 maxCount:1 minCost:1],
                     //add to self on hit TODO REMOVED, ABILITY MEANINGLESS, SAME AS CARD WITH HIGHER BASE CD
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] elements:@[] rarity:cardRarityCommon minPoints:0 maxPoints:0 maxCount:1 minCost:2],
                     //add to attacker on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[DEFENSIVE_ELEMENTS] rarity:cardRarityRare minPoints:35 maxPoints:80 maxCount:1 minCost:2],
                     //add to attacker on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnDeath targetType:targetAttacker withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] elements:@[ELEMENT_ICE] rarity:cardRarityExceptional minPoints:25 maxPoints:100 maxCount:1 minCost:1],
                     //add to all enemy on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_ICE, ELEMENT_DARK] rarity:cardRarityExceptional minPoints:120 maxPoints:240 maxCount:1 minCost:3], //dark only?
                     //add to one random enemy on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnDeath targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityRare minPoints:40 maxPoints:80 maxCount:1 minCost:1],
                     //add to all minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnDeath targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_ICE] rarity:cardRarityLegendary minPoints:90 maxPoints:180 maxCount:1 minCost:1],
                     //add to random enemy minion on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnMove targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[FIRE_AND_ICE] rarity:cardRarityUncommon minPoints:50 maxPoints:100 maxCount:1 minCost:3],
                     //add to all enemy minions on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddCooldown castType:castOnMove targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] elements:@[ELEMENT_ICE] rarity:cardRarityLegendary minPoints:250 maxPoints:250 maxCount:1 minCost:4], //this is potentially op as hell since it's perma freeze, so may be hard to balance, should be legendary
                     
                     //---lose cooldown---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //lose for 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityCommon minPoints:80 maxPoints:200 maxCount:2 minCost:0], //this shouldnt be for neutral? swap with 1 friendly
                     //lose for 1 friendly minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_LIGHTNING] rarity:cardRarityUncommon minPoints:80 maxPoints:200 maxCount:2 minCost:0],
                     //lose for all friendly minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityLegendary minPoints:250 maxPoints:400 maxCount:1 minCost:2],
                     //lose for all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityLegendary minPoints:230 maxPoints:370 maxCount:1 minCost:2], //this shouldnt be much cheaper since -1 for enemy will mostly have no effect
                     //lose on damage taken
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_ICE] rarity:cardRarityExceptional minPoints:30 maxPoints:60 maxCount:2 minCost:1], //TODO maybe should actually be based on attack?
                     //lose to all friendly minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnDeath targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityExceptional minPoints:150 maxPoints:250 maxCount:1 minCost:3],
                     //lose to all minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnDeath targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityExceptional minPoints:60 maxPoints:140 maxCount:1 minCost:2], //really cheap because dying on enemy turn will actually hurt you
                     //REMOVED used to be lose cd of friendly minion on end of turn, which is useless except for 2+ cd
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnMove targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] elements:@[] rarity:cardRarityLegendary minPoints:85 maxPoints:85 maxCount:1 minCost:1],
                     
                     //---add max cooldown---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //add for 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@3] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityCommon minPoints:90 maxPoints:270 maxCount:2 minCost:1],
                     //add for 1 enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@3] withDescription:nil] elements:@[ELEMENT_NEUTRAL] rarity:cardRarityLegendary minPoints:90 maxPoints:270 maxCount:1 minCost:1],
                     //add for 1 random enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@3] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityRare minPoints:75 maxPoints:225 maxCount:2 minCost:1],
                     //add for all enemy minions (very very expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityLegendary minPoints:250 maxPoints:550 maxCount:1 minCost:1],
                     //add for all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnSummon targetType:targetAllMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_DARK] rarity:cardRarityLegendary minPoints:200 maxPoints:420 maxCount:1 minCost:0],
                     //add to victim on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnHit targetType:targetVictimMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@3] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityExceptional minPoints:70 maxPoints:250 maxCount:1 minCost:1],
                     //add to self on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnHit targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_FIRE] rarity:cardRarityExceptional minPoints:0 maxPoints:0 maxCount:1 minCost:3], //depends on stats
                     //add to attacker on damaged (very expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityExceptional minPoints:80 maxPoints:160 maxCount:1 minCost:1],
                     //add to attacker on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnDeath targetType:targetAttacker withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_EARTH] rarity:cardRarityExceptional minPoints:50 maxPoints:100 maxCount:1 minCost:1],
                     //add to all enemy on death (very expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityLegendary minPoints:180 maxPoints:400 maxCount:1 minCost:3],
                     //add to random enemy on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnDeath targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[LIGHTNING_AND_EARTH] rarity:cardRarityExceptional minPoints:50 maxPoints:110 maxCount:1 minCost:1],
                     //add to all minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnDeath targetType:targetAllMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityExceptional minPoints:120 maxPoints:250 maxCount:1 minCost:2],
                     //add to random enemy on move (very expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddMaxCooldown castType:castOnMove targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityRare minPoints:100 maxPoints:220 maxCount:1 minCost:2],
                     
                     //---lose max cooldown---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //lose for 1 minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseMaxCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityRare minPoints:100 maxPoints:200 maxCount:2 minCost:1],
                     //lose for 1 friendly minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseMaxCooldown castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityExceptional minPoints:100 maxPoints:200 maxCount:2 minCost:1],
                     //lose for all friendly minions (very very expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseMaxCooldown castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityLegendary minPoints:300 maxPoints:560 maxCount:1 minCost:2],
                     //lose for all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseMaxCooldown castType:castOnSummon targetType:targetAllMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_LIGHT, ELEMENT_FIRE] rarity:cardRarityLegendary minPoints:280 maxPoints:530 maxCount:1 minCost:3], //barely cheaper since rare for enemy to have cards with high cd
                     //lose to all friendly minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseMaxCooldown castType:castOnDeath targetType:targetAllFriendlyMinions withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityLegendary minPoints:200 maxPoints:380 maxCount:1 minCost:1],
                     //lose to all minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseMaxCooldown castType:castOnDeath targetType:targetAllMinion withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityExceptional minPoints:180 maxPoints:350 maxCount:1 minCost:1],
                     
                     //---assassin---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //minion with assassin
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAssassin castType:castAlways targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_DARK, ELEMENT_LIGHTNING] rarity:cardRarityUncommon minPoints:0 maxPoints:0 maxCount:2 minCost:1], //depends entirely on base stats (inc. cast on hit!)
                     //give assassin to a minion (pretty OP)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAssassin castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityRare minPoints:85 maxPoints:85 maxCount:1 minCost:1],
                     //give assassin to a random enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAssassin castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityRare minPoints:-25 maxPoints:-25 maxCount:1 minCost:3],
                     //give assassin to a random friendly minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAssassin castType:castOnDeath targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityUncommon minPoints:50 maxPoints:50 maxCount:1 minCost:1],
                     
                     //---remove abilities---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //minion with no abilities, but cannot receive debuffs
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castAlways targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_NEUTRAL] rarity:cardRarityRare minPoints:0 maxPoints:0 maxCount:3 minCost:0], //cost depends on creature stats
                     //silence a minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityCommon minPoints:52 maxPoints:52 maxCount:2 minCost:0],
                     //silence an enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_ICE, ELEMENT_EARTH] rarity:cardRarityCommon minPoints:52 maxPoints:52 maxCount:2 minCost:0],
                     //silence all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetAllMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[OFFENSIVE_ELEMENTS] rarity:cardRarityExceptional minPoints:160 maxPoints:160 maxCount:1 minCost:2],
                     //silence all enemy minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityLegendary minPoints:210 maxPoints:210 maxCount:1 minCost:1],
                     //silence random enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityCommon minPoints:40 maxPoints:40 maxCount:2 minCost:0],
                     //silence attacker on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_ICE] rarity:cardRarityExceptional minPoints:30 maxPoints:30 maxCount:1 minCost:1], //rather weak ability, should be high rarity
                     //silence victim on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnHit targetType:targetVictimMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_FIRE] rarity:cardRarityExceptional minPoints:50 maxPoints:50 maxCount:1 minCost:1],
                     //silence one random minion every end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnEndOfTurn targetType:targetOneRandomMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityExceptional minPoints:50 maxPoints:50 maxCount:1 minCost:1],
                     //silence one random enemy minion every end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnEndOfTurn targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityRare minPoints:100 maxPoints:100 maxCount:1 minCost:1],
                     //silence random enemy minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnDeath targetType:targetOneRandomEnemyMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityCommon minPoints:30 maxPoints:30 maxCount:1 minCost:1],
                     //silence all enemy minions on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityCommon minPoints:140 maxPoints:140 maxCount:1 minCost:2],
                     
                     //---gain resource---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //gain x resources immediately (mostly for spell cards, such as gain 2 resource for 0 cost)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddResource castType:castOnSummon targetType:targetHeroFriendly withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityUncommon minPoints:55 maxPoints:110 maxCount:2 minCost:0], //costs half if the card has no other abilities (must be spell card), NOTE the maxPoints cost should be based on rarity's bonus points TODO add for dark?
                     //gain x resources on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddResource castType:castOnHit targetType:targetHeroFriendly withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityExceptional minPoints:50 maxPoints:100 maxCount:1 minCost:1],
                     //gain 1 resource on move
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddResource castType:castOnMove targetType:targetHeroFriendly withDuration:durationForever withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_EARTH] rarity:cardRarityRare minPoints:75 maxPoints:150 maxCount:1 minCost:1],
                     
                     //---return to hand---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //return 1 friendly minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityUncommon minPoints:20 maxPoints:20 maxCount:2 minCost:0],
                     //return 1 minion (much more expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityUncommon minPoints:105 maxPoints:105 maxCount:2 minCost:1],
                     //return all minions
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnSummon targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_DARK] rarity:cardRarityLegendary minPoints:360 maxPoints:360 maxCount:1 minCost:2],
                     //return all friendly minions on summon
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityExceptional minPoints:50 maxPoints:50 maxCount:1 minCost:1],
                     //return 1 random enemy minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnSummon targetType:targetOneRandomEnemyMinion withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityUncommon minPoints:80 maxPoints:80 maxCount:2 minCost:2],
                     //return 1 random minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnSummon targetType:targetOneRandomMinion withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityUncommon minPoints:60 maxPoints:60 maxCount:1 minCost:0],
                     //return attacker on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnDeath targetType:targetAttacker withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_EARTH, ELEMENT_LIGHT] rarity:cardRarityExceptional minPoints:30 maxPoints:30 maxCount:1 minCost:1],
                     //return victim on hit
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnHit targetType:targetVictim withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityExceptional minPoints:70 maxPoints:70 maxCount:1 minCost:1],
                     //return attacker on damaged
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnDamaged targetType:targetAttacker withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[FIRE_AND_ICE] rarity:cardRarityExceptional minPoints:70 maxPoints:70 maxCount:1 minCost:1],
                     //return all minions on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnDeath targetType:targetAllMinion withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityExceptional minPoints:275 maxPoints:275 maxCount:1 minCost:2],
                     //return all friendly minions on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnDeath targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_LIGHT] rarity:cardRarityLegendary minPoints:50 maxPoints:50 maxCount:1 minCost:2],
                     //return all enemy minions on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityReturnToHand castType:castOnDeath targetType:targetAllEnemyMinions withDuration:durationInstant withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityLegendary minPoints:350 maxPoints:350 maxCount:1 minCost:1],
                     
                     //---fracture---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //fracture on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityFracture castType:castOnDeath targetType:targetSelf withDuration:durationInstant withValue:0 withOtherValues:@[@1,@3] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityRare minPoints:0 maxPoints:0 maxCount:2 minCost:0], //note that costs don't change, depends on stats of original minion
                     //fracture on damaged (EXTREMELY expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityFracture castType:castOnDamaged targetType:targetSelf withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_ICE] rarity:cardRarityLegendary minPoints:0 maxPoints:0 maxCount:1 minCost:0], //note that costs don't change. based on stats
                     //fracture on move (EXTREMELY expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityFracture castType:castOnMove targetType:targetSelf withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_EARTH] rarity:cardRarityLegendary minPoints:0 maxPoints:0 maxCount:1 minCost:0], //note that costs don't change. based on stats
                     //fracture on end of turn (EXTREMELY expensive)
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityFracture castType:castOnEndOfTurn targetType:targetSelf withDuration:durationInstant withValue:0 withOtherValues:@[@1,@2] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityLegendary minPoints:0 maxPoints:0 maxCount:1 minCost:0], //note that costs don't change
                     //NOTE: additional fracture abilities' costs needs to be added in cardEditor
                     
                     //---pierce---// //WARNING!!! ADD ADDITIONAL ABILITIES AT BOTTOM, DO NOT INSERT IN MIDDLE!!!
                     //minion with pierce
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityPierce castType:castAlways targetType:targetSelf withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[OFFENSIVE_ELEMENTS] rarity:cardRarityUncommon minPoints:0 maxPoints:0 maxCount:3 minCost:1], //depends on damage
                     //give pierce to a minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityPierce castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_FIRE] rarity:cardRarityRare minPoints:60 maxPoints:60 maxCount:1 minCost:0],
                     //give pierce to a random friendly minion
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityPierce castType:castOnSummon targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityRare minPoints:50 maxPoints:50 maxCount:1 minCost:0],
                     //give pierce to a random friendly minion on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityPierce castType:castOnDeath targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:0 withOtherValues:@[] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_DARK] rarity:cardRarityExceptional minPoints:30 maxPoints:30 maxCount:1 minCost:1],
                     
                     //ADD ADDITIONAL ABILITIES HERE, DO NOT INSERT IN MIDDLE!!!
                     
                     
                     //additional
                     //damage enemy hero on end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnEndOfTurn targetType:targetHeroEnemy withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[DEFENSIVE_ELEMENTS] rarity:cardRarityRare minPoints:30 maxPoints:300 maxCount:1 minCost:2],
                     //damage friendly hero on end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityLoseLife castType:castOnEndOfTurn targetType:targetHeroFriendly withDuration:durationForever withValue:0 withOtherValues:@[@1,@10] withDescription:nil] elements:@[ELEMENT_NEUTRAL, ELEMENT_DARK] rarity:cardRarityUncommon minPoints:-10 maxPoints:-100 maxCount:1 minCost:2], //note that neutral dont have as many good abilities to synergize this with
                     //draw 1 card on end of turn
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityDrawCard castType:castOnEndOfTurn targetType:targetHeroFriendly withDuration:durationForever withValue:0 withOtherValues:@[@1,@1] withDescription:nil] elements:@[ELEMENT_LIGHTNING] rarity:cardRarityRare minPoints:170 maxPoints:170 maxCount:1 minCost:3],
                     //heal enemy hero on death
                     [[AbilityWrapper alloc] initWithAbility:
                      [[Ability alloc] initWithType:abilityAddLife castType:castOnDeath targetType:targetHeroEnemy withDuration:durationForever withValue:0 withOtherValues:@[@1,@15] withDescription:nil] elements:@[ELEMENT_DARK] rarity:cardRarityCommon minPoints:-5 maxPoints:-75 maxCount:2 minCost:1],
    ];
    
    //use this to print out all abilities for temp card design
    
    
    NSMutableArray *counts = [NSMutableArray arrayWithArray:@[@0,@0,@0,@0,@0,@0,@0]];
    
    for (int i = 0; i < [allAbilities count]; i++)
    {
        AbilityWrapper *wrapper = allAbilities[i];
        
        for (int element = 0; element < 7; element++)
        {
            if ([wrapper isCompatibleWithElement:element])
                counts[element] = [NSNumber numberWithInt:[counts[element]intValue]+1];
        }
        
        //NSLog(@"%d %d %d %d", i, wrapper.ability.abilityType, wrapper.ability.castType, wrapper.ability.targetType);
    }
    
    NSLog(@"NEUTRAL %@", counts[0]);
    NSLog(@"FIRE %@", counts[1]);
    NSLog(@"ICE %@", counts[2]);
    NSLog(@"THUNDER %@", counts[3]);
    NSLog(@"EARTH %@", counts[4]);
    NSLog(@"LIGHT %@", counts[5]);
    NSLog(@"DARK %@", counts[6]);
    
    
    //for (int element = 0; element < 7; element++)
    //{
       
        for (int i = 0; i < [allAbilities count]; i++)
        {
            AbilityWrapper *wrapper = allAbilities[i];
            
            if ([wrapper isCompatibleWithElement:elementDark])
            {
                NSString*abilityDescription = [[Ability getDescription:wrapper.ability fromCard:[[SpellCardModel alloc]initWithIdNumber:-1]] string];
                NSLog(@"%@ LIMIT: %d RARITY: %d", abilityDescription, wrapper.maxCount, wrapper.rarity );
            }
        }
    //}
}



@end
