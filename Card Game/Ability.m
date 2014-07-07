//
//  Ability.m
//  cardgame
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "Ability.h"
#import "UIConstants.h"

@implementation Ability

@synthesize abilityType = _abilityType;
@synthesize targetType = _targetType;
@synthesize durationType = _durationType;
@synthesize castType = _castType;
@synthesize value = _value;
@synthesize otherValues = _otherValues;
@synthesize isBaseAbility = _isBaseAbility;
@synthesize description = _description;


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
        self.otherValues = @[];
        self.description = nil;
        self.expired = NO;
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

-(instancetype) initWithType: (enum AbilityType) abilityType castType: (enum CastType) castType targetType: (enum TargetType) targetType withDuration: (enum DurationType) durationType  withValue: (NSNumber*) value withOtherValues: (NSArray*) otherValues withDescription: (NSString*) description
{
    self = [self initWithType:abilityType castType: castType targetType: targetType withDuration:durationType withValue:value withOtherValues:otherValues];
    
    if (self)
    {
        self.description = description;
    }
    
    return self;
}

-(instancetype) initWithAbility: (Ability*) ability
{
    self = [self initWithType:ability.abilityType castType:ability.castType targetType:ability.targetType withDuration:ability.durationType withValue:ability.value withOtherValues:ability.otherValues withDescription:ability.description];
    
    return self;
}


-(BOOL)isEqualTypeTo:(Ability*)ability
{
    if (ability.abilityType == self.abilityType &&
        ability.castType == self.castType &&
        ability.targetType == self.targetType &&
        ability.durationType == self.durationType)
        return YES;
    return NO;
}

-(BOOL)isCompatibleTo:(Ability*)ability
{
    //TODO probably should have used a better structure, but probably not that many rules anyways
    
    //abilities with opposite effect can co-exist only if their target or cast types are different
    if (self.targetType == ability.targetType && self.castType == ability.castType)
    {
        //add damage and lose damage
        if ((self.abilityType == abilityAddDamage && ability.abilityType == abilityLoseDamage)
            || (self.abilityType == abilityLoseDamage && ability.abilityType == abilityAddDamage))
            return NO;
        //add life and lose life
        if ((self.abilityType == abilityAddLife && ability.abilityType == abilityLoseLife)
            || (self.abilityType == abilityLoseLife && ability.abilityType == abilityAddLife))
            return NO;
        //add cooldown with lose or set
        if (self.abilityType == abilityAddCooldown)
        {
            if (ability.abilityType == abilitySetCooldown || ability.abilityType == abilityLoseCooldown || ability.abilityType == abilityLoseMaxCooldown )
                return NO;
        }
        //lose cooldown with add or set
        if (self.abilityType == abilityLoseCooldown)
        {
            if (ability.abilityType == abilitySetCooldown || ability.abilityType == abilityAddCooldown || ability.abilityType == abilityAddMaxCooldown)
                    return NO;
        }
        //add max cooldown with lose or set
        if (self.abilityType == abilityAddMaxCooldown)
        {
            if (ability.abilityType == abilitySetCooldown || ability.abilityType == abilityLoseMaxCooldown || ability.abilityType == abilityLoseCooldown)
                return NO;
        }
        //lose max cooldown with add or set
        if (self.abilityType == abilityLoseMaxCooldown)
        {
            if (ability.abilityType == abilitySetCooldown || ability.abilityType == abilityAddMaxCooldown || ability.abilityType == abilityAddCooldown)
                return NO;
        }
        //set cooldown with any other
        if (self.abilityType == abilitySetCooldown)
        {
            if (ability.abilityType == abilityAddMaxCooldown || ability.abilityType == abilityAddCooldown || ability.abilityType == abilityLoseMaxCooldown || ability.abilityType == abilityLoseCooldown)
                return NO;
        }
        //kill with add life
        if (self.abilityType == abilityKill)
        {
            if (ability.abilityType == abilityAddLife || ability.abilityType == abilityAddMaxLife)
                return NO;
        }
        //add life with kill
        if (self.abilityType == abilityAddLife && ability.abilityType == abilityKill)
                return NO;
        //add max life with kill
        if (self.abilityType == abilityAddMaxLife && ability.abilityType == abilityKill)
            return NO;
    }
    
    //cast types:
    NSArray*targetOneConflicts = @[[NSNumber numberWithInt:targetOneAny],[NSNumber numberWithInt:targetOneFriendly],[NSNumber numberWithInt:targetOneFriendlyMinion], [NSNumber numberWithInt:targetOneEnemy], [NSNumber numberWithInt:targetOneEnemyMinion], [NSNumber numberWithInt:targetHeroAny], [NSNumber numberWithInt:targetOneAnyMinion]];
    
    //cannot have abilities with different castTypes
    if ([targetOneConflicts containsObject:[NSNumber numberWithInt:self.castType]] && [targetOneConflicts containsObject:[NSNumber numberWithInt:ability.castType]] && (self.castType != ability.castType))
        return NO;
    
    return YES;
}

