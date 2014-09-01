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
#import "SinglePlayerMenuViewController.h"
#import "CampaignMenuViewController.h"

@interface MainScreenViewController ()

@end

@implementation MainScreenViewController

int SCREEN_WIDTH, SCREEN_HEIGHT;
UILabel *loadingLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    
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
    
    //some temporary stuff
    /*
    UILabel *tempTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    tempTitle.center = CGPointMake(self.view.bounds.size.width/2, 50);
    tempTitle.textAlignment = NSTextAlignmentCenter;
    tempTitle.text = @"Card Game Temporary Menu";
    tempTitle.textColor = [UIColor whiteColor];
    
    [self.view addSubview:tempTitle];
     */
    
    UIImageView*menuLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_logo"]];
    menuLogo.frame = CGRectMake(0,0,250,200);
    menuLogo.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/4);
    
    CFLabel*menuLogoBackground = [[CFLabel alloc] initWithFrame:CGRectInset(menuLogo.frame, 0, 15)];
    menuLogoBackground.center = menuLogo.center;
    [self.view addSubview:menuLogoBackground];
    [self.view addSubview:menuLogo];
    
    CFButton *singlePlayerButton = [[CFButton alloc] initWithFrame: CGRectMake(0, 0, 100, 100)];
    [singlePlayerButton setTextSize:12];
    singlePlayerButton.frame = CGRectMake(0, 0, 100, 100);
    singlePlayerButton.center = CGPointMake(self.view.bounds.size.width/3 - 5, self.view.bounds.size.height*2/3 - 58);
    [singlePlayerButton setTitle:@"Singleplayer" forState:UIControlStateNormal];
    [singlePlayerButton addTarget:self action:@selector(singlePlayerButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:singlePlayerButton];
    
    CFButton *multiPlayerButton = [[CFButton alloc] initWithFrame: CGRectMake(0, 0, 100, 100)];
    [multiPlayerButton setTextSize:12];
    multiPlayerButton.frame = CGRectMake(0, 0, 100, 100);
    multiPlayerButton.center = CGPointMake(self.view.bounds.size.width*2/3 + 5, self.view.bounds.size.height*2/3 - 58);
    [multiPlayerButton setTitle:@"Multiplayer" forState:UIControlStateNormal];
    [multiPlayerButton addTarget:self action:@selector(multiPlayerButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:multiPlayerButton];
    
    CFButton *deckButton = [[CFButton alloc] initWithFrame: CGRectMake(0, 0, 100, 100)];
    [deckButton setTextSize:12];
    deckButton.center = CGPointMake(self.view.bounds.size.width/3 - 5, self.view.bounds.size.height*2/3 + 58);
    [deckButton setTitle:@"Deck Builder" forState:UIControlStateNormal];
    [deckButton addTarget:self action:@selector(deckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:deckButton];
    
    CFButton *storeButton = [[CFButton alloc] initWithFrame: CGRectMake(0, 0, 100, 100)];
    [storeButton setTextSize:12];
    storeButton.frame = CGRectMake(0, 0, 100, 100);
    storeButton.center = CGPointMake(self.view.bounds.size.width*2/3 + 5, self.view.bounds.size.height*2/3 + 58);
    [storeButton setTitle:@"Cards Store" forState:UIControlStateNormal];
    [storeButton addTarget:self action:@selector(storeButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:storeButton];
    
    UIButton *messageButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,30,30)];
    [messageButton setImage:MESSAGE_ICON_IMAGE forState:UIControlStateNormal];
    messageButton.center = CGPointMake(SCREEN_WIDTH - 95, SCREEN_HEIGHT - 32);
    [self.view addSubview:messageButton];
    _messageCountLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(-10, 6, 50, 30)];
    _messageCountLabel.textAlignment = NSTextAlignmentCenter;
    _messageCountLabel.textColor = [UIColor whiteColor];
    _messageCountLabel.font = [UIFont fontWithName:cardMainFont size:16];
    _messageCountLabel.strokeOn = YES;
    _messageCountLabel.strokeColour = [UIColor blackColor];
    _messageCountLabel.strokeThickness = 3;
    [messageButton addTarget:self action:@selector(messageButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //TODO
    //_messageCountLabel.text = [NSString stringWithFormat:@"%d", 999];
    
    [messageButton addSubview:_messageCountLabel];
    
    UIButton *optionsButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,30,30)];
    [optionsButton setImage:OPTION_ICON_IMAGE forState:UIControlStateNormal];
    optionsButton.center = CGPointMake(SCREEN_WIDTH - 60, SCREEN_HEIGHT - 32);
    [self.view addSubview:optionsButton];
    
    [optionsButton addTarget:self action:@selector(optionButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //initial loading TODO
    if (!userInfoLoaded)
    {
        _gameLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_gameLoadingView setColor:COLOUR_INTERFACE_BLUE];
        [_gameLoadingView setFrame:self.view.bounds];
        [_gameLoadingView setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:1 alpha:0.8]];
        [_gameLoadingView setUserInteractionEnabled:YES];
        loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
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

-(void)messageButtonPressed
{
    MessagesViewController *vc = [[MessagesViewController alloc] init];
    [self presentViewController:vc animated:NO completion:nil];
}

-(void)optionButtonPressed
{
    
}

//checks for userInfoLoaded flag to be set to YES. Once it does, remove the loading screen.
-(void)checkForLoadFinish
{
    if (userInitError)
    {
        loadingLabel.text = @"Error loading game.";
        [_gameLoadingView setColor:[UIColor clearColor]];
    }
    else if (userInfoLoaded)
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

-(void)singlePlayerButtonPressed
{
    /*
    CampaignMenuViewController *viewController = [[CampaignMenuViewController alloc] init];
    [self presentViewController:viewController animated:NO completion:nil];
     */
    SinglePlayerMenuViewController *viewController = [[SinglePlayerMenuViewController alloc] init];
    [self presentViewController:viewController animated:NO completion:nil];
}

-(void)multiPlayerButtonPressed
{
    
}

-(void)deckButtonPressed
{
    DeckEditorViewController *viewController = [[DeckEditorViewController alloc] init];
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
