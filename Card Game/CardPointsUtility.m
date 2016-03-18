//
//  CardPointsUtility.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-08.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CardPointsUtility.h"

@implementation CardPointsUtility

/* stats multiplied by this number is its cost (life or attack) */
const int STAT_MULTIPLIER = 10;

/* Minimum amount of points a monster (with no abilities) can be at */
const int MIN_MONSTER_POINTS = 2 * STAT_MULTIPLIER;

+(int)getMaxPointsForCard:(CardModel*)card
{
    int maxCost = 50; //base
    maxCost += card.cost * 50;
    
    //rarity gives bonus to max cost
    if (card.rarity == cardRarityUncommon)
        maxCost *= 1.05;
    else if (card.rarity == cardRarityRare)
        maxCost *= 1.1;
    else if (card.rarity == cardRarityExceptional)
        maxCost *= 1.15;
    else if (card.rarity == cardRarityLegendary)
        maxCost *= 1.25;
    
    return maxCost;
}

+(int)getMaxAbilityCountForCard:(CardModel*)card
{
    int count = 1;
    
#ifdef DEBUG_COST
    count = 4;
#else
    if ([card isKindOfClass:[MonsterCardModel class]])
    {
        if (card.rarity == cardRarityCommon)
            count = 1;
        else if (card.rarity == cardRarityUncommon)
            count = 1;
        else if (card.rarity == cardRarityRare)
            count = 2;
        else if (card.rarity == cardRarityExceptional)
            count = 2;
        else if (card.rarity == cardRarityLegendary)
            count = 3;

    }
    else if ([card isKindOfClass:[SpellCardModel class]])
    {
        if (card.rarity == cardRarityCommon)
            count = 1;
        else if (card.rarity == cardRarityUncommon)
            count = 2;
        else if (card.rarity == cardRarityRare)
            count = 2;
        else if (card.rarity == cardRarityExceptional)
            count = 3;
        else if (card.rarity == cardRarityLegendary)
            count = 4;
    }
#endif
    
    return count;
}

+(int)getMaxCostForCard:(CardModel*)card
{
#ifdef DEBUG_COST
    return 10;
#else
    return card.rarity + 6;
#endif
    
}

+(int)getWrappersTotalPoints:(NSArray*)wrappers forCard:(CardModel*)card
{
    int points = 0;
    for (AbilityWrapper*curWrapper in wrappers)
    {
        [CardPointsUtility updateAbilityPoints:card forWrapper:curWrapper withWrappers:wrappers];
        points += curWrapper.currentPoints;
    }
    return points;
}

+(int)getStatsPointsForMonsterCard:(MonsterCardModel*)monster
{
    int points = 0;
    //TODO it's much more complicated (add damage/life modifiers from abilities)
    if (monster.damage == 0)
        points -= 5 * STAT_MULTIPLIER; //no damange = can't attack = gain some extra points
    else
    {
        BOOL hasTaunt = [CardPointsUtility cardHasTaunt:monster];
        
        //no taunt, every 1 attack is worth STAT_MULTIPLIER points, and divided by cooldown
        if (hasTaunt)
        {
            points += ceil(monster.damage * STAT_MULTIPLIER / (monster.maximumCooldown == 0 ? 1 : monster.maximumCooldown));
        }
        //has taunt, cooldown provides much fewer reduction
        else
        {
            double cooldown = (monster.maximumCooldown == 0 ? 1 : monster.maximumCooldown);
            if (cooldown > 1)
                cooldown = cooldown/15.f + 1; //only about 20% more damage at cooldown of 5
            
            points += ceil(monster.damage * STAT_MULTIPLIER / cooldown);
        }
    }
    
    points += ceil(monster.maximumLife * STAT_MULTIPLIER);
    
    if (points < MIN_MONSTER_POINTS)
        points = MIN_MONSTER_POINTS;
    
    return points;
}

+(BOOL)cardHasTaunt:(CardModel*)card
{
    
    if ([card isKindOfClass:[MonsterCardModel class]])
        for (Ability *ability in card.abilities)
            if (ability.abilityType == abilityTaunt && ability.targetType == targetSelf && ability.castType == castAlways)
                return YES;
    
    return NO;
}

