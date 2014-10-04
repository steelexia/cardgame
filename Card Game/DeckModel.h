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

/** For player decks, if this is set to NO, it cannot be used in battle. */
@property BOOL isInvalid;

/** If is not valid, this will contain array of reasons why it's invalid */
@property (strong) NSMutableArray *invalidReasons;

/** Adds a CardModel into cards. Returns NO if contains duplicate, not a CardModel, or deck is full */
-(BOOL) addCard: (CardModel*) cardModel;
-(BOOL) insertCard: (CardModel*) cardModel atIndex:(NSUInteger)index;

/** Returns the card at the index */
-(CardModel*) getCardAtIndex: (int) index;

/** Removes the card at the index and returns it */
-(CardModel*) removeCardAtIndex: (int) index;

/** Returns the number of cards in the deck */
-(int) count;

/** Reorders all cards in the deck. Used during games */
-(void) shuffleDeck;

/** Sort the deck according to idNumber */
-(void)sortDeck;

+(void) validateDeck:(DeckModel*)deck;

/** Assumes deck is already invalid! */
+(BOOL) isDeckInvalidOnlyTooFewCards:(DeckModel*)deck;

+(void) validateDeckIgnoreTooFewCards:(DeckModel*)deck;

/** Returns the elements and abilities that can no longer be added to the deck. */
+(NSArray*)getLimits:(DeckModel*)deck;

+(NSArray*)getElementArraySummary:(DeckModel*)deck;
+(NSString*)getElementSummary:(DeckModel*)deck;

@end

/** Max number of cards allowed in a deck during regular gameplay. This is not a hard limit in the code but should be obeyed in the deck construction UI */
extern const int MAX_CARDS_IN_DECK;