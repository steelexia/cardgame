//
//  CardPointsUtility.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-08.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardModel.h"
#import "MonsterCardModel.h"
#import "Ability.h"
#import "AbilityWrapper.h"

/** Functions for calculation points associated with designing a card. */
@interface CardPointsUtility : NSObject

/** Max points of card is based on rarity and cost */
+(int)getMaxPointsForCard:(CardModel*)card;

/** Get max number of abilities allowed for a card. It depends on the rarity and card type */
+(int)getMaxAbilityCountForCard:(CardModel*)card;

/** Get max cost (playing cost) of a card. Depends on rarity */
+(int)getMaxCostForCard:(CardModel*)card;

/** Calculate the total points cost of an array of wrappers for a card */
+(int)getWrappersTotalPoints:(NSArray*)wrappers forCard:(CardModel*)card;

/** Get points of card's basic stats (damage, life, cooldown) */
+(int)getStatsPointsForMonsterCard:(MonsterCardModel*)monster;

/** Stores the points in wrapper */
+(void)updateAbilityPoints:(CardModel*)card forWrapper:(AbilityWrapper*)wrapper withWrappers:(NSArray*)wrappers;

+(BOOL)cardHasTaunt:(CardModel*)card;
+(BOOL)cardHasAssassin:(CardModel*)card;
+(BOOL)cardHasCharge:(CardModel*)card;

@end
