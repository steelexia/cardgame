//
//  GameModel.h
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardModel.h"
#import "CardView.h"
#import "MonsterCardModel.h"
#import "SpellCardModel.h"
#import "PlayerModel.h"
#import "DeckModel.h"
#import "Ability.h"
#import "SinglePlayerCards.h"
#import "AIPlayer.h"
#import <Parse/Parse.h>
#import "AbilityWrapper.h"
#import "Level.h"

@class AIPlayer;
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
 Stores two PlayerModel's. Access the index using PLAYER_SIDE and OPPONENT_SIDE
 */
@property NSArray* players;

/**
 Stores two DeckModel's each containing a number of cards in its deck. 
 Access the index of each deck using PLAYER_SIDE and OPPONENT_SIDE.
 */
@property NSArray* decks;

@property AIPlayer* aiPlayer;

@property enum GameMode gameMode;

@property (strong)Level*level;

/** For multiplayer */
@property (strong) DeckModel*opponentDeck;

/** Stores if the game has ended */
@property BOOL gameOver;
@property BOOL playerOneDefeated, playerTwoDefeated;

/** Note that turn number increases every time end turn is pressed */
@property int turnNumber;

@property (weak) MonsterCardModel* opponentCurrentTarget;

/** Initialies the GameModel with an attached controller for drawing */
-(instancetype)initWithViewController:(GameViewController *)gameViewController gameMode: (enum GameMode)gameMode withLevel:(Level*)level;

/** Informs models that a new turn has started, and performs any necessary actions */
-(void)newTurn:(int)side;

/** Ends the turn and performs any necessary actions */
-(void)endTurn:(int)side;

/**
 Checks if possible and draws a card from hand
 */
-(BOOL)drawCard:(int)side;

/** 
 Adds a monster card to the battlefield with the specified side. side must be either PLAYER_SIDE or OPPONENT_SIDE.
 Assumes canSummonCard returns YES
 NOTE: should use summonCard for general purposes
 */
-(void)addCardToBattlefield: (MonsterCardModel*)monsterCard side:(char)side;

/**
 Checks if a card can be summoned. It first checks if the player can afford the cost. If the card is a MonsterCardModel, it means to place it on the battlefield. If the card is a SpellCardModel, it means to use it.
 Returns NO if it can not summon it, such as if addCardToBattleField returns false, or if the player summoning does not have sufficient resources */
-(BOOL)canSummonCard: (CardModel*)card side:(char)side;

/** Lazy function for AI */
-(BOOL) canSummonCard: (CardModel*)card side:(char)side withAdditionalResource:(int)resource;

/** Checks if an ability has valid targets. caster can be nil, if casted by SpellCard. */
-(BOOL)abilityHasValidTargets: (Ability*)ability castedBy:(CardModel*)caster side:(int)side;

/**
 Summon a card. If the card is a MonsterCardModel, it will attempt to place it on the battlefield. If the card is a SpellCardModel, it will attempt to use it.
 Assumes canSummonCard: card side:side returns YES */
-(void)summonCard: (CardModel*)card side:(char)side;

/**
 Adds a card to the hand of the specified player. side must be either PLAYER_SIDE or OPPONENT_SIDE.
 If successful and is , sets the card's deployed variable to NO
 Returns NO if hand reached maximum size.
 NOTE: should use drawCard for general purposes
 */
-(BOOL)addCardToHand: (CardModel*)card side:(char)side;

/** perform any new turn effects on a monsterCard, such as deducting cooldown, using abilities etc */
-(void)cardNewTurn: (MonsterCardModel*) monsterCard fromSide: (int)side;

/** Called when card ends its turn. Casts all castOnEndOfTurn effects */
-(void)cardEndTurn: (MonsterCardModel*) monsterCard fromSide: (int)side;

/**
 Calculates and returns the amount of damage dealt by an attacker MonsterCardModel to a target MonsterCardModel. It does not actually deal the damage. NOTE that this should not be used for most attack purposes. Use attackCard instead
 */
-(int)calculateDamage: (MonsterCardModel*)attacker fromSide:(int) side dealtTo:(MonsterCardModel*)target;

/** 
 Performs the attack on target. Uses calculateDamage for the damage, but also performs other functions such as reflected damage or cooldown reset. The model will also remove cards that are dead. Note that attacker may be both spell card and monster card.
    Returns array of the two damages deal. Attacker is stored in index 0, defender is stored in index 1
 */
-(NSArray*)attackCard: (CardModel*) attacker fromSide: (int)side target: (MonsterCardModel*)target;

/**
 Checks if a monsterCard can attack. Conditions for NO can be monsterCard's cooldown not being 0, or if it has no attack value, or if it is under some status ailment.
 */
-(BOOL)canAttack: (MonsterCardModel*) attacker fromSide: (int) side;

/** Determines if the target is valid. Invalid scenarios can be when the target's side has taunt card, or if target is under some protection etc. NOTE: This method assumes that canAttack: attacker is YES
 */
-(BOOL)validAttack: (CardModel*) attacker target: (MonsterCardModel*)target;

/** Performs actions needed for a card's death. This moves it to the graveyard, and performs any abilities that casts on death */
-(void)cardDies: (CardModel*) card destroyedBy: (CardModel*) attacker fromSide: (int) side;

-(void)castAbility: (Ability*) ability byMonsterCard: (MonsterCardModel*) attacker toMonsterCard: (MonsterCardModel*) target fromSide: (int)side;


/** Checks if game is over */
-(void) checkForGameOver;

-(void)startGame;
-(void)loadDecks;

-(void)setOpponentSeed:(uint32_t)seed;
-(void)setPlayerSeed:(uint32_t)seed;
-(void)setCurrentTarget:(int)targetPosition;
-(MonsterCardModel*)getTarget:(int)targetPosition;
-(int)getTargetIndex: (MonsterCardModel*)target;
+(void)loadQuickMatchDeck:(DeckModel*)deck;
+(enum CardPosition) getReversedPosition:(enum CardPosition)position;

@end

enum GameMode
{
    GameModeSingleplayer,
    GameModeMultiplayer,
};

/** Card positions on the battlefield for multiplayer purposes */
enum CardPosition
{
    positionNoPosition,
    positionHeroA,
    positionHeroB,
    positionA1,
    positionA2,
    positionA3,
    positionA4,
    positionA5,
    positionB1,
    positionB2,
    positionB3,
    positionB4,
    positionB5,
};

extern const int INITIAL_CARD_DRAW;
