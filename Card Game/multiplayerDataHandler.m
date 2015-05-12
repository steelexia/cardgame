//
//  multiplayerDataHandler.m
//  cardgame
//
//  Created by Brian Allen on 2015-04-01.
//  Copyright (c) 2015 Content Games. All rights reserved.
//

#import "multiplayerDataHandler.h"
#include <stdlib.h>

@implementation multiplayerDataHandler
@synthesize connectedParseUser;

int r;
NSInteger playerNumber;
NSString *opponentDeckID;
BOOL sentDeck = FALSE;
PNChannel *gameChannel;

+ (multiplayerDataHandler*)sharedInstance
{
    // 1
    static multiplayerDataHandler *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[multiplayerDataHandler alloc] init];
        [PubNub setDelegate:(id<PNDelegate>)self];
    });
    return _sharedInstance;
}

-(void)connectPlayer
{
    connectedParseUser = [PFUser currentUser];
    
    [PubNub setClientIdentifier:connectedParseUser.objectId];
    
    //subscribe on array of channels
    [PubNub subscribeOn:@[[PNChannel channelWithName:@"main_lobby" shouldObservePresence:YES]]];
    
}

-(NSArray *)getConnectedPlayers
{
    NSMutableArray *channelList = [[NSMutableArray alloc] init];
    [channelList addObject:[PNChannel channelWithName:@"main_lobby"]];
    
    [PubNub requestParticipantsListFor:channelList clientIdentifiersRequired:YES withCompletionBlock:^(PNHereNow *presenceInformation, NSArray *channels, PNError *error) {
        PNHereNow *thisPresenceInfo = presenceInformation;
        NSLog(@"got here get connected");
        
        
          }];
    return channelList;
    
}

-(void)sendPlayerMessage:(NSString *)msg
{
    PNChannel *mainLobbyChannel = [PNChannel channelWithName:@"main_lobby"];
    
    [PubNub sendMessage:msg toChannel:mainLobbyChannel];
}

-(void)getPlayerState
{
    [self updatePlayerState];
    
    PNChannel *mainLobbyChannel = [PNChannel channelWithName:@"main_lobby"];

    [PubNub setClientIdentifier:connectedParseUser.objectId];
    //[PubNub requestClientState:connectedParseUser.objectId forChannel:mainLobbyChannel];
    
    [PubNub requestClientState:connectedParseUser.objectId forObject:mainLobbyChannel];
}

-(void)updatePlayerState
{
    connectedParseUser = [PFUser currentUser];
    NSMutableDictionary *playerStateInfo = [[NSMutableDictionary alloc] init];
    NSNumber *playerLevel = [NSNumber numberWithInt:2];
    
    [playerStateInfo setObject:playerLevel forKey:@"playerLevel"];
    PNChannel *mainLobby = [PNChannel channelWithName:@"main_lobby"];
    
    [PubNub updateClientState:connectedParseUser.objectId state:playerStateInfo forObject:mainLobby];
    
}

