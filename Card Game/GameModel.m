//
//  GameModel.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "GameModel.h"
#import "GameViewController+Animation.h"

@implementation GameModel

const int MAX_BATTLEFIELD_SIZE = 5;
const int MAX_HAND_SIZE = 8;
const char PLAYER_SIDE = 0, OPPONENT_SIDE = 1;

@synthesize gameViewController = _gameViewController;
@synthesize battlefield = _battlefield;
@synthesize graveyard = _graveyard;
@synthesize hands = _hands;
@synthesize players = _players;
@synthesize decks = _decks;
@synthesize gameOver = _gameOver;
@synthesize aiPlayer = _aiPlayer;

//TEMPORARY
int cardIDCount = 0;

-(instancetype)initWithViewController:(GameViewController *)gameViewController matchType: (enum MatchType)matchType
{
    self = [super init];
    
    if (self){
        self.matchType = matchType;
        self.gameViewController = gameViewController;
        
        //initialize battlefield and hands to be two arrays
        self.battlefield = @[[NSMutableArray array],[NSMutableArray array]];
        self.graveyard = @[[NSMutableArray array],[NSMutableArray array]];
        self.hands = @[[NSMutableArray array],[NSMutableArray array]];
        self.decks = @[[[DeckModel alloc] init], [[DeckModel alloc] init ]];
        
        //temporary fills up each deck with random cards
        [self fillDecks];
        
        //temporary players are hardcoded
        MonsterCardModel *playerHeroModel = [[MonsterCardModel alloc] initWithIdNumber:0];
        [playerHeroModel setupAsPlayerHero:@"Player 1" onSide:PLAYER_SIDE];
        PlayerModel *player = [[PlayerModel alloc] initWithPlayerMonster: playerHeroModel];
        //player.resource = 9;
        
        MonsterCardModel *opponentHeroModel = [[MonsterCardModel alloc] initWithIdNumber:0];
        [opponentHeroModel setupAsPlayerHero:@"Player 2" onSide:OPPONENT_SIDE];
        PlayerModel *opponent = [[PlayerModel alloc] initWithPlayerMonster: opponentHeroModel];
        //opponent.resource = 9;
        
        self.players = @[player, opponent];
        
        self.aiPlayer = [[AIPlayer alloc] initWithPlayerModel:opponent gameViewController:gameViewController gameModel: self];
        
        //start a new game, each player draws three cards
        [self startGame];
    }
    
    return self;
}

-(void)startGame
{
    //TODO load decks from database
    
    
    //draw three cards per side
    for (int side = 0; side < 2; side++)
    {
        DeckModel *deck = self.decks[side];
        //shuffle deck
        [deck shuffleDeck]; //TURN THIS ON/OFF FOR DEBUGGING
        
        //draw 3 cards
        for (int i = 0; i < 3; i++)
        {
            [self drawCard:side];
        }
    }
}

-(void)newTurn:(int)side
{
    //add a resource and update it
    PlayerModel *player = self.players[side];
    player.maxResource++;
    player.resource = player.maxResource;
    
    //new turn effects to all cards (e.g. deduct cooldown)
    for (MonsterCardModel* monsterCard in self.battlefield[side])
    {
        [self cardNewTurn:monsterCard fromSide: side];
        [monsterCard.cardView updateView];
    }
    
    //draws another card
    [self drawCard:side];
}

-(void) endTurn: (int) side
{
    //end turn effects to all cards (e.g. deduct cooldown)
    for (MonsterCardModel* monsterCard in self.battlefield[side])
    {
        [self cardEndTurn:monsterCard fromSide: side];
        [monsterCard.cardView updateView];
    }
}

-(BOOL)drawCard:(int)side
{
    DeckModel *deck = self.decks[side];
    NSMutableArray *hand = self.hands[side];
    
    if ([deck count] > 0 && hand.count < MAX_HAND_SIZE)
    {
        [hand addObject: [deck removeCardAtIndex:0]];
    }
    
    //TODO deal damage to player maybe
    
    return NO;
}

