//
//  MultiplayerGameViewController.m
//  cardgame
//
//  Created by Brian Allen on 2014-09-09.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "MultiplayerGameViewController.h"
//brian sep 9
#import "MultiplayerNetworking.h"
#import "GameKitHelper.h"
#import "CardView.h"
#import "GameViewController.h"
#import "DeckChooserViewController.h"
#import "LeaderboardsViewController.h"
#import "AutoSizeChatCellTableViewCell.h"
#import "GameModel.h"
#import "StrokedLabel.h"

@interface MultiplayerGameViewController () <MultiplayerNetworkingProtocol>


@end

@implementation MultiplayerGameViewController

/** Screen dimension for convinience */
int SCREEN_WIDTH, SCREEN_HEIGHT;

BOOL playerAuthenticated;
BOOL alreadyLoadedMatch;
MultiplayerNetworking *_networkingEngine;
NSUInteger _currentPlayerIndex;
multiplayerDataHandler *MPDataHandler;
UIView *bgDarkenView;
UIView *sureMatchView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SCREEN_WIDTH = [[UIScreen mainScreen] bounds].size.width;
    SCREEN_HEIGHT = [[UIScreen mainScreen] bounds].size.height;
    
    //iPhone 4S Values
    
    //background view
    UIImageView*backgroundImageTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_background_top"]];
    backgroundImageTop.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    [self.view addSubview:backgroundImageTop];
    
    UIImageView*backgroundImageMiddle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_background_center"]];
    backgroundImageMiddle.frame = CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - 40 - 40);
    
    [self.view addSubview:backgroundImageMiddle];
    
    UIImageView*backgroundImageBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_background_bottom"]];
    backgroundImageBottom.frame = CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, 40);
    [self.view addSubview:backgroundImageBottom];
    
    
    CFLabel*menuLogoBackground = [[CFLabel alloc] initWithFrame:CGRectMake(0,0,250,50)];
    menuLogoBackground.center = CGPointMake(SCREEN_WIDTH/2, 50);
    menuLogoBackground.label.textAlignment = NSTextAlignmentCenter;
    [menuLogoBackground setTextSize:30];
    menuLogoBackground.label.text = @"Multiplayer";
    [self.view addSubview:menuLogoBackground];
    
    
    self.quickMatchButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 200, 130)];
    self.quickMatchButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 150);
    //[self.quickMatchButton.label setText:@"Quick Match"];
    
    
    //[startButton addTarget:self action:@selector(startGameCenterButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.quickMatchButton addTarget:self action:@selector(quickMatch)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.quickMatchButton];
    
    CFButton* connectButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    connectButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 200);
    [connectButton.label setText:@"Connect"];
    //[startButton addTarget:self action:@selector(startGameCenterButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [connectButton addTarget:self action:@selector(startConnectingPubNub)    forControlEvents:UIControlEventTouchUpInside];
    
    //[self.view addSubview:connectButton];
    
    CFButton* leaderboardButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    leaderboardButton.center = CGPointMake(SCREEN_WIDTH-70, SCREEN_HEIGHT - 45);
    [leaderboardButton.label setText:@"Leaderboards"];
    
    [leaderboardButton addTarget:self action:@selector(viewLeaderboards)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:leaderboardButton];
    
    self.mpLobbyTableView = [[UITableView alloc] initWithFrame:CGRectMake(20,80,SCREEN_WIDTH-40,150)];
    self.mpLobbyTableView.delegate = self;
    self.mpLobbyTableView.dataSource = self;
    self.mpLobbyTableView.alpha = 0;
    self.mpLobbyTableView.tag = 88;
    self.mpLobbyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mpLobbyTableView.alwaysBounceVertical = NO;
    [self.mpLobbyTableView.layer setZPosition:0.0];
    CALayer *mpLobbyLayer = self.mpLobbyTableView.layer;
    mpLobbyLayer.cornerRadius = 8.0f;
    mpLobbyLayer.masksToBounds = YES;
    
    self.noPlayersAvailableLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, SCREEN_WIDTH-40,150)];
    [self.noPlayersAvailableLabel setText:@"Multiplayer Connection Verified, No Players Available."];
    [self.noPlayersAvailableLabel setFont:[UIFont fontWithName:cardMainFont size:13]];
    [self.noPlayersAvailableLabel setAlpha:0];
    [self.noPlayersAvailableLabel setTextAlignment:NSTextAlignmentCenter];
    [self.noPlayersAvailableLabel setNumberOfLines:2];
    [self.noPlayersAvailableLabel.layer setZPosition:0.1];
    //[self.noPlayersAvailableLabel setTextColor:[UIColor whiteColor]];
    
    
    [self.view addSubview:self.mpLobbyTableView];
    [self.view addSubview:self.noPlayersAvailableLabel];
    
    self.chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(20,240,SCREEN_WIDTH-40,100)];
    self.chatTableView.backgroundColor = [UIColor blackColor];
    self.chatTableView.tag = 99;
    self.chatTableView.userInteractionEnabled = YES;
    self.chatTableView.allowsSelection = NO;
    self.chatTableView.dataSource = self;
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    CALayer *chatTableLayer = self.chatTableView.layer;
    chatTableLayer.cornerRadius = 8.0f;
    chatTableLayer.masksToBounds = YES;
    
    
    [self.view addSubview:self.mpLobbyTableView];
    
    self.chatTableView.delegate = self;
    [self.view addSubview:self.chatTableView];
    
    self.chatField = [[UITextField alloc] initWithFrame:CGRectMake(20,345,SCREEN_WIDTH-95 ,30)];
    self.chatField.delegate = self;
    self.chatField.alpha = 0;
    self.chatField.borderStyle = UITextBorderStyleNone;
    self.chatField.backgroundColor = [UIColor whiteColor];
    CALayer *chatFieldLayer = self.chatField.layer;
    chatFieldLayer.cornerRadius = 8.0f;
    chatFieldLayer.masksToBounds = YES;
    
    [self.view addSubview:self.chatField];
    
    self.chatSendButton = [[CFButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-70,345,50,30)];
    //self.chatSendButton.backgroundColor = [UIColor blueColor];
    [self.chatSendButton setTitle:@"Send" forState:UIControlStateNormal];
    self.chatSendButton.alpha = 0;
    CALayer *chatBtnLayer = self.chatSendButton.layer;
    //chatBtnLayer.cornerRadius = 8.0f;
    //chatBtnLayer.masksToBounds = YES;
    
    [self.chatSendButton addTarget:self action:@selector(chatSend:) forControlEvents:UIControlEventTouchUpInside];
    
    self.chatSendButton.titleLabel.textColor = [UIColor whiteColor];
    
    [self.view addSubview:self.chatSendButton];
    
    UITapGestureRecognizer *chatTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapChat:)];
    
    [self.chatTableView addGestureRecognizer:chatTapRecognizer];
    
    
    UIButton* backButton = [[CFButton alloc] initWithFrame:CGRectMake(35, SCREEN_HEIGHT - 32 - 30, 46, 32)];
    [backButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    self.currentLoadStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,200,300,50)];
    self.currentLoadStateLabel.text = @"Default Text";
    
    self.numberOfPlayersLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,300,300,50)];
    self.numberOfPlayersLabel.text = @"Num of Players Connected";
    
    // [self.view addSubview:self.currentLoadStateLabel];
    //[self.view addSubview:self.numberOfPlayersLabel];
    
    self.chatMessages = [[NSMutableArray alloc] init];
    NSString *chat1 = @"Hi there this is chat";
    
    [self.chatTableView reloadData];
    
    
    //---------------activity indicator--------------------//
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_activityIndicator setFrame:self.view.bounds];
    [_activityIndicator setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.5]];
    [_activityIndicator setUserInteractionEnabled:YES];
    _activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    _activityLabel.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + 60);
    _activityLabel.textAlignment = NSTextAlignmentCenter;
    _activityLabel.textColor = [UIColor whiteColor];
    _activityLabel.font = [UIFont fontWithName:cardMainFont size:20];
    _activityLabel.text = [NSString stringWithFormat:@"Processing..."];
    [_activityIndicator addSubview:_activityLabel];
    
    _activityFailedButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    _activityFailedButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 60);
    _activityFailedButton.label.text = @"Ok";
    [_activityFailedButton setTextSize:18];
    [_activityFailedButton addTarget:self action:@selector(activityFailedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    //TODO prompt before this
    //[self startGameCenterButtonPressed];
    
    [self.view addSubview:_activityIndicator];
    
    [self loadParseChatMessages];
    
    
    
    
    
}

//brian sep 9
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [MPDataHandler getPubNubConnectedPlayers];
    NSLog(@"appeared");
}

