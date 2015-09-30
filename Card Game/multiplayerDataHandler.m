    //
//  multiplayerDataHandler.m
//  cardgame
//
//  Created by Brian Allen on 2015-04-01.
//  Copyright (c) 2015 Content Games. All rights reserved.
//

#import "multiplayerDataHandler.h"
#include <stdlib.h>
#import "GameModel.h"

@implementation multiplayerDataHandler
@synthesize connectedParseUser;

int randomSeed;
NSInteger playerNumber;
NSString *opponentDeckID;
BOOL sentDeck = FALSE;
PNChannel *gameChannel;
PNChannel *chatChannel;
NSTimer *challengeLockTimer;
NSTimer *firstChallengeTimer;

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

-(void)sendStartMatch
{
    randomSeed = arc4random_uniform(3000);
    NSString *integerString = [NSString stringWithFormat:@"%d",randomSeed];
    NSString *fullGameBeginMessage = [@"Begin" stringByAppendingString:integerString];
    
    NSMutableDictionary *BeginMsgDict = [[NSMutableDictionary alloc] init];
    [BeginMsgDict setObject:fullGameBeginMessage forKey:@"text"];
    [BeginMsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
    
    [PubNub sendMessage:BeginMsgDict toChannel:self.currentMPGameChannel];
    
}

-(void)setPubnubConfigDetails
{
    [PNLogger loggerEnabled:FALSE];
    
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
                                                                  publishKey:@"pub-c-d1465391-f40c-44e3-8fc9-9d92be0a63c5" subscribeKey:@"sub-c-cac0d926-d8ab-11e4-8301-0619f8945a4f" secretKey:@"sec-c-MzAzYzM3ZGMtZjFmNC00Mjk3LTkxOTEtMTRmNzUxNDBjYzdi"];
    
    NSString *uuid = userPF.objectId;
    [PubNub setClientIdentifier:uuid];
    configuration.presenceHeartbeatInterval = 10;
    configuration.presenceHeartbeatTimeout = 30;
    [PubNub setConfiguration:configuration];
    [PubNub connect];
   
    // #1 Define our channel name with +PNChannel+.
    gameChannel = [PNChannel channelWithName:@"main_lobby"
                                 shouldObservePresence:YES];
    
    chatChannel = [PNChannel channelWithName:@"chat" shouldObservePresence:YES];
    
    
    
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self withCallbackBlock:^(NSString *origin, BOOL connected, PNError *connectionError){
        
        if (connected)
        {
            NSLog(@"OBSERVER: Successful Connection!");
            
            // #2 +subscribeOnChannel+ if the client connects successfully.
            // [PubNub subscribeOnChannel:my_channel];
            //[PubNub subscribeOn:@[gameChannel]];
            NSNumber *eloVal = [userPF objectForKey:@"eloRating"];
            NSString *userName = userPF.username;
            
            
            /*
            [PubNub subscribeOn:@[gameChannel] withClientState:@{@"eloRating": eloVal,
                                                                 @"username": userName,
                                                                 @"gameState": @"In Lobby"
                                                                 }];
             */
            NSMutableDictionary *clientStateMutable = [[NSMutableDictionary alloc] init];
            [clientStateMutable setObject:eloVal forKey:@"eloRating"];
            [clientStateMutable setObject:userName forKey:@"usernameCustom"];
            [clientStateMutable setObject:userPF.objectId forKey:@"userID"];
            [clientStateMutable setObject:@"Lobby" forKey:@"gameState"];
            NSDictionary *myDict = [clientStateMutable copy];
            
            [PubNub subscribeOn:@[gameChannel,chatChannel] withClientState:myDict
             andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
                //
                if(error)
                {
                    NSLog(error.localizedDescription);
                    
                }
                 else
                 {
                     //inspect state variable
                     NSLog(@"subscribe success");
                     [PubNub updateClientState:userPF.objectId state:myDict forObject:gameChannel withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
                         if(error)
                         {
                             NSLog(error.localizedDescription);
                             
                         }
                         else
                         {
                             NSLog(@"success updating state");
                             //update channel info
                             //[self getPubNubConnectedPlayers];
                             
                         }
                     }];
                 }
               
                
            }];
            
            
            
            
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
                BOOL enabled = [PubNub isPresenceObservationEnabledFor:gameChannel];
                
                NSLog(@"OBSERVER: Subscribed to Channel: %@, Presence enabled:%hhd", channels[0], enabled);
                if (!enabled) {
                    NSMutableArray *channelsToObserve = [[NSMutableArray alloc] init];
                    [channelsToObserve addObject:gameChannel];
                    
                    [PubNub enablePresenceObservationFor:channelsToObserve];
                     BOOL nowenabled = [PubNub isPresenceObservationEnabledFor:gameChannel];
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
    
    
    [[PNObservationCenter defaultCenter] addChannelParticipantsListProcessingObserver:self withBlock:^(PNHereNow *presenceInformation, NSArray *channels, PNError *error) {
        
        NSArray *participantsOnGameLobby = [presenceInformation participantsForChannel:gameChannel];
        for(PNClient *heldClient in participantsOnGameLobby)
        {
            NSDictionary *channelState = [heldClient stateForChannel:gameChannel];
            
        }
    }];
    
    // #1 Add the +addPresenceEventObserver+ which will catch events received on the channel.
    [[PNObservationCenter defaultCenter] addPresenceEventObserver:self withBlock:^(PNPresenceEvent *event) {
        
        
        [self getPubNubConnectedPlayers];
        // NSLog(@"OBSERVER: Presence: %u", event.type);
        if(event.channel == self.currentMPGameChannel)
        {
            switch (event.occupancy) {
                case 1:
                    // [PubNub sendMessage:[NSString stringWithFormat:@"%@ Says: It's a ghost town.",uuid ] toChannel:gameChannel ];
                    NSLog(@"occupancy 1");
                    break;
                case 2:
                    NSLog(@"occupancy 2");
                    //send start message
                    if([self.opponentIDChallenged length]>0)
                    {
                       if(!self.sentStartMatch)
                       {
                           //I am challenger, send game start
                           [self sendStartMatch];
                           self.sentStartMatch = TRUE;
                           self.gameStarted = YES;
                       }
                      
                        
                    }
                    break;
                case 3:
                    NSLog(@"occupancy 3");
                    
                    break;
                default:
                    break;
            }
        

        }
        // #2 Add logic that sends messages to the channel based on the type of event received.
        switch (event.type) {
            case PNPresenceEventJoin:
                
                break;
            case PNPresenceEventLeave:
                //[PubNub sendMessage:[NSString stringWithFormat:@"%@ Says: Catch you on the flip side!",uuid ] toChannel:gameChannel ];
                if(event.channel == self.currentMPGameChannel && self.gameStarted ==YES)
                {
                    //declare self winner on game controller delegate function.
                    NSLog(@"Other Player Timed Out");
                    [self.gameDelegate opponentForfeit];
                    
                }

                break;
            case PNPresenceEventTimeout:
                //[PubNub sendMessage:[NSString stringWithFormat:@"%@ Says: Too Bad!",uuid ] toChannel:gameChannel ];
               
                //if the game has started already, interpret this as a forfeit and give the player the win.
                if(event.channel == self.currentMPGameChannel && self.gameStarted ==YES)
                {
                    //declare self winner on game controller delegate function.
                    NSLog(@"Other Player Timed Out");
                    [self.gameDelegate opponentForfeit];
                    
                }
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
                [self.delegate updateNumPlayersLabel:@"1 Player"];
                
                break;
            case 2:
                //[PubNub sendMessage:[NSString stringWithFormat:@"%@ Says: It takes two to make a thing go right.",uuid ] toChannel:gameChannel ];
               // [PubNub sendMessage:BeginMsgDict toChannel:gameChannel];
                //[alert show];
                
                NSLog(@"occupancy 2");
                [self.delegate updateNumPlayersLabel:@"2 Players, Start Match When Ready"];
                break;
            case 3:
                //[PubNub sendMessage:[NSString stringWithFormat:@"%@ Says: Three people is a party!" ,uuid ] toChannel:gameChannel ];
                  NSLog(@"occupancy 3");
                [self.delegate updateNumPlayersLabel:@"3 Players, Error"];
                break;
            default:
                break;
        }
    }];
    
    
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self withBlock:^(PNMessage *message) {
         NSLog( @"%@", [NSString stringWithFormat:@"received: %@", message.message] );
         NSLog(@"this fired from the mp controller zoinks");
        
        NSDictionary *msgIncomingDict = message.message;
        NSString *thisChannel = [msgIncomingDict objectForKey:@"channel"];
        
        /*
         quick match challenge object details
        [quickMatchMsgDict setObject:userIDJustJoined forKey:@"qmOpponentID"];
        [quickMatchMsgDict setObject:userID forKey:@"challengingUserID"];
        [quickMatchMsgDict setObject:@"quickMatch" forKey:@"channel"];
        [quickMatchMsgDict setObject:@"qmCHG" forKey:@"msgType"];
        [quickMatchMsgDict setObject:eloRating forKey:@"eloRating"];
        */
        
        if([thisChannel isEqualToString:@"quickMatch"])
        {
            //check for receiving a challenge
            NSString *msgType = [msgIncomingDict objectForKey:@"msgType"];
            NSString *myUserID = [PFUser currentUser].objectId;
            
            if([msgType isEqualToString:@"qmCHG"] )
            {
                NSString *challengedUserID = [msgIncomingDict objectForKey:@"qmOpponentID"];
                NSString *challengerID = [msgIncomingDict objectForKey:@"challengingUserID"];
                
                if([challengedUserID isEqualToString:myUserID])
                    {
                    //received a challenge!
                    //make sure player isn't already in a challenge
                        if([self.opponentID length] ==0)
                        {
                            self.opponentID = challengerID;
                            
                            //join a channel with the two users
                            [self acceptChallenge:challengerID];
                        
                            //send a message when joined to start the game
                            
                            
                        }
                        
                    }
            }
            /*
            [quickMatchMsgDict setObject:userID forKey:@"userID"];
            [quickMatchMsgDict setObject:@"quickMatch" forKey:@"channel"];
            [quickMatchMsgDict setObject:@"qmJOIN" forKey:@"msgType"];
            [quickMatchMsgDict setObject:eloRating forKey:@"eloRating"];
             */
            if([msgType isEqualToString:@"qmJOIN"])
            {
                //always try to send the challenge, it will prevent the user if the lock is not enabled or they already have an opponentID
                NSString *joinedUser= [msgIncomingDict objectForKey:@"userID"];
                
                [self sendQuickMatchChallenge:joinedUser];
                
            }
        }
        
        if([thisChannel isEqualToString:@"chat"])
        {
            NSString *chatMessage = [msgIncomingDict objectForKey:@"messageText"];
            NSString *userName = [msgIncomingDict objectForKey:@"userName"];
            NSDate *chatTime = [msgIncomingDict objectForKey:@"chatMsgDate"];
            //send this to the delegate to add to its array of messages
            [self.delegate chatUpdate:msgIncomingDict];
            
            return;
        }
        
        if([thisChannel isEqualToString:@"main_lobby"])
        {
           /*
            //object structure
            [challengeMsgDict setObject:userID forKey:@"userID"];
            [challengeMsgDict setObject:@"chgStart" forKey:@"chgText"];
            [challengeMsgDict setObject:username forKey:@"chgUserName"];
            [challengeMsgDict setObject:user.objectId forKey:@"chgUserID"];
            [challengeMsgDict setObject:@"challenge" forKey:@"channel"];
              [challengeMsgDict setObject:eloRatingString forKey:@"eloRatingChallenger"];
            */
            
            NSString *msgType = [msgIncomingDict objectForKey:@"msgType"];
            
            //handle challenge message types
            if([msgType isEqualToString:@"challenge"])
            {
                NSString *userIDBeingChallenged = [msgIncomingDict objectForKey:@"userID"];
                NSString *ownUserID = [PFUser currentUser].objectId;
                
                if([userIDBeingChallenged isEqualToString:ownUserID])
                {
                    //someone challenged you, display a popup announcing it.
                    
                    if(self.inChallengeProcess)
                    {
                        NSString *chgUserID = [msgIncomingDict objectForKey:@"chgUserID"];
                        
                        //notify challenger you are busy!
                        [self rejectChallenge:chgUserID withReason:@"Already Challenging/In Challenge"];
                        
                    }
                    else
                    {
                        self.inChallengeProcess = YES;
                        NSNumber *challengerEloRating = [msgIncomingDict objectForKey:@"eloRatingNum"];
                        
                        self.opponentEloRating = [challengerEloRating intValue];
                        self.opponentID = [msgIncomingDict objectForKey:@"chgUserID"];
                        
                        [self.delegate notifyPlayerOfChallenge:msgIncomingDict];
                    }
                    return;
                    
                }
                else
                {
                    return;
                    
                }

            }
            else if([msgType isEqualToString:@"challengeAccept"])
            {
                NSString *userIDOfChallengeAccept = [msgIncomingDict objectForKey:@"challengeAcceptID"];
                NSString *opponentAccepting = [msgIncomingDict objectForKey:@"accepterID"];
                //self.opponentID = opponentAccepting;
                
                NSString *ownUserID = [PFUser currentUser].objectId;
                if([userIDOfChallengeAccept isEqualToString:ownUserID] && [opponentAccepting isEqualToString:self.opponentIDChallenged])
                {
                    
                    //join a channel with the ids of the two users and start loading the match
                    //startID Challenger secondID challengee
                    NSString *fullChannelName = [ownUserID stringByAppendingString:self.opponentIDChallenged];
                    self.currentMPGameChannel = [PNChannel channelWithName:fullChannelName
                                       shouldObservePresence:YES];
                    
                    
                    [PubNub subscribeOn:@[self.currentMPGameChannel] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
                      
                        //do nothing, start event will be fired by occupancy 2 only by challenger
                        return;
                        
                    }];
                    
                    
                }
    
                else
                {
                    return;
                    
                }
                
            }
            else if([msgType isEqualToString:@"challengeReject"])
            {
                NSString *userIDOfChallengeReject = [msgIncomingDict objectForKey:@"challengeRejectID"];
                NSString *reason = [msgIncomingDict objectForKey:@"reason"];
                
                NSString *ownUserID = [PFUser currentUser].objectId;
                if([userIDOfChallengeReject isEqualToString:ownUserID])
                {
                    //dismiss challenge UI and reset variables
                    self.opponentIDChallenged = @"";
                    [self.delegate dismissChallengeUI:reason];
                    self.inChallengeProcess = NO;
                    
                }
                else
                {
                    return;
                    
                }

            }
            else if([msgType isEqualToString:@"challengeCancel"])
            {
                NSString *userIDOfChallengeReject = [msgIncomingDict objectForKey:@"challengeCancelID"];
                NSString *ownUserID = [PFUser currentUser].objectId;
                if([userIDOfChallengeReject isEqualToString:ownUserID])
                {
                    //notify player being challenged the challenge was cancelled
                    [self.delegate notifyPlayerOfCancelChallenge];
                     self.inChallengeProcess = NO;
                }
                else
                {
                    return;
                    
                }

            }
        }

        NSString *msgStringVal = [msgIncomingDict objectForKey:@"text"];
      
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
               NSLog(@"Received Begin");
               [self.delegate updateStatusLabelText:@"Received Begin"];
               self.gameStarted = YES;
               
               
               //get the rest of the characters to get the random seed
               NSString *seed = [msgStringVal substringFromIndex: [msgStringVal length] - 4];
               
               //convert to int value
               NSInteger seedint = [seed integerValue];
               //worst code ever to just quick hack not getting a tie..
               if(randomSeed ==0)
               {
                   randomSeed = arc4random_uniform(3000);
               }
               if(seedint==randomSeed)
               {
                   randomSeed = arc4random_uniform(3000);
               }
               if(seedint ==randomSeed)
               {
                   randomSeed = arc4random_uniform(3000);
               }
               
               //check against own seed
               if(seedint<=randomSeed)
               {
                   //I am player 1, send back they are player 2
                   
                   NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
                   [MsgDict setObject:[NSString stringWithFormat:@"Start2"] forKey:@"text"];
                   [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
                   [PubNub sendMessage:MsgDict toChannel:self.currentMPGameChannel];
                   playerNumber = 1;
                   NSLog(@"setting self player 1");
               }
               else
               {
                   //I am player 2, send back they are player 1
                   NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
                   [MsgDict setObject:[NSString stringWithFormat:@"Start1"] forKey:@"text"];
                   [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
                   [PubNub sendMessage:MsgDict toChannel:self.currentMPGameChannel];
                   playerNumber = 2;
                   NSLog(@"setting self player 2");
               }
               
           }
        
        if([prefix isEqualToString:@"Start"])
        {
            NSLog(@"Received Start");
            
            [self.delegate updateStatusLabelText:@"Received Start"];
            //check the player number
            //get the rest of the characters to get the random seed
            NSString *playerNum = [msgStringVal substringFromIndex: [msgStringVal length] - 1];
            playerNumber = [playerNum integerValue];
            
            //TODO--update to send back deck information and random seed information at same time
            NSString *deckID = userCurrentDeck.objectID;
            NSString *totalDeckString = [@"PDeck" stringByAppendingString:deckID];
            NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
            [MsgDict setObject:totalDeckString forKey:@"text"];
            [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
            
            sentDeck=TRUE;
            [PubNub sendMessage:MsgDict toChannel:self.currentMPGameChannel ];
            
        }
        if([prefix isEqualToString:@"PDeck"])
        {
                        
            NSLog(@"ReceivedPDeck");
            
            [self.delegate updateStatusLabelText:@"Received PDECK"];
            opponentDeckID = [msgStringVal substringFromIndex:5];
        
            //if I have sent deck already, start loading sequence and send a message to start the game after loading complete
            if(sentDeck==TRUE)
            {
                NSLog(@"Starting Deck Download");
                      
                [self.delegate updateStatusLabelText:@"Starting Deck Download"];
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
                [PubNub sendMessage:MsgDict toChannel:self.currentMPGameChannel ];
                sentDeck=YES;
                 NSLog(@"Sending Deck & Starting Deck Download");
                [self.delegate updateStatusLabelText:@"Sending Deck"];
                //start downloading their deck
                [self.delegate startDownloadingOpponentDeck:opponentDeckID];
                
            }
           
            
        }
        
        
        if([prefix isEqualToString:@"LoadG"])
        {
            NSLog(@"Received LoadG");
            [self.delegate updateStatusLabelText:@"Received LoadG"];
            //start loading the game, both players have received the deck ID's
            if(self.opponentReceivedSeed && self.receivedOpponentSeed)
            {
                //continue
            }
            else
            {
                [self.delegate updateStatusLabelText:@"Error With Seeds"];
                NSLog(@"error with seeds");
                return;
                
            }
            
            [self.delegate startLoadingMatch];
            
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
        if([prefix isEqualToString:@"SeedR"])
        {
            NSLog(@"received seedR");
            [self.delegate updateStatusLabelText:@"Received SeedR"];
            //extract seed message
            //get the rest of the characters to get the random seed
            NSString *seed = [msgStringVal substringFromIndex:5];
            
            //convert to int value
           int seedint = [seed intValue];
            
            _receivedOpponentSeed = YES;
            //[_gameDelegate setOpponentSeed:messageRandomNumber->seed];
            
            _opponentSeed = seedint;
            
           
            
            //send seed received
            [self sendSeedReceived];
            
        }
        if([prefix isEqualToString:@"GotSd"])
        {
            NSLog(@"Received GotSD");
            
            [self.delegate updateStatusLabelText:@"Received GotSD"];
            self.opponentReceivedSeed = YES;
            
            if(self.receivedOpponentSeed ==YES)
            {
                //start the match with LOADG Message
                
                 NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
                 [MsgDict setObject:@"LoadG" forKey:@"text"];
                 [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
                 [PubNub sendMessage:MsgDict toChannel:self.currentMPGameChannel ];
                
                 [self.delegate startLoadingMatch];
            }
            else
            {
                //waiting for opponent to start the match and send LoadG
            }
            
            
        }
     }];
    
    
}

-(void)getPubNubConnectedPlayers
{
    
    [PubNub requestParticipantsListFor:@[gameChannel] clientIdentifiersRequired:YES clientState:YES withCompletionBlock:^(PNHereNow *presenceInformation, NSArray *channels, PNError *error) {
        NSArray *participants = [presenceInformation participantsForChannel:gameChannel];
        
        NSLog(@"got participants");
        NSLog(@"%ld",participants.count);
        NSMutableArray *playerArray = [[NSMutableArray alloc] init];
        
        for(PNClient *heldClient in participants)
        {
          NSDictionary *stateInChannel = [heldClient stateForChannel:gameChannel];
            if(stateInChannel !=nil && ![[stateInChannel objectForKey:@"usernameCustom"] isEqual:userPF.username])
            {
                 [playerArray addObject:stateInChannel];
            }
           
            
        }
        [self.delegate updatePlayerLobby:[playerArray copy]];
        NSLog(@"got here");

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



-(void)sendLoadGameMessage:(NSString *)msg
{
    NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
    [MsgDict setObject:@"LoadG" forKey:@"text"];
    [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
    [PubNub sendMessage:MsgDict toChannel:self.currentMPGameChannel ];
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
    
    int target = [GameModel getReversedPosition:targetPosition];
    NSNumber *targetPositionNum = [NSNumber numberWithInt:target];
    [MsgDict setObject:cardIndexNum forKey:@"cardIndex"];
    [MsgDict setObject:targetPositionNum forKey:@"targetPosition"];
    
    [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
    
    [PubNub sendMessage:MsgDict toChannel:self.currentMPGameChannel ];
}
//ATTAC
//NSNumber *attackerPosition = [msgIncomingDict objectForKey:@"attackerPosition"];
//NSNumber *targetPosition = [msgIncomingDict objectForKey:@"targetPosition"];
-(void)sendAttackCard:(int)attackerPosition withTarget:(int)targetPosition
{
    NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
    [MsgDict setObject:@"ATTAC" forKey:@"text"];
    
    int attacker = [GameModel getReversedPosition:attackerPosition];
    int target = [GameModel getReversedPosition:targetPosition];
    
    NSNumber *attackerPositionNum = [NSNumber numberWithInt:attacker];
    NSNumber *targetPositionNum = [NSNumber numberWithInt:target];
    [MsgDict setObject:attackerPositionNum forKey:@"attackerPosition"];
    [MsgDict setObject:targetPositionNum forKey:@"targetPosition"];
    [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
    
    [PubNub sendMessage:MsgDict toChannel:self.currentMPGameChannel ];
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
    [PubNub sendMessage:MsgDict toChannel:self.currentMPGameChannel ];
    self.opponentDeckLoaded = @"YES";
}
-(void)sendSeedMessage:(NSString *)msg
{
    [self sendSeed];
    
}

-(void)sendSeed
{
   
    //only send if opponent hasn't received it
    if(!self.opponentReceivedSeed)
    
    {
    NSString *seedSend = [@"SeedR" stringByAppendingString:[NSString stringWithFormat:@"%d",randomSeed]];
    NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
    [MsgDict setObject:seedSend forKey:@"text"];
    [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
    [PubNub sendMessage:MsgDict toChannel:self.currentMPGameChannel ];
    _playerSeed = randomSeed;
    }
}

-(void)sendSeedReceived
{
    NSString *gotSeed = @"GotSd";
    NSMutableDictionary *MsgDict = [[NSMutableDictionary alloc] init];
    [MsgDict setObject:gotSeed forKey:@"text"];
    [MsgDict setObject:userPF.objectId forKey:@"msgSenderParseID"];
    [PubNub sendMessage:MsgDict toChannel:self.currentMPGameChannel ];

}

-(void)gameOver:(int)winner
{
    
    if (winner == PLAYER_SIDE)
    {
        //TODO
        
    }
    else if (winner == PLAYER_SIDE)
    {
        //TODO
        
    }
    else
    {
        //TODO
    }
    
    //[_gameKitHelper.match disconnect];
    //TODO--Disconnect Players on Pubnub
    
    [_delegate matchEnded];
    
}

-(void)sendChatWithDict:(NSDictionary *)Dict
{
 [PubNub sendMessage:Dict toChannel:chatChannel];
}

-(void)sendChallengeToPlayerObj:(NSDictionary *)Dict
{
    NSMutableDictionary *challengeMsgDict = [[NSMutableDictionary alloc] init];
    
    //Dict is a player object with username, userID, elo rating, and gamestate set at time of connection
    
    /*
    [clientStateMutable setObject:eloVal forKey:@"eloRating"];
    [clientStateMutable setObject:userName forKey:@"usernameCustom"];
    [clientStateMutable setObject:userObj.objectId forKey:@"userID"];
    [clientStateMutable setObject:@"Lobby" forKey:@"gameState"];
     */
    self.opponentEloRating = [[Dict objectForKey:@"eloRating"] intValue];
    self.opponentID = [Dict objectForKey:@"userID"];
    
    NSString *userID = [Dict objectForKey:@"userID"];
    
    PFUser *user = [PFUser currentUser];
    NSString *username = user.username;
    NSNumber *eloRating = [user objectForKey:@"eloRating"];
    NSString *eloRatingString = [eloRating stringValue];
    self.opponentIDChallenged = userID;
    
    [challengeMsgDict setObject:userID forKey:@"userID"];
    [challengeMsgDict setObject:@"chgStart" forKey:@"chgText"];
    [challengeMsgDict setObject:username forKey:@"chgUserName"];
    [challengeMsgDict setObject:user.objectId forKey:@"chgUserID"];
    [challengeMsgDict setObject:@"main_lobby" forKey:@"channel"];
     [challengeMsgDict setObject:@"challenge" forKey:@"msgType"];
    [challengeMsgDict setObject:eloRatingString forKey:@"eloRatingChallenger"];
    [challengeMsgDict setObject:eloRating forKey:@"eloRatingNum"];
    
     self.inChallengeProcess = YES;
    
    [PubNub sendMessage:challengeMsgDict toChannel:gameChannel];
    
}

-(void)acceptChallenge:(NSString *)challengerID
{
    NSMutableDictionary *challengeAcceptMsgDict = [[NSMutableDictionary alloc] init];
    PFUser *currentUser = [PFUser currentUser];
    NSString *myID = currentUser.objectId;
    [challengeAcceptMsgDict setObject:challengerID forKey:@"challengeAcceptID"];
    [challengeAcceptMsgDict setObject:@"main_lobby" forKey:@"channel"];
    [challengeAcceptMsgDict setObject:@"challengeAccept" forKey:@"msgType"];
    [challengeAcceptMsgDict setObject:myID forKey:@"accepterID"];
    
      NSString *ownUserID = [PFUser currentUser].objectId;
    
    NSString *fullChannelName = [challengerID stringByAppendingString:ownUserID];
    self.currentMPGameChannel = [PNChannel channelWithName:fullChannelName
                                     shouldObservePresence:YES];
    
    [PubNub subscribeOn:@[self.currentMPGameChannel] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        
        //set opponent elo rating
        
        //do nothing, start event will be fired by occupancy 2 only by challenger
         [PubNub sendMessage:challengeAcceptMsgDict toChannel:gameChannel];
        
    }];

    
}

-(void)rejectChallenge:(NSString *)challengerID withReason:(NSString *)reason
{
    NSMutableDictionary *challengeRejectMsgDict = [[NSMutableDictionary alloc] init];
    
    [challengeRejectMsgDict setObject:challengerID forKey:@"challengeRejectID"];
    [challengeRejectMsgDict setObject:@"main_lobby" forKey:@"channel"];
    [challengeRejectMsgDict setObject:@"challengeReject" forKey:@"msgType"];
    [challengeRejectMsgDict setObject:reason forKey:@"reason"];
    
     [PubNub sendMessage:challengeRejectMsgDict toChannel:gameChannel];
     self.inChallengeProcess = NO;
}

-(void)cancelChallenge
{
    NSMutableDictionary *challengeCancelMsgDict = [[NSMutableDictionary alloc] init];
    
    [challengeCancelMsgDict setObject:self.opponentIDChallenged forKey:@"challengeCancelID"];
    [challengeCancelMsgDict setObject:@"main_lobby" forKey:@"channel"];
    [challengeCancelMsgDict setObject:@"challengeCancel" forKey:@"msgType"];
    
    [PubNub sendMessage:challengeCancelMsgDict toChannel:gameChannel];
     self.inChallengeProcess = NO;
}

-(void)handlePlayerVictory
{
    //save eloRating of self and opponent as variables at time of match start..
    NSNumber *selfEloRating = [[PFUser currentUser] objectForKey:@"eloRating"];
    NSNumber *opponentEloRating = [NSNumber numberWithInt:self.opponentEloRating];
     NSError* error;
    [PFCloud callFunction:@"mpMatchComplete" withParameters:@{
                                                              @"User1" : [PFUser currentUser].objectId, @"User2" :self.opponentID, @"User1Rating" :selfEloRating,@"User2Rating": opponentEloRating
                                                              } error:&error];
    if (!error){
        [userPF fetch];
        
        NSNumber *newSelfEloRating =  [userPF objectForKey:@"eloRating"];
        NSLog(@"New eloRating: %@", newSelfEloRating);
    }
    /*[PFCloud callFunctionInBackground:@"mpMatchComplete" withParameters:@{
                                                                         @"User1" : [PFUser currentUser].objectId, @"User2" :self.opponentID, @"User1Rating" :selfEloRating,@"User2Rating": opponentEloRating
                                                                         }
                                                        block:^(id object, NSError *error) {
                                                                             //code
                                                            NSLog(@"Error: %@",error.description);
                                                        }];*/
}

-(void)handlePlayerDefeat
{
    //save eloRating of self and opponent as variables at time of match start..
    NSNumber *selfEloRating = [[PFUser currentUser] objectForKey:@"eloRating"];
    NSNumber *opponentEloRating = [NSNumber numberWithInt:self.opponentEloRating];
    NSError* error;
   
    [PFCloud callFunction:@"mpMatchComplete" withParameters:@{
                                                              @"User1" :self.opponentID , @"User2" :[PFUser currentUser].objectId, @"User1Rating" :opponentEloRating ,@"User2Rating": selfEloRating
                                                              } error:&error];
    if (!error){
        [userPF fetch];
        
        NSNumber *newSelfEloRating =  [userPF objectForKey:@"eloRating"];
        NSLog(@"New eloRating: %@", newSelfEloRating);
    }
    /*[PFCloud callFunctionInBackground:@"mpMatchComplete" withParameters:@{
     @"User1" : [PFUser currentUser].objectId, @"User2" :self.opponentID, @"User1Rating" :selfEloRating,@"User2Rating": opponentEloRating
     }
     block:^(id object, NSError *error) {
     //code
     NSLog(@"Error: %@",error.description);
     }];*/
}

-(void)resetAllMPVariables
{
    self.opponentEloRating = 0;
    self.opponentID = 0;
    self.opponentIDChallenged = 0;
    
    if(self.currentMPGameChannel !=nil)
    {
        
    NSMutableArray *channelsToLeave = [[NSMutableArray alloc] init];
    [channelsToLeave addObject:self.currentMPGameChannel];
        if(self.quickMatchChannel !=nil)
        {
            [channelsToLeave addObject:self.quickMatchChannel];
            
        }
    
    //leave game channel
    [PubNub unsubscribeFrom:channelsToLeave withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
        NSLog(@"unsubscribe success");
         self.currentMPGameChannel = nil;
        self.quickMatchChannel = nil;
        
    }];
    }
    
    
   
}

-(void)joinQuickMatchChannel
{
    if(self.quickMatchChannel !=nil)
    {
        return;
        
    }
    self.inChallengeProcess = TRUE;
    self.opponentID = @"";
    
    self.quickMatchChannel = [PNChannel channelWithName:@"quickMatch"
                                     shouldObservePresence:YES];
    NSString *userID = [PFUser currentUser].objectId;
    NSNumber *eloRating = [[PFUser currentUser] objectForKey:@"eloRating"];
    
    NSMutableDictionary *quickMatchMsgDict = [[NSMutableDictionary alloc] init];
    
    [quickMatchMsgDict setObject:userID forKey:@"userID"];
    [quickMatchMsgDict setObject:@"quickMatch" forKey:@"channel"];
    [quickMatchMsgDict setObject:@"qmJOIN" forKey:@"msgType"];
    [quickMatchMsgDict setObject:eloRating forKey:@"eloRating"];
    
    
[PubNub subscribeOn:@[self.quickMatchChannel] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
    
    //start a timer, after this timer expires the user can fire their first quickMatchChallenge if they didn't get challenged first
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    challengeLockTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(firstChallengeTimer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:challengeLockTimer forMode:NSRunLoopCommonModes];
    
    [PubNub sendMessage:quickMatchMsgDict toChannel:self.quickMatchChannel];
    
}];
}

-(void)sendQuickMatchChallenge:(NSString *)userIDJustJoined
{
    //lock out the player for 4 seconds until they see if they get a response or not from the user they challenge.  If no response, then their lock is reset and they can send a quick match challenge to another user who joins.
    //If they get a response, their lock remains
    
    //if already challenged, don't allow to send out challenges
    if([self.opponentID length] >0)
    {
        return;
        
    }
    
    if(self.firstQuickMatchEnabled ==FALSE)
    {
        return;
        
    }
    
     NSString *userID = [PFUser currentUser].objectId;
     NSNumber *eloRating = [[PFUser currentUser] objectForKey:@"eloRating"];
    if(self.quickMatchLock ==FALSE)
    {
        //send the challenge
        //lock quick match
        self.quickMatchLock =TRUE;
        self.opponentIDChallenged = userIDJustJoined;
        
        NSMutableDictionary *quickMatchMsgDict = [[NSMutableDictionary alloc] init];
        
        [quickMatchMsgDict setObject:userIDJustJoined forKey:@"qmOpponentID"];
        [quickMatchMsgDict setObject:userID forKey:@"challengingUserID"];
        [quickMatchMsgDict setObject:@"quickMatch" forKey:@"channel"];
        [quickMatchMsgDict setObject:@"qmCHG" forKey:@"msgType"];
        [quickMatchMsgDict setObject:eloRating forKey:@"eloRating"];
        
        [PubNub sendMessage:quickMatchMsgDict toChannel:self.quickMatchChannel];
    }
    
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    challengeLockTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(UpdateChallengeLock) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:challengeLockTimer forMode:NSRunLoopCommonModes];
    
}

-(void)UpdateChallengeLock
{
    NSLog(@"update challenge lock enabled to false");
    
    //player can challenge the next user joining
    self.quickMatchLock = FALSE;
    self.opponentIDChallenged = @"";
    
}

-(void)firstChallengeTimer
{
    NSLog(@"user allowed to send first quick match challenge");
    
    self.firstQuickMatchEnabled = TRUE;
    
}

@end
