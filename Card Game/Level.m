//
//  Level.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-15.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "Level.h"
#import "SinglePlayerCards.h"


@implementation Level

-(instancetype)initWithID:(NSString*)levelID
{
    self = [super init];
    
    if (self)
    {
        _levelID = levelID;
        _opponentName = @"";
        _cards = [SinglePlayerCards getCampaignDeckWithID:_levelID];
        _goldReward = 0;
        _cardReward = 0;
        _opponentHealth = HERO_MAX_LIFE;
        _endBattleText = @"";
        _breakBeforeNextLevel = YES;
        _isBossFight = NO;
        _opponentShuffleDeck = YES;
        _playerShuffleDeck = YES;
        _playerGoesFirst = YES;
        _isTutorial = NO;
        _difficultyOffset = 0;
        _heroId = NO_ID;
    }
    
    return self;
}



@end