-(void)setPubnubConfigDetails
{
    
    
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
                                                                  publishKey:@"pub-c-d1465391-f40c-44e3-8fc9-9d92be0a63c5" subscribeKey:@"sub-c-cac0d926-d8ab-11e4-8301-0619f8945a4f" secretKey:@"sec-c-MzAzYzM3ZGMtZjFmNC00Mjk3LTkxOTEtMTRmNzUxNDBjYzdi"];
    
    NSString *uuid = [NSString stringWithFormat:@"Mike_Stubbs"];
    [PubNub setClientIdentifier:uuid];
    configuration.presenceHeartbeatInterval = 10;
    configuration.presenceHeartbeatTimeout = 30;
    [PubNub setConfiguration:configuration];
    [PubNub connect];
    
    // #1 Define our channel name with +PNChannel+.
    gameChannel = [PNChannel channelWithName:@"demo2"
                                 shouldObservePresence:NO];
    
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self withCallbackBlock:^(NSString *origin, BOOL connected, PNError *connectionError){
        
        if (connected)
        {
            NSLog(@"OBSERVER: Successful Connection!");
            
            // #2 +subscribeOnChannel+ if the client connects successfully.
            // [PubNub subscribeOnChannel:my_channel];
            [PubNub subscribeOn:@[gameChannel]];
            
        }
        else if (!connected || connectionError)
        {
            NSLog(@"OBSERVER: Error %@, Connection Failed!", connectionError.localizedDescription);
        }
        
    }];
    [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error){
        
        switch (state) {
            case PNSubscriptionProcessSubscribedState:
            {
                // #3 enable presence if isPresenceObservationEnabledForChannel is false.
                BOOL enabled = [PubNub isPresenceObservationEnabledForChannel:gameChannel];
                NSLog(@"OBSERVER: Subscribed to Channel: %@, Presence enabled:%hhd", channels[0], enabled);
                if (!enabled) {
                    [PubNub enablePresenceObservationForChannel:gameChannel];
                }
                break;
            }
            case PNSubscriptionProcessNotSubscribedState:
                NSLog(@"OBSERVER: Not subscribed to Channel: %@, Error: %@", channels[0], error);
                break;
            case PNSubscriptionProcessWillRestoreState:
                NSLog(@"OBSERVER: Will re-subscribe to Channel: %@", channels[0]);
                break;
            case PNSubscriptionProcessRestoredState:
                NSLog(@"OBSERVER: Re-subscribed to Channel: %@", channels[0]);
                break;
        }
    }];
    
    // #4 Add the +addClientPresenceEnablingObserver+ to catch when presence has been enabled.
    [[PNObservationCenter defaultCenter] addClientPresenceEnablingObserver:self withCallbackBlock:^(NSArray *channel, PNError *error) {
        NSLog(@"OBSERVER: Enabled on Channel: %@",channel.description);
        switch(channel.count){
                
        }
    }];
    
    // #1 Add the +addPresenceEventObserver+ which will catch events received on the channel.
    [[PNObservationCenter defaultCenter] addPresenceEventObserver:self withBlock:^(PNPresenceEvent *event) {
        
        r = arc4random_uniform(3000);
        NSString *integerString = [NSString stringWithFormat:@"%d",r];
        NSString *fullGameBeginMessage = [@"Begin" stringByAppendingString:integerString];
        
        
        NSMutableDictionary *BeginMsgDict = [[NSMutableDictionary alloc] init];
        [BeginMsgDict setObject:fullGameBeginMessage forKey:@"text"];
        [BeginMsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];

        
        
        // NSLog(@"OBSERVER: Presence: %u", event.type);
        
        // #2 Add logic that sends messages to the channel based on the type of event received.
        switch (event.type) {
            case PNPresenceEventJoin:
                [PubNub sendMessage:BeginMsgDict toChannel:gameChannel];
                break;
            case PNPresenceEventLeave:
                //[PubNub sendMessage:[NSString stringWithFormat:@"%@ Says: Catch you on the flip side!",uuid ] toChannel:gameChannel ];
                break;
            case PNPresenceEventTimeout:
                //[PubNub sendMessage:[NSString stringWithFormat:@"%@ Says: Too Bad!",uuid ] toChannel:gameChannel ];
                break;
            default:
                break;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:@"case2Found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        // #3. Add logic that sends messages to the channel based on channel occupancy.
        switch (event.occupancy) {
            case 1:
               // [PubNub sendMessage:[NSString stringWithFormat:@"%@ Says: It's a ghost town.",uuid ] toChannel:gameChannel ];
                NSLog(@"occupancy 1");
                
                break;
            case 2:
                //[PubNub sendMessage:[NSString stringWithFormat:@"%@ Says: It takes two to make a thing go right.",uuid ] toChannel:gameChannel ];
               // [PubNub sendMessage:BeginMsgDict toChannel:gameChannel];
                [alert show];
                
                NSLog(@"occupancy 2");
                break;
            case 3:
                //[PubNub sendMessage:[NSString stringWithFormat:@"%@ Says: Three people is a party!" ,uuid ] toChannel:gameChannel ];
                  NSLog(@"occupancy 3");
                break;
            default:
                break;
        }
    }];
    
    
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self withBlock:^(PNMessage *message) {
         NSLog( @"%@", [NSString stringWithFormat:@"received: %@", message.message] );
         NSLog(@"this fired from the mp controller zoinks");
        
        NSDictionary *msgIncomingDict = message.message;
        NSString *msgStringVal = [msgIncomingDict objectForKey:@"text"];
        NSString *thisChannel = [msgIncomingDict objectForKey:@"channel"];
        NSString *msgSenderParseID = [msgIncomingDict objectForKey:@"msgSenderParseID"];
        
        //ignore the message if I am the sender
        if([msgSenderParseID isEqualToString:userPF.objectId])
            {
                //ignore message, don't respond
                NSLog(@"my own message, ignoring");
                return;
                
            }
        
        NSDate *msgDate = (NSDate *)message.receiveDate.date;
        
        //process the different kinds of messages based on the 5 first characters of the message
        NSString *prefix = nil;
        
        if ([msgStringVal length] >= 3)
            prefix = [msgStringVal substringToIndex:5];
        else
            prefix = msgStringVal;
        
        if([prefix isEqualToString:@"Begin"])
           {
               //get the rest of the characters to get the random seed
               NSString *seed = [msgStringVal substringFromIndex: [msgStringVal length] - 4];
               
               //convert to int value
               NSInteger seedint = [seed integerValue];
               
               //check against own seed
               if(seedint>=r)
               {
                   //I am player 1, send back they are player 2
                   
                   NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
                   [MsgDict setObject:[NSString stringWithFormat:@"Start2"] forKey:@"text"];
                   [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
                   [PubNub sendMessage:MsgDict toChannel:gameChannel];
                   playerNumber = 1;
                   
               }
               else
               {
                   //I am player 2, send back they are player 1
                   NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
                   [MsgDict setObject:[NSString stringWithFormat:@"Start1"] forKey:@"text"];
                   [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
                   [PubNub sendMessage:MsgDict toChannel:gameChannel];
                   playerNumber = 2;
               }
               
           }
        
        if([prefix isEqualToString:@"Start"])
        {
            //check the player number
            //get the rest of the characters to get the random seed
            NSString *playerNum = [msgStringVal substringFromIndex: [msgStringVal length] - 1];
            playerNumber = [playerNum integerValue];
            
            //send back deck information, they have already selected by this point
            NSString *deckID = userCurrentDeck.objectID;
            NSString *totalDeckString = [@"PDeck" stringByAppendingString:deckID];
            NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
            [MsgDict setObject:totalDeckString forKey:@"text"];
            [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
            
            
            [PubNub sendMessage:MsgDict toChannel:gameChannel ];
            
        }
        if([prefix isEqualToString:@"PDeck"])
        {
           opponentDeckID = [msgStringVal substringFromIndex:5];
        
            //if I have sent deck already, start loading sequence and send a message to start the game after loading complete
            if(sentDeck==TRUE)
            {
                //have delegate start loading sequence and tell other player to start loading sequence also
                NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
                [MsgDict setObject:@"LoadG" forKey:@"text"];
                [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
                [PubNub sendMessage:MsgDict toChannel:gameChannel ];
                
                 [self.delegate startDownloadingOpponentDeck:opponentDeckID];
            }
            
            //if I haven't sent my deck yet, send deck now
            if(sentDeck==FALSE)
            {
                //send back deck information, they have already selected by this point
                NSString *deckID = userCurrentDeck.objectID;
                NSString *totalDeckString = [@"PDeck" stringByAppendingString:deckID];
                NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
                [MsgDict setObject:totalDeckString forKey:@"text"];
                [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
                [PubNub sendMessage:MsgDict toChannel:gameChannel ];
                sentDeck=YES;
                
                //start downloading their deck
                [self.delegate startDownloadingOpponentDeck:opponentDeckID];
                
            }
        }
        if([prefix isEqualToString:@"LoadG"])
        {
            //start loading the game, both players have received the deck ID's
            
            if([self.opponentDeckLoaded isEqualToString:@"YES"])
            {
                [self.delegate startLoadingMatch];
            }
            else
            {
               //set property "opponent ready" so delegate knows to start the match immediately when finished downloading
                self.opponentReady = @"YES";
                
            }
        }
        if([prefix isEqualToString:@"ENDTR"])
        {
            [self.gameDelegate opponentEndTurn];
            
        }
        if([prefix isEqualToString:@"SUMMO"])
        {
            NSNumber *cardIndex = [msgIncomingDict objectForKey:@"cardIndex"];
            NSNumber *targetPosition = [msgIncomingDict objectForKey:@"targetPosition"];
            NSInteger cardIndexInt = [cardIndex integerValue];
            NSInteger targetPositionInt = [targetPosition integerValue];
            
            NSLog(@"opponent summoned card %ld %ld", (long)cardIndexInt, (long)targetPositionInt);
            [_gameDelegate opponentSummonedCard:cardIndexInt withTarget:targetPositionInt];
        }
        if([prefix isEqualToString:@"ATTAC"])
        {
            NSNumber *attackerPosition = [msgIncomingDict objectForKey:@"attackerPosition"];
            NSNumber *targetPosition = [msgIncomingDict objectForKey:@"targetPosition"];
            NSInteger attackerPositionInt = [attackerPosition integerValue];
            NSInteger targetPositionInt = [targetPosition integerValue];
            NSLog(@"opponent attacked card %ld %ld", (long)attackerPositionInt, (long)targetPositionInt);
            
            [_gameDelegate opponentAttackCard:attackerPositionInt withTarget:targetPositionInt];
        }
        if([prefix isEqualToString:@"FORFE"])
        {
            NSLog(@"opponent forfeit!");
            [_gameDelegate opponentForfeit];
        }
        if([prefix isEqualToString:@"GAMEO"])
            {
                NSLog(@"Game over message received");
                
                //[self.delegate gameOver:messageGameOver->player1Won];
            }
     }];
    
    
}

           /*
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
*/

-(NSString *)getOpponentDeckID
{
    return opponentDeckID;
    
}

-(void)sendDeckDownloadedMessage:(NSString *)msg
{
    NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
    [MsgDict setObject:@"LoadG" forKey:@"text"];
    [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
    [PubNub sendMessage:MsgDict toChannel:gameChannel ];
    self.opponentDeckLoaded = @"YES";

}

#pragma mark GameViewController Message Protocol Functions
//SUMMO
//NSNumber *cardIndex = [msgIncomingDict objectForKey:@"cardIndex"];
//NSNumber *targetPosition = [msgIncomingDict objectForKey:@"targetPosition"];
-(void)sendSummonCard:(int)cardIndex withTarget:(int)targetPosition
{
    NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
    [MsgDict setObject:@"SUMMO" forKey:@"text"];
    NSNumber *cardIndexNum = [NSNumber numberWithInt:cardIndex];
    NSNumber *targetPositionNum = [NSNumber numberWithInt:targetPosition];
    [MsgDict setObject:cardIndexNum forKey:@"cardIndex"];
    [MsgDict setObject:targetPositionNum forKey:@"targetPosition"];
    
    [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
    
    [PubNub sendMessage:MsgDict toChannel:gameChannel ];
}
//ATTAC
//NSNumber *attackerPosition = [msgIncomingDict objectForKey:@"attackerPosition"];
//NSNumber *targetPosition = [msgIncomingDict objectForKey:@"targetPosition"];
-(void)sendAttackCard:(int)attackerPosition withTarget:(int)targetPosition
{
    NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
    [MsgDict setObject:@"ATTAC" forKey:@"text"];
    NSNumber *attackerPositionNum = [NSNumber numberWithInt:attackerPosition];
    NSNumber *targetPositionNum = [NSNumber numberWithInt:targetPosition];
    [MsgDict setObject:attackerPositionNum forKey:@"attackerPosition"];
    [MsgDict setObject:targetPositionNum forKey:@"targetPosition"];
    [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
    
    [PubNub sendMessage:MsgDict toChannel:gameChannel ];
}

-(void)playerForfeit
{
    
}
//the player has quit the game, the other player will win
-(void)sendOpponentForfeit
{
    
}
//ENDTR
-(void)sendEndTurn
{
    NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
    [MsgDict setObject:@"ENDTR" forKey:@"text"];
    [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
    [PubNub sendMessage:MsgDict toChannel:gameChannel ];
    self.opponentDeckLoaded = @"YES";
}

@end