//
//  AIPlayer.m
//  cardgame
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "AIPlayer.h"
#import "AIPlayer+Utility.h"

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
    
    CardModel *bestCard;
    MonsterCardModel *bestTarget;
    int bestPoints = USELESS_MOVE;
    
    for (CardModel* card in hand)
    {
        //if it's possible to summon this card, decide what to do with it
        if ([self.gameModel canSummonCard:card side:OPPONENT_SIDE])
        {
            //if is a monster card, summon as long as there's space
            if ([card isKindOfClass:[MonsterCardModel class]])
            {
                MonsterCardModel*monster = (MonsterCardModel*)card;
                int points = [self evaluateMonsterValue:(MonsterCardModel*)card]/2; //50% effective
                
                int allAbilityPoints = USELESS_MOVE;
                
                allAbilityPoints = [self getCastOnSummonValue:card];
                
                //add up all points from cast on summon
                /*
                for(Ability*ability in card.abilities)
                {
                    if (ability.castType == castOnSummon)
                    {
                        Ability*copyAbility = [[Ability alloc] initWithAbility:ability];
                        copyAbility.castType = castAlways;
                        
                        NSArray*targets = [self getAbilityTargets:copyAbility attacker:monster target:nil fromSide:OPPONENT_SIDE];
                        
                        NSArray*copyTargets = [self copyMonsterArray:targets];
                        
                        int abilityPoints = [self evaluateAbilitiesPoints:copyAbility caster:monster targets:copyTargets fromSide:OPPONENT_SIDE withCost:card.cost];
                        
                        if (abilityPoints == IMPOSSIBLE_MOVE)
                            allAbilityPoints = IMPOSSIBLE_MOVE;
                        else if (abilityPoints == VICTORY_MOVE)
                            allAbilityPoints = VICTORY_MOVE;
                        else if (abilityPoints == USELESS_MOVE)
                        {
                            //do nothing, it won't contribute to the points
                        }
                        //regular move
                        else
                        {
                            //should expect good card to deal good damage, so doesn't waste them on bad moves
                            //if so far all useless moves, this move is no longer useless
                            if (allAbilityPoints == USELESS_MOVE)
                                allAbilityPoints = abilityPoints;
                            //as long as not a victory move, add the points to previous
                            else if (points != VICTORY_MOVE && points != IMPOSSIBLE_MOVE)
                                allAbilityPoints += abilityPoints;
                        }
                    }
                }
                */
                //add the ability points if it's a regular move
                if (allAbilityPoints == VICTORY_MOVE || allAbilityPoints == IMPOSSIBLE_MOVE)
                    points = allAbilityPoints;
                else if (allAbilityPoints != USELESS_MOVE)
                {
                    points += allAbilityPoints;
                    points -= [self getCardBaseCost:card];
                }
                
                if (points > bestPoints)
                {
                    bestCard = card;
                    bestPoints = points;
                    bestTarget = self.currentTarget; //assume it's placed here
                }
                
                NSLog(@"points for summoning %d %d minion: %d", monster.damage, monster.life, points);
                //[self pickAbilityTarget:card]; //searches for castOnSummon ability and picks a target
                //[self.gameViewController summonCard:card fromSide:OPPONENT_SIDE];
                //return NO; //finished one move cycle
            }
            
            //if is spell card, summon it if there's at least one monster on the field, or if hand is full, and there is no monster card left to summon
            else if ([card isKindOfClass:[SpellCardModel class]])
            {
                //check if the card has valid target first
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
                {
                    NSLog(@"AI: Card has no valid target");
                    return YES;
                }
                
                int points = USELESS_MOVE;
                
                points = [self getCastOnSummonValue:card];
                
                //should expect good card to deal good damage, so doesn't waste them on bad moves
                points -= [self getCardBaseCost:card];
                
                NSLog(@"AI: total points from spell card with cost %d: %d points", card.cost, points);
                
                if (points > bestPoints)
                {
                    bestPoints = points;
                    bestCard = card;
                    bestTarget = self.currentTarget; //assume it's placed here
                }
            }
        }
    }
    
    //TODO bestPoints > number needs a lot of adjusting, basically don't waste cards on bad moves
    //TODO threshhold for bestPoints should also change depending on number of cars in hand, if too full, needs to cast cards to free up space, or if made no moves this turn, will lower
    if (bestCard != nil)
    {
        //TODO the threshold may end up with the AI doing stupid stuff such as attacking itself
        int moveThreshold = 0; //minimum move value to cast
        
        if ([bestCard isKindOfClass:[MonsterCardModel class]])
        {
            //if no minion on field
            if (field.count == 0)
            {
                //willing to summon a very bad card if enemy has minions
                if (enemyField.count > 0)
                    moveThreshold -= 250 + (250 * (enemyField.count - field.count));
                //otherwise only willing to summon slightly poor cards
                else
                    moveThreshold -= 250;
            }
            //willing to summon if enemy has more minions TODO maybe compare strength instead
            else if (field.count < enemyField.count)
                moveThreshold -= 250 * (enemyField.count - field.count);
        }
        
        //get rid of cards if full
        if (hand.count >= MAX_HAND_SIZE)
            moveThreshold -= 2000;
        
        NSLog(@"AI: move threshold: %d", moveThreshold);
        
        if (bestPoints > moveThreshold)
        {
            //sets the current target to the correct object since algorithm will pick a copy of the original card
            self.currentTarget = bestTarget;
            
            if(self.currentTarget!=nil)
            {
                NSLog(@"AI: current target is not nil, pointing back to original card.");
                while(self.currentTarget.originalCard!=nil)
                    self.currentTarget = self.currentTarget.originalCard;
            }
            
            if (self.currentTarget == nil)
            {
                NSLog(@"AI: current target is nil. May be using ability without target.");
            }
            else
            {
                NSLog(@"AI: targetting minion %d %d", self.currentTarget.damage, self.currentTarget.life);
            }
            
            [self.gameViewController summonCard:bestCard fromSide:OPPONENT_SIDE];
            
            return NO;
        }
    }
    
    
    if (bestPoints <= 0)
    {
        if (bestPoints == IMPOSSIBLE_MOVE)
            NSLog(@"AI: No valid move");
        else if (bestPoints == USELESS_MOVE)
            NSLog(@"AI: Only useless moves");
        else
            NSLog(@"AI: Best move not good enough: %d", bestPoints);
    }
    
    if (bestCard == nil)
        NSLog(@"AI: No best card");
    
    return YES; //no moves left
    
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
        NSLog(@"AI: WARNING: targets is nil in evaluateMovePoints.");
        return IMPOSSIBLE_MOVE;
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
                    double damageModifier = (((float)(enemyPlayer.playerMonster.maximumLife - enemyPlayer.playerMonster.life) / enemyPlayer.playerMonster.maximumLife))*2 + 0.25;
                    
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
                    NSLog(@"AI: leaving monster with too low life -%f points", (1000 - lifeLeft)/1000.f * 5000);
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

