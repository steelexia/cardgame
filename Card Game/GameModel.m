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
            [self.hands[side] addObject: [deck removeCardAtIndex:0]];
        }
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
            card.life = (20 + arc4random_uniform(15 * pow(card.cost,1.5)) + 15 * card.cost) * 50;
            
            //high cost cards may have cooldown
            if (card.cost > 2)
                card.cooldown = arc4random_uniform(2) + 1;
            if (card.cost > 4)
                card.cooldown += arc4random_uniform(1);
            
            [self.decks[side] addCard:card];
        }
    }
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

-(BOOL)summonCard: (CardModel*)card side:(char)side
{
    if ([card isKindOfClass: [MonsterCardModel class]])
    {
        MonsterCardModel *monsterCard = (MonsterCardModel*) card;
        
        PlayerModel *player = (PlayerModel*) self.players[side];
        
        //checks if player can afford this
        if (player.resource >= monsterCard.cost)
        {
            BOOL addCardSuccessful = [self addCardToBattlefield:monsterCard side:side];
            
            if (addCardSuccessful)
            {
                player.resource -= monsterCard.cost;
                [self.hands[side] removeObject:card];
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

-(void)cardNewTurn: (MonsterCardModel*) monsterCard
{
    //cooldown deduction (add card effects here)
    monsterCard.cooldown--;
}

-(int)calculateDamage: (MonsterCardModel*)attacker fromSide:(int) side dealtTo:(MonsterCardModel*)target
{
    int damage = attacker.damage;
    
    //TODO modifiers such as spell cards' effects, target's armour, etc
    
    return damage;
}

-(void)attackCard: (CardModel*) attacker fromSide: (int) side target: (MonsterCardModel*)target
{
    if ([attacker isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel *attackerMonsterCard = (MonsterCardModel*)attacker;
        
        int damage = [self calculateDamage:attackerMonsterCard fromSide:side dealtTo:target];
        [target loseLife: damage];
        
        attackerMonsterCard.cooldown = attackerMonsterCard.maximumCooldown;
        
        int oppositeSide = side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
        
        //target dies
        if (target.dead)
        {
            [self cardDies:target fromSide:oppositeSide];
        }
    }
    
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

-(void)cardDies: (CardModel*) card fromSide: (int) side
{
    if ([card isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel *monsterCard = (MonsterCardModel*)card;
        
        //TODO any abilities that casts on death
        
        //remove it from the battlefield
        [self.battlefield[side] removeObject:monsterCard];
    }
    
    [self.graveyard[side] addObject:card]; //add it to the graveyard
}

@end
