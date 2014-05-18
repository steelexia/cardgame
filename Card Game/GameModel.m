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

//TEMPORARY
int cardIDCount = 0;

-(instancetype)initWithViewController:(GameViewController *)gameViewController
{
    self = [super init];
    
    if (self){
        self.gameViewController = gameViewController;
        
        //initialize battlefield and hands to be two arrays
        self.battlefield = @[[NSMutableArray array],[NSMutableArray array]];
        self.graveyard = @[[NSMutableArray array],[NSMutableArray array]];
        self.hands = @[[NSMutableArray array],[NSMutableArray array]];
        self.decks = @[[[DeckModel alloc] init], [[DeckModel alloc] init ]];
        
        //temporary fills up each deck with random cards
        [self fillDecks];
        
        //temporary players are hardcoded
        MonsterCardModel *playerMonsterCard = [[MonsterCardModel alloc] initWithIdNumber:999];
        playerMonsterCard.life = 20000;
        PlayerModel *player = [[PlayerModel alloc] initWithPlayerMonster: playerMonsterCard];
        //player.resource = 9;
        
        MonsterCardModel *opponentMonsterCard = [[MonsterCardModel alloc] initWithIdNumber:998];
        opponentMonsterCard.life = 20000;
        PlayerModel *opponent = [[PlayerModel alloc] initWithPlayerMonster: opponentMonsterCard];
        //opponent.resource = 9;
        
        self.players = @[player, opponent];
        
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
        //[deck shuffleDeck]; //TODO!!!!!!!!!!!!
        
        //draw 3 cards
        for (int i = 0; i < 3; i++)
        {
            [self drawCard:side];
        }
    }
}

-(void)newTurn:(int)side
{
    //new turn effects to all cards (e.g. deduct cooldown)
    for (MonsterCardModel* monsterCard in self.battlefield[side])
    {
        [self cardNewTurn:monsterCard fromSide: side];
        [monsterCard.cardView updateView];
    }
    
    //draws another card
    [self drawCard:side];
    
    
    //add a resource and update it
    PlayerModel *player = self.players[side];
    player.maxResource++;
    player.resource = player.maxResource;
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
    for (int side = 0; side < 2; side++)
    {
        //add 20 random cards
        for (int i = 0; i < 20; i++)
        {
            MonsterCardModel *card = [[MonsterCardModel alloc] initWithIdNumber:cardIDCount++];
            
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
            
            //TODO just some temporary tests
            /*
             int abilityType = abilityNil + 1 + arc4random_uniform(9);
             int castType = castNil + 1 + arc4random_uniform(3);
             int targetType = targetNil + 1 + arc4random_uniform(13);
             int durationType = durationNil + 1 + arc4random_uniform(3);
             int value = 0;
             
             if (abilityType == abilityLoseCooldown || abilityType == abilityLoseMaxCooldown || abilityType == abilityAddCooldown || abilityType == abilityAddMaxCooldown)
             {
             value = 1 + arc4random_uniform(3);
             }
             else
             value = arc4random_uniform(200) * 50;
             
             Ability *ability = [[Ability alloc] initWithType:abilityType castType:castType targetType:targetType withDuration:durationType withValue:[NSNumber numberWithInt:value]];
             */
            
            if (i == 0)
            {
                Ability *ability = [[Ability alloc] initWithType:abilityAddLife castType:castOnHit targetType:targetAllMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:500]];
            
                [card.abilities addObject:ability];
            }
            
            [self.decks[side] addCard:card];
        }
    }
}

-(void)addCardToBattlefield: (MonsterCardModel*)monsterCard side:(char)side
{
    
    [self.battlefield[side] addObject:monsterCard];
    monsterCard.deployed = YES;
}

-(BOOL) canSummonCard: (CardModel*)card side:(char)side
{
    if ([card isKindOfClass: [MonsterCardModel class]])
    {
        MonsterCardModel *monsterCard = (MonsterCardModel*) card;
        
        PlayerModel *player = (PlayerModel*) self.players[side];
        
        //checks if player can afford this
        if (player.resource >= monsterCard.cost)
        {
            //has space for more cards
            if ([self.battlefield[side] count] < MAX_BATTLEFIELD_SIZE && !monsterCard.deployed)
            {
                return YES;
            }
        }
    }
    else if ([card isKindOfClass: [SpellCardModel class]])
    {
        //TODO
    }
    
    return NO;
}

-(void)summonCard: (CardModel*)card side:(char)side
{
    if ([card isKindOfClass: [MonsterCardModel class]])
    {
        MonsterCardModel *monsterCard = (MonsterCardModel*) card;
        
        PlayerModel *player = (PlayerModel*) self.players[side];
        [self addCardToBattlefield:monsterCard side:side];
        
        player.resource -= monsterCard.cost;
        [self.hands[side] removeObject:card];
        
        //CastType castOnSummon is casted here
        for (Ability *ability in monsterCard.abilities)
            if (ability.castType == castOnSummon)
                [self castAbility:ability byMonsterCard:monsterCard toMonsterCard:nil fromSide:side];
    }
    else if ([card isKindOfClass: [SpellCardModel class]])
    {
        //TODO
    }
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
    
    for (Ability *ability in monsterCard.abilities)
        if (ability.durationType == durationUntilEndOfTurn)
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

-(int)attackCard: (CardModel*) attacker fromSide: (int) side target: (MonsterCardModel*)target
{
    if ([attacker isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel *attackerMonsterCard = (MonsterCardModel*)attacker;
        
        int damage = [self calculateDamage:attackerMonsterCard fromSide:side dealtTo:target];
        [target loseLife: damage];
        
        //CastType castOnDamaged is casted here by defender
        for (Ability *ability in target.abilities)
            if (ability.castType == castOnDamaged)
                [self castAbility:ability byMonsterCard:target toMonsterCard:attackerMonsterCard fromSide:side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE];
        
        //CastType castOnHit is casted here by attacker
        for (Ability *ability in attackerMonsterCard.abilities)
            if (ability.castType == castOnHit)
                [self castAbility:ability byMonsterCard:attackerMonsterCard toMonsterCard:target fromSide:side];
    
        attackerMonsterCard.cooldown = attackerMonsterCard.maximumCooldown;
        
        int oppositeSide = side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
        
        //target dies
        if (target.dead)
            [self cardDies:target destroyedBy:attackerMonsterCard fromSide:oppositeSide];
        
        return damage;
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
 AbilityType and TargetType is main concern here
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
        //TODO pick one
    }
    else if (ability.targetType == targetOneFriendly)
    {
        //TODO
    }
    else if (ability.targetType == targetOneEnemy)
    {
        //TODO
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
        //TODO
    }
    else if (ability.targetType == targetHeroFriendly)
    {
        //TODO
    }
    else if (ability.targetType == targetHeroEnemy)
    {
        //TODO
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
        [monster loseLife:monster.life];
        [self.gameViewController animateCardDamage:monster.cardView forDamage:3000 fromSide:monster.side];
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

@end
