//
//  ViewController.h
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameModel.h"
#import "ViewLayer.h"

/**
 Main class of the game that handles the view and controls
 */
@interface GameViewController : UIViewController

@property (strong) GameModel *gameModel;

/** Layer that stores the hand cards */
@property (strong) ViewLayer *handsView;

/** Layer that stores the field*/
@property (strong) ViewLayer *fieldView;

/** Layer that stores the overlaying UI */
@property (strong) ViewLayer *uiView;

/** Layer that stores the background, behind everything else */
@property (strong) ViewLayer *backgroundView;

/** updates the position of all hands with the gameModel, adding views to cards that don't have one yet */
//-(void)updateHandsView;

/** Updates the views of the cards in hand */
-(void)updateHandsView: (int)side;

/** Updates the views of the cards in field */
-(void)updateBattlefieldView: (int)side;


@end
