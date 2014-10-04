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
#import "Campaign.h"

@implementation GameModel

const int MAX_BATTLEFIELD_SIZE = 5;
const int MAX_HAND_SIZE = 7;
const char PLAYER_SIDE = 0, OPPONENT_SIDE = 1;

@synthesize gameViewController = _gameViewController;
@synthesize battlefield = _battlefield;
@synthesize graveyard = _graveyard;
@synthesize hands = _hands;
@synthesize players = _players;
@synthesize decks = _decks;
@synthesize gameOver = _gameOver;
@synthesize aiPlayer = _aiPlayer;

uint32_t xor128_x = 123456789;
uint32_t xor128_y = 362436069;
uint32_t xor128_z = 521288629;
uint32_t xor128_w = 88675123;

uint32_t oppo_xor128_x,oppo_xor128_y,oppo_xor128_z,oppo_xor128_w,player_xor128_x,player_xor128_y,player_xor128_z,player_xor128_w;

const int INITIAL_CARD_DRAW = 4;

//TEMPORARY
int cardIDCount = 0;

-(instancetype)initWithViewController:(GameViewController *)gameViewController gameMode: (enum GameMode)gameMode withLevel:(Level*)level
{
    self = [super init];
    
    if (self){
        self.gameMode = gameMode;
        self.gameViewController = gameViewController;
        _level = level;
        
        //initialize battlefield and hands to be two arrays
        self.battlefield = @[[NSMutableArray array],[NSMutableArray array]];
        self.graveyard = @[[NSMutableArray array],[NSMutableArray array]];
        self.hands = @[[NSMutableArray array],[NSMutableArray array]];
        self.decks = @[[[DeckModel alloc] init], [[DeckModel alloc] init ]];
        
        if (gameMode != GameModeMultiplayer)
            [self loadDecks];
        
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
        
        if (_gameMode == GameModeSingleplayer)
        {
            self.aiPlayer = [[AIPlayer alloc] initWithPlayerModel:opponent gameViewController:gameViewController gameModel: self];
            
            opponentHeroModel.life = opponentHeroModel.maximumLife = level.opponentHealth;
            opponentHeroModel.name = level.opponentName;
            
            if (_level.isBossFight)
            {
                self.aiPlayer.isBossFight = YES;
                
                MonsterCardModel*boss = [SinglePlayerCards getCampaignBossWithID:_level.levelID];
                
                if (boss)
                {
                    opponent.playerMonster = [[MonsterCardModel alloc] initWithCardModel:boss];
                    opponent.playerMonster.side = OPPONENT_SIDE;
                    [self addCardToBattlefield:opponent.playerMonster side:OPPONENT_SIDE];
                }
            }
            if (_level.isTutorial)
                self.aiPlayer.isTutorial = YES;
            //levelDifficultyOffset
        }
    }
    
    return self;
}

-(void)startGame
{
    //TODO load decks from database for multiplayer (not here though)
    
    int cardDraw = INITIAL_CARD_DRAW;
    
    //draw three cards per side
    for (int side = 0; side < 2; side++)
    {
        DeckModel *deck = self.decks[side];
        //shuffle deck
        
        if (side == OPPONENT_SIDE && _level != nil && !_level.opponentShuffleDeck)
        {
            //NO SHUFFLE
        }
        else if (side == PLAYER_SIDE && _level != nil && !_level.playerShuffleDeck)
        {
            //NO SHUFFLE
        }
        else if (_gameMode == GameModeMultiplayer)
        {
            if (side == PLAYER_SIDE)
            {
                xor128_x = player_xor128_x;
                xor128_y = player_xor128_y;
                xor128_z = player_xor128_z;
                xor128_w = player_xor128_w;
            }
            else if (side == OPPONENT_SIDE)
            {
                xor128_x = oppo_xor128_x;
                xor128_y = oppo_xor128_y;
                xor128_z = oppo_xor128_z;
                xor128_w = oppo_xor128_w;
            }
            
            [self multiplayerShuffleDeck:deck];
        }
        else
            [deck shuffleDeck];
        
        //fist tutorial draws only one card at start
        if ([TUTORIAL_ONE isEqualToString:_level.levelID])
            cardDraw = 1;
        
        //draw 4 cards
        for (int i = 0; i < cardDraw; i++)
        {
            [self.gameViewController performBlock:^{
                [self drawCard:side];
                [self.gameViewController updateHandsView:side];
            } afterDelay:0.5*(i+1)];
        }
    }
    
    [self.gameViewController performBlock:^{
        [self.gameViewController newGame];
    } afterDelay:0.5*(cardDraw+1)];
    
    //add a card to player hand for quick testing
    
    NSMutableArray* playerHand = self.hands[PLAYER_SIDE];
    NSMutableArray* aiHand = self.hands[OPPONENT_SIDE];
    
    //TODO testing
    /*
    MonsterCardModel*monster;
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10025 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 7500;
    monster.damage = 5000;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.side = PLAYER_SIDE;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityPierce castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [playerHand addObject:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10025 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 7500;
    monster.damage = 5000;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.side = PLAYER_SIDE;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnHit targetType:targetHeroEnemy withDuration:durationForever withValue:[NSNumber numberWithInt:5000]]];
    
    [playerHand addObject:monster];
    */
    
    SpellCardModel*spell;
    
    spell = [[SpellCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    spell.element = elementLightning;
    spell.name = @"Insta Win";
    spell.cost = 0;
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetHeroEnemy withDuration:durationInstant withValue:[NSNumber numberWithInt:400000]]];
    //[playerHand addObject:spell];
    
    /*
    MonsterCardModel*monster;
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Nameless card";
    monster.life = monster.maximumLife = 99999;
    monster.damage = 99999;
    monster.cost = 0;
    monster.cooldown = monster.maximumCooldown = 0;
    monster.side = PLAYER_SIDE;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityKill castType:castOnDeath targetType:targetAttacker withDuration:durationForever withValue:[NSNumber numberWithInt:2000]]];
    
    [playerHand addObject:monster];
    
    SpellCardModel*spell;
    
    spell = [[SpellCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    spell.element = elementLightning;
    spell.name = @"Overpowered Card";
    spell.cost = 1;
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationForever withValue:[NSNumber numberWithInt:400000]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:4000]]];
    [aiHand addObject:spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    spell.element = elementLightning;
    spell.name = @"Overpowered Card";
    spell.cost = 1;
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddMaxLife castType:castOnSummon targetType:targetHeroFriendly withDuration:durationForever withValue:[NSNumber numberWithInt:400000]]];
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:4000]]];
    [aiHand addObject:spell];
    

    
    spell = [[SpellCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    spell.element = elementLightning;
    spell.name = @"Overpowered Card";
    spell.cost = 0;
    [spell.abilities addObject: [[Ability alloc] initWithType:abilityRemoveAbility castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:5000]]];
    [playerHand addObject:spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    spell.element = elementLightning;
    spell.name = @"Overpowered Card";
    spell.cost = 0;
    [spell.abilities addObject: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneFriendlyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:5000]]];
    [playerHand addObject:spell];
    
    
    spell = [[SpellCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    spell.element = elementLightning;
    spell.name = @"Overpowered Card";
    spell.cost = 1;
    [spell.abilities addObject: [[Ability alloc] initWithType:abilityLoseLife castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:5000]]];
    
    [aiHand addObject:spell];
    
    spell = [[SpellCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    spell.element = elementLightning;
    spell.name = @"Overpowered Card";
    spell.cost = 1;
    [spell.abilities addObject: [[Ability alloc] initWithType:abilityKill castType:castOnSummon targetType:targetOneEnemyMinion withDuration:durationInstant withValue:[NSNumber numberWithInt:5000]]];
    [aiHand addObject:spell];
    
    
    MonsterCardModel*monster;

    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Nameless card";
    monster.life = monster.maximumLife = 2000;
    monster.damage = 1000;
    monster.cost = 0;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.side = PLAYER_SIDE;
    
    
    [playerHand addObject:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Nameless card";
    monster.life = monster.maximumLife = 2000;
    monster.damage = 1000;
    monster.cost = 0;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.side = PLAYER_SIDE;
    
    
    [playerHand addObject:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Nameless card";
    monster.life = monster.maximumLife = 2000;
    monster.damage = 1000;
    monster.cost = 0;
    monster.cooldown = monster.maximumCooldown = 1;
    monster.side = PLAYER_SIDE;

    
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
    
    //expire all abilities that only lasts until end of turn
    for (MonsterCardModel*monsterCard in self.battlefield[PLAYER_SIDE])
    {
        //cast type must also be always since that means it's already casted
        for (Ability *ability in monsterCard.abilities)
            if (ability.durationType == durationUntilEndOfTurn && ability.castType == castAlways)
                ability.expired = YES;
        
        [monsterCard.cardView updateView];
    }
    for (MonsterCardModel*monsterCard in self.battlefield[OPPONENT_SIDE])
    {
        //cast type must also be always since that means it's already casted
        for (Ability *ability in monsterCard.abilities)
            if (ability.durationType == durationUntilEndOfTurn && ability.castType == castAlways)
                ability.expired = YES;
        
        [monsterCard.cardView updateView];
    }
    
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
    
    _turnNumber++;
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
-(void)loadDecks
{
    //self.decks = @[ [SinglePlayerCards getDeckOne], [SinglePlayerCards getDeckOne]];
    //[SinglePlayerCards uploadPlayerDeck];
    
    DeckModel *opponentDeck;
    DeckModel *playerDeck;
    
    if (_gameMode == GameModeSingleplayer)
    {
        opponentDeck = [[DeckModel alloc]init];
        
        //dup the cards
        for (CardModel*card in _level.cards.cards)
            [opponentDeck addCard:[[CardModel alloc] initWithCardModel:card]];
        
        //get player's preconstructed campaign deck
        DeckModel*campaignPlayerDeck = [SinglePlayerCards getPlayerCampaignDeckWithID:_level.levelID];
        if (campaignPlayerDeck != nil)
        {
            playerDeck = [[DeckModel alloc] init];
            for (CardModel*card in campaignPlayerDeck.cards)
                [playerDeck addCard:[[CardModel alloc] initWithCardModel:card]];
            
            NSLog(@"player cards count %d",playerDeck.cards.count);
        }
        
        //this is for old stuff, cards are shuffled in start game now
        /*
        if (_level.opponentShuffleDeck)
        {
            if (aiDeck.count > 0)
            {
                [aiDeck shuffleDeck];
                
                while ([aiDeck count] > 20) //limit to 20 cards
                    [aiDeck removeCardAtIndex:0];
            }
        }
         */
    }
    else if (_gameMode == GameModeMultiplayer)
    {
        opponentDeck = _opponentDeck; //TODO
        NSLog(@"Opponent deck set");
        
    
        //note do not shuffle enemy deck since it's already shuffled on their client
    }
    else
    {
        //NOT SUPPOSE TO HAPPEN
        opponentDeck = [[DeckModel alloc] init];
    }
    
   
    if (playerDeck == nil)
    {
        playerDeck = [[DeckModel alloc] init];
        
        DeckModel *deckOne;
        
        //TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! should not actually be hard coded in GameModel. Instead GameViewController tells what deck to choose
        if (userCurrentDeck != nil)
        {
            deckOne = userCurrentDeck;
        }
        else
        {
            deckOne = userAllDecks[0];
            NSLog(@"ERROR: NO DECK FOUND");
        }
        
        for (CardModel*card in deckOne.cards)
            [playerDeck addCard:[[CardModel alloc] initWithCardModel:card]];
    }
    
    self.decks = @[playerDeck, opponentDeck];
    
    //while ([playerDeck count] > 20) //limit to 20 cards
    //    [playerDeck removeCardAtIndex:0];
    
    
    //TODO testing
    /*
    aiDeck = [[DeckModel alloc] init];
    
    
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
    
    /*
    MonsterCardModel*monster;
    
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
    
    [aiDeck addCard:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:10025 type:cardTypeSinglePlayer];
    monster.name = @"Monster";
    monster.life = monster.maximumLife = 7500;
    monster.damage = 1200;
    monster.cost = 5;
    monster.cooldown = monster.maximumCooldown = 1;
    
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnDamaged targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:2500]]];
    
    [aiDeck addCard:monster];
    */
    
    
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
            if ([self canAddAbility:monster ability:ability] && !monster.heroic)
                return YES;
        
        return NO;
    }
    else if(targetType == targetOneRandomEnemyMinion ||
            targetType == targetAllEnemyMinions ||
            targetType == targetOneEnemyMinion)
    {
        for (MonsterCardModel*monster in enemyField)
            if ([self canAddAbility:monster ability:ability] && !monster.heroic)
                return YES;
        
        return NO;
    }
    else if (targetType == targetAllMinion ||
             targetType == targetOneRandomMinion ||
             targetType == targetOneAnyMinion)
    {
        for (MonsterCardModel*monster in friendlyField)
            if ([self canAddAbility:monster ability:ability] && !monster.heroic)
                return YES;
        
        for (MonsterCardModel*monster in enemyField)
            if ([self canAddAbility:monster ability:ability] && !monster.heroic)
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
        //[self.gameViewController updateBattlefieldView: side];
        
        [self.gameViewController addAnimationCounter]; //the delayed cast counts as an animation
        
        //cast a little later for better visuals
        [self.gameViewController performBlock:^{
            //CastType castOnSummon is casted here
            for (int i = 0; i < [monsterCard.abilities count]; i++) //castAbility may insert objects in end
            {
                Ability*ability = monsterCard.abilities[i];
                if (ability.castType == castOnSummon)
                {
                    [card.cardView castedAbility:ability];
                    [self castAbility:ability byMonsterCard:monsterCard toMonsterCard:nil fromSide:side];
                }
            }
            [self.gameViewController decAnimationCounter];
        } afterDelay:0.4];
    }
    else if ([card isKindOfClass: [SpellCardModel class]])
    {
        //don't need to cast later since don't have deployment time
        for (int i = 0; i < [card.abilities count]; i++) //castAbility may insert objects in end
        {
            Ability*ability = card.abilities[i];
            if (ability.castType == castOnSummon)
            {
                [card.cardView castedAbility:ability];
                [self castAbility:ability byMonsterCard:nil toMonsterCard:nil fromSide:side];
            }
        }
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
            {
                [monsterCard.cardView castedAbility:ability];
                [self castAbility:ability byMonsterCard:monsterCard toMonsterCard:nil fromSide:side];
            }
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
        {
            [monsterCard.cardView castedAbility:ability];
            [self castAbility:ability byMonsterCard:monsterCard toMonsterCard:nil fromSide:side];
        }
    }
    
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
        }
        else
            defenderDamage = 0; //will not receive damage
        
        //CastType castOnDamaged is casted here by defender (even if !willReceiveAttack)
        for (int i = 0; i < [target.abilities count]; i++) //castAbility may insert objects in end
        {
            Ability*ability = target.abilities[i];
            if (ability.castType == castOnDamaged)
            {
                [target.cardView castedAbility:ability];
                
                if (willReceiveAttack)
                {
                    if (ability.castType == castOnDamaged)
                    {
                        [self castAbility:ability byMonsterCard:target toMonsterCard:attackerMonsterCard fromSide:oppositeSide];
                    }
                    
                }
                //assassin will dodge the targeting (but still get hit if for example it was deal damage to all)
                else
                {
                    //to fix the animation
                    [self castAbility:ability byMonsterCard:target toMonsterCard:attackerMonsterCard fromSide:oppositeSide];
                }
            }
        }
        
        //CastType castOnHit is casted here by attacker
        for (int i = 0; i < [attackerMonsterCard.abilities count]; i++) //castAbility may insert objects in end
        {
            Ability*ability = attackerMonsterCard.abilities[i];
            if (ability.castType == castOnHit)
            {
                [attackerMonsterCard.cardView castedAbility:ability];
                [self castAbility:ability byMonsterCard:attackerMonsterCard toMonsterCard:target fromSide:side];
            }
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
                            
                            [self checkForGameOver];
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
                            
                            [self checkForGameOver];
                        }
                    }
                }
            }
        }
        
        return @[[NSNumber numberWithInt:dealtDamageTarget],[NSNumber numberWithInt:dealtDamageAttacker]];
    }
    
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
    
    //if no attacker and attacker is monster card (spell can target freely)
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
    NSLog(@"monster died");
    if ([card isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel *monsterCard = (MonsterCardModel*)card;
        
        if (!monsterCard.deployed)
            return;
        monsterCard.deployed = NO;
        
        MonsterCardModel* attackerMonster = nil;
        if ([attacker isKindOfClass:[MonsterCardModel class]])
            attackerMonster = (MonsterCardModel*)attacker;
        
        NSLog(@"monster died 2");
        
        //CastType castOnDeath is casted here
        for (int i = 0; i < [monsterCard.abilities count]; i++) //castAbility may insert objects in end
        {
            NSLog(@"looping ondeath");
            Ability*ability = monsterCard.abilities[i];
            if (ability.castType == castOnDeath)
            {
                NSLog(@"casted ondeath");
                [monsterCard.cardView castedAbility:ability];
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
    
    [self checkForGameOver];
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
    {
        if (target.heroic)
            return;
        
        targets = @[target];
    }
    else if (ability.targetType == targetVictimMinion)
    {
        if (target.heroic) //do not cast ability if target is not a minion
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
                NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
                [allTargets removeObject:attacker]; //remove itself
                [allTargets addObjectsFromArray:self.battlefield[oppositeSide]];
                [allTargets addObject:((PlayerModel*)self.players[side]).playerMonster];
                [allTargets addObject:((PlayerModel*)self.players[oppositeSide]).playerMonster];
                
                for (MonsterCardModel *monster in allTargets)
                {
                    //cannot have dup ability or add ability to muted minions
                    if (![self canAddAbility:monster ability:ability])
                        continue;
                    else if (monster == attacker) //cannot target self
                        continue;
                    
                    monster.cardView.cardHighlightType = cardHighlightTarget;
                }
                
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
                NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
                [allTargets removeObject:attacker]; //remove itself
                [allTargets addObjectsFromArray:self.battlefield[oppositeSide]];
                
                for (MonsterCardModel *monster in allTargets)
                {
                    //cannot have dup ability or add ability to muted minions
                    if (![self canAddAbility:monster ability:ability])
                        continue;
                    else if (monster == attacker) //cannot target self
                        continue;
                    else if (monster.heroic)
                        continue;
                    
                    monster.cardView.cardHighlightType = cardHighlightTarget;
                }
                
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
                NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
                [allTargets removeObject:attacker]; //remove itself
                [allTargets addObject:((PlayerModel*)self.players[side]).playerMonster];
                
                for (MonsterCardModel *monster in allTargets)
                {
                    //cannot have dup ability or add ability to muted minions
                    if (![self canAddAbility:monster ability:ability])
                        continue;
                    else if (monster == attacker) //cannot target self
                        continue;
                    
                    //NSLog(@"name: %@", monster.name);
                    monster.cardView.cardHighlightType = cardHighlightTarget;
                }
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
                NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
                [allTargets removeObject:attacker]; //remove itself
                
                for (MonsterCardModel *monster in allTargets)
                {
                    //cannot have dup ability or add ability to muted minions
                    if (![self canAddAbility:monster ability:ability])
                        continue;
                    else if (monster == attacker) //cannot target self
                        continue;
                    else if (monster.heroic)
                        continue;
                    
                    monster.cardView.cardHighlightType = cardHighlightTarget;
                }
                
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
                NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[oppositeSide]];
                [allTargets addObject:((PlayerModel*)self.players[oppositeSide]).playerMonster];
                
                for (MonsterCardModel *monster in allTargets)
                {
                    //cannot have dup ability or add ability to muted minions
                    if (![self canAddAbility:monster ability:ability])
                        continue;
                    else if (monster == attacker) //cannot target self
                        continue;
                    
                    monster.cardView.cardHighlightType = cardHighlightTarget;
                }
                
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
                NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[oppositeSide]];
                
                for (MonsterCardModel *monster in allTargets)
                {
                    //cannot have dup ability or add ability to muted minions
                    if (![self canAddAbility:monster ability:ability])
                        continue;
                    else if (monster == attacker) //cannot target self
                        continue;
                    else if (monster.heroic)
                        continue;
                    
                    monster.cardView.cardHighlightType = cardHighlightTarget;
                }
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
        [allTargets removeObject:[self.players[OPPONENT_SIDE] playerMonster]]; //happens in boss fights
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
        [allTargets removeObject:[self.players[OPPONENT_SIDE] playerMonster]]; //happens in boss fights
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
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[oppositeSide]];
        [allTargets removeObject:[self.players[OPPONENT_SIDE] playerMonster]]; //happens in boss fights
        targets = [NSArray arrayWithArray:allTargets];
    }
    else if (ability.targetType == targetOneRandomAny)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        [allTargets addObjectsFromArray:self.battlefield[oppositeSide]];
        [allTargets addObject:((PlayerModel*)self.players[side]).playerMonster];
        [allTargets addObject:((PlayerModel*)self.players[oppositeSide]).playerMonster];
        
        if (allTargets.count == 0)
            return;
        
        targets = @[allTargets[(int)(drand48()*allTargets.count)]];
    }
    else if (ability.targetType == targetOneRandomMinion)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        [allTargets addObjectsFromArray:self.battlefield[oppositeSide]];
        [allTargets removeObject:[self.players[OPPONENT_SIDE] playerMonster]]; //happens in boss fights
        
        if (allTargets.count == 0)
            return;
        
        targets = @[allTargets[(int)(drand48()*allTargets.count)]];
    }
    else if (ability.targetType == targetOneRandomFriendly)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        [allTargets addObject:((PlayerModel*)self.players[side]).playerMonster];
        
        if (allTargets.count == 0)
            return;
        
        targets = @[allTargets[(int)(drand48()*allTargets.count)]];
    }
    else if (ability.targetType == targetOneRandomFriendlyMinion)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[side]];
        [allTargets removeObject:attacker]; //remove itself
        [allTargets removeObject:[self.players[OPPONENT_SIDE] playerMonster]]; //happens in boss fights
        if (allTargets.count == 0)
            return;
        
        targets = @[allTargets[(int)(drand48()*allTargets.count)]];
    }
    else if (ability.targetType == targetOneRandomEnemy)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[oppositeSide]];
        [allTargets addObject:((PlayerModel*)self.players[oppositeSide]).playerMonster];
        
        if (allTargets.count == 0)
            return;
        
        targets = @[allTargets[(int)(drand48()*allTargets.count)]];
    }
    else if (ability.targetType == targetOneRandomEnemyMinion)
    {
        NSMutableArray *allTargets = [NSMutableArray arrayWithArray:self.battlefield[oppositeSide]];
        [allTargets removeObject:[self.players[OPPONENT_SIDE] playerMonster]]; //happens in boss fights
        if (allTargets.count == 0)
            return;
        
        targets = @[allTargets[(int)(drand48()*allTargets.count)]];
    }
    else if (ability.targetType == targetHeroAny)
    {
        if (target != nil)
            targets = @[target];
        else
        {
            if (side == PLAYER_SIDE)
            {
                NSMutableArray *allTargets = [NSMutableArray array];
                [allTargets addObject:((PlayerModel*)self.players[side]).playerMonster];
                [allTargets addObject:((PlayerModel*)self.players[oppositeSide]).playerMonster];
                
                for (MonsterCardModel *monster in allTargets)
                {
                    //cannot have dup ability or add ability to muted minions
                    if (![self canAddAbility:monster ability:ability])
                        continue;
                    else if (monster == attacker) //cannot target self
                        continue;
                    
                    monster.cardView.cardHighlightType = cardHighlightTarget;
                }
                
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
        if (player.playerMonster == nil)
            return;
            
        targets = @[player.playerMonster];
    }
    else if (ability.targetType == targetHeroEnemy)
    {
        PlayerModel *enemy = self.players[oppositeSide];
        if (enemy.playerMonster == nil)
            return;
        
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
        appliedAbility.isBaseAbility = NO;
        
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
                //also includes a one-time add/lose cooldown
                if (ability.abilityType == abilityAddMaxCooldown)
                    target.cooldown += [ability.value intValue];
                if (ability.abilityType == abilityLoseMaxCooldown)
                    target.cooldown -= [ability.value intValue];
                //also removes all existing abilities
                else if (ability.abilityType == abilityRemoveAbility)
                {
                    if (target.heroic) //cannot silence hero
                        return;
                    
                    for (int i = 0; i < [target.abilities count]; i++)
                    {
                        Ability*targetAbility = target.abilities[i];
                        
                        //skip all abilityRemoveAbility that targets itself
                        if (!targetAbility.expired && targetAbility.abilityType == abilityRemoveAbility && targetAbility.targetType == targetSelf)
                        {
                            //skip
                        }
                        else
                            targetAbility.expired = YES;
                    }
                    
                    //reset life and cooldown to max if they're above
                    if (target.life > target.maximumLife)
                        target.life = target.maximumLife;
                    if (target.cooldown > target.maximumCooldown)
                        target.cooldown = target.maximumCooldown;
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
        int lostAmount = [ability.value intValue] < originalLife ? [ability.value intValue] : originalLife;
        [self.gameViewController animateCardDamage:monster.cardView forDamage:lostAmount fromSide:monster.side];
        
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
        if (monster.heroic) //immune to kill
            return YES;
        
        int lifeLost = monster.life;
        [monster loseLife:monster.life];
        [self.gameViewController animateCardDamage:monster.cardView forDamage:lifeLost fromSide:monster.side];
        
        //cast on damanged is casted here by monster
        //CastType castOnDamaged is casted here by defender
        for (int i = 0; i < [monster.abilities count]; i++) //castAbility may insert objects in end
        {
            Ability*ability = monster.abilities[i];
            if (ability.castType == castOnDamaged)
                [self castAbility:ability byMonsterCard:monster toMonsterCard:nil fromSide:oppositeSide];
        }
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
        
        if (monster.heroic) //cannot return heroic
            return YES;
        
        //TODO needs to reset any silenced abilty (instead of removing abilities with silence, set them to expired
        
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
        
        if (monster.side == OPPONENT_SIDE && monster.cardView.frontFacing)
            [monster.cardView flipCard]; //includes update view
        else
            [monster.cardView updateView];
        
        //[monster.cardView updateView];
        
        return YES; //if it's returned to hand, it cannot die or have anything else happen to it
    }
    else if (ability.abilityType == abilityFracture)
    {
        if (monster.heroic)
            return YES;
        
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
            cost = ceil(cost*0.35);
            damage = ceil(damage*0.35/100)*100;
            life = ceil(life*0.35/100)*100;
        }
        else if ([ability.value intValue] == 3)
        {
            cost = ceil(cost*0.3);
            damage = ceil(damage*0.3/100)*100;
            life = ceil(life*0.3/100)*100;
        }
        for (int i = 0 ; i < [ability.value intValue]; i++)
        {
            MonsterCardModel*fracture = [[MonsterCardModel alloc] initWithCardModel:monster];
            fracture.dead = NO;
            fracture.turnEnded = YES;
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
                [self addCardToBattlefield:fracture side:monster.side];
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
        if (monsterAbility.abilityType == ability.abilityType && !monsterAbility.expired)
        {
            //TODO add abilities that cannot have duplicates here
            if (ability.abilityType == abilityTaunt || ability.abilityType == abilityPierce || ability.abilityType == abilityAssassin || ability.abilityType == abilityRemoveAbility)
            {
                //all settings are identical
                if (monsterAbility.targetType == targetSelf && monsterAbility.durationType == ability.durationType && monsterAbility.castType == castAlways)
                    return YES;
            }
        }
    }
    return NO;
}

/** Checks if it's possible to add this ability to the target. */
-(BOOL)canAddAbility:(MonsterCardModel*)target ability:(Ability*)ability
{
    if (target.heroic)
    {
        if (ability.abilityType == abilityTaunt || ability.abilityType == abilityAddMaxCooldown|| ability.abilityType == abilityAddMaxLife)
            return NO;
    }
    
    //instant ability don't worry about can add or not TODO maybe new ability that prevents it from being targetted
    if (ability.durationType != durationInstant)
    {
        //cannot add if contains the abilityRemoveAbility ability.
        for (Ability *ability in target.abilities)
        {
            if (ability.abilityType == abilityRemoveAbility && ability.targetType == targetSelf && ability.castType == castAlways && !ability.expired)
            {
                //NSLog(@"Cannot add ability: target is already muted");
                return NO;
            }
        }
        
        //cannot add duplicate ability
        if ([self containsDuplicateAbility:target ability:ability])
        {
            //NSLog(@"Cannot add ability: target contains identical ability that does not allow duplication");
            return NO;
        }
    }
    
    //if targetting an attacker, ability is avoided if target has abilityAssassin
    if (ability.targetType == targetAttacker)
    {
        for (Ability *ability in target.abilities)
            if (ability.abilityType == abilityAssassin && ability.targetType == targetSelf && ability.castType == castAlways && !ability.expired)
                return NO;
    }
    
    return YES;
}

-(void) checkForGameOver
{
    BOOL alreadyOver = NO;
    if (_gameOver)
        alreadyOver = YES;
    
    PlayerModel *player = self.players[PLAYER_SIDE];
    PlayerModel *enemy = self.players[OPPONENT_SIDE];
    
    //TODO this actually won't ever happen because one player will always die first
    if (player.playerMonster.dead && enemy.playerMonster.dead)
    {
        NSLog(@"Game ended in a draw!");
        self.gameOver = YES;
        _playerOneDefeated = YES;
        _playerTwoDefeated = YES;
    }
    else if (player.playerMonster.dead)
    {
        NSLog(@"Player 1 lost!");
        self.gameOver = YES;
        _playerOneDefeated = YES;
    }
    else if (enemy.playerMonster.dead)
    {
        NSLog(@"Player 2 lost!");
        self.gameOver = YES;
        _playerTwoDefeated = YES;
    }
    
    if (self.gameOver)
    {
        [self.gameViewController.backgroundView setUserInteractionEnabled:NO];
        [self.gameViewController.handsView setUserInteractionEnabled:NO];
        [self.gameViewController.fieldView setUserInteractionEnabled:NO];
        [self.gameViewController.uiView setUserInteractionEnabled:NO];
        
        if (!alreadyOver)
            [self.gameViewController gameOver];
    }
}

//block delay functions
- (void)performBlock:(void (^)())block
{
    block();
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay
{
    void (^block_)() = [block copy]; // autorelease this if you're not using ARC
    [self performSelector:@selector(performBlock:) withObject:block_ afterDelay:delay];
}

-(void)setOpponentSeed:(int)seed
{
    NSLog(@"oppo seed: %d", seed);
    oppo_xor128_x = seed;
    oppo_xor128_y = seed + 13;
    oppo_xor128_z = seed + 19571;
    oppo_xor128_w = seed + 576377;
}

-(void)setPlayerSeed:(int)seed
{
    NSLog(@"player seed: %d", seed);
    player_xor128_x = seed;
    player_xor128_y = seed + 13;
    player_xor128_z = seed + 19571;
    player_xor128_w = seed + 576377;
}

uint32_t xor128(void) {
    uint32_t t = xor128_x ^ (xor128_x << 11);
    xor128_x = xor128_y; xor128_y = xor128_z; xor128_z = xor128_w;
    return xor128_w = xor128_w ^ (xor128_w >> 19) ^ (t ^ (t >> 8));
}

/** Uses xor128 to sort */
-(void)multiplayerShuffleDeck:(DeckModel*)deck
{
    [deck sortDeck];
    
    NSMutableArray *newCards = [NSMutableArray array];
    
    //take a random card from original array and place into new array
    while ([deck.cards count] > 0)
    {
        uint32_t random = xor128();
        int count = [deck.cards count]-1;
        int cardIndex;
        
        if (count == 0)
            cardIndex = 0;
        else
            cardIndex = random%count;
        
        [newCards addObject:deck.cards[cardIndex]];
        [deck.cards removeObjectAtIndex:cardIndex];
    }
    
    for (CardModel*card in newCards)
        [deck addCard:card];
}

@end
