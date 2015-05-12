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
#import "UserModel.h"
@class multiplayerDataHandler;
@protocol multiplayerDataHandlerDelegate
- (void)startDownloadingOpponentDeck:(NSString *)deckID;
- (void)startLoadingMatch;
@end;

@protocol MPGameProtocol <NSObject>
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
-(NSString *)getOpponentDeckID;
-(void)sendDeckDownloadedMessage:(NSString *)msg;
@property (strong,nonatomic) NSString *opponentDeckLoaded;
@property (strong,nonatomic) NSString *opponentReady;
@property (strong,nonatomic) NSString *deckChosen;
@property (nonatomic, assign) id <multiplayerDataHandlerDelegate> delegate;
@property (nonatomic, assign) id<MPGameProtocol> gameDelegate;

-(void)sendSummonCard:(int)cardIndex withTarget:(int)targetPosition;
-(void)sendAttackCard:(int)attackerPosition withTarget:(int)targetPosition;
-(void)playerForfeit;
-(void)sendOpponentForfeit;
-(void)sendEndTurn;
@end
