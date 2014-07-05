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

/** A move that has no effect. Only make this move if it can free up a hand slot */
const int USELESS_MOVE = -9999998;
/** Making this move is either impossible (invalid), or will result in game lost immediately. Never make this move. */
const int IMPOSSIBLE_MOVE = -9999999;
/** Making this move will result in game won immediately. Make this move right away. */
const int VICTORY_MOVE = 9999999;

/** A rough estimate of the two side's strength. TODO */
int enemyTotalStrength, friendlyTotalStrength;

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
    [self performSelector:@selector(makeOneMove) withObject:nil afterDelay:arc4random_uniform(1000)/1000.f + 2]; //wait for a random duration to make the AI feel more realistic
}

-(void)makeOneMove
{
    //if there is running animation, wait until it's over before making another move
    if (self.gameViewController.currentNumberOfAnimations > 0)
    {
        [self performSelector:@selector(makeOneMove) withObject:nil afterDelay:0.5];
        return;
    }
    
    //step 1: process the cards currently in hand
    //keep trying to summon/use cards until no more left
    BOOL outOfHandMoves = [self processHandCards];
    BOOL outOfFieldMoves = YES;
    
    //step 2: process the cards currently on field if no more hand moves
    if (outOfHandMoves)
        outOfFieldMoves = [self processFieldCards];
    
    //if hasn't run out of moves, keep trying
    if (!outOfHandMoves || !outOfFieldMoves)
        [self performSelector:@selector(makeOneMove) withObject:nil afterDelay:arc4random_uniform(500)/500.f + 1.2];
    else
        [self.gameViewController endTurn]; //out of moves, end turn
}

/** Processes all hand cards. If exhausted all possible moves, returns YES, otherwise NO */
-(BOOL) processHandCards
{
    //TODO cost of not summoning a card (e.g. monster with wasted on summon ability)
    
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
                    return NO; //finished one move cycle
                    
                    //NSLog(@"AI: didn't find any target for a spell card.");
                }
            }
        }
    }
    
    return YES;
}

/** Processes all field cards. If exhausted all possible moves, returns YES, otherwise NO */
-(BOOL) processFieldCards
{
    MonsterCardModel *bestMonster;
    MonsterCardModel *bestTarget;
    int bestPoints = IMPOSSIBLE_MOVE;
    
    
    for (MonsterCardModel* monster in field)
    {
        //if monster can attack, try to find a target to attack
        if ([self.gameModel canAttack:monster fromSide:OPPONENT_SIDE])
        {
            //check the points against every enemy monster
            for (MonsterCardModel *enemy in enemyField)
            {
                if ([self.gameModel validAttack:monster target:enemy])
                {
                    //calculate the points and if it's better than previous, set it as new best
                    int points = [self evaluateMovePoints:monster targets:@[enemy]];
                    
                    if (points > bestPoints)
                    {
                        bestPoints = points;
                        bestMonster = monster;
                        bestTarget = enemy;
                    }
                }
            }
            
            //check the points against enemy player
            if ([self.gameModel validAttack:monster target:enemyPlayer.playerMonster])
            {
                int points = [self evaluateMovePoints:monster targets:@[enemyPlayer.playerMonster]];
                
                if (points > bestPoints)
                {
                    bestPoints = points;
                    bestMonster = monster;
                    bestTarget = enemyPlayer.playerMonster;
                }
            }
        }
    }
    
    if (bestPoints == IMPOSSIBLE_MOVE)
        NSLog(@"AI: No move left.");
    else
        NSLog(@"AI: picked move with %d points.", bestPoints);
    
    //didn't find a monster that could attack, out of moves
    if (bestPoints == IMPOSSIBLE_MOVE || bestMonster == nil)
        return YES;
    else{
        if (bestTarget.type == cardTypePlayer)
        {
            [self.gameViewController attackHero:bestMonster target:bestTarget fromSide:OPPONENT_SIDE];
        }
        else
        {
            [self.gameViewController attackCard:bestMonster target:bestTarget fromSide:OPPONENT_SIDE];
        }
        return NO; //found a target, might not out of moves yet
    }
}


/** 
 The AI picks a target for cards with targetType that allows choosing. Note that this is ONLY for processing onSummon abilities, since no other castType can use choosable targetType.
 */