/**
 Returns the current value (also sort of like threat level) of a minion. This value changes greatly depending on the current situation. For example a minion with a current cooldown of 5 is almost worthless (unless it has some special abilities), a minion with 5000 damage and 0 cd with the opponent's hero at 5000 health is incredibly dangerous
 */
-(int)evaluateMonsterValue: (MonsterCardModel*)monster
{
    int points = 0;
    
    //life of the minion is a function where having too high health is meaningless (abilities will kill it one hit or mute it anyways)
    points += [self evaluateMonsterLifeValue:monster];
    //NSLog(@"AI after life %d", points);
    
    points += [self evaluateMonsterDamageValue:monster];
    
    //NSLog(@"AI after damage %d, enemyHero: %d", points, enemyHero.life);
    
    //targets that cannot attack any time soon are not very threatening
    if (monster.cooldown > 1)
    {
        points -= pow((monster.cooldown), 1.5) * 1000;
    }
    
    //NSLog(@"AI: monster with attack:%d life:%d has a value of %d", monster.damage, monster.life, points);
    
    //TODO important to skip stat-modifying abilities that are casted on the monster itself (e.g. add damage, add max life, etc.)
    
    //check all cast on move and hit abilities, their points also contribute
    for(Ability*ability in monster.abilities)
    {
        if (ability.castType != castOnSummon)
        {
            //skip stat modifying abilities that are already casted
            if (ability.castType == castAlways)
                if (ability.abilityType == abilityAddMaxCooldown || ability.abilityType == abilityLoseMaxCooldown || ability.abilityType == abilityAddMaxLife || ability.abilityType == abilityAddDamage || ability.abilityType == abilityLoseDamage)
                    continue;
            
            Ability*copyAbility = [[Ability alloc] initWithAbility:ability];
            
            int abilityPoint = [self evaluateAbilityPoints:copyAbility caster:nil target:monster fromSide:monster.side withCost:0];
            
            if (abilityPoint == VICTORY_MOVE)
                abilityPoint = VICTORY_MOVE;
            else if (abilityPoint == IMPOSSIBLE_MOVE)
                return IMPOSSIBLE_MOVE;
            else if (abilityPoint == USELESS_MOVE)
            {
                
            }
            else
            {
                if (points != VICTORY_MOVE)
                    if (ability.castType == castOnHit || ability.castType == castOnMove)
                        abilityPoint = abilityPoint / (monster.cooldown>0?monster.cooldown:1);
            }
                
            points += abilityPoint / 2; //half as effective
        }
    }
    
    return points;
}

-(int)evaluateMonsterLifeValue:(MonsterCardModel*)monster
{
    return pow((monster.life/1000.f), 21.f/44) * 3.5 * 1000 / 2; //at ~11k life the function is at x=y
    ;
}

-(int)evaluateMonsterDamageValue:(MonsterCardModel *)monster
{
    int side = monster.side;
    int oppositeSide = side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;

    MonsterCardModel*friendlyHero = [self.gameModel.players[side] playerMonster];
    MonsterCardModel*enemyHero = [self.gameModel.players[oppositeSide] playerMonster];
    
    //damage points is linear because having high damage can result in one shotting the enemy hero, but capping at 25k (hero's life)
    int damagePoints = monster.damage > HERO_MAX_LIFE ? HERO_MAX_LIFE : monster.damage;
    damagePoints /= 2; //damage and life are half as effective as points (i.e. 1000/1000 monster ~= 1000 points)
    
    //enemy hero having low life makes this more attractive
    double damageModifier = (((float)(HERO_MAX_LIFE - enemyHero.life) / HERO_MAX_LIFE))*5 + 1;
    
    return damagePoints * damageModifier;
}

/*
 ALGORITHM: (so I can remember)
 
 //-----Value of an ability cast-----//
 Simple abilities (add damage, draw cards) can be evaluated directly.
 Complicated abilities (kill, deal damage, return to hand) evaluated by recursively checking the value of the card
 Multiple targets are evaluated separately and added together
 
 //-----Value of a minion-----//
 If recursion depth == 3, value is only its basic stats (attack, cd, life)
 Else value is basic stat plus the value of its stats, which is evaluated by casting the abilities
 
 */

/**
 Calculates the "points" value of casting an array of abilities at an array of MonsterCardModel targets from the side "side".
  Call this main function for most purposes, and not the other ones.
 All abilities that are being casted needs to be converted to castAlways, and all abilities that are not valid for casting needs to be converted to castNil. The exception is when a minion is being casted, when all abilities are valid (note that castOnSummon still needs to be converted to castAlways).
 For example:
 When minion is casted, convert castOnSummon to castAlways, leave rest be.
 When minion is attacking, convert castOnHit to castAlways, turn rest to castNil.
 When minion is dying, convert castOnDeath to castAlways, turn rest to castNil.
 When enemy minion is taking damage, convert castOnDamaged to castAlways, turn rest to castNil.
 
 Ensure that targets sent in are copies of the original minions, as they will be modified in the function

 LIMITATIONS:
 - Cannot evaluate result of castOnDeath from a castOnDeath ability due to infinite loops (since there's no state for AI's calculations)
 */
-(int)evaluateAbilitiesPoints: (Ability*)ability caster:(MonsterCardModel*)caster targets:(NSArray*)targets  fromSide:(int)side  withCost:(int)cost
{
    int points = USELESS_MOVE;
    
    int i = 0;
    
    for (MonsterCardModel* target in targets)
    {
        NSLog(@"AI: targets loop %d: Minion %d %d", i++, target.damage, target.life);
        //deep copy the target to perform ability effects
        //MonsterCardModel*copyTarget = (MonsterCardModel*)[[CardModel alloc] initWithCardModel:target];
        
        enum TargetType targetType = ability.targetType;
        int targetPoint = [self evaluateAbilityPoints:ability caster:caster target:target fromSide:side  withCost:cost];
        
        if (targetType == targetHeroAny || targetType == targetOneAny ||targetType == targetOneAnyMinion ||targetType == targetOneEnemy ||targetType == targetOneEnemyMinion||targetType == targetOneFriendly ||targetType == targetOneFriendlyMinion)
        {
            //only one is casted, choose best one (and currentTarget)
            if (targetPoint > points)
            {
                points = targetPoint;
                self.currentTarget = target; //TODO for these all end up getting casted to the monster for AI state, should only be casted on the chosen one
            }
        }
        //all being casted, add them together
        else
        {
            NSLog(@"not a selected type");
            //if impossible move, don't bother trying anything else. It's impossible (or game will be lost)
            if (targetPoint == IMPOSSIBLE_MOVE)
                return IMPOSSIBLE_MOVE;
            //this move will win. as long as there are no IMPOSSIBLE_MOVE from other abilities, cast it immediately
            else if (targetPoint == VICTORY_MOVE)
                points = VICTORY_MOVE;
            //useless move, don't contribute to points, but if all are useless, don't cast it
            else if (targetPoint == USELESS_MOVE)
            {
                //do nothing, it won't contribute to the points
            }
            //regular move
            else
            {
                //if so far all useless moves, this move is no longer useless
                if (points == USELESS_MOVE)
                    points = targetPoint;
                //as long as not a victory move, add the points to previous
                else if (points != VICTORY_MOVE)
                    points += targetPoint;
            }
        }
    }

    //if is a random target ability
    if (ability.targetType == targetOneRandomAny || ability.targetType == targetOneRandomEnemy || ability.targetType == targetOneRandomEnemyMinion || ability.targetType == targetOneRandomFriendly || ability.targetType == targetOneRandomFriendlyMinion || ability.targetType == targetOneRandomMinion)
    {
        //and is not one of the special moves, the actual values is all minions divided by the total number, since only one can be targetted
        if (points != IMPOSSIBLE_MOVE && points != VICTORY_MOVE && points != USELESS_MOVE)
            points /= [targets count];
    }
    
    return points;
}

/**
 Calculates the "points" value of casting an array of abilities at a single MonsterCardModel target from the side "side".
 In most cases should not call this, but call the parent function instead
 */
/*
-(int)evaluateAbilitiesPoints: (NSArray*)abilities target:(MonsterCardModel*)target targetSide:(int)side
{
    int points = USELESS_MOVE;
    
    for (MonsterCardModel* target in abilities)
    {
        int targetPoint = [self evaluateAbilitiesPoints:abilities target:target targetSide:side];
        
        //if impossible move, don't bother trying anything else. It's impossible (or game will be lost)
        if (targetPoint == IMPOSSIBLE_MOVE)
            return IMPOSSIBLE_MOVE;
        //this move will win. as long as there are no IMPOSSIBLE_MOVE from other abilities, cast it immediately
        else if (targetPoint == VICTORY_MOVE)
            points = VICTORY_MOVE;
        //useless move, don't contribute to points, but if all are useless, don't cast it
        else if (targetPoint == USELESS_MOVE)
        {
            //do nothing, it won't contribute to the points
        }
        //regular move
        else
        {
            //if so far all useless moves, this move is no longer useless
            if (points == USELESS_MOVE)
                points = targetPoint;
            //as long as not a victory move, add the points to previous
            else if (points != VICTORY_MOVE)
                points += points;
        }
    }
    
    return points;
}
*/

/** 
 Calculates the "points" value of casting a single ability at a single MonsterCardModel target from the side "side".
 In most cases should not call this, but call the parent function instead
 This function will actually cast the effect on the target when applicable.
 Note that abilities being casted will have the castType of castAlways, so all other casts are (probably?) summoning a minion with the ability. E.g. abilityAddLife with castOnDamaged must be summoning or giving a minion this ability, as when it's casted while onDamaged isn't evaluated.
 NOTE: if an ability has castNil, it means it is not a valid cast at the moment. This is for example used on castOnSummon when it has already been summoned, or castOnEndOfTurn when a minion is attacking.
 */
-(int)evaluateAbilityPoints: (Ability*)ability caster:(MonsterCardModel*)caster target:(MonsterCardModel*)target fromSide:(int)side withCost:(int)cost
{
    int points = 0;
    int oppositeside = side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
    
    //for convenience
    enum CastType castType = ability.castType;
    enum DurationType durationType = ability.durationType;
    enum TargetType targetType = ability.targetType;
    
    //minion is already summoned, this ability becomes useless
    if (ability.castType == castNil || ability.expired)
        return USELESS_MOVE;
    
    if (ability.abilityType == abilityAddLife)
    {
        int lifeDifference = target.maximumLife - target.life;
        
        //base points from amount of health healed
        points = [ability.value intValue] > lifeDifference ? [ability.value intValue] : [ability.value intValue];
        points *= -1; //"good" abilities are negative
        
        if (points == 0 || target.dead)
            return USELESS_MOVE;
    
        //all repeated casts have similar algorithms
        if (castType == castOnDamaged || castType == castOnHit || castType == castOnMove || castType == castOnEndOfTurn || castType == castOnDeath)
        {
            //healing is exponentially good if monster has enough life
            if (castType != castOnDeath)
            {
                if (target.maximumLife > 2000)
                {
                    points -= pow(target.maximumLife - 1000, 1.1);
                }
                else
                {
                    points *= 2; //otherwise just twice as good
                }
            }
            
            if (castType == castOnDamaged)
            {
                if (durationType != durationUntilEndOfTurn)
                    points *= 1.5; //cast on damaged is extra good
            }
            else if (castType == castOnMove || castType == castOnHit)
            {
                points /= target.maximumCooldown; //terrible if has high cooldown
                
                if (durationType == durationUntilEndOfTurn)
                {
                    points /= 2; //more maulus
                    if (target.cooldown > 0) //no effect if monster can't even cast it
                        return USELESS_MOVE;
                }
            }
            
            //cheap method: multiplied by what and how many it targets
            points = [self getTargetTypeMultipliedPoints:ability.targetType points:points];
        }
        else
        {
            if (points == 0)
                return USELESS_MOVE;
            
            int targetPoints = -[self evaluateMonsterValue:target];
            
            //any other cast types
            points += targetPoints * 0.2; //stronger target = better move
            
            if (target.side == side)
                points = -points;
            
            if (castType == castAlways)
            {
                //heal the copy so other abilities can evaluate the updated "state"
                [target healLife:[ability.value intValue]];
            }
            
            //TODO healing low life hero is critical
        }
        
        NSLog(@"AI: ability heal, %d points", points);
    }
    else if (ability.abilityType == abilityAddMaxLife)
    {
        int lifeChange = [ability.value intValue];
        
        if (castType == castOnDamaged || castType == castOnHit || castType == castOnMove || castType == castOnEndOfTurn || castType == castOnDeath)
        {
            points = lifeChange * 1.2; //slightly better than healing
            
            //repeated damage is exponentially good if monster has enough life
            if (castType != castOnDeath)
            {
                if (target.maximumLife > 2000)
                {
                    points += pow(target.maximumLife - 1000, 1.1);
                }
                else
                {
                    points *= 1.5;
                }
            }
            
            if (castType == castOnDamaged)
            {
                if (durationType != durationUntilEndOfTurn)
                    points *= 1.5; //cast on damaged is extra good
            }
            else if (castType == castOnMove || castType == castOnHit)
            {
                points /= target.maximumCooldown; //terrible if has high cooldown
                
                if (durationType == durationUntilEndOfTurn)
                {
                    points /= 2; //more maulus
                    if (target.cooldown > 0) //no effect if monster can't even cast it
                        return USELESS_MOVE;
                }
            }
            
            //multiplied by what and how many it targets
            points = [self getTargetTypeMultipliedPoints:ability.targetType points:points];
        }
        else
        {
            if (lifeChange == 0)
                return USELESS_MOVE;
            
            int originalLifeValue = [self evaluateMonsterLifeValue:target];
            NSLog(@"target life: %d", target.life);
            target.maximumLife += lifeChange;
            target.life += lifeChange;
            NSLog(@"target life: %d", target.life);
            int newLifeValue = [self evaluateMonsterLifeValue:target];
            
            NSLog(@"AI: original value: %d, new value: %d", originalLifeValue, newLifeValue);
            
            points = newLifeValue - originalLifeValue;
            points *= 1.5; //small bonus
            if (target.side == oppositeside) //healing enemy is bad
                points = -points;
        }
    }
    else if (ability.abilityType == abilityLoseLife)
    {
        //base points from amount of damage dealt
        points = [ability.value intValue] > target.life ? target.life : [ability.value intValue];
        
        NSLog(@"AI: base points from damage %d", points);
        
        //dealt no damage, useless
        if (points == 0 || target.dead)
            return USELESS_MOVE;
        
        //all repeated casts have similar algorithms
        if (castType == castOnDamaged || castType == castOnHit || castType == castOnMove || castType == castOnEndOfTurn || castType == castOnDeath)
        {
            //repeated damage is exponentially good if monster has enough life
            if (castType != castOnDeath)
            {
                if (target.maximumLife > 2000)
                {
                    points += pow(target.maximumLife - 1000, 1.1);
                }
                else
                {
                    points *= 2; //otherwise just twice as good
                }
            }
            
            if (castType == castOnDamaged)
            {
                if (durationType != durationUntilEndOfTurn)
                    points *= 1.5; //cast on damaged is extra good
            }
            else if (castType == castOnMove || castType == castOnHit)
            {
                points /= target.maximumCooldown; //terrible if has high cooldown
                
                if (durationType == durationUntilEndOfTurn)
                {
                    points /= 2; //more maulus
                    if (target.cooldown > 0) //no effect if monster can't even cast it
                        return USELESS_MOVE;
                }
            }
            
            //multiplied by what and how many it targets
            points = [self getTargetTypeMultipliedPoints:ability.targetType points:points];
        }
        else
        {
            int targetPoints = [self evaluateMonsterValue:target];
            if (target.side == side) //friendly minions are "negative" points
                targetPoints = -targetPoints;
            
            //dealing damage actually isn't that good at all, instead killing is what makes it a good move
            points = points/2;
            
            points += targetPoints * 0.05; //stronger target = better move
            
            NSLog(@"AI: bonus from strong target: %f", targetPoints * 0.05);
            
            if (target.side == side) //dealing damage to own minion makes it negative
                points = -points;
            else if (target.side == PLAYER_SIDE)
            {
                //overdealing damage to enemy is bad
                int overDamage = [ability.value intValue] - target.life;
                
                if (overDamage > 0)
                {
                    points -= overDamage/4;
                    NSLog(@"AI: over damage: %d", -overDamage/4);
                }
            }
            
            if (castType == castAlways)
            {
                [target loseLife:[ability.value intValue]];
            }
            
            if (target.dead)
            {
                points += targetPoints/3; //killing a stronger target = much better move
                NSLog(@"AI: bonus from killing strong target: %d", targetPoints/3);
                
                if (target.type == cardTypePlayer)
                {
                    if (target.side == side)
                        return IMPOSSIBLE_MOVE;
                    else
                        return VICTORY_MOVE;
                }
            }
        }
        
        //NOTE monster death is checked at the end of all ability casts
        NSLog(@"AI: ability damage, %d final points", points);
    }
    else if (ability.abilityType == abilityKill)
    {
        if (target.dead)
            return USELESS_MOVE;
        
        if (castType == castOnDamaged || castType == castOnHit || castType == castOnMove || castType == castOnEndOfTurn || castType == castOnDeath)
        {
            //lazy
            points = 3500;
            
            //repeated cast is exponentially good if monster has enough life
            if (castType != castOnDeath)
            {
                if (target.maximumLife > 2000)
                {
                    points += pow(target.maximumLife - 1000, 1.1);
                }
                else
                {
                    points *= 2; //otherwise just twice as good
                }
            }
            
            if (castType == castOnDamaged)
            {
                if (durationType != durationUntilEndOfTurn)
                    points *= 1.5; //cast on damaged is extra good
            }
            else if (castType == castOnMove || castType == castOnHit)
            {
                points /= target.maximumCooldown; //terrible if has high cooldown
                
                if (durationType == durationUntilEndOfTurn)
                {
                    points /= 2; //more maulus
                    if (target.cooldown > 0) //no effect if monster can't even cast it
                        return USELESS_MOVE;
                }
            }
            
            //multiplied by what and how many it targets
            points = [self getTargetTypeMultipliedPoints:ability.targetType points:points];
        }
        else
        {
            Ability*copyAbility = [[Ability alloc] initWithAbility:ability];
            //if directly casting, simply return same as damage
            copyAbility.abilityType = abilityLoseLife;
            copyAbility.value = [[NSNumber alloc] initWithInt: target.life];
            return [self evaluateAbilityPoints:copyAbility caster:caster target:target fromSide:side  withCost:cost];
        }
        
        NSLog(@"AI: ability kill, %d final points", points);
    }
    else if (ability.abilityType == abilityAddCooldown || ability.abilityType == abilityLoseCooldown)
    {
        int cooldownChange = [ability.value intValue];
        
        if (ability.abilityType == abilityLoseCooldown)
            cooldownChange = -cooldownChange;
        
        if (castType == castOnDamaged || castType == castOnHit || castType == castOnMove || castType == castOnEndOfTurn || castType == castOnDeath)
        {
            points = cooldownChange * 1000; //TODO lazy
            
            //repeated cast is exponentially good if monster has enough life
            if (castType != castOnDeath)
            {
                if (target.maximumLife > 2000)
                {
                    points += pow(target.maximumLife - 1000, 1.1);
                }
                else
                {
                    points *= 2; //otherwise just twice as good
                }
            }
            
            if (castType == castOnDamaged)
            {
                if (durationType != durationUntilEndOfTurn)
                    points *= 1.5; //cast on damaged is extra good
            }
            else if (castType == castOnMove || castType == castOnHit)
            {
                points /= target.maximumCooldown; //terrible if has high cooldown
                
                if (durationType == durationUntilEndOfTurn)
                {
                    points /= 2; //more maulus
                    if (target.cooldown > 0) //no effect if monster can't even cast it
                        return USELESS_MOVE;
                }
            }
            
            //multiplied by what and how many it targets
            points = [self getTargetTypeMultipliedPoints:ability.targetType points:points];
        }
        else
        {
            //cannot reduce cooldown below 0
            if (cooldownChange < 0 && abs(cooldownChange) > target.cooldown)
                cooldownChange = -target.cooldown;
            
            if (cooldownChange == 0)
                return USELESS_MOVE;
            
            points = [self getMonsterPerTurnValue:target];
            
            if (points == USELESS_MOVE)
                points = 0;
            else if (points == VICTORY_MOVE)
                return VICTORY_MOVE;
            else if (points == IMPOSSIBLE_MOVE)
                return IMPOSSIBLE_MOVE;
            
            points *= 1 + (target.life / 8000.f);
            
            NSLog(@"AI: points for per turn value: %d", points);
            points *= cooldownChange; //negative since adding cd is bad
            NSLog(@"AI: points cooldown change %d", cooldownChange);
            if (target.side == side)
                points = -points;
            NSLog(@"AI: points after side: %d", points);
            if (castType == castAlways)
                target.cooldown += cooldownChange;
        }
        
         NSLog(@"AI: ability cooldown add/lose, %d final points", points);
    }
    else if (ability.abilityType == abilitySetCooldown)
    {
        if (castType == castOnDamaged || castType == castOnHit || castType == castOnMove || castType == castOnEndOfTurn || castType == castOnDeath)
        {
            //TODO being lazy right now since few setCooldown are these casts, this assumes setCooldown is 0
            points = [self getTargetTypeMultipliedPoints:targetType points:2000];
        }
        else
        {
            //same as lose/add cooldown
            Ability*copyAbility = [[Ability alloc] initWithAbility:ability];
            
            if (target.cooldown > [ability.value intValue])
            {
                copyAbility.abilityType = abilityLoseCooldown;
                copyAbility.value = [[NSNumber alloc] initWithInt: target.cooldown - [ability.value intValue]];
            }
            else
            {
                copyAbility.abilityType = abilityAddCooldown;
                copyAbility.value = [[NSNumber alloc] initWithInt: [ability.value intValue] - target.cooldown];
            }
            
            return [self evaluateAbilityPoints:copyAbility caster:caster target:target fromSide:side withCost:cost];
        }
    }
    else if (ability.abilityType == abilityAddMaxCooldown || ability.abilityType == abilityLoseMaxCooldown)
    {
        //very similar to add/lose cooldown, except HP of target also plays into a factor
        int cooldownChange = [ability.value intValue];
        
        if (ability.abilityType == abilityLoseCooldown)
            cooldownChange = -cooldownChange;
        
        if (castType == castOnDamaged || castType == castOnHit || castType == castOnMove || castType == castOnEndOfTurn || castType == castOnDeath)
        {
            points = cooldownChange * 2000;
            
            //repeated damage is exponentially good if monster has enough life
            if (castType != castOnDeath)
            {
                if (target.maximumLife > 2000)
                {
                    points += pow(target.maximumLife - 1000, 1.1);
                }
                else
                {
                    points *= 1.5;
                }
            }
            
            if (castType == castOnDamaged)
            {
                if (durationType != durationUntilEndOfTurn)
                    points *= 1.5; //cast on damaged is extra good
            }
            else if (castType == castOnMove || castType == castOnHit)
            {
                points /= target.maximumCooldown; //terrible if has high cooldown
                
                if (durationType == durationUntilEndOfTurn)
                {
                    points /= 2; //more maulus
                    if (target.cooldown > 0) //no effect if monster can't even cast it
                        return USELESS_MOVE;
                }
            }
            
            //multiplied by what and how many it targets
            points = [self getTargetTypeMultipliedPoints:ability.targetType points:points];
        }
        else
        {
            //cannot reduce cooldown below 0
            if (cooldownChange < 0 && abs(cooldownChange) > target.maximumCooldown)
                cooldownChange = -target.maximumCooldown;
            
            if (cooldownChange == 0)
                return USELESS_MOVE;
            
            points = [self getMonsterPerTurnValue:target];
            
            if (points == USELESS_MOVE)
                points = 0;
            else if (points == VICTORY_MOVE)
                return VICTORY_MOVE;
            else if (points == IMPOSSIBLE_MOVE)
                return IMPOSSIBLE_MOVE;
            
            points *= 1 + (target.life / 8000.f);
            points *= cooldownChange; //negative since adding cd is bad
            
            if (target.side == side)
                points = -points;
            if (castType == castAlways)
                target.maximumCooldown += cooldownChange;
        }
        
        NSLog(@"AI: ability cooldown add/lose, %d final points", points);
    }
    //all these use the monsterValue to determine the ability value
    else if (ability.abilityType == abilityAddDamage || ability.abilityType == abilityLoseDamage)
    {
        int damageChange = [ability.value intValue];
        
        if (ability.abilityType == abilityLoseDamage)
            damageChange = -damageChange;
        
        if (castType == castOnDamaged || castType == castOnHit || castType == castOnMove || castType == castOnEndOfTurn || castType == castOnDeath)
        {
            points = damageChange;
            
            //repeated damage is exponentially good if monster has enough life
            if (castType != castOnDeath)
            {
                if (target.maximumLife > 2000)
                {
                    points += pow(target.maximumLife - 1000, 1.1);
                }
                else
                {
                    points *= 1.5;
                }
            }
            
            if (castType == castOnDamaged)
            {
                if (durationType != durationUntilEndOfTurn)
                    points *= 1.5; //cast on damaged is extra good
            }
            else if (castType == castOnMove || castType == castOnHit)
            {
                points /= target.maximumCooldown; //terrible if has high cooldown
                
                if (durationType == durationUntilEndOfTurn)
                {
                    points /= 2; //more maulus
                    if (target.cooldown > 0) //no effect if monster can't even cast it
                        return USELESS_MOVE;
                }
            }
            
            //multiplied by what and how many it targets
            points = [self getTargetTypeMultipliedPoints:ability.targetType points:points];
            
            if (target.side == side)
                points = -points;
        }
        else
        {
            //cannot reduce cooldown below 0
            if (damageChange < 0 && abs(damageChange) > target.damage)
                damageChange = -target.damage;
            
            if (damageChange == 0)
                return USELESS_MOVE;
            
            int originalDamageValue = [self evaluateMonsterDamageValue:target];
            
            target.damage += damageChange;
            
            int newDamageValue = [self evaluateMonsterDamageValue:target];
            
            points = originalDamageValue - newDamageValue;
            points *= 1.5; //small bonus
            if (target.side == side)
                points = -points;
        }
        
        NSLog(@"AI: ability add/lose damage, %d final points", points);
    }
    else if (ability.abilityType == abilityTaunt)
    {
        //TODO
        if (castType == castOnDamaged || castType == castOnHit || castType == castOnMove || castType == castOnEndOfTurn || castType == castOnDeath)
        {
            //cheap
            points = [self getTargetTypeMultipliedPoints:ability.targetType points:500];
        }
        else
        {
            points += target.life * 0.15;
            points += target.damage * 0.15;
            
            PlayerModel*targetPlayer = self.gameModel.players[target.side];
            
            //player having low health makes taunt much much better
            if (targetPlayer.playerMonster.life < 10000)
                points += (10000 - targetPlayer.playerMonster.life) * 0.25;
            
            //having other minions on field is even better
            if ([self.gameModel.battlefield[target.side] count] > 0)
            {
                points += target.life * 0.15;
                points += target.damage * 0.15;
            }
        }
        
        if (target.side == side)
            points = -points;
    }
    else if (ability.abilityType == abilityDrawCard)
    {
        if (castType == castOnDamaged || castType == castOnHit || castType == castOnMove || castType == castOnEndOfTurn || castType == castOnDeath)
        {
            //cheap
            points = [self getTargetTypeMultipliedPoints:ability.targetType points:[ability.value integerValue] * 2500];
        }
        else
        {
            int cardChange = [ability.value intValue];
            NSArray*targetHand;
            
            if (targetType == targetHeroFriendly || targetType == targetAll)
            {
                targetHand = self.gameModel.hands[target.side];
                int remainingSpace = MAX_HAND_SIZE - [targetHand count];
                if (cardChange > remainingSpace)
                    cardChange = remainingSpace;
                
                if (cardChange == 0)
                    points = USELESS_MOVE;
                else if (target.side == side)
                    points += cardChange * 2500;
                else
                    points += cardChange * -2500;
            }
            
            if (targetType == targetHeroEnemy || targetType == targetAll)
            {
                targetHand = self.gameModel.hands[target.side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE];
                int remainingSpace = MAX_HAND_SIZE - [targetHand count];
                if (cardChange > remainingSpace)
                    cardChange = remainingSpace;
                
                if (cardChange == 0)
                {
                    if (cardChange == 0)
                        points = USELESS_MOVE;
                }
                else
                {
                    if (points == USELESS_MOVE)
                        points = 0;
                    
                    if (target.side != side)
                        points += cardChange * 2500;
                    else
                        points += cardChange * -2500;
                }
            }
        }
    }
    else if (ability.abilityType == abilityAddResource)
    {
        if (castType == castOnDamaged || castType == castOnHit || castType == castOnMove || castType == castOnEndOfTurn || castType == castOnDeath)
        {
            //cheap
            points = [self getTargetTypeMultipliedPoints:ability.targetType points:[ability.value integerValue] * 1000];
        }
        else
        {
            int resourceChange = [ability.value intValue];
            
            if (targetType == targetHeroFriendly || targetType == targetAll)
            {
                NSArray*targetHand = self.gameModel.hands[target.side];
                
                int summonableCards = 0;
                
                int remainingSpace = MAX_RESOURCE - resourceChange;
                if (resourceChange > remainingSpace)
                    resourceChange = remainingSpace;
                
                for (CardModel*card in targetHand)
                {
                    if ([self.gameModel canSummonCard:card side:target.side withAdditionalResource:resourceChange-cost])
                        summonableCards++;
                }
                
                if (summonableCards < 2) //asumming the card casted here is summonable
                    points = USELESS_MOVE;
                else if (target.side == side)
                    points += resourceChange * 1000;
                else
                    points += resourceChange * -1000;
            }
            
            if (targetType == targetHeroEnemy || targetType == targetAll)
            {
                NSArray*targetHand = self.gameModel.hands[target.side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE];
                int remainingSpace = MAX_RESOURCE - resourceChange;
                if (resourceChange > remainingSpace)
                    resourceChange = remainingSpace;
                
                int summonableCards = 0;
                
                for (CardModel*card in targetHand)
                {
                    if ([self.gameModel canSummonCard:card side:target.side withAdditionalResource:resourceChange-cost])
                        summonableCards++;
                }
                
                if (summonableCards < 2)
                {
                    if (points == 0)
                        points = USELESS_MOVE;
                }
                else
                {
                    if (points == USELESS_MOVE)
                        points = 0;
                    
                    if (target.side != side)
                        points += resourceChange * 1000;
                    else
                        points += resourceChange * -1000;
                }
            }
        }
    }
    else if (ability.abilityType == abilityAssassin)
    {
        if (castType == castOnDamaged || castType == castOnHit || castType == castOnMove || castType == castOnEndOfTurn || castType == castOnDeath)
        {
            //cheap
            points = [self getTargetTypeMultipliedPoints:ability.targetType points:3000];
        }
        else
        {
            points = [self getMonsterPerTurnValue:target]; //TODO not exactly correct since on move is not that relevant
        }
    }
    else if (ability.abilityType == abilityPierce)
    {
        if (castType == castOnDamaged || castType == castOnHit || castType == castOnMove || castType == castOnEndOfTurn || castType == castOnDeath)
        {
            //cheap
            points = [self getTargetTypeMultipliedPoints:ability.targetType points:2000];
        }
        else
            points = target.damage / target.maximumCooldown / 2;
    }
    else if (ability.abilityType == abilityFracture)
    {
        if (castType == castOnDamaged || castType == castOnHit || castType == castOnMove || castType == castOnEndOfTurn || castType == castOnDeath)
        {
            //cheap
            points = [self getTargetTypeMultipliedPoints:ability.targetType points:3000];
        }
        else
        {
            points += target.damage / target.maximumCooldown / 2;
            points += target.life / 2;

            int fractureCount = [ability.value intValue];
            int fieldSpace = [self.gameModel.battlefield[target.side] count] - 1; //TODO assumes this is cast on death, but that's not exactly always the case (rare enough)
            
            if (fieldSpace < [ability.value intValue])
            {
                fractureCount = fieldSpace;
                
                if ([ability.value intValue]!=0)
                    points *= (float)fractureCount / [ability.value intValue];
            }
        }
    }
    else if (ability.abilityType == abilityRemoveAbility)
    {
        if (castType == castOnDamaged || castType == castOnHit || castType == castOnMove || castType == castOnEndOfTurn || castType == castOnDeath)
        {
            //cheap
            points = [self getTargetTypeMultipliedPoints:ability.targetType points:3000];
        }
        else
        {
            int originalDamageValue = [self evaluateMonsterDamageValue:target];
            
            target.abilities = [NSMutableArray array];
            
            int newDamageValue = [self evaluateMonsterDamageValue:target];
            
            points = originalDamageValue - newDamageValue;
            
            if (target.side == side)
                points *= -1;
        }
    }
    else if (ability.abilityType == abilityReturnToHand)
    {
        if (castType == castOnDamaged || castType == castOnHit || castType == castOnMove || castType == castOnEndOfTurn || castType == castOnDeath)
        {
            //WAY too complicated
            points = [self getTargetTypeMultipliedPoints:ability.targetType points:1000];
        }
        else
        {
            //value equals to cast on summon value minus cost and half of minion's value
            points = [self getCastOnSummonValue:target];
            
            points -= [self getCardBaseCost:target];
            points -= [self evaluateMonsterValue:target]/2;
            
            if (target.side == side)
                points *= -1;
        }
    }
    else
    {
        NSLog(@"AI: unimplemented ability, useless move");
        points = USELESS_MOVE;
    }
    
    //useless if until end of turn and minion has cooldown
    if (castType == castAlways && durationType == durationUntilEndOfTurn)
    {
        if (ability.abilityType != abilityAssassin && ability.abilityType != abilityPierce && ability.abilityType != abilityTaunt)
        
        //TODO this is under the assumption that all instant abilities with durationUntilEndOfTurn requires 0 cooldown to be useful. add exception
        if (target.cooldown != 0)
            points = USELESS_MOVE;
    }
    
    return points;
}

