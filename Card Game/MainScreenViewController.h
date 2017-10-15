//
//  MainScreenViewController.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-27.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DeckEditorViewController;
@class GameViewController;
@class UserModel;
@class CFButton;
@class MessagesViewController;
@class OptionsViewController;
@class StrokedLabel;

#import "PNImports.h"

@interface MainScreenViewController : UIViewController <PNDelegate>

@property (strong) StrokedLabel *messageCountLabel;
@property BOOL loadedTutorial;
@property (strong) UIButton *singlePlayerButton, *multiPlayerButton, *deckButton, *storeButton;
@property (strong)NSArray *messagesRetrieved;

@end
