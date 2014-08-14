//
//  GameStore.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-02.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardModel.h"

/** All of the support functions required for the store */
@interface GameStore : NSObject
/** Cost in gold to buy a card depends completely on its rarity. */
+(int)getCardCost:(CardModel*)card;
+(int)getCardSellPrice:(CardModel*)card;

@end

extern const int LIKE_CARD_GOLD_GAIN;