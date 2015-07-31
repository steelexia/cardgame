//
//  ChallengesViewController.m
//  cardgame
//
//  Created by Brian Allen on 2015-07-30.
//  Copyright (c) 2015 Content Games. All rights reserved.
//

#import "ChallengesViewController.h"
#import "Campaign.h"
#import "CardView.h"
#import "DeckChooserViewController.h"
#import "GameViewController.h"

@interface ChallengesViewController ()

@end

@implementation ChallengesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *challengeButton = [[UIButton alloc] initWithFrame:CGRectMake(20,20,300,300)];
    [challengeButton setTitle:@"Cow Level" forState:UIControlStateNormal];
    
    [challengeButton addTarget:self action:@selector(challengeButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:challengeButton];
    
}

-(void)challengeButtonPressed
{
    //set up the level
    //start a challenge instantly for now
    //d_1_c_4_l_1"
    Level*level = [Campaign getLevelWithDifficulty:1 withChapter:4 withLevel:1];
    
    GameViewController *gvc = [[GameViewController alloc] initWithGameMode:GameModeSingleplayer withLevel:level];
    
    DeckChooserViewController *dcvc = [[DeckChooserViewController alloc] init];
    if (level.isTutorial)
        dcvc.noPickDeck = YES;
    dcvc.opponentName = level.opponentName;
    
    dcvc.nextScreen = gvc;
    
    [self presentViewController:dcvc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