/** DO NOT call inside castOnMove or other per turn  */
-(int)getMonsterPerTurnValue:(MonsterCardModel*)monster
{
    int damagePerCD = monster.damage;
    if (monster.cooldown > 0)
        damagePerCD /= monster.cooldown;
    
    damagePerCD /= 2; //half as effective
    
    int targetPoint = damagePerCD;
    
    //check all cast on move and hit abilities, their points also contribute
    for(Ability*ability in monster.abilities)
    {
        //if the cast type is dependent on cooldown, get the value of having that ability
        if (ability.castType == castOnMove || ability.castType == castOnHit)
        {
            //skip other cooldown abilities to avoid infinite loops
            if (ability.abilityType == abilityAddCooldown || ability.abilityType == abilityLoseCooldown || ability.abilityType == abilitySetCooldown || ability.abilityType == abilityAddMaxCooldown || ability.abilityType == abilityLoseMaxCooldown)
                continue;
            
            int abilityPoint = [self evaluateAbilityPoints:ability caster:nil target:monster fromSide:monster.side withCost:0];
            
            if (abilityPoint == VICTORY_MOVE)
                targetPoint = VICTORY_MOVE;
            else if (abilityPoint == IMPOSSIBLE_MOVE)
                return IMPOSSIBLE_MOVE;
            else if (abilityPoint == USELESS_MOVE)
            {
                
            }
            else if (targetPoint != VICTORY_MOVE)
                targetPoint += abilityPoint / (monster.cooldown>0?monster.cooldown:1) / 2; //half as effective
        }
    }
    
    return targetPoint;
}
-(int)getCastOnSummonValue:(CardModel*)card
{
    int points = USELESS_MOVE;
    
    NSMutableArray*cardAbilitiesCopy = [NSMutableArray array];
    
    for (Ability *ability in card.abilities)
    {
        Ability*copyAbility = [[Ability alloc] initWithAbility:ability];
        copyAbility.castType = castAlways; //set this to always meaning it is casted right now
        [cardAbilitiesCopy addObject: copyAbility];
    }
    
    //go through all abilities and add up the points
    for (Ability *ability in cardAbilitiesCopy)
    {
        //here all onSummon becomes castAlways
        if (ability.castType == castOnSummon)
            ability.castType = castAlways;
        
        NSArray *targets = [self getAbilityTargets:ability attacker:nil target:nil fromSide:OPPONENT_SIDE];
        NSArray *targetsCopy = [self copyMonsterArray:targets];
        //TODO each array of ability should be sharing the target list
        
        NSLog(@"AI: number of targets: %d", targets.count);
        NSLog(@"AI: number of targetsCopy: %d", targetsCopy.count);
        int abilityPoints = [self evaluateAbilitiesPoints:ability caster:nil targets:targetsCopy fromSide:OPPONENT_SIDE withCost:card.cost];
        
        if (abilityPoints == IMPOSSIBLE_MOVE)
            points = IMPOSSIBLE_MOVE;
        else if (abilityPoints == VICTORY_MOVE)
            points = VICTORY_MOVE;
        else if (abilityPoints == USELESS_MOVE)
        {
            //do nothing, it won't contribute to the points
        }
        //regular move
        else
        {
            NSLog(@"AI: total points from ability %@, %d points", [[Ability getDescription:ability fromCard:card] string], abilityPoints);
            
            //if so far all useless moves, this move is no longer useless
            if (points == USELESS_MOVE)
                points = abilityPoints;
            //as long as not a victory move, add the points to previous
            else if (points != VICTORY_MOVE && points != IMPOSSIBLE_MOVE)
                points += abilityPoints;
        }
    }
    
    return points;
}

/*
-(int)getMostMonsterPerTurnValueFromSide:(int)side
{
    int points = 0;
 
    for (MonsterCardModel*monster in self.gameModel.battlefield[side])
        points += [self getMonsterPerTurnValue:monster];
 
    return points;
}
 */

@end
