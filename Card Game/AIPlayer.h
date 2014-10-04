//
//  AIPlayer.h
//
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

/** Boss fight AI slightly adjusted */
@property BOOL isBossFight;

/** Tutorial AI also adjusted. They will play any card possible */
@property BOOL isTutorial;

/** Easier difficulties have cards cost less since the cards are weaker, while higher difficulties have cards cost more. At 0 there is no difference and is the default calculation */
@property int levelDifficultyOffset;

/** When AI casts a spell that requires targetting, it will set it to this variable. */
//NOTE: this has been moved to GameModel's opponentCurrentTarget
//@property (weak) MonsterCardModel* currentTarget;

-(instancetype)initWithPlayerModel: (PlayerModel*) playerModel gameViewController:(GameViewController*)gameViewController gameModel:(GameModel*) gameModel;

/** Tells the AI that a new turns has begun, and it will start to make moves */
-(void)newTurn;

-(int)evaluateMonsterValue: (MonsterCardModel*)monster;

@end
