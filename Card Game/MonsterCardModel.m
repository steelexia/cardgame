//
//  MonsterCardModel.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "MonsterCardModel.h"

@implementation MonsterCardModel

@synthesize damage = _damage;
@synthesize life = _life;
@synthesize maximumLife = _maximumLife;
@synthesize cooldown = _cooldown;
@synthesize maximumCooldown = _maximumCooldown;
@synthesize deployed = _deployed;
@synthesize additionalDamage = _additionalDamage;
@synthesize side = _side;
@synthesize dead = _dead;

/** constructor with id number, all other fields will be defaut values */
-(instancetype)initWithIdNumber: (long)idNumber
{
    self = [super initWithIdNumber:idNumber];
    
    if (self)
    {
        self.damage = self.additionalDamage = 0 ;
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

/** damage will be 0 if set any lower */
-(void)setDamage:(int)damage{
    _damage = damage > 0 ? damage : 0;
}

-(int)damage{
    int damage = _damage + self.additionalDamage;
    
    for (Ability *ability in self.abilities)
    {
        //add and lose damage work when target is self and ability is always. For other cast types, they incrementally add damage
        if (ability.targetType == targetSelf && (ability.castType == castAlways))
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
    if (life <= 0)
        self.dead = YES;
    _life = life > 0 ? life : 0;
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
        if (ability.abilityType == abilityAddMaxLife && ability.targetType == targetSelf)
            if (ability.castType == castAlways)
                totalLife += [ability.value intValue];
    
    return totalLife;
}

/** cooldown will be 0 if set any lower */
-(void)setCooldown:(int)cooldown{
    _cooldown = cooldown > 0 ? cooldown : 0;
}

-(int)cooldown{
    int totalCooldown = _cooldown;
    
    for (Ability *ability in self.abilities){
        if (ability.castType == castAlways)
        {
            if (ability.abilityType == abilityAddMaxCooldown && ability.targetType == targetSelf)
                totalCooldown += [ability.value intValue];
            else if (ability.abilityType == abilityLoseMaxCooldown && ability.targetType == targetSelf)
                totalCooldown -= [ability.value intValue];
        }
    }
    
    return totalCooldown;
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

-(void) addDamage:(int)damage
{
    self.additionalDamage += damage;
}

-(void) addLife: (int)amount{
    _life += amount;
    if (_life < 0)
        _life = 0;
}


-(void) setupAsPlayerHero: (NSString*) name onSide:(int) side;
{
    self.name = name;
    self.type = cardTypePlayer;
    self.maximumLife = 20000;
    self.life = 20000;
  
    self.damage = 0;
    self.cooldown = 0;
    self.side = side;
}

//TODO not used
-(void)applyAbility: (Ability*) ability
{
    Ability* abilityCopy = [[Ability alloc] initWithType:ability.abilityType castType:ability.castType targetType:targetSelf withDuration:ability.durationType withValue:ability.value  withOtherValues:ability.otherValues]; //NOTE ability.otherValues is immutable so this is fine?
    
    [self.abilities addObject:abilityCopy];
}

@end
