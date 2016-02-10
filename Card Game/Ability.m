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
    self.isBaseAbility = ability.isBaseAbility;
    
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
    //if any ability is Mute then no ability is compatible
    if (ability.abilityType == abilityRemoveAbility && ability.castType == castAlways && ability.targetType == targetSelf)
        return NO;
    if (self.abilityType == abilityRemoveAbility && self.castType == castAlways && self.targetType == targetSelf)
        return NO;
    
    //TODO probably should have used a better structure, but probably not that many rules anyways
    
    //abilities with opposite effect can co-exist only if their target or cast types are different
    if (self.targetType == ability.targetType && self.castType == ability.castType)
    {
        //TODO these are old if statements, should move down into more compact version
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
    
    //don't know a better way to cut this down in half
    for (int i = 0; i < 2; i++)
    {
        Ability *a,*b;
        if (i == 0)
        {
            a = self;
            b = ability;
        }
        else if (i == 1)
        {
            a = ability;
            b = self;
        }
        
        //if one ability is kill, and they have both same cast types
        if (a.abilityType == abilityKill && a.castType == b.castType)
        {
            //if the kill ability targets enemies
            if (a.targetType == targetAllEnemyMinions || a.targetType == targetAllMinion || a.targetType == targetVictimMinion)
            {
                //then the other ability cannot target the victim (subset of a), or any target type same as ability a
                if (b.targetType == targetVictim || b.targetType == targetVictimMinion || (b.targetType == a.targetType))
                {
                    //this prevents for example killing all enemy minions and adding attack to victim minion, which is meaningless
                    return NO;
                }
            }
        }
        
        //if same cast type
        if (a.castType == b.castType)
        {
            //one ability is kill
            if (a.abilityType == abilityKill)
            {
                //the other cannot be any ability subset of the kill ability (e.g. kill all minions, add damage for enemy is invalid)
                if ([b isTargetTypeSubsetOf:a.targetType])
                    return NO;
            }
            
            //draw card abilities cannot be draw for enemy and friendly, for that must use the targetAll instead (because drawing for all is better than the difference of draw for own and draw for enemy
            if (a.abilityType == abilityDrawCard && b.abilityType == abilityDrawCard)
            {
                if (a.targetType == targetHeroFriendly && b.targetType == targetHeroEnemy)
                    return NO;
            }
        }
    }
    
    //cast types: cannot have more than one selectable cast type
    NSArray*targetOneConflicts = @[[NSNumber numberWithInt:targetOneAny],[NSNumber numberWithInt:targetOneFriendly],[NSNumber numberWithInt:targetOneFriendlyMinion], [NSNumber numberWithInt:targetOneEnemy], [NSNumber numberWithInt:targetOneEnemyMinion], [NSNumber numberWithInt:targetHeroAny], [NSNumber numberWithInt:targetOneAnyMinion]];
    
    //cannot have abilities with different castTypes
    if ([targetOneConflicts containsObject:[NSNumber numberWithInt:self.targetType]] && [targetOneConflicts containsObject:[NSNumber numberWithInt:ability.targetType]] && (self.targetType != ability.targetType))
        return NO;
    
    return YES;
}

