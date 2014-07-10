//
//  AIPlayer+Utility.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-07-10.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "AIPlayer.h"

/** Extra utility functions that don't require constant changing/tweaking goes here */
@interface AIPlayer (Utility)

/** Returns eligible targets for the given ability with attacker and target. For simple targetTypes, the array contains all minions that will be targetted. For selectable targets, it contains all mininos that can be targetted.  */
-(NSArray*)getAbilityTargets:(Ability*)ability attacker:(MonsterCardModel*)attacker target:(MonsterCardModel*)target;

@end
