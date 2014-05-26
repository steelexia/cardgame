//
//  AIPlayer.h
//  cardgame
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerModel.h"
#import "GameModel.h"
#import "GameViewController.h"
@class GameViewController;
@class GameModel;

/** The AI player used during single player games. It assumes that it is always on OPPONENT_SIDE. */
@interface AIPlayer : NSObject

@property (weak) PlayerModel* playerModel;

@property (weak) GameModel* gameModel;

@property (weak) GameViewController* gameViewController;

-(instancetype)initWithPlayerModel: (PlayerModel*) playerModel gameViewController:(GameViewController*)gameViewController gameModel:(GameModel*) gameModel;

/** Tells the AI that a new turns has begun, and it will start to make moves */
-(void)newTurn;

@end