/** TODO this is a temporary function used to fill decks up with random cards for testing */
-(void)fillDecks
{
    self.decks = @[ [SinglePlayerCards getDeckOne], [SinglePlayerCards getDeckOne]];
    
    /*
    for (int side = 0; side < 2; side++)
    {
        //add 10 random spell cards
        for (int i = 0; i < 3; i++)
        {
            SpellCardModel *card = [[SpellCardModel alloc] initWithIdNumber:cardIDCount++];
            card.name = @"No Name";
            
            card.cost = 1;
            
            Ability *ability;
            
            int random = arc4random_uniform(4);
            
            if (random == 0)
            {
                ability = [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetAllEnemyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1000]];
                card.cost = 2;
            }
            else if (random == 1){
                card.cost = 2;
                ability = [[Ability alloc] initWithType:abilityAddLife castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:2000]];
            }
            else if (random == 2){
                card.cost = 3;
                ability = [[Ability alloc] initWithType:abilityLoseCooldown castType:castOnSummon targetType:targetAllFriendlyMinions withDuration:durationInstant withValue:[NSNumber numberWithInt:1]];}
            else if (random == 3){
                ability = [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:3000]];}
            else if (random == 4){
                ability = [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneRandomFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:2000]];}
            
            //if (i == 0)
            //{
                ability = [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneRandomMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:1]];
                
                //Ability *ability = [[Ability alloc] initWithType:abilityAddCooldown castType:castOnDamaged targetType:targetAttacker withDuration:durationInstant withValue:[NSNumber numberWithInt:2]];
                
            //}
            
            [card.abilities addObject:ability];
            
            [self.decks[side] addCard:card];
        }
        
        //add 20 random monster cards
        for (int i = 0; i < 20; i++)
        {
            MonsterCardModel *card = [[MonsterCardModel alloc] initWithIdNumber:cardIDCount++];
            
            card.name = @"No Name";
            
            card.cost = arc4random_uniform(6);
            card.cost -= 2; //just for a little bit of fake distribution
            if (card.cost == 0) card.cost = 1;
            
            card.damage = (10 + arc4random_uniform(10 * pow(card.cost,1.5)) + 10 * card.cost) * 50;
            card.maximumLife = card.life = (20 + arc4random_uniform(15 * pow(card.cost,1.5)) + 15 * card.cost) * 50;
            card.side = side;
            
            //high cost cards may have cooldown
            if (card.cost > 2)
                card.maximumCooldown = card.cooldown = arc4random_uniform(2) + 1;
            if (card.cost > 4)
                card.maximumCooldown = card.cooldown += arc4random_uniform(1);
            
            //TODO temporary testing ability
            
            //for (int j = 0; j < card.cost; j++)
            //{
            

            
            if (i == 0)
            {
                Ability *ability = [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:2000]];

                                    
                [card.abilities addObject:ability];
            }
        
            [self.decks[side] addCard:card];
        }
    }
     */
}

-(void)addCardToBattlefield: (MonsterCardModel*)monsterCard side:(char)side
{
    [self.battlefield[side] addObject:monsterCard];
    monsterCard.side = side;
    monsterCard.deployed = YES;
}

-(BOOL) canSummonCard: (CardModel*)card side:(char)side
{
    PlayerModel *player = (PlayerModel*) self.players[side];
    
    //checks if player can afford this first before caring about card type
    if (player.resource >= card.cost)
    {
        if ([card isKindOfClass: [MonsterCardModel class]])
        {
            MonsterCardModel *monsterCard = (MonsterCardModel*) card;
            
            //has space for more cards
            if ([self.battlefield[side] count] < MAX_BATTLEFIELD_SIZE && !monsterCard.deployed)
                return YES;
        }
        else if ([card isKindOfClass: [SpellCardModel class]])
        {
            SpellCardModel *spellCard = (SpellCardModel*) card;
            
            NSArray *friendlyField = self.battlefield[side];
            NSArray *enemyField = self.battlefield[side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE];
            
            //check if has valid target. If one ability has no valid target then card is invalid (e.g. targets enemy hero & all enemy minions but no enemy minions on field then invalid)
            for (Ability *ability in spellCard.abilities)
            {
                enum TargetType targetType = ability.targetType;
                
                //if targets friendly minion but none on field, not allowed
                if (targetType == targetOneRandomFriendlyMinion ||
                    targetType == targetAllFriendlyMinions ||
                    targetType == targetOneRandomFriendlyMinion)
                {
                    if ([friendlyField count] == 0)
                        return NO;
                }
                else if(targetType == targetOneRandomEnemyMinion ||
                        targetType == targetAllEnemyMinions ||
                        targetType == targetOneRandomEnemyMinion)
                {
                    if ([enemyField count] == 0)
                        return NO;
                }
                else if (targetType == targetAllMinion ||
                         targetType == targetOneRandomMinion)
                {
                    if ([friendlyField count] == 0 && [enemyField count] == 0)
                        return NO;
                }
                
                //TODO additional goes here
            }
            
            return YES;
        }
    }
    
    return NO;
}

