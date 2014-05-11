//
//  ViewController.h
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameModel.h"

/**
 Main class of the game that handles the view and controls
 */
@interface GameViewController : UIViewController

@property (strong) GameModel* gameModel;

/** updates the position of all hands with the gameModel, adding views to cards that don't have one yet */
//-(void)updateHandsView;

@end