-(void)loadParseChatMessages
{
    PFQuery *chatQuery = [PFQuery queryWithClassName:@"chatMessage"];
    [chatQuery orderByDescending:@"createdAt"];
    chatQuery.limit = 50;
    
    [chatQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //chat objects
        
        NSArray* reversedArray = [[objects reverseObjectEnumerator] allObjects];
        [self.chatMessages addObjectsFromArray:reversedArray];
        [self.chatTableView reloadData];
        
        
        NSInteger rowNumbers = [self.chatTableView numberOfRowsInSection:0];
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowNumbers-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        
        
    }];
    
}


-(void)startConnectingPubNub
{
    
    MPDataHandler = [multiplayerDataHandler sharedInstance];
    [MPDataHandler setPubnubConfigDetails];
    
    NSLog(@"starting gameViewController");
    _gvc = [[GameViewController alloc] initWithGameMode:GameModeMultiplayer withLevel:nil];
    _gvc.MPDataHandler = MPDataHandler;
    MPDataHandler.gameDelegate = _gvc;
    MPDataHandler.delegate = self;
    
    //[MPDataHandler getPubNubConnectedPlayers];
    //[self testMPFunction];
    
    
    
    
}
-(void)viewLeaderboards
{
    LeaderboardsViewController *lvc = [[LeaderboardsViewController alloc] init];
    
    [self presentViewController:lvc animated:YES completion:nil];
    
    
}

-(void)quickMatch
{
    // [MPDataHandler sendStartMatch];
    
    //show a loading bar..
    
    /* _activityIndicator.alpha = 0;
     _activityLabel.text = @"Finding Opponent...";
     [_activityIndicator setColor:[UIColor whiteColor]];
     [self.view addSubview:_activityIndicator];
     [_activityIndicator startAnimating];
     [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
     animations:^{
     _activityIndicator.alpha = 1;
     }
     completion:^(BOOL completed){
     }];*/
    [self displayQuickMatchUI];
    
    [MPDataHandler joinQuickMatchChannel];
    
}


-(void)startGameCenterButtonPressed
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LocalPlayerIsAuthenticated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerAuthenticated)
                                                 name:LocalPlayerIsAuthenticated object:nil];
    
    
    _activityIndicator.alpha = 0;
    _activityLabel.text = @"Loading Game Center...";
    [_activityIndicator setColor:[UIColor whiteColor]];
    [self.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _activityIndicator.alpha = 1;
                     }
                     completion:^(BOOL completed){
                     }];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(showAuthenticationViewController)
     name:PresentAuthenticationViewController
     object:nil];
    
    [[GameKitHelper sharedGameKitHelper]
     authenticateLocalPlayer];
}

-(void)backButtonPressed
{
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//brian sep 9 2014
- (void)showAuthenticationViewController
{
    GameKitHelper *gameKitHelper =
    [GameKitHelper sharedGameKitHelper];
    
    [self presentViewController:
     gameKitHelper.authenticationViewController
                       animated:YES
                     completion:^{
                         /*
                          [self closeLoadingScreen];
                          */
                     }];
}

-(void)closeLoadingScreen
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _activityIndicator.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [_activityIndicator stopAnimating];
                         [_activityIndicator removeFromSuperview];
                     }];
}

//brian sep 9 2014
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)playerAuthenticated {
    _networkingEngine = [[MultiplayerNetworking alloc] init];
    _networkingEngine.delegate = self;
    self.networkingEngine = _networkingEngine;
    [[GameKitHelper sharedGameKitHelper] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self delegate:_networkingEngine];
}


/*
 #pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)setCurrentPlayerIndex:(NSUInteger)index {
    _currentPlayerIndex = index;
}

//brian sep9
#pragma mark MultiplayerNetworkingProtocol


-(void)playersFound
{
    if (_playersFound)
        return;
    else
        _playersFound = YES;
    
    //[self.navigationController pushViewController:dcvc animated:YES];
    //[self addChildViewController:dcvc];
    NSLog(@"deck chooser");
    _gvc = [[GameViewController alloc] initWithGameMode:GameModeMultiplayer withLevel:nil];
    _gvc.noPreviousView = YES;
    _gvc.networkingEngine = _networkingEngine;
    [_gvc setPlayerSeed:_networkingEngine.playerSeed];
    [_gvc setOpponentSeed:_networkingEngine.opponentSeed];
    
    if (![_networkingEngine isLocalPlayerPlayer1])
    {
        [_gvc setCurrentSide:OPPONENT_SIDE];
    }
    
    //_dcvc = [[DeckChooserViewController alloc] init];
    //_dcvc.isMultiplayer = YES;
    //_dcvc.networkingEngine = _networkingEngine;
    
    //_networkingEngine.deckChooserDelegate = _dcvc;
    _networkingEngine.gameDelegate = _gvc;
    
    /*
     if ([_networkingEngine indexForLocalPlayer] == 0)
     _dcvc.opponentName = _playerTwoAlias;
     else
     _dcvc.opponentName = _playerOneAlias;
     */
    //_dcvc.nextScreen = _gvc;
    
    //[self presentViewController:_dcvc animated:YES completion:nil];
    
    [_networkingEngine sendDeckID:userCurrentDeck.objectID];
    
    _activityLabel.text = @"Starting game...";
}


- (void)movePlayerAtIndex:(NSUInteger)index {
    NSString *indexString = [NSString stringWithFormat:@"%i", index];
    
    self.messageStateLabel.text = [indexString stringByAppendingString:@" Player"];
}

