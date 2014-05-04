//
//  GameModel.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "GameModel.h"

@implementation GameModel

const int MAX_BATTLEFIELD_SIZE = 5;
const int MAX_HAND_SIZE = 8;
const char PLAYER_SIDE = 0, OPPONENT_SIDE = 1;

@synthesize gameViewController = _gameViewController;
@synthesize battlefield = _battlefield;
@synthesize hands = _hands;

-(instancetype)initWithViewController:(GameViewController *)gameViewController
{
    self = [super init];
    
    if (self){
        self.gameViewController = gameViewController;
        
        //initialize battlefield and hands to be two arrays
        self.battlefield = @[[NSMutableArray array],[NSMutableArray array]];
        self.hands = @[[NSMutableArray array],[NSMutableArray array]];
    }
    
    return self;
}

-(BOOL)addCardToBattlefield: (MonsterCardModel*)monsterCard side:(char)side
{
    //has space for more cards
    if ([self.battlefield[side] count] < MAX_BATTLEFIELD_SIZE && !monsterCard.deployed)
    {
        [self.battlefield[side] addObject:monsterCard];
        monsterCard.deployed = YES;
        return YES;
    }
    
    //no space for more cards
    return NO;
}

-(int)calculateDamage: (MonsterCardModel*)attacker dealtTo:(MonsterCardModel*)target
{
    int damage = attacker.damage;
    
    //TODO modifiers such as spell cards' effects, target's armour, etc
    
    return damage;
}

@end
