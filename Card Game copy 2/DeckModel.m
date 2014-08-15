//
//  DeckModel.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "DeckModel.h"
#import "AbilityWrapper.h"

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
        _invalidReasons = [NSMutableArray array];
        _isInvalid = NO;
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

+(void) validateDeck:(DeckModel*)deck
{
    [self validateDeck:deck checkTooFewCards:YES];
}

+(void) validateDeckIgnoreTooFewCards:(DeckModel*)deck
{
    [self validateDeck:deck checkTooFewCards:NO];
}

+(BOOL) isDeckInvalidOnlyTooFewCards:(DeckModel*)deck
{
    [self validateDeck:deck checkTooFewCards:NO];
    return !deck.isInvalid;
}

+(void) validateDeck:(DeckModel*)deck checkTooFewCards:(BOOL)checkTooFewCards
{
    deck.isInvalid = NO;
    deck.invalidReasons = [NSMutableArray array];
    
    //check if too many
    if (deck.count > MAX_CARDS_IN_DECK)
    {
        deck.isInvalid = YES;
        [deck.invalidReasons addObject:@"Maximum card limit reached."];
    }
    
    if (checkTooFewCards)
    {
        //check if too few
        if (deck.count < MAX_CARDS_IN_DECK)
        {
            deck.isInvalid = YES;
            [deck.invalidReasons addObject:@"Not enough cards in deck."];
        }
    }
    
    //check opposite elements
    NSMutableDictionary*elements = [NSMutableDictionary dictionary];
    for (CardModel *card in deck.cards)
    {
        [elements setValue:@(YES) forKey:[NSString stringWithFormat:@"%d", card.element]];
        
        if (card.element == elementFire)
        {
            if (elements[[NSString stringWithFormat:@"%d", elementIce]] != nil)
            {
                deck.isInvalid = YES;
                [deck.invalidReasons addObject:@"Cannot have both Fire and Ice cards."];
                break;
            }
        }
        else if (card.element == elementIce)
        {
            if (elements[[NSString stringWithFormat:@"%d", elementFire]] != nil)
            {
                deck.isInvalid = YES;
                [deck.invalidReasons addObject:@"Cannot have both Fire and Ice cards."];
                break;
            }
        }
        else if (card.element == elementLightning)
        {
            if (elements[[NSString stringWithFormat:@"%d", elementEarth]] != nil)
            {
                deck.isInvalid = YES;
                [deck.invalidReasons addObject:@"Cannot have both Thunder and Earth cards."];
                break;
            }
        }
        else if (card.element == elementEarth)
        {
            if (elements[[NSString stringWithFormat:@"%d", elementLightning]] != nil)
            {
                deck.isInvalid = YES;
                [deck.invalidReasons addObject:@"Cannot have both Thunder and Earth cards."];
                break;
            }
        }
        else if (card.element == elementLight)
        {
            if (elements[[NSString stringWithFormat:@"%d", elementDark]] != nil)
            {
                deck.isInvalid = YES;
                [deck.invalidReasons addObject:@"Cannot have both Light and Dark cards."];
                break;
            }
        }
        else if (card.element == elementDark)
        {
            if (elements[[NSString stringWithFormat:@"%d", elementLight]] != nil)
            {
                deck.isInvalid = YES;
                [deck.invalidReasons addObject:@"Cannot have both Light and Dark cards."];
                break;
            }
        }
    }
    
    //check ability limits
    NSMutableDictionary*abilities = [NSMutableDictionary dictionary];
    for (CardModel *card in deck.cards)
    {
        for (Ability* ability in card.abilities)
        {
            int wrapperID = [AbilityWrapper getIdWithAbility:ability];
            
            if (wrapperID != -1)
            {
                NSString *key = [NSString stringWithFormat:@"%d", wrapperID];
                NSNumber *value = abilities[key];
                
                if (value == nil)
                    [abilities setValue:@(1) forKey:key];
                else
                {
                    AbilityWrapper*wrapper = [AbilityWrapper getWrapperWithId:wrapperID];
                    
                    if (wrapper.maxCount < [value intValue] + 1)
                    {
                        NSString*abilityDescription = [[Ability getDescription:ability fromCard:card] string];
                        [deck.invalidReasons addObject:[NSString stringWithFormat: @"Following ability reached maximum limit of %d: %@", wrapper.maxCount, abilityDescription]];
                        deck.isInvalid = YES;
                    }
                    
                    [abilities setValue:@([value intValue] + 1) forKey:key];
                }
            }
        }
    }
}

@end
