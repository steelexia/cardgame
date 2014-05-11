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

-(instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _cards = [NSMutableArray array];
    }
    
    return self;
}

-(BOOL) addCard: (CardModel*) cardModel
{
    //TODO check if is full
    //TODO check for dup
    
    if ([cardModel isMemberOfClass: [CardModel class]])
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
        [newCards addObject:self.cards[arc4random_uniform([self.cards count])]];
    
    _cards = newCards;
}

@end