- (void)gameOver:(BOOL)player1Won {
    BOOL didLocalPlayerWin = YES;
    if (player1Won) {
        didLocalPlayerWin = NO;
    }
    if (self.gameOverBlock) {
        self.gameOverBlock(didLocalPlayerWin);
    }
}

- (void)setPlayerAliases:(NSArray*)playerAliases {
    [playerAliases enumerateObjectsUsingBlock:^(NSString *playerAlias, NSUInteger idx, BOOL *stop) {
        if (idx == 0)
            _playerOneAlias = playerAlias;
        else
            _playerTwoAlias = playerAlias;
        NSLog(@"Player Alias is..");
        
        NSLog(playerAlias);
    }];
}

-(void)receivedOpponentDeck: (NSString*) deckID
{
    NSLog(@"receiving opponent deck... %@", deckID);
    PFQuery *deckQuery = [PFQuery queryWithClassName:@"Deck"];
    NSError*error;
    PFObject *deckPF = [deckQuery getObjectWithId:deckID error:&error];
    if (!error)
    {
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        DeckModel *deck = [UserModel downloadDeckFromPF:deckPF];
        NSArray*cards = deckPF[@"cards"];
        NSLog(@"count PF: %d local: %d", [cards count], deck.count);
        
        if (deck != nil)
        {
            NSLog(@"finished downloading opponent deck");
            
            [_gvc setOpponentDeck:deck];
            
            //[_dcvc receivedOpponentDeck];
            //[self receivedOpponentDeck];
            // [_networkingEngine sendReceivedDeck]; //tells other player deck is received
            
            // MPDataHandler
            if(!MPDataHandler.opponentReceivedSeed)
            {
                [MPDataHandler sendSeedMessage:nil];
                
            }
            
        }
        else
        {
            //TODO ERROR
            NSLog(@"getDeckFromPF returned nil");
            
        }
        //});
    }
    else{
        //TODO ERROR
        NSLog(@"Couldn't find deck");
    }
}


-(void)showActivityIndicatorWithBlock:(BOOL (^)())block loadingText:(NSString*)loadingText failedText:(NSString*)failedText
{
    _activityIndicator.alpha = 0;
    _activityLabel.text = loadingText;
    [_activityIndicator setColor:[UIColor whiteColor]];
    [self.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _activityIndicator.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         BOOL succ = block();
                         
                         if (succ)
                         {
                             [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  _activityIndicator.alpha = 0;
                                              }
                                              completion:^(BOOL completed){
                                                  [_activityIndicator stopAnimating];
                                                  [_activityIndicator removeFromSuperview];
                                              }];
                         }
                         else
                         {
                             [_activityIndicator setColor:[UIColor clearColor]];
                             _activityLabel.text = failedText;
                             _activityFailedButton.alpha = 0;
                             [_activityIndicator addSubview:_activityFailedButton];
                             [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  _activityFailedButton.alpha = 1;
                                              }
                                              completion:^(BOOL completed){
                                                  [_activityFailedButton setUserInteractionEnabled:YES];
                                              }];
                         }
                     }];
}

-(void)activityFailedButtonPressed
{
    [_activityFailedButton setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _activityIndicator.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [_activityFailedButton removeFromSuperview];
                     }];
}

-(void)playerNotAuthenticated
{
    [self closeLoadingScreen];
    [self resetState];
}

-(void)matchCancelled
{
    //TODO
    [self closeLoadingScreen];
    [self resetState];
}

-(void)matchFailed:(NSError*)error
{
    //TODO
    [self closeLoadingScreen];
    [self resetState];
}

- (void)matchEnded {
    [self closeLoadingScreen];
    [self resetState];
}

-(void)resetState
{
    _playersFound = NO;
    _opponentHasReceivedDeck = NO;
    _deckReceived = NO;
}

-(void)opponentReceivedDeck
{
    NSLog(@"deckChooser opponentReceivedDeck");
    _opponentHasReceivedDeck = YES;
    
    //also received opponent's deck, both are ready
    if (_deckReceived)
    {
        NSLog(@"start!");
        
        //dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:_gvc animated:YES completion:^{
            [self closeLoadingScreen];
        }];
        //});
    }
}

-(void)receivedOpponentDeck
{
    NSLog(@"deckChooser receivedOpponentDeck");
    _deckReceived = YES;
    
    //opponent also received deck, start
    if(_opponentHasReceivedDeck)
    {
        NSLog(@"start!");
        //dispatch_async(dispatch_get_main_queue(), ^{
        //[self closeLoadingScreen];
        [self presentViewController:_gvc animated:YES completion:^{
            //[self closeLoadingScreen];
        }];
        //});
    }
}

- (void)startDownloadingOpponentDeck:(NSString *)deckID
{
    [self receivedOpponentDeck:deckID];
    
}

- (void)startLoadingMatch
{
    //reference the opponent deckID from the property on multiplayer data handler
    NSString *opponentDeckID = [MPDataHandler getOpponentDeckID];
    _deckReceived = YES;
    _opponentHasReceivedDeck = YES;
    
    [_gvc setPlayerSeed:MPDataHandler.playerSeed];
    [_gvc setOpponentSeed:MPDataHandler.opponentSeed];
    if(MPDataHandler.playerSeed <= MPDataHandler.opponentSeed)
    {
        [_gvc setCurrentSide:OPPONENT_SIDE];
    }
    
    NSLog(@"start!");
    
    if(!alreadyLoadedMatch)
    {
        
        alreadyLoadedMatch = TRUE;
        
        //dispatch_async(dispatch_get_main_queue(), ^{
        // [self closeLoadingScreen];
        [self presentViewController:_gvc animated:YES completion:^{
            //[self closeLoadingScreen];
            
        }];
    }
    
}

-(void)sendEndTurn
{
    
}

-(void)updateStatusLabelText:(NSString *) text
{
    self.currentLoadStateLabel.text = text;
    
}

-(void)updateNumPlayersLabel:(NSString *)text
{
    self.numberOfPlayersLabel.text = text;
    
}

