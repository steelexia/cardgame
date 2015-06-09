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
#import "MultiplayerGameViewController.h"
#import "CampaignMenuViewController.h"
#import "Campaign.h"
#import "PNImports.h"
#import "AppDelegate.h"


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
        
        _singlePlayerButton = [[CFButton alloc] initWithFrame: CGRectMake(0, 0, 100, 100)];
        [_singlePlayerButton setTextSize:12];
        _singlePlayerButton.frame = CGRectMake(0, 0, 100, 100);
        _singlePlayerButton.center = CGPointMake(self.view.bounds.size.width/3 - 5, self.view.bounds.size.height*2/3 - 58);
        _singlePlayerButton.label.text = @"Singleplayer";
        [_singlePlayerButton addTarget:self action:@selector(singlePlayerButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_singlePlayerButton];
        
        _multiPlayerButton = [[CFButton alloc] initWithFrame: CGRectMake(0, 0, 100, 100)];
        [_multiPlayerButton setTextSize:12];
        _multiPlayerButton.frame = CGRectMake(0, 0, 100, 100);
        _multiPlayerButton.center = CGPointMake(self.view.bounds.size.width*2/3 + 5, self.view.bounds.size.height*2/3 - 58);
        _multiPlayerButton.label.text = @"Multiplayer";
        [_multiPlayerButton addTarget:self action:@selector(multiPlayerButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_multiPlayerButton];
        
        _deckButton = [[CFButton alloc] initWithFrame: CGRectMake(0, 0, 100, 100)];
        [_deckButton setTextSize:12];
        _deckButton.center = CGPointMake(self.view.bounds.size.width/3 - 5, self.view.bounds.size.height*2/3 + 58);
        _deckButton.label.text = @"Deck Builder";
        [_deckButton addTarget:self action:@selector(deckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_deckButton];
        
        _storeButton = [[CFButton alloc] initWithFrame: CGRectMake(0, 0, 100, 100)];
        [_storeButton setTextSize:12];
        _storeButton.frame = CGRectMake(0, 0, 100, 100);
        _storeButton.center = CGPointMake(self.view.bounds.size.width*2/3 + 5, self.view.bounds.size.height*2/3 + 58);
        _storeButton.label.text = @"Store";
        [_storeButton addTarget:self action:@selector(storeButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_storeButton];
        
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
    
    //[self setPubNubConfigDetails2];
    
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [PFUser currentUser];
    [installation saveInBackground];
}

-(void) setPubNubConfigDetails
{
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
                                                                  publishKey:@"pub-c-d1465391-f40c-44e3-8fc9-9d92be0a63c5" subscribeKey:@"sub-c-cac0d926-d8ab-11e4-8301-0619f8945a4f" secretKey:@"sec-c-MzAzYzM3ZGMtZjFmNC00Mjk3LTkxOTEtMTRmNzUxNDBjYzdi"];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    configuration.presenceHeartbeatInterval = 10;
    
    [PubNub setConfiguration:configuration];
    
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        //NSLog(origin);
        NSLog(@"connect success flagged here");
        
    } errorBlock:^(PNError *error) {
        NSLog(error.localizedDescription);
    }];
    
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:appDelegate withCallbackBlock:^(NSString *origin, BOOL connected, PNError *connectionError){
        if (connected)
        {
            NSLog(@"OBSERVER: Successful Connection!");
        }
        else if (!connected || connectionError)
        {
            NSLog(@"OBSERVER: Error %@, Connection Failed!", connectionError.localizedDescription);
        }
    }];
    
    [[PNObservationCenter defaultCenter] addChannelParticipantsListProcessingObserver:appDelegate withBlock:^(PNHereNow *presenceInformation, NSArray *channels, PNError *error) {
        NSLog(@"OBSERVER: addChannelParticipantsListProcessingObserver: list: %@, on Channel: %@", presenceInformation, channels);
    }];
    
    // #4 Add the +addClientPresenceEnablingObserver+ to catch when presence has been enabled.
    [[PNObservationCenter defaultCenter] addClientPresenceEnablingObserver:appDelegate withCallbackBlock:^(NSArray *channel, PNError *error) {
        NSLog(@"OBSERVER: Enabled on Channel: %@",channel.description);
        switch(channel.count){
                
        }
    }];
    
}

