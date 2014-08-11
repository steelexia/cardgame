//
//  MainScreenViewController.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-27.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "MainScreenViewController.h"
#import "DeckChooserViewController.h"
#import "CardEditorViewController.h"
#import "StoreViewController.h"
#import "UIConstants.h"

@interface MainScreenViewController ()

@end

@implementation MainScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //some temporary stuff
    UILabel *tempTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    tempTitle.center = CGPointMake(self.view.bounds.size.width/2, 50);
    tempTitle.textAlignment = NSTextAlignmentCenter;
    tempTitle.text = @"Card Game Temporary Menu";
    
    [self.view addSubview:tempTitle];
    
    UIButton *gameButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    gameButton.frame = CGRectMake(0, 0, 200, 40);
    gameButton.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2 - 80);
    [gameButton setTitle:@"Play Against AI" forState:UIControlStateNormal];
    [gameButton addTarget:self action:@selector(gameButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:gameButton];
    
    UIButton *deckButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    deckButton.frame = CGRectMake(0, 0, 200, 40);
    deckButton.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2 - 0);
    [deckButton setTitle:@"Deck Builder" forState:UIControlStateNormal];
    [deckButton addTarget:self action:@selector(deckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:deckButton];
    
    UIButton *cardButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cardButton.frame = CGRectMake(0, 0, 200, 40);
    cardButton.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2 + 80);
    [cardButton setTitle:@"Card Editor" forState:UIControlStateNormal];
    [cardButton addTarget:self action:@selector(cardButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:cardButton];
    
    UIButton *storeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    storeButton.frame = CGRectMake(0, 0, 200, 40);
    storeButton.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2 + 160);
    [storeButton setTitle:@"Cards Store" forState:UIControlStateNormal];
    [storeButton addTarget:self action:@selector(storeButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:storeButton];
    
    //initial loading TODO
    if (!userInfoLoaded)
    {
        _gameLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_gameLoadingView setColor:COLOUR_INTERFACE_BLUE];
        [_gameLoadingView setFrame:self.view.bounds];
        [_gameLoadingView setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:1 alpha:0.8]];
        [_gameLoadingView setUserInteractionEnabled:YES];
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        loadingLabel.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2 + 60);
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        loadingLabel.textColor = COLOUR_INTERFACE_BLUE;
        loadingLabel.font = [UIFont fontWithName:cardMainFont size:20];
        loadingLabel.text = [NSString stringWithFormat:@"Loading Game..."];
        [_gameLoadingView addSubview:loadingLabel];
        
        [self.view addSubview:_gameLoadingView];
        [_gameLoadingView startAnimating];
        [self checkForLoadFinish];
    }
}

//checks for userInfoLoaded flag to be set to YES. Once it does, remove the loading screen.
-(void)checkForLoadFinish
{
    if (userInfoLoaded)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _gameLoadingView.alpha = 0;
                         }
                         completion:^(BOOL completed){
                             [_gameLoadingView stopAnimating];
                             [_gameLoadingView removeFromSuperview];
                         }];
    }
    else
    {
        //keep checking
        [self performBlock:^{
            [self checkForLoadFinish];
        } afterDelay:0.2];
    }
}

-(void)gameButtonPressed
{
    GameViewController *gvc = [[GameViewController alloc] init];
    DeckChooserViewController*dcvc = [[DeckChooserViewController alloc]init];
    dcvc.nextScreen = gvc;
    [self presentViewController:dcvc animated:YES completion:nil];
}

-(void)deckButtonPressed
{
    DeckEditorViewController *viewController = [[DeckEditorViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)cardButtonPressed
{
    CardEditorViewController *viewController = [[CardEditorViewController alloc] initWithMode:cardEditorModeCreation WithCard:nil];
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)storeButtonPressed
{
    StoreViewController *viewController = [[StoreViewController alloc] init];
    viewController.previousScreen = [[MainScreenViewController alloc]init];
    [self presentViewController:viewController animated:YES completion:nil];
}

//block delay functions
- (void)performBlock:(void (^)())block
{
    block();
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay
{
    void (^block_)() = [block copy]; // autorelease this if you're not using ARC
    [self performSelector:@selector(performBlock:) withObject:block_ afterDelay:delay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
