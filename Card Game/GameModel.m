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
#import "CardPointsUtility.h"

@implementation GameModel
{
    MonsterCardModel* opponentCurrentTarget;
}

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
@synthesize moveHistories = _moveHistories;

/*
uint32_t xor128_x = 123456789;
uint32_t xor128_y = 362436069;
uint32_t xor128_z = 521288629;
uint32_t xor128_w = 88675123;
*/

uint32_t oppo_xor128_x,oppo_xor128_y,oppo_xor128_z,oppo_xor128_w,player_xor128_x,player_xor128_y,player_xor128_z,player_xor128_w;

const int INITIAL_CARD_DRAW = 4;

//TEMPORARY
int cardIDCount = 0;

enum GameMode __gameMode; //because C functions cant access

-(instancetype)initWithViewController:(GameViewController *)gameViewController gameMode: (enum GameMode)gameMode withLevel:(Level*)level
{
    self = [super init];
    
    if (self){
        self.gameMode = gameMode;
        __gameMode = gameMode;
        self.gameViewController = gameViewController;
        _level = level;
        
        //initialize battlefield and hands to be two arrays
        self.battlefield = @[[NSMutableArray array],[NSMutableArray array]];
        self.graveyard = @[[NSMutableArray array],[NSMutableArray array]];
        self.hands = @[[NSMutableArray array],[NSMutableArray array]];
        self.decks = @[[[DeckModel alloc] init], [[DeckModel alloc] init ]];
        self.moveHistories = [NSMutableArray array];
        
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
            
            //d1 cards are worse than the "standard", d2 roughly equal, and d3 better
            if ([_level.levelID hasPrefix:@"d1"])
            {
                self.aiPlayer.levelDifficultyOffset = 0.25;
            }
            else if ([_level.levelID hasPrefix:@"d2"])
            {
                self.aiPlayer.levelDifficultyOffset = 0;
            }
            else if ([_level.levelID hasPrefix:@"d3"])
            {
                self.aiPlayer.levelDifficultyOffset = -0.1;
            }
            
            
        }
        
        if (gameMode != GameModeMultiplayer)
            [self loadDecks];
        
    }
    
    return self;
}

-(void)startGame
{
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
            [self multiplayerShuffleDeck:deck side:side];
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
    /*
    DeckModel*aiDeck = self.decks[OPPONENT_SIDE];
    
    NSLog(@"ai deck size %d", aiDeck.count);
    for (int i = 0; i < aiDeck.count; i++)
    {
        CardModel*card = [aiDeck getCardAtIndex:i];
        NSLog(@"%@, %d", card.name, i);
    }*/
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
    
    spell = [[SpellCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    spell.element = elementLightning;
    spell.name = @"DEBUG CARD";
    spell.cost = 0;
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationUntilEndOfTurn withValue:[NSNumber numberWithInt:1]]];
    //[playerHand addObject:spell];
    
    
    spell = [[SpellCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    spell.element = elementLightning;
    spell.name = @"DEBUG CARD";
    spell.cost = 0;
    [spell addBaseAbility: [[Ability alloc] initWithType:abilityAddDamage castType:castOnSummon targetType:targetOneAnyMinion withDuration:durationForever withValue:[NSNumber numberWithInt:1]]];
    //[playerHand addObject:spell];

    /*
    MonsterCardModel*monster;
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Nameless card";
    monster.life = monster.maximumLife = 10;
    monster.damage = 10;
    monster.cost = 0;
    monster.cooldown = monster.maximumCooldown = 0;
    monster.side = PLAYER_SIDE;
    [monster addBaseAbility: [[Ability alloc] initWithType:abilityPierce castType:castAlways targetType:targetSelf withDuration:durationForever withValue:[NSNumber numberWithInt:0]]];
    
    [playerHand addObject:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Nameless card";
    monster.life = monster.maximumLife = 10;
    monster.damage = 10;
    monster.cost = 0;
    monster.cooldown = monster.maximumCooldown = 0;
    monster.side = PLAYER_SIDE;
    //[monster addBaseAbility: [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    
    [playerHand addObject:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Nameless card";
    monster.life = monster.maximumLife = 10;
    monster.damage = 10;
    monster.cost = 0;
    monster.cooldown = monster.maximumCooldown = 0;
    monster.side = PLAYER_SIDE;
    //[monster addBaseAbility: [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    
    [playerHand addObject:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Nameless card";
    monster.life = monster.maximumLife = 10;
    monster.damage = 10;
    monster.cost = 0;
    monster.cooldown = monster.maximumCooldown = 0;
    monster.side = PLAYER_SIDE;
    //[monster addBaseAbility: [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    
    [playerHand addObject:monster];
    
    monster = [[MonsterCardModel alloc] initWithIdNumber:0 type:cardTypeSinglePlayer];
    monster.name = @"Nameless card";
    monster.life = monster.maximumLife = 10;
    monster.damage = 10;
    monster.cost = 0;
    monster.cooldown = monster.maximumCooldown = 0;
    monster.side = PLAYER_SIDE;
    //[monster addBaseAbility: [[Ability alloc] initWithType:abilitySetCooldown castType:castOnSummon targetType:targetSelf withDuration:durationInstant withValue:[NSNumber numberWithInt:0]]];
    
    [playerHand addObject:monster];
    */
    
    /*
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
    NSLog(@"load deck called");
    //self.decks = @[ [SinglePlayerCards getDeckOne], [SinglePlayerCards getDeckOne]];
    //[SinglePlayerCards uploadPlayerDeck];
    
    DeckModel *opponentDeck;
    DeckModel *playerDeck;
    
    if (_gameMode == GameModeSingleplayer)
    {
        opponentDeck = [[DeckModel alloc]init];
        
        //quick match level, do nothing as this will be loaded and set by GameViewController
        if (_level == [Campaign quickMatchLevel])
        {
            //[self loadQuickMatchDeck: opponentDeck];
            
        }
        else
        {
            //dup the cards from level
            for (CardModel*card in _level.cards.cards)
                [opponentDeck addCard:[[CardModel alloc] initWithCardModel:card]];
        }
        
        
        //get player's preconstructed campaign deck
        DeckModel*campaignPlayerDeck = [SinglePlayerCards getPlayerCampaignDeckWithID:_level.levelID];
        if (campaignPlayerDeck != nil)
        {
            playerDeck = [[DeckModel alloc] init];
            for (CardModel*card in campaignPlayerDeck.cards)
                [playerDeck addCard:[[CardModel alloc] initWithCardModel:card]];
            
            NSLog(@"player cards count %lu",playerDeck.cards.count);
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
    //NSLog(@"Breakpoint, loadDecks"); // testing purposes
    
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

+(void)loadQuickMatchDeck:(DeckModel*)deck
{
    PFQuery *cardsQuery = [PFQuery queryWithClassName:@"Card"];
    
    //TODO needs mana curve
    //TODO need to ignore legacy cards (once there's enough cards in database)
    
    /*
     Types of deck's element structures:
     0 = neutral heavy
     1 = one element (not neutral) focus
     2 = two element (not neutral) focus
     3 = balanced
     */
    
    int deckStructure = arc4random_uniform(4);
    deckStructure = 3;
    
    //picks elements
    NSArray*elements = @[
                         @(arc4random_uniform(2)),
                         @(arc4random_uniform(2)),
                         @(arc4random_uniform(2))
                         ];
    
    /*
     focused elements (depending on deckStructure)
     
     element structure = 1:
     0 = fire/ice
     1 = thunder/earth
     2 = light/dark
     
     element structure = 2:
     reverse of element structure = 1 (i.e. 0 = thunder/earth and light/dark)
     
     element structure = 0 or 3:
     N/A
     */
    
    
    
    int elementFocus = arc4random_uniform(3);

    __block int i = 0;
    
    while (i < 20)
    {
        //apply filters:
        int elementToPick = 0;
        
        //neutral focused
        if (deckStructure == 0)
        {
            //80% neutral cards
            if (arc4random_uniform(10) < 8)
                elementToPick = elementNeutral;
            //20% other cards
            else
            {
                int randomElement = arc4random_uniform(3);
                
                elementToPick = elementNeutral + 1 + 2 * randomElement + [elements[randomElement] intValue];
            }
        }
        //single element focus
        else if (deckStructure == 1)
        {
            //20% neutral cards
            if (arc4random_uniform(10) < 2)
                elementToPick = elementNeutral;
            else
            {
                //start off random
                int randomElement = arc4random_uniform(3);
                
                elementToPick = elementNeutral + 1 + 2 * randomElement + [elements[randomElement] intValue];
                
                //70% to pick element focus (i.e. 80% since randomElement can be this)
                if (arc4random_uniform(10) < 7)
                    elementToPick = elementNeutral + 1 + 2 * elementFocus + [elements[elementFocus] intValue];
            }
        }
        //two element focus
        else if (deckStructure == 2)
        {
            //20% neutral cards
            if (arc4random_uniform(10) < 2)
                elementToPick = elementNeutral;
            else
            {
                //start off random
                int randomElement = arc4random_uniform(3);
                
                elementToPick = elementNeutral + 1 + 2 * randomElement + [elements[randomElement] intValue];
                
                //if picked not focus, reroll (1/3 becomes 1/9)
                if (elementToPick == (elementNeutral + 1 + 2 * elementFocus + [elements[elementFocus] intValue]))
                {
                    int randomElement2 = arc4random_uniform(3);
                    
                    elementToPick = elementNeutral + 1 + 2 * randomElement2 + [elements[randomElement2] intValue];
                }
            }
        }
        //balanced
        else if (deckStructure == 3)
        {
            //20% neutral cards
            if (arc4random_uniform(10) < 2)
                elementToPick = elementNeutral;
            //80% other cards
            else
            {
                int randomElement = arc4random_uniform(3);
                
                elementToPick = elementNeutral + 1 + 2 * randomElement + [elements[randomElement] intValue];
            }
        }
        
        //NSLog(@"element: %d", elementToPick);
        
        [cardsQuery whereKey:@"element" equalTo:@(elementToPick)];
        //[cardsQuery whereKey:@"adminPhotoCheck" equalTo:@(YES)];
        
        int count = (int)[cardsQuery countObjects];
        
        cardsQuery.skip = arc4random_uniform(count);
        
        PFObject *cardPF = [cardsQuery getFirstObject];
        
        NSLog(@"get card start");
        [CardModel createCardFromPFObject:cardPF onFinish:^(CardModel * card) {
            [deck addCard:card];
            NSLog(@"got card: %d", card.idNumber);
        }];
        
        
        
        i++;
    }
    
    while (i < 20)
        sleep(10);
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
            
            //EDIT: changed to as long as one is valid then it's valid
            for (Ability *ability in spellCard.abilities)
            {
                if ([self abilityHasValidTargets:ability castedBy:nil side:side])
                    return YES;
            }
            
            return NO;
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
    
    _currentMoveHistory = [[MoveHistory alloc] initWithCaster:card withTargets:[NSMutableArray array] withMoveType:MoveTypeSummon withSide:side withBoardState:[self getAllMonstersOnField]];
    
    if ([card isKindOfClass: [MonsterCardModel class]])
    {
        MonsterCardModel *monsterCard = (MonsterCardModel*) card;

        //TODO for now added before effects so it doesnt mess up some animations
        //TODO honestly these two lines should only be called AFTER castAbility is resolved (a bit tricky to do, also includes spell cards)
        [self addCardToBattlefield:monsterCard side:side];
        
        if (side == PLAYER_SIDE)
        {
            [self.gameViewController updateBattlefieldView: side];
        }
        
        //[self.gameViewController performBlock:^{
            //CastType castOnSummon is casted here
            for (int i = 0; i < [monsterCard.abilities count]; i++) //castAbility may insert objects in end
            {
                Ability*ability = monsterCard.abilities[i];
                if (ability.castType == castOnSummon)
                {
                    [card.cardView castedAbility:ability];
                    NSArray*targets = [self castAbility:ability byMonsterCard:monsterCard toMonsterCard:nil fromSide:side];
                    
                    for (int i = 0; i < targets.count; i++)
                        [_currentMoveHistory addTarget:targets[i]];
                }
            }
            //[self.gameViewController decAnimationCounter];
            
            //send multiplayer data on summon if no targets
            if (_gameMode == GameModeMultiplayer && side == PLAYER_SIDE && _gameViewController.currentAbilities.count == 0)
            {
                [_gameViewController.MPDataHandler sendSummonCard:_gameViewController.currentCardIndex withTarget:positionNoPosition];
            }
        //} afterDelay:0.0];
        
        //[self.gameViewController updateBattlefieldView: side];
        
        //[self.gameViewController addAnimationCounter]; //the delayed cast counts as an animation
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
                NSArray*targets = [self castAbility:ability byMonsterCard:nil toMonsterCard:nil fromSide:side];
                
                for (int i = 0; i < targets.count; i++)
                    [_currentMoveHistory addTarget:targets[i]];
            }
        }
        
        //send multiplayer data on summon
        if (_gameMode == GameModeMultiplayer && side == PLAYER_SIDE && _gameViewController.currentAbilities.count == 0)
        {
            [_gameViewController.MPDataHandler sendSummonCard:_gameViewController.currentCardIndex withTarget:positionNoPosition];
        }
    }
    
    //remove card and use up cost
    [self.hands[side] removeObject:card];
    player.resource -= card.cost;
    
    //update again because some cards have effects on summon (e.g. charge will make it highlighted immediately)
    if (side == PLAYER_SIDE)
    {
        [self.gameViewController updateBattlefieldView: side];
    }
    
    //not waiting on any selectable abilities, insta record the history
    if (_gameViewController.currentAbilities.count == 0)
    {
        [_currentMoveHistory updateAllValues];
        
        NSLog(@"==================HISTORY RECORDED==================");
        NSLog(@"CASTER: %@", _currentMoveHistory.caster.name);
        
        for (int i = 0; i < _currentMoveHistory.targets.count; i++)
        {
            NSLog(@"TARGET: %@, VALUE: %@", [_currentMoveHistory.targets[i] name], _currentMoveHistory.targetsValues[i]);
        }
        
        NSLog(@"====================================================");
        
        [_moveHistories addObject:_currentMoveHistory];
        [_gameViewController.moveHistoryTableView.tableView reloadInputViews];
        [_gameViewController.moveHistoryTableView.tableView reloadData];
        
        _currentMoveHistory = nil;
        
        
    }
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
                //currently no move history, add it
                if (_currentMoveHistory == nil)
                {
                    _currentMoveHistory = [[MoveHistory alloc] initWithCaster:monsterCard withTargets:[NSMutableArray array] withMoveType:MoveTypeOnMove withSide:side withBoardState:[self getAllMonstersOnField]];
                }
                
                [monsterCard.cardView castedAbility:ability];
                NSArray*targets = [self castAbility:ability byMonsterCard:monsterCard toMonsterCard:nil fromSide:side];
                
                for (int i = 0; i < targets.count; i++)
                {
                    [_currentMoveHistory addTarget:(MonsterCardModel*)targets[i]];
                }
            }
        }
    }
    
    //had cast on move, save the history
    if (_currentMoveHistory != nil)
    {
        [_currentMoveHistory updateAllValues];
        
        NSLog(@"==================HISTORY RECORDED==================");
        NSLog(@"CASTER: %@, VALUE: %@", _currentMoveHistory.caster.name, _currentMoveHistory.casterValue);
        
        for (int i = 0; i < _currentMoveHistory.targets.count; i++)
        {
            NSLog(@"TARGET: %@, VALUE: %@", [_currentMoveHistory.targets[i] name], _currentMoveHistory.targetsValues[i]);
        }
        
        NSLog(@"====================================================");
        
        [_moveHistories addObject:_currentMoveHistory];
        [_gameViewController.moveHistoryTableView.tableView reloadInputViews];
        [_gameViewController.moveHistoryTableView.tableView reloadData];
        
        _currentMoveHistory = nil;
    }
    
    monsterCard.turnEnded = NO;
}

-(void)cardEndTurn: (MonsterCardModel*) monsterCard fromSide: (int)side
{
    //set all 0 cooldown creatures to 1
    for (int i = 0; i < [monsterCard.abilities count]; i++)
    {
        if (monsterCard.cooldown == 0)
            monsterCard.cooldown = 1;
    }
    
    //cast abilities that castOnEndOfTurn
    for (int i = 0; i < [monsterCard.abilities count]; i++) //castAbility may insert objects in end
    {
        Ability*ability = monsterCard.abilities[i];
        if (ability.castType == castOnEndOfTurn)
        {
            //currently no move history, add it
            if (_currentMoveHistory == nil)
            {
                _currentMoveHistory = [[MoveHistory alloc] initWithCaster:monsterCard withTargets:[NSMutableArray array] withMoveType:MoveTypeOnEndOfTurn withSide:side withBoardState:[self getAllMonstersOnField]];
            }
            
            [monsterCard.cardView castedAbility:ability];
            NSArray* targets = [self castAbility:ability byMonsterCard:monsterCard toMonsterCard:nil fromSide:side];
            
            for (int i = 0; i < targets.count; i++)
            {
                [_currentMoveHistory addTarget:(MonsterCardModel*)targets[i]];
            }
        }
    }
    
    //check for dead
    if (monsterCard.dead)
        [self cardDies:monsterCard destroyedBy:nil fromSide:side];
    
    //had cast on move, save the history
    if (_currentMoveHistory != nil)
    {
        [_currentMoveHistory updateAllValues];
        
        NSLog(@"==================HISTORY RECORDED==================");
        NSLog(@"CASTER: %@, VALUE: %@", _currentMoveHistory.caster.name, _currentMoveHistory.casterValue);
        
        for (int i = 0; i < _currentMoveHistory.targets.count; i++)
        {
            NSLog(@"TARGET: %@, VALUE: %@", [_currentMoveHistory.targets[i] name], _currentMoveHistory.targetsValues[i]);
        }
        
        NSLog(@"====================================================");
        
        [_moveHistories addObject:_currentMoveHistory];
        [_gameViewController.moveHistoryTableView.tableView reloadInputViews];
        [_gameViewController.moveHistoryTableView.tableView reloadData];
        
        _currentMoveHistory = nil;
    }
    
    monsterCard.turnEnded = YES;
}

-(int)calculateDamage: (MonsterCardModel*)attacker fromSide:(int) side dealtTo:(MonsterCardModel*)target
{
    //damage already includes attacker's abilities
    int damage = [attacker damage];
    
    //additional modifiers, especially from defender
    return damage;
}

-(NSArray*)attackCard: (CardModel*) attacker fromSide: (int) side target: (MonsterCardModel*)target
{
    if ([attacker isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel *attackerMonsterCard = (MonsterCardModel*)attacker;
        _currentMoveHistory = [[MoveHistory alloc] initWithCaster:attackerMonsterCard withTargets:[NSMutableArray arrayWithObject:target] withMoveType:MoveTypeAttack withSide:side withBoardState:[self getAllMonstersOnField]];
        
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
                    [self castAbility:ability byMonsterCard:target toMonsterCard:attackerMonsterCard fromSide:oppositeSide];
                    //note that these will not be recorded by move history
                }
                //assassin will dodge the targeting (but still get hit if for example it was deal damage to all)
                else
                {
                    //to fix the animation
                    [self castAbility:ability byMonsterCard:target toMonsterCard:nil fromSide:oppositeSide];
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
                NSArray* targets = [self castAbility:ability byMonsterCard:attackerMonsterCard toMonsterCard:target fromSide:side];
                
                for (int i = 0; i < targets.count; i++)
                {
                    [_currentMoveHistory addTarget:(MonsterCardModel*)targets[i]];
                }
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
                            
                            [_currentMoveHistory addTarget:targetPlayer.playerMonster];
                            
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
            //note: attacker dying's effect will also not be recorded
            
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
        
        //record the attack
        [_currentMoveHistory updateAllValues];
        
        NSLog(@"==================HISTORY RECORDED==================");
        NSLog(@"CASTER: %@, VALUE: %@", _currentMoveHistory.caster.name, _currentMoveHistory.casterValue);
        
        for (int i = 0; i < _currentMoveHistory.targets.count; i++)
        {
            NSLog(@"TARGET: %@, VALUE: %@", [_currentMoveHistory.targets[i] name], _currentMoveHistory.targetsValues[i]);
        }
        
        NSLog(@"====================================================");
        
        [_moveHistories addObject:_currentMoveHistory];
        [_gameViewController.moveHistoryTableView.tableView reloadInputViews];
        [_gameViewController.moveHistoryTableView.tableView reloadData];
        
        _currentMoveHistory = nil;
        
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
    if ([attacker damage] <= 0)
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
            if (!ability.expired && ability.abilityType == abilityTaunt && ability.targetType == targetSelf && ability.castType == castAlways)
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
                        if (!ability.expired && ability.abilityType == abilityTaunt && ability.targetType == targetSelf && ability.castType == castAlways)
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
 Returns a list of MonsterCards that it targetted
 */
-(NSArray*)castAbility: (Ability*) ability byMonsterCard: (MonsterCardModel*) attacker toMonsterCard: (MonsterCardModel*) target fromSide: (int)side
{
    if (ability.expired) //cannot be cast if already expired
        return @[];
    
    //first find array of targets to apply effects on
    NSArray *targets;
    
    int oppositeSide = side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
    
    //all of the target types. Put the target into the array targets for applying abilities later
    if (ability.targetType == targetSelf)
        targets = @[attacker];
    else if (ability.targetType == targetVictim)
    {
        if (target.heroic)
            return @[];
        
        targets = @[target];
    }
    else if (ability.targetType == targetVictimMinion)
    {
        if (target.heroic) //do not cast ability if target is not a minion
            return @[];
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
                NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[side]];
                
                if (attacker != nil)
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
                return @[];
            }
            else
            {
                //AI must have already picked a target
                MonsterCardModel* opponentTarget = opponentCurrentTarget;
                if (opponentTarget != nil && [self validAttack:nil target:opponentTarget])
                    targets = @[opponentTarget];
                else
                {
                    if (opponentTarget != nil)
                        NSLog(@"WARNING: AI tried to attack an invalid target!");
                    return @[];
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
                NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[side]];
                if (attacker != nil)
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
                return @[];
            }
            else
            {
                //AI must have already picked a target
                MonsterCardModel* opponentTarget = opponentCurrentTarget;
                if (opponentTarget != nil && [self validAttack:nil target:opponentTarget])
                    targets = @[opponentTarget];
                else
                {
                    if (opponentTarget != nil)
                        NSLog(@"WARNING: AI tried to attack an invalid target!");
                    return @[];
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
                NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[side]];
                if (attacker != nil)
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
                return @[];
            }
            else
            {
                //AI must have already picked a target
                MonsterCardModel* opponentTarget = opponentCurrentTarget;
                if (opponentTarget != nil && [self validAttack:nil target:opponentTarget])
                    targets = @[opponentTarget];
                else
                {
                    if (opponentTarget != nil)
                        NSLog(@"WARNING: AI tried to attack an invalid target!");
                    return @[];
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
                NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[side]];
                if (attacker != nil)
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
                return @[];
            }
            else
            {
                //AI must have already picked a target
                MonsterCardModel* opponentTarget = opponentCurrentTarget;
                if (opponentTarget != nil && [self validAttack:nil target:opponentTarget])
                    targets = @[opponentTarget];
                else
                {
                    if (opponentTarget != nil)
                        NSLog(@"WARNING: AI tried to attack an invalid target!");
                    return @[];
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
                NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[oppositeSide]];
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
                return @[];
            }
            else
            {
                //AI must have already picked a target
                MonsterCardModel* opponentTarget = opponentCurrentTarget;
                if (opponentTarget != nil && [self validAttack:nil target:opponentTarget])
                    targets = @[opponentTarget];
                else
                {
                    if (opponentTarget != nil)
                        NSLog(@"WARNING: AI tried to attack an invalid target!");
                    return @[];
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
                NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[oppositeSide]];
                
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
                return @[];
            }
            else
            {
                //AI must have already picked a target
                MonsterCardModel* opponentTarget = opponentCurrentTarget;
                if (opponentTarget != nil && [self validAttack:nil target:opponentTarget])
                    targets = @[opponentTarget];
                else
                {
                    if (opponentTarget != nil)
                        NSLog(@"WARNING: AI tried to attack an invalid target!");
                    return @[];
                }
            }
        }
    }
    else if (ability.targetType == targetAll)
    {
        NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[side]];
        if (attacker != nil)
            [allTargets removeObject:attacker]; //remove itself
        [allTargets addObjectsFromArray:self.battlefield[oppositeSide]];
        [allTargets addObject:((PlayerModel*)self.players[side]).playerMonster];
        [allTargets addObject:((PlayerModel*)self.players[oppositeSide]).playerMonster];
        
        targets = [NSArray arrayWithArray:allTargets.allObjects];
    }
    else if (ability.targetType == targetAllMinion)
    {
        NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[side]];
        if (attacker != nil)
            [allTargets removeObject:attacker]; //remove itself
        [allTargets addObjectsFromArray:self.battlefield[oppositeSide]];
        [allTargets removeObject:[self.players[OPPONENT_SIDE] playerMonster]]; //happens in boss fights
        targets = [NSArray arrayWithArray:allTargets.allObjects];
    }
    else if (ability.targetType == targetAllFriendly)
    {
        NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[side]];
        if (attacker != nil)
            [allTargets removeObject:attacker]; //remove itself
        [allTargets addObject:((PlayerModel*)self.players[side]).playerMonster];
        
        targets = [NSArray arrayWithArray:allTargets.allObjects];
    }
    else if (ability.targetType == targetAllFriendlyMinions)
    {
        NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[side]];
        if (attacker != nil)
            [allTargets removeObject:attacker]; //remove itself
        [allTargets removeObject:[self.players[OPPONENT_SIDE] playerMonster]]; //happens in boss fights
        targets = [NSArray arrayWithArray:allTargets.allObjects];
    }
    else if (ability.targetType == targetAllEnemy)
    {
        NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[oppositeSide]];
        [allTargets addObject:((PlayerModel*)self.players[oppositeSide]).playerMonster];
        
        targets = [NSArray arrayWithArray:allTargets.allObjects];
    }
    else if (ability.targetType == targetAllEnemyMinions)
    {
        NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[oppositeSide]];
        [allTargets removeObject:[self.players[OPPONENT_SIDE] playerMonster]]; //happens in boss fights
        targets = [NSArray arrayWithArray:allTargets.allObjects];
    }
    else if (ability.targetType == targetOneRandomAny)
    {
        NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[side]];
        if (attacker != nil)
            [allTargets removeObject:attacker]; //remove itself
        [allTargets addObjectsFromArray:self.battlefield[oppositeSide]];
        [allTargets addObject:((PlayerModel*)self.players[side]).playerMonster];
        [allTargets addObject:((PlayerModel*)self.players[oppositeSide]).playerMonster];
        
        if (allTargets.count == 0)
            return @[];
        
        NSArray* allTargetsArray = [NSArray arrayWithArray:allTargets.allObjects];
        
        //remove monsters that are not valid targets (e.g. add attack to a muted card)
        for (int i = (int)allTargetsArray.count - 1; i >= 0; i--)
        {
            MonsterCardModel*monster = allTargetsArray[i];
            
            if (![self canAddAbility:monster ability:ability])
                [allTargets removeObject:monster];
        }
        
        targets = @[allTargets.allObjects[(int)(xor128(side)%allTargets.count)]];
    }
    else if (ability.targetType == targetOneRandomMinion)
    {
        NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[side]];
        if (attacker != nil)
            [allTargets removeObject:attacker]; //remove itself
        [allTargets addObjectsFromArray:self.battlefield[oppositeSide]];
        [allTargets removeObject:[self.players[OPPONENT_SIDE] playerMonster]]; //happens in boss fights
        
        NSArray* allTargetsArray = [NSArray arrayWithArray:allTargets.allObjects];
        
        //remove monsters that are not valid targets (e.g. add attack to a muted card)
        for (int i = (int)allTargetsArray.count - 1; i >= 0; i--)
        {
            MonsterCardModel*monster = allTargetsArray[i];
            
            if (![self canAddAbility:monster ability:ability])
                [allTargets removeObject:monster];
        }
        
        if (allTargets.count == 0)
            return @[];
        
        targets = @[allTargets.allObjects[(int)(xor128(side)%allTargets.count)]];
    }
    else if (ability.targetType == targetOneRandomFriendly)
    {
        NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[side]];
        if (attacker != nil)
            [allTargets removeObject:attacker]; //remove itself
        [allTargets addObject:((PlayerModel*)self.players[side]).playerMonster];
        
        NSArray* allTargetsArray = [NSArray arrayWithArray:allTargets.allObjects];
        
        //remove monsters that are not valid targets (e.g. add attack to a muted card)
        for (int i = (int)allTargetsArray.count - 1; i >= 0; i--)
        {
            MonsterCardModel*monster = allTargetsArray[i];
            
            if (![self canAddAbility:monster ability:ability])
                [allTargets removeObject:monster];
        }
        
        if (allTargets.count == 0)
            return @[];
        
        targets = @[allTargets.allObjects[(int)(xor128(side)%allTargets.count)]];
    }
    else if (ability.targetType == targetOneRandomFriendlyMinion)
    {
        NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[side]];
        if (attacker != nil)
            [allTargets removeObject:attacker]; //remove itself
        [allTargets removeObject:[self.players[OPPONENT_SIDE] playerMonster]]; //happens in boss fights
        
        NSArray* allTargetsArray = [NSArray arrayWithArray:allTargets.allObjects];
        
        //remove monsters that are not valid targets (e.g. add attack to a muted card)
        for (int i = (int)allTargetsArray.count - 1; i >= 0; i--)
        {
            MonsterCardModel*monster = allTargetsArray[i];
            
            if (![self canAddAbility:monster ability:ability])
                [allTargets removeObject:monster];
        }
        
        if (allTargets.count == 0)
            return @[];
        
        targets = @[allTargets.allObjects[(int)(xor128(side)%allTargets.count)]];
    }
    else if (ability.targetType == targetOneRandomEnemy)
    {
        NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[oppositeSide]];
        [allTargets addObject:((PlayerModel*)self.players[oppositeSide]).playerMonster];
        
        NSArray* allTargetsArray = [NSArray arrayWithArray:allTargets.allObjects];
        
        //remove monsters that are not valid targets (e.g. add attack to a muted card)
        for (int i = (int)allTargetsArray.count - 1; i >= 0; i--)
        {
            MonsterCardModel*monster = allTargetsArray[i];
            
            if (![self canAddAbility:monster ability:ability])
                [allTargets removeObject:monster];
        }
        
        if (allTargets.count == 0)
            return @[];
        
        targets = @[allTargets.allObjects[(int)(xor128(side)%allTargets.count)]];
    }
    else if (ability.targetType == targetOneRandomEnemyMinion)
    {
        NSMutableSet *allTargets = [NSMutableSet setWithArray:self.battlefield[oppositeSide]];
        [allTargets removeObject:[self.players[OPPONENT_SIDE] playerMonster]]; //happens in boss fights
        
        NSArray* allTargetsArray = [NSArray arrayWithArray:allTargets.allObjects];
        
        //remove monsters that are not valid targets (e.g. add attack to a muted card)
        for (int i = (int)allTargetsArray.count - 1; i >= 0; i--)
        {
            MonsterCardModel*monster = allTargetsArray[i];
            
            if (![self canAddAbility:monster ability:ability])
                [allTargets removeObject:monster];
        }
        
        if (allTargets.count == 0)
            return @[];
        
        targets = @[allTargets.allObjects[(int)(xor128(side)%allTargets.count)]];
    }
    else if (ability.targetType == targetHeroAny)
    {
        if (target != nil)
            targets = @[target];
        else
        {
            if (side == PLAYER_SIDE)
            {
                NSMutableSet *allTargets = [NSMutableSet set];
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
                return @[];
            }
            else
            {
                //AI must have already picked a target
                MonsterCardModel* opponentTarget = opponentCurrentTarget;
                if (opponentTarget != nil && [self validAttack:nil target:opponentTarget])
                    targets = @[opponentTarget];
                else
                {
                    if (opponentTarget != nil)
                        NSLog(@"WARNING: AI tried to attack an invalid target!");
                    return @[];
                }
            }
           
        }
    }
    else if (ability.targetType == targetHeroFriendly)
    {
        PlayerModel *player = self.players[side];
        if (player.playerMonster == nil)
            return @[];
            
        targets = @[player.playerMonster];
    }
    else if (ability.targetType == targetHeroEnemy)
    {
        PlayerModel *enemy = self.players[oppositeSide];
        if (enemy.playerMonster == nil)
            return @[];
        
        targets = @[enemy.playerMonster];
    }
    
    
    //---SPECIAL CASE ABILITIES HERE---//
    
    //these abilities do not target any minion, so simply cast it
    if (ability.abilityType == abilityDrawCard || ability.abilityType == abilityAddResource || ability.abilityType == abilitySummonFighter)
    {
        [self castInstantAbility:ability onMonsterCard:nil fromSide:side];
        return @[];
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
                        return @[];
                    
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
    
    return targets;
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
        
        if (self.gameViewController.currentSpellCard) {
            if (self.gameViewController.currentSpellCard.element == elementLightning) {
                [self.gameViewController animateCardThunderDamage:monster.cardView fromSide:monster.side];
            }else if (self.gameViewController.currentSpellCard.element == elementFire) {
                [self.gameViewController animateCardFireDamage:monster.cardView fromSide:monster.side];
            }else if (self.gameViewController.currentSpellCard.element == elementIce){
                [self.gameViewController animateCardIceDamage:monster.cardView fromSide:monster.side];
            }
            
        }
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
            
            [_gameViewController updateHandsView:PLAYER_SIDE];
        }
        else if (ability.targetType == targetHeroEnemy)
        {
            opponent.resource += [ability.value intValue];
        }
        else if (ability.targetType == targetAll)
        {
            player.resource += [ability.value intValue];
            opponent.resource += [ability.value intValue];
            
            [_gameViewController updateHandsView:PLAYER_SIDE];
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
            cost = ceil(cost*0.8);
            damage = ceil(damage*0.8);
            life = ceil(life*0.8);
        }
        else if ([ability.value intValue] == 2)
        {
            cost = ceil(cost*0.4);
            damage = ceil(damage*0.4);
            life = ceil(life*0.4);
        }
        else if ([ability.value intValue] == 3)
        {
            cost = ceil(cost*0.3);
            damage = ceil(damage*0.3);
            life = ceil(life*0.3);
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
            int currentMonsterCount = (int)[monsterField count];
            if (monster.dead)
                currentMonsterCount--;
            
            if (currentMonsterCount < MAX_BATTLEFIELD_SIZE)
                [self addCardToBattlefield:fracture side:monster.side];
        }
        
        return YES;
    }
    else if (ability.abilityType == abilitySummonFighter)
    {
        NSArray*monsterField = self.battlefield[side];
        int currentMonsterCount = (int)[monsterField count];
        if (monster.dead)
            currentMonsterCount--;
        
        if (currentMonsterCount < MAX_BATTLEFIELD_SIZE)
        {
            NSString *cardID = [NSString stringWithFormat:@"d%@_%@",ability.otherValues[2], ability.value];
            
            MonsterCardModel*fighter = (MonsterCardModel*)[SinglePlayerCards getCampaignCardWithFullID:cardID];
            fighter.side = side;
            fighter.cooldown = 0;
            NSLog(@"NAME: %@ SIDE: %d, monster: %@", fighter.name, monster.side, monster.name);
            
            
            [self addCardToBattlefield:fighter side:side];
        }
    }
    else
    {
        return NO; //not an instant ability, nothing happened
    }
    //TODO when adding new instant effects, include them in the AIPlayer
    
    self.gameViewController.currentSpellCard = nil;
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
        if (ability.abilityType == abilityTaunt || ability.abilityType == abilityAddMaxLife)
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
    else if (_playerTwoDefeated) //during mulitplayer
        self.gameOver = YES;
    
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

-(NSArray*)getDeadMonsterWithAttacker:(MonsterCardModel*)attacker target:(MonsterCardModel*)target;
{
    NSMutableSet*deadMonsters = [NSMutableSet set];
    
    BOOL attackerIsAssassin = [CardPointsUtility cardHasAssassin:attacker];
    
    //if attacker more damage, should always cause death
    if ([attacker damage] >= target.life)
    {
        [deadMonsters addObject:target];
    }
    
    //if target more damage, should always cause death except assassin
    if ([target damage] >= attacker.life && !attackerIsAssassin)
    {
        [deadMonsters addObject:attacker];
    }
    
    //NOTE: will only check for abilities that deal direct effects (e.g. checks for reflect damage to attacker but not reflect damage to all enemies)
    
    //reflect damage/kill
    if (!attackerIsAssassin)
    {
        for (Ability *ability in target.abilities)
        {
            if (ability.abilityType == abilityLoseLife && ability.targetType == targetAttacker && ability.castType == castAlways)
            {
                if ((int)ability.value + [target damage] >= attacker.life)
                {
                    [deadMonsters addObject:attacker];
                    break;
                }
            }
            //kill on death
            else if (ability.abilityType == abilityKill && ability.targetType == targetAttacker && ability.castType == castAlways)
            {
                [deadMonsters addObject:attacker];
                break;
            }
        }
    }
    
    //pierce can cause a hero to die
    if ([CardPointsUtility cardHasPierce:attacker])
    {
        int overkillAmount = [attacker damage] - target.life;
        
        if (overkillAmount > 0 && overkillAmount >= [self.players[target.side] playerMonster].life)
        {
            [deadMonsters addObject:[self.players[target.side] playerMonster]];
        }
    }
    
    if ([CardPointsUtility cardHasPierce:target])
    {
        int overkillAmount = [target damage] - attacker.life;
        
        if (overkillAmount > 0 && overkillAmount >= [self.players[attacker.side] playerMonster].life)
        {
            [deadMonsters addObject:[self.players[attacker.side] playerMonster]];
        }
    }
    
    //TODO can add additional ones in future if needed
    
    
    return [deadMonsters allObjects];
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

-(void)setOpponentSeed:(uint32_t)seed
{
    NSLog(@"oppo seed: %d", seed);
    oppo_xor128_x = seed;
    oppo_xor128_y = seed + 13;
    oppo_xor128_z = seed + 19571;
    oppo_xor128_w = seed + 576377;
}

-(void)setPlayerSeed:(uint32_t)seed
{
    NSLog(@"player seed: %d", seed);
    player_xor128_x = seed;
    player_xor128_y = seed + 13;
    player_xor128_z = seed + 19571;
    player_xor128_w = seed + 576377;
}

uint32_t xor128(int side) {
    if (__gameMode == GameModeSingleplayer)
    {
        return arc4random();
    }
    else if (side == PLAYER_SIDE)
    {
        uint32_t t = player_xor128_x ^ (player_xor128_x << 11);
        player_xor128_x = player_xor128_y; player_xor128_y = player_xor128_z; player_xor128_z = player_xor128_w;
        player_xor128_w = player_xor128_w ^ (player_xor128_w >> 19) ^ (t ^ (t >> 8));
        return player_xor128_w;
    }
    else
    {
        uint32_t t = oppo_xor128_x ^ (oppo_xor128_x << 11);
        oppo_xor128_x = oppo_xor128_y; oppo_xor128_y = oppo_xor128_z; oppo_xor128_z = oppo_xor128_w;
        oppo_xor128_w = oppo_xor128_w ^ (oppo_xor128_w >> 19) ^ (t ^ (t >> 8));
        return oppo_xor128_w;
    }
}

/** Uses xor128 to sort */
-(void)multiplayerShuffleDeck:(DeckModel*)deck side:(int)side
{
    [deck sortDeck];
    
    /*
    NSLog(@"shuffle start, deck sorted");
    for (CardModel* card in deck.cards)
    {
        NSLog(@"%d", card.idNumber);
    }
     */
    
    NSMutableArray *newCards = [NSMutableArray array];
    
    //take a random card from original array and place into new array
    while ([deck.cards count] > 0)
    {
        uint32_t random = xor128(side);
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

-(int)getTargetIndex: (MonsterCardModel*)target
{
    if (target == [_players[PLAYER_SIDE] playerMonster])
    {
        return positionHeroA;
    }
    else if (target == [_players[OPPONENT_SIDE] playerMonster])
    {
        return positionHeroB;
    }
    else
    {
        NSArray*playerField = _battlefield[PLAYER_SIDE];
        for (int i = 0; i < [playerField count]; i++)
        {
            MonsterCardModel* monster = _battlefield[PLAYER_SIDE][i];
            
            if (target == monster)
                return positionA1 + i;
        }
        
        NSArray*opponentField = _battlefield[OPPONENT_SIDE];
        for (int i = 0; i < [opponentField count]; i++)
        {
            MonsterCardModel* monster = _battlefield[OPPONENT_SIDE][i];
            
            if (target == monster)
                return positionB1 + i;
        }
    }
    
    NSLog(@"DEBUG: no target position for this move");
    
    return positionNoPosition;
}

-(MonsterCardModel*)getTarget:(int)targetPosition
{
    if (targetPosition == positionHeroA)
    {
        return [_players[PLAYER_SIDE] playerMonster];
    }
    else if (targetPosition == positionHeroB)
    {
        return [_players[OPPONENT_SIDE] playerMonster];
    }
    else if (targetPosition >= positionA1 && targetPosition <= positionA5)
    {
        int index = targetPosition - positionA1;
        NSMutableArray*field = _battlefield[PLAYER_SIDE];
        
        if (index < field.count)
            return field[index];
        else
            NSLog(@"ERROR: Opponent tried to target an empty position on player's side");
    }
    else if (targetPosition >= positionB1 && targetPosition <= positionB5)
    {
        int index = targetPosition - positionB1;
        NSMutableArray*field = _battlefield[OPPONENT_SIDE];
        
        if (index < field.count)
            return field[index];
        else
            NSLog(@"ERROR: Opponent tried to target an empty position on their side");
    }
    
    return nil;
}

/*
-(void)setCurrentTarget:(int)targetPosition
{
    opponentCurrentTarget = [self getTarget:targetPosition];
    NSLog(@"set opponent current target to position %d, object is %@", targetPosition, opponentCurrentTarget);
}*/

-(MonsterCardModel*)getOpponentTarget
{
    return opponentCurrentTarget;
}

-(void)setOpponentTarget:(MonsterCardModel*)target
{
    opponentCurrentTarget = target;
}

-(NSMutableArray*)getAllMonstersOnField
{
    NSMutableArray*allMonsters = [NSMutableArray array];
    
    [allMonsters addObjectsFromArray:_battlefield[OPPONENT_SIDE]];
    if (![allMonsters containsObject:[_players[OPPONENT_SIDE] playerMonster]])
        [allMonsters addObject:[_players[OPPONENT_SIDE] playerMonster]];
    
    [allMonsters addObjectsFromArray:_battlefield[PLAYER_SIDE]];
    [allMonsters addObject:[_players[PLAYER_SIDE] playerMonster]];
    return allMonsters;
}

+(enum CardPosition) getReversedPosition:(enum CardPosition)position
{
    if (position == positionHeroA)
        return positionHeroB;
    else if (position == positionHeroB)
        return positionHeroA;
    else if (position == positionA1)
        return positionB1;
    else if (position == positionA2)
        return positionB2;
    else if (position == positionA3)
        return positionB3;
    else if (position == positionA4)
        return positionB4;
    else if (position == positionA5)
        return positionB5;
    else if (position == positionB1)
        return positionA1;
    else if (position == positionB2)
        return positionA2;
    else if (position == positionB3)
        return positionA3;
    else if (position == positionB4)
        return positionA4;
    else if (position == positionB5)
        return positionA5;
    
    return position;
}

@end
