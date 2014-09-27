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
#import "CFButton.h"
#import "MultiplayerNetworking.h"

@interface DeckChooserViewController  : UIViewController<MultiplayerDeckChooserProtocol>

@property (strong)UIView* deckBackground;
@property (strong)DeckTableView*deckView;
@property (strong)NSString*opponentName;
@property (strong)StrokedLabel*opponentNameLabel;
@property (strong)StrokedLabel*chooseDeckLabel;
@property (strong)CFLabel*titleBackground;
@property(strong)StrokedLabel*chosenDeckNameLabel;
@property (strong)UILabel*chosenDeckElementSummaryLabel, *chosenDeckTagsLabel;
@property (strong)CFButton*chooseDeckButton,*backButton;
@property (strong)DeckModel*currentDeck;
@property(strong)UIViewController *nextScreen;
@property BOOL noPickDeck;
@property BOOL isMultiplayer;
@property BOOL deckPicked;


-(void)receivedOpponentDeck;

/** For multiplayer */
@property (nonatomic, strong) MultiplayerNetworking *networkingEngine;

@end
