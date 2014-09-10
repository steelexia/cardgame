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
@interface MultiplayerGameViewController () <MultiplayerNetworkingProtocol>

@end

@implementation MultiplayerGameViewController
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
                     completion:nil];
}
//brian sep 9 2014
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



//brian sep 9
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(showAuthenticationViewController)
     name:PresentAuthenticationViewController
     object:nil];
    
    [[GameKitHelper sharedGameKitHelper]
     authenticateLocalPlayer];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerAuthenticated)
                                                 name:LocalPlayerIsAuthenticated object:nil];
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

@end
