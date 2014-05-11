//
//  GameModel.h
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardModel.h"
#import "MonsterCardModel.h"
#import "SpellCardModel.h"
#import "PlayerModel.h"
#import "DeckModel.h"

/** 
 Main class of the game that handles the view and controls
 */
@class GameViewController;

/** maximum number of cards that can be placed per battlefield */
const int MAX_BATTLEFIELD_SIZE;

/** maximum number of cards a player can hold in their hand */
const int MAX_HAND_SIZE;

/** Constants for representing sides */
const char PLAYER_SIDE, OPPONENT_SIDE;

/** Stores all of the data and logic related to the card game, and performs functions such as calculating card attacks*/
@interface GameModel : NSObject

/** Reference to the view controller */
@property (weak) GameViewController* gameViewController;

/** 
 Stores two arrays each containing a NSMutableArray of MonsterCardModel's on each side of the battlefield.
 Access the index of each side using PLAYER_SIDE and OPPONENT_SIDE.
 */
@property NSArray* battlefield;

/** 
 Stores two arrays each containing a NSMutableArray of CardModel's for each player's hand.
 Access the index of each side using PLAYER_SIDE and OPPONENT_SIDE.
 */
@property NSArray* hands;

/**
 Stores two arrays each containing a NSMutableArray of CardModel's for each player's dead card. Using up a spell card also counts as dead. Access the index of each side using PLAYER_SIDE and OPPONENT_SIDE 
 */
@property NSArray* graveyard;

/** 
 Stores two players. Access the index using PLAYER_SIDE and OPPONENT_SIDE
 */
@property NSArray* players;

/**
 Stores two DeckModel's each containing a number of cards in its deck. 
 Access the index of each deck using PLAYER_SIDE and OPPONENT_SIDE.
 */
@property NSArray* decks;

/** Initialies the GameModel with an attached controller for drawing */
-(instancetype)initWithViewController: (GameViewController*) gameViewController;

/**
 Checks if possible and draws a card from hand
 */
-(BOOL)drawCard:(int)side;

/** 
 Adds a monster card to the battlefield with the specified side. side must be either PLAYER_SIDE or OPPONENT_SIDE.
 If successful, sets the card's deployed variable to YES
 Returns NO if battlefield reached maximum size, or if the card's deployed variable is YES.
 NOTE: should use summonCard for general purposes
 */
-(BOOL)addCardToBattlefield: (MonsterCardModel*)monsterCard side:(char)side;

/**
 Attempts to summon a card. If the card is a MonsterCardModel, it will attempt to place it on the battlefield. If the card is a SpellCardModel, it will attempt to use it.
 Returns NO if it does not successfuly summons it, such as if addCardToBattleField returns false, or if the player summoning does not have sufficient resources */
-(BOOL)summonCard: (CardModel*)card side:(char)side;

/**
 Adds a card to the hand of the specified player. side must be either PLAYER_SIDE or OPPONENT_SIDE.
 If successful and is , sets the card's deployed variable to NO
 Returns NO if hand reached maximum size.
 NOTE: should use drawCard for general purposes
 */
-(BOOL)addCardToHand: (CardModel*)card side:(char)side;

/** perform any new turn effects on a monsterCard, such as deducting cooldown, using abilities etc */
-(void)cardNewTurn: (MonsterCardModel*) monsterCard;

/**
 Calculates and returns the amount of damage dealt by an attacker MonsterCardModel to a target MonsterCardModel. It does not actually deal the damage. NOTE that this should not be used for most attack purposes. Use attackCard instead
 */
-(int)calculateDamage: (MonsterCardModel*)attacker fromSide:(int) side dealtTo:(MonsterCardModel*)target;

/** 
 Performs the attack on target. Uses calculateDamage for the damage, but also performs other functions such as reflected damage or cooldown reset. The model will also remove cards that are dead. Note that attacker may be both spell card and monster card.
 */
-(void)attackCard: (CardModel*) attacker fromSide: (int)side target: (MonsterCardModel*)target;

/**
 Checks if a monsterCard can attack. Conditions for NO can be monsterCard's cooldown not being 0, or if it has no attack value, or if it is under some status ailment.
 */
-(BOOL)canAttack: (MonsterCardModel*) attacker fromSide: (int) side;

/** Determines if the target is valid. Invalid scenarios can be when the target's side has taunt card, or if target is under some protection etc. NOTE: This method assumes that canAttack: attacker is YES
 */
-(BOOL)validAttack: (CardModel*) attacker target: (MonsterCardModel*)target;

/** Performs actions needed for a card's death. This moves it to the graveyard, and performs any abilities that casts on death */
-(void)cardDies: (CardModel*) card fromSide: (int) side;

@end