-(void)testMPFunction
{
    NSError* error;
    [PFCloud callFunction:@"mpMatchComplete" withParameters:@{
                                                              @"User1" : [PFUser currentUser].objectId, @"User2" :@"IRh33iYFK9", @"User1Rating" :@800,@"User2Rating": @400
                                                              } error:&error];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if(tableView.tag ==88)
    {
        return 40.0;
    }
    else
    {
        return 0;
        
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView.tag==88)
    {
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,40)];
        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,40)];
        titleLabel.backgroundColor = [UIColor darkGrayColor];
        
        titleLabel.text = @"  USERNAME   RATING";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:@"BookmanOldStyle-Bold" size:13];
        
        UIButton *reloadButton = [[UIButton alloc] initWithFrame:CGRectMake(175,8,90,27)];
        reloadButton.backgroundColor = [UIColor greenColor];
        [reloadButton setTitle:@"Refresh" forState:UIControlStateNormal];
        [reloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        reloadButton.titleLabel.font = [UIFont fontWithName:@"BookmanOldStyle-Bold" size:15];
        reloadButton.layer.cornerRadius = 12.0f;
        reloadButton.layer.masksToBounds = YES;
        [reloadButton addTarget:self action:@selector(refreshLobby:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [headerView addSubview:titleLabel];
        [headerView addSubview:reloadButton];
        
        return headerView;
    }
    else
    {
        return nil;
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView.tag==88)
    {
        return self.connectedPlayers.count;
        
    }
    else
    {
        return self.chatMessages.count;
        
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView.tag ==99)
    {
        /*
         //check the length of the message
         NSDictionary *msgIncomingDict = [self.chatMessages objectAtIndex:indexPath.row];
         
         NSString *chatMessage = [msgIncomingDict objectForKey:@"messageText"];
         NSString *userName = [msgIncomingDict objectForKey:@"userName"];
         NSDate *chatTime = [msgIncomingDict objectForKey:@"chatMsgDate"];
         
         NSString *fullChatString = [[[@"[" stringByAppendingString:userName] stringByAppendingString:@"]: "] stringByAppendingString:chatMessage];
         
         if([fullChatString length] <40)
         {
         return 15;
         }
         else if([fullChatString length] <80)
         {
         return 45;
         }
         else if([fullChatString length] <120)
         {
         return 65;
         
         }
         else
         {
         return 75;
         
         }
         */
        
        AutoSizeChatCellTableViewCell *cell = [[AutoSizeChatCellTableViewCell alloc] init];
        
        NSDictionary *msgIncomingDict = [self.chatMessages objectAtIndex:indexPath.row];
        
        NSString *chatMessage = [msgIncomingDict objectForKey:@"messageText"];
        NSString *userName = [msgIncomingDict objectForKey:@"userName"];
        NSDate *chatTime = [msgIncomingDict objectForKey:@"chatMsgDate"];
        
        NSString *fullChatString = [[[@"[" stringByAppendingString:userName] stringByAppendingString:@"]: "] stringByAppendingString:chatMessage];
        
        cell.textLabel.text = fullChatString;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints
        // (Note that the preferredMaxLayoutWidth is set on multi-line UILabels inside the -[layoutSubviews] method
        // in the UITableViewCell subclass
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        // Get the actual height required for the cell
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        // Add an extra point to the height to account for the cell separator, which is added between the bottom
        // of the cell's contentView and the bottom of the table view cell.
        height += 0;
        // NSLog(@"height @%f",height);
        
        
        return height;
        
    }
    else
        
    {
        return 25;
    }
    
}

-(NSInteger)getNumberOfLinesInLabelOrTextView:(id)obj withText:(NSString *) text
{
    NSInteger lineCount = 0;
    if([obj isKindOfClass:[UILabel class]])
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.text = text;
        label.font = [UIFont fontWithName:@"BookmanOldStyle-Bold" size:11];
        
        CGRect frame = label.frame;
        frame.size.width = self.chatTableView.frame.size.width;
        
        frame.size = [label sizeThatFits:frame.size];
        CGSize requiredSize = frame.size;
        
        int charSize = label.font.leading;
        int rHeight = requiredSize.height;
        
        lineCount = rHeight/charSize;
    }
    else if ([obj isKindOfClass:[UITextView class]])
    {
        UITextView *textView = (UITextView *)obj;
        lineCount = textView.contentSize.height / textView.font.leading;
    }
    
    return lineCount;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView.tag ==88)
    {
        
        static NSString *MyIdentifier = @"leaderboardCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        UILabel *userNameLabel;
        UILabel *userStateLabel;
        UILabel *userEloLabel;
        UIButton *challengeButton;
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:MyIdentifier];
            userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,25)];
            userStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(191,0,70,25)];
            userEloLabel = [[UILabel alloc] initWithFrame:CGRectMake(105,0,40,25)];
            challengeButton = [[UIButton alloc] initWithFrame:CGRectMake(175,2,90,21)];
            [challengeButton setBackgroundColor:[UIColor blueColor]];
            [challengeButton setTitle:@"Challenge" forState:UIControlStateNormal];
            challengeButton.titleLabel.font = [UIFont fontWithName:@"BookmanOldStyle-Bold" size:12];
            
            [challengeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            CALayer *btnLayer = challengeButton.layer;
            btnLayer.cornerRadius = 8.0f;
            btnLayer.masksToBounds = YES;
            
            
            [challengeButton addTarget:self action:@selector(challengePlayer:) forControlEvents:UIControlEventTouchUpInside];
            userNameLabel.font = [UIFont fontWithName:@"BookmanOldStyle-Bold" size:10];
            userEloLabel.font = [UIFont fontWithName:@"BookmanOldStyle-Bold" size:10];
            userNameLabel.tag = 1;
            [userNameLabel setTextAlignment:NSTextAlignmentCenter];
            [userEloLabel setTextAlignment:NSTextAlignmentCenter];
            [cell addSubview:userNameLabel];
            userStateLabel.tag = 2;
            [cell addSubview:userStateLabel];
            userEloLabel.tag = 3;
            [cell addSubview:userEloLabel];
            challengeButton.tag = 1000+indexPath.row;
            [cell addSubview:challengeButton];
            
            
        }
        
        // Here we use the provided setImageWithURL: method to load the web image
        // Ensure you use a placeholder image otherwise cells will be initialized with no image
        NSDictionary *userObjectAtIndex = [self.connectedPlayers objectAtIndex:indexPath.row];
        
        
        NSNumber *playerElo = [userObjectAtIndex objectForKey:@"eloRating"];
        NSString *playerName = [userObjectAtIndex objectForKey:@"usernameCustom"];
        NSString *playerState = [userObjectAtIndex objectForKey:@"gameState"];
        
        userNameLabel = (UILabel *)[cell viewWithTag:1];
        userStateLabel = (UILabel *)[cell viewWithTag:2];
        userEloLabel = (UILabel *)[cell viewWithTag:3];
        challengeButton = (UIButton *)[cell viewWithTag:1000+indexPath.row];
        
        
        userStateLabel.text = playerState;
        userNameLabel.text = playerName;
        userEloLabel.text = [playerElo stringValue];
        
        if([userStateLabel.text isEqualToString:@"Lobby"])
        {
            userStateLabel.textColor = [UIColor greenColor];
        }
        else
        {
            userStateLabel.textColor = [UIColor blackColor];
            
        }
        
        //cell.textLabel.text =[playerElo stringValue];
        
        
        return cell;
    }
    else
    {
        //return chat cell
        static NSString *MyIdentifier = @"chatCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        UILabel *messageLabel;
        
        if (cell == nil)
        {
            cell = [[AutoSizeChatCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                        reuseIdentifier:MyIdentifier];
            messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,250,70)];
            //[cell addSubview:messageLabel];
            
            cell.textLabel.textColor = [UIColor whiteColor];
            
            cell.backgroundColor = [UIColor blackColor];
            
            cell.textLabel.font = [UIFont fontWithName:@"BookmanOldStyle-Bold" size:11];
            
            //messageLabel.numberOfLines = 3;
            //messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
            
        }
        //[messageLabel setFrame:CGRectMake(cell.frame.origin.x , cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
        
        NSDictionary *msgIncomingDict = [self.chatMessages objectAtIndex:indexPath.row];
        
        NSString *chatMessage = [msgIncomingDict objectForKey:@"messageText"];
        NSString *userName = [msgIncomingDict objectForKey:@"userName"];
        NSDate *chatTime = [msgIncomingDict objectForKey:@"chatMsgDate"];
        
        NSString *fullChatString = [[[@"[" stringByAppendingString:userName] stringByAppendingString:@"]: "] stringByAppendingString:chatMessage];
        
        cell.textLabel.text = fullChatString;
        
        
        return cell;
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView.tag==99)
    {
        //dimensions iPhone 4s
        //self.chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(20,240,SCREEN_WIDTH-40,125)];
        
        if(self.chatField.alpha ==0)
        {
            //expand chat tableview and show the chat option
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
                //Animation
                [self.chatTableView setFrame:CGRectMake(20,80,SCREEN_WIDTH-40,260)];
                if(self.chatField ==nil)
                {
                    self.chatField = [[UITextField alloc] initWithFrame:CGRectMake(25,275,SCREEN_WIDTH-50,50)];
                    [self.view addSubview:self.chatField];
                }
                self.chatField.alpha = 1;
                [self.chatField becomeFirstResponder];
                self.chatSendButton.alpha = 1;
                self.quickMatchButton.alpha = 0;
            } completion:^(BOOL finished) {
            }];
            
        }else{
            
            [self.chatField resignFirstResponder];
        }
        /* else
         {
         
         [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
         //Animation
         [self.chatTableView setFrame:CGRectMake(20,240,SCREEN_WIDTH-40,100)];
         self.chatField.alpha = 0;
         self.chatSendButton.alpha = 0;
         [self.chatField resignFirstResponder];
         self.quickMatchButton.alpha = 1;
         } completion:^(BOOL finished) {
         }];
         
         }*/
    }
}

-(void)updatePlayerLobby:(NSArray *)connectedPlayers
{
    if ([connectedPlayers count] > 0) {
        self.connectedPlayers = connectedPlayers;
        
        
        [self.mpLobbyTableView setAlpha:1.0];
        [self.noPlayersAvailableLabel setAlpha:0.0];
    }else{
        self.connectedPlayers = nil;
        [self.mpLobbyTableView setAlpha:1.0];
        [self.noPlayersAvailableLabel setAlpha:1.0];
    }
    
    [self.mpLobbyTableView reloadData];
    [self.activityIndicator removeFromSuperview];
    
}

-(void)challengePlayer:(UIButton *)sender;
{
    //send to the delegate the relevant information for the challenge
    UIButton *sendingButton = sender;
    NSInteger playerTag = sendingButton.tag-1000;
    
    //get player at index
    NSDictionary *playerObjAtIndex = [self.connectedPlayers objectAtIndex:playerTag];
    
    //send to MPDataHandler function, function should send a request to this user to show a challenge window.  If they click yes on the challenge window, then it goes forward with a 1 on 1 match.
    
    [MPDataHandler sendChallengeToPlayerObj:playerObjAtIndex];
    
    [self displayChallengeUI:playerObjAtIndex];
    
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // textField.text = @"";
    
    [self animateTextField:textField up:YES];
}




- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
    if (self.chatField.alpha ==1) {
        [self didTapChat:nil];
    }
    
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];// this will do the trick
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    int animatedDistance;
    int moveUpValue = textField.frame.origin.y+ textField.frame.size.height;
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        
        animatedDistance = 216-(self.view.frame.size.height-moveUpValue-20);
    }
    else
    {
        animatedDistance = 162-(320-moveUpValue-5);
    }
    
    if(animatedDistance>0)
    {
        const int movementDistance = animatedDistance;
        const float movementDuration = 0.3f;
        int movement = (up ? -movementDistance : movementDistance);
        [UIView beginAnimations: nil context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        [UIView commitAnimations];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    //put the string of the text field onto a label now in the same cell
    //put -100 so it doesn't interfere with the uilabel tag of 3 in every cell
    
    [textField resignFirstResponder];
    
    
    return YES;
}



- (void)didTapChat:(UITapGestureRecognizer *)tapGesture
{
    //dimensions iPhone 4s
    //self.chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(20,240,SCREEN_WIDTH-40,125)];
    
    if(self.chatField.alpha ==0)
    {
        //expand chat tableview and show the chat option
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
            //Animation
            [self.chatTableView setFrame:CGRectMake(20,80,SCREEN_WIDTH-40,260)];
            if(self.chatField ==nil)
            {
                self.chatField = [[UITextField alloc] initWithFrame:CGRectMake(25,275,SCREEN_WIDTH-50,50)];
                [self.view addSubview:self.chatField];
            }
            self.chatField.alpha = 1;
            [self.chatField becomeFirstResponder];
            self.chatSendButton.alpha = 1;
            self.quickMatchButton.alpha = 0;
            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatMessages.count -1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        } completion:^(BOOL finished) {
        }];
        
    }
    else
    {
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
            //Animation
            [self.chatTableView setFrame:CGRectMake(20,240,SCREEN_WIDTH-40,100)];
            self.chatField.alpha = 0;
            self.chatSendButton.alpha = 0;
            [self.chatField resignFirstResponder];
            self.quickMatchButton.alpha = 1;
            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[NSNumber numberWithFloat:self.chatMessages.count /2] intValue] inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        } completion:^(BOOL finished) {
        }];
        
    }
}

-(void)chatSend:(id)sender
{
    
    NSString *chatString = self.chatField.text;
    self.chatField.text = @"";
    if([chatString length] ==0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Chat Entered" message:@"Must Enter Chat Before Sending" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if([chatString length] >200)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Chat Too Long" message:@"200 Character Limit On Chat" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
        
    }
    
    //send the chat object to parse and to PubNub
    
    PFObject *messageObject = [PFObject objectWithClassName:@"chatMessage"];
    
    NSString *messageText = chatString;
    
    PFUser *myUser = [PFUser currentUser];
    NSString *userName = myUser.username;
    
    
    [messageObject setObject:messageText forKey:@"messageText"];
    [messageObject setObject:userName forKey:@"userName"];
    [messageObject setObject:myUser forKey:@"messageSender"];
    [messageObject setObject:myUser.objectId forKey:@"messageSenderID"];
    
    [messageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error)
        {
            NSLog(@"There was a parse upload error: @%@",error.localizedDescription);
            UIAlertView *msgUploadError = [[UIAlertView alloc] initWithTitle:@"Message Error" message:@"The Message Failed to Upload To The Server, Your Recipient May Not Receive It" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [msgUploadError show];
            
        }
    }
     ];
    
    //send the message to pubnub
    
    NSMutableDictionary *sendingMsgDict = [[NSMutableDictionary alloc] init];
    [sendingMsgDict setObject:messageText forKey:@"messageText"];
    
    [sendingMsgDict setObject:myUser.objectId forKey:@"msgSenderUserID"];
    
    [sendingMsgDict setObject:userName forKey:@"userName"];
    
    [sendingMsgDict setObject:@"chat" forKey:@"channel"];
    
    [MPDataHandler sendChatWithDict:sendingMsgDict];
    
}

