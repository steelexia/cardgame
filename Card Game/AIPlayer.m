//
//  AIPlayer.m
//  cardgame
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "AIPlayer.h"

@implementation AIPlayer

@synthesize playerModel = _playerModel;
@synthesize gameModel = _gameModel;
@synthesize gameViewController = _gameViewController;

-(instancetype)initWithPlayerModel: (PlayerModel*) playerModel gameViewController:(GameViewController*)gameViewController gameModel:(GameModel*) gameModel
{
    self = [super init];
    
    if (self)
    {
        self.gameViewController = gameViewController;
        self.playerModel = playerModel;
        self.gameModel = gameModel;
    }
    
    return self;
}

-(void)newTurn
{
    //current AI logic is absolutely simple: summon all monsters in hand, play all spell cards that has valid target, use all monsters to attack first enemy on field.
    [self performSelector:@selector(makeOneMove) withObject:nil afterDelay:arc4random_uniform(1000)/1000.f + 0.75]; //wait for a random duration to make the AI feel more realistic
}

-(void)makeOneMove
{
    //step 1: process the cards currently in hand
    //keep trying to summon/use cards until no more left
    BOOL outOfHandMoves = [self processHandCards];
    BOOL outOfFieldMoves = YES;
    
    //step 2: process the cards currently on field if no more hand moves
    if (outOfHandMoves)
        outOfFieldMoves = [self processFieldCards];
    
    //if hasn't run out of moves, keep trying
    if (!outOfHandMoves || !outOfFieldMoves)
        [self performSelector:@selector(makeOneMove) withObject:nil afterDelay:arc4random_uniform(500)/500.f + 0.5];
    else
        [self.gameViewController endTurn]; //out of moves, end turn
}

/** Processes all hand cards. If exhausted all possible moves, returns YES, otherwise NO */
-(BOOL) processHandCards
{
    NSArray*hand = self.gameModel.hands[OPPONENT_SIDE];
    NSArray*field = self.gameModel.battlefield[OPPONENT_SIDE];
    MonsterCardModel*enemyPlayer = self.gameModel.players[PLAYER_SIDE];
    
    for (CardModel* card in hand)
    {
        //if it's possible to summon this card, decide what to do with it
        if ([self.gameModel canSummonCard:card side:OPPONENT_SIDE])
        {
            //if is a monster card, summon as long as there's space
            if ([card isKindOfClass:[MonsterCardModel class]])
            {
                [self.gameViewController summonCard:card fromSide:OPPONENT_SIDE];
                return NO; //finished one move cycle
            }
            //if is spell card, summon it if there's at least one monster on the field, or if hand is full
            else if ([card isKindOfClass:[SpellCardModel class]])
            {
                if ([field count] > 0 || [hand count] == MAX_HAND_SIZE)
                {
                    [self.gameViewController summonCard:card fromSide:OPPONENT_SIDE];
                    return NO; //finished one move cycle
                }
            }
        }
    }
    
    return YES;
}

-(BOOL) processFieldCards
{
    NSArray*field = self.gameModel.battlefield[OPPONENT_SIDE];
    NSArray*enemyField = self.gameModel.battlefield[PLAYER_SIDE];
    PlayerModel*enemyPlayer = self.gameModel.players[PLAYER_SIDE];
    
    for (MonsterCardModel* monster in field)
    {
        //if monster can attack, use it to attack
        if ([self.gameModel canAttack:monster fromSide:OPPONENT_SIDE])
        {
            //for every monster, if is a valid target, use it to attack
            for (MonsterCardModel *enemy in enemyField)
            {
                if ([self.gameModel validAttack:monster target:enemy])
                {
                    [self.gameViewController attackCard:monster target:enemy fromSide:OPPONENT_SIDE];
                    return NO;
                }
            }
            
            //did not find an enemy target to attack, attack their hero
            if ([self.gameModel validAttack:monster target:enemyPlayer.playerMonster])
            {
                [self.gameViewController attackHero:monster target:enemyPlayer.playerMonster fromSide:OPPONENT_SIDE];
                return NO;
            }
        }
    }
    
    return YES;
}

@end
