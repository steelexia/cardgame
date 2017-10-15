//
//  SinglePlayerMenuViewController.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-12.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "SinglePlayerMenuViewController.h"
#import "GameViewController.h"
#import "DeckChooserViewController.h"
#import "CampaignMenuViewController.h"
#import "Campaign.h"
#import "ChallengesViewController.h"
#import "SceneObjCViewController.h"
#import "cardgame-Swift.h"
#import "GameModel.h"
#import "StrokedLabel.h"
@interface SinglePlayerMenuViewController ()

@end

@implementation SinglePlayerMenuViewController

int SCREEN_WIDTH, SCREEN_HEIGHT;

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
    menuLogoBackground.label.text = @"Singleplayer";
    [self.view addSubview:menuLogoBackground];
    
    CFButton *quickMatchButton = [[CFButton alloc] initWithFrame: CGRectMake(0, 0, 100, 100)];
    [quickMatchButton setTextSize:12];
    quickMatchButton.frame = CGRectMake(0, 0, 100, 100);
    quickMatchButton.center = CGPointMake(self.view.bounds.size.width/3 - 5, self.view.bounds.size.height*2/3 - 58);
    [quickMatchButton setTitle:@"Quick Match" forState:UIControlStateNormal];
    [quickMatchButton addTarget:self action:@selector(quickMatchButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:quickMatchButton];
    
    CFButton *campaignButton = [[CFButton alloc] initWithFrame: CGRectMake(0, 0, 100, 100)];
    [campaignButton setTextSize:12];
    campaignButton.frame = CGRectMake(0, 0, 100, 100);
    campaignButton.center = CGPointMake(self.view.bounds.size.width*2/3 + 5, self.view.bounds.size.height*2/3 - 58);
    [campaignButton setTitle:@"Campaign" forState:UIControlStateNormal];
    [campaignButton addTarget:self action:@selector(campaignButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:campaignButton];
    
    CFButton *challengesButton = [[CFButton alloc] initWithFrame: CGRectMake(0, 0, 100, 100)];
    [challengesButton setTextSize:12];
    challengesButton.frame = CGRectMake(0, 0, 100, 100);
    challengesButton.center = CGPointMake(self.view.bounds.size.width/3 - 5, self.view.bounds.size.height*2/3 + 58);
    [challengesButton setTitle:@"Challenges" forState:UIControlStateNormal];
    [challengesButton addTarget:self action:@selector(challengesButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [challengesButton setEnabled:TRUE];
    
    [self.view addSubview:challengesButton];
    
    
    /*
    CFButton *deckButton = [[CFButton alloc] initWithFrame: CGRectMake(0, 0, 100, 100)];
    [deckButton setTextSize:12];
    deckButton.center = CGPointMake(self.view.bounds.size.width/3 - 5, self.view.bounds.size.height*2/3 + 58);
    [deckButton setTitle:@"Deck Builder" forState:UIControlStateNormal];
    [deckButton addTarget:self action:@selector(deckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:deckButton];
     */
    
    CFButton *backButton = [[CFButton alloc] initWithFrame: CGRectMake(0, 0, 100, 100)];
    [backButton setTextSize:12];
    backButton.frame = CGRectMake(0, 0, 100, 100);
    backButton.center = CGPointMake(self.view.bounds.size.width*2/3 + 5, self.view.bounds.size.height*2/3 + 58);
    [backButton setTitle:@"Main Menu" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:backButton];
}

-(void)quickMatchButtonPressed
{
    GameViewController *gvc = [[GameViewController alloc] initWithGameMode:GameModeSingleplayer withLevel:[Campaign quickMatchLevel]];
    
    DeckChooserViewController*dcvc = [[DeckChooserViewController alloc]init];
    dcvc.nextScreen = gvc;
    [self presentViewController:dcvc animated:YES completion:nil];
}

-(void)campaignButtonPressed
{
    CampaignMenuViewController *viewController = [[CampaignMenuViewController alloc] init];
    [self presentViewController:viewController animated:NO completion:nil];
}

-(void)challengesButtonPressed
{
   // ChallengesViewController *viewController = [[ChallengesViewController alloc] init];
   // [self presentViewController:viewController animated:NO completion:nil];
    
    /*
    SceneTestViewController *customSceneTest = [[SceneTestViewController alloc] init];
    [self presentViewController:customSceneTest animated:NO completion:nil];
    */
    SceneObjCViewController *objCTest = [[SceneObjCViewController alloc] init];
    [self presentViewController:objCTest animated:NO completion:nil];
    

}

-(void)backButtonPressed
{
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