-(BOOL)isTargetTypeSubsetOf:(enum TargetType)targetType
{
    //base case: equal types are subsets
    if (self.targetType == targetType)
        return YES;
    
    //any is subset of targetall
    if (targetType == targetAll)
        return YES;
    
    //non minion-specifics:
    if (targetType == targetAllFriendly)
    {
        if ([self isTargetTypeSubsetOf:targetOneFriendly])
            return YES;
        if ([self isTargetTypeSubsetOf:targetOneRandomFriendly])
            return YES;
        if ([self isTargetTypeSubsetOf:targetAllFriendlyMinions])
            return YES;
    }
    if (targetType == targetAllEnemy)
    {
        if ([self isTargetTypeSubsetOf:targetOneEnemy])
            return YES;
        if ([self isTargetTypeSubsetOf:targetOneRandomEnemy])
            return YES;
        if ([self isTargetTypeSubsetOf:targetAllEnemyMinions])
            return YES;
    }
    
    //minion specifics
    if (targetType == targetAllMinion)
    {
        if ([self isTargetTypeSubsetOf:targetAllFriendlyMinions] || [self isTargetTypeSubsetOf:targetAllEnemyMinions])
            return YES;
        if ([self isTargetTypeSubsetOf:targetOneAnyMinion] || [self isTargetTypeSubsetOf:targetOneRandomMinion])
            return YES;
    }
    if (targetType == targetAllFriendlyMinions)
    {
        if ([self isTargetTypeSubsetOf:targetOneFriendlyMinion])
            return YES;
        if ([self isTargetTypeSubsetOf:targetOneRandomFriendlyMinion])
            return YES;
    }
    if (targetType == targetAllEnemyMinions)
    {
        if ([self isTargetTypeSubsetOf:targetOneEnemyMinion])
            return YES;
        if ([self isTargetTypeSubsetOf:targetOneRandomEnemyMinion])
            return YES;
    }
    
    
    //hero specifics
    if (targetType == targetHeroAny)
    {
        if ([self isTargetTypeSubsetOf:targetHeroFriendly])
            return YES;
        if ([self isTargetTypeSubsetOf:targetHeroEnemy])
            return YES;
    }
    if (targetType == targetOneFriendly)
    {
        if ([self isTargetTypeSubsetOf:targetHeroFriendly])
            return YES;
    }
    if (targetType == targetOneEnemy)
    {
        if ([self isTargetTypeSubsetOf:targetHeroEnemy])
            return YES;
    }
    
    return NO;
}

+(NSString*) getDescriptionForBaseAbilities: (CardModel*) card
{
    NSArray *dupAbilities = [NSMutableArray arrayWithArray:card.abilities];
    NSMutableArray *sortedAbilities = [NSMutableArray arrayWithArray: [dupAbilities sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        Ability*abilityA = (Ability*)a;
        Ability*abilityB = (Ability*)b;
        return [[Ability getCastTypeOrder:abilityA.castType] compare:[Ability getCastTypeOrder:abilityB.castType]];
    }]];
    
    //remove all non-base or expired abilities
    for (int i = [sortedAbilities count] - 1; i >= 0; i--)
    {
        Ability*ability = sortedAbilities[i];
        if (ability.expired || !ability.isBaseAbility)
            [sortedAbilities removeObjectAtIndex:i];
    }
   
    NSString*description = @"";
    
    while ([sortedAbilities count] > 0)
    {
        Ability*ability = sortedAbilities[0];
        [sortedAbilities removeObjectAtIndex:0];
        
        enum AbilityType abilityType = ability.abilityType;
        enum CastType castType = ability.castType;
        enum TargetType targetType = ability.targetType;
        enum DurationType durationType = ability.durationType;
        
        NSString*castTypeString = [Ability getCastTypeDescription:castType fromCard:card];
        
        //checks if cast type is already written
        if ([description rangeOfString:castTypeString].location == NSNotFound)
        {
            //add a period if this is not the first cast type
            if (description.length > 0)
                description = [NSString stringWithFormat:@"%@.\n%@", description, castTypeString];
            //first ability of cast type, put the cast type in
            else
                description = [NSString stringWithFormat:@"%@%@", description, castTypeString];
        }
        else
            description = [NSString stringWithFormat:@"%@. ", description];
        
        description = [NSString stringWithFormat:@"%@%@", description, [Ability getAbilityTypeDescriptionFromAbility:ability withValueDescription: [NSString stringWithFormat:@"%@", ability.value]]];
        
        Ability*lastAbility = ability; //keeps track of the last ability in the sentence
        
        //look for abilities with same cast type
        for (int i = [sortedAbilities count] - 1; i >= 0; i--)
        {
            Ability*otherAbility = sortedAbilities[i];

            //all types are the same
            if (otherAbility.castType == castType && otherAbility.durationType == durationType && otherAbility.targetType == targetType)
            {
                //do not add for these special cases
                if (otherAbility.abilityType == abilityAddResource || otherAbility.abilityType == abilityDrawCard)
                    continue;
                
                description = [NSString stringWithFormat:@"%@, %@", description, [Ability getAbilityTypeDescriptionFromAbility:otherAbility withValueDescription: [NSString stringWithFormat:@"%@", otherAbility.value]]];
                [sortedAbilities removeObjectAtIndex:i];
                lastAbility = otherAbility;
            }
        }
        
        if (targetType != targetSelf)
        {
            //TODO: ADD SPECIAL CASES
            if (lastAbility.abilityType == abilityAddResource || lastAbility.abilityType == abilityDrawCard)
            {
                //do nothing, these don't use the generic target strings
            }
            else
            {
                description = [NSString stringWithFormat:@"%@ %@ %@", description, [Ability getAbilityPreposition:lastAbility], [Ability getTargetTypeDescription:targetType]];
            }
        }
        
        description = [NSString stringWithFormat:@"%@%@", description, [Ability  getDurationTypeDescription:durationType]];
    }

    //add a period at the end
    if (description.length > 0)
        description = [NSString stringWithFormat:@"%@.", description];
    
    return description;
}

