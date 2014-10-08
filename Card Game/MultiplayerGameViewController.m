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
@interface MultiplayerGameViewController () <MultiplayerNetworkingProtocol>


@end

@implementation MultiplayerGameViewController

/** Screen dimension for convinience */
int SCREEN_WIDTH, SCREEN_HEIGHT;

BOOL playerAuthenticated;

MultiplayerNetworking *_networkingEngine;
NSUInteger _currentPlayerIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
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
    
    
    CFLabel*menuLogoBackground = [[CFLabel alloc] initWithFrame:CGRectMake(0,0,250,100)];
    menuLogoBackground.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/4);
    menuLogoBackground.label.textAlignment = NSTextAlignmentCenter;
    [menuLogoBackground setTextSize:30];
    menuLogoBackground.label.text = @"Multiplayer";
    [self.view addSubview:menuLogoBackground];
    
    CFButton* startButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    startButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 100);
    [startButton.label setText:@"Start"];
    [startButton addTarget:self action:@selector(startGameCenterButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startButton];
    
    
    UIButton* backButton = [[CFButton alloc] initWithFrame:CGRectMake(35, SCREEN_HEIGHT - 32 - 20, 46, 32)];
    [backButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    
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
    [self startGameCenterButtonPressed];
}

//brian sep 9
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"appeared");
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
                         [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              _activityIndicator.alpha = 0;
                                          }
                                          completion:^(BOOL completed){
                                              [_activityIndicator stopAnimating];
                                              [_activityIndicator removeFromSuperview];
                                          }];
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
    _gvc.networkingEngine = _networkingEngine;
    [_gvc setPlayerSeed:_networkingEngine.playerSeed];
    [_gvc setOpponentSeed:_networkingEngine.opponentSeed];
    
    if (![_networkingEngine isLocalPlayerPlayer1])
    {
        [_gvc setCurrentSide:OPPONENT_SIDE];
    }
    
    _dcvc = [[DeckChooserViewController alloc] init];
    _dcvc.isMultiplayer = YES;
    _dcvc.networkingEngine = _networkingEngine;
    
    _networkingEngine.deckChooserDelegate = _dcvc;
    _networkingEngine.gameDelegate = _gvc;
    
    if ([_networkingEngine indexForLocalPlayer] == 0)
        _dcvc.opponentName = _playerTwoAlias;
    else
        _dcvc.opponentName = _playerOneAlias;
    
    _dcvc.nextScreen = _gvc;
    
    [self presentViewController:_dcvc animated:YES completion:nil];
}


- (void)matchEnded {
    if (self.gameEndedBlock) {
        self.gameEndedBlock();
    }
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            DeckModel *deck = [UserModel downloadDeckFromPF:deckPF];
            NSArray*cards = deckPF[@"cards"];
            NSLog(@"count PF: %d local: %d", [cards count], deck.count);
            
            if (deck != nil)
            {
                [_gvc setOpponentDeck:deck];
                [_dcvc receivedOpponentDeck];
                [_networkingEngine sendReceivedDeck]; //tells other player deck is received
                
                NSLog(@"finished receiving opponent deck");
            }
            else
            {
                //TODO ERROR
                NSLog(@"getDeckFromPF returned nil");
            }
        });
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

-(void)matchCancelled
{
    //TODO
}

-(void)matchFailed:(NSError*)error
{
    //TODO
}

@end
