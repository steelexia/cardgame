//
//  DeckModel.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "DeckModel.h"


@implementation DeckModel

@synthesize cards = _cards;
@synthesize name = _name;
@synthesize tags = _tags;
@synthesize cdDeck = _cdDeck;

const int MAX_CARDS_IN_DECK = 20;

-(instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _cards = [NSMutableArray array];
        _tags = [NSMutableArray array];
        _name = @"";
    }
    
    return self;
}

/** Note that this function does not care about max deck size for gameplay */
-(BOOL) addCard: (CardModel*) cardModel
{
    //TODO check for dup?
    if (![cardModel isKindOfClass: [CardModel class]])
        return NO;
    
    [_cards addObject:cardModel];
    return YES;
}

-(CardModel*) getCardAtIndex: (int) index
{
    return [self.cards objectAtIndex:index];
}

-(CardModel*) removeCardAtIndex: (int) index
{
    CardModel *card = [self.cards objectAtIndex:index];
    
    [self.cards removeObjectAtIndex:index];
    
    return card;
}

-(int) count
{
    return self.cards.count;
}

-(void) shuffleDeck
{
    NSMutableArray *newCards = [NSMutableArray array];
    
    //take a random card from original array and place into new array
    while ([self.cards count] > 0)
    {
        int cardIndex = arc4random_uniform([self.cards count]-1);
        
        [newCards addObject:self.cards[cardIndex]];
        [self.cards removeObjectAtIndex:cardIndex];
    }
    
    _cards = newCards;
}

@end
