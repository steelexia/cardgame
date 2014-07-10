//
//  AIPlayer+Utility.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-07-10.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "AIPlayer+Utility.h"


@implementation AIPlayer (Utility)

-(NSArray*)getAbilityTargets:(Ability*)ability attacker:(MonsterCardModel*)attacker target:(MonsterCardModel*)target
{
    NSArray *targets = [NSArray array];
    int side = attacker.side;
    int oppositeSide = attacker.side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
    
    //all of the target types. Put the target into the array targets for applying abilities later
    if (ability.targetType == targetSelf)
        targets = @[attacker];
    else if (ability.targetType == targetVictim)
        targets = @[target];
    else if (ability.targetType == targetVictimMinion)
    {
        if (target.type == cardTypePlayer) //do not cast ability if target is not a minion
            return @[];
        else
            targets = @[target];
    }
    else if (ability.targetType == targetAttacker)
    {
        if (target != nil)
            targets = @[target];
        else
            targets = @[]; //no target if damaged by spellCard
    }
    /** Same range of targets */
    else if (ability.targetType == targetAll || ability.targetType == targetOneAny || ability.targetType == targetOneRandomAny )
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.gameModel.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        [allTargets addObjectsFromArray:self.gameModel.battlefield[oppositeSide]];
        [allTargets addObject:((PlayerModel*)self.gameModel.players[side]).playerMonster];
        [allTargets addObject:((PlayerModel*)self.gameModel.players[oppositeSide]).playerMonster];
        
        targets = [NSArray arrayWithArray:allTargets];
    }
    else if (ability.targetType == targetAllMinion || ability.targetType == targetOneAnyMinion || ability.targetType == targetOneRandomMinion)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.gameModel.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        [allTargets addObjectsFromArray:self.gameModel.battlefield[oppositeSide]];
        
        targets = [NSArray arrayWithArray:allTargets];
    }
    else if (ability.targetType == targetAllFriendly || ability.targetType == targetOneFriendly || ability.targetType == targetOneRandomFriendly)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.gameModel.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        [allTargets addObject:((PlayerModel*)self.gameModel.players[side]).playerMonster];
        
        targets = [NSArray arrayWithArray:allTargets];
    }
    else if (ability.targetType == targetAllFriendlyMinions || ability.targetType == targetOneFriendlyMinion || ability.targetType == targetOneRandomFriendlyMinion)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.gameModel.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        targets = [NSArray arrayWithArray:allTargets];
    }
    else if (ability.targetType == targetAllEnemy || ability.targetType == targetOneEnemy || ability.targetType == targetOneRandomEnemy)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.gameModel.battlefield[oppositeSide]];
        [allTargets addObject:((PlayerModel*)self.gameModel.players[oppositeSide]).playerMonster];
        
        targets = [NSArray arrayWithArray:allTargets];
    }
    else if (ability.targetType == targetAllEnemyMinions || ability.targetType == targetOneEnemyMinion || ability.targetType == targetOneRandomEnemyMinion)
    {
        targets = [NSArray arrayWithArray:self.gameModel.battlefield[oppositeSide]];
    }
    else if (ability.targetType == targetHeroAny)
    {
        PlayerModel *player = self.gameModel.players[PLAYER_SIDE];
        PlayerModel *opponent = self.gameModel.players[OPPONENT_SIDE];
        targets = @[player, opponent];
         
    }
    else if (ability.targetType == targetHeroFriendly)
    {
        PlayerModel *player = self.gameModel.players[side];
        targets = @[player.playerMonster];
    }
    else if (ability.targetType == targetHeroEnemy)
    {
        PlayerModel *enemy = self.gameModel.players[oppositeSide];
        targets = @[enemy.playerMonster];
    }
    
    return targets;
}

@end
