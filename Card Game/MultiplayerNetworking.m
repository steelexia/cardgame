//
//  MultiplayerNetworking.m
//  cardgame
//
//  Created by Brian Allen on 2014-09-09.
//  Copyright (c) 2014 Content Games. All rights reserved.
//


#define playerIdKey @"PlayerId"
#define randomNumberKey @"randomNumber"

typedef NS_ENUM(NSUInteger, GameState) {
    kGameStateWaitingForMatch = 0,
    kGameStateWaitingForRandomNumber,
    kGameStateWaitingForStart,
    kGameStateActive,
    kGameStateDone
};

typedef NS_ENUM(NSUInteger, MessageType) {
    kMessageTypeRandomNumber = 0,
    kMessageTypeSeed,
    kMessageTypeSeedReceived,
    kMessageTypeGameBegin,
    kMessageTypeMove,
    kMessageTypeGameOver,
    kMessageTypeDeckID,
    kMessageTypeDeckIDReceived,
    //---------in-game---------//
    kMessageTypeEndTurn,
    kMessageTypeSummonCard,
    kMessageTypeAttackCard,
};

typedef struct {
    MessageType messageType;
} Message;

typedef struct {
    Message message;
    uint32_t randomNumber;
} MessageRandomNumber;

typedef struct {
    Message message;
    uint32_t seed;
} MessageSeed;

typedef struct {
    Message message;
} MessageSeedReceived;

typedef struct {
    Message message;
} MessageGameBegin;

typedef struct {
    Message message;
} MessageMove;

typedef struct {
    Message message;
    char deckID[10]; //TODO becareful that parse data doesn't change size
} MessageDeckID;

typedef struct {
    Message message;
} MessageDeckIDReceived;

typedef struct {
    Message message;
    BOOL player1Won;
} MessageGameOver;

typedef struct {
    Message message;
} MessageEndTurn;

typedef struct {
    Message message;
    int cardIndex;
    int targetPosition;
} MessageSummonCard;

typedef struct {
    Message message;
    int attackerPosition;
    int targetPosition;
} MessageAttackCard;

#import "MultiplayerNetworking.h"
#import "MultiplayerGameViewController.h"
#import "GameModel.h"

@implementation MultiplayerNetworking

{
    uint32_t _ourRandomNumber;
    GameState _gameState;
    BOOL _isPlayer1, _receivedAllRandomNumbers;
    
    NSMutableArray *_orderOfPlayers;
};

- (id)init
{
    if (self = [super init]) {
        _ourRandomNumber = arc4random();
        _gameState = kGameStateWaitingForMatch;
        _orderOfPlayers = [NSMutableArray array];
        [_orderOfPlayers addObject:@{playerIdKey : [GKLocalPlayer localPlayer].playerID,
                                     randomNumberKey : @(_ourRandomNumber)}];
    }
    return self;
}

- (void)sendData:(NSData*)data
{
    NSError *error;
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    
    BOOL success = [gameKitHelper.match
                    sendDataToAllPlayers:data
                    withDataMode:GKMatchSendDataReliable
                    error:&error];
    
    if (!success) {
        NSLog(@"Error sending data:%@", error.localizedDescription);
        [self matchEnded];
    }
}

#pragma mark GameKitHelper delegate methods

- (void)matchStarted
{
    NSLog(@"Match has started successfully");
    if (_receivedAllRandomNumbers) {
        _gameState = kGameStateWaitingForStart;
    } else {
        _gameState = kGameStateWaitingForRandomNumber;
    }
    
    //if (_isPlayer1)
    //    [self sendSeed];
    
    [self sendRandomNumber];
    [self tryStartGame];
}

-(void)playersFound
{
    _matchMakerPresented = YES;
    [self sendSeed];
}

- (void)sendRandomNumber
{
    MessageRandomNumber message;
    message.message.messageType = kMessageTypeRandomNumber;
    message.randomNumber = _ourRandomNumber;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];
    [self sendData:data];
}

-(void)sendSeed
{
    uint32_t randomNumber = arc4random();
    //srand48(randomNumber);
    
    NSLog(@"sent seed %ud", randomNumber);
    
    MessageSeed message;
    message.message.messageType = kMessageTypeSeed;
    message.seed = randomNumber;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageSeed)];
    [self sendData:data];
    
    _playerSeed = randomNumber;
}

// Add right after sendRandomNumber
- (void)sendGameBegin {
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)];
    [self sendData:data];
}

