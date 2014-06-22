//
//  MonsterCardModel.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "MonsterCardModel.h"
#import "CardView.h"

@implementation MonsterCardModel

@synthesize damage = _damage;
@synthesize life = _life;
@synthesize maximumLife = _maximumLife;
@synthesize cooldown = _cooldown;
@synthesize maximumCooldown = _maximumCooldown;
@synthesize deployed = _deployed;
@synthesize side = _side;
@synthesize dead = _dead;

/** constructor with id number, all other fields will be defaut values */
-(instancetype)initWithIdNumber: (long)idNumber
{
    self = [super initWithIdNumber:idNumber];
    
    if (self)
    {
        self.damage = 0 ;
        self.life = self.maximumLife = 1;
        self.cooldown = self.maximumCooldown = 1;
        self.deployed = NO;
        self.side = -1;
    }
    
    return self;
}

-(instancetype)initWithIdNumber:(long)idNumber type:(enum CardType) type
{
    self = [self initWithIdNumber:idNumber];
    
    if (self)
    {
        self.type = type;
    }
    
    return self;
}

-(instancetype)initWithMonsterCard:(MonsterCardModel*)monsterCard
{
    self = [self initWithIdNumber:monsterCard.idNumber];
    
    if (self)
    {
        //deep copy of all attributes
        self.damage = monsterCard.baseDamage;
        self.life = monsterCard.life;
        self.maximumLife = monsterCard.baseMaxLife;
        self.cooldown = monsterCard.cooldown;
        self.maximumCooldown = monsterCard.baseMaxCooldown;
        self.deployed = monsterCard.deployed;
        self.side = monsterCard.side;
        self.type = monsterCard.type;
        self.element = monsterCard.element;
        self.dead = monsterCard.dead;
        for (Ability*ability in monsterCard.abilities)
            [self.abilities addObject: [[Ability alloc] initWithAbility:ability]];
        self.cost = monsterCard.cost;
        self.rarity = monsterCard.rarity;
        self.name = [[NSString alloc]initWithString:monsterCard.name];
        self.creator = [[NSString alloc]initWithString:monsterCard.creator];
        self.creatorName = [[NSString alloc]initWithString:monsterCard.creatorName];
    }
    
    return self;

}

/** damage will be 0 if set any lower */
-(void)setDamage:(int)damage{
    if (damage > 0)
    {
        if (_damage != damage)
            self.cardView.damageViewNeedsUpdate = YES;
        _damage = damage;
    }
    else
    {
        if (_damage != 0)
            self.cardView.damageViewNeedsUpdate = YES;
        _damage = 0;
    }
}

-(int)damage{
    int damage = _damage;
    
    for (Ability *ability in self.abilities)
    {
        //add and lose damage work when target is self and ability is always. For other cast types, they incrementally add damage
        if (!ability.expired && ability.targetType == targetSelf && (ability.castType == castAlways))
        {
            if (ability.abilityType == abilityAddDamage)
                damage += [ability.value intValue];
            else if (ability.abilityType == abilityLoseDamage)
                damage -= [ability.value intValue];
        }
    }
    
    return damage > 0 ? damage : 0; //cannot deal negative damage
}

-(int)baseDamage
{
    return _damage;
}

/** life can be above maximumHealth, and negative numbers become 0. For healing use healLife */
-(void)setLife:(int)life{
    
    //inform view to make animation on next update
    if (life <= 0)
    {
        self.dead = YES;
        self.deployed = NO; //undeployed
        if (_life != 0)
            self.cardView.lifeViewNeedsUpdate = YES;
        _life = 0;
    }
    else
    {
        if (_life != life)
            self.cardView.lifeViewNeedsUpdate = YES;
        _life = life;
    }
}

-(int)life{
    return _life;
}

/** maximumHealth will be 1 if set any lower */
-(void)setMaximumLife:(int)MaximumLife{
    _maximumLife = MaximumLife > 1 ? MaximumLife : 1;
}

-(int)maximumLife{
    int totalLife = _maximumLife;
    
    for (Ability *ability in self.abilities)
        if (!ability.expired && ability.abilityType == abilityAddMaxLife && ability.targetType == targetSelf)
            if (ability.castType == castAlways)
                totalLife += [ability.value intValue];
    
    return totalLife;
}

/** cooldown will be 0 if set any lower */
-(void)setCooldown:(int)cooldown{
    if (cooldown >= 0)
    {
        if (cooldown != _cooldown)
            self.cardView.cooldownViewNeedsUpdate = YES;
        _cooldown = cooldown;
    }
    else
    {
        if (_cooldown != 0)
            self.cardView.cooldownViewNeedsUpdate = YES;
        _cooldown = 0;
    }
}

-(int)cooldown
{
    return _cooldown;
}


-(void)setMaximumCooldown:(int)maximumCooldown
{
    _maximumCooldown = maximumCooldown > 0 ? maximumCooldown : 0;
}

-(int)maximumCooldown{
    int totalCooldown = _maximumCooldown;
    
    for (Ability *ability in self.abilities){
        if (!ability.expired && ability.castType == castAlways)
        {
            if (ability.abilityType == abilityAddMaxCooldown && ability.targetType == targetSelf)
                totalCooldown += [ability.value intValue];
            else if (ability.abilityType == abilityLoseMaxCooldown && ability.targetType == targetSelf)
                totalCooldown -= [ability.value intValue];
        }
    }
    
    return totalCooldown;
}

-(int) baseMaxCooldown
{
    return _maximumCooldown;
}

-(void) loseLife: (int) amount{
    self.life = self.life - amount;
}

-(void) healLife: (int) amount{
    self.life = self.life + amount;
    
    //cannot overheal
    if (self.life > self.maximumLife)
        self.life = self.maximumLife;
}

-(void) addLife: (int)amount{
    _life += amount;
    if (_life < 0)
        _life = 0;
}

-(int) baseMaxLife{
    return _maximumLife;
}


-(void) setupAsPlayerHero: (NSString*) name onSide:(int) side;
{
    self.name = name;
    self.type = cardTypePlayer;
    self.maximumLife = 25000;
    self.life = 25000;
  
    self.damage = 0;
    self.cooldown = 0;
    self.side = side;
    self.deployed = YES;
}

-(void)resetAllStats
{
    //remove all abilities that are not the removeAbility itself
    //delete this way to prevent concurrent mod
    for (int i = 0; i < [self.abilities count];)
    {
        Ability*ability = self.abilities[i];
        
        //skip all abilityRemoveAbility that targets itself
        if (ability.isBaseAbility == YES)
        {
            ability.expired = NO;
            i++;
        }
        else
        {
            [self.abilities removeObjectAtIndex:i];
        }
    }
    
    self.life = self.maximumLife;
    self.cooldown = self.maximumCooldown;
    self.deployed = NO;
    self.dead = NO;
}

//TODO not used
-(void)applyAbility: (Ability*) ability
{
    Ability* abilityCopy = [[Ability alloc] initWithType:ability.abilityType castType:ability.castType targetType:targetSelf withDuration:ability.durationType withValue:ability.value  withOtherValues:ability.otherValues]; //NOTE ability.otherValues is immutable so this is fine?
    
    [self.abilities addObject:abilityCopy];
}

@end
