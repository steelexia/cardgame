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
}

-(void)gameButtonPressed
{
    GameViewController *gvc = [[GameViewController alloc] init];
    DeckChooserViewController*dcvc = [[DeckChooserViewController alloc]init];
    dcvc.nextScreen = gvc;
    dcvc.previousScreen = [[MainScreenViewController alloc]init];
    [self presentViewController:dcvc animated:YES completion:nil];
}

-(void)deckButtonPressed
{
    DeckEditorViewController *viewController = [[DeckEditorViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)cardButtonPressed
{
    CardEditorViewController *viewController = [[CardEditorViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
