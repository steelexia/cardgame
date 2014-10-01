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
@end

@protocol MultiplayerDeckChooserProtocol <NSObject>

-(void)opponentReceivedDeck;

@end

@protocol MultiplayerGameProtocol <NSObject>

@end

@interface MultiplayerNetworking : NSObject<GameKitHelperDelegate>
@property (nonatomic, assign) id<MultiplayerNetworkingProtocol> delegate;
@property (nonatomic, assign) id<MultiplayerDeckChooserProtocol> deckChooserDelegate;
@property (nonatomic, assign) id<MultiplayerGameProtocol> gameDelegate;

@property BOOL matchMakerPresented;
@property BOOL seedReceived;

- (void)sendMove;
- (void)sendGameEnd:(BOOL)player1Won;
- (void)sendDeckID:(NSString*)deckID;
- (void)sendReceivedDeck;

- (NSUInteger)indexForLocalPlayer;




@end