+(NSString*)getAbilityPreposition:(Ability*)ability
{
    enum AbilityType abilityType = ability.abilityType;
    enum TargetType targetType = ability.targetType;
    
    if (abilityType == abilityLoseLife)
    {
        return @"to";
    }
    else if (abilityType == abilityKill || abilityType == abilityAddResource || abilityType == abilityDrawCard || abilityType == abilityReturnToHand || abilityType == abilityRemoveAbility)
    {
        return @"";
    }
    else if (abilityType == abilitySetCooldown)
    {
        if (targetType == targetSelf)
            return @"";
        else
            return @"for";
    }
    else
    {
        if (targetType == targetSelf)
            return @"";
        else
            return @"to";
    }
}

//TODO!!!! This is an older function which needs some clean up to use the function beneath it instead
+(NSMutableAttributedString*) getDescription: (Ability*) ability fromCard: (CardModel*) cardModel
{
    if (ability.description != nil)
        return [[NSMutableAttributedString alloc] initWithString:ability.description]; //TODO needs some replacements
    
    enum AbilityType abilityType = ability.abilityType;
    
    NSString *targetDescription = [Ability getTargetTypeDescription:ability.targetType];
    NSString *castDescription = [Ability getCastTypeDescription:ability.castType fromCard:cardModel];
    NSString *durationDescription = [Ability getDurationTypeDescription:ability.durationType];
    NSString *valueDescription = @"NO VALUE";
    
    NSString *description = @"NO DESCRIPTION";
    
    BOOL shouldHighlightValue = NO;
    
    if (ability.value == nil)
    {
        if (ability.otherValues.count >= 2 && [ability.otherValues[0] integerValue] != [ability.otherValues[1] integerValue])
        {
            valueDescription = @"X";
            shouldHighlightValue = YES;
        }
        else if (ability.otherValues.count > 0)
        {
            //TODO CRITICAL SX - temporarily rounding all numbers to appear as if they're smaller numbers, REMOVE this eventually, uncomment line below
            
            float temporaryRounding = [ability.otherValues[0] floatValue];
            if (temporaryRounding >= 100)
                temporaryRounding /= 500;
            
            valueDescription = [NSString stringWithFormat:@"%d", (int)ceilf(temporaryRounding)];
            
            //valueDescription = [NSString stringWithFormat:@"%@", ability.otherValues[0]];
        }
    }
    else
    {
        if (ability.otherValues.count >= 2 && [ability.otherValues[0] integerValue] != [ability.otherValues[1] integerValue])
            shouldHighlightValue = YES;
        
        //TODO CRITICAL SX - temporarily rounding all numbers to appear as if they're smaller numbers, REMOVE this eventually, uncomment line below
        float temporaryRounding = [ability.value floatValue];
        if (temporaryRounding >= 100)
            temporaryRounding /= 500;
        
        valueDescription = [NSString stringWithFormat:@"%d", (int)ceilf(temporaryRounding)];
        
        
        //valueDescription = [NSString stringWithFormat:@"%@", ability.value];
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
            description = [NSString stringWithFormat:@"%@Guardian%@.", castDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@Give Guardian to %@%@.", castDescription, targetDescription, durationDescription];
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
            description = [NSString stringWithFormat:@"%@Opponent gains %@ resource%@.", castDescription, valueDescription, durationDescription];
        else if (ability.targetType == targetHeroFriendly)
            description = [NSString stringWithFormat:@"%@Gain %@ resource%@.", castDescription, valueDescription, durationDescription];
        else if (ability.targetType == targetAll)
            description = [NSString stringWithFormat:@"%@All players gain %@ resource%@.", castDescription, valueDescription, durationDescription];
    }
    else if (abilityType == abilityRemoveAbility){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@Mute%@.", castDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@Mute %@%@.", castDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityAssassin){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@Assassin%@.", castDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@Give Assassin to %@%@.", castDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityReturnToHand){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@Withdraw%@.", castDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@Withdraw %@%@.", castDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityPierce){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@Pierce%@.", castDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@Give Pierce to %@%@.", castDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityFracture){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"%@Fractures into %@ pieces%@.", castDescription, valueDescription, durationDescription];
        else
            description = [NSString stringWithFormat:@"%@Gives Fracture %@ to %@%@.", castDescription, valueDescription, targetDescription, durationDescription];
    }
    else if (abilityType == abilityHeroic)
    {
        description = [NSString stringWithFormat:@"Heroic"];
    }
    else
        description = [NSString stringWithFormat:@"ability no name %d", ability.abilityType];
    
    NSMutableAttributedString *attriDescription = [[NSMutableAttributedString alloc]initWithString:description];
    
    if (shouldHighlightValue)
    {
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
        [attributes addEntriesFromDictionary:@{NSForegroundColorAttributeName:COLOUR_INTERFACE_BLUE_PRESSED}];
        
        [attriDescription setAttributes:attributes range:[description rangeOfString:valueDescription]];
    }
    
    return attriDescription;
}

+(NSString*) getAbilityTypeDescriptionFromAbility:(Ability*)ability withValueDescription:(NSString*)valueDescription
{
    NSString* description = @"NO DESCRIPTION";
    
    //TODO CRITICAL SX - temporarily rounding all numbers to appear as if they're smaller numbers, REMOVE this eventually
    float temporaryRounding = [valueDescription floatValue];
    if (temporaryRounding >= 100)
        temporaryRounding /= 500;
    valueDescription = [NSString stringWithFormat:@"%d", (int)ceilf(temporaryRounding)];
    
    enum AbilityType abilityType = ability.abilityType;
    
    if (abilityType == abilityNil)
        description = [NSString stringWithFormat:@"nil ability"];
    else if (abilityType == abilityAddDamage){
            description = [NSString stringWithFormat:@"+%@ damage", valueDescription];
    }
    else if (abilityType == abilityLoseDamage){
            description = [NSString stringWithFormat:@"-%@ damage", valueDescription];
    }
    else if (abilityType == abilityAddLife){
            description = [NSString stringWithFormat:@"Heal %@ life", valueDescription];
    }
    else if (abilityType == abilityAddMaxLife){
            description = [NSString stringWithFormat:@"+%@ life", valueDescription];
    }
    else if (abilityType == abilityLoseLife){
        description = [NSString stringWithFormat:@"Deal %@ damage", valueDescription];
    }
    else if (abilityType == abilityKill){
        description = [NSString stringWithFormat:@"Destroy"];
    }
    else if (abilityType == abilitySetCooldown){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"Set its cooldown to %@", valueDescription];
        else
            description = [NSString stringWithFormat:@"Set cooldown to %@ for ", valueDescription];
    }
    else if (abilityType == abilityAddCooldown){
            description = [NSString stringWithFormat:@"+%@ cooldown", valueDescription];
    }
    else if (abilityType == abilityAddMaxCooldown){
            description = [NSString stringWithFormat:@"+%@ maximum cooldown", valueDescription];
    }
    else if (abilityType == abilityLoseCooldown){
            description = [NSString stringWithFormat:@"-%@ cooldown", valueDescription];
    }
    else if (abilityType == abilityLoseMaxCooldown){
            description = [NSString stringWithFormat:@"-%@ maximum cooldown", valueDescription];
    }
    else if (abilityType == abilityTaunt){
            description = [NSString stringWithFormat:@"Guardian"];
    }
    else if (abilityType == abilityDrawCard){
        if (ability.targetType == targetHeroEnemy)
            description = [NSString stringWithFormat:@"Opponent draws %@ card(s)", valueDescription];
        else if (ability.targetType == targetHeroFriendly)
            description = [NSString stringWithFormat:@"Draw %@ card(s)", valueDescription];
        else if (ability.targetType == targetAll)
            description = [NSString stringWithFormat:@"All players draw %@ card(s)", valueDescription];
    }
    else if (abilityType == abilityAddResource){
        if (ability.targetType == targetHeroEnemy)
            description = [NSString stringWithFormat:@"Opponent gains %@ resource(s)", valueDescription];
        else if (ability.targetType == targetHeroFriendly)
            description = [NSString stringWithFormat:@"Gain %@ resource(s)", valueDescription];
        else if (ability.targetType == targetAll)
            description = [NSString stringWithFormat:@"All players gain %@ resource(s)", valueDescription];
    }
    else if (abilityType == abilityRemoveAbility){
            description = [NSString stringWithFormat:@"Mute"];
    }
    else if (abilityType == abilityAssassin){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"Assassin"];
        else
            description = [NSString stringWithFormat:@"Give Assassin"];
    }
    else if (abilityType == abilityReturnToHand){
            description = [NSString stringWithFormat:@"Withdraw"];
    }
    else if (abilityType == abilityPierce){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"Pierce"];
        else
            description = [NSString stringWithFormat:@"Give Pierce"];
    }
    else if (abilityType == abilityFracture){
        if (ability.targetType == targetSelf)
            description = [NSString stringWithFormat:@"Fractures into %@ pieces",  valueDescription];
        else
            description = [NSString stringWithFormat:@"Gives Fracture %@", valueDescription];
    }
    else if (abilityType == abilityHeroic)
    {
        description = [NSString stringWithFormat:@"Heroic"];
    }
    else
        description = [NSString stringWithFormat:@"ability no name %d", ability.abilityType];
    
    return description;
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
        return [NSString stringWithFormat:@"creature target"];
    else if (targetType == targetAttacker)
        return [NSString stringWithFormat:@"attacker"];
    else if (targetType == targetOneAny)
        return [NSString stringWithFormat:@"a character"];
    else if (targetType == targetOneAnyMinion)
        return [NSString stringWithFormat:@"a creature"];
    else if (targetType == targetOneFriendly)
        return [NSString stringWithFormat:@"a friendly character"];
    else if (targetType == targetOneFriendlyMinion)
        return [NSString stringWithFormat:@"a friendly creature"];
    else if (targetType == targetOneEnemy)
        return [NSString stringWithFormat:@"an enemy character"];
    else if (targetType == targetOneEnemyMinion)
        return [NSString stringWithFormat:@"an enemy creature"];
    else if (targetType == targetAll)
        return [NSString stringWithFormat:@"all characters"];
    else if (targetType == targetAllMinion)
        return [NSString stringWithFormat:@"all other creatures"];
    else if (targetType == targetAllFriendly)
        return [NSString stringWithFormat:@"all other friendly characters"];
    else if (targetType == targetAllFriendlyMinions)
        return [NSString stringWithFormat:@"all other friendly creatures"];
    else if (targetType == targetAllEnemy)
        return [NSString stringWithFormat:@"all enemy characters"];
    else if (targetType == targetAllEnemyMinions)
        return [NSString stringWithFormat:@"all enemy creatures"];
    else if (targetType == targetOneRandomAny)
        return [NSString stringWithFormat:@"a random character"];
    else if (targetType == targetOneRandomMinion)
        return [NSString stringWithFormat:@"a random creature"];
    else if (targetType == targetOneRandomFriendly)
        return [NSString stringWithFormat:@"a random friendly character"];
    else if (targetType == targetOneRandomFriendlyMinion)
        return [NSString stringWithFormat:@"a random friendly creature"];
    else if (targetType == targetOneRandomEnemy)
        return [NSString stringWithFormat:@"a random enemy character"];
    else if (targetType == targetOneRandomEnemyMinion)
        return [NSString stringWithFormat:@"a random enemy creature"];
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
        return [NSString stringWithFormat:@"On move: "];
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

