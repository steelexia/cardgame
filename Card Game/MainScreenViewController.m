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
@import AudioToolbox;


@interface MainScreenViewController ()

@end

@implementation MainScreenViewController

int SCREEN_WIDTH, SCREEN_HEIGHT;
UILabel *loadingLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    SCREEN_WIDTH = [[UIScreen mainScreen] bounds].size.width;
    SCREEN_HEIGHT = [[UIScreen mainScreen] bounds].size.height;
    
    float mockupHeight = 1136.0f;
    float mockupWidth = 640.0f;
    
    //background view
    /*
    UIImageView*backgroundImageTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_background_top"]];
    backgroundImageTop.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    [self.view addSubview:backgroundImageTop];
    
    UIImageView*backgroundImageMiddle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_background_center"]];
    backgroundImageMiddle.frame = CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - 40 - 40);
    [self.view addSubview:backgroundImageMiddle];
    
    UIImageView*backgroundImageBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_background_bottom"]];
    backgroundImageBottom.frame = CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, 40);
    [self.view addSubview:backgroundImageBottom];
    */
    
    UIImageView *mainBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WoodBackgroundWithFrames"]];
    mainBackground.frame = CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
    [self.view addSubview:mainBackground];
    
    
    //some temporary stuff
    /*
     UILabel *tempTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
     tempTitle.center = CGPointMake(self.view.bounds.size.width/2, 50);
     tempTitle.textAlignment = NSTextAlignmentCenter;
     tempTitle.text = @"Card Game Temporary Menu";
     tempTitle.textColor = [UIColor whiteColor];
     
     [self.view addSubview:tempTitle];
     */
    
    /*
    UIImageView*menuLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_logo"]];
    menuLogo.frame = CGRectMake(0,0,250,200);
    menuLogo.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/4);
    */
    
    /*
        CFLabel*menuLogoBackground = [[CFLabel alloc] initWithFrame:CGRectInset(menuLogo.frame, 0, 15)];
        menuLogoBackground.center = menuLogo.center;
        [self.view addSubview:menuLogoBackground];
        [self.view addSubview:menuLogo];
        */
    
    
    UIImageView *flagBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopFlag2"]];
    
    //calculate height ratio for different pieces
    //iphone4S--480 height
    //iPhone5--568 height
    //iPhone6--667 height
    
    //flag iPhone 6 resolutions
    //366 height, 206y
    float topFlagHeightRatio = 366/mockupHeight;
    float topFlagYPositionRatio = 206/mockupHeight;
    
    flagBG.frame = CGRectMake(0,SCREEN_HEIGHT*topFlagYPositionRatio,SCREEN_WIDTH,SCREEN_HEIGHT*topFlagHeightRatio);
    [self.view addSubview:flagBG];
    
    //UIImageView *topMetalFrame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MetalFrame"]];
    //topMetalFrame.frame = CGRectMake(-40,20,SCREEN_WIDTH+100,63);
    
    //label1 yPositionRatio—238Y,60x,28H,206W
    //label2 xpositionRatio—370X,30H, 192W,240Y
    float singlePlayerLabelHeightRatio = 30/mockupHeight;
    float singlePlayerLabelWidthRatio = 206/mockupWidth;
    float singlePlayerLabelXRatio = 60/mockupWidth;
    float singlePlayerLabelYRatio = 240/mockupHeight;
    
    UILabel *singlePlayerLabel = [[UILabel alloc] initWithFrame:CGRectMake(singlePlayerLabelXRatio*SCREEN_WIDTH,singlePlayerLabelYRatio*SCREEN_HEIGHT,singlePlayerLabelWidthRatio*SCREEN_WIDTH,singlePlayerLabelHeightRatio*SCREEN_HEIGHT)];
    
    int sfontSize;
    if(SCREEN_HEIGHT<500)
    {
        sfontSize = 12;
    }
    else
    {
        sfontSize = 14;
        
    }
    
    singlePlayerLabel.font = [UIFont fontWithName:@"BookmanOldStyle-Bold" size:sfontSize];
    singlePlayerLabel.adjustsFontSizeToFitWidth = YES;
    singlePlayerLabel.textColor = [UIColor whiteColor];
    singlePlayerLabel.text = @"Singleplayer";
    singlePlayerLabel.shadowColor = [UIColor blackColor];
    singlePlayerLabel.shadowOffset = CGSizeMake(2,2);
    singlePlayerLabel.textAlignment = NSTextAlignmentCenter;
    

    [self.view addSubview:singlePlayerLabel];
    
    //[self.view addSubview:topMetalFrame];
    
      //hammer yPositionRatio—274Y, 256H,108W,110 X
    float singlePlayerButtonYPositionRatio = 274/mockupHeight;
    float singlePlayerButtonXPositionRatio = 110/mockupWidth;
    float singlePlayerButtonHeightRatio = 256/mockupHeight;
    float singlePlayerButtonWidthRatio = 108/mockupWidth;
    
        _singlePlayerButton = [[UIButton alloc] initWithFrame:CGRectMake(singlePlayerButtonXPositionRatio*SCREEN_WIDTH,singlePlayerButtonYPositionRatio*SCREEN_HEIGHT,singlePlayerButtonWidthRatio*SCREEN_WIDTH,singlePlayerButtonHeightRatio*SCREEN_HEIGHT)];
    
    
  
    
    [_singlePlayerButton setBackgroundColor:[UIColor clearColor]];
    
    UIImage *singlePlayerBtnImage = [UIImage imageNamed:@"SinglePlayerHammer"];
    
    [_singlePlayerButton setImage:singlePlayerBtnImage forState:UIControlStateNormal];
    
        [_singlePlayerButton addTarget:self action:@selector(singlePlayerButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_singlePlayerButton];
    
    //label2 xpositionRatio—360X,30H, 190W,240Y
    float multiplayerLabelXRatio = 360/mockupWidth;
    float multiplayerLabelYRatio = 240/mockupHeight;
    float multiplayerLabelHeightRatio = 30/mockupHeight;
    float multiplayerLabelWidthRatio = 190/mockupWidth;
    
    UILabel *multiPlayerLabel = [[UILabel alloc] initWithFrame:CGRectMake(multiplayerLabelXRatio*SCREEN_WIDTH,multiplayerLabelYRatio*SCREEN_HEIGHT,multiplayerLabelWidthRatio*SCREEN_WIDTH,multiplayerLabelHeightRatio*SCREEN_HEIGHT)];
    int fontSize;
    if(SCREEN_HEIGHT<500)
    {
        fontSize = 12;
    }
    else
    {
        fontSize = 14;
        
    }
    multiPlayerLabel.font = [UIFont fontWithName:@"BookmanOldStyle-Bold" size:fontSize];
    multiPlayerLabel.textColor = [UIColor whiteColor];
    multiPlayerLabel.text = @"Multiplayer";
    multiPlayerLabel.shadowColor = [UIColor blackColor];
    multiPlayerLabel.shadowOffset = CGSizeMake(2,2);
    multiPlayerLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:multiPlayerLabel];
    
    UIImage *multiplayerBtnImage = [UIImage imageNamed:@"MultiplayerHammers"];
    
    //mphammer ypositionRatio—280Y,240H, 264 W,322X
    float multiplayerButtonYRatio = 280/mockupHeight;
    float multiplayerButtonXRatio = 322/mockupWidth;
    float multiplayerButtonHeightRatio = 240/mockupHeight;
    float multiplayerButtonWidthRatio = 264/mockupWidth;
        _multiPlayerButton = [[UIButton alloc] initWithFrame: CGRectMake(multiplayerButtonXRatio*SCREEN_WIDTH, multiplayerButtonYRatio*SCREEN_HEIGHT, multiplayerButtonWidthRatio*SCREEN_WIDTH, multiplayerButtonHeightRatio*SCREEN_HEIGHT)];
    
    [_multiPlayerButton setImage:multiplayerBtnImage forState:UIControlStateNormal];
    
    
        [_multiPlayerButton addTarget:self action:@selector(multiPlayerButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_multiPlayerButton];
    
    //bottom flag y—602,height,242,
    float bottomFlagYRatio = 602/mockupHeight;
    float bottomFlagHeightRatio = 242/mockupHeight;
    
    UIImageView *bottomFlag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BottomFlag2"]];
    bottomFlag.frame = CGRectMake(0,bottomFlagYRatio*SCREEN_HEIGHT,SCREEN_WIDTH,bottomFlagHeightRatio*SCREEN_HEIGHT);
    [self.view addSubview:bottomFlag];
    
     //label2 xpositionRatio—360X,30H, 190W,236Y
   //DeckBuild—x= 74,626y,178W
    float deckLabelXRatio = 74/mockupWidth;
    float deckLabelYRatio = 626/mockupHeight;
    float deckLabelWidthRatio = 178/mockupWidth;
    float deckLabelHeightRatio = 30/mockupHeight;
    
    UILabel *deckLabel = [[UILabel alloc] initWithFrame:CGRectMake(deckLabelXRatio*SCREEN_WIDTH,deckLabelYRatio*SCREEN_HEIGHT,deckLabelWidthRatio*SCREEN_WIDTH,deckLabelHeightRatio*SCREEN_HEIGHT)];
    deckLabel.font = [UIFont fontWithName:@"BookmanOldStyle-Bold" size:fontSize];
    deckLabel.textColor = [UIColor whiteColor];
    deckLabel.text = @"Build Decks";
    deckLabel.shadowColor = [UIColor blackColor];
    deckLabel.shadowOffset = CGSizeMake(2,2);
    [self.view addSubview:deckLabel];
    
    //cardX—110,height 144,y672,width 98
    float deckButtonXRatio = 110/mockupWidth;
    float deckButtonYRatio = 672/mockupHeight;
    float deckButtonWidthRatio = 98/mockupWidth;
    float deckButtonHeightRatio = 144/mockupHeight;
        _deckButton = [[UIButton alloc] initWithFrame: CGRectMake(deckButtonXRatio*SCREEN_WIDTH, deckButtonYRatio*SCREEN_HEIGHT, deckButtonWidthRatio*SCREEN_WIDTH, deckButtonHeightRatio*SCREEN_HEIGHT)];
    
    UIImage *deckButtonImage = [UIImage imageNamed:@"Cards"];
    [_deckButton setImage:deckButtonImage forState:UIControlStateNormal];
    
        [_deckButton addTarget:self action:@selector(deckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_deckButton];
    
    //Store—X422, 626y,90W
    float storeLabelXRatio = 422/mockupWidth;
    float storeLabelYRatio = 626/mockupHeight;
    float storeLabelWidthRatio = 90/mockupWidth;
    float storeLabelHeightRatio = 30/mockupHeight;
    
    UILabel *storeLabel = [[UILabel alloc] initWithFrame:CGRectMake(storeLabelXRatio*SCREEN_WIDTH,storeLabelYRatio*SCREEN_HEIGHT,storeLabelWidthRatio*SCREEN_WIDTH,storeLabelHeightRatio*SCREEN_HEIGHT)];
    
    storeLabel.font = [UIFont fontWithName:@"BookmanOldStyle-Bold" size:fontSize];
    storeLabel.textColor = [UIColor whiteColor];
    storeLabel.text = @"Store";
    storeLabel.shadowColor = [UIColor blackColor];
    storeLabel.shadowOffset = CGSizeMake(2,2);
    [self.view addSubview:storeLabel];
    //store—width 194,height 158,y666,x354
    float storeButtonXRatio = 354/mockupWidth;
    float storeButtonYRatio = 666/mockupHeight;
    float storeButtonWidthRatio = 194/mockupWidth;
    float storeButtonHeightRatio = 158/mockupHeight;
    
        _storeButton = [[UIButton alloc] initWithFrame: CGRectMake(storeButtonXRatio*SCREEN_WIDTH, storeButtonYRatio *SCREEN_HEIGHT, storeButtonWidthRatio*SCREEN_WIDTH, storeButtonHeightRatio*SCREEN_HEIGHT)];
    
    
    
    UIImage *storeImage = [UIImage imageNamed:@"TreasureChest"];
    [_storeButton setImage:storeImage forState:UIControlStateNormal];
    
        [_storeButton addTarget:self action:@selector(storeButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_storeButton];
        
        UIButton *messageButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,78,59)];
        //[messageButton setImage:MESSAGE_ICON_IMAGE forState:UIControlStateNormal];
        UIImage *messageImage = [UIImage imageNamed:@"envelope"];
        [messageButton setImage:messageImage forState:UIControlStateNormal];
    
    //messageButton—868Y,148X,90Height,134X
    //gear—100Height,,104Width,378X,865Y
    float messageButtonXRatio = 148/mockupWidth;
    float messageButtonYRatio = 868/mockupHeight;
    float messageButtonWidthRatio = 134/mockupWidth;
    float messageButtonHeightRatio = 90/mockupHeight;
    
    messageButton.frame = CGRectMake(messageButtonXRatio*SCREEN_WIDTH,messageButtonYRatio*SCREEN_HEIGHT,messageButtonWidthRatio*SCREEN_WIDTH,messageButtonHeightRatio*SCREEN_HEIGHT);
    
        [self.view addSubview:messageButton];
        _messageCountLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(messageButton.frame.size.width-30, 2, 20, 20)];
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
        
        UIButton *optionsButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,56,56)];
        //[optionsButton setImage:OPTION_ICON_IMAGE forState:UIControlStateNormal];
    [optionsButton setImage:[UIImage imageNamed:@"cog"] forState:UIControlStateNormal];
     //gear—100Height,,104Width,378X,865Y
    float optionsButtonXRatio = 378/mockupWidth;
    float optionsButtonYRatio = 865/mockupHeight;
    float optionsButtonWidthRatio = 104/mockupWidth;
    float optionsButtonHeightRatio = 100/mockupHeight;
    
    optionsButton.frame = CGRectMake(optionsButtonXRatio*SCREEN_WIDTH,optionsButtonYRatio*SCREEN_HEIGHT,optionsButtonWidthRatio*SCREEN_WIDTH,optionsButtonHeightRatio*SCREEN_HEIGHT);
    
        [self.view addSubview:optionsButton];
        
        [optionsButton addTarget:self action:@selector(optionButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //UIImageView *bottomMetalFrame = [[UIImageView alloc] initWithFrame:CGRectMake(-40,492,SCREEN_WIDTH+100,63)];
    //[bottomMetalFrame setImage:[UIImage imageNamed:@"MetalFrame"]];
    //[self.view addSubview:bottomMetalFrame];
    
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
    [messagesQuery whereKey:@"messageRead" notEqualTo:@"YES"];
    
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
    
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("titleGongSound"), CFSTR("wav"), NULL);
    SystemSoundID soundId;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundId);
    AudioServicesPlaySystemSound(soundId);
    CFRelease(soundFileURLRef);
}

-(void)multiPlayerButtonPressed
{
    MultiplayerGameViewController *mgvc = [[MultiplayerGameViewController alloc] init];
    
    DeckChooserViewController *dcv = [[DeckChooserViewController alloc] init];
    dcv.nextScreen = mgvc;
    dcv.isMultiplayer = YES;
    [self presentViewController:dcv animated:YES completion:nil];
    
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("titleGongSound"), CFSTR("wav"), NULL);
    SystemSoundID soundId;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundId);
    AudioServicesPlaySystemSound(soundId);
    CFRelease(soundFileURLRef);
}

-(void)deckButtonPressed
{
    DeckEditorViewController *viewController = [[DeckEditorViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
    
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("selectSound1"), CFSTR("wav"), NULL);
    SystemSoundID soundId;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundId);
    AudioServicesPlaySystemSound(soundId);
    CFRelease(soundFileURLRef);
}

-(void)storeButtonPressed
{
    StoreViewController *viewController = [[StoreViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
    
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("select2"), CFSTR("wav"), NULL);
    SystemSoundID soundId;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundId);
    AudioServicesPlaySystemSound(soundId);
    CFRelease(soundFileURLRef);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
