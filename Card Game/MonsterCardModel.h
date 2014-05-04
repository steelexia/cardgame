//
//  MonsterCardModel.h
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CardModel.h"

/** Basic card that represents a "monster", which can be placed on the battlefield and used to attach other cards. */
@interface MonsterCardModel : CardModel

//----------------Card battle stats values----------------//

/** Amount of damage a card deal per attack */
@property int damage;

/** Amount of damage a card can sustain before dying */
@property int life;
@property int maximumLife;

/** Number of turns it takes before being able to attack */
@property int cooldown;
@property int maximumCooldown;

/** readonly, checks if card is dead, i.e. health is 0 */
@property (getter = isDead, readonly) BOOL dead;

/** keeps track if the card is currently deployed (i.e. on the battlefield) */
@property BOOL deployed;

//----------------Functions----------------//

/**
 Deducts some life from the monster card. This simply subtracts the number and does not look at any other elements such as defence. Mainly a convinience method.
 */
-(void) loseLife: (int) amount;

/** constructor */
-(instancetype)initWithIdNumber: (long)idNumber;

@end
