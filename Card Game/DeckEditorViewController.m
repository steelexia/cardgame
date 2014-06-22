//
//  DeckEditorViewController.m
//  cardgame
//
//  Created by Macbook on 2014-06-21.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "DeckEditorViewController.h"

@interface DeckEditorViewController ()

@end

@implementation DeckEditorViewController

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
    
    //get the single player deck
    DeckModel * testDeck = [SinglePlayerCards getDeckOne];
    
    //get the CardView of every card in the deck
    for (CardModel *card in testDeck.cards)
    {
        //create a card view and set it up
        CardView *cardView = [[CardView alloc] initWithModel:card cardImage:[[UIImageView alloc]initWithImage: [UIImage imageNamed:@"card_image_placeholder"]]viewMode:cardViewModeIngame];
        card.cardView = cardView;
        
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)backBtnPressed:(id)sender
{
    
}

- (IBAction)DeckSegmentedControl:(id)sender
{
    
}

- (IBAction)CardTypeValueChanged:(id)sender
{
    
}

- (IBAction)RemoveAllCardsPressed:(id)sender
{
    
}

- (IBAction)SaveDeckPressed:(id)sender
{
    
}

@end