-(void)chatUpdate:(NSDictionary *)chatDictionary
{
    [self.chatMessages addObject:chatDictionary];
    [self.chatTableView reloadData];
    NSInteger rowNumbers = [self.chatTableView numberOfRowsInSection:0];
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowNumbers-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(void)notifyPlayerOfChallenge:(NSDictionary *)challengeDictionary
{
    NSString *challengingPlayerUserName = [challengeDictionary objectForKey:@"chgUserName"];
    self.challengerUserID = [challengeDictionary objectForKey:@"chgUserID"];
    
    NSString *eloRating = [challengeDictionary objectForKey:@"eloRatingChallenger"];
    
    //show a popup announcing the challenge.
    sureMatchView = [[UIView alloc] initWithFrame:CGRectMake(20,70,self.view.frame.size.width-40,450)];
    sureMatchView.backgroundColor = [UIColor whiteColor];
    CALayer *sureMatchLayer = sureMatchView.layer;
    sureMatchLayer.cornerRadius = 8.0f;
    
    
    UILabel *sureMatchTitle = [[UILabel alloc] initWithFrame:CGRectMake(20,20,sureMatchView.frame.size.width-40,40)];
    sureMatchTitle.text = @"You Have A Challenge!";
    sureMatchTitle.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:30];
    sureMatchTitle.textAlignment = NSTextAlignmentCenter;
    
    [sureMatchView addSubview:sureMatchTitle];
    
    
    UILabel *sureMatchCaseNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,70,300,50)];
    
    sureMatchCaseNameLabel.font =[UIFont fontWithName:@"Futura-CondensedMedium" size:25];
    
    
    sureMatchCaseNameLabel.text = [[[challengingPlayerUserName stringByAppendingString:@" ("] stringByAppendingString:eloRating] stringByAppendingString:@")"];
    
    
    UIImageView *sureMatchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10,120,150,150)];
    
    //check to see if there is a caseProfile for this caseID
    NSString *defaultMatchImgFileName = [[NSBundle mainBundle] pathForResource:@"angryorc" ofType:@"jpeg"];
    sureMatchImageView.image = [UIImage imageWithContentsOfFile:defaultMatchImgFileName];
    
    [sureMatchView addSubview:sureMatchCaseNameLabel];
    [sureMatchView addSubview:sureMatchImageView];
    
    //add two buttons for "Not Who I Wanted" and "Start a Conversation"
    UIButton *notWhoIWantedButton = [[UIButton alloc] initWithFrame:CGRectMake(10,300,sureMatchView.frame.size.width-20,50)];
    notWhoIWantedButton.backgroundColor = [UIColor redColor];
    notWhoIWantedButton.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:20];
    notWhoIWantedButton.titleLabel.textColor = [UIColor whiteColor];
    notWhoIWantedButton.titleLabel.text = @"Not Who I Wanted";
    [notWhoIWantedButton setTitle:@"Reject Match" forState:UIControlStateNormal];
    notWhoIWantedButton.tag = 102;
    
    [notWhoIWantedButton addTarget:self action:@selector(rejectMatch:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *startConversationButton = [[UIButton alloc] initWithFrame:CGRectMake(10,360,sureMatchView.frame.size.width-20,50)];
    
    startConversationButton.backgroundColor = [UIColor blueColor];
    startConversationButton.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:20];
    startConversationButton.titleLabel.textColor = [UIColor whiteColor];
    startConversationButton.titleLabel.text = @"Start Conversation";
    [startConversationButton setTitle:@"Start Match" forState:UIControlStateNormal];
    startConversationButton.tag = 101;
    
    [startConversationButton addTarget:self action:@selector(startMatch:) forControlEvents:UIControlEventTouchUpInside];
    [sureMatchView addSubview:notWhoIWantedButton];
    [sureMatchView addSubview:startConversationButton];
    
    bgDarkenView = [[UIView alloc] initWithFrame:self.view.bounds];
    bgDarkenView.backgroundColor = [UIColor blackColor];
    bgDarkenView.alpha = 0.7;
    [self.view addSubview:bgDarkenView];
    [self.view addSubview:sureMatchView];
    
}

-(void)startMatch:(id)sender
{
    //send an acceptance back through the MPDataHandler
    [MPDataHandler acceptChallenge:self.challengerUserID];
    
    //[bgDarkenView removeFromSuperview];
    // [sureMatchView removeFromSuperview];
    [[sureMatchView viewWithTag:101] removeFromSuperview];
    [[sureMatchView viewWithTag:102] removeFromSuperview];
    
    UIActivityIndicatorView *actIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [actIndicator setFrame:CGRectMake(10,360,sureMatchView.frame.size.width-20,50)];
    
    self.currentLoadStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 410, SCREEN_WIDTH, 40)];
    [self.currentLoadStateLabel setCenter:CGPointMake(sureMatchView.frame.size.width/2, 430)];
    [self.currentLoadStateLabel setFont:[UIFont fontWithName:cardMainFont size:16]];
    [self.currentLoadStateLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.currentLoadStateLabel setText:@"Loading..."];
    [sureMatchView addSubview:actIndicator];
    [sureMatchView addSubview:self.currentLoadStateLabel];
    
    [actIndicator startAnimating];
    
}

-(void)rejectMatch:(id)sender
{
    
    [bgDarkenView removeFromSuperview];
    [sureMatchView removeFromSuperview];
    
    //send rejectMessage
    [MPDataHandler rejectChallenge:self.challengerUserID withReason:@"Rejected Challenge"];
    
    
}

//playerobj follows clientStateMutable on multiplayerDataHandler
/*
 [clientStateMutable setObject:eloVal forKey:@"eloRating"];
 [clientStateMutable setObject:userName forKey:@"usernameCustom"];
 [clientStateMutable setObject:userObj.objectId forKey:@"userID"];
 [clientStateMutable setObject:@"Lobby" forKey:@"gameState"];
 */
