//
//  GameModel.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "GameModel.h"
#import "GameViewController+Animation.h"
#import "UserModel.h"

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
        
        //draw 4 cards
        for (int i = 0; i < 4; i++)
        {
            [self.gameViewController performBlock:^{
                [self drawCard:side];
                [self.gameViewController updateHandsView:side];
            } afterDelay:0.5*(i+1)];
        }
    }
    
    [self.gameViewController performBlock:^{
        [self.gameViewController newGame];
    } afterDelay:0.5*(5)];
    
    //add a card to player hand for quick testing
    
    NSMutableArray* playerHand = self.hands[PLAYER_SIDE];
    NSMutableArray* aiHand = self.hands[OPPONENT_SIDE];
    
    /*
    SpellCardModel*spell;
    spell = [[SpellCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    spell.element = elementLightning;
    spell.name = @"Overpowered Card";
    spell.cost = 0;
    
    [spell.abilities addObject: [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneAny withDuration:durationForever withValue:[NSNumber numberWithInt:2000]]];
    
    [hand addObject:spell];
    */
    
    /*
    MonsterCardModel*monster;
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Nameless card";
    monster.life = monster.maximumLife = 2000;
    monster.damage = 7000;
    monster.cost = 0;
    monster.cooldown = monster.maximumCooldown = 0;
    
    [monster.abilities addObject: [[Ability alloc] initWithType:abilityFracture castType:castOnDeath targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:2]]];
    
    [playerHand addObject:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Nameless card";
    monster.life = monster.maximumLife = 2000;
    monster.damage = 1000;
    monster.cost = 0;
    monster.cooldown = monster.maximumCooldown = 1;
    
    //[monster.abilities addObject: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAll withDuration:durationForever withValue:[NSNumber numberWithInt:2000]]];
    
    [playerHand addObject:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.element = elementLightning;
    monster.name = @"Nameless card";
    monster.life = monster.maximumLife = 40000;
    monster.damage = 10000;
    monster.cost = 0;
    monster.cooldown = monster.maximumCooldown = 1;
    
    //[monster.abilities addObject: [[Ability alloc] initWithType:abilityLoseLife castType:castOnDeath targetType:targetAll withDuration:durationForever withValue:[NSNumber numberWithInt:2000]]];
    
    [hand addObject:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Nameless card";
    monster.life = monster.maximumLife = 4000;
    monster.damage = 1000;
    monster.cost = 0;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster.abilities addObject: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneAny withDuration:durationInstant withValue:[NSNumber numberWithInt:2000]]];
    
    [hand addObject:monster];
    */
}

-(void)newTurn:(int)side
{
    //add a resource and update it
    PlayerModel *player = self.players[side];
    player.maxResource++;
    player.resource = player.maxResource;
    
    //new turn effects to all cards (e.g. deduct cooldown)
    /*
    for (MonsterCardModel* monsterCard in self.battlefield[side])
    {
        [self cardNewTurn:monsterCard fromSide: side];
        [monsterCard.cardView updateView];
    }
     */
    
    NSArray* battlefield = self.battlefield[side];
    BOOL allCardsStarted = NO;
    
    //this ensures every single card has its turn started even if the array has been modified
    while (!allCardsStarted)
    {
        for (int i = 0; i < [battlefield count]; i++)
        {
            MonsterCardModel* monsterCard = battlefield[i];
            
            //turn has not started, start its turn
            if (monsterCard.turnEnded)
            {
                [self cardNewTurn:monsterCard fromSide: side];
                [monsterCard.cardView updateView];
                break; //restart the loop
            }
            //at the last card and already has turn ended, all done
            else if (i == [battlefield count]-1)
                allCardsStarted = YES;
        }
        
        //no monster left, end it
        if ([battlefield count] == 0)
            break;
    }
    
    //draws another card
    [self drawCard:side];
}

-(void) endTurn: (int) side
{
    NSArray* battlefield = self.battlefield[side];
    BOOL allCardsEnded = NO;
    
    //this ensures every single card has its turn ended even if the array has been modified
    while (!allCardsEnded)
    {
        for (int i = 0; i < [battlefield count]; i++)
        {
            MonsterCardModel* monsterCard = battlefield[i];
            
            //turn has not ended, end its turn
            if (!monsterCard.turnEnded)
            {
                [self cardEndTurn:monsterCard fromSide: side];
                [monsterCard.cardView updateView];
                break; //restart the loop
            }
            //at the last card and already has turn ended, all done
            else if (i == [battlefield count]-1)
                allCardsEnded = YES;
        }
        
        //no monster left, end it
        if ([battlefield count] == 0)
            break;
    }
    
    //end turn effects to all cards (e.g. deduct cooldown)
    /*
    for (int i = 0; i < [battlefield count]; i++)
    {
        MonsterCardModel* monsterCard = battlefield[i];
        [self cardEndTurn:monsterCard fromSide: side];
        [monsterCard.cardView updateView];
    }
    */
    
}

-(BOOL)drawCard:(int)side
{
    DeckModel *deck = self.decks[side];
    NSMutableArray *hand = self.hands[side];
    
    if ([deck count] > 0 && hand.count < MAX_HAND_SIZE)
    {
        CardModel *card = [deck removeCardAtIndex:0];
        
        if ([card isKindOfClass:[MonsterCardModel class]])
        {
            MonsterCardModel*monster = (MonsterCardModel*)card;
            monster.side = side;
        }
        

        
        [hand addObject: card];
    }
    
    
    //TODO deal damage to player maybe
    
    return NO;
}

/** TODO this is a temporary function used to fill decks up with random cards for testing */
-(void)fillDecks
{
    //self.decks = @[ [SinglePlayerCards getDeckOne], [SinglePlayerCards getDeckOne]];
    //[SinglePlayerCards uploadPlayerDeck];
    
    DeckModel *aiDeck = [SinglePlayerCards getDeckOne];
    
    if (aiDeck.count > 0)
    {
        [aiDeck shuffleDeck];

        while ([aiDeck count] > 20) //limit to 20 cards
            [aiDeck removeCardAtIndex:0];
     }
    
    DeckModel *playerDeck = [[DeckModel alloc] init];
    
    DeckModel *deckOne;
    
    //TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! should not actually be hard coded in GameModel. Instead GameViewController tells what deck to choose
    if (userCurrentDeck != nil)
        deckOne = userCurrentDeck;
    else
        deckOne = userAllDecks[0];
    
    for (CardModel*card in deckOne.cards)
        [playerDeck addCard:[[CardModel alloc] initWithCardModel:card]];
    
    if (playerDeck.count > 0)
        [playerDeck shuffleDeck];
    //while ([playerDeck count] > 20) //limit to 20 cards
    //    [playerDeck removeCardAtIndex:0];
    
    
    //TODO testing
    
    aiDeck = [[DeckModel alloc] init];
    
    /*
    SpellCardModel*spell;
    spell = [[SpellCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    spell.element = elementLightning;
    spell.name = @"Spell";
    spell.cost = 1;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:5000]]];
    
    [aiDeck addCard:spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    spell.element = elementLightning;
    spell.name = @"Spell";
    spell.cost = 1;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:5000]]];
    
    [aiDeck addCard:spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    spell.element = elementLightning;
    spell.name = @"Spell";
    spell.cost = 1;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseDamage castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:5000]]];
    
    [aiDeck addCard:spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    spell.element = elementLightning;
    spell.name = @"Spell";
    spell.cost = 1;
    
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddCooldown castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:2]]];
    
    [aiDeck addCard:spell];
    */
    
    
    MonsterCardModel*monster;
    /*
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Nameless card";
    monster.life = monster.maximumLife = 1000;
    monster.damage = 2000;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneAny withDuration:durationInstant withValue:[NSNumber numberWithInt:2000]]];
    
    [aiDeck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Nameless card";
    monster.life = monster.maximumLife = 1000;
    monster.damage = 2000;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneAny withDuration:durationInstant withValue:[NSNumber numberWithInt:2000]]];
    
    [aiDeck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Nameless card";
    monster.life = monster.maximumLife = 1000;
    monster.damage = 2000;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneAny withDuration:durationInstant withValue:[NSNumber numberWithInt:2000]]];
    
    [aiDeck addCard:monster];*/
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10025 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 7500;
    monster.damage = 1200;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:2500]]];
    
    [aiDeck addCard:monster];
    
    self.decks = @[playerDeck, aiDeck];
    
    
    
    //temporary function that grabs 20 cards from Parse database.
    /*
    PFQuery *query = [PFQuery queryWithClassName:@"Card"];
    query.limit = 20;
    NSArray* result = [query findObjects];
    for (PFObject *cardPF in result)
    {
        [playerDeck addCard:[CardModel createCardFromPFObject:cardPF]];
    }
    */
    
    //TODO no player database yet, so just use single player cards
    
    
    //NSLog(@"loaded %d cards for player.", [playerDeck count]);
    
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
    monsterCard.deployed = YES;
}

-(BOOL) canSummonCard: (CardModel*)card side:(char)side
{
    return [self canSummonCard:card side:side withAdditionalResource:0];
}

-(BOOL) canSummonCard: (CardModel*)card side:(char)side withAdditionalResource:(int)resource
{
    PlayerModel *player = (PlayerModel*) self.players[side];
    
    //checks if player can afford this first before caring about card type
    if (player.resource + resource >= card.cost)
    {
        if ([card isKindOfClass: [MonsterCardModel class]])
        {
            MonsterCardModel *monsterCard = (MonsterCardModel*) card;
            
            //has space for more cards
            NSArray *field = self.battlefield[side];
            if ([field count] < MAX_BATTLEFIELD_SIZE && !monsterCard.deployed)
                return YES;
        }
        else if ([card isKindOfClass: [SpellCardModel class]])
        {
            SpellCardModel *spellCard = (SpellCardModel*) card;
            
            //check if has valid target. If one ability has no valid target then card is invalid (e.g. targets enemy hero & all enemy minions but no enemy minions on field then invalid)
            for (Ability *ability in spellCard.abilities)
            {
                if (![self abilityHasValidTargets:ability castedBy:nil side:side])
                    return NO;
            }
            
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)abilityHasValidTargets: (Ability*)ability castedBy:(CardModel*)caster side:(int)side
{
    NSArray *friendlyField = self.battlefield[side];
    NSArray *enemyField = self.battlefield[side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE];
    
    enum TargetType targetType = ability.targetType;
    
    //if targets friendly minion but none on field, not allowed
    if (targetType == targetOneRandomFriendlyMinion ||
        targetType == targetAllFriendlyMinions ||
        targetType == targetOneFriendlyMinion)
    {
        for (MonsterCardModel*monster in friendlyField)
            if (monster != caster)
                return YES;
        
        return NO;
    }
    else if(targetType == targetOneRandomEnemyMinion ||
            targetType == targetAllEnemyMinions ||
            targetType == targetOneEnemyMinion)
    {
        if ([enemyField count] == 0)
            return NO;
    }
    else if (targetType == targetAllMinion ||
             targetType == targetOneRandomMinion ||
             targetType == targetOneAnyMinion)
    {
        if ([enemyField count] > 0)
            return YES;
        
        for (MonsterCardModel*monster in friendlyField)
            if (monster != caster)
                return YES;
        
        return NO;
    }
    
    //TODO additional goes here
    return YES;
}

-(void)summonCard: (CardModel*)card side:(char)side
{
    PlayerModel *player = (PlayerModel*) self.players[side];
    
    if ([card isKindOfClass: [MonsterCardModel class]])
    {
        MonsterCardModel *monsterCard = (MonsterCardModel*) card;
        
        [self addCardToBattlefield:monsterCard side:side];
        //update it first for better animations
        [self.gameViewController updateBattlefieldView: side];
        
        [self.gameViewController addAnimationCounter]; //the delayed cast counts as an animation
        
        //cast a little later for better visuals
        [self.gameViewController performBlock:^{
            //CastType castOnSummon is casted here
            for (int i = 0; i < [monsterCard.abilities count]; i++) //castAbility may insert objects in end
            {
                Ability*ability = monsterCard.abilities[i];
                if (ability.castType == castOnSummon)
                    [self castAbility:ability byMonsterCard:monsterCard toMonsterCard:nil fromSide:side];
            }
            [self.gameViewController decAnimationCounter];
            [self checkForGameOver];
        } afterDelay:0.4];
    }
    else if ([card isKindOfClass: [SpellCardModel class]])
    {
        //don't need to cast later since don't have deployment time
        for (int i = 0; i < [card.abilities count]; i++) //castAbility may insert objects in end
        {
            Ability*ability = card.abilities[i];
            if (ability.castType == castOnSummon)
                [self castAbility:ability byMonsterCard:nil toMonsterCard:nil fromSide:side];
        }
        [self checkForGameOver];
    }
    
    //remove card and use up cost
    [self.hands[side] removeObject:card];
    player.resource -= card.cost;
}

-(BOOL)addCardToHand: (CardModel*)card side:(char)side
{
    //has space for more cards
    NSArray *hand = self.hands[side];
    if ([hand count] < MAX_HAND_SIZE)
    {
        [self.hands[side] addObject:card];
        
        //if is MonsterCardModel, set deployed to YES
        //if ([card isKindOfClass: [MonsterCardModel class]])
        //    ((MonsterCardModel*)card).deployed = NO;
        
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
        for (int i = 0; i < [monsterCard.abilities count]; i++) //castAbility may insert objects in end
        {
            Ability*ability = monsterCard.abilities[i];
            if (ability.castType == castOnMove)
                [self castAbility:ability byMonsterCard:monsterCard toMonsterCard:nil fromSide:side];
        }
    }
    
    monsterCard.turnEnded = NO;
}

-(void)cardEndTurn: (MonsterCardModel*) monsterCard fromSide: (int)side
{
    //cast abilities that castOnEndOfTurn
    for (int i = 0; i < [monsterCard.abilities count]; i++) //castAbility may insert objects in end
    {
        Ability*ability = monsterCard.abilities[i];
        if (ability.castType == castOnEndOfTurn)
            [self castAbility:ability byMonsterCard:monsterCard toMonsterCard:nil fromSide:side];
    }
    
    //cast type must also be always since that means it's already casted
    for (Ability *ability in monsterCard.abilities)
        if (ability.durationType == durationUntilEndOfTurn && ability.castType == castAlways)
            ability.expired = YES;
    
    //check for dead
    if (monsterCard.dead)
        [self cardDies:monsterCard destroyedBy:nil fromSide:side];
    
    monsterCard.turnEnded = YES;
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
        int originalLifeTarget = target.life;
        [target loseLife: attackerDamage];
        int dealtDamageTarget = (originalLifeTarget - target.life);
        int overDamageTarget = attackerDamage - dealtDamageTarget; //used for pierce attack
        
        int originalLifeAttacker = attackerMonsterCard.life;
        int defenderDamage = [self calculateDamage:target fromSide:oppositeSide dealtTo:attackerMonsterCard];
        int overDamageAttacker = 0;
        int dealtDamageAttacker = 0;
        
        BOOL willReceiveAttack = YES;
        
        //if attacker has assassinate, it will not be hit in return
        for (Ability *ability in attacker.abilities)
            if (!ability.expired && ability.abilityType == abilityAssassin && ability.targetType == targetSelf)
            {
                willReceiveAttack = NO;
                break;
            }
        
        //defender hits back
        if (willReceiveAttack)
        {
            [attackerMonsterCard loseLife: defenderDamage];
            dealtDamageAttacker = (originalLifeAttacker - attackerMonsterCard.life);
            overDamageAttacker = defenderDamage - (originalLifeAttacker - attackerMonsterCard.life);
            
            //CastType castOnDamaged is casted here by defender
            for (int i = 0; i < [target.abilities count]; i++) //castAbility may insert objects in end
            {
                Ability*ability = target.abilities[i];
                if (ability.castType == castOnDamaged)
                    [self castAbility:ability byMonsterCard:target toMonsterCard:attackerMonsterCard fromSide:oppositeSide];
            }
        }
        else
            defenderDamage = 0; //will not receive damage
        
        //CastType castOnHit is casted here by attacker
        for (int i = 0; i < [attackerMonsterCard.abilities count]; i++) //castAbility may insert objects in end
        {
            Ability*ability = attackerMonsterCard.abilities[i];
            if (ability.castType == castOnHit)
                [self castAbility:ability byMonsterCard:attackerMonsterCard toMonsterCard:target fromSide:side];
        }
        
        //NOTE: castOnHit cannot be casted when defending and castOnDamaged cannot be casted when attack, otherwise defensive abilities can be used by attacking etc
        
        //just a safeguard in case a minion has cooldown of 0. This prevents infinite attacks
        if (attackerMonsterCard.maximumCooldown > 0)
            attackerMonsterCard.cooldown = attackerMonsterCard.maximumCooldown;
        else
            attackerMonsterCard.cooldown = 1;
        
        //target dies
        if (target.dead)
        {
            [self cardDies:target destroyedBy:attackerMonsterCard fromSide:oppositeSide];
            
            //search for pierce damage
            if (target.type != cardTypePlayer)
            {
                for (Ability *ability in attackerMonsterCard.abilities)
                {
                    if (ability.abilityType == abilityPierce && ability.targetType == targetSelf && !ability.expired)
                    {
                        if (overDamageTarget > 0)
                        {
                            int dealtDamage = 0;
                            
                            PlayerModel*targetPlayer = self.players[target.side];
                            
                            int originalLife = targetPlayer.playerMonster.life;
                            [targetPlayer.playerMonster loseLife:overDamageTarget];
                            
                            if (targetPlayer.playerMonster.life > 0)
                                dealtDamage = overDamageTarget;
                            else
                                dealtDamage = overDamageTarget - originalLife;
                            
                            [self.gameViewController performBlock:^{
                                [self.gameViewController animateCardDamage:targetPlayer.playerMonster.cardView forDamage:dealtDamage  fromSide:attackerMonsterCard.side];
                            } afterDelay:0.1];
                        }
                    }
                }
            }
        }
        
        //attacker dies
        if (attackerMonsterCard.dead)
        {
            [self cardDies:attackerMonsterCard destroyedBy:target fromSide:side];
            
            //search for pierce damage
            if (attackerMonsterCard.type != cardTypePlayer)
            {
                for (Ability *ability in target.abilities)
                {
                    if (ability.abilityType == abilityPierce && ability.targetType == targetSelf && !ability.expired)
                    {
                        if (overDamageAttacker > 0)
                        {
                            int dealtDamage = 0;
                            
                            PlayerModel*attackerPlayer = self.players[attackerMonsterCard.side];
                            
                            int originalLife = attackerPlayer.playerMonster.life;
                            [attackerPlayer.playerMonster loseLife:overDamageAttacker];
                            
                            if (attackerPlayer.playerMonster.life > 0)
                                dealtDamage = overDamageAttacker;
                            else
                                dealtDamage = overDamageAttacker - originalLife;
                            
                            [self.gameViewController performBlock:^{
                                [self.gameViewController animateCardDamage:attackerPlayer.playerMonster.cardView forDamage:dealtDamage  fromSide:target.side];
                            } afterDelay:0.1];
                        }
                    }
                }
            }
        }
        
        return @[[NSNumber numberWithInt:dealtDamageTarget],[NSNumber numberWithInt:dealtDamageAttacker]];
    }
    
    [self checkForGameOver];
    
    return 0;
}

-(BOOL)canAttack: (MonsterCardModel*) attacker fromSide: (int) side
{
    //these are mainly for AI due to synchronization with animation
    if (attacker.dead || !attacker.deployed)
        return NO;
    
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
    //cannot accidentally attack undeployed or dead cards
    if (!target.deployed || target.dead)
        return NO;
    
    if (attacker != nil && [attacker isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel *attackerMonsterCard = (MonsterCardModel*)attacker;
        
        //if target is a taunt unit, then it can be attacked regardless if there are other taunt units
        BOOL targetHasTaunt = NO;
        
        for (Ability *ability in target.abilities)
        {
            if (!ability.expired && ability.abilityType == abilityTaunt && ability.targetType == targetSelf)
            {
                targetHasTaunt = YES;
                break;
            }
        }
        
        //search all minion in target's field. If a minion has the ability taunt and is targetting itself, it cannot be attacked
        if (!targetHasTaunt)
        {
            NSArray *targetField = self.battlefield[target.side];
            
            for (MonsterCardModel *monster in targetField)
            {
                if (monster != target)
                {
                    for (Ability *ability in monster.abilities)
                        if (!ability.expired && ability.abilityType == abilityTaunt && ability.targetType == targetSelf)
                            return NO;
                }
            }
        }
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
        for (int i = 0; i < [monsterCard.abilities count]; i++) //castAbility may insert objects in end
        {
            Ability*ability = monsterCard.abilities[i];
            if (ability.castType == castOnDeath)
            {
                [self.gameViewController addAnimationCounter]; //counts as animation
                //casting after a slight delay makes chain reactions less chaotic
                [self.gameViewController performBlock:^{
                    [self castAbility:ability byMonsterCard:monsterCard toMonsterCard:attackerMonster fromSide:side];
                    [self.gameViewController decAnimationCounter];
                } afterDelay:0.4]; //TODO will need visual indicator later
            }
        }
        
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
    if (ability.expired) //cannot be cast if already expired
        return;
    
    //first find array of targets to apply effects on
    NSArray *targets;
    
    int oppositeSide = side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
    
    //all of the target types. Put the target into the array targets for applying abilities later
    if (ability.targetType == targetSelf)
        targets = @[attacker];
    else if (ability.targetType == targetVictim)
        targets = @[target];
    else if (ability.targetType == targetVictimMinion)
    {
        if (target.type == cardTypePlayer) //do not cast ability if target is not a minion
            return;
        else
            targets = @[target];
    }
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
                
                [self.gameViewController pickAbilityTarget:ability castedBy:attacker];
                
                //does not actually cast it immediately since it requires the player to pick a target
                return;
            }
            else
            {
                //AI must have already picked a target
                MonsterCardModel* aiTarget = self.aiPlayer.currentTarget;
                if (aiTarget != nil && [self validAttack:nil target:aiTarget])
                    targets = @[aiTarget];
                else
                {
                    if (aiTarget != nil)
                        NSLog(@"WARNING: AI tried to attack an invalid target!");
                    return;
                }
            }
        }
    }
    else if (ability.targetType == targetOneAnyMinion)
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
                
                for (MonsterCardModel *monster in self.battlefield[OPPONENT_SIDE])
                    monster.cardView.cardHighlightType = cardHighlightTarget;
                
                [self.gameViewController pickAbilityTarget:ability castedBy:attacker];
                
                //does not actually cast it immediately since it requires the player to pick a target
                return;
            }
            else
            {
                //AI must have already picked a target
                MonsterCardModel* aiTarget = self.aiPlayer.currentTarget;
                if (aiTarget != nil && [self validAttack:nil target:aiTarget])
                    targets = @[aiTarget];
                else
                {
                    if (aiTarget != nil)
                        NSLog(@"WARNING: AI tried to attack an invalid target!");
                    return;
                }
            }
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
                
                [self.gameViewController pickAbilityTarget:ability castedBy:attacker];
                
                //does not actually cast it immediately since it requires the player to pick a target
                return;
            }
            else
            {
                //AI must have already picked a target
                MonsterCardModel* aiTarget = self.aiPlayer.currentTarget;
                if (aiTarget != nil && [self validAttack:nil target:aiTarget])
                    targets = @[aiTarget];
                else
                {
                    if (aiTarget != nil)
                        NSLog(@"WARNING: AI tried to attack an invalid target!");
                    return;
                }
            }
        }
    }
    else if (ability.targetType == targetOneFriendlyMinion)
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
                
                [self.gameViewController pickAbilityTarget:ability castedBy:attacker];
                
                //does not actually cast it immediately since it requires the player to pick a target
                return;
            }
            else
            {
                //AI must have already picked a target
                MonsterCardModel* aiTarget = self.aiPlayer.currentTarget;
                if (aiTarget != nil && [self validAttack:nil target:aiTarget])
                    targets = @[aiTarget];
                else
                {
                    if (aiTarget != nil)
                        NSLog(@"WARNING: AI tried to attack an invalid target!");
                    return;
                }
            }
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
                
                [self.gameViewController pickAbilityTarget:ability castedBy:attacker];
                
                //does not actually cast it immediately since it requires the player to pick a target
                return;
            }
            else
            {
                //AI must have already picked a target
                MonsterCardModel* aiTarget = self.aiPlayer.currentTarget;
                if (aiTarget != nil && [self validAttack:nil target:aiTarget])
                    targets = @[aiTarget];
                else
                {
                    if (aiTarget != nil)
                        NSLog(@"WARNING: AI tried to attack an invalid target!");
                    return;
                }
            }
        }
    }
    else if (ability.targetType == targetOneEnemyMinion)
    {
        if (target != nil)
            targets = @[target];
        else
        {
            if (side == PLAYER_SIDE)
            {
                for (MonsterCardModel *monster in self.battlefield[OPPONENT_SIDE])
                    monster.cardView.cardHighlightType = cardHighlightTarget;
                
                [self.gameViewController pickAbilityTarget:ability castedBy:attacker];
                
                //does not actually cast it immediately since it requires the player to pick a target
                return;
            }
            else
            {
                //AI must have already picked a target
                MonsterCardModel* aiTarget = self.aiPlayer.currentTarget;
                if (aiTarget != nil && [self validAttack:nil target:aiTarget])
                    targets = @[aiTarget];
                else
                {
                    if (aiTarget != nil)
                        NSLog(@"WARNING: AI tried to attack an invalid target!");
                    return;
                }
            }
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
        
        targets = @[allTargets[arc4random_uniform(allTargets.count)]];
    }
    else if (ability.targetType == targetOneRandomMinion)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        [allTargets addObjectsFromArray:self.battlefield[oppositeSide]];
        
        targets = @[allTargets[arc4random_uniform(allTargets.count)]];
    }
    else if (ability.targetType == targetOneRandomFriendly)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        [allTargets addObject:((PlayerModel*)self.players[side]).playerMonster];
        
        targets = @[allTargets[arc4random_uniform(allTargets.count)]];
    }
    else if (ability.targetType == targetOneRandomFriendlyMinion)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        
        targets = @[allTargets[arc4random_uniform(allTargets.count)]];
    }
    else if (ability.targetType == targetOneRandomEnemy)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[oppositeSide]];
        [allTargets addObject:((PlayerModel*)self.players[oppositeSide]).playerMonster];
        
        targets = @[allTargets[arc4random_uniform(allTargets.count)]];
    }
    else if (ability.targetType == targetOneRandomEnemyMinion)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[oppositeSide]];
        
        targets = @[allTargets[arc4random_uniform(allTargets.count)]];
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
                
                [self.gameViewController pickAbilityTarget:ability castedBy:attacker];
                //does not actually cast it immediately since it requires the player to pick a target
                return;
            }
            else
            {
                //AI must have already picked a target
                MonsterCardModel* aiTarget = self.aiPlayer.currentTarget;
                if (aiTarget != nil && [self validAttack:nil target:aiTarget])
                    targets = @[aiTarget];
                else
                {
                    if (aiTarget != nil)
                        NSLog(@"WARNING: AI tried to attack an invalid target!");
                    return;
                }
            }
           
        }
    }
    else if (ability.targetType == targetHeroFriendly)
    {
        PlayerModel *player = self.players[side];
        targets = @[player.playerMonster];
    }
    else if (ability.targetType == targetHeroEnemy)
    {
        PlayerModel *enemy = self.players[oppositeSide];
        targets = @[enemy.playerMonster];
    }
    
    //---SPECIAL CASE ABILITIES HERE---//
    
    //these abilities do not target any minion, so simply cast it
    if (ability.abilityType == abilityDrawCard || ability.abilityType == abilityAddResource)
    {
        [self castInstantAbility:ability onMonsterCard:nil fromSide:side];
        return;
    }
    
    //apply the effect to the targets NOTE: this loop is inefficient but saves a lot of lines
    for (MonsterCardModel* target in targets)
    {
        if (target.dead //skip dead monsters
            //except for the following abilities
            && ability.abilityType != abilityFracture //fracturing always targets a dead monster
            && ability.abilityType != abilityReturnToHand //can return a dead monster to hand
            )
            continue;
        
        Ability * appliedAbility;
        //all effects are first added to the abilities: add the ability to the object with castType as castAlways as they're already casted, and pass all other values on. Instant effects are applied right after
        appliedAbility = [[Ability alloc] initWithType:ability.abilityType castType:castAlways targetType:targetSelf withDuration:ability.durationType withValue:ability.value withOtherValues:ability.otherValues];
        
        //if the ability has an instant effect (e.g. deal some damage, draw some cards), cast the effect immediately
        BOOL castedInstantAbility = [self castInstantAbility:appliedAbility onMonsterCard:target fromSide:side];
        
        //is not an instant effect but rather a buff/debuff (e.g. add damage, heal every turn) then store it in the monster
        if (!castedInstantAbility)
        {
            //don't duplicate abilities such as taunt
            if ([self canAddAbility:target ability:appliedAbility])
            {
                [target.abilities addObject:appliedAbility];
                
                //Add special cases here:
                
                //also includes a one-time heal
                if (ability.abilityType == abilityAddMaxLife)
                    target.life += [ability.value intValue];
                //also includes a one-time add cooldown
                if (ability.abilityType == abilityAddMaxCooldown)
                    target.cooldown += [ability.value intValue];
                //also removes all existing abilities
                else if (ability.abilityType == abilityRemoveAbility)
                {
                    
                    //remove all abilities that are not the removeAbility itself
                    //delete this way to prevent concurrent mod
                    for (int i = 0; i < [target.abilities count];)
                    {
                        Ability*targetAbility = target.abilities[i];
                        
                        //skip all abilityRemoveAbility that targets itself
                        if (targetAbility.abilityType == abilityRemoveAbility && targetAbility.targetType == targetSelf)
                            i++;
                        else
                            [target.abilities removeObjectAtIndex:i];
                    }
                    
                    //[target.cardView updateView];
                }
                
                [target.cardView updateView];
            }
        }
    }
}