-(void)summonCard: (CardModel*)card side:(char)side
{
    PlayerModel *player = (PlayerModel*) self.players[side];
    
    if ([card isKindOfClass: [MonsterCardModel class]])
    {
        MonsterCardModel *monsterCard = (MonsterCardModel*) card;
        
        [self addCardToBattlefield:monsterCard side:side];
        
        //CastType castOnSummon is casted here
        for (Ability *ability in monsterCard.abilities)
            if (ability.castType == castOnSummon)
                [self castAbility:ability byMonsterCard:monsterCard toMonsterCard:nil fromSide:side];
    }
    else if ([card isKindOfClass: [SpellCardModel class]])
    {
        for (Ability *ability in card.abilities)
            if (ability.castType == castOnSummon)
                [self castAbility:ability byMonsterCard:nil toMonsterCard:nil fromSide:side];
    }
    
    //remove card and use up cost
    [self.hands[side] removeObject:card];
    player.resource -= card.cost;
}

-(BOOL)addCardToHand: (CardModel*)card side:(char)side
{
    //has space for more cards
    if ([self.hands[side] count] < MAX_HAND_SIZE)
    {
        [self.hands[side] addObject:card];
        
        //if is MonsterCardModel, set deployed to YES
        if ([card isKindOfClass: [MonsterCardModel class]])
            ((MonsterCardModel*)card).deployed = YES;
        
        return YES;
    }
    
    //no space for more cards
    return NO;
}

-(void)cardNewTurn: (MonsterCardModel*) monsterCard fromSide: (int)side
{
    //cooldown deduction
    monsterCard.cooldown--;
    
    //CastType castOnMove is casted here
    if (monsterCard.cooldown == 0)
    {
        for (Ability *ability in monsterCard.abilities)
            if (ability.castType == castOnMove)
                [self castAbility:ability byMonsterCard:monsterCard toMonsterCard:nil fromSide:side];
    }
}

-(void)cardEndTurn: (MonsterCardModel*) monsterCard fromSide: (int)side
{
    //cast abilities that castOnEndOfTurn
    for (Ability *ability in monsterCard.abilities)
        if (ability.castType == castOnEndOfTurn)
            [self castAbility:ability byMonsterCard:monsterCard toMonsterCard:nil fromSide:side];
    
    //remove abilities that durationUntilEndOfTurn
    NSMutableArray *removedAbilities = [NSMutableArray array];
    
    //cast type must also be always since that means it's already casted
    for (Ability *ability in monsterCard.abilities)
        if (ability.durationType == durationUntilEndOfTurn && ability.castType == castAlways)
            [removedAbilities addObject:ability];
    
    for (Ability *removedAbility in removedAbilities)
        [monsterCard.abilities removeObject:removedAbility];
    
    //check for dead
    if (monsterCard.dead)
        [self cardDies:monsterCard destroyedBy:nil fromSide:side];
}

-(int)calculateDamage: (MonsterCardModel*)attacker fromSide:(int) side dealtTo:(MonsterCardModel*)target
{
    //damage already includes attacker's abilities
    int damage = attacker.damage;
    
    
    //additional modifiers, especially from defender
    return damage;
}

-(NSArray*)attackCard: (CardModel*) attacker fromSide: (int) side target: (MonsterCardModel*)target
{
    if ([attacker isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel *attackerMonsterCard = (MonsterCardModel*)attacker;
        
        int oppositeSide = side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
        
        int attackerDamage = [self calculateDamage:attackerMonsterCard fromSide:side dealtTo:target];
        [target loseLife: attackerDamage];
        
        int defenderDamage = [self calculateDamage:target fromSide:oppositeSide dealtTo:attackerMonsterCard];
        [attackerMonsterCard loseLife: defenderDamage];
        
        //CastType castOnDamaged is casted here by defender
        for (Ability *ability in target.abilities)
            if (ability.castType == castOnDamaged)
                [self castAbility:ability byMonsterCard:target toMonsterCard:attackerMonsterCard fromSide:oppositeSide];
        
        //CastType castOnHit is casted here by attacker
        for (Ability *ability in attackerMonsterCard.abilities)
            if (ability.castType == castOnHit)
                [self castAbility:ability byMonsterCard:attackerMonsterCard toMonsterCard:target fromSide:side];
        
        //CastType castOnDamaged is casted here by attacker
        for (Ability *ability in attackerMonsterCard.abilities)
            if (ability.castType == castOnDamaged)
                [self castAbility:ability byMonsterCard:attackerMonsterCard toMonsterCard:target fromSide:side];
        
        //CastType castOnHit is casted here by defender
        for (Ability *ability in target.abilities)
            if (ability.castType == castOnHit)
                [self castAbility:ability byMonsterCard:target toMonsterCard:attackerMonsterCard fromSide:oppositeSide];
        
        attackerMonsterCard.cooldown = attackerMonsterCard.maximumCooldown;
        
        //target dies
        if (target.dead)
            [self cardDies:target destroyedBy:attackerMonsterCard fromSide:oppositeSide];
        
        //attacker dies
        if (attackerMonsterCard.dead)
            [self cardDies:attackerMonsterCard destroyedBy:target fromSide:side];
        
        return @[[NSNumber numberWithInt:attackerDamage],[NSNumber numberWithInt:defenderDamage]];
    }
    
    return 0;
    //TODO spellcard
}

-(BOOL)canAttack: (MonsterCardModel*) attacker fromSide: (int) side
{
    //cannot attack if cooldown is above 0
    if (attacker.cooldown > 0)
        return NO;
    
    //cannot attack if no damage value
    if (attacker.damage <= 0)
        return NO;
    
    return YES;
}

-(BOOL)validAttack: (CardModel*) attacker target: (MonsterCardModel*)target
{
    if ([attacker isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel *attackerMonsterCard = (MonsterCardModel*)attacker;
        
        //TODO
    }
    
    return YES;
}

-(void)cardDies: (CardModel*) card destroyedBy: (CardModel*) attacker fromSide: (int) side
{
    if ([card isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel *monsterCard = (MonsterCardModel*)card;
        
        MonsterCardModel* attackerMonster = nil;
        if ([attacker isKindOfClass:[MonsterCardModel class]])
            attackerMonster = (MonsterCardModel*)attacker;
        
        //CastType castOnDeath is casted here
        for (Ability *ability in monsterCard.abilities)
            if (ability.castType == castOnDeath)
                [self castAbility:ability byMonsterCard:monsterCard toMonsterCard:attackerMonster fromSide:side];
        
        //TODO DurationType durationUntilDeath is removed here, but currently no point of removing it at death
        
        //remove it from the battlefield
        [self.battlefield[side] removeObject:monsterCard];
    }
    
    [self.graveyard[side] addObject:card]; //add it to the graveyard
}

/**
 The core method for handing all abilities that are casted. attacker and target can be nil if targetType is applicable (e.g. targetOneAny, targetAll can omit target)
 CastType is not relevant since it is already called in the correct place.
 DurationType is not as relevant either since it is not handed here.
 AbilityType and TargetType is main concern here.
 Notes: If target is not nil for the picked targetTypes such as targetOneAny, it is assume that target is the chosen target. Otherwise target should always be nil for that targetType, as it should only be used with castOnSummon, which does not have a target.
 */
-(void)castAbility: (Ability*) ability byMonsterCard: (MonsterCardModel*) attacker toMonsterCard: (MonsterCardModel*) target fromSide: (int)side
{
    //first find array of targets to apply effects on
    NSArray *targets;
    
    int oppositeSide = side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
    
    //all of the target types. Put the target into the array targets for applying abilities later
    if (ability.targetType == targetSelf)
        targets = @[attacker];
    else if (ability.targetType == targetVictim)
        targets = @[target];
    else if (ability.targetType == targetAttacker)
    {
        if (target != nil)
            targets = @[target];
        else
            targets = @[]; //no target if damaged by spellCard
    }
    else if (ability.targetType == targetOneAny)
    {
        if (target != nil)
            targets = @[target];
        else
        {
            if (side == PLAYER_SIDE)
            {
                //NOTE: change here for any future abilities that makes a target immune
                
                for (MonsterCardModel *monster in self.battlefield[PLAYER_SIDE])
                    if (monster != attacker) //cannot target self
                        monster.cardView.cardHighlightType = cardHighlightTarget;
                
                PlayerModel *player = self.players[PLAYER_SIDE];
                player.playerMonster.cardView.cardHighlightType = cardHighlightTarget;
                
                for (MonsterCardModel *monster in self.battlefield[OPPONENT_SIDE])
                    monster.cardView.cardHighlightType = cardHighlightTarget;
                
                PlayerModel *opponent = self.players[OPPONENT_SIDE];
                opponent.playerMonster.cardView.cardHighlightType = cardHighlightTarget;
                
                [self.gameViewController pickAbilityTarget:ability];
            }
            
            //does not actually cast it immediately since it requires the player to pick a target
            return;
        }
    }
    else if (ability.targetType == targetOneFriendly)
    {
        if (target != nil)
            targets = @[target];
        else
        {
            if (side == PLAYER_SIDE)
            {
                for (MonsterCardModel *monster in self.battlefield[PLAYER_SIDE])
                    if (monster != attacker) //cannot target self
                        monster.cardView.cardHighlightType = cardHighlightTarget;
                
                PlayerModel *player = self.players[PLAYER_SIDE];
                player.playerMonster.cardView.cardHighlightType = cardHighlightTarget;
                
                [self.gameViewController pickAbilityTarget:ability];
            }
            
            //does not actually cast it immediately since it requires the player to pick a target
            return;
        }
    }
    else if (ability.targetType == targetOneEnemy)
    {
        if (target != nil)
            targets = @[target];
        else
        {
            if (side == PLAYER_SIDE)
            {
                for (MonsterCardModel *monster in self.battlefield[OPPONENT_SIDE])
                    monster.cardView.cardHighlightType = cardHighlightTarget;
                
                PlayerModel *opponent = self.players[OPPONENT_SIDE];
                opponent.playerMonster.cardView.cardHighlightType = cardHighlightTarget;
                
                [self.gameViewController pickAbilityTarget:ability];
            }
            
            //does not actually cast it immediately since it requires the player to pick a target
            return;
        }
        
    }
    else if (ability.targetType == targetAll)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        [allTargets addObjectsFromArray:self.battlefield[oppositeSide]];
        [allTargets addObject:((PlayerModel*)self.players[side]).playerMonster];
        [allTargets addObject:((PlayerModel*)self.players[oppositeSide]).playerMonster];
        
        targets = [NSArray arrayWithArray:allTargets];
    }
    else if (ability.targetType == targetAllMinion)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        [allTargets addObjectsFromArray:self.battlefield[oppositeSide]];
        
        targets = [NSArray arrayWithArray:allTargets];
    }
    else if (ability.targetType == targetAllFriendly)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        [allTargets addObject:((PlayerModel*)self.players[side]).playerMonster];
        
        targets = [NSArray arrayWithArray:allTargets];
    }
    else if (ability.targetType == targetAllFriendlyMinions)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        targets = [NSArray arrayWithArray:allTargets];
    }
    else if (ability.targetType == targetAllEnemy)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[oppositeSide]];
        [allTargets addObject:((PlayerModel*)self.players[oppositeSide]).playerMonster];
        
        targets = [NSArray arrayWithArray:allTargets];
    }
    else if (ability.targetType == targetAllEnemyMinions)
    {
        targets = [NSArray arrayWithArray:self.battlefield[oppositeSide]];
        
    }
    else if (ability.targetType == targetOneRandomAny)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        [allTargets addObjectsFromArray:self.battlefield[oppositeSide]];
        [allTargets addObject:((PlayerModel*)self.players[side]).playerMonster];
        [allTargets addObject:((PlayerModel*)self.players[oppositeSide]).playerMonster];
        
        targets = @[allTargets[arc4random_uniform(allTargets.count-1)]];
    }
    else if (ability.targetType == targetOneRandomMinion)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        [allTargets addObjectsFromArray:self.battlefield[oppositeSide]];
        
        targets = @[allTargets[arc4random_uniform(allTargets.count-1)]];
    }
    else if (ability.targetType == targetOneRandomFriendly)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        [allTargets addObject:((PlayerModel*)self.players[side]).playerMonster];
        
        targets = @[allTargets[arc4random_uniform(allTargets.count-1)]];
    }
    else if (ability.targetType == targetOneRandomFriendlyMinion)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        
        targets = @[allTargets[arc4random_uniform(allTargets.count-1)]];
    }
    else if (ability.targetType == targetOneRandomEnemy)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[oppositeSide]];
        [allTargets addObject:((PlayerModel*)self.players[oppositeSide]).playerMonster];
        
        targets = @[allTargets[arc4random_uniform(allTargets.count-1)]];
    }
    else if (ability.targetType == targetOneRandomEnemyMinion)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[oppositeSide]];
        
        targets = @[allTargets[arc4random_uniform(allTargets.count-1)]];
    }
    else if (ability.targetType == targetHeroAny)
    {
        if (target != nil)
            targets = @[target];
        else
        {
            if (side == PLAYER_SIDE)
            {
                PlayerModel *player = self.players[PLAYER_SIDE];
                player.playerMonster.cardView.cardHighlightType = cardHighlightTarget;
                
                PlayerModel *opponent = self.players[OPPONENT_SIDE];
                opponent.playerMonster.cardView.cardHighlightType = cardHighlightTarget;
                
                [self.gameViewController pickAbilityTarget:ability];
            }
            
            //does not actually cast it immediately since it requires the player to pick a target
            return;
        }
    }
    else if (ability.targetType == targetHeroFriendly)
    {
        targets = @[self.players[side]];
    }
    else if (ability.targetType == targetHeroEnemy)
    {
        targets = @[self.players[oppositeSide]];
    }
    
    //apply the effect to the targets NOTE: this loop is inefficient but saves a lot of lines
    for (MonsterCardModel* target in targets)
    {
        Ability * appliedAbility;
        //all effects are first added to the abilities: add the ability to the object with castType as castAlways as they're already casted, and pass all other values on. Instant effects are applied right after
        appliedAbility = [[Ability alloc] initWithType:ability.abilityType castType:castAlways targetType:targetSelf withDuration:ability.durationType withValue:ability.value withOtherValues:ability.otherValues];
        
        //apply the instant effects before they're added
        if (ability.durationType == durationInstant)
            [self castInstantAbility:appliedAbility onMonsterCard:target];
        //not happening right away, store it in there
        else
        {
            [target.abilities addObject:appliedAbility];
            
            //Add special cases here:
            
            if (ability.abilityType == abilityAddMaxLife) //also includes a one-time heal
                target.life += [ability.value intValue];
        }
    }
}