-(void)displayChallengeUI:(NSDictionary *)playerObj
{
    NSString *playerUserName = [playerObj objectForKey:@"usernameCustom"];
    NSString *eloRating = [[playerObj objectForKey:@"eloRating"] stringValue];
    
    //show a popup announcing the challenge.
    sureMatchView = [[UIView alloc] initWithFrame:CGRectMake(20,70,self.view.frame.size.width-40,450)];
    sureMatchView.backgroundColor = [UIColor whiteColor];
    CALayer *sureMatchLayer = sureMatchView.layer;
    sureMatchLayer.cornerRadius = 8.0f;
    
    
    UILabel *sureMatchTitle = [[UILabel alloc] initWithFrame:CGRectMake(20,20,sureMatchView.frame.size.width-40,40)];
    sureMatchTitle.text = @"You Have Challenged A Player!";
    sureMatchTitle.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:24];
    sureMatchTitle.textAlignment = NSTextAlignmentCenter;
    
    [sureMatchView addSubview:sureMatchTitle];
    
    
    UILabel *sureMatchCaseNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,70,300,50)];
    
    sureMatchCaseNameLabel.font =[UIFont fontWithName:@"Futura-CondensedMedium" size:25];
    
    
    sureMatchCaseNameLabel.text = [[[playerUserName stringByAppendingString:@" ("] stringByAppendingString:eloRating] stringByAppendingString:@")"];
    
    
    UIImageView *sureMatchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10,120,150,150)];
    
    //check to see if there is a caseProfile for this caseID
    NSString *defaultMatchImgFileName = [[NSBundle mainBundle] pathForResource:@"angryorc" ofType:@"jpeg"];
    sureMatchImageView.image = [UIImage imageWithContentsOfFile:defaultMatchImgFileName];
    
    [sureMatchView addSubview:sureMatchCaseNameLabel];
    [sureMatchView addSubview:sureMatchImageView];
    
    NSError* error;
    NSString *eloDiff = [PFCloud callFunction:@"getELORatingOnWin" withParameters:@{
                                                                                    @"User1Rating" : [userPF objectForKey:@"eloRating"] , @"User2Rating": eloRating
                                                                                    } error:&error];
    
    
    if (!error){
        [userPF fetch];
        
        // NSNumber *newSelfEloRating =  [userPF objectForKey:@"eloRating"];
        NSLog(@"ELO Rating diff: %@", eloDiff);
        
        UILabel *ELORatingOnWin = [[UILabel alloc] initWithFrame:CGRectMake(165, 120, 110, 150)];
        ELORatingOnWin.textColor = [UIColor colorWithRed:9.0/255.0 green:127.0/255.0 blue:4.0/255.0 alpha:1.0];
        ELORatingOnWin.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:21];
        ELORatingOnWin.text = [NSString stringWithFormat:@"+%@ ELO Rating on WIN",eloDiff];
        ELORatingOnWin.numberOfLines = 3;
        ELORatingOnWin.textAlignment = NSTextAlignmentCenter;
        
        [sureMatchView addSubview:ELORatingOnWin];
        
    }
    
    
    //add two buttons for "Not Who I Wanted" and "Start a Conversation"
    UIButton *notWhoIWantedButton = [[UIButton alloc] initWithFrame:CGRectMake(10,300,sureMatchView.frame.size.width-20,50)];
    notWhoIWantedButton.backgroundColor = [UIColor redColor];
    notWhoIWantedButton.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:20];
    notWhoIWantedButton.titleLabel.textColor = [UIColor whiteColor];
    notWhoIWantedButton.titleLabel.text = @"Cancel Challenge";
    [notWhoIWantedButton setTitle:@"Cancel Challenge" forState:UIControlStateNormal];
    
    [notWhoIWantedButton addTarget:self action:@selector(cancelChallenge:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIActivityIndicatorView *actIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [actIndicator setFrame:CGRectMake(10,360,sureMatchView.frame.size.width-20,50)];
    
    self.currentLoadStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 410, SCREEN_WIDTH, 40)];
    [self.currentLoadStateLabel setCenter:CGPointMake(sureMatchView.frame.size.width/2, 430)];
    [self.currentLoadStateLabel setFont:[UIFont fontWithName:cardMainFont size:16]];
    [self.currentLoadStateLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.currentLoadStateLabel setText:@"Waiting for response..."];
    [sureMatchView addSubview:actIndicator];
    [sureMatchView addSubview:self.currentLoadStateLabel];
    
    [sureMatchView addSubview:_battleActivityLabel];
    [actIndicator startAnimating];
    
    
    /*
     UIButton *startConversationButton = [[UIButton alloc] initWithFrame:CGRectMake(10,360,sureMatchView.frame.size.width-20,50)];
     
     startConversationButton.backgroundColor = [UIColor blueColor];
     startConversationButton.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:20];
     startConversationButton.titleLabel.textColor = [UIColor whiteColor];
     startConversationButton.titleLabel.text = @"Start Conversation";
     [startConversationButton setTitle:@"Start Match" forState:UIControlStateNormal];
     
     [startConversationButton addTarget:self action:@selector(startMatch:) forControlEvents:UIControlEventTouchUpInside];
     */
    [sureMatchView addSubview:notWhoIWantedButton];
    //[sureMatchView addSubview:startConversationButton];
    
    bgDarkenView = [[UIView alloc] initWithFrame:self.view.bounds];
    bgDarkenView.backgroundColor = [UIColor blackColor];
    bgDarkenView.alpha = 0.7;
    
    [self.view addSubview:bgDarkenView];
    [self.view addSubview:sureMatchView];
    
}

-(void)displayQuickMatchUI
{
    
    //show a popup announcing the challenge.
    sureMatchView = [[UIView alloc] initWithFrame:CGRectMake(20,70,self.view.frame.size.width-40,300)];
    sureMatchView.center = self.view.center;
    sureMatchView.backgroundColor = [UIColor whiteColor];
    CALayer *sureMatchLayer = sureMatchView.layer;
    sureMatchLayer.cornerRadius = 8.0f;
    
    
    UILabel *sureMatchTitle = [[UILabel alloc] initWithFrame:CGRectMake(20,20,sureMatchView.frame.size.width-40,40)];
    sureMatchTitle.text = @"Quick Match!";
    sureMatchTitle.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:30];
    sureMatchTitle.textAlignment = NSTextAlignmentCenter;
    
    [sureMatchView addSubview:sureMatchTitle];
    
    
    /*UILabel *sureMatchCaseNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,70,300,50)];
     
     sureMatchCaseNameLabel.font =[UIFont fontWithName:@"Futura-CondensedMedium" size:25];
     
     
     sureMatchCaseNameLabel.text = [[[playerUserName stringByAppendingString:@" ("] stringByAppendingString:eloRating] stringByAppendingString:@")"];
     
     
     UIImageView *sureMatchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10,120,150,150)];
     
     //check to see if there is a caseProfile for this caseID
     NSString *defaultMatchImgFileName = [[NSBundle mainBundle] pathForResource:@"angryorc" ofType:@"jpeg"];
     sureMatchImageView.image = [UIImage imageWithContentsOfFile:defaultMatchImgFileName];
     
     [sureMatchView addSubview:sureMatchCaseNameLabel];
     [sureMatchView addSubview:sureMatchImageView];
     */
    //add two buttons for "Not Who I Wanted" and "Start a Conversation"
    UIButton *notWhoIWantedButton = [[UIButton alloc] initWithFrame:CGRectMake(10,140,sureMatchView.frame.size.width-20,50)];
    notWhoIWantedButton.backgroundColor = [UIColor redColor];
    notWhoIWantedButton.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:20];
    notWhoIWantedButton.titleLabel.textColor = [UIColor whiteColor];
    notWhoIWantedButton.titleLabel.text = @"Cancel";
    [notWhoIWantedButton setTitle:@"Cancel" forState:UIControlStateNormal];
    
    [notWhoIWantedButton addTarget:self action:@selector(cancelChallenge:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIActivityIndicatorView *actIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [actIndicator setFrame:CGRectMake(10,200,sureMatchView.frame.size.width-20,50)];
    
    self.currentLoadStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 410, SCREEN_WIDTH, 40)];
    [self.currentLoadStateLabel setCenter:CGPointMake(sureMatchView.frame.size.width/2, 270)];
    [self.currentLoadStateLabel setFont:[UIFont fontWithName:cardMainFont size:16]];
    [self.currentLoadStateLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.currentLoadStateLabel setText:@"Finding Opponent..."];
    [sureMatchView addSubview:actIndicator];
    [sureMatchView addSubview:self.currentLoadStateLabel];
    [self.noPlayersAvailableLabel setHidden:YES];
    
    [sureMatchView addSubview:_battleActivityLabel];
    [actIndicator startAnimating];
    
    
    /*
     UIButton *startConversationButton = [[UIButton alloc] initWithFrame:CGRectMake(10,360,sureMatchView.frame.size.width-20,50)];
     
     startConversationButton.backgroundColor = [UIColor blueColor];
     startConversationButton.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:20];
     startConversationButton.titleLabel.textColor = [UIColor whiteColor];
     startConversationButton.titleLabel.text = @"Start Conversation";
     [startConversationButton setTitle:@"Start Match" forState:UIControlStateNormal];
     
     [startConversationButton addTarget:self action:@selector(startMatch:) forControlEvents:UIControlEventTouchUpInside];
     
     [sureMatchView addSubview:notWhoIWantedButton];*/
    //[sureMatchView addSubview:startConversationButton];
    
    [sureMatchView addSubview:notWhoIWantedButton];
    
    bgDarkenView = [[UIView alloc] initWithFrame:self.view.bounds];
    bgDarkenView.backgroundColor = [UIColor blackColor];
    bgDarkenView.alpha = 0.7;
    
    [self.view addSubview:bgDarkenView];
    [self.view addSubview:sureMatchView];
    
}

