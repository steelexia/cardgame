//
//  Ability.h
//  cardgame
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardModel.h"
#import "SpellCardModel.h"
#import "MonsterCardModel.h"

/** Represents an ability a card has. Can be a card's original ability, or added by a spell card or another card's ability */
@interface Ability : NSObject

/** Determines the type of ability */
@property enum AbilityType abilityType;

/** Determines what can be targetted by this skill */
@property enum TargetType targetType;
@property enum CastType castType;
@property enum DurationType durationType;

/** Set to YES if this ability came with the card, NO if it is applied from elsewhere (including an ability it used on itself */
@property BOOL isBaseAbility;

/** Stores the main value of the ability. This is sufficient for most abilities, such as +1000 damage, +1000 life, or -1 cooldown. */
@property NSNumber *value;

/** Stores the other values of the ability. Most abilities will have this as nil, but some abilities may need additional values (such as deal 1000-5000 damage) */
@property NSArray *otherValues;

-(instancetype) initWithType: (enum AbilityType) abilityType castType: (enum CastType) castType targetType: (enum TargetType) targetType withDuration: (enum DurationType) durationType withValue: (NSNumber*) value;

-(instancetype) initWithType: (enum AbilityType) abilityType castType: (enum CastType) castType targetType: (enum TargetType) targetType withDuration: (enum DurationType) durationType  withValue: (NSNumber*) value withOtherValues: (NSArray*) otherValues;

/** Generate a description in String of the ability */
+(NSString*) getDescription: (Ability*) ability fromCard:(CardModel*) cardModel;


@end

/** AbilityType describes the stat that it modifies, or the general effect that it creates. */
enum AbilityType
{
    abilityNil, //acts as nil pointer
    abilityAddDamage,
    abilityLoseDamage,
    abilityAddLife, //heal
    abilityAddMaxLife, //also heals
    abilityLoseLife,
    abilityKill,
    abilitySetCooldown, //mostly used for setting it to 0
    abilityAddCooldown,
    abilityAddMaxCooldown,
    abilityLoseCooldown,
    abilityLoseMaxCooldown,
    
    //future
    abilityLeech, //gain life equal to x% of damage
    abilityTaunt, //enemy must attack this. Spells are ignored
    abilityFracture, //split into ~1-3 monsters with 60%, 25%, and 10% original stats
    abilityDrawCard, //draw x number of cards, instant effect
};

/** TargetType determines where the ability is applied to. targetSelf is automatically used by the card with the effect, while most others are casted explicitly.
    COMPATIBILITY: selectable targets (such as targetOne, targetHeroAny) can only be used with CastType onSummon.
    targetVictim MUST be used with castOnHit.
 */
enum TargetType
{
    targetNil,
    targetSelf, //not for spell cards, and is applied automatically
    targetVictim, //not for spell cards, victim is monsterCard attacked by attacker. MUST be used with onHit
    targetAttacker, //not for spell cards, attacker is monsterCard that attacked this card. Must be used with castOnDamaged or castOnDeath
    targetOneAny,
    targetOneFriendly,
    targetOneEnemy,
    targetAll,
    targetAllMinion,
    targetAllFriendly,
    targetAllFriendlyMinions,
    targetAllEnemy,
    targetAllEnemyMinions,
    targetOneRandomAny,
    targetOneRandomMinion,
    targetOneRandomFriendly,
    targetOneRandomFriendlyMinion,
    targetOneRandomEnemy,
    targetOneRandomEnemyMinion,
    targetHeroAny,
    targetHeroFriendly,
    targetHeroEnemy,
    
    //additional possibilities
    targetOneTaunt,
    targetEnemyMostLife,
    targetEnemyMostDamage,
};

/** CastType determines when it is casted.  */
enum CastType
{
    castNil,
    castOnSummon, //all spell cards
    castAlways, //this effect is always on. use for abilities that has already been applied. CANNOT be used with selectable target
    castOnHit, //effect applied on the monster it hits. CANNOT be used with selectable target
    castOnDamaged, //effect applied on the monster that attacks it. CANNOT be used with selectable target
    castOnMove, //whenever its cooldown reaches 0. CANNOT be used with selectable target
    castOnEndOfTurn, //whenever the turn ends, even if cooldown is not 0, note that this does not mean it disappears after turn is over, that is DurationType. CANNOT be used with selectable target
    castOnDeath, //CANNOT be used with selectable target
};

/** DurationType determines when it is removed */
enum DurationType
{
    durationNil,
    durationInstant, //default for most spells that creates a single, instant effect. Buffs that affect stats MUST NOT use this
    durationUntilEndOfTurn, //effect lasts until end of turn
    durationUntilDeath, //effect lasts until summoner's death (for monsterCards) TODO not done yet (in future it can be +X damage to all friendlies if alive)
    durationForever, //buffs on a monster card lasts forever (of course until the buffed card dies).
    //nothing complicated here as it's more code to keep track of a timer
};