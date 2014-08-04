//
//  GameStore.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-02.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "GameStore.h"

@implementation GameStore

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

@end