-(void)sendDeckID:(NSString*)deckID{
    MessageDeckID message;
    message.message.messageType = kMessageTypeDeckID;
    
    if (deckID.length != 10)
    {
        NSLog(@"Error: Deck ID's length is not 10.");
        return;
    }
    
    for (int i = 0; i < deckID.length; i++)
        message.deckID[i] = [deckID characterAtIndex:i];
    
    //message.deckID = [deckID UTF8String];
    NSData*data = [NSData dataWithBytes:&message length:sizeof(MessageDeckID)];
    //NSData*data = [deckID dataUsingEncoding:NSUTF8StringEncoding];
    [self sendData:data];
}

-(void)sendReceivedDeck
{
    MessageDeckIDReceived message;
    message.message.messageType = kMessageTypeDeckIDReceived;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageDeckIDReceived)];
    [self sendData:data];
}

-(void)sendEndTurn
{
    MessageEndTurn message;
    message.message.messageType = kMessageTypeEndTurn;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageEndTurn)];
    [self sendData:data];
}

-(void)sendSummonCard:(int)cardIndex withTarget:(int)targetPosition
{
    int target = [GameModel getReversedPosition:targetPosition];
    
    MessageSummonCard message;
    message.message.messageType = kMessageTypeSummonCard;
    message.cardIndex = cardIndex;
    message.targetPosition = target;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageSummonCard)];
    [self sendData:data];
}

// Fill the contents of tryStartGame as shown
- (void)tryStartGame {
    if (_isPlayer1 && _gameState == kGameStateWaitingForStart) {
        _gameState = kGameStateActive;
        [self sendGameBegin];
        
        //first player
        [self.delegate setCurrentPlayerIndex:0];
        
        [self processPlayerAliases];
    }
}

- (void)matchEnded {
    NSLog(@"Match has ended");
    [_delegate matchEnded];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    //1
    Message *message = (Message*)[data bytes];
    if (message->messageType == kMessageTypeRandomNumber) {
        MessageRandomNumber *messageRandomNumber = (MessageRandomNumber*)[data bytes];
        
        NSLog(@"Received random number:%d", messageRandomNumber->randomNumber);
        
        BOOL tie = NO;
        if (messageRandomNumber->randomNumber == _ourRandomNumber) {
            //2
            NSLog(@"Tie");
            tie = YES;
            _ourRandomNumber = arc4random();
            [self sendRandomNumber];
        } else {
            //3
            NSDictionary *dictionary = @{playerIdKey : playerID,
                                         randomNumberKey : @(messageRandomNumber->randomNumber)};
            [self processReceivedRandomNumber:dictionary];
        }
        
        //4
        if (_receivedAllRandomNumbers) {
            _isPlayer1 = [self isLocalPlayerPlayer1];
        }
        
        if (!tie && _receivedAllRandomNumbers) {
            //5
            if (_gameState == kGameStateWaitingForRandomNumber) {
                _gameState = kGameStateWaitingForStart;
            }
            [self tryStartGame];
        }
    }
    else if (message->messageType == kMessageTypeSeed) {
        
        MessageSeed *messageRandomNumber = (MessageSeed*)[data bytes];
        //srand48(messageRandomNumber->seed);
        
        //respond notifying seed received
        MessageSeedReceived message;
        message.message.messageType = kMessageTypeSeedReceived;
        NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageSeedReceived)];
        [self sendData:data];
        
        _receivedOpponentSeed = YES;
        //[_gameDelegate setOpponentSeed:messageRandomNumber->seed];
        _opponentSeed = messageRandomNumber->seed;
        
        NSLog(@"received seed %ud", _opponentSeed);
        
        //both have seed, start
        if (_matchMakerPresented && _opponentReceivedSeed)
        {
            [_delegate playersFound];
        }
    }
    else if (message->messageType == kMessageTypeSeedReceived)
    {
        _opponentReceivedSeed = YES;
        
        //both have seed, start
        if (_matchMakerPresented && _receivedOpponentSeed)
        {
            [_delegate playersFound];
        }
    }
    else if (message->messageType == kMessageTypeGameBegin) {
        NSLog(@"Begin game message received");
        [self.delegate setCurrentPlayerIndex:[self indexForLocalPlayer]];
        _gameState = kGameStateActive;
        [self processPlayerAliases];
    } else if (message->messageType == kMessageTypeMove) {
        NSLog(@"Move message received");
        MessageMove *messageMove = (MessageMove*)[data bytes];
        [self.delegate movePlayerAtIndex:[self indexForPlayerWithId:playerID]];
    } else if(message->messageType == kMessageTypeGameOver) {
        NSLog(@"Game over message received");
        MessageGameOver * messageGameOver = (MessageGameOver *) [data bytes];
        [self.delegate gameOver:messageGameOver->player1Won];
    } else if(message->messageType == kMessageTypeDeckID) {
        NSLog(@"Deck ID received");
        MessageDeckID * messageDeckID = (MessageDeckID*) [data bytes];
        NSLog(@"received deck ID: %s", messageDeckID->deckID);
        NSString *deckID = [[NSString alloc] initWithBytes:messageDeckID->deckID  length:10 encoding:NSUTF8StringEncoding];
        //[self.delegate receivedOpponentDeck: [NSString stringWithUTF8String: messageDeckID->deckID]];
        [self.delegate receivedOpponentDeck: deckID];
    } else if(message->messageType == kMessageTypeDeckIDReceived) {
        NSLog(@"Opponent received deck");
        [self.deckChooserDelegate opponentReceivedDeck];
    } else if(message->messageType == kMessageTypeEndTurn) {
        NSLog(@"Opponent ended turn");
        [self.gameDelegate opponentEndTurn];
    } else if (message->messageType == kMessageTypeSummonCard)
    {
        MessageSummonCard *messageSummon = (MessageSummonCard*)[data bytes];
        
        int cardIndex = messageSummon->cardIndex;
        int targetPosition = messageSummon->targetPosition;
        
        NSLog(@"opponent summoned card %d %d", cardIndex, targetPosition);
        
        [_gameDelegate opponentSummonedCard:cardIndex withTarget:targetPosition];
    }
}

