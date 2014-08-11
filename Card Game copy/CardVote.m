//
//  CardVote.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-08.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CardVote.h"
#import "CardPointsUtility.h"

@implementation CardVote

-(instancetype) initWithPFObject:(PFObject*)cardVotePF
{
    self = [super init];
    
    if (self)
    {
        _totalVotes = [cardVotePF[@"totalVotes"] intValue];
        
        _averageCost  = [cardVotePF[@"averageCost"] doubleValue];
        _averageDamage  = [cardVotePF[@"averageDamage"] doubleValue];
        _averageLife  = [cardVotePF[@"averageLife"] doubleValue];
        _averageCD  = [cardVotePF[@"averageCD"] doubleValue];
        
        NSArray*abilitiesArray = cardVotePF[@"abilities"];
        
        _abilities = [NSMutableArray arrayWithCapacity:abilitiesArray.count];
        
        for (NSString*abilityString in abilitiesArray)
        {
            NSArray*stringSplit = [abilityString componentsSeparatedByString:@" "];
            
            if (stringSplit.count >= 3)
            {
                int abilityID = [stringSplit[0] intValue];
                int totalVotes = [stringSplit[1] intValue];
                double averageValue = [stringSplit[2] doubleValue];
                
                [_abilities addObject:@[@(abilityID), @(totalVotes), @(averageValue)]];
            }
        }
        
        [cardVotePF[@"currentVotedCard"] fetch];
        _votedCard = cardVotePF[@"currentVotedCard"];
    }
    
    return self;
}

-(instancetype) initWithCardModel:(CardModel*)cardModel
{
    self = [super init];
    
    if (self)
    {
        _totalVotes = 1;
        
        _averageCost  = cardModel.baseCost;
        
        if ([cardModel isKindOfClass:[MonsterCardModel class]])
        {
            MonsterCardModel *monster = (MonsterCardModel*)cardModel;
            _averageDamage  = monster.baseDamage;
            _averageLife  = monster.baseMaxLife;
            _averageCD  = monster.baseMaxCooldown;
        }
        else
        {
            _averageDamage = 1;
            _averageLife = 1;
            _averageCD = 1;
        }
        
        _abilities = [NSMutableArray arrayWithCapacity:cardModel.abilities.count];
        
        for (Ability*ability in cardModel.abilities)
        {
            int wrapperID = [AbilityWrapper getIdWithAbility:ability];
            if (wrapperID < 0)
                continue;
            
            int abilityID = wrapperID;
            int totalVotes = 1;
            double averageValue = [ability.value intValue];
            
            [_abilities addObject:@[@(abilityID), @(totalVotes), @(averageValue)]];
        }
    }
    
    return self;
}

