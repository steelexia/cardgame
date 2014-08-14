//
//  DeckModel.h
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardModel.h"
#import "CDDeckModel.h"

/**
 Stores an array of CardModel in the deck. Also provides utility functions for various deck operations.
 */
@interface DeckModel : NSObject

@property (strong, readonly) NSMutableArray *cards;

/** Name of the deck for construction purposes */
@property (strong) NSString *name;

/** Array of string tags representing the deck */
@property (strong) NSMutableArray *tags;

/** Used only if needed for synching with core data. If this deck was loaded from core data, it should have this variable */
@property (strong) CDDeckModel *cdDeck;

/** For parse */
@property (strong) NSString*objectID;

/** Adds a CardModel into cards. Returns NO if contains duplicate, not a CardModel, or deck is full */
-(BOOL) addCard: (CardModel*) cardModel;

/** Returns the card at the index */
-(CardModel*) getCardAtIndex: (int) index;

/** Removes the card at the index and returns it */
-(CardModel*) removeCardAtIndex: (int) index;

/** Returns the number of cards in the deck */
-(int) count;

/** Reorders all cards in the deck. Used during games */
-(void) shuffleDeck;

@end

/** Max number of cards allowed in a deck during regular gameplay. This is not a hard limit in the code but should be obeyed in the deck construction UI */
extern const int MAX_CARDS_IN_DECK;