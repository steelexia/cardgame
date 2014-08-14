//
//  DeckCollectionView.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-25.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomTableView.h"
#import "UIConstants.h"
#import "StrokedLabel.h"

/** This view doubles as a container for all decks a player as built, as well as a container for all cards in a deck that is currently being built. */
@interface DeckTableView :UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong) CustomTableView *tableView;

/** The stored data depends on the current mode. When editing all decks, the array stores DeckModel's. When editing a single deck, the array stores CardModel. */
@property (strong) NSMutableArray *currentCells;

@property enum DeckTableViewMode viewMode;

-(void)removeCellAt:(int)index;

-(void)removeAllCells;

@end

enum DeckTableViewMode
{
    deckTableViewCards,
    deckTableViewDecks,
};