-(void) pickAbilityTarget: (CardModel*) card
{
    //clear this before searching
    self.currentTarget = nil;
    
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

/** 
 RUDIMENTARY AI: (hopefully remove and use better methods eventually)
 All moves (i.e. summoning a card, casting a spell card, and attacking with a minion) are evaluated and rated with "points". The higher the points, the better the move is. When there are choices between moves, the move with most "points" is chosen.
 card can be either SpellCard or MonsterCard. Target must be a NSArray containing MonsterCardModel. If it is empty, card must be a MonsterCard, meaning that it is being summoned. Otherwise, it is assumed to be either using monster card to attack one target (so targets must be a single element), or casting spell card at target(s).
 */
-(int)evaluateMovePoints: (CardModel*)card targets:(NSArray*)targets
{
    if (targets == nil)
    {
        NSLog(@"WARNING: targets is nil in evaluateMovePoints.");
        return -99999;
    }
    
    int points = 0;
    
    if ([card isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel *monster = (MonsterCardModel*)card;
        
        //monster attack target
        if ([targets count] > 0)
        {
            MonsterCardModel*target = targets[0];

            //int attackPoint = 0;
            //int defencePoint = 0;
            int damageDealt = monster.damage < target.life ? monster.damage : target.life;
            int overDamage = monster.damage > damageDealt ? monster.damage - damageDealt : 0;
            
            int damageReceived = monster.life < target.damage ? monster.life : target.damage;
            int overDamageReceived = target.damage > monster.life ? target.damage - monster.life : 0;
            
            NSLog(@"AI: Evaluating move: Monster %d %d targetting Monster %d %d.", monster.damage, monster.life, target.damage, target.life);
            
            //attackPoint = monster.damage - target.life;
            
            //attacking hero
            if (target.type == cardTypePlayer)
            {
                //this attack can kill player, make it immediately
                if (damageDealt >= target.life)
                    return VICTORY_MOVE;
                else
                {
                    //will be reluctant to attack a full life hero
                    int lifeLost = enemyPlayer.playerMonster.maximumLife - enemyPlayer.playerMonster.life;
                    if (lifeLost < 10000)
                    {
                        points -= (10000 - lifeLost)/2;
                        NSLog(@"AI: enemy hero high life -%d points", (10000 - lifeLost)/2);
                    }
                    
                    //enemy hero having high life makes dealing damage unattractive, but enemy having low life makes any damage attractive
                    double damageModifier = (((enemyPlayer.playerMonster.maximumLife - enemyPlayer.playerMonster.life) / enemyPlayer.playerMonster.maximumLife))*2 + 0.25;
                    
                    NSLog(@"AI: enemy hero damage modifier %f", damageModifier);
                    
                    //not a fatal blow, attraction depends on enemy hero's life
                    points += damageDealt * damageModifier;
                    NSLog(@"AI: high damage hitting enemy hero +%f points", damageDealt * damageModifier);
                }
            }
            //attacking monster
            else
            {
                //if this attack cannot kill and will receive recoil damage, it's twice worse
                //if (damageDealt < target.life)
                //    attackPoint *= 2;
                
                //TODO assassin and other abilities
                
                //defencePoint = monster.life - target.damage;
                
                //friendly hero having low life makes killing targets with high life attractive
                double enemyDamageModifier = (((selfPlayer.playerMonster.maximumLife - selfPlayer.playerMonster.life) / selfPlayer.playerMonster.maximumLife))*2 + 0.25;
                
                //if this move can kill, make it positive (i.e. 1k/1k vs 1k/1k = fair trade, do it)
                if (damageDealt >= target.life)
                {
                    points += damageDealt;
                    NSLog(@"AI: damageDealt +%d points", damageDealt);
                    
                    points -= overDamage*0.33; //dealing too much damage is undesirable
                    NSLog(@"AI: overDamage -%f points", overDamage*0.33);
                    
                    //target with a high damage is a threat, remove asap
                    points += target.damage*0.75 * enemyDamageModifier;
                    NSLog(@"AI: friendly hero damage modifier %f", enemyDamageModifier);
                    NSLog(@"AI: high damage threat +%f points", target.damage*0.75 * enemyDamageModifier);
                }
                //this move cannot kill, is less good move
                else
                {
                    points += damageDealt*0.33;
                    NSLog(@"AI: damageDealt (half) +%f points", damageDealt*0.33);
                    
                    //target with a high damage but can't even kill it, less desirable
                    points += target.damage*0.33 * enemyDamageModifier;
                    NSLog(@"AI: high damage threat +%f points", target.damage*0.33 * enemyDamageModifier);
                }
                
                //if not dying from this move, damage received is worth less
                if (damageReceived < monster.life)
                {
                    points -= damageReceived*0.33;
                    NSLog(@"AI: damageReceived (half) -%f points", damageReceived*0.5);
                    
                    if (damageReceived > 0)
                    {
                        points -= monster.damage*0.1; //try to avoid losing health of a high damage minion
                        NSLog(@"AI: avoid losing high damage -%f points", monster.damage*0.25);
                    }
                }
                else
                {
                    points -= damageReceived;
                    NSLog(@"AI: damageReceived -%d points", damageReceived);
                    
                    points += overDamageReceived*0.5; //receiving over damage is good
                    NSLog(@"AI: received overDamage +%f points", overDamageReceived*0.5);
                    
                    points -= monster.damage*0.33; //losing a monster with high damage is bad
                    NSLog(@"AI: losing monster with high damage -%f points", monster.damage*0.33);
                }
                
                //hitting a monster and leaving it with <1000 life is terrible idea TODO not as bad once there's kill if below health ability
                int lifeLeft = target.life - damageDealt;
                if (lifeLeft < 1000 && lifeLeft > 0)
                {
                    points -= (1000 - lifeLeft)/1000 * 5000;
                    NSLog(@"AI: leaving monster with too low life -%f points", (1000 - lifeLeft)/1000 * 5000);
                }
                
                //targets that cannot attack any time soon are not very threatening
                if (target.cooldown > 1)
                {
                    points -= pow((target.cooldown), 1.5) * 1000;
                    NSLog(@"AI: enemy has high cooldown -%f points", pow((target.cooldown), 1.5) * 1000);
                }
            }
            
            NSLog(@"AI: Evaluated move: %d points.", points);
        }
        //summon monster
        else
        {
            //TODO
            points = card.cost * 1000;
        }
    }
    else if ([card isKindOfClass:[SpellCardModel class]])
    {
        SpellCardModel *spell = (SpellCardModel*)card;
        
        //TODO
        points = card.cost * 1000;
    }
    
    return points;
}

@end
