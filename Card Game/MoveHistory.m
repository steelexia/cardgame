//
//  MoveHistory.m
//  cardgame
//
//  Created by Steele on 2014-10-13.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "MoveHistory.h"


@implementation MoveHistory

@synthesize caster = _caster;
@synthesize casterValue = _casterValue;
@synthesize targets = _targets;
@synthesize moveType = _moveType;
@synthesize targetsValues = _targetsValues;
@synthesize side = _side;
@synthesize allMonsters = _allMonsters;

-(instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _caster = nil;
        _casterValue = @"";
        _targets = [NSMutableArray array];
        _targetsValues = [NSMutableArray array];
        _moveType = MoveTypeSummon;
        _side = 0;
        _allMonsters = [NSMutableArray array];
    }
    
    return self;
}

-(instancetype)initWithCaster:(CardModel*)caster withTargets:(NSMutableArray*)targets withMoveType:(enum MoveType) moveType withSide:(int)side withBoardState:(NSMutableArray*)allMonsters
{
    self = [super init];
    
    if (self)
    {
        if ([caster isKindOfClass:[MonsterCardModel class]])
        {
            //if is monster, keep a copy
            MonsterCardModel*monster = [[MonsterCardModel alloc] initWithCardModel:caster];
            monster.originalCard = (MonsterCardModel*)caster;
            _caster = monster;
        }
        else
        {
            _caster = caster;
        }

        _casterValue = @"";
        _targets = targets;
        _targetsValues = [NSMutableArray arrayWithCapacity:targets.count];
        
        _allMonsters = [NSMutableArray arrayWithCapacity:allMonsters.count];
        for (int i = 0; i < allMonsters.count; i++)
        {
            MonsterCardModel*monster = allMonsters[i];
            MonsterCardModel*monsterCopy = [[MonsterCardModel alloc]initWithCardModel:monster];
            monsterCopy.originalCard = monster;
            
            _allMonsters[i] = monsterCopy;
        }

        for (int i = 0; i < _targetsValues.count; i++)
        {
            _targetsValues[i] = @"";
        }
        _moveType = moveType;
        _side = side;
    }
    
    return self;
}

-(void)addTarget:(MonsterCardModel*)target
{
    //don't add dups
    for (int i = 0; i < _targets.count; i++)
    {
        MonsterCardModel* monster = _targets[i];
        if (monster.originalCard == target)
            return;
    }

    //if target is in allMonsters (i.e. not a monster created by ability), add to list with link to new monster
    for (int i = 0; i < _allMonsters.count; i++)
    {
        MonsterCardModel*monster = _allMonsters[i];
        if (monster.originalCard == target)
        {
            [_targets addObject:monster];
            [_targetsValues addObject:@""];
            return;
        }
    }
    
    //monster created by ability, add it without an originalCard
    [_targets addObject:target];
    [_targetsValues addObject:@""];
}


-(void)updateAllValues
{
    if ([_caster isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel*casterMonster = (MonsterCardModel*)_caster;
        
        _casterValue = [self getNewValueWithOldMonster:casterMonster withNewMonster:casterMonster.originalCard];
    }
    
    for (int i = 0; i < _targets.count; i++)
    {
        MonsterCardModel*oldMonster = _targets[i];
        MonsterCardModel*newMonster = oldMonster.originalCard == nil ? oldMonster : oldMonster.originalCard;
        
        _targetsValues[i] = [self getNewValueWithOldMonster:oldMonster withNewMonster:newMonster];
    }
    
    //clears allMonsters array to save memory
    _allMonsters = nil;
}

-(NSString*)getNewValueWithOldMonster:(MonsterCardModel*)oldMonster withNewMonster:(MonsterCardModel*)newMonster
{
    int lifeChange = newMonster.life - oldMonster.life;
    NSString*lifeChangeString = lifeChange > 0 ? [NSString stringWithFormat:@"+%d", lifeChange] : [NSString stringWithFormat:@"%d", lifeChange];
    
    int dmgChange = [newMonster damage] - [oldMonster damage];
    NSString*dmgChangeString = dmgChange > 0 ? [NSString stringWithFormat:@"+%d", dmgChange] : [NSString stringWithFormat:@"%d", dmgChange];
    
    //if damage changes, display as +-X/+-X, e.g. +3 attack would show as +3/0
    if (dmgChange != 0)
    {
        return [NSString stringWithFormat:@"%@/%@", dmgChangeString, lifeChangeString];
    }
    //if only life changes, show as one number e.g. +3 health would show as +3
    else if (lifeChange != 0)
    {
        return lifeChangeString;
    }

    return @"";
}

@end
