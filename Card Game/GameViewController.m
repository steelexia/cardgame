//
//  ViewController.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "GameViewController.h"
#import "CardView.h"
#import "MonsterCardModel.h"

@interface GameViewController ()

@end

@implementation GameViewController

@synthesize gameModel = _gameModel;

//TODO these are just temporary
CardView* card1V, *card2V;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gameModel = [[GameModel alloc] initWithViewController:(self)];
    
    
    
    //TODO below are just some temporary testing stuff
    
    //create the card's model
    MonsterCardModel* card1 = [[MonsterCardModel alloc] initWithIdNumber:0];
    card1.damage = 1000;
    card1.life = 3000;
    card1.cost = 1;
    [self.gameModel addCardToBattlefield:card1 side:PLAYER_SIDE]; //note: does nothing yet
    
    //create the card's view
	card1V = [[CardView alloc] initWithModel:(card1)];
    card1V.center = CGPointMake(100, self.view.bounds.size.height - 50);
    
    
    MonsterCardModel* card2 = [[MonsterCardModel alloc] initWithIdNumber:1];
    card2.damage = 800;
    card2.life = 4000;
    card2.cost = 1;
    [self.gameModel addCardToBattlefield:card2 side:OPPONENT_SIDE]; //note: does nothing yet

	card2V = [[CardView alloc] initWithModel:(card2)];
    card2V.center = CGPointMake(100, 100);
    
    //add cards to view
    [self.view addSubview:card1V];
    [self.view addSubview:card2V];
    
    [card1V updateView];
    [card2V updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //temporary tests, card1 attacks card2 and card2 attacks card1
    int damage = [self.gameModel calculateDamage:self.gameModel.battlefield[PLAYER_SIDE][0] dealtTo:self.gameModel.battlefield[OPPONENT_SIDE][0]];
    [self.gameModel.battlefield[OPPONENT_SIDE][0] loseLife:damage];
    
    damage = [self.gameModel calculateDamage:self.gameModel.battlefield[OPPONENT_SIDE][0] dealtTo:self.gameModel.battlefield[PLAYER_SIDE][0]];
    [self.gameModel.battlefield[PLAYER_SIDE][0] loseLife:damage];
    
    [card1V updateView];
    [card2V updateView];
    
    NSLog(@"cards attack each other");
}

@end