-(void) setPubNubConfigDetails2
{
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
                                                                  publishKey:@"pub-c-d1465391-f40c-44e3-8fc9-9d92be0a63c5" subscribeKey:@"sub-c-cac0d926-d8ab-11e4-8301-0619f8945a4f" secretKey:@"sec-c-MzAzYzM3ZGMtZjFmNC00Mjk3LTkxOTEtMTRmNzUxNDBjYzdi"];
    
    NSString *uuid = [NSString stringWithFormat:@"Mike_Stubbs"];
    [PubNub setClientIdentifier:uuid];
    configuration.presenceHeartbeatInterval = 10;
    configuration.presenceHeartbeatTimeout = 30;
    [PubNub setConfiguration:configuration];
    [PubNub connect];
    
    // #1 Define our channel name with +PNChannel+.
    PNChannel *my_channel = [PNChannel channelWithName:@"demo2"
                                 shouldObservePresence:NO];
    
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self withCallbackBlock:^(NSString *origin, BOOL connected, PNError *connectionError){
        
        if (connected)
        {
            NSLog(@"OBSERVER: Successful Connection!");
            
            // #2 +subscribeOnChannel+ if the client connects successfully.
           // [PubNub subscribeOnChannel:my_channel];
            [PubNub subscribeOn:@[my_channel]];
            
        }
        else if (!connected || connectionError)
        {
            NSLog(@"OBSERVER: Error %@, Connection Failed!", connectionError.localizedDescription);
        }
        
    }];
    [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error){
        
        switch (state) {
            case PNSubscriptionProcessSubscribedState:
            {
                // #3 enable presence if isPresenceObservationEnabledForChannel is false.
                BOOL enabled = [PubNub isPresenceObservationEnabledForChannel:my_channel];
                NSLog(@"OBSERVER: Subscribed to Channel: %@, Presence enabled:%hhd", channels[0], enabled);
                if (!enabled) {
                    [PubNub enablePresenceObservationForChannel:my_channel];
                }
                break;
            }
            case PNSubscriptionProcessNotSubscribedState:
                NSLog(@"OBSERVER: Not subscribed to Channel: %@, Error: %@", channels[0], error);
                break;
            case PNSubscriptionProcessWillRestoreState:
                NSLog(@"OBSERVER: Will re-subscribe to Channel: %@", channels[0]);
                break;
            case PNSubscriptionProcessRestoredState:
                NSLog(@"OBSERVER: Re-subscribed to Channel: %@", channels[0]);
                break;
        }
    }];
    
    // #4 Add the +addClientPresenceEnablingObserver+ to catch when presence has been enabled.
    [[PNObservationCenter defaultCenter] addClientPresenceEnablingObserver:self withCallbackBlock:^(NSArray *channel, PNError *error) {
        NSLog(@"OBSERVER: Enabled on Channel: %@",channel.description);
        switch(channel.count){
                
        }
    }];
    
    // #1 Add the +addPresenceEventObserver+ which will catch events received on the channel.
    [[PNObservationCenter defaultCenter] addPresenceEventObserver:self withBlock:^(PNPresenceEvent *event) {
        // NSLog(@"OBSERVER: Presence: %u", event.type);
        
        // #2 Add logic that sends messages to the channel based on the type of event received.
        switch (event.type) {
            case PNPresenceEventJoin:
                [PubNub sendMessage:[NSString stringWithFormat:@"%@ Says: What's Happening?!",uuid ] toChannel:my_channel ];
                break;
            case PNPresenceEventLeave:
                [PubNub sendMessage:[NSString stringWithFormat:@"%@ Says: Catch you on the flip side!",uuid ] toChannel:my_channel ];
                break;
            case PNPresenceEventTimeout:
                [PubNub sendMessage:[NSString stringWithFormat:@"%@ Says: Too Bad!",uuid ] toChannel:my_channel ];
                break;
            default:
                break;
        }
        
        // #3. Add logic that sends messages to the channel based on channel occupancy.
        switch (event.occupancy) {
            case 1:
                [PubNub sendMessage:[NSString stringWithFormat:@"%@ Says: It's a ghost town.",uuid ] toChannel:my_channel ];
                break;
            case 2:
                [PubNub sendMessage:[NSString stringWithFormat:@"%@ Says: It takes two to make a thing go right.",uuid ] toChannel:my_channel ];
                break;
            case 3:
                [PubNub sendMessage:[NSString stringWithFormat:@"%@ Says: Three people is a party!" ,uuid ] toChannel:my_channel ];
                break;
            default:
                break;
        }
    }];

}

