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

/** Initialies the GameModel with an attached controller for drawing */
-(instancetype)initWithViewController: (GameViewController*) gameViewController;

/** 
 Adds a monster card to the battlefield with the specified side. side must be either PLAYER_SIDE or OPPONENT_SIDE.
 If successful, sets the card's deployed variable to YES
 Returns NO if battlefield reached maximum size, or if the card's deployed variable is YES.
 */
-(BOOL)addCardToBattlefield: (MonsterCardModel*)monsterCard side:(char)side;

/**
 Calculates and returns the amount of damage dealt by an attacker MonsterCardModel to a target MonsterCardModel. It does not actually deal the damage.
 */
-(int)calculateDamage: (MonsterCardModel*)attacker dealtTo:(MonsterCardModel*)target;

@end
