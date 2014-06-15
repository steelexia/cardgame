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

//variables for convenience
NSArray*hand;
NSArray*field;
NSArray*enemyField;
PlayerModel*enemyPlayer;
PlayerModel*selfPlayer;

-(instancetype)initWithPlayerModel: (PlayerModel*) playerModel gameViewController:(GameViewController*)gameViewController gameModel:(GameModel*) gameModel
{
    self = [super init];
    
    if (self)
    {
        self.gameViewController = gameViewController;
        self.playerModel = playerModel;
        self.gameModel = gameModel;
        
        hand = self.gameModel.hands[OPPONENT_SIDE];
        field = self.gameModel.battlefield[OPPONENT_SIDE];
        enemyField = self.gameModel.battlefield[PLAYER_SIDE];
        enemyPlayer = self.gameModel.players[PLAYER_SIDE];
        selfPlayer = self.gameModel.players[OPPONENT_SIDE];
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
    for (CardModel* card in hand)
    {
        //if it's possible to summon this card, decide what to do with it
        if ([self.gameModel canSummonCard:card side:OPPONENT_SIDE])
        {
            //if is a monster card, summon as long as there's space
            if ([card isKindOfClass:[MonsterCardModel class]])
            {
                [self pickAbilityTarget:card]; //searches for castOnSummon ability and picks a target
                [self.gameViewController summonCard:card fromSide:OPPONENT_SIDE];
                self.currentTarget = nil; //clear it once it's casted
                return NO; //finished one move cycle
            }
            
            //if is spell card, summon it if there's at least one monster on the field, or if hand is full, and there is no monster card left to summon
            else if ([card isKindOfClass:[SpellCardModel class]])
            {
                BOOL hasSummonableMonsterCard = NO;
                //check if has a monsterCard it can summon
                for (CardModel *card in hand)
                {
                    if ([card isKindOfClass:[MonsterCardModel class]] && [self.gameModel canSummonCard:card side:OPPONENT_SIDE])
                    {
                        hasSummonableMonsterCard = YES;
                        break;
                    }
                }
                
                NSLog(@"AI: has summonable monster card: %@", hasSummonableMonsterCard ? @"YES" : @"NO");
                
                if ([field count] > 0 || [hand count] == MAX_HAND_SIZE || !hasSummonableMonsterCard) //TODO use this either way
                {
                    //TODO check what kind of spell it is
                    if ([card.abilities count] > 0) //must have abilities but just in case
                    {
                        //if found a target, it will be stored in self.currentTarget. If it didn't find a target, don't use it.
                        [self pickAbilityTarget:card];
                    }
                    else
                        NSLog(@"WARNING: AI has a spell card with no ability");
                
                    BOOL cardHasValidTarget = NO;
                    for (Ability *ability in card.abilities)
                    {
                        if ([self.gameModel abilityHasValidTargets:ability castedBy:card side:OPPONENT_SIDE])
                        {
                            cardHasValidTarget = YES;
                            break;
                        }
                    }
                    
                    if (!cardHasValidTarget) //card has no valid target, don't use it
                        return YES;
                    
                    [self.gameViewController summonCard:card fromSide:OPPONENT_SIDE];
                    self.currentTarget = nil; //clear it once it's casted
                    return NO; //finished one move cycle
                    
                    //NSLog(@"AI: didn't find any target for a spell card.");
                }
            }
        }
    }
    
    return YES;
}

-(BOOL) processFieldCards
{
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


/** 
 The AI picks a target for cards with targetType that allows choosing. Note that this is ONLY for processing onSummon abilities, since no other castType can use choosable targetType.
 */
-(void) pickAbilityTarget: (CardModel*) card
{
    //for simplicity only checks first ability, assumes rest are all identical. NOTE: player cards will likely be a mix, but AI cards must be structured properly
    Ability* onSummonAbility;
    
    for (Ability *ability in card.abilities)
    {
        if (!ability.expired && ability.castType == castOnSummon) //search for a castOnSummon ability
        {
            onSummonAbility = ability;
            break;
        }
    }
    
    //if did not find an ability (or a valid ability), don't need to pick target
    if (onSummonAbility == nil)
        return;
    
    enum TargetType targetType = onSummonAbility.targetType;
    
    if (targetType == targetOneFriendly)
    {
        //target first monster on field, or hero if N/A
        if ([field count] > 0)
            self.currentTarget = field[0]; //TODO!!!!!!!!!!!!!! This is cheating for monsterCards
        else
            self.currentTarget = selfPlayer.playerMonster;
    }
    else if (targetType == targetOneFriendlyMinion)
    {
        if ([field count] > 0)
            self.currentTarget = field[0];
    }
    else if (targetType == targetOneEnemy)
    {
        //target first enemy monster on field, or hero if N/A
        if ([enemyField count] > 0)
            self.currentTarget = enemyField[0];
        else
            self.currentTarget = enemyPlayer.playerMonster;
    }
    else if (targetType == targetOneEnemyMinion)
    {
        if ([enemyField count] > 0)
            self.currentTarget = enemyField[0];
    }
    else if (targetType == targetOneAny)
    {
        //not harmful, has monster, target it
        if ([field count] > 0 && ![self isHarmfulAbility:card.abilities[0] toTarget:field[0]])
        {
            self.currentTarget = field[0];
        }
        //not harmful, target player
        else if ([self isHarmfulAbility:card.abilities[0] toTarget:selfPlayer.playerMonster])
        {
            self.currentTarget = selfPlayer.playerMonster;
        }
        else if ([enemyField count] > 0 && [self isHarmfulAbility:card.abilities[0] toTarget:enemyField[0]])
        {
            self.currentTarget = enemyField[0];
        }
        //not harmful, target player
        else if ([self isHarmfulAbility:card.abilities[0] toTarget:enemyPlayer.playerMonster])
        {
            self.currentTarget = enemyPlayer.playerMonster;
        }
    }
    else if (targetType == targetOneAnyMinion)
    {
        //not harmful, has monster, target it
        if ([field count] > 0 && ![self isHarmfulAbility:card.abilities[0] toTarget:field[0]])
        {
            self.currentTarget = field[0];
        }
        //harmful, has enemy
        else if ([enemyField count] > 0 && [self isHarmfulAbility:card.abilities[0] toTarget:enemyField[0]])
        {
            self.currentTarget = enemyField[0];
        }
    }
}



/** If an ability is considered "harmful", it will never target it at a target of its own minion. Otherwise it will target itself. */
-(BOOL)isHarmfulAbility: (Ability*) ability toTarget:(MonsterCardModel*)target
{
    enum AbilityType type = ability.abilityType;
    //TODO some depend on target
    
    if (type == abilityLoseLife ||
        type == abilityLoseDamage ||
        type == abilityKill ||
        type == abilityAddCooldown ||
        type == abilityAddMaxCooldown ||
        type == abilityRemoveAbility //TODO
        )
        return YES;
    else if (type == abilitySetCooldown)
    {
        if ([ability.value intValue] <= target.cooldown)
            return NO;
        else
            return YES;
    }
    
    return NO;
    /*
    abilityNil, //acts as nil pointer
    abilityAddDamage,
    abilityLoseDamage,
    abilityAddLife, //heal
    abilityAddMaxLife, //also heals
    abilityLoseLife,
    abilityKill,
    abilitySetCooldown, //mostly used for setting it to 0
    abilityAddCooldown,
    abilityAddMaxCooldown,
    abilityLoseCooldown,
    abilityLoseMaxCooldown,
    
    //future
    abilityLeech, //gain life equal to x% of damage
    abilityTaunt, //enemy must attack this. Spells are ignored
    abilityFracture, //split into ~1-3 monsters with 60%, 25%, and 10% original stats
    abilityDrawCard, //draw x number of cards, instant effect
    abilityFaceDown, //card is placed faced down until it attacks or is attacked (REALLY cool)
    abilityHideLife, //hide a card's health (or maybe only hero), only a visual effect
    abilityKillIfBelowHealth, //kill a card if its health is below x. Good for low number such as below 1000 to kill off monsters that would have died if damage/life were 1000 times smaller.
    abilityReflect, //reflect x% of damage deal by the attacker instead of its attack
    abilityRemoveAbility, //target abilities become useless and prevents target from receiving more
    abilitySpellImmunity, //might be only for single player, target is immune to all spells and abilities
    abilityCrushingBlow,
    abilityAssassinate,*/
}

@end
