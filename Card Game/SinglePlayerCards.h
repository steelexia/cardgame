//
//  SinglePlayerCards.h
//  cardgame
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeckModel.h"
#import "MonsterCardModel.h"
#import "SpellCardModel.h"
#import "Ability.h"

/** Stores the pre-designed cards for single player so that there's no need to read them from a file. */
@interface SinglePlayerCards : NSObject

+(DeckModel*) getDeckOne;

@end
