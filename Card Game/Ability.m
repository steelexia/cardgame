//
//  Ability.m
//  cardgame
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "Ability.h"


@implementation Ability

@synthesize abilityType = _abilityType;
@synthesize targetType = _targetType;
@synthesize durationType = _durationType;
@synthesize castType = _castType;
@synthesize value = _value;
@synthesize otherValues = _otherValues;
@synthesize isBaseAbility = _isBaseAbility;


-(instancetype) initWithType: (enum AbilityType) abilityType castType: (enum CastType) castType targetType: (enum TargetType) targetType withDuration: (enum DurationType) durationType withValue: (NSNumber*) value
{
    self = [super init];
    
    if (self)
    {
        self.abilityType = abilityType;
        self.targetType = targetType;
        self.durationType = durationType;
        self.castType = castType;
        self.value = value;
    }
    
    return self;
};

-(instancetype) initWithType: (enum AbilityType) abilityType castType: (enum CastType) castType targetType: (enum TargetType) targetType withDuration: (enum DurationType) durationType withValue: (NSNumber*) value withOtherValues: (NSArray*) otherValues
{
    self = [self initWithType:abilityType castType: castType targetType: targetType withDuration:durationType withValue:value];
    
    if (self)
    {
        self.otherValues = otherValues;
    }
    
    return self;
};

+(NSString*) getDescription: (Ability*) ability fromCard: (CardModel*) cardModel
{
    enum AbilityType abilityType = ability.abilityType;
    
    NSString *targetDescription = [Ability getTargetTypeDescription:ability.targetType];
    NSString *castDescription = [Ability getCastTypeDescription:ability.castType fromCard:cardModel];
    NSString *durationDescription = [Ability getDurationTypeDescription:ability.durationType];
    
    if (abilityType == abilityNil)
        return [NSString stringWithFormat:@"nil ability"];
    else if (abilityType == abilityAddDamage){
        if (ability.targetType == targetSelf)
            return [NSString stringWithFormat:@"%@+%@ damage%@.", castDescription, ability.value, durationDescription];
        else
            return [NSString stringWithFormat:@"%@+%@ damage to %@%@.", castDescription, ability.value, targetDescription, durationDescription];
    }
    else if (abilityType == abilityLoseDamage){
        if (ability.targetType == targetSelf)
            return [NSString stringWithFormat:@"%@-%@ damage%@.", castDescription, ability.value, durationDescription];
        else
            return [NSString stringWithFormat:@"%@-%@ damage to %@%@.", castDescription, ability.value, targetDescription, durationDescription];
    }
    else if (abilityType == abilityAddLife){
        if (ability.targetType == targetSelf)
            return [NSString stringWithFormat:@"%@Heal %@ life%@.", castDescription, ability.value, durationDescription];
        else
            return [NSString stringWithFormat:@"%@Heal %@ life to %@%@.", castDescription, ability.value, targetDescription, durationDescription];
    }
    else if (abilityType == abilityAddMaxLife){
        if (ability.targetType == targetSelf)
            return [NSString stringWithFormat:@"%@+%@ life%@.", castDescription, ability.value, durationDescription];
        else
            return [NSString stringWithFormat:@"%@+%@ life to %@%@.", castDescription, ability.value, targetDescription, durationDescription];
    }
    else if (abilityType == abilityLoseLife){
        return [NSString stringWithFormat:@"%@Deal %@ damage to %@%@.", castDescription, ability.value, targetDescription, durationDescription];
    }
    else if (abilityType == abilityKill){
        return [NSString stringWithFormat:@"%@destroy %@%@.", castDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilitySetCooldown){
        if (ability.targetType == targetSelf)
            return [NSString stringWithFormat:@"%@set its cooldown to %@%@.", castDescription, ability.value, durationDescription];
        else
            return [NSString stringWithFormat:@"%@set cooldown to %@ for %@%@.", castDescription, ability.value, targetDescription, durationDescription];
    }
    else if (abilityType == abilityAddCooldown){
        if (ability.targetType == targetSelf)
            return [NSString stringWithFormat:@"%@+%@ cooldown%@.", castDescription, ability.value, durationDescription];
        else
            return [NSString stringWithFormat:@"%@+%@ cooldown to %@%@.", castDescription, ability.value, targetDescription, durationDescription];
    }
    else if (abilityType == abilityAddMaxCooldown){
        if (ability.targetType == targetSelf)
            return [NSString stringWithFormat:@"%@+%@ maximum cooldown%@.", castDescription, ability.value, durationDescription];
        else
            return [NSString stringWithFormat:@"%@+%@ maximum cooldown to %@%@.", castDescription, ability.value, targetDescription, durationDescription];
    }
    else if (abilityType == abilityLoseCooldown){
        if (ability.targetType == targetSelf)
        return [NSString stringWithFormat:@"%@-%@ cooldown%@.", castDescription, ability.value, durationDescription];
        else
            return [NSString stringWithFormat:@"%@-%@ cooldown to %@%@.", castDescription, ability.value, targetDescription, durationDescription];
    }
    else if (abilityType == abilityLoseMaxCooldown){
        if (ability.targetType == targetSelf)
            return [NSString stringWithFormat:@"%@-%@ maximum cooldown%@.", castDescription, ability.value, durationDescription];
        else
            return [NSString stringWithFormat:@"%@-%@ maximum cooldown to %@%@.", castDescription, ability.value, targetDescription, durationDescription];
    }

    
    return [NSString stringWithFormat:@"ability %d", ability.abilityType];
}

+(NSString*) getTargetTypeDescription: (enum TargetType) targetType
{
    if (targetType == targetNil)
        return [NSString stringWithFormat:@"nil"];
    else if (targetType == targetSelf)
        return [NSString stringWithFormat:@"itself"]; //special case, may not use this text depending on wording
    else if (targetType == targetVictim)
        return [NSString stringWithFormat:@"target"];
    else if (targetType == targetAttacker)
        return [NSString stringWithFormat:@"attacker"];
    else if (targetType == targetOneAny)
        return [NSString stringWithFormat:@"any minion"];
    else if (targetType == targetOneFriendly)
        return [NSString stringWithFormat:@"any friendly minion"];
    else if (targetType == targetOneEnemy)
        return [NSString stringWithFormat:@"any enemy minion"];
    else if (targetType == targetAll)
        return [NSString stringWithFormat:@"all characters"];
    else if (targetType == targetAllMinion)
        return [NSString stringWithFormat:@"all other minions"];
    else if (targetType == targetAllFriendly)
        return [NSString stringWithFormat:@"all other friendly characters"];
    else if (targetType == targetAllFriendlyMinions)
        return [NSString stringWithFormat:@"all other friendly minions"];
    else if (targetType == targetAllEnemy)
        return [NSString stringWithFormat:@"all enemy minion characters"];
    else if (targetType == targetAllEnemyMinions)
        return [NSString stringWithFormat:@"all enemy minions"];
    else if (targetType == targetOneRandomAny)
        return [NSString stringWithFormat:@"a random character"];
    else if (targetType == targetOneRandomMinion)
        return [NSString stringWithFormat:@"a random minion"];
    else if (targetType == targetOneRandomFriendly)
        return [NSString stringWithFormat:@"a random friendly character"];
    else if (targetType == targetOneRandomFriendlyMinion)
        return [NSString stringWithFormat:@"a random friendly minion"];
    else if (targetType == targetOneRandomEnemy)
        return [NSString stringWithFormat:@"a random enemy character"];
    else if (targetType == targetOneRandomEnemyMinion)
        return [NSString stringWithFormat:@"a random enemy minion"];
    else if (targetType == targetHeroAny)
        return [NSString stringWithFormat:@"any hero"];
    else if (targetType == targetHeroFriendly)
        return [NSString stringWithFormat:@"your hero"];
    else if (targetType == targetHeroEnemy)
        return [NSString stringWithFormat:@"your enemy's hero"];
    
    return [NSString stringWithFormat:@"target type %d", targetType];
}

+(NSString*) getCastTypeDescription: (enum CastType) castType fromCard: (CardModel*) cardModel
{
    if (castType == castNil)
        return [NSString stringWithFormat:@"nil"];
    else if (castType == castOnSummon) //depends on card type
    {
        if ([cardModel isKindOfClass:[SpellCardModel class]])
            return [NSString stringWithFormat:@""]; //no description since this is default behaviour
        else
            return [NSString stringWithFormat:@"On summon: "];
    }
    else if (castType == castAlways)
        return [NSString stringWithFormat:@""];
    else if (castType == castOnHit)
        return [NSString stringWithFormat:@"On attack: "];
    else if (castType == castOnDamaged)
        return [NSString stringWithFormat:@"On damaged: "];
    else if (castType == castOnMove)
        return [NSString stringWithFormat:@"On zero cooldown: "];
    else if (castType == castOnEndOfTurn)
        return [NSString stringWithFormat:@"On end of turn: "];
    else if (castType == castOnDeath)
        return [NSString stringWithFormat:@"On death: "];
    
    return [NSString stringWithFormat:@"cast type %d", castType];
}

+(NSString*) getDurationTypeDescription: (enum DurationType) durationType
{
    if (durationType == durationNil)
        return [NSString stringWithFormat:@"nil"]; //no description needed
    else if (durationType == durationInstant)
        return [NSString stringWithFormat:@""]; //no description needed
    else if (durationType == durationUntilEndOfTurn)
        return [NSString stringWithFormat:@" until the end of the turn"];
    else if (durationType == durationUntilDeath)
        return [NSString stringWithFormat:@" until the caster dies"];
    else if (durationType == durationForever)
        return [NSString stringWithFormat:@""]; //no description needed
    
    return [NSString stringWithFormat:@"duration type %d", durationType];
}

@end
