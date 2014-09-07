//
//  Level.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-15.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeckModel.h"
#import "MonsterCardModel.h"

@interface Level : NSObject

//Level infos
@property (strong) NSString*levelID;
@property (strong) DeckModel*cards;

/** Name of the opponent's hero to be displayed */
@property (strong)NSString*opponentName;

/** MonsterCardModel for boss fights */
@property (strong)MonsterCardModel*bossCard;

@property int opponentHealth;

@property int goldReward;
@property int cardReward;

/** For AI */
@property int difficultyOffset;

/** For single player images */
@property int heroId;

/** Set this for battles that have breakBeforeNextLabel set to NO. */
@property (strong) NSString*endBattleText;

//Level settings
/** Boss fights has no enemy hero, instead it's a minion on the field */
@property BOOL isBossFight;
/** If set to NO, next level begins immediately after winning */
@property BOOL breakBeforeNextLevel;
/** Should the AI shuffle its deck */
@property BOOL opponentShuffleDeck;
/** Should the player shuffle its deck */
@property BOOL playerShuffleDeck;
@property BOOL playerGoesFirst;
/** For making some code shorter for tutorial levels */
@property BOOL isTutorial;

-(instancetype)initWithID:(NSString*)levelID;

@end