+(BOOL)cardHasAssassin:(CardModel*)card
{
    if ([card isKindOfClass:[MonsterCardModel class]])
        for (Ability *ability in card.abilities)
            if (ability.abilityType == abilityAssassin && ability.targetType == targetSelf && ability.castType == castAlways)
                return YES;
    return NO;
}

/** Charge means on summon set self cooldown to 0 */
+(BOOL)cardHasCharge:(CardModel*)card
{
    if ([card isKindOfClass:[MonsterCardModel class]])
        for (Ability *ability in card.abilities)
            if (ability.abilityType == abilitySetCooldown && ability.targetType == targetSelf && ability.castType == castOnSummon)
                return YES;
    
    return NO;
}

+(void)updateAbilityPoints:(CardModel*)card forWrapper:(AbilityWrapper*)wrapper withWrappers:(NSArray*)wrappers
{
    int abilityCost = 0;
    
    enum CastType castType = wrapper.ability.castType;
    enum AbilityType abilityType = wrapper.ability.abilityType;
    enum TargetType targetType = wrapper.ability.targetType;
    
    //has min and max values, lerp the abilityCost
    if (wrapper.ability.otherValues != nil && wrapper.ability.otherValues.count >= 2)
    {
        int minValue = [wrapper.ability.otherValues[0] intValue];
        int maxValue = [wrapper.ability.otherValues[1] intValue];
        int valueDifference = maxValue - minValue;
        
        if (valueDifference == 0)
            valueDifference = 1;
        
        int currentValue = [wrapper.ability.value intValue] - minValue;
        double valuePercent = (double)currentValue / valueDifference;
        
        abilityCost = ceil(((wrapper.maxPoints - wrapper.minPoints)*valuePercent) + wrapper.minPoints);
    }
    //no adjustable value/cost, just use min points
    else
    {
        abilityCost = wrapper.minPoints;
    }
    
    wrapper.basePoints = abilityCost;
    
    //monster card specific stuff
    if ([card isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel*monster = (MonsterCardModel*)card;
        
        //fracture ability is a special case
        if (abilityType == abilityFracture)
        {
            //base cost
            int cooldown = (monster.maximumCooldown == 0 ? 1 : monster.maximumCooldown);
            abilityCost += monster.damage * STAT_MULTIPLIER / cooldown;
            abilityCost += monster.life * STAT_MULTIPLIER;
            
            if (castType == castOnDamaged)
                abilityCost *= 1.5;
            else if (castType == castOnEndOfTurn)
                abilityCost *= 2.5;
            else if (castType == castOnMove)
                abilityCost *= 1.8;
        }
        else if (abilityType == abilityLoseDamage)
        {
            //lose damage abilities' negative points are capped by the minion's actual damage. e.g. if minion has 2000 damage, -2500 damage on hit is same as -2000
            if (targetType == targetSelf)
            {
                int minPoints = wrapper.minPoints; //ASSUMING LINEAR POINTS
                if (castType == castOnHit)
                {
                    if (![CardPointsUtility cardHasTaunt:card]) //taunt removes the bonus TODO shouldn't remove, should just be big penalty
                    {
                        if (abilityCost < -monster.damage*minPoints) //multiplied by points cost
                            abilityCost = -monster.damage*minPoints;
                    }
                }
                else if (castType == castOnDamaged)
                {
                    if (abilityCost < -monster.damage*minPoints)
                        abilityCost = -monster.damage*minPoints;
                }
                else if (castType == castOnMove)
                {
                    if (abilityCost < -monster.damage*minPoints)
                        abilityCost = -monster.damage*minPoints;
                }
            }
        }
        else if (abilityType == abilityAddMaxCooldown)
        {
            if (targetType == targetSelf)
            {
                //adding cooldown to self depends on the damage
                if (castType == castOnHit)
                {
                    float multiplier = 0;
                    
                    if ([CardPointsUtility cardHasTaunt:card]) //taunt has less bonus
                    {
                        multiplier = 0.2;
                    }
                    else
                    {
                        multiplier = 0.5;
                    }
                    
                    abilityCost = -monster.damage * STAT_MULTIPLIER * multiplier;
                }
            }
        }
        if (castType == castAlways)
        {
            if (targetType == targetSelf)
            {
                //taunt has its special case for values
                if (abilityType == abilityTaunt)
                {
                    //costs % of stats
                    abilityCost += (monster.damage + monster.maximumLife) * STAT_MULTIPLIER * 0.05;
                }
                else if (abilityType == abilityAssassin)
                {
                    //costs % of stats
                    abilityCost += (monster.damage + monster.maximumLife) * STAT_MULTIPLIER * 0.125;
                    abilityCost /= monster.maximumCooldown == 0 ? 1 : monster.maximumCooldown;
                    
                    //damageless assassin has it cheaper
                    if (monster.damage == 0)
                        abilityCost *= 0.6;
                }
                else if (abilityType == abilityPierce)
                {
                    abilityCost += monster.damage * STAT_MULTIPLIER * 0.3;
                }
                else if (abilityType == abilityRemoveAbility)
                {
                    abilityCost += (monster.damage + monster.maximumLife) * STAT_MULTIPLIER * 0.05;
                }
            }
            
            //these cannot be free or negative
            if (abilityCost <= 0)
                abilityCost = 1;
        }
        else if (castType == castOnSummon)
        {
            //if is charge (assuming value = 0)
            if (abilityType == abilitySetCooldown && targetType == targetSelf)
            {
                abilityCost += monster.damage * STAT_MULTIPLIER * 1.2; //having charge is equivalent in cost as having a deal damage ability
                //NOTE: affects cast on hit abilities' cost
            }
        }
        
        //save again since above are abilities with no cost
        wrapper.basePoints = abilityCost;
        
        
        //cast on move and hit's points are divided by the max cooldown
        if (castType == castOnMove || castType == castOnHit)
        {
            if (castType == castOnHit)
            {
                //having assassin makes cast on hit MUCH better
                if ([CardPointsUtility cardHasAssassin:card])
                {
                    abilityCost *= 1.4;
                }
                else
                    
                    //charge makes this even more expensive
                    if ([CardPointsUtility cardHasCharge:card])
                    {
                        abilityCost *= 1.75;
                    }
                    else
                        
                        //cast on hit with no damage from the minion
                        if (monster.damage == 0)
                        {
                            //all negative becomes useless
                            if (abilityCost < 0)
                                abilityCost = 0;
                            //positive gets discount
                            else
                                abilityCost *= 0.6;
                        }
            }
            
            abilityCost /= monster.maximumCooldown == 0 ? 1 : monster.maximumCooldown;
        }
        else if (castType == castOnDamaged || castType == castOnDeath)
        {
            BOOL hasTaunt = [CardPointsUtility cardHasTaunt:card];
            
            if (hasTaunt)
            {
                //has taunt, becomes more expensive, although multiplier doesn't work on negative abilities
                if (abilityCost > 0)
                {
                    if (castType == castOnDeath)
                        abilityCost *= 1.15;
                    else if (castType == castOnDamaged)
                        abilityCost *= 1.45;
                }
            }
            else
            {
                //no taunt, no damage
                if (monster.damage == 0)
                {
                    //negative abilities become useless since nobody will attack it anyways
                    if (abilityCost < 0)
                        abilityCost = 0;
                    else
                    {
                        //positive abilities receive discount
                        if (castType == castOnDeath)
                            abilityCost *= 0.6;
                        else if (castType == castOnDamaged)
                            abilityCost *= 0.5;
                    }
                }
            }
        }
        
    }
    else if ([card isKindOfClass:[SpellCardModel class]])
    {
        if (abilityType == abilityAddResource)
        {
            if (targetType == targetHeroFriendly && castType == castOnSummon)
            {
                //half off if ability is spell card and has no other abilities
                if (wrappers.count == 0 || (wrappers.count == 1 && [wrapper.ability isEqualTypeTo:[wrappers[0] ability]]))
                    abilityCost *= 0.5;
            }
        }
    }
    
    wrapper.currentPoints = abilityCost;
}


@end
