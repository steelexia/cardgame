//
//  UserModel.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-27.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeckModel.h"
/** Stores all the data of a user, such as cards, decks, coins, etc. NOT to be confused with PlayerModel, which is used during in-game. All data is stored as static variables */
@interface UserModel : NSObject

+(void)setupUser;
+(void)loadAllCards;
+(void)loadAllDecks;
+(void)saveDeck:(DeckModel*)deck;
+(void)deleteDeck:(DeckModel*)deck;
+(void)publishCard:(CardModel*)card;
@end

/** Array of CardModel's that the player has. */
NSMutableArray*userAllCards;
NSMutableArray*userAllCDCards;
NSMutableArray*userAllDecks;
NSManagedObjectContext*userCDContext;
DeckModel *userCurrentDeck;
int userDeckLimit;



/** The number of decks allowed per player at the very beginning of the game. Can gain more via quests etc. */
extern const int INITIAL_DECK_LIMIT;