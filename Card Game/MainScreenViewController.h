//
//  MainScreenViewController.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-27.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeckEditorViewController.h"
#import "GameViewController.h"
#import "UserModel.h"
#import "CFButton.h"
#import "MessagesViewController.h"
#import "OptionsViewController.h"
#import "PNImports.h"

@interface MainScreenViewController : UIViewController <PNDelegate>

@property (strong) StrokedLabel *messageCountLabel;
@property BOOL loadedTutorial;
@property (strong) CFButton *singlePlayerButton, *multiPlayerButton, *deckButton, *storeButton;

@end