/** Maybe return an array later */
+(NSString*)getAbilityKeywordDescription: (Ability*)ability
{
    if (ability.abilityType == abilityTaunt)
        return @"Guardian: Enemy creatures must attack this creature.";
    else if (ability.abilityType == abilityRemoveAbility)
        return @"Mute: Target cannot have any abilities.";
    else if (ability.abilityType == abilityAssassin)
        return @"Assassin: Target does not receive recoil damage when attacking.";
    else if (ability.abilityType == abilityReturnToHand)
        return @"Withdraw: Target is returned to the owner's hand.";
    else if (ability.abilityType == abilityPierce)
        return @"Pierce: Attack damage dealt above target's health is deal to the enemy hero.";
    else if (ability.abilityType == abilityFracture)
        return @"Fracture: Summons weaker copies of itself that has no abilities.";
    else if (ability.abilityType == abilityHeroic)
        return @"Heoric: Acts as the hero.";
    
    return nil;
}

+(NSMutableArray*)getAbilityKeywordDescriptions: (CardModel*)card
{
    NSMutableArray *descriptions = [NSMutableArray array];
    for (Ability*ability in card.abilities)
    {
        if (ability.expired)
            continue;
        
        NSString*description = [Ability getAbilityKeywordDescription:ability];
        
        if (description == nil)
            continue;
        
        BOOL found = NO;
        for (NSString *d in descriptions)
        {
            if ([d isEqualToString:description])
            {
                found = YES;
                break;
            }
        }
        
        if (!found)
            [descriptions addObject:description];
    }
    return descriptions;
}

+(BOOL)abilityIsSelectableTargetType:(Ability*)ability
{
    enum TargetType targetType = ability.targetType;
    
    if (targetType == targetHeroAny || targetType == targetOneAny ||targetType == targetOneAnyMinion ||targetType == targetOneEnemy ||targetType == targetOneEnemyMinion||targetType == targetOneFriendly ||targetType == targetOneFriendlyMinion)
        return YES;
    
    return NO;
}

+(NSNumber*)getCastTypeOrder:(enum CastType)castType
{
    //NOTE: give enough space between numbers so can add more in future
    if (castType == castAlways)
        return @100;
    else if (castType == castOnSummon)
        return @200;
    else if (castType == castOnEndOfTurn)
        return @300;
    else if (castType == castOnMove)
        return @400;
    else if (castType == castOnHit)
        return @500;
    else if (castType == castOnDamaged)
        return @600;
    else if (castType == castOnDeath)
        return @700;
    
    return @10000;
}

@end
