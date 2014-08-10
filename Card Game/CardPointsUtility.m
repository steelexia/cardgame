//
//  CardPointsUtility.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-08.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CardPointsUtility.h"

@implementation CardPointsUtility

+(int)getMaxPointsForCard:(CardModel*)card
{
    int maxCost = 1000; //base
    maxCost += card.cost * 1000;
    
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
    int count = 2;
    
    //TEMPORARY FOR TESTING TODO:
    if (card.rarity == cardRarityCommon)
        count = 4;
    
    if (card.rarity >= cardRarityLegendary)
        count = 4;
    else if (card.rarity >= cardRarityRare)
        count = 3;
    
    if ([card isKindOfClass:[SpellCardModel class]])
        count++;
    
    return count;
}

+(int)getMaxCostForCard:(CardModel*)card
{
    //TEMPORARY FOR TESTING TODO:
    if (card.rarity == cardRarityCommon)
        return 10;
    
    return card.rarity + 6;
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
        points -= 250; //experimental: no damange = can't attack = gain some extra points
    else
    {
        BOOL hasTaunt = [CardPointsUtility cardHasTaunt:monster];
        
        //no taunt, every 1k attack is worth 500 points, and divided by cooldown
        if (hasTaunt)
        {
            points += ceil(monster.damage / 2 / (monster.maximumCooldown == 0 ? 1 : monster.maximumCooldown));
        }
        //has taunt, cooldown provides much fewer reduction
        else
        {
            double cooldown = (monster.maximumCooldown == 0 ? 1 : monster.maximumCooldown);
            if (cooldown > 1)
                cooldown = cooldown/15.f + 1; //only about 20% more damage at cooldown of 5
            
            points += ceil(monster.damage / 2 / cooldown);
        }
    }
    
    points += ceil(monster.maximumLife / 2);
    
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
            abilityCost += monster.damage * 0.5 / cooldown;
            abilityCost += monster.life * 0.5;
            
            if (castType == castOnDamaged)
                abilityCost *= 2;
            else if (castType == castOnEndOfTurn)
                abilityCost *= 3;
            else if (castType == castOnMove)
                abilityCost *= 3;
        }
        else if (abilityType == abilityLoseDamage)
        {
            //lose damage abilities' negative points are capped by the minion's actual damage. e.g. if minion has 2000 damage, -2500 damage on hit is same as -2000
            if (targetType == targetSelf)
            {
                if (castType == castOnHit)
                {
                    if (![CardPointsUtility cardHasTaunt:card]) //taunt removes the bonus
                    {
                        if (abilityCost < -monster.damage*0.1)
                            abilityCost = -monster.damage*0.1;
                    }
                }
                else if (castType == castOnDamaged)
                {
                    if (abilityCost < -monster.damage*0.2)
                        abilityCost = -monster.damage*0.2;
                }
                else if (castType == castOnMove)
                {
                    if (abilityCost < -monster.damage*0.4)
                        abilityCost = -monster.damage*0.4;
                }
            }
        }
        else if (abilityType == abilityAddCooldown || abilityType == abilityAddMaxCooldown)
        {
            if (targetType == targetSelf)
            {
                //adding cooldown to self depends on the damage
                if (castType == castOnHit)
                {
                    if (![CardPointsUtility cardHasTaunt:card]) //taunt removes the bonus
                    {
                        if (abilityType == abilityAddCooldown)
                            abilityCost = -monster.damage*0.1;
                        else if (abilityType == abilityAddMaxCooldown)
                            abilityCost = -monster.damage*0.2;
                    }
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
                    //costs 10% of stats
                    abilityCost += monster.damage * 0.1;
                    abilityCost += monster.life * 0.1;
                }
                else if (abilityType == abilityAssassin)
                {
                    //costs 40% of stats
                    abilityCost += monster.damage * 0.25;
                    abilityCost += monster.life * 0.25;
                    abilityCost /= monster.maximumCooldown == 0 ? 1 : monster.maximumCooldown;
                    
                    //damageless assassin has it cheaper
                    if (monster.damage == 0)
                        abilityCost *= 0.6;
                }
                else if (abilityType == abilityPierce)
                {
                    abilityCost += monster.damage * 0.1;
                }
            }
        }
        else if (castType == castOnSummon)
        {
            //if is charge (assuming value = 0)
            if (abilityType == abilitySetCooldown && targetType == targetSelf)
            {
                abilityCost += monster.damage; //having charge is equivalent in cost as having a deal damage ability
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