-(void)viewWillAppear:(BOOL)animated
{
    //query for the messages
    PFQuery *messagesQuery = [PFQuery queryWithClassName:@"Message"];
    PFUser *user = [PFUser currentUser];
    
    [messagesQuery whereKey:@"userPointer" equalTo:user.objectId];
    
    [messagesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.messageCountLabel.text = [NSString stringWithFormat:@"%ld",objects.count];
        self.messagesRetrieved = objects;
        
    }];
    
    
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //_storeButton.label.text = @"Store";
    
    NSLog(@"did appear");
    
    if (!_loadedTutorial)
    {
        NSLog(@"not loaded tut");
        
        //if user is still in tutorial, automatically jump to tutorial
        NSArray*completedLevels = userPF[@"completedLevels"];
        Level*tutLevel;
        
        //TODO these are copypasta from CampaignMenuViewController's levelButtonPressed
        if (![completedLevels containsObject:@"d_1_c_1_l_1"])
        {
            tutLevel = [Campaign getLevelWithDifficulty:1 withChapter:1 withLevel:1];
        }
        else if (![completedLevels containsObject:@"d_1_c_1_l_2"])
        {
            tutLevel = [Campaign getLevelWithDifficulty:1 withChapter:1 withLevel:2];
        }
        else if (![completedLevels containsObject:@"d_1_c_1_l_4"])
        {
            tutLevel = [Campaign getLevelWithDifficulty:1 withChapter:1 withLevel:3];
        }
        
        if (tutLevel != nil)
        {
            NSLog(@"tut not null");
            GameViewController *gvc = [[GameViewController alloc] initWithGameMode:GameModeSingleplayer withLevel:tutLevel];
            gvc.noPreviousView = YES;
            
            /*
             DeckChooserViewController *dcvc = [[DeckChooserViewController alloc] init];
             if (tutLevel.isTutorial)
             dcvc.noPickDeck = YES;
             dcvc.opponentName = tutLevel.opponentName;
             
             dcvc.nextScreen = gvc;
             [dcvc.backButton setEnabled:NO];*/
            
            [self presentViewController:gvc animated:NO completion:nil];
            NSLog(@"tried appear");
        }
        _loadedTutorial = YES;
    }
}



-(void)messageButtonPressed
{
    MessagesViewController *vc = [[MessagesViewController alloc] init];
    vc.messagesRetrieved = self.messagesRetrieved;
    
    [self presentViewController:vc animated:NO completion:nil];
}

-(void)optionButtonPressed
{
    OptionsViewController *vc = [[OptionsViewController alloc] init];
    [self presentViewController:vc animated:NO completion:nil];
}

-(void)singlePlayerButtonPressed
{
    SinglePlayerMenuViewController *viewController = [[SinglePlayerMenuViewController alloc] init];
    [self presentViewController:viewController animated:NO completion:nil];
}

-(void)multiPlayerButtonPressed
{
    MultiplayerGameViewController *mgvc = [[MultiplayerGameViewController alloc] init];
    
    DeckChooserViewController *dcv = [[DeckChooserViewController alloc] init];
    dcv.nextScreen = mgvc;
    dcv.isMultiplayer = YES;
    [self presentViewController:dcv animated:YES completion:nil];
}

-(void)deckButtonPressed
{
    DeckEditorViewController *viewController = [[DeckEditorViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)storeButtonPressed
{
    StoreViewController *viewController = [[StoreViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
