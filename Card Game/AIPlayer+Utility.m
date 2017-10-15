//
//  AIPlayer+Utility.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-07-10.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "AIPlayer+Utility.h"
#import "GameModel.h"
#import "Ability.h"
#import "MonsterCardModel.h"
#import "PlayerModel.h"
@implementation AIPlayer (Utility)

-(NSArray*)getAbilityTargets:(Ability*)ability attacker:(MonsterCardModel*)attacker target:(MonsterCardModel*)target fromSide:(int)side
{
    NSArray *targets = [NSArray array];
    int oppositeSide = side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
    
    //all of the target types. Put the target into the array targets for applying abilities later
    if (ability.targetType == targetSelf)
    {
        if (attacker!=nil)
            targets = @[attacker];
    }
    else if (ability.targetType == targetVictim)
    {
        if (target!=nil && !target.heroic)
            targets = @[target];
    }
    else if (ability.targetType == targetVictimMinion)
    {
        if (target.type == cardTypePlayer || target.heroic) //do not cast ability if target is not a minion
            return @[];
        else if (target!=nil)
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
        
        [allTargets removeObject:[self.gameModel.players[OPPONENT_SIDE] playerMonster]]; //boss fight
        
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
        [allTargets removeObject:[self.gameModel.players[OPPONENT_SIDE] playerMonster]]; //boss fight
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
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.gameModel.battlefield[oppositeSide]];
        [allTargets removeObject:[self.gameModel.players[OPPONENT_SIDE] playerMonster]]; //boss fight
        targets = [NSArray arrayWithArray:allTargets];
    }
    else if (ability.targetType == targetHeroAny)
    {
        PlayerModel *player = self.gameModel.players[PLAYER_SIDE];
        PlayerModel *opponent = self.gameModel.players[OPPONENT_SIDE];
        targets = @[player.playerMonster, opponent.playerMonster];
         
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

-(int)getTargetTypeMultipliedPoints:(enum TargetType)targetType points:(int)points
{
    
    if (targetType == targetOneEnemy || targetType == targetHeroEnemy)
        return 1 * points;
    if (targetType == targetOneEnemyMinion)
        return 0.9 * points;
    if (targetType == targetOneRandomEnemy)
        return 0.75 * points;
    if (targetType == targetOneRandomEnemyMinion)
        return 0.7 * points;
    if (targetType == targetAllEnemy)
        return 2.5 * points;
    if (targetType == targetAllEnemyMinions)
        return 2.25 * points;
    if (targetType == targetOneFriendly || targetType == targetOneFriendlyMinion || targetType == targetSelf || targetType == targetHeroFriendly)
        return -1 * points;
    if (targetType == targetOneFriendlyMinion)
        return -0.9 * points;
    if (targetType == targetOneRandomFriendly)
        return -0.75 * points;
    if (targetType == targetOneRandomFriendlyMinion)
        return -0.7 * points;
    if (targetType == targetAllFriendly)
        return -2.5 * points;
    if (targetType == targetAllFriendlyMinions)
        return -2.25 * points;
    if (targetType == targetOneAny || targetType == targetHeroAny)
        return abs(points*1);
    if (targetType == targetOneAnyMinion)
        return abs((int)(points*0.9));
    if (targetType == targetOneRandomAny || targetType == targetOneRandomMinion)
        return 0;
    if (targetType == targetAttacker || targetType == targetVictim || targetType == targetVictimMinion)
        return 1;
    
    return points;
}

-(NSArray*)copyMonsterArray:(NSArray*)monsters
{
    NSMutableArray*copyMonsters = [NSMutableArray array];
    
    for (MonsterCardModel*monster in monsters)
    {
        MonsterCardModel*copyMonster = [[MonsterCardModel alloc]initWithCardModel:monster];
        copyMonster.originalCard = monster;
        [copyMonsters addObject:copyMonster];
    }
    
    return copyMonsters;
}

-(int)getMostMonsterValueFromSide: (int)side
{
    int mostPoints = 0;
    for (MonsterCardModel*target in self.gameModel.battlefield[side])
    {
        int targetPoints = [self evaluateMonsterValue:target];
        if (targetPoints > mostPoints)
            mostPoints = targetPoints;
    }
    return mostPoints;
}

-(int)getCardBaseCost:(CardModel*)card
{
    int cost = card.cost * -1000;
    if (cost == 0)
        cost = -250;
    
    cost += card.cost * -self.levelDifficultyOffset; //negative offset means cards are cheaper, since their stats are worse
    
    if (self.isBossFight) //boss cards are worse because the boss monster is extremely strong
        cost += card.cost * 800;
    if (self.isTutorial)
        cost = 0; //all cards are "free" so they will use every card as soon as they get it
    
    
    
    return cost;
}

@end
