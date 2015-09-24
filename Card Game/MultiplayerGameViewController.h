//
//  MultiplayerGameViewController.h
//  cardgame
//
//  Created by Brian Allen on 2014-09-09.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiplayerNetworking.h"
#import "CFButton.h"
#import "CFLabel.h"
#import "UserModel.h"
#import <Parse/Parse.h>
#import "multiplayerDataHandler.h"

@class GameViewController;
@class DeckChooserViewController;

@interface MultiplayerGameViewController : UIViewController<MultiplayerNetworkingProtocol,multiplayerDataHandlerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic, copy) void (^gameOverBlock)(BOOL didWin);
@property (nonatomic, copy) void (^gameEndedBlock)();

@property (weak, nonatomic) IBOutlet UILabel *messageStateLabel;

@property (nonatomic, strong) MultiplayerNetworking *networkingEngine;
@property (strong,nonatomic) UILabel *currentLoadStateLabel;
@property (strong,nonatomic) UILabel *numberOfPlayersLabel;

@property (strong,nonatomic) UITableView *mpLobbyTableView;
@property (strong,nonatomic) UITableView *chatTableView;
@property (strong,nonatomic) UITextField *chatField;
@property (strong,nonatomic) UIButton *chatSendButton;
@property (strong,nonatomic) CFButton *quickMatchButton;


@property (strong,nonatomic) NSArray *connectedPlayers;
@property (strong,nonatomic) NSMutableArray *chatMessages;
@property (strong,nonatomic) PNChannel *chatChannel;
@property (strong,nonatomic) NSString *challengerUserID;


@property (strong)GameViewController *gvc;
//@property (strong)DeckChooserViewController *dcvc;

@property BOOL playersFound;

//loading view
@property (strong)UIActivityIndicatorView*activityIndicator;
@property(strong) UILabel *activityLabel;
@property(strong) UILabel *battleActivityLabel;
@property (strong)CFButton*activityFailedButton;
@property (strong) NSString*playerOneAlias, *playerTwoAlias;

@property bool opponentHasReceivedDeck, deckReceived;

@end
