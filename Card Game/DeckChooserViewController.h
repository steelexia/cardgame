//
//  DeckChooserViewController.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-07-06.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeckTableView.h"
#import "DeckModel.h"
#import "CFLabel.h"

@interface DeckChooserViewController : UIViewController

@property (strong)UIView* deckBackground;
@property (strong)DeckTableView*deckView;
@property (strong)NSString*opponentName;
@property (strong)StrokedLabel*opponentNameLabel;
@property (strong)UILabel*chooseDeckLabel;
@property (strong)CFLabel*titleBackground;
@property(strong)StrokedLabel*chosenDeckNameLabel;
@property (strong)UILabel*chosenDeckElementSummaryLabel, *chosenDeckTagsLabel;
@property (strong)UIButton*chooseDeckButton,*backButton;
@property (strong)DeckModel*currentDeck;
@property(strong)UIViewController *nextScreen;

@end