-(void)addVote:(CardModel*)cardModel
{
    int newTotalVote = _totalVotes+1;
    
    double newVotePercent = ((double)1)/newTotalVote;
    double oldVotePercent = 1 - newVotePercent;
    
    if (cardModel.baseCost != _averageCost)
        _averageCost = _averageCost * oldVotePercent + cardModel.baseCost * newVotePercent;
    
    if ([cardModel isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel *monster = (MonsterCardModel*)cardModel;
        
        //do not update the value if they're already identical (to prevent rounding errors perhaps rounding life below 1000)
        if (monster.baseDamage != _averageDamage)
            _averageDamage = _averageDamage * oldVotePercent + monster.damage * newVotePercent;
        if (monster.baseMaxLife != _averageLife)
            _averageLife = _averageLife * oldVotePercent + monster.life * newVotePercent;
        if (monster.baseMaxCooldown != _averageCD)
            _averageCD = _averageCD * oldVotePercent + monster.cooldown * newVotePercent;
    }
    
    for (Ability*ability in cardModel.abilities)
    {
        int wrapperID = [AbilityWrapper getIdWithAbility:ability];
        
        if (wrapperID != -1)
        {
            BOOL abilityExists = NO;
            for (int i = 0; i < _abilities.count; i++)
            {
                NSArray*abilityVote = _abilities[i];
                if (abilityVote.count < 3)
                    continue;
                
                //exists
                if ([abilityVote[0] intValue] == wrapperID)
                {
                    int oldVoteCount = [abilityVote[1] intValue];
                    int newVoteCount = oldVoteCount + 1;
                    double oldAverage = [abilityVote[2] doubleValue];
                    
                    double newAbilityVotePercent = ((double)1)/(newVoteCount);
                    double oldAbilityVotePercent = 1 - newAbilityVotePercent;
                    double newAverage = oldAverage;
                    
                    if ([ability.value intValue] != oldAverage)
                    {
                        newAverage = oldAverage * oldAbilityVotePercent + [ability.value intValue] * newAbilityVotePercent;
                        NSLog(@"cur: %d old avg: %f, new avg: %f",[ability.value intValue], oldAverage, newAverage);
                    }
                    
                    _abilities[i] = @[@(wrapperID), @(newVoteCount), @(newAverage)];
                    abilityExists = YES;
                    break;
                }
            }
            
            //does not exist, add a new one
            if(!abilityExists)
                [_abilities addObject:@[@(wrapperID), @(1), ability.value != nil ? ability.value : @(0)]];
        }
    }
    
    _totalVotes++;
}


-(void)updateToPFObject:(PFObject*)cardVotePF
{
    cardVotePF[@"totalVotes"] = @(_totalVotes);
    
    cardVotePF[@"averageCost"] = @(_averageCost);
    cardVotePF[@"averageDamage"] = @(_averageDamage);
    cardVotePF[@"averageLife"] = @(_averageLife);
    cardVotePF[@"averageCD"] = @(_averageCD);
    
    NSMutableArray*abilitiesPF = [NSMutableArray arrayWithCapacity:_abilities.count];
    for (NSArray*ability in _abilities)
    {
        if (ability.count >= 3)
        {
            [abilitiesPF addObject:[NSString stringWithFormat:@"%d %d %f", [ability[0]intValue], [ability[1]intValue], [ability[2]doubleValue]]];
        }
    }
    
    cardVotePF[@"abilities"] = abilitiesPF;
    
    cardVotePF[@"currentVotedCard"] = _votedCard;
}

-(void)generatedVotedCard:(CardModel*)cardModel
{
    int statsPoints = 0;
    
    cardModel.cost = round(_averageCost);
    int maxPoints = [CardPointsUtility getMaxPointsForCard:cardModel];
    
    if ([cardModel isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel *monster = (MonsterCardModel*)cardModel;
        int averageCooldown = round(_averageCD);
        monster.cooldown = monster.maximumCooldown = averageCooldown > 0 ? averageCooldown : 1;
        
        int averageDamage = round(_averageDamage / 100) * 100;
        monster.damage = averageDamage >= 0 ? averageDamage : 0;
        
        int averageLife = round(_averageLife / 100) * 100;
        monster.life = monster.maximumLife = averageLife >= 1000 ? averageLife : 1000;
        
        statsPoints += [CardPointsUtility getStatsPointsForMonsterCard:monster];
    }
    
    //sort abilities from most votes to least
    NSMutableArray*sortedAbilities = [NSMutableArray arrayWithArray:[_abilities sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSArray*aArray = a;
        NSArray*bArray = b;
        
        NSNumber *aNumber = 0;
        if (aArray.count >= 3)
            aNumber = aArray[1];
        NSNumber *bNumber = 0;
        if (bArray.count >= 3)
            bNumber = bArray[1];
        
        return [bNumber compare:aNumber]; //from largest to smallest
    }]];
    
    //clear current abilities
    cardModel.abilities = [NSMutableArray array];
    
    NSArray *allWrappers = [AbilityWrapper allAbilities];
    
    //convert abilities into wrappers for calculation
    NSMutableArray *cardWrappers = [NSMutableArray arrayWithCapacity:cardModel.abilities.count];
    for (NSArray*abilityArray in sortedAbilities)
    {
        if (abilityArray.count >= 3)
        {
            int idNumber = [abilityArray[0] intValue];
            int abilityValue = round([abilityArray[2] doubleValue]);
            
            //round the value
            if (abilityValue > 999)
                abilityValue = round([abilityArray[2] doubleValue] / 100) * 100;
            else if (abilityValue > 99)
                abilityValue = round([abilityArray[2] doubleValue] / 10) * 10;
            
            if (idNumber >= 0 && idNumber < allWrappers.count)
            {
                AbilityWrapper *wrapper = [[AbilityWrapper alloc] initWithAbilityWrapper:allWrappers[idNumber]];
                wrapper.ability.value = @(abilityValue);
                [cardWrappers addObject:wrapper];
            }
        }
    }
    
    NSMutableArray*addedWrappers = [NSMutableArray array];
    
    BOOL reachedEnd = NO;
    
    while (!reachedEnd)
    {
        //TODO check rarity & ability limit
        
        for (int i = 0; i < cardWrappers.count; i++)
        {
            NSLog(@"loop start");
            AbilityWrapper*wrapper = cardWrappers[i];
            
            //remove wrapper if it's incompatible
            if (![wrapper isCompatibleWithCardModel:cardModel])
            {
                NSLog(@"wrapper incompatible. Removed");
                //TODO this is not the MOST accurate way, since negative wrappers can be removed later, freeing this ability up. but that is only in extremely rare cases
                [cardWrappers removeObject:wrapper];
                break;
            }
            
            //temporarily add the ability to calculate points
            [addedWrappers addObject:wrapper];
            
            //recalculate all previous wrappers, since adding a new wrapper could change cost of previous wrapper
            int currentPoints = [CardPointsUtility getWrappersTotalPoints:addedWrappers forCard:cardModel];
            
            //ability still fits
            if (maxPoints >= currentPoints + statsPoints)
            {
                NSLog(@"still fit, added");
                [cardModel addBaseAbility:wrapper.ability];
                [cardWrappers removeObject:wrapper];
                break;
            }
            //ability don't fit
            else
            {
                NSLog(@"don't fit");
                [addedWrappers removeObject:wrapper]; //remove the temporarily added
                
                //this is the last ability in the list, then there cannot possibly be another ability that can still fit
                if (i == cardWrappers.count - 1)
                {
                    NSLog(@"loop finished");
                    reachedEnd = YES;
                    break;
                }
                //else keep checking for more possible abilities
            }
        }
        
        if (cardWrappers.count == 0)
            reachedEnd = YES;
        
        //at the end, try to remove any negative abilities. for example a spell card with ability A costing 1000 and ability B costing -500 with a max cost of 1000 means that it doesn't need ability B at all, since it should be a negative effect. Also prevents negative abilities getting added instantly with a single vote (since it always fits)
        if (reachedEnd)
        {
            for (int i = 0; i < addedWrappers.count; i++)
            {
                AbilityWrapper* wrapper = addedWrappers[i];
                
                if (wrapper.currentPoints < 0)
                {
                    [addedWrappers removeObjectAtIndex:i];
                    
                    int currentPoints = [CardPointsUtility getWrappersTotalPoints:addedWrappers forCard:cardModel];
                    
                    //card's points is still good after removing the negative ability
                    if (maxPoints >= currentPoints + statsPoints)
                    {
                        NSLog(@"unnecessary negative ability. Removed");
                        //remove it for good (already removed from cardWrappers)
                        [cardModel.abilities removeObject:wrapper.ability];
                        reachedEnd = NO; //a space has been freed up, restart loop and check for other abilities to add
                        break;
                    }
                    //cannt remove this ability, insert it back. don't break and keep checking for other potential removals
                    else
                    {
                        NSLog(@"negative ability unremovable");
                        [addedWrappers insertObject:wrapper atIndex:i];
                    }
                }
            }
        }
    }
    
    if (_votedCard == nil)
        _votedCard = [PFObject objectWithClassName:@"VotedCard"];
    
    _votedCard[@"cost"] = @(cardModel.baseCost);
    
    if ([cardModel isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel *monster = (MonsterCardModel*)cardModel;
        _votedCard[@"damage"] = @(monster.baseDamage);
        _votedCard[@"life"] = @(monster.baseMaxLife);
        _votedCard[@"cooldown"] = @(monster.baseMaxCooldown);
    }
    
    //WARNING: copypasta from CardModel
    NSMutableArray *pfAbilities = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < [cardModel.abilities count]; i++){
        if ([cardModel.abilities[i] isKindOfClass:[PFObject class]]){
            [pfAbilities addObject:cardModel.abilities[i]];
        }
        //convert the ability to PFObject
        else if ([cardModel.abilities[i] isKindOfClass:[Ability class]])
        {
            Ability*ability = cardModel.abilities[i];
            int abilityID = [AbilityWrapper getIdWithAbility:ability];
            
            if (abilityID != -1)
            {
                PFObject*pfAbility = [PFObject objectWithClassName:@"Ability"];
                pfAbility[@"idNumber"] = [[NSNumber alloc] initWithInt:abilityID];
                if (ability.value == nil)
                    pfAbility[@"value"] = @0;
                else
                    pfAbility[@"value"] = ability.value;
                
                NSLog(@"%d", [pfAbility[@"value"] intValue]);
                
                pfAbility[@"otherValues"] = ability.otherValues;
                
                [pfAbilities addObject:pfAbility];
            }
            else{
                
                NSLog(@"WARNING: Could not find the id of an ability of card. Ability: %@", [Ability getDescription:ability fromCard:cardModel]);
            }
        }
    }
    
    NSArray*array = _votedCard[@"abilities"];
    
    //delete all existing abilities
    if (array != nil)
        for (PFObject *object in array)
            [object deleteEventually];
    
    _votedCard[@"abilities"] = pfAbilities;
}

@end
