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

/** constructor with id number, all other fields will be defaut values */
-(instancetype)initWithIdNumber: (long)idNumber
{
    self = [super initWithIdNumber:idNumber];
    
    if (self)
    {
        self.damage = 0;
        self.life = self.maximumLife = 1;
        self.cooldown = self.maximumCooldown = 1;
        self.deployed = NO;
    }
    
    return self;
}

/** damage will be 0 if set any lower */
-(void)setDamage:(int)damage{
    _damage = damage > 0 ? damage : 0;
}

-(int)damage{
    return _damage;
}

/** life can be above maximumHealth, but negative numbers become 0 */
-(void)setLife:(int)life{
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
    return _maximumLife;
}

/** cooldown will be 0 if set any lower */
-(void)setCooldown:(int)cooldown{
    _cooldown = cooldown > 0 ? cooldown : 0;
}

-(int)cooldown{
    return _cooldown;
}

/** Checks if the card is dead (i.e. life = 0) */
-(BOOL)isDead{
    return self.life <= 0 ? YES : NO;
}

-(void) loseLife: (int) amount{
    self.life = self.life - amount;
}

@end
