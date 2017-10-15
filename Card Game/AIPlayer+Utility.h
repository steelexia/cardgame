//
//  AIPlayer+Utility.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-07-10.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "AIPlayer.h"
@class MonsterCardModel;
@class CardModel;
#import "Ability.h"


/** Extra utility functions that don't require constant changing/tweaking goes here */
@interface AIPlayer (Utility)

/** Returns eligible targets for the given ability with attacker and target. For simple targetTypes, the array contains all minions that will be targetted. For selectable targets, it contains all mininos that can be targetted.  */
-(NSArray*)getAbilityTargets:(Ability*)ability attacker:(MonsterCardModel*)attacker target:(MonsterCardModel*)target fromSide:(int)side;

/** Cheap way of estimating the value of an ability that is not being casted. Returns a mulitplier that should be multiplied to points of an ability. For example, targetAllEnemy is 2.5 times better than targetOneEnemy when deploying a minion with deal damage on death ability */
-(int)getTargetTypeMultipliedPoints:(enum TargetType)targetType points:(int)points;

-(NSArray*)copyMonsterArray:(NSArray*)monsters;

-(int)getMostMonsterValueFromSide: (int)side;

-(int)getCardBaseCost:(CardModel*)card;

@end