+(NSMutableAttributedString*) getDescription: (Ability*) ability fromCard: (CardModel*) cardModel
{
    if (ability.description != nil)
        return [[NSMutableAttributedString alloc] initWithString:ability.description]; //TODO needs some replacements
    
    enum AbilityType abilityType = ability.abilityType;
    
    NSString *targetDescription = [Ability getTargetTypeDescription:ability.targetType];
    NSString *castDescription = [Ability getCastTypeDescription:ability.castType fromCard:cardModel];
    NSString *durationDescription = [Ability getDurationTypeDescription:ability.durationType];
    NSString *valueDescription;
    
    NSString *description;
    
    BOOL shouldHighlightValue = NO;
    
    if (ability.value == nil)
    {
        if (ability.otherValues.count >= 2 && [ability.otherValues[0] integerValue] != [ability.otherValues[1] integerValue])
        {
            valueDescription = @"X";
            shouldHighlightValue = YES;
        }
        else
            valueDescription = [NSString stringWithFormat:@"%@", ability.otherValues[0]];
    }
    else
    {
        if (ability.otherValues.count >= 2 && [ability.otherValues[0] integerValue] != [ability.otherValues[1] integerValue])
            shouldHighlightValue = YES;
        
        valueDescription = [NSString stringWithFormat:@"%@", ability.value];
    }
    
    if (abilityType == abilityNil)
        description = [NSString stringWithFormat:@"nil ability"];
    else if (abilityType == abilityAddDamage){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@+%@ damage%@.", castDescription, valueDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@+%@ damage to %@%@.", castDescription, valueDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityLoseDamage){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@-%@ damage%@.", castDescription, valueDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@-%@ damage to %@%@.", castDescription, valueDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityAddLife){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@Heal %@ life%@.", castDescription, valueDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@Heal %@ life to %@%@.", castDescription, valueDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityAddMaxLife){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@+%@ life%@.", castDescription, valueDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@+%@ life to %@%@.", castDescription, valueDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityLoseLife){
        description = [NSString stringWithFormat:@"%@Deal %@ damage to %@%@.", castDescription, valueDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityKill){
        description = [NSString stringWithFormat:@"%@Destroy %@%@.", castDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilitySetCooldown){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@Set its cooldown to %@%@.", castDescription, valueDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@Set cooldown to %@ for %@%@.", castDescription, valueDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityAddCooldown){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@+%@ cooldown%@.", castDescription, valueDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@+%@ cooldown to %@%@.", castDescription, valueDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityAddMaxCooldown){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@+%@ maximum cooldown%@.", castDescription, valueDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@+%@ maximum cooldown to %@%@.", castDescription, valueDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityLoseCooldown){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@-%@ cooldown%@.", castDescription, valueDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@-%@ cooldown to %@%@.", castDescription, valueDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityLoseMaxCooldown){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@-%@ maximum cooldown%@.", castDescription, valueDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@-%@ maximum cooldown to %@%@.", castDescription, valueDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityTaunt){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@Taunt%@.", castDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@Give Taunt to %@%@.", castDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityDrawCard){
        if (ability.targetType == targetHeroEnemy)
            description = [NSString stringWithFormat:@"%@Opponent draws %@ card%@.", castDescription, valueDescription, durationDescription];
        else if (ability.targetType == targetHeroFriendly)
            description = [NSString stringWithFormat:@"%@Draw %@ card%@.", castDescription, valueDescription, durationDescription];
        else if (ability.targetType == targetAll)
            description = [NSString stringWithFormat:@"%@All players draw %@ card%@.", castDescription, valueDescription, durationDescription];
    }
    else if (abilityType == abilityAddResource){
        if (ability.targetType == targetHeroEnemy)
            description = [NSString stringWithFormat:@"%@Opponent gains %@ resource(s)%@.", castDescription, valueDescription, durationDescription];
        else if (ability.targetType == targetHeroFriendly)
            description = [NSString stringWithFormat:@"%@Gain %@ resource(s)%@.", castDescription, valueDescription, durationDescription];
        else if (ability.targetType == targetAll)
            description = [NSString stringWithFormat:@"%@All players gain %@ resource(s)%@.", castDescription, valueDescription, durationDescription];
    }
    else if (abilityType == abilityRemoveAbility){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@Monster cannot have any abilities%@.", castDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@Remove all abilities from %@%@.", castDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityAssassin){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@Does not receive damage when attacking%@.", castDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@Monster will not receive damage when attacking %@%@.", castDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityReturnToHand){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@Returns itself to hand%@.", castDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@Return %@ to its owner's hand%@.", castDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityPierce){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@Pierce attack%@.", castDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@Gives Pierce to%@%@.", castDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityFracture){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@Fractures into %@ pieces%@.", castDescription, valueDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@Gives Fracture %@ to%@%@.", castDescription, valueDescription, targetDescription, durationDescription];
    }
    else
        description = [NSString stringWithFormat:@"ability no name %d", ability.abilityType];
    
    NSMutableAttributedString *attriDescription = [[NSMutableAttributedString alloc]initWithString:description];
    
    if (shouldHighlightValue)
    {
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
        [attributes addEntriesFromDictionary:@{NSForegroundColorAttributeName:COLOUR_INTERFACE_BLUE}];
        
        [attriDescription setAttributes:attributes range:[description rangeOfString:valueDescription]];
    }
    
    return attriDescription;
}

+(NSString*) getTargetTypeDescription: (enum TargetType) targetType
{
    if (targetType == targetNil)
        return [NSString stringWithFormat:@"nil"];
    else if (targetType == targetSelf)
        return [NSString stringWithFormat:@"itself"]; //special case, may not use this text depending on wording
    else if (targetType == targetVictim)
        return [NSString stringWithFormat:@"target"];
    else if (targetType == targetVictimMinion)
        return [NSString stringWithFormat:@"minion target"];
    else if (targetType == targetAttacker)
        return [NSString stringWithFormat:@"attacker"];
    else if (targetType == targetOneAny)
        return [NSString stringWithFormat:@"a character"];
    else if (targetType == targetOneAnyMinion)
        return [NSString stringWithFormat:@"a minion"];
    else if (targetType == targetOneFriendly)
        return [NSString stringWithFormat:@"a friendly character"];
    else if (targetType == targetOneFriendlyMinion)
        return [NSString stringWithFormat:@"a friendly minion"];
    else if (targetType == targetOneEnemy)
        return [NSString stringWithFormat:@"an enemy character"];
    else if (targetType == targetOneEnemyMinion)
        return [NSString stringWithFormat:@"an enemy minion"];
    else if (targetType == targetAll)
        return [NSString stringWithFormat:@"all characters"];
    else if (targetType == targetAllMinion)
        return [NSString stringWithFormat:@"all other minions"];
    else if (targetType == targetAllFriendly)
        return [NSString stringWithFormat:@"all other friendly characters"];
    else if (targetType == targetAllFriendlyMinions)
        return [NSString stringWithFormat:@"all other friendly minions"];
    else if (targetType == targetAllEnemy)
        return [NSString stringWithFormat:@"all enemy characters"];
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
        return [NSString stringWithFormat:@"a hero"];
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
