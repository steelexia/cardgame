//
//  MonsterCardModel.h
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

//TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Needs String to store the creator

#import "CardModel.h"
#import "Ability.h"
@class Ability;

/** Basic card that represents a "monster", which can be placed on the battlefield and used to attach other cards. */
@interface MonsterCardModel : CardModel

//----------------Card battle stats values----------------//

/** Amount of damage a card deal per attack. Includes all modifiers from abilities, so use baseDamage for unmodified. */
@property int damage;

/** Amount of damage a card can sustain before dying */
@property int life;
@property int maximumLife;

/** Number of turns it takes before being able to attack. At 1 the card can attack every turn except the turn it was deployed on. */
@property int cooldown;
@property int maximumCooldown;

/** readonly, checks if card is dead, i.e. health is 0 */
@property BOOL dead;

/** keeps track if the card is currently deployed (i.e. on the battlefield) */
@property BOOL deployed;

/** Which side is the card deployed on. Must be PLAYER_SIDE or OPPONENT_SIDE */
@property int side;

/** For correctly iterating through turn start and ends for each card */
@property BOOL turnEnded;

/** For single player bosses, monster card with this property treats it as a hero. It won */
@property BOOL heroic;

/** Used for AI to keep track of the original card when copying them for states. */
@property (strong) MonsterCardModel*originalCard;

//----------------Functions----------------//
/**
 Deducts some life from the monster card. This simply subtracts the number and does not look at any other elements such as defence. Mainly a convinience method.
 */
-(void) loseLife: (int) amount;

/** Gains life without gaining more than maxLife */
-(void) healLife: (int) amount;

/** Adds life ignoring maxLife */
-(void) addLife: (int) amount;

/** Returns the max life without any modifiers from abilities */
-(int) baseMaxLife;

/** Returns the unmodified damage from this card */
-(int) baseDamage;

/** Returns the unmodified max cooldown from this card */
-(int) baseMaxCooldown;

/** Sets up the values for the card to become a hero card */
-(void) setupAsPlayerHero: (NSString*) name onSide:(int) side;

/** Resets the card as it was first created. Removes all added abilities and resets all stats to default. */
-(void)resetAllStats;

/** Creates another copy of ability and add it to its abilities. The ability's target type is then set to targetSelf */
-(void) applyAbility: (Ability*) ability;

/** constructor */
-(instancetype)initWithIdNumber: (int)idNumber;

/** Deep copy constructor */
//-(instancetype)initWithMonsterCard:(MonsterCardModel*)monsterCard;

@end

extern const int HERO_MAX_LIFE;