-(void)processReceivedRandomNumber:(NSDictionary*)randomNumberDetails {
    //1
    if([_orderOfPlayers containsObject:randomNumberDetails]) {
        [_orderOfPlayers removeObjectAtIndex:
         [_orderOfPlayers indexOfObject:randomNumberDetails]];
    }
    //2
    [_orderOfPlayers addObject:randomNumberDetails];
    
    //3
    NSSortDescriptor *sortByRandomNumber =
    [NSSortDescriptor sortDescriptorWithKey:randomNumberKey
                                  ascending:NO];
    NSArray *sortDescriptors = @[sortByRandomNumber];
    [_orderOfPlayers sortUsingDescriptors:sortDescriptors];
    
    //4
    if ([self allRandomNumbersAreReceived]) {
        _receivedAllRandomNumbers = YES;
    }
}

- (BOOL)allRandomNumbersAreReceived
{
    NSMutableArray *receivedRandomNumbers =
    [NSMutableArray array];
    
    for (NSDictionary *dict in _orderOfPlayers) {
        [receivedRandomNumbers addObject:dict[randomNumberKey]];
    }
    
    NSArray *arrayOfUniqueRandomNumbers = [[NSSet setWithArray:receivedRandomNumbers] allObjects];
    
    if (arrayOfUniqueRandomNumbers.count ==
        [GameKitHelper sharedGameKitHelper].match.playerIDs.count + 1) {
        return YES;
    }
    return NO;
}

- (BOOL)isLocalPlayerPlayer1
{
    NSDictionary *dictionary = _orderOfPlayers[0];
    if ([dictionary[playerIdKey]
         isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
        NSLog(@"I'm player 1");
        return YES;
    }
    return NO;
}

- (NSUInteger)indexForLocalPlayer
{
    NSString *playerId = [GKLocalPlayer localPlayer].playerID;
    
    return [self indexForPlayerWithId:playerId];
}

- (NSUInteger)indexForPlayerWithId:(NSString*)playerId
{
    __block NSUInteger index = -1;
    [_orderOfPlayers enumerateObjectsUsingBlock:^(NSDictionary
                                                  *obj, NSUInteger idx, BOOL *stop){
        NSString *pId = obj[playerIdKey];
        if ([pId isEqualToString:playerId]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

- (void)sendMove {
    MessageMove messageMove;
    messageMove.message.messageType = kMessageTypeMove;
    NSData *data = [NSData dataWithBytes:&messageMove
                                  length:sizeof(MessageMove)];
    [self sendData:data];
}

- (void)sendGameEnd:(BOOL)player1Won {
    MessageGameOver message;
    message.message.messageType = kMessageTypeGameOver;
    message.player1Won = player1Won;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameOver)];
    [self sendData:data];
}

- (void)processPlayerAliases {
    if ([self allRandomNumbersAreReceived]) {
        NSMutableArray *playerAliases = [NSMutableArray arrayWithCapacity:_orderOfPlayers.count];
        for (NSDictionary *playerDetails in _orderOfPlayers) {
            NSString *playerId = playerDetails[playerIdKey];
            [playerAliases addObject:((GKPlayer*)[GameKitHelper sharedGameKitHelper].playersDict[playerId]).alias];
        }
        if (playerAliases.count > 0) {
            [self.delegate setPlayerAliases:playerAliases];
        }
    }
}


@end
