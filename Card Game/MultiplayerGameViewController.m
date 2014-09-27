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
@interface MultiplayerGameViewController () <MultiplayerNetworkingProtocol>

@end

@implementation MultiplayerGameViewController

/** Screen dimension for convinience */
int SCREEN_WIDTH, SCREEN_HEIGHT;

BOOL playerAuthenticated;

//brian sep 9
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
    
    
    [self startGameCenterButtonPressed];
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


- (IBAction)touchMoveButton:(id)sender {
    //do code to send a move to other player via network engine
    if (_currentPlayerIndex == -1) {
        return;
    }
    
    [_networkingEngine sendMove];
}

MultiplayerNetworking *_networkingEngine;
NSUInteger _currentPlayerIndex;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
        //[_players[idx] setPlayerAliasText:playerAlias];
        NSLog(@"Player Alias is..");
        
        NSLog(playerAlias);
        
    }];
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



@end
