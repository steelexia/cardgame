//
//  DeckModel.h
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardModel.h"

/**
 Stores an array of CardModel in the deck. Also provides utility functions for various deck operations.
 */
@interface DeckModel : NSObject

@property (strong, readonly) NSMutableArray *cards;

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