-(void)cancelChallenge:(id)sender
{
    
    //send data through MPDataHandler to notify the other player the challenge is cancelled
    [MPDataHandler cancelChallenge];
    [self.noPlayersAvailableLabel setHidden:NO];
    [bgDarkenView removeFromSuperview];
    [sureMatchView removeFromSuperview];
    
}

-(void)notifyPlayerOfCancelChallenge
{
    if(bgDarkenView !=nil)
    {
        
        [bgDarkenView removeFromSuperview];
        [sureMatchView removeFromSuperview];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Challenger Cancelled" message:@"The Challenging Player Cancelled or Left" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

//called by MPDataHandler, dismiss screen shown that the player is challenging another
-(void)dismissChallengeUI:(NSString *)reason
{
    if(bgDarkenView !=nil)
    {
        
        [bgDarkenView removeFromSuperview];
        [sureMatchView removeFromSuperview];
    }
    NSString *rejectionString = [@"Reason: " stringByAppendingString:reason];
    
    if (![reason isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Player Rejected Challenge" message:rejectionString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)searchForQuickMatchUI
{
    //show a popup announcing the challenge.
    sureMatchView = [[UIView alloc] initWithFrame:CGRectMake(20,70,self.view.frame.size.width-40,450)];
    sureMatchView.backgroundColor = [UIColor whiteColor];
    CALayer *sureMatchLayer = sureMatchView.layer;
    sureMatchLayer.cornerRadius = 8.0f;
    
    UILabel *sureMatchTitle = [[UILabel alloc] initWithFrame:CGRectMake(20,20,sureMatchView.frame.size.width-40,40)];
    sureMatchTitle.text = @"Quick Match!";
    sureMatchTitle.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:30];
    sureMatchTitle.textAlignment = NSTextAlignmentCenter;
    
    [sureMatchView addSubview:sureMatchTitle];
    
    
    UILabel *sureMatchCaseNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,70,300,50)];
    
    sureMatchCaseNameLabel.font =[UIFont fontWithName:@"Futura-CondensedMedium" size:25];
    
    sureMatchCaseNameLabel.text = @"Looking For Match...";
    
    UIImageView *sureMatchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10,120,150,150)];
    
    //check to see if there is a caseProfile for this caseID
    NSString *defaultMatchImgFileName = [[NSBundle mainBundle] pathForResource:@"angryorc" ofType:@"jpeg"];
    sureMatchImageView.image = [UIImage imageWithContentsOfFile:defaultMatchImgFileName];
    
    [sureMatchView addSubview:sureMatchCaseNameLabel];
    [sureMatchView addSubview:sureMatchImageView];
    
    //add two buttons for "Not Who I Wanted" and "Start a Conversation"
    UIButton *notWhoIWantedButton = [[UIButton alloc] initWithFrame:CGRectMake(10,300,sureMatchView.frame.size.width-20,50)];
    notWhoIWantedButton.backgroundColor = [UIColor redColor];
    notWhoIWantedButton.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:20];
    notWhoIWantedButton.titleLabel.textColor = [UIColor whiteColor];
    notWhoIWantedButton.titleLabel.text = @"Cancel Quick Match";
    [notWhoIWantedButton setTitle:@"Cancel Quick Match" forState:UIControlStateNormal];
    
    [notWhoIWantedButton addTarget:self action:@selector(cancelChallenge:) forControlEvents:UIControlEventTouchUpInside];
    /*
     UIButton *startConversationButton = [[UIButton alloc] initWithFrame:CGRectMake(10,360,sureMatchView.frame.size.width-20,50)];
     
     startConversationButton.backgroundColor = [UIColor blueColor];
     startConversationButton.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:20];
     startConversationButton.titleLabel.textColor = [UIColor whiteColor];
     startConversationButton.titleLabel.text = @"Start Conversation";
     [startConversationButton setTitle:@"Start Match" forState:UIControlStateNormal];
     
     [startConversationButton addTarget:self action:@selector(startMatch:) forControlEvents:UIControlEventTouchUpInside];
     */
    [sureMatchView addSubview:notWhoIWantedButton];
    [sureMatchView.layer setZPosition:1.0];
    //[sureMatchView addSubview:startConversationButton];
    
    bgDarkenView = [[UIView alloc] initWithFrame:self.view.bounds];
    bgDarkenView.backgroundColor = [UIColor blackColor];
    bgDarkenView.alpha = 0.7;
    
    [self.view addSubview:bgDarkenView];
    [self.view addSubview:sureMatchView];
}

-(void)refreshLobby:(id)sender
{
    //get participants
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [MPDataHandler getPubNubConnectedPlayers];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self startConnectingPubNub];
    [super viewWillAppear:animated];
    [self resetAllVariables];
    
    
}
-(void)resetAllVariables
{
    [self refreshLobby:self];
    [sureMatchView removeFromSuperview];
    [bgDarkenView removeFromSuperview];
    [MPDataHandler setInChallengeProcess:NO];
    [MPDataHandler setQuickMatchLock:NO];
    [MPDataHandler setQuickMatchChannel:nil];
    [MPDataHandler setOpponentIDChallenged:@""];
    [MPDataHandler setFirstQuickMatchEnabled:NO];
    [MPDataHandler resetAllMPVariables];
    //[MPDataHandler resetAllMPVariables];
}


@end
