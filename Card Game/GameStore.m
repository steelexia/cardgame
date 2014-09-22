//
//  GameStore.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-02.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "GameStore.h"

@implementation GameStore

const int LIKE_CARD_GOLD_GAIN = 15;

const int FLAVOUR_TEXT_COST = 400;

+(int)getCardCost:(CardModel*)card
{
    if (card.rarity == cardRarityCommon)
        return 100;
    else if (card.rarity == cardRarityUncommon)
        return 300;
    else if (card.rarity == cardRarityRare)
        return 900;
    else if (card.rarity == cardRarityExceptional)
        return 2200;
    else if (card.rarity == cardRarityLegendary)
        return 4800;
    
    return 100;
}

+(int)getCardSellPrice:(CardModel*)card
{
    int buyCost = [GameStore getCardCost:card];
    
    return buyCost *= 0.6;
}

@end