/** Since castAbility adds instant abilities as an ability, this method actually applies the ability so that it can be removed. Calling an ability that's not applicable results in no effect */
-(void) castInstantAbility: (Ability*) ability onMonsterCard: (MonsterCardModel*) monster
{
    if (ability.abilityType == abilityAddLife)
    {
        int originalHealth = monster.life; //will only pop up the change in health
        [monster healLife:[ability.value intValue]];
        [self.gameViewController animateCardHeal:monster.cardView forLife:monster.life - originalHealth];
    }
    else if (ability.abilityType == abilityLoseLife)
    {
        [monster loseLife:[ability.value intValue]];
        [self.gameViewController animateCardDamage:monster.cardView forDamage:[ability.value integerValue] fromSide:monster.side];
    }
    else if (ability.abilityType == abilityKill)
    {
        int lifeLost = monster.life;
        [monster loseLife:monster.life];
        [self.gameViewController animateCardDamage:monster.cardView forDamage:lifeLost fromSide:monster.side];
    }
    else if (ability.abilityType == abilitySetCooldown)
        monster.cooldown = [ability.value intValue];
    else if (ability.abilityType == abilityAddCooldown)
        monster.cooldown += [ability.value intValue];
    else if (ability.abilityType == abilityLoseCooldown)
        monster.cooldown -= [ability.value intValue];
    else
        NSLog(@"WARNING: Tried to cast an instant ability of AbilityType %d that cannot be casted as durationInstant. Set it to a different DurationType, such as durationForever.", ability.abilityType);
    
    //update view and check for death
    [monster.cardView updateView];
    
    if (monster.dead)
        [self cardDies:monster destroyedBy:nil fromSide:monster.side];
}

-(void) checkForGameOver
{
    PlayerModel *player = self.players[PLAYER_SIDE];
    PlayerModel *enemy = self.players[OPPONENT_SIDE];
    
    if (player.playerMonster.dead && enemy.playerMonster.dead)
    {
        NSLog(@"Game ended in a draw!");
        self.gameOver = YES;
    }
    else if (player.playerMonster.dead)
    {
        NSLog(@"Player 1 lost!");
        self.gameOver = YES;
    }
    else if (enemy.playerMonster.dead)
    {
        NSLog(@"Player 2 lost!");
        self.gameOver = YES;
    }
    
    if (self.gameOver)
    {
        [self.gameViewController.backgroundView setUserInteractionEnabled:NO];
        [self.gameViewController.handsView setUserInteractionEnabled:NO];
        [self.gameViewController.fieldView setUserInteractionEnabled:NO];
        [self.gameViewController.uiView setUserInteractionEnabled:NO];
    }
}

@end
