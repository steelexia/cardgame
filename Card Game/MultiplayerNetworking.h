//
//  MultiplayerNetworking.h
//  cardgame
//
//  Created by Brian Allen on 2014-09-09.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "GameKitHelper.h"


@protocol MultiplayerNetworkingProtocol <NSObject>
- (void)matchEnded;
- (void)setCurrentPlayerIndex:(NSUInteger)index;
- (void)movePlayerAtIndex:(NSUInteger)index;
- (void)gameOver:(BOOL)player1Won;
- (void)setPlayerAliases:(NSArray*)playerAliases;
- (void)playersFound;
- (void)receivedOpponentDeck: (NSString*) deckID;
-(void)matchCancelled;
-(void)matchFailed:(NSError*)error;
-(void)opponentReceivedDeck;
@end


@protocol MultiplayerGameProtocol <NSObject>

-(void)setPlayerSeed:(uint32_t)seed;
-(void)setOpponentSeed:(uint32_t)seed;
-(void)opponentEndTurn;
-(void)opponentSummonedCard:(int)cardIndex withTarget:(int)target;
-(void)opponentAttackCard:(int)attackerPosition withTarget:(int)target;

@end

@interface MultiplayerNetworking : NSObject<GameKitHelperDelegate>
@property (nonatomic, assign) id<MultiplayerNetworkingProtocol> delegate;
@property (nonatomic, assign) id<MultiplayerGameProtocol> gameDelegate;

@property BOOL matchMakerPresented;
@property BOOL receivedOpponentSeed;
@property BOOL opponentReceivedSeed;
@property uint32_t playerSeed, opponentSeed;

- (void)sendMove;
- (void)sendGameEnd:(BOOL)player1Won;
- (void)sendDeckID:(NSString*)deckID;
- (void)sendReceivedDeck;
-(void)sendEndTurn;
- (BOOL)isLocalPlayerPlayer1;
-(void)sendSummonCard:(int)cardIndex withTarget:(int)targetPosition;
-(void)sendAttackCard:(int)attackerPosition withTarget:(int)targetPosition;

- (NSUInteger)indexForLocalPlayer;




@end
