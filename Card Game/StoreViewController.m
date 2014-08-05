//
//  StoreViewController.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-02.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "StoreViewController.h"
#import "UIConstants.h"
#import "UserModel.h"
#import "SinglePlayerCards.h"
#import "GameStore.h"

@interface StoreViewController ()


@end

@implementation StoreViewController

@synthesize cardsView = _cardsView;

/** Screen dimension for convinience */
int SCREEN_WIDTH, SCREEN_HEIGHT;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _cardsView = [[StoreCardsCollectionView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height-100-40)];
        
        _cardsView.backgroundColor = COLOUR_INTERFACE_BLUE;
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        [self.view addSubview:_cardsView];
        
        [self loadCards];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(4, SCREEN_HEIGHT-36, 46, 32)];
    [self.backButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.backButton];
    
    _goldLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 160, SCREEN_HEIGHT - 40, 155, 40)];
    _goldLabel.textAlignment = NSTextAlignmentRight;
    _goldLabel.textColor = [UIColor blackColor]; //TODO change colour
    _goldLabel.font = [UIFont fontWithName:cardMainFont size:28];
    _goldLabel.text = [NSString stringWithFormat:@"Gold: %d", userGold];
    
    [self.view addSubview:_goldLabel];
    
    
    //-----------------Card info views----------------//
    _cardInfoView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    _darkFilter = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH, SCREEN_HEIGHT-40)];
    _darkFilter.backgroundColor = [[UIColor alloc]initWithHue:0 saturation:0 brightness:0 alpha:0.8];
    [_darkFilter setUserInteractionEnabled:YES]; //blocks all interaction behind it
    [_cardInfoView addSubview:_darkFilter];
    
    _buyButton = [[UIButton alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT - 110, 80, 60)];
    [_buyButton setImage:[UIImage imageNamed:@"buy_button"] forState:UIControlStateNormal];
    [_buyButton setImage:[UIImage imageNamed:@"buy_button_gray"] forState:UIControlStateDisabled];
    [_buyButton addTarget:self action:@selector(buyButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [_cardInfoView addSubview:_buyButton];
    
    _editButton = [[UIButton alloc] initWithFrame:CGRectMake(120, SCREEN_HEIGHT - 110, 80, 60)];
    [_editButton setImage:[UIImage imageNamed:@"edit_button"] forState:UIControlStateNormal];
    [_editButton setImage:[UIImage imageNamed:@"edit_button_gray"] forState:UIControlStateDisabled];
    [_buyButton addTarget:self action:@selector(editButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [_cardInfoView addSubview:_editButton];
    
    _likeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-20-80, SCREEN_HEIGHT - 110, 80, 60)];
    [_likeButton setImage:[UIImage imageNamed:@"like_button"] forState:UIControlStateNormal];
    [_likeButton setImage:[UIImage imageNamed:@"like_button_gray"] forState:UIControlStateDisabled];
    [_buyButton addTarget:self action:@selector(likeButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [_cardInfoView addSubview:_likeButton];
    
    _cardPurchaseIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_cardPurchaseIndicator setFrame:self.view.bounds];
    [_cardPurchaseIndicator setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.5]];
    [_cardPurchaseIndicator setUserInteractionEnabled:YES];
    UILabel *cardPurchaseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    cardPurchaseLabel.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + 60);
    cardPurchaseLabel.textAlignment = NSTextAlignmentCenter;
    cardPurchaseLabel.textColor = [UIColor whiteColor];
    cardPurchaseLabel.font = [UIFont fontWithName:cardMainFont size:20];
    cardPurchaseLabel.text = [NSString stringWithFormat:@"Processing Purchase..."];
    [_cardPurchaseIndicator addSubview:cardPurchaseLabel];
}

-(void)backButtonPressed
{
    [self presentViewController:self.previousScreen animated:YES completion:nil];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    UIView*touchedView = touch.view;
    
    //touched a card in current list of cards
    if ([touchedView isKindOfClass:[CardView class]])
    {
        CardView*cardView = (CardView*)touchedView;
        
        //from collection
        if ([cardView.superview isKindOfClass:[UICollectionViewCell class]])
        {
            [self openCardInfoView:cardView.cardModel];
        }
        //from currently viewing
        else if (cardView == _cardView)
        {
            [self closeCardInfoView];
        }
    }
}

-(void)openCardInfoView:(CardModel*)cardModel
{
    CardView*originalView = cardModel.cardView;
    _cardView = [[CardView alloc] initWithModel:cardModel cardImage:[[UIImageView alloc] initWithImage: cardModel.cardView.cardImage.image] viewMode:cardViewModeEditor];
    cardModel.cardView = originalView;
    _cardView.cardViewState = cardViewStateCardViewer;
    
    if (SCREEN_HEIGHT < 568)
    {
        _cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
        _cardView.center = CGPointMake(SCREEN_WIDTH/2, 150);
    }
    else
    {
        _cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
        _cardView.center = CGPointMake(SCREEN_WIDTH/2, 200);
    }
    
    [_cardInfoView addSubview:_cardView];
    
    _cardInfoView.alpha = 0;
    [self.view addSubview:_cardInfoView];
    
    //TODO when viewing own cards, don't show the buy buttons etc. use if sale.seller == current user
    
    NSArray*cards = userPF[@"cards"];
    
    if ([cards containsObject:@(cardModel.idNumber)])
        [_buyButton setEnabled:NO];
    else
        [_buyButton setEnabled:YES];
    
    [_backButton setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _cardInfoView.alpha = 1;
                         _backButton.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         
                     }];
}

-(void)closeCardInfoView
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _backButton.alpha = 1;
                         _cardInfoView.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [_cardInfoView removeFromSuperview];
                         [_cardView removeFromSuperview];
                         [_backButton setUserInteractionEnabled:YES];
                     }];
}

-(void)buyButtonPressed
{
    [_buyButton setEnabled:NO];
    
    [self.view addSubview:_cardPurchaseIndicator];
    [_cardPurchaseIndicator startAnimating];
    _cardPurchaseIndicator.alpha = 0;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _cardPurchaseIndicator.alpha = 1;
                     }
                     completion:^(BOOL completed){
                     }];
    
    //check again when buying
    int currentCardIndex = [_cardsView.currentCards indexOfObject:_cardView.cardModel];
    
    if (currentCardIndex >= 0 && currentCardIndex < _cardsView.currentSales.count)
    {
        PFObject *salePF = _cardsView.currentSales[currentCardIndex];
        [salePF refreshInBackgroundWithBlock:^(PFObject *salePF, NSError *error) {
            if (!error)
            {
                NSNumber *stockSize = salePF[@"stock"];
                
                if (stockSize > 0)
                {
                    stockSize = @([stockSize intValue] - 1);
                    [salePF saveInBackground]; //TODO maybe this should be done in server
                    
                    int cost = [GameStore getCardCost:_cardView.cardModel];
                    
                    userGold -= cost;
                    if (userGold < 0)
                        userGold = 0; //not suppose to happen anyways
                    userPF[@"gold"] = @(userGold);
                    
                    [userAllCards addObject:_cardView.cardModel];
                    [UserModel saveCard:_cardView.cardModel];
                    
                    NSMutableArray *ownedCards = [NSMutableArray arrayWithArray:userPF[@"cards" ]];
                    [ownedCards addObject:@(_cardView.cardModel.idNumber)];
                    
                    userPF[@"cards"] = ownedCards;
                    [userPF saveInBackground];
                    
                    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         _cardPurchaseIndicator.alpha = 0;
                                     }
                                     completion:^(BOOL completed){
                                         [_cardPurchaseIndicator stopAnimating];
                                         [_cardPurchaseIndicator removeFromSuperview];
                                     }];
                }
                else{
                    //TODO
                    NSLog(@"TODO: No stock left");
                }

            }
            else
            {
                NSLog(@"ERROR: FAILED TO FIND SALE");
                //TODO
            }
            
        }];
    }
    else
    {
        NSLog(@"ERROR: FAILED TO FIND SALE IN ARRAY");
        //TODO
    }
    
    
    
    //PFQuery *saleQuery = [PFQuery queryWithClassName:@"Card"];
    /*
    [cardQuery whereKey:@"idNumber" equalTo: @(_cardView.cardModel.idNumber)];
    [cardQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            if (objects.count > 0)
            {
                PFObject *cardPF = objects[0];
                NSNumber *stockSize = cardPF[@"stock"];
                
                if (stockSize > 0)
                {
                    stockSize = @([stockSize intValue] - 1);
                    [cardPF saveInBackground]; //TODO maybe this should be done in server
                    
                    int cost = [GameStore getCardCost:_cardView.cardModel];
                    
                    userGold -= cost;
                    if (userGold < 0)
                        userGold = 0; //not suppose to happen anyways
                    
                    [userAllCards addObject:_cardView.cardModel];
                    [UserModel saveCard:_cardView.cardModel];
                    
                    NSMutableArray *ownedCards = [NSMutableArray arrayWithArray:userPF[@"cards" ]];
                    [ownedCards addObject:@(_cardView.cardModel.idNumber)];
                    
                    userPF[@"cards"] = ownedCards;
                    [userPF saveInBackground];
                }
                else{
                    //TODO
                }
                [self.buyButton setEnabled:NO];
            }
            else
            {
                NSLog(@"ERROR: FAILED TO FIND CARD");
                //TODO
            }
        }
        else
        {
            NSLog(@"ERROR: QUERY RESULTED IN ERROR");
            //TODO
        }
    }];
    ;
    */
    
}

-(void)likeButtonPressed
{
    
}

-(void)editButtonPressed
{
    
}

-(void)loadCards
{
    PFQuery *salesQuery = [PFQuery queryWithClassName:@"Sale"];
    salesQuery.limit = 20; //TODO!!!!!!!!!!!
    [salesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            //load all sales without the cards
            _cardsView.currentSales = [NSMutableArray arrayWithArray: objects];
            //_cardsView.currentCards = [NSMutableArray arrayWithCapacity:objects.count];
            for (int i = 0; i < objects.count; i++)
                [_cardsView.currentCards addObject:[NSNull null]];
            
            [self.cardsView reloadInputViews];
            [self.cardsView.collectionView reloadData];
            
            //TODO insert loading cells, then update them as they arrive
            for (int i = 0; i < objects.count; i++)
            {
                PFObject *sale = objects[i];
                
                PFQuery *cardQuery = [PFQuery queryWithClassName:@"Card"];
                cardQuery.limit = 1;
                [cardQuery whereKey:@"idNumber" equalTo:sale[@"cardID"]];
                [cardQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if(!error && objects.count >= 1){
                        PFObject *card = objects[0];
                        
                        _cardsView.currentCards[i] = [CardModel createCardFromPFObject:card];
                        
                        [_cardsView.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
                    }
                    else
                    {
                        NSLog(@"ERROR SEARCHING SALES");
                    }
                }];
            }
            
            
        }
        else
        {
            NSLog(@"ERROR SEARCHING SALES");
        }
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