/** Since castAbility adds instant abilities as an ability, this method actually applies the ability so that it can be removed. Calling an ability that's not applicable returns NO. */
-(BOOL) castInstantAbility: (Ability*) ability onMonsterCard: (MonsterCardModel*) monster fromSide:(int)side
{
    int oppositeSide = side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
    
    if (ability.abilityType == abilityAddLife)
    {
        int originalLife = monster.life; //will only pop up the change in health
        [monster healLife:[ability.value intValue]];
        [self.gameViewController animateCardHeal:monster.cardView forLife:monster.life - originalLife];
    }
    else if (ability.abilityType == abilityLoseLife)
    {
        int originalLife = monster.life;
        [monster loseLife:[ability.value intValue]];
        [self.gameViewController animateCardDamage:monster.cardView forDamage:monster.life-originalLife fromSide:monster.side];
        
        //cast on damanged is casted here by monster
        //CastType castOnDamaged is casted here by defender
        for (int i = 0; i < [monster.abilities count]; i++) //castAbility may insert objects in end
        {
            Ability*ability = monster.abilities[i];
            if (ability.castType == castOnDamaged)
                [self castAbility:ability byMonsterCard:monster toMonsterCard:nil fromSide:oppositeSide];
        }
    }
    else if (ability.abilityType == abilityKill)
    {
        int lifeLost = monster.life;
        [monster loseLife:monster.life];
        [self.gameViewController animateCardDamage:monster.cardView forDamage:lifeLost fromSide:monster.side];
    }
    else if (ability.abilityType == abilitySetCooldown)
    {
        monster.cooldown = [ability.value intValue];
    }
    else if (ability.abilityType == abilityAddCooldown)
    {
        monster.cooldown += [ability.value intValue];
    }
    else if (ability.abilityType == abilityLoseCooldown)
    {
        monster.cooldown -= [ability.value intValue];
    }
    else if (ability.abilityType == abilityDrawCard)
    {
        //draws card for one or both sides
        //TODO not updating caster's view immediately since it's being updated later anyways
        if (ability.targetType == targetHeroFriendly)
        {
            for (int i = 0; i < [ability.value intValue]; i++)
            {
                [self.gameViewController addAnimationCounter];
                [self.gameViewController performBlock:^{
                    [self drawCard:side];
                    [self.gameViewController updateHandsView:side];
                    [self.gameViewController decAnimationCounter];
                } afterDelay:0.5*(i+1)];
            }
        }
        else if (ability.targetType == targetHeroEnemy)
        {
            for (int i = 0; i < [ability.value intValue]; i++)
            {
                [self.gameViewController addAnimationCounter];
                [self.gameViewController performBlock:^{
                    [self drawCard:oppositeSide];
                    [self.gameViewController updateHandsView:oppositeSide];
                    [self.gameViewController decAnimationCounter];
                } afterDelay:0.5*(i+1)];
            }
        }
        else if (ability.targetType == targetAll)
        {
            for (int i = 0; i < [ability.value intValue]; i++)
            {
                [self.gameViewController addAnimationCounter];
                [self.gameViewController performBlock:^{
                    [self drawCard:side];
                    [self drawCard:oppositeSide];
                    
                    [self.gameViewController updateHandsView:side];
                    [self.gameViewController updateHandsView:oppositeSide];
                    [self.gameViewController decAnimationCounter];
                } afterDelay:0.5*(i+1)];
            }
        }
    }
    else if (ability.abilityType == abilityAddResource)
    {
        PlayerModel* player = self.players[side];
        PlayerModel* opponent = self.players[oppositeSide];
        
        //one or both sides gain resources
        if (ability.targetType == targetHeroFriendly)
        {
            player.resource += [ability.value intValue];
        }
        else if (ability.targetType == targetHeroEnemy)
        {
            opponent.resource += [ability.value intValue];
        }
        else if (ability.targetType == targetAll)
        {
            player.resource += [ability.value intValue];
            opponent.resource += [ability.value intValue];
        }
        [self.gameViewController updateResourceView: side];
        [self.gameViewController updateResourceView: oppositeSide];
    }
    else if (ability.abilityType == abilityReturnToHand)
    {
        if (monster.type == cardTypePlayer) //very wrong
        {
            NSLog(@"WARNING: Tried to return a hero to its hand.");
            return YES;
        }
        
        int monsterSide = monster.side;
        
        [monster resetAllStats]; //reset all stats
        monster.deployed = NO;
        NSMutableArray*battlefield = self.battlefield[monsterSide];
        [battlefield removeObject:monster];
        
        NSMutableArray*hand = self.hands[monsterSide];
        [hand addObject:monster];
        [self.gameViewController.handsView addSubview:monster.cardView];
        
        [self.gameViewController updateBattlefieldView:monsterSide];
        [self.gameViewController updateHandsView:monsterSide];
        [monster.cardView updateView];
        //[monster.cardView updateView];
        
        return YES; //if it's returned to hand, it cannot die or have anything else happen to it
    }
    else if (ability.abilityType == abilityFracture)
    {
        int cost = monster.baseCost;
        int damage = monster.baseDamage;
        int life = monster.baseMaxLife;
        
        if ([ability.value intValue] == 1)
        {
            cost = ceil(cost*0.6);
            damage = ceil(damage*0.6/100)*100;
            life = ceil(life*0.6/100)*100;
        }
        else if ([ability.value intValue] == 2)
        {
            cost = ceil(cost*0.25);
            damage = ceil(damage*0.25/100)*100;
            life = ceil(life*0.25/100)*100;
        }
        else if ([ability.value intValue] == 3)
        {
            cost = ceil(cost*0.15);
            damage = ceil(damage*0.15/100)*100;
            life = ceil(life*0.15/100)*100;
        }
        for (int i = 0 ; i < [ability.value intValue]; i++)
        {
            MonsterCardModel*fracture = [[MonsterCardModel alloc] initWithCardModel:monster];
            fracture.dead = NO;
            fracture.turnEnded = NO;
            fracture.abilities = [NSMutableArray array]; //clear all abilities
            fracture.cost = cost;
            fracture.damage = damage;
            fracture.life = fracture.maximumLife = life;
            fracture.cooldown = fracture.maximumCooldown = monster.baseMaxCooldown;
            
            NSArray*monsterField = self.battlefield[monster.side];
            int currentMonsterCount = [monsterField count];
            if (monster.dead)
                currentMonsterCount--;
            
            if (currentMonsterCount < MAX_BATTLEFIELD_SIZE)
            {
                [self addCardToBattlefield:fracture side:monster.side];
                
                //CardView *fractureView = [[CardView alloc]initWithModel:fracture cardImage:monster.cardView.cardImage viewMode:monster.cardView.cardViewMode];
                //fractureView.center = monster.cardView.center;
            }
        }
        
        return YES;
    }
    else
    {
        return NO; //not an instant ability, nothing happened
    }
    //TODO when adding new instant effects, include them in the AIPlayer
    
    //update view and check for death
    [monster.cardView updateView];
    
    if (monster.dead)
    {
        [self cardDies:monster destroyedBy:nil fromSide:monster.side];
    }
    
    return YES;
}


/** Returns YES if monster already contains an ability that cannot be stacked (i.e. cannot have two taughts) */
-(BOOL)containsDuplicateAbility:(MonsterCardModel*)monster ability:(Ability*)ability
{
    for (Ability*monsterAbility in monster.abilities)
    {
        if (monsterAbility.abilityType == ability.abilityType)
        {
            if (ability.abilityType == abilityTaunt || ability.abilityType == abilityRemoveAbility)
            {
                //all settings are identical
                if (monsterAbility.targetType == ability.targetType && monsterAbility.durationType == ability.durationType && monsterAbility.castType == ability.castType)
                    return YES;
            }
        }
    }
    return NO;
}

/** Checks if it's possible to add this ability to the target. */
-(BOOL)canAddAbility:(MonsterCardModel*)target ability:(Ability*)ability
{
    //cannot add duplicate ability
    if ([self containsDuplicateAbility:target ability:ability])
        return NO;
    
    //cannot add if contains the abilityRemoveAbility ability.
    for (Ability *ability in target.abilities)
        if (ability.abilityType == abilityRemoveAbility && ability.targetType == targetSelf)
            return NO;
    
    return YES;
}

-(void) checkForGameOver
{
    //game already over, can't check
    if (self.gameOver)
        return;
    
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
