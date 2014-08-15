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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
    UILabel*singlePlayerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    singlePlayerLabel.textAlignment = NSTextAlignmentCenter;
    singlePlayerLabel.text = @"Single Player";
    singlePlayerLabel.center = CGPointMake(SCREEN_WIDTH/2, 80);
    [self.view addSubview:singlePlayerLabel];
    
    UIButton*quickMatchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    quickMatchButton.frame = CGRectMake(0, 0, 120, 120);
    quickMatchButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [quickMatchButton setTitle:@"Quick Match" forState:UIControlStateNormal];
    quickMatchButton.center = CGPointMake(SCREEN_WIDTH/2 - 70, SCREEN_HEIGHT/2 - 50);
    [quickMatchButton addTarget:self action:@selector(quickMatchButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:quickMatchButton];
    
    UIButton*campaignButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    campaignButton.frame = CGRectMake(0, 0, 120, 120);
    campaignButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [campaignButton setTitle:@"Campaign" forState:UIControlStateNormal];
    campaignButton.center = CGPointMake(SCREEN_WIDTH/2 + 70, SCREEN_HEIGHT/2 - 50);
    [campaignButton addTarget:self action:@selector(campaignButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:campaignButton];
    
    UIButton*challengeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    challengeButton.frame = CGRectMake(0, 0, 120, 120);
    challengeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [challengeButton setTitle:@"Challenges" forState:UIControlStateNormal];
    challengeButton.center = CGPointMake(SCREEN_WIDTH/2 - 70, SCREEN_HEIGHT/2 + 50);
    [challengeButton addTarget:self action:@selector(challengeButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:challengeButton];
    
    UIButton*backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backButton.frame = CGRectMake(0, 0, 120, 120);
    backButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [backButton setTitle:@"Main Menu" forState:UIControlStateNormal];
    backButton.center = CGPointMake(SCREEN_WIDTH/2 + 70, SCREEN_HEIGHT/2 + 50);
    [backButton addTarget:self action:@selector(backButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

-(void)quickMatchButtonPressed
{
    GameViewController *gvc = [[GameViewController alloc] init];
    DeckChooserViewController*dcvc = [[DeckChooserViewController alloc]init];
    dcvc.nextScreen = gvc;
    [self presentViewController:dcvc animated:YES completion:nil];
}

-(void)campaignButtonPressed
{
    
}

-(void)challengeButtonPressed
{
    
}

-(void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
