//
//  multiplayerDataHandler.h
//  cardgame
//
//  Created by Brian Allen on 2015-04-01.
//  Copyright (c) 2015 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNImports.h"
#import <Parse/Parse.h>
@class UserModel;

//#import "UserModel.h"

//@class multiplayerDataHandler;
@protocol multiplayerDataHandlerDelegate
- (void)startDownloadingOpponentDeck:(NSString *)deckID;
- (void)startLoadingMatch;
- (void)matchEnded;
-(void)updateStatusLabelText:(NSString *) text;
-(void)updateNumPlayersLabel:(NSString *) text;
-(void)updatePlayerLobby:(NSArray *)connectedPlayers;
-(void)chatUpdate:(NSDictionary *)chatDictionary;
-(void)notifyPlayerOfChallenge:(NSDictionary *)challengeDictionary;
-(void)dismissChallengeUI:(NSString *) reason;

-(void)notifyPlayerOfCancelChallenge;
@end;

@protocol MPGameProtocol <NSObject>
-(void)setPlayerSeed:(uint32_t)seed;
-(void)setOpponentSeed:(uint32_t)seed;
-(void)opponentEndTurn;
-(void)opponentSummonedCard:(int)cardIndex withTarget:(int)target;
-(void)opponentAttackCard:(int)attackerPosition withTarget:(int)target;
-(void)opponentForfeit;
@end


@interface multiplayerDataHandler : NSObject <PNDelegate>
+ (multiplayerDataHandler*)sharedInstance;
-(void)connectPlayer;
-(NSArray *)getConnectedPlayers;
-(void)sendPlayerMessage:(NSString *)msg;
@property PFUser *connectedParseUser;
-(void)getPlayerState;
-(void)setPubnubConfigDetails;
-(void)getPubNubConnectedPlayers;
-(void)sendStartMatch;
@property BOOL sentStartMatch;

-(NSString *)getOpponentDeckID;
-(void)sendSeedMessage:(NSString *)msg;
@property (strong,nonatomic) NSString *opponentDeckLoaded;
@property (strong,nonatomic) NSString *loadedOpponentsDeck;
@property (strong,nonatomic) NSString *opponentReady;
@property (strong,nonatomic) NSString *deckChosen;
@property (nonatomic, assign) id <multiplayerDataHandlerDelegate> delegate;
@property (nonatomic, assign) id<MPGameProtocol> gameDelegate;
@property uint32_t playerSeed, opponentSeed;
@property BOOL receivedOpponentSeed;
@property BOOL opponentReceivedSeed;
@property (strong,nonatomic) NSString *opponentIDChallenged;
@property (strong,nonatomic) PNChannel *currentMPGameChannel;
@property BOOL inChallengeProcess;
@property BOOL gameStarted;
@property int opponentEloRating;
@property NSString *opponentID;

@property (strong,nonatomic) PNChannel *quickMatchChannel;
@property BOOL quickMatchLock;
@property BOOL firstQuickMatchEnabled;

-(void)sendSummonCard:(int)cardIndex withTarget:(int)targetPosition;
-(void)sendAttackCard:(int)attackerPosition withTarget:(int)targetPosition;
-(void)playerForfeit;
-(void)sendOpponentForfeit;
-(void)sendEndTurn;
-(void)gameOver:(int)winner;
-(void)sendChatWithDict:(NSDictionary *)Dict;
-(void)sendChallengeToPlayerObj:(NSDictionary *)Dict;
-(void)acceptChallenge:(NSString *)challengerID;
-(void)rejectChallenge:(NSString *)challengerID withReason:(NSString *)reason;
-(void)cancelChallenge;
-(void)handlePlayerVictory;
-(void)handlePlayerDefeat;
-(void)resetAllMPVariables;
-(void)joinQuickMatchChannel;

@end
