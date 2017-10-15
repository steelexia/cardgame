//
//  GameViewController+Tutorial.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-19.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "GameViewController.h"
@class CFLabel;
@class CFButton;



@interface GameViewController (Tutorial)

-(void)tutorialSetup;

-(void)tutorialMessageGameStart;

-(void)returnedFromCardEditorTutorial;

-(void)summonedCardTutorial:(CardModel*)card fromSide:(int)side;

-(void)endTurnTutorial;

-(void)cardAttacksTutorial;

@end
