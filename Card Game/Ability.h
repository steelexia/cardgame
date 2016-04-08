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

/** If abilityh as custom description, this is used. */
@property NSString *description;

/** Stores the main value of the ability. This is sufficient for most abilities, such as +1000 damage, +1000 life, or -1 cooldown. Note that it MUST store integers. Decimal numbers (such as 33%) must be written in whole numbers. (such as 33 not 0.33) */
@property NSNumber *value;

/** Stores other values needed. Note that inside a wrapper it instead stores all the ranges. TODO otherValues is currently not implemented to actually work for extra values. It is only for storing range of value for now. To add the functionality make sure to edit CardEditViewController (add new buttons) and follow the format from comments of AbilityWrapper */
@property NSArray *otherValues;

/** YES if the duration has already expired, such as durationUntilEndOfTurn. Once this is YES, it will no longer trigger. */
@property BOOL expired;

/** Checks if all types (castType, abilityType etc) is identical. Does not check the actual values! */
-(BOOL)isEqualTypeTo:(Ability*)ability;

/** Returns YES if the two ability is compatible, i.e. can exist in the same card */
-(BOOL)isCompatibleTo:(Ability*)ability;

-(instancetype) initWithType: (enum AbilityType) abilityType castType: (enum CastType) castType targetType: (enum TargetType) targetType withDuration: (enum DurationType) durationType withValue: (NSNumber*) value;

-(instancetype) initWithType: (enum AbilityType) abilityType castType: (enum CastType) castType targetType: (enum TargetType) targetType withDuration: (enum DurationType) durationType  withValue: (NSNumber*) value withOtherValues: (NSArray*) otherValues;

-(instancetype) initWithType: (enum AbilityType) abilityType castType: (enum CastType) castType targetType: (enum TargetType) targetType withDuration: (enum DurationType) durationType  withValue: (NSNumber*) value withOtherValues: (NSArray*) otherValues withDescription: (NSString*) description;

/** Copies an ability */
-(instancetype) initWithAbility: (Ability*) ability;

/** Generate a description in String of the ability */
+(NSMutableAttributedString*) getDescription: (Ability*) ability fromCard:(CardModel*) cardModel;

/** Get all of the description needed */
+(NSString*) getDescriptionForBaseAbilities: (CardModel*) card;

+(NSMutableArray*)getAbilityKeywordDescriptions: (CardModel*)card;

+(BOOL)abilityIsSelectableTargetType:(Ability*)ability;

@end

/** AbilityType describes the stat that it modifies, or the general effect that it creates. */
enum AbilityType
{
    //WARNING: PUT ALL ADDITIONS AT THE BOTTOM OF THE LIST, DO NOT INSERT IN MIDDLE
    /** Acts as nil pointer. Should never use this */
    abilityNil,
    
    /** Gives a minion more damage */
    abilityAddDamage,
    /** Makes a minion lose damage */
    abilityLoseDamage,
    /** Heals a minion, cannot go above maxLife, do not target hero */
    abilityAddLife,
    /** Adds x to both minion's life and maxLife */
    abilityAddMaxLife,
    /** Damages a minion */
    abilityLoseLife,
    /** Instantly kills a minion regardless of health */
    abilityKill,
    /** Sets a minion's cooldown to x. Useful for setting to 0 (i.e. attack immediately) */
    abilitySetCooldown,
    /** Adds cooldown to a minion, can be above max */
    abilityAddCooldown,
    /** Adds both a minion's cooldown and maxCooldown */
    abilityAddMaxCooldown,
    /** Makes a minion lose its cooldown, cannot become lower than 0 */
    abilityLoseCooldown,
    /** Makes a minion lose both cooldown and maxCooldown. Cannot be lower than 0. */
    abilityLoseMaxCooldown,
    /** Enemy minions must target this card when attacking. durationType can be anything except instant, but in almost all cases it should be durationAlways */
    abilityTaunt,
    /** 
     Draws x number of cards for the caster.
     targetType should be: targetHeroEnemy to draw card for enemy, targetHeroFriendly to draw card for caster, or targetAll to draw for both.
     */
    abilityDrawCard,
    /** Target abilities become useless and prevents target from receiving more. Note that this doesn't prevent instant abilities targetting this, such as kill, deal damage, heal, etc. The only ones that are blocked are abilities that stay */
    abilityRemoveAbility,
    /** Does not take damage from defender when attacking. It also won't be targetted by defender's onDamaged abilities */
    abilityAssassin,
    /** Adds x point of resources to the target player. targetType should be same as abilityDrawCard: targetHeroFriendly, targetHeroEnemy, targetAll. */
    abilityAddResource,
    /** Returns a minion to the owner's hand. DO NOT combine this with targetSelf and castOnSummon. (Doesn't make sense anyways) */
    abilityReturnToHand,
    /** Extra damage dealt to a destroyed enemy is dealt to the enemy hero. NOTE: spell cards cannot pierce because its damage is anonymously dealt (also since it's an ability not a direct damage) */
    abilityPierce,
    /** split into ~1-3 monsters with 60%, 25%, and 10% original stats, but no abilities */
    abilityFracture,
    /** Doesn't actually do anything. Instead the monster will have the heroic variable set to YES, which treats it as a hero. This means it cannot be targetted by any ability that targets only minions. SINGLE PLAYER ONLY! */
    abilityHeroic,
    /** Single player only TODO not completely implemented */
    abilitySetDamage,
    /** Single player only, chapter 3 boss, uses value for card ID, uses 3 otherValues for attack, life, and campaign difficulty */
    abilitySummonFighter,
    
    //------------------NOT YET IMPLEMENTED-----------------//
    /* kill a card if its health is below x. Good for low number such as below 1000 to kill off monsters that would have died if damage/life were 1000 times smaller. TODO */
    abilityKillIfBelowHealth,
    abilityLeech, //gain life equal to x% of damage
    
    abilityFaceDown, //card is placed faced down until it attacks or is attacked (REALLY cool)
    abilityHideLife, //hide a card's health (or maybe only hero), only a visual effect
    
    abilityReflect, //reflect x% of damage deal by the attacker instead of its attack
    
    abilitySpellImmunity, //might be only for single player, target is immune to all spells and abilities
    
    /** Frozen minions cannot attack or deal recoil damage. Duration should almost always be untilEndOfTurn, or else the minion will be frozen forever (until silenced). ice TODO */
    abilityFreeze,
    /** Burning minions take x damage to itself and deals the same amount to all other minions on the same field. Perhaps burns do not stack and only the strongest burn will have effect per side. Damage will likely be very small (~300-1000), fire TODO */
    abilityBurn,
    /** Poisoned minions take x damage per turn. Deals much more than burn (~500-3000), earth TODO */
    abilityPoison,
    /** Shocked minions take x times (e.g. 2 = 2x) amount of damage per turn. lightning maybe TODO */
    abilityShock,
    /**  dark TODO */
    abilityCorrupt,
    /** Becomes invulnerable (pretty much always until end of turn) light TODO */
    abilityBless,
    /** Summons a fake minion of a random element with fake stats (probably copies name and image of a random minion from deck, with random stats). It dies immediately to any attack. Probably the summoned minion is casted along castOnSummon abilities so the spell card is not wasted. (e.g. for 3 cost summon a fake 4000/2000 minion with onSummon deal damage to a minion, so not only the spell card has effect, the minion would look real) TODO  */
    abilityImage,
    /** Card can be added to the deck above the regular limit. Maybe ~2-3 limit for this ability, so can have max of 23 cards in total. This card costs a lot of points, so it'd be a poor card for the benefit of having more cards to draw  TODO*/
    abilityExtraCard,
    /** Must be targetSelf and onSummon. It summons a twin card with identical stats. Cost should be more than half the total points available to a card. This allows having more abilities than limit  TODO*/
    abilityTwin,
    /** On attack, all friendly minions of type X (probably element type, such as lightnin)'s damage is added onto the attack. TODO */
    abilityConcentrate,
    /** Change target's element to neutral */
    abilityNullify,
    /** one-time removal of all added abilities */
    abilityPurify,
    /** Copies the stats of a card (i.e. only damage, life, and maxCooldown) */
    abilityCopyStats,
    /** Randomly gains a stat modifying ability */
    abilityInstability,
    /** Cannot be targetted by monster attacks */
    abilityAcrobatics,
    /** Randomly targetted abilities always hit this minion (or one of it if there are multiple on field) */
    abilityAttract,
};

/** TargetType determines where the ability is applied to. targetSelf is automatically used by the card with the effect, while most others are casted explicitly.
    COMPATIBILITY: selectable targets (such as targetOne, targetHeroAny) can only be used with CastType onSummon.
    targetVictim MUST be used with castOnHit.
 */
enum TargetType
{
    //WARNING: PUT ALL ADDITIONS AT THE BOTTOM OF THE LIST, DO NOT INSERT IN MIDDLE
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
    targetOneEnemyMinion,
    targetOneFriendlyMinion, //23
    targetOneAnyMinion,
    /** This can only work if target is a minion. */
    targetVictimMinion,
    
    //additional possibilities
    targetOneTaunt,
    targetEnemyMinionMostLife,
    targetEnemyMinionMostDamage,
    
    //TODO unsure how to do element targets
};

/** CastType determines when it is casted.  */
enum CastType
{
    //WARNING: PUT ALL ADDITIONS AT THE BOTTOM OF THE LIST, DO NOT INSERT IN MIDDLE
    castNil,
    /** As soon as the card is summoned. All spellCard's abilities MUST use this type. */
    castOnSummon,
    /** This effect is always on. Or this ability that has already been applied. CANNOT be used with selectable target */
    castAlways,
    castOnHit, //effect applied on the monster it hits. CANNOT be used with selectable target
    /** Effect applied on the monster that attacks it. CANNOT be used with selectable target, and MUST NOT be used with abilityLoseLife, since it will result in loops (except in specific combinations such as targetAttacker) */
    castOnDamaged,
    /** Whenever the minion's cooldown reaches 0. DO NOT use with any ability that loses cooldown. It could easily result in infinite loops of cooldown loss. CANNOT be used with selectable target. 
     NOTE: This can only be triggered at the start of a turn. Even if a monster has its CD reduced to 0 during a turn, castOnMove will not trigger. This again prevents infinite loops.
     */
    castOnMove,
    castOnEndOfTurn, //whenever the turn ends, even if cooldown is not 0, note that this does not mean it disappears after turn is over, that is DurationType. CANNOT be used with selectable target
    castOnDeath, //CANNOT be used with selectable target
    
    //future
    /** TODO */
    castOnAnyMinionDeath,
    /** TODO */
    castOnFriendlyMinionDeath,
    /** TODO */
    castOnEnemyMinionDeath,
    /** Many abilities should be using this one instead */
    castOnStartOfTurn,
};

/** 
 DurationType determines when it is removed. This actually functions differently depending on the other types:
 For any ability with targetSelf, this determines when the ability is removed. E.g. an addDamage with targetSelf and castAlways, durationForever means it wil always stay, and durationUntilEndOfTurn means it will be removed at the end of turn. durationInstant would not make sense in this case.
 For any other abilities, if the ability is an instant ability with a single-cast castType (e.g. castOnSummon, castOnDeath), the durationType should be durationInstant. If it can be casted more than once, the durationType can be others (e.g. durationUntilEndOfTurn with castOnHit means it will cast every hit until end of turn). If the ability is not an instant ability (e.g. buff/debuff), durationType determines when the effect is removed on the target. For example, loseLife is instant ability so durationType should be instant. But addDamage using targetAllMinion with durationUntilEndOfTurn means target minion will receive the effect until end of turn. As a result, the ability itself is effectively durationForever, since there is only one durationType to store essentially two values.
 This means that it is impossible to for example make a minion that for one turn, curse victim minions on hit with damage debuff that lasts until end of turn. In this case, since the targetType is not targetSelf, there is no way to give the minion the ability to curse for a single turn, and it must be forever.
 */
enum DurationType
{
    //WARNING: PUT ALL ADDITIONS AT THE BOTTOM OF THE LIST, DO NOT INSERT IN MIDDLE
    durationNil,
    durationInstant, //default for most spells that creates a single, instant effect. Buffs that affect stats MUST NOT use this
    durationUntilEndOfTurn, //effect lasts until end of turn
    durationUntilDeath, //effect lasts until summoner's death (for monsterCards) TODO not done yet (in future it can be +X damage to all friendlies if alive)
    durationForever, //buffs on a monster card lasts forever (of course until the buffed card dies).
    //nothing complicated here as it's more code to keep track of a timer
};