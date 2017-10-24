//
//  DeckEditorViewController.m
//  cardgame
//
//  Created by Macbook on 2014-06-21.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "DeckEditorViewController.h"
#import "DeckModel.h"
#import "CardView.h"
#import "CardModel.h"
#import "SinglePlayerCards.h"
#import "UserModel.h"
#import "MainScreenViewController.h"
#import "StrokedLabel.h"
#import "UserCardVersion.h"
#import "UIConstants.h"
#import "CardsCollectionCell.h"
#import "CustomCollectionView.h"
#import "CardEditorViewController.h"

@interface DeckEditorViewController ()

@end


@implementation DeckEditorViewController
@synthesize cardsView = _cardsView;
@synthesize deckView = _deckView;

//double CARD_VIEWER_SCALE = 0.8;
/** Screen dimension for convinience */
float SCREEN_WIDTH, SCREEN_HEIGHT;
float DeckEditWidth, DeckEditHeight;
float DeckWRatio,DeckHRatio;

/** UILabel used to darken the screen during card selections */
UILabel *darkFilter;

/** Currently maximized card */
CardView *currentCard;
/** Original view of the currently maximized card */
CardView *originalCurrentCard;
/** Index of currentCard in the collection */
int currentIndex = -1;

CFButton *addCardToDeckButton, *removeCardFromDeckButton, *sellCardButton;

/** Shows the number of cards currently in the deck */
UILabel *deckCountLabel;

/** Label explaining why the card cannot be added */
UILabel *cannotAddCardReasonLabel;

/** Used to add another deck */
CFButton *addDeckButton;

/** Buttons for pressing the addDeckButton when the deck is invalid */
CFButton *autoAddCardsButton, *notAutoAddCardsButton, *autoAddCardsFailedButton, *notFixDeckButton, *cancelNotFixButton;
UILabel *autoAddCardsLabel, *autoAddCardsFailedLabel;
UIView*autoAddView;
UIView*fixCardView;

/** Used to save and return to organizing decks*/
CFButton *saveDeckButton;

/** Add a new deck */
CFButton *addDeckButton;

/** Returns to main menu */
CFButton *backButton;

/** The current deck being organized when deckView is in card mode if is nil, a new deck is being created. */
DeckModel* currentDeck;

UILabel *deleteDeckLabel;

CFButton*invalidDeckButton;
StrokedLabel*invalidDeckLabel;

/** For unmaximizing */
enum CardCollectinViewMode lastVCardCollectionViewMode;

DeckModel * allCards;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([userPF[@"deckTutorialDone"] boolValue] == NO)
        _isTutorial = YES;
    
    _isForgeCardsMode = NO;
    
    SCREEN_WIDTH = [[UIScreen mainScreen] bounds].size.width;
    SCREEN_HEIGHT = [[UIScreen mainScreen] bounds].size.height;
    
    //dimensions of this screen have been based on:
    //x--320
    //y--568
    DeckEditHeight = 568;
    DeckEditWidth = 320;
    
    DeckHRatio = SCREEN_HEIGHT/DeckEditHeight;
    DeckWRatio = SCREEN_WIDTH/DeckEditWidth;
    
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT)];
    backgroundImageView.image = [UIImage imageNamed:@"WoodBG.jpg"];
    [self.view addSubview:backgroundImageView];
    
    //cost 0 to 10
    _costFilter = [NSMutableArray arrayWithArray: @[@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES)]];
    
    //7 elements
    _elementFilter = [NSMutableArray arrayWithArray: @[@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES)]];
    
    //5 rarities
    _rarityFilter = [NSMutableArray arrayWithArray: @[@(YES),@(YES),@(YES),@(YES),@(YES)]];
    
    //get the single player deck TODO
    //allCards = userAllCards;
    allCards = [[DeckModel alloc] init];
    
    for (CardModel* card in userAllCards)
    {
        [allCards addCard:[[CardModel alloc] initWithCardModel: card]];
    }
    
    //sort the cards
    [allCards.cards sortUsingComparator:^(CardModel* a, CardModel* b){
         return [a compare:b];
     }];
    
    //Brian June 7--CardFlagging Logic
    
    //get the array of card versions from all cards that are stored in coreData
    NSArray *cdCardVersions = [UserModel getCDCardVersions:allCards.cards];
    
    //create array of cardID's
    NSMutableArray *savedCardVersionIDs = [[NSMutableArray alloc] init];
    NSMutableArray *versionOnCoreData = [[NSMutableArray alloc] init];
    
    for (UserCardVersion *ucv in cdCardVersions)
    {
        [savedCardVersionIDs addObject:ucv.idNumber];
       
        NSNumber *savedVersionNum = ucv.viewedVersion;
        [versionOnCoreData addObject:savedVersionNum];
        
    }
    
    //loop through this array.  if coreData doesn't have a version, the card should be added to an index of cards that need a new flag.  If coreData has an older version, it will also be added to this index.
    
    self.indexOfNewCards = [[NSMutableArray alloc] init];
    self.indexOfStarterCards = [[NSMutableArray alloc] init];
    
    int counter = 0;
    for (CardModel *card in allCards.cards)
    {
        //id lower than starting ID are starter cards
        if(card.idNumber < CARD_ID_START)
        {
            NSNumber *starterCardIndexNum = [NSNumber numberWithInt:counter];
            [self.indexOfStarterCards addObject:starterCardIndexNum];
        }
        else
        {
            
        NSNumber *allCardsID = [NSNumber numberWithInt:card.idNumber];
        int cardVersionNum = card.version;
        
        if([savedCardVersionIDs containsObject:allCardsID])
        {
           NSInteger savedCardVersIndex= [savedCardVersionIDs indexOfObject:allCardsID];
            
            //check the two version numbers
            NSNumber *coreDataSavedVersion = [versionOnCoreData objectAtIndex:savedCardVersIndex];
            
            
            int coreDataVersion = [coreDataSavedVersion intValue];
            
            if(coreDataVersion <cardVersionNum)
            {
                //flag this as new
                NSNumber *newCardIndexNum = [NSNumber numberWithInt:counter];
                [self.indexOfNewCards addObject:newCardIndexNum];
                
            }
            
        }
        else
        {
          //flag as new
            NSNumber *newCardIndexNum = [NSNumber numberWithInt:counter];
            [self.indexOfNewCards addObject:newCardIndexNum];
        }
        
       
        }
         counter = counter+1;
    }
    
    //if the card is a starter deck card, it should have a flag set that it's a starter card
    
    //set up cards view
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    
   self.cardsView = [[CardsCollectionView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-((408/DeckEditHeight)*SCREEN_HEIGHT), SCREEN_WIDTH-((88/DeckEditWidth)*SCREEN_WIDTH), (366/DeckEditHeight)*SCREEN_HEIGHT) collectionViewLayout:layout];
    //self.cardsView = [[CardsCollectionView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-((408/DeckEditHeight)*SCREEN_HEIGHT), SCREEN_WIDTH-((88/DeckEditWidth)*SCREEN_WIDTH), 366) collectionViewLayout:layout];
    //self.cardsView = [[CardsCollectionView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-((408/DeckEditHeight)*SCREEN_HEIGHT), SCREEN_WIDTH-((88/DeckEditWidth)*SCREEN_WIDTH), 366) collectionViewLayout:layout];
    self.cardsView.indexOfNewCards = self.indexOfNewCards;
    self.cardsView.indexOfStarterCards = self.indexOfStarterCards;
    
    CGRect cardFrame = self.cardsView.frame;
    
    self.cardsView.parentViewController = self; //for callbacks
    self.cardsView.backgroundColor = [UIColor clearColor];
    
    //try writing some code to adjust card viewer scale if this height is lower than 360
    //brian oct 23 2017--this is a hack to get viewing on iPad to feel good.
    if(cardFrame.size.height <360)
    {
        CARD_VIEWER_SCALE = 0.65f;
    }
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.cardsView];
    
    [self.view setUserInteractionEnabled:YES];
    [self.cardsView setUserInteractionEnabled:YES];
    
    //set up deck view
    //self.deckView = [[DeckTableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-90,0,90,SCREEN_HEIGHT-42)];
    self.deckView = [[DeckTableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-(90*DeckWRatio),0,90*DeckWRatio,SCREEN_HEIGHT-(42*DeckHRatio))];
    self.deckView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.deckView];
    [self.deckView setUserInteractionEnabled:YES];
    
    //_footerView = [[UIView alloc]initWithFrame:CGRectMake(0,SCREEN_HEIGHT-(44*DeckHRatio),SCREEN_WIDTH, 44*DeckHRatio)];
    _footerView = [[UIView alloc]initWithFrame:CGRectMake(0,SCREEN_HEIGHT-44,SCREEN_WIDTH, 44)];
    //_footerView = [[UIView alloc]initWithFrame:CGRectMake(0,self.cardsView.frame.origin.y+self.cardsView.frame.size.height,SCREEN_WIDTH, SCREEN_HEIGHT-(self.cardsView.frame.origin.y+self.cardsView.frame.size.height))];
    //_footerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_footerView];
    
    //CFLabel*footerBackground = [[CFLabel alloc] initWithFrame:CGRectMake(-8, 0, _footerView.frame.size.width+16, _footerView.frame.size.height+8)];
    CFLabel*footerBackground = [[CFLabel alloc] initWithFrame:CGRectMake(-8*DeckWRatio, 0, _footerView.frame.size.width+(16*DeckWRatio), _footerView.frame.size.height+(8*DeckHRatio))];
    [footerBackground setBackgroundColor:COLOUR_INTERFACE_BLUE_DARK];
    [_footerView addSubview:footerBackground];
    
    //set up UI
    darkFilter = [[UILabel alloc] initWithFrame:self.view.bounds];
    darkFilter.backgroundColor = [[UIColor alloc]initWithHue:0 saturation:0 brightness:0 alpha:0.8];
    [darkFilter setUserInteractionEnabled:YES]; //blocks all interaction behind it
    
    addCardToDeckButton = [[CFButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - CARD_DETAIL_BUTTON_WIDTH - 10, SCREEN_HEIGHT - CARD_DETAIL_BUTTON_WIDTH - 50, CARD_DETAIL_BUTTON_WIDTH, CARD_DETAIL_BUTTON_WIDTH)];
    [addCardToDeckButton setImage:[UIImage imageNamed:@"add_button"] forState:UIControlStateNormal];
    [addCardToDeckButton addTarget:self action:@selector(addCardToDeckPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    removeCardFromDeckButton = [[CFButton alloc] initWithFrame:addCardToDeckButton.frame];
    [removeCardFromDeckButton setImage:[UIImage imageNamed:@"remove_button"] forState:UIControlStateNormal];
    
    [removeCardFromDeckButton addTarget:self action:@selector(removeCardFromDeckPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    sellCardButton = [[CFButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - CARD_DETAIL_BUTTON_WIDTH - 10, 10, CARD_DETAIL_BUTTON_WIDTH, CARD_DETAIL_BUTTON_HEIGHT)];
    sellCardButton.label.text = @"Sell";
    [sellCardButton setTextSize:CARD_NAME_SIZE +7];
    [sellCardButton addTarget:self action:@selector(sellCardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    //deck count label
    deckCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 115, 8, 90, 40)];
    deckCountLabel.textAlignment = NSTextAlignmentCenter;
    deckCountLabel.textColor = [UIColor blackColor];
    deckCountLabel.backgroundColor = [UIColor clearColor];
    deckCountLabel.font = [UIFont fontWithName:cardMainFont size:16];
    [_footerView addSubview:deckCountLabel];
    
    cannotAddCardReasonLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT - 120, 200, 120)];
    cannotAddCardReasonLabel.textColor = [UIColor redColor];
    cannotAddCardReasonLabel.backgroundColor = [UIColor clearColor];
    cannotAddCardReasonLabel.font = [UIFont fontWithName:cardMainFont size:14];
    cannotAddCardReasonLabel.textAlignment = NSTextAlignmentLeft;
    cannotAddCardReasonLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cannotAddCardReasonLabel.numberOfLines = 6;
    
    //save deck button
    saveDeckButton = [[CFButton alloc] initWithFrame:CGRectMake(4, SCREEN_HEIGHT-36, 46, 32)];
    [saveDeckButton setImage:[UIImage imageNamed:@"save_deck_button"] forState:UIControlStateNormal];
    [saveDeckButton addTarget:self action:@selector(saveDeckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:saveDeckButton];
    
    addDeckButton = [[CFButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, SCREEN_HEIGHT-36, 46, 32)];
    [addDeckButton setImage:[UIImage imageNamed:@"add_deck_button"] forState:UIControlStateNormal];
    [addDeckButton addTarget:self action:@selector(addDeckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    backButton = [[CFButton alloc] initWithFrame:CGRectMake(4, 8, 46, 32)];
    [backButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //self.MyForgedCardsButton = [[UIButton alloc] initWithFrame:CGRectMake(14, 82, 200, 64)];
    self.MyForgedCardsButton = [[UIButton alloc] initWithFrame:CGRectMake(14*DeckWRatio, 82*DeckHRatio, 200*DeckWRatio, 64*DeckHRatio)];
    //self.MyForgedCardsButton.label.text = @"Forge Cards";
    [self.MyForgedCardsButton addTarget:self action:@selector(ForgedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.MyForgedCardsButton setTitle:@"Forge Cards" forState:UIControlStateNormal];
    
    //UIImageView *myCrdImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cardforgebuttonBURNED"]];
    
    //[myCrdImg setFrame:CGRectMake(55,100,300,100)];
    
    //[myCrdImg.layer setBorderColor:[[UIColor blackColor] CGColor]];
    //[myCrdImg.layer setBorderWidth:5.0];
    
    //[self.view addSubview:myCrdImg];
    
    //_makeCardsExplanationLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(72, 17, 140, 60)];
    _makeCardsExplanationLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(72*DeckWRatio, 17*DeckHRatio, 140*DeckWRatio, 60*DeckHRatio)];
    _makeCardsExplanationLabel.textColor = [UIColor whiteColor];
    _makeCardsExplanationLabel.backgroundColor = [UIColor clearColor];
    _makeCardsExplanationLabel.font = [UIFont fontWithName:cardMainFont size:20];
    _makeCardsExplanationLabel.textAlignment = NSTextAlignmentCenter;
    _makeCardsExplanationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _makeCardsExplanationLabel.numberOfLines = 0;
    _makeCardsExplanationLabel.strokeOn = YES;
    _makeCardsExplanationLabel.strokeColour = [UIColor blackColor];
    _makeCardsExplanationLabel.strokeThickness = 3;
    
    _makeCardsExplanationLabel.text = @"Create & Sell Your Own Cards!";
    
    UIImage *CardForgeButtonImg = [UIImage imageNamed:@"CardStoreBlueButton"];
    [self.MyForgedCardsButton setBackgroundImage:CardForgeButtonImg forState:UIControlStateNormal];
    
    //self.ForgeNewCardButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 100, 80)];
    //289 × 107 pixels
    self.ForgeNewCardButton = [[UIButton alloc] initWithFrame:CGRectMake(17*DeckWRatio, 75*DeckHRatio, 289/1.9*DeckWRatio, 107/1.8*DeckHRatio)];
    UIImage *PayToForgeImg = [UIImage imageNamed:@"FeaturedStorePurchaseButton"];
    [self.ForgeNewCardButton setImage:PayToForgeImg forState:UIControlStateNormal];
    self.ForgeNewCardButton.alpha = 0;
    
   _createCostLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(35*DeckWRatio, 75*DeckHRatio, 140*DeckWRatio, 60*DeckHRatio)];
    _createCostLabel.textColor = [UIColor whiteColor];
    _createCostLabel.backgroundColor = [UIColor clearColor];
    _createCostLabel.font = [UIFont fontWithName:cardMainFont size:20];
    _createCostLabel.textAlignment = NSTextAlignmentCenter;
    _createCostLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _createCostLabel.numberOfLines = 0;
    _createCostLabel.strokeOn = YES;
    _createCostLabel.strokeColour = [UIColor blackColor];
    _createCostLabel.strokeThickness = 3;
    _createCostLabel.text = @"500";
   
    
    
    [self.ForgeNewCardButton addTarget:self action:@selector(ForgeNewCard) forControlEvents:UIControlEventTouchUpInside];
    
    //new buy view code
    //-------------------buy gold view-------------------//
    _buyGoldViewDeck = [[UIView alloc] initWithFrame:self.view.bounds];
    _buyGoldViewDeck.alpha = 0;
    
    UIView *buyGoldDarkFilter = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH, SCREEN_HEIGHT-40)];
    buyGoldDarkFilter.backgroundColor = [[UIColor alloc]initWithHue:0 saturation:0 brightness:0 alpha:0.8];
    [buyGoldDarkFilter setUserInteractionEnabled:YES]; //blocks all interaction behind it
    [_buyGoldViewDeck addSubview:buyGoldDarkFilter];
    
    StrokedLabel*buyGoldLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    buyGoldLabel.textAlignment = NSTextAlignmentCenter;
    buyGoldLabel.textColor = [UIColor whiteColor];
    buyGoldLabel.backgroundColor = [UIColor clearColor];
    
    buyGoldLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE +11];
    buyGoldLabel.strokeOn = YES;
    buyGoldLabel.strokeColour = [UIColor blackColor];
    buyGoldLabel.strokeThickness = 5;
    buyGoldLabel.text = @"Purchase additional gold:";
    buyGoldLabel.center = CGPointMake(SCREEN_WIDTH/2, 100);
    [_buyGoldViewDeck addSubview:buyGoldLabel];
    
    CFButton*buyGoldBackButton = [[CFButton alloc] initWithFrame:CGRectMake(4, SCREEN_HEIGHT-40-40 + 4, 46, 32)];
    [buyGoldBackButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [buyGoldBackButton addTarget:self action:@selector(buyGoldBackButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [_buyGoldViewDeck addSubview:buyGoldBackButton];
    
    _buyGoldButtonsDeck = [NSMutableArray arrayWithCapacity:6];
    

    //code for coin balance view section, turn off section when not needed.
    self.UserCoinBalanceView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*0.6, 0*DeckHRatio, SCREEN_WIDTH*0.4, 157*DeckHRatio)];
    //self.UserCoinBalanceView.backgroundColor = [UIColor redColor];
    
   UIImage *borderImg = [UIImage imageNamed:@"CardDescriptionEdge"];
    self.myCoinBalanceFrame = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.UserCoinBalanceView.frame.size.width,self.UserCoinBalanceView.frame.size.height)];
    self.myCoinBalanceFrame.image = borderImg;
    
    [self.UserCoinBalanceView addSubview:self.myCoinBalanceFrame];
    
    
    UIImageView *coinBag = [[UIImageView alloc] init];
    
    //code
    self.UserCoinBalanceButton = [[UIButton alloc] initWithFrame:CGRectMake(10*DeckWRatio, 20*DeckHRatio, 45*DeckWRatio, 45*DeckHRatio)];
    UIImage *coinBagImg = [UIImage imageNamed:@"CoinPile002.png"];
    
    [self.UserCoinBalanceButton setImage:coinBagImg forState:UIControlStateNormal];
    [self.UserCoinBalanceButton addTarget:self action:@selector(openBuyGoldView)    forControlEvents:UIControlEventTouchUpInside];
    
    self.UserCoinBalanceLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(60*DeckWRatio,15*DeckHRatio,150*DeckWRatio,50*DeckHRatio)];
    _UserCoinBalanceLabel.textColor = [UIColor whiteColor];
    _UserCoinBalanceLabel.backgroundColor = [UIColor clearColor];
    _UserCoinBalanceLabel.font = [UIFont fontWithName:cardMainFont size:20];
    _UserCoinBalanceLabel.textAlignment = NSTextAlignmentLeft;
    _UserCoinBalanceLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _UserCoinBalanceLabel.numberOfLines = 0;
    _UserCoinBalanceLabel.strokeOn = YES;
    _UserCoinBalanceLabel.strokeColour = [UIColor blackColor];
    _UserCoinBalanceLabel.strokeThickness = 3;
    self.UserCoinBalanceLabel.text = @"40";
    
    [self.UserCoinBalanceView addSubview:self.UserCoinBalanceButton];
    [self.UserCoinBalanceView addSubview:self.UserCoinBalanceLabel];
    
    //set user CoinBalanceLabel value from user amount
    self.UserCoinBalanceLabel.text = [NSString stringWithFormat:@"%d", userGold];
    
    //128 × 180 pixels--card dimensions
    self.myFreeCardsImg = [[UIImageView alloc] initWithFrame:CGRectMake(10*DeckWRatio,75*DeckHRatio,128*0.35*DeckWRatio,180*0.35*DeckHRatio)];
    UIImage *freeCardImg = [UIImage imageNamed:@"CardStoreCardIcon"];
    self.myFreeCardsImg.image = freeCardImg;
    
    [self.UserCoinBalanceView addSubview:self.myFreeCardsImg];
    
    self.UserFreeCardsLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(60*DeckWRatio,80*DeckHRatio,90*DeckWRatio,50*DeckHRatio)];
    _UserFreeCardsLabel.textColor = [UIColor whiteColor];
    _UserFreeCardsLabel.backgroundColor = [UIColor clearColor];
    _UserFreeCardsLabel.font = [UIFont fontWithName:cardMainFont size:20];
    _UserFreeCardsLabel.textAlignment = NSTextAlignmentLeft;
    _UserFreeCardsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _UserFreeCardsLabel.numberOfLines = 2;
    _UserFreeCardsLabel.strokeOn = YES;
    _UserFreeCardsLabel.strokeColour = [UIColor blackColor];
    _UserFreeCardsLabel.strokeThickness = 3;
    self.UserFreeCardsLabel.text = @"2 Free Cards";
    
    [self.UserCoinBalanceView addSubview:self.UserFreeCardsLabel];
    
    //brian return point--need to add this coin balance button in front of other views--suggest adding somewhere else in code
    //code
    
    self.deleteDeckButton = [[CFButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, 8, 46, 32)];
    [self.deleteDeckButton setImage:[UIImage imageNamed:@"remove_deck_button"] forState:UIControlStateNormal];
    [self.deleteDeckButton addTarget:self action:@selector(deleteButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    autoAddView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    //---------------------filter view----------------------//
    _filterToggleButton = [[CFButton alloc] initWithFrame:CGRectMake(4 + 50, 8, 46, 32)];
    _filterToggleButton.label.text = @"Filter";
    [_filterToggleButton setTextSize:10];
    [_filterToggleButton addTarget:self action:@selector(filterToggleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:_filterToggleButton];
    
    //save deck dialog
    autoAddCardsLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT)];
    autoAddCardsLabel.textColor = [UIColor whiteColor];
    autoAddCardsLabel.backgroundColor = [UIColor clearColor];
    autoAddCardsLabel.font = [UIFont fontWithName:cardMainFont size:25];
    autoAddCardsLabel.textAlignment = NSTextAlignmentCenter;
    autoAddCardsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    autoAddCardsLabel.numberOfLines = 0;
    //autoAddCardsLabel.text;
    [autoAddCardsLabel sizeToFit];
    [autoAddView addSubview:autoAddCardsLabel];
    
    autoAddCardsButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    autoAddCardsButton.center = CGPointMake(SCREEN_WIDTH/2 - 80, SCREEN_HEIGHT - 60);
    autoAddCardsButton.label.text = @"Yes";
    [autoAddCardsButton setTextSize:18];
    [autoAddCardsButton addTarget:self action:@selector(autoAddCardsButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    notAutoAddCardsButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    notAutoAddCardsButton.center = CGPointMake(SCREEN_WIDTH/2 + 80, SCREEN_HEIGHT - 60);
    notAutoAddCardsButton.label.text = @"No";
    [notAutoAddCardsButton setTextSize:18];
    [notAutoAddCardsButton addTarget:self action:@selector(notAutoAddCardsButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    notFixDeckButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    notFixDeckButton.center = CGPointMake(SCREEN_WIDTH/2 - 80, SCREEN_HEIGHT - 60);
    notFixDeckButton.label.text = @"Yes";
    [notFixDeckButton setTextSize:18];
    [notFixDeckButton addTarget:self action:@selector(notFixDeckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    cancelNotFixButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    cancelNotFixButton.center = CGPointMake(SCREEN_WIDTH/2 + 80, SCREEN_HEIGHT - 60);
    cancelNotFixButton.label.text = @"No";
    [cancelNotFixButton setTextSize:18];
    [cancelNotFixButton addTarget:self action:@selector(cancelNotFixButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    autoAddCardsFailedLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT)];
    autoAddCardsFailedLabel.textColor = [UIColor whiteColor];
    autoAddCardsFailedLabel.backgroundColor = [UIColor clearColor];
    autoAddCardsFailedLabel.font = [UIFont fontWithName:cardMainFont size:25];
    autoAddCardsFailedLabel.textAlignment = NSTextAlignmentCenter;
    autoAddCardsFailedLabel.lineBreakMode = NSLineBreakByWordWrapping;
    autoAddCardsFailedLabel.numberOfLines = 0;
    autoAddCardsFailedLabel.text = @"Sorry, you don't have enough valid cards to fill up this deck. Please try again with different cards.";
    [autoAddCardsFailedLabel sizeToFit];
    
    autoAddCardsFailedButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    autoAddCardsFailedButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 60);
    autoAddCardsFailedButton.label.text = @"Ok";
    [autoAddCardsFailedButton setTextSize:18];
    [autoAddCardsFailedButton setImage:[UIImage imageNamed:@"ok_button"] forState:UIControlStateNormal];
    //[saveDeckButton addTarget:self action:@selector(saveDeckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //delete deck dialog
    deleteDeckLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT/2)];
    deleteDeckLabel.textColor = [UIColor whiteColor];
    deleteDeckLabel.backgroundColor = [UIColor clearColor];
    deleteDeckLabel.font = [UIFont fontWithName:cardMainFont size:25];
    deleteDeckLabel.textAlignment = NSTextAlignmentCenter;
    deleteDeckLabel.lineBreakMode = NSLineBreakByWordWrapping;
    deleteDeckLabel.numberOfLines = 0;
    deleteDeckLabel.text = @"Are you sure you want to delete this deck?";
    [deleteDeckLabel sizeToFit];
    
    self.deleteDeckConfirmButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    self.deleteDeckConfirmButton.center = CGPointMake(SCREEN_WIDTH/2 - 80, SCREEN_HEIGHT - 60);
    self.deleteDeckConfirmButton.label.text = @"Ok";
    [self.deleteDeckConfirmButton setTextSize:18];
    [self.deleteDeckConfirmButton addTarget:self action:@selector(deleteDeckConfirmButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    self.deleteDeckCancelButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    self.deleteDeckCancelButton.center = CGPointMake(SCREEN_WIDTH/2 + 80, SCREEN_HEIGHT - 60);
    self.deleteDeckCancelButton.label.text = @"No";
    [self.deleteDeckCancelButton setTextSize:18];
    [self.deleteDeckCancelButton addTarget:self action:@selector(deleteDeckCancelButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    
   // _searchResult = [[StrokedLabel alloc] initWithFrame:CGRectMake(10, self.cardsView.frame.size.height/2 - 40, self.cardsView.frame.size.width - 20, self.cardsView.frame.size.height)];
    _searchResult = [[StrokedLabel alloc] initWithFrame:CGRectMake(10*DeckWRatio, self.cardsView.frame.size.height/2 - (40*DeckHRatio), self.cardsView.frame.size.width - (20*DeckWRatio), self.cardsView.frame.size.height)];
    _searchResult.textColor = [UIColor whiteColor];
    _searchResult.backgroundColor = [UIColor clearColor];
    _searchResult.font = [UIFont fontWithName:cardMainFont size:20];
    _searchResult.textAlignment = NSTextAlignmentCenter;
    _searchResult.lineBreakMode = NSLineBreakByWordWrapping;
    _searchResult.numberOfLines = 0;
    _searchResult.strokeOn = YES;
    _searchResult.strokeColour = [UIColor blackColor];
    _searchResult.strokeThickness = 3;
    //_searchResult.center = CGPointMake(_cardsView.bounds.size.width/2, _cardsView.bounds.size.height/2);
   [self.view addSubview:_searchResult];
    
    //_deckCreateExplanationLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(10, self.cardsView.frame.size.height/2 - 39, self.cardsView.frame.size.width - 20, self.cardsView.frame.size.height)];
    _deckCreateExplanationLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(10*DeckWRatio, self.cardsView.frame.size.height/2 - (39*DeckHRatio), self.cardsView.frame.size.width - (20*DeckWRatio), self.cardsView.frame.size.height)];
    _deckCreateExplanationLabel.textColor = [UIColor whiteColor];
    _deckCreateExplanationLabel.backgroundColor = [UIColor clearColor];
    _deckCreateExplanationLabel.font = [UIFont fontWithName:cardMainFont size:20];
    _deckCreateExplanationLabel.textAlignment = NSTextAlignmentCenter;
    _deckCreateExplanationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _deckCreateExplanationLabel.numberOfLines = 0;
    _deckCreateExplanationLabel.strokeOn = YES;
    _deckCreateExplanationLabel.strokeColour = [UIColor blackColor];
    _deckCreateExplanationLabel.strokeThickness = 3;
    //_deckCreateExplanationLabel.center = CGPointMake(_cardsView.bounds.size.width/2, _cardsView.bounds.size.height/2);
    _deckCreateExplanationLabel.text = @"Decks Can Have Up To 5 FORGE Cards";
    [self.view addSubview:_deckCreateExplanationLabel];
    
    _deckCreateExplanationLabel2 = [[StrokedLabel alloc] initWithFrame:CGRectMake(10*DeckWRatio, self.cardsView.frame.size.height/2 + (60*DeckHRatio), self.cardsView.frame.size.width - (20*DeckWRatio), self.cardsView.frame.size.height)];
    _deckCreateExplanationLabel2.textColor = [UIColor whiteColor];
    _deckCreateExplanationLabel2.backgroundColor = [UIColor clearColor];
    _deckCreateExplanationLabel2.font = [UIFont fontWithName:cardMainFont size:20];
    _deckCreateExplanationLabel2.textAlignment = NSTextAlignmentCenter;
    _deckCreateExplanationLabel2.lineBreakMode = NSLineBreakByWordWrapping;
    _deckCreateExplanationLabel2.numberOfLines = 0;
    _deckCreateExplanationLabel2.strokeOn = YES;
    _deckCreateExplanationLabel2.strokeColour = [UIColor blackColor];
    _deckCreateExplanationLabel2.strokeThickness = 3;
    //_deckCreateExplanationLabel.center = CGPointMake(_cardsView.bounds.size.width/2, _cardsView.bounds.size.height/2);
    _deckCreateExplanationLabel2.text = @"Try Different Element Combinations For New Strategies";
    [self.view addSubview:_deckCreateExplanationLabel2];
    
    //@property (strong)StrokedLabel *deckCreateExplanationLabel;
    //@property (strong)StrokedLabel *deckCreateExplanationLabel2;
    
    
    
    
    invalidDeckButton = [[CFButton alloc] initWithFrame:CGRectMake(104,8,58, 32)];
    invalidDeckButton.buttonStyle = CFButtonStyleWarning;
    invalidDeckButton.label.text = @"Problems";
    [invalidDeckButton setTextSize:9];
    [invalidDeckButton addTarget:self action:@selector(invalidDeckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    _deckLimitationsButton = [[CFButton alloc] initWithFrame:CGRectMake(164,SCREEN_HEIGHT-36,58, 32)];
    _deckLimitationsButton.label.text = @"Limits";
    [_deckLimitationsButton setTextSize:10];
    [_deckLimitationsButton addTarget:self action:@selector(deckLimitationsButtonPressed)    forControlEvents:UIControlEventTouchUpInside];

    /** Activity */
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_activityIndicator setFrame:self.view.bounds];
    [_activityIndicator setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.5]];
    [_activityIndicator setUserInteractionEnabled:YES];
    _activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    _activityLabel.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + 60);
    _activityLabel.textAlignment = NSTextAlignmentCenter;
    _activityLabel.textColor = [UIColor whiteColor];
    _activityLabel.font = [UIFont fontWithName:cardMainFont size:20];
    _activityLabel.text = [NSString stringWithFormat:@"Processing..."];
    [_activityIndicator addSubview:_activityLabel];
    
    _activityFailedButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    _activityFailedButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 60);
    _activityFailedButton.label.text = @"Ok";
    [_activityFailedButton setTextSize:18];
    [_activityFailedButton addTarget:self action:@selector(activityFailedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    _invalidDeckReasonsLabel = [[UITextView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/8, SCREEN_WIDTH*6/8, SCREEN_HEIGHT*2/3)];
    _invalidDeckReasonsLabel.textColor = [UIColor whiteColor];
    _invalidDeckReasonsLabel.backgroundColor = [UIColor clearColor];
    _invalidDeckReasonsLabel.font = [UIFont fontWithName:cardMainFont size:14];
    [_invalidDeckReasonsLabel setDelegate:self];
    //_invalidDeckReasonsLabel.textAlignment = NSTextAlignmentCenter;
    [_invalidDeckReasonsLabel setUserInteractionEnabled:YES];
    //_invalidDeckReasonsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    //_invalidDeckReasonsLabel.numberOfLines = 30;
    
    _invalidDeckReasonsOkButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    _invalidDeckReasonsOkButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 60);
    _invalidDeckReasonsOkButton.label.text = @"Ok";
    [_invalidDeckReasonsOkButton setTextSize:18];
    [_invalidDeckReasonsOkButton addTarget:self action:@selector(invalidDeckReasonsOkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    //property view UIEDITBrian
    
    _propertiesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-_deckView.frame.size.width, _cardsView.frame.origin.y)];
    
    //_propertiesView.backgroundColor = [UIColor redColor];
    
    /*
    CFLabel*propertiesBackground = [[CFLabel alloc] initWithFrame:CGRectMake(_propertiesView.frame.origin.x, _propertiesView.frame.origin.y - 8, _propertiesView.frame.size.width+2, _propertiesView.frame.size.height + 8)];
    [propertiesBackground setBackgroundColor:COLOUR_INTERFACE_BLUE_DARK];
    [self.view addSubview:propertiesBackground];
    */
    
    self.propertyBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _propertiesView.frame.size.width, _propertiesView.frame.size.height)];
    //UIImageView *propertyBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _propertiesView.frame.size.width, _propertiesView.frame.size.height-50)];
    [_propertyBackground setImage:[UIImage imageNamed:@"CardCreateDialog2"]];
    //[propertyBackground setImage:[UIImage imageNamed:@"CardBackgroundLight"]];
    [self.view addSubview:_propertyBackground];
    //_propertiesView.backgroundColor = [UIColor redColor];
    
    //[_propertiesView addSubview:propertyBackground];
    
    
    _tagsPopularButton = [[CFButton alloc] initWithFrame:CGRectMake(_propertiesView.frame.size.width - 52 - 4, _propertiesView.frame.size.height - 36, 50, 28)];
    
    if (SCREEN_HEIGHT >= 568)
    {
        _tagsPopularButton = [[CFButton alloc] initWithFrame:CGRectMake(8, _propertiesView.frame.size.height - 40, 50, 32)];
    }
    _tagsPopularButton.label.text = @"Suggest";
    [_tagsPopularButton setTextSize:9];
    
    [_propertiesView addSubview:_tagsPopularButton];
    
    UILabel*deckNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 5, 45, 25)];
    deckNameLabel.textColor = [UIColor blackColor];
    deckNameLabel.font = [UIFont fontWithName:cardMainFont size:16];
    deckNameLabel.textAlignment = NSTextAlignmentRight;
    deckNameLabel.text = @"Name:";
    [_propertiesView addSubview:deckNameLabel];
    
    _nameField = [[UITextField alloc] initWithFrame:CGRectMake(59,4,_propertiesView.frame.size.width - 55 - 12,30)];
    _nameField.textColor = [UIColor blackColor];
    _nameField.font = [UIFont fontWithName:cardMainFont size:16];
    _nameField.returnKeyType = UIReturnKeyDone;
    [_nameField setPlaceholder:@"Name your deck"];
    [_nameField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_nameField addTarget:self action:@selector(nameFieldBegan) forControlEvents:UIControlEventEditingChanged];
    [_nameField setDelegate:self];
    [_nameField.layer setBorderColor:[UIColor blackColor].CGColor];
    [_nameField.layer setBorderWidth:2];
    _nameField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    [_nameField setBackgroundColor:COLOUR_INTERFACE_RED];
    
    [_propertiesView addSubview:_nameField];
    
    UILabel*deckTagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 40, 45, 25)];
    deckTagsLabel.textColor = [UIColor blackColor];
    deckTagsLabel.font = [UIFont fontWithName:cardMainFont size:16];
    deckTagsLabel.textAlignment = NSTextAlignmentRight;
    deckTagsLabel.text = @"Tags:";
    [_propertiesView addSubview:deckTagsLabel];
    
    _tagsArea = [[UITextView alloc] initWithFrame:CGRectMake(59, 38, _propertiesView.frame.size.width - 105 - 12, _propertiesView.frame.size.height - 38 - 8)];
    _tagsArea.textColor = [UIColor blackColor];
    [_tagsArea setBackgroundColor:COLOUR_INTERFACE_BLUE_LIGHT];
    _tagsArea.font = [UIFont fontWithName:cardMainFont size:16];
    [_tagsArea setAutocorrectionType:UITextAutocorrectionTypeNo];
    //[_nameField addTarget:self action:@selector(searchFieldBegan) forControlEvents:UIControlEventEditingDidBegin];UIControlEventEditingDidEnd];
    [_tagsArea setDelegate:self];
    [_tagsArea.layer setBorderColor:[UIColor blackColor].CGColor];
    [_tagsArea.layer setBorderWidth:2];
    _tagsArea.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    //_tagsArea.layer.cornerRadius = 4.0;
    
    if (SCREEN_HEIGHT >= 568)
        _tagsArea.frame = CGRectMake(59, 38, _propertiesView.frame.size.width - 55 - 12, _propertiesView.frame.size.height - 38 - 8);
    
    [_propertiesView addSubview:_tagsArea];
    
    
    [self.view addSubview:_propertiesView];
    
    //-------------------filter view------------------//
    _filterView = [[CFLabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-40, self.view.bounds.size.width, 258)];
    [self.view insertSubview:_filterView aboveSubview:_deckView];
    [_filterView setUserInteractionEnabled:YES];
    [_filterView setBackgroundColor:COLOUR_INTERFACE_BLUE_DARK];
    
    //cost buttons
    CGPoint costFilterStartPoint = CGPointMake(20, 24);
    _costFilterButtons = [NSMutableArray arrayWithCapacity:11];
    for (int i = 0; i < 11; i++)
    {
        UIButton*costFilterButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,28,28)];
        [costFilterButton setImage:RESOURCE_ICON_IMAGE forState:UIControlStateNormal];
        [costFilterButton addTarget:self action:@selector(costFilterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        costFilterButton.center = CGPointMake(costFilterStartPoint.x + i*28, costFilterStartPoint.y);
        
        [_filterView addSubview:costFilterButton];
        
        StrokedLabel*costLabel = [[StrokedLabel alloc]initWithFrame:costFilterButton.bounds];
        costLabel.textAlignment = NSTextAlignmentCenter;
        costLabel.textColor = [UIColor whiteColor];
        costLabel.backgroundColor = [UIColor clearColor];
        costLabel.font = [UIFont fontWithName:cardMainFontBlack size:22];
        costLabel.strokeOn = YES;
        costLabel.strokeColour = [UIColor blackColor];
        costLabel.strokeThickness = 3;
        costLabel.text = [NSString stringWithFormat:@"%d", i];
        [costFilterButton addSubview:costLabel];
        //costLabel.center = costFilterButton.center;
        
        [_costFilterButtons addObject:costFilterButton];
    }
    
    //rarity buttons
    CGPoint rarityFilterStartPoint = CGPointMake(SCREEN_WIDTH/3, 60);
    _rarityFilterButtons = [NSMutableArray arrayWithCapacity:cardRarityLegendary+1];
    for (int i = 0; i <= cardRarityLegendary; i++)
    {
        CFButton*rarityFilterButton = [[CFButton alloc] initWithFrame:CGRectMake(0,0,90,25)];
        [rarityFilterButton.dottedBorder removeFromSuperlayer];
        rarityFilterButton.label.text = [CardModel getRarityText:i];
        [rarityFilterButton setTextSize:14];
        //[rarityFilterButton setImage:[UIImage imageNamed:@"filter_button"] forState:UIControlStateNormal];
        [rarityFilterButton addTarget:self action:@selector(rarityFilterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        rarityFilterButton.center = CGPointMake(rarityFilterStartPoint.x, rarityFilterStartPoint.y + i*28);
        
        [_filterView addSubview:rarityFilterButton];
        
        /*
        StrokedLabel*rarityLabel = [[StrokedLabel alloc]initWithFrame:CGRectMake(0, 0, 90, 25)];
        rarityLabel.textAlignment = NSTextAlignmentCenter;
        rarityLabel.textColor = [UIColor whiteColor];
        rarityLabel.backgroundColor = [UIColor clearColor];
        rarityLabel.font = [UIFont fontWithName:cardMainFont size:18];
        //rarityLabel.strokeOn = YES;
        rarityLabel.strokeColour = [UIColor blackColor];
        rarityLabel.strokeThickness = 3;
        rarityLabel.text = [CardModel getRarityText:i];
        [rarityFilterButton addSubview:rarityLabel];
        //rarityLabel.backgroundColor = [UIColor blueColor];
        //costLabel.center = costFilterButton.center;
        */
        [_rarityFilterButtons addObject:rarityFilterButton];
    }
    
    //element buttons
    CGPoint elementFilterStartPoint = CGPointMake(SCREEN_WIDTH*2/3, 60);
    _elementFilterButtons = [NSMutableArray arrayWithCapacity:7];
    for (int i = 0; i < 7; i++)
    {
        CFButton*elementFilterButton = [[CFButton alloc] initWithFrame:CGRectMake(0,0,90,25)];
        [elementFilterButton.dottedBorder removeFromSuperlayer];
        elementFilterButton.label.text = [CardModel elementToString:i];
        [elementFilterButton setTextSize:14];
        [elementFilterButton addTarget:self action:@selector(elementFilterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        elementFilterButton.center = CGPointMake(elementFilterStartPoint.x, elementFilterStartPoint.y + i*28);
        
        [_filterView addSubview:elementFilterButton];

        //costLabel.center = costFilterButton.center;
        
        [_elementFilterButtons addObject:elementFilterButton];
    }
    
    _modalFilter = [[UILabel alloc] initWithFrame:self.view.bounds];
    _modalFilter.backgroundColor = [[UIColor alloc]initWithHue:0 saturation:0 brightness:0 alpha:0.8];
    [_modalFilter setUserInteractionEnabled:YES]; //blocks all interaction behind it
    
    if (_isTutorial)
    {
        [self modalScreen];
        self.tutOkButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        self.tutOkButton.label.text = @"Ok";
        
        self.tutLabel = [[CFLabel alloc] initWithFrame:CGRectMake(0,0,260,180)];
        [self setTutLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
        [self.tutLabel setIsDialog:YES];
        self.tutLabel.label.text = @"This is the deck editor. Here you can browse through your cards and either edit an existing deck, or build a new one.";
        [self.tutOkButton addTarget:self action:@selector(removeAllTutorialViews) forControlEvents:UIControlEventTouchUpInside];
        [self.tutLabel.label setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:_tutLabel];
        [self.view addSubview:_tutOkButton];
    }
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(tapRegistered)];
    [tapGesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGesture];
    
    self.UserCoinBalanceView.alpha = 0;
    [self.view addSubview:self.UserCoinBalanceView];
    
    self.myAnvilImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cardforgeanvilIconFiltered"]];
    _myAnvilImg.frame = CGRectMake(8*DeckWRatio,10*DeckHRatio,70*DeckWRatio,70*DeckHRatio);
    [self.view addSubview:_myAnvilImg];
    
    [self.view addSubview:_makeCardsExplanationLabel];
    
    [self resetAllViews];
    
    
}

/** Update all cards to ensure cards that cannot be added are grayed out */
- (void) updateCardsViewCards
{
    for (CardModel* card in self.cardsView.currentCardModels)
        [self updateCard:card];
}

-(void) updateCard:(CardModel*)card
{
    if ([self.deckView containsCardId:card.idNumber])
    {
        card.cardViewState = cardViewStateCardViewerTransparent;
    }
    else if ([[self canAddCardToDeck: card] count] == 0)
    {
        //NSLog(@"can add");
        card.cardViewState = cardViewStateCardViewer;
    }
    else
    {
        //NSLog(@"can't add");
        card.cardViewState = cardViewStateCardViewerGray;
    }
    
    //prevent updating pointers that wrongly points to the deckview
    if (card.cardView != nil && card.cardView.superview != nil && [card.cardView.superview isKindOfClass:[CardsCollectionCell class]])
        card.cardView.cardViewState = card.cardViewState;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)nameFieldBegan
{
    while (_nameField.text.length > 100)
        _nameField.text = [_nameField.text substringToIndex:[_nameField.text length]-1];
    
    _hasMadeChange = YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (textView == _tagsArea)
    {
        while (textView.text.length > 100)
            textView.text = [textView.text substringToIndex:[textView.text length]-1];
    }
    //not editable
    else if (textView == _invalidDeckReasonsLabel)
            [textView resignFirstResponder];
    
    _hasMadeChange = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isModal)
        return;
    
    UITouch *touch = [touches anyObject];
    UIView*touchedView = touch.view;
    
    //touched a card in current list of cards
    if ([touchedView isKindOfClass:[CardView class]])
    {
        NSLog(@"touched");
        CardView*cardView = (CardView*)touchedView;
        UIView*view = cardView.superview;
        
        //cardsView
        if ([cardView.superview isKindOfClass:[UICollectionViewCell class]])
        {
            
            if (cardView != currentCard && currentCard == nil && cardView.cardViewState != cardViewStateCardViewerTransparent)
            {
                NSLog(@"maxed");
                CardView*newMaximizedView = [[CardView alloc] initWithModel:cardView.cardModel viewMode:cardViewModeEditor]; //constructor also modifies monster's cardView pointer
                newMaximizedView.frontFacing = YES;
                [newMaximizedView setCardViewState:cardView.cardViewState];
                
                newMaximizedView.cardModel.cardView = cardView; //recover the pointer
                
                //find index of cardView
                for (int i = 0; i < self.cardsView.currentCardModels.count; i++)
                    if (self.cardsView.currentCardModels[i] == [cardView cardModel])
                    {
                        NSLog(@"found current index");
                        currentIndex = i;
                        
                        break;
                    }
                
                //check to see if the card at this current index is in the new cards index, remove it if so.
                
                NSNumber *currentIndexNum = [NSNumber numberWithInt:currentIndex];
                if([self.cardsView.indexOfNewCards containsObject:currentIndexNum])
                {
                   [self.cardsView removeNewIndexNum:currentIndexNum];
                }
            
                //store this card as currentCard
                currentCard = newMaximizedView;
                originalCurrentCard = cardView;
                
                CGPoint cardViewCenter = [self.view convertPoint:cardView.center fromView:cardView];
                
                //scrolls to left or right side depending on current position (TODO: may feel kinda weird)
                enum UICollectionViewScrollPosition scrollDir;
                
                if (cardViewCenter.x < self.cardsView.frame.origin.x + self.cardsView.frame.size.width/2)
                    scrollDir = UICollectionViewScrollPositionLeft;
                else
                    scrollDir = UICollectionViewScrollPositionRight;
                
                [self.cardsView.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]  animated:YES scrollPosition:scrollDir];
                
                //NSLog(@"%@ %@", NSStringFromCGRect(cardViewRect), NSStringFromCGRect(self.cardsView.frame));
                
                
                //[self.cardsView.collectionView scrollRectToVisible:CGRectMake(cardViewTopLeft.x, cardViewTopLeft.y, cardView.frame.size.width, cardView.frame.size.height) animated:YES];
                
                if(self.isForgeCardsMode)
                {
                      [self maximizeCardAnimation:newMaximizedView originalCard:cardView mode:cardCollectionForgeCard];
                }
                [self maximizeCardAnimation:newMaximizedView originalCard:cardView mode:cardCollectionAddCard];
                if ([self isFilterOpen])
                    [self setFilterViewState:NO];
            }
        }
        else if ([cardView.superview isKindOfClass:[UIScrollView class]] || [cardView.superview isKindOfClass:[UITableViewCell class]]) //depends on SDK
        {
            NSLog(@"side");
            //nearly identical code with cardview
            if (cardView != currentCard && currentCard == nil)
            {
                NSLog(@"side opened");
                CardView*newMaximizedView = [[CardView alloc] initWithModel:cardView.cardModel viewMode:cardViewModeEditor]; //constructor also modifies monster's cardView pointer
                newMaximizedView.frontFacing = YES;
                [newMaximizedView setCardViewState:cardView.cardViewState];
                
                newMaximizedView.cardModel.cardView = cardView; //recover the pointer
                
                //find index of cardView in table
                for (int i = 0; i < self.deckView.currentCells.count; i++)
                    if (self.deckView.currentCells[i] == cardView.cardModel)
                    {
                        currentIndex = i;
                        break;
                    }
                
                //store this card as currentCard
                currentCard = newMaximizedView;
                originalCurrentCard = cardView;
                
                CGPoint cardViewCenter = [self.view convertPoint:cardView.center fromView:cardView];
                
                [self maximizeCardAnimation:newMaximizedView originalCard:cardView mode:cardCollectionRemoveCard];
                if ([self isFilterOpen])
                    [self setFilterViewState:NO];
            }
        }
        else if (cardView == currentCard)
        {
            //[self addCardToDeckPressed];
            
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 currentCard.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_SCALE, CARD_VIEWER_SCALE);
                                 currentCard.center = [self.view convertPoint:originalCurrentCard.center fromView:originalCurrentCard];
                             }
                             completion:^(BOOL completed){
                                 [currentCard removeFromSuperview];
                                 currentCard = nil;
                             }];
            
            [self unmaximizeCard:lastVCardCollectionViewMode];
        }
    }
    else
    {
        //selecting an existing deck
        NSIndexPath *indexPath = [self.deckView.tableView indexPathForRowAtPoint:[touch locationInView:self.deckView]];
        
        if (indexPath)
        {
            //because for whatever reason it's possible to select a card view here
            if ([self.deckView.currentCells[indexPath.row] isKindOfClass:[DeckModel class]])
            {
                currentDeck = self.deckView.currentCells[indexPath.row];
                
                [self setupDeckEditView];
            }
        }
    }
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(BOOL)isRowVisible: (int)row {
    NSArray *indexes = [self.cardsView.collectionView indexPathsForVisibleItems];
    for (NSIndexPath *index in indexes)
        if (index.row == row)
            return YES;
    
    return NO;
}

-(void)cardsViewFinishedScrollingAnimation
{
   
}

/** Performs the animation of the card maximizing. Will wait for cardsView's scrolling to finish before playing. */
-(void) maximizeCardAnimation:(CardView*)newMaximizedView originalCard:(CardView*)cardView mode:(enum CardCollectinViewMode)mode
{
    [self performBlock:^{
        if (self.cardsView.isScrolling)
        {
            NSLog(@"is scrolling");
            [self maximizeCardAnimation:newMaximizedView originalCard:cardView mode:mode];
        }
        else
        {
            NSLog(@"scrolling done");
            //darken the background (also disables views)
            [self maximizeCard:mode];
            
            //[currentCard setCardViewState:cardViewStateMaximize];
            
            //for the maximizing animation, the new card starts out in the same size and pos as the original card
            currentCard.transform = originalCurrentCard.transform;
            currentCard.center = [self.view convertPoint:originalCurrentCard.center fromView:originalCurrentCard];
            
            //the new view is a maxed card for closing viewing
            [self.view addSubview:currentCard];
            
            //animate the maximizing
            [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 currentCard.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_MAXED_SCALE, CARD_VIEWER_MAXED_SCALE);
                                 currentCard.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - 40);
                             }
                             completion:nil];
        }
    } afterDelay:0.05];
}

-(void)darkenScreen
{
    darkFilter.alpha = 0;
    [self.view addSubview:darkFilter];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         darkFilter.alpha = 0.9;
                     }
                     completion:nil];
}

-(void)undarkenScreen
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         darkFilter.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [darkFilter removeFromSuperview];
                     }];
}


-(void)openBuyGoldView
{
    [self.view insertSubview:_buyGoldViewDeck belowSubview:_footerView];
    [backButton setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _buyGoldViewDeck.alpha = 1;
                         backButton.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              //_blankCardView.alpha = 0;
                                          }completion:nil];
                     }];
}


-(void)buyGoldBackButtonPressed
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _buyGoldViewDeck.alpha = 0;
                         backButton.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         [backButton setUserInteractionEnabled:YES];
                         [_buyGoldViewDeck removeFromSuperview];
                     }];
}


-(void)ForgeNewCard
{
    //bring up the screen to create a brand new card.
    CardEditorViewController *viewController = [[CardEditorViewController alloc] initWithMode:cardEditorModeCreation WithCard:nil];
    
    [self presentViewController:viewController animated:YES completion:nil];
    
}

-(void)maximizeCard:(enum CardCollectinViewMode)mode
{
    lastVCardCollectionViewMode = mode;
    darkFilter.alpha = 0;
    
    [UserModel setCDCardVersion:currentCard.cardModel];
    
    [self.view addSubview:darkFilter];
    
    if (mode== cardCollectionForgeCard)
    {
        /*
        @property (strong)UIButton *UpgradeConfirmButton;
        @property (strong)StrokedLabel *TotalCardSalesLabel;
        @property (strong)StrokedLabel *TotalCardLikesLabel;
        @property (strong)StrokedLabel *TotalGoldEarnedLabel;
        @property (strong)StrokedLabel *CardApprovalStatus;
        @property (strong)StrokedLabel *CardRarityLabel;
        @property (strong)StrokedLabel *CostToIncreaseToNextRarity;
        @property (strong)UIImageView *CardSalesIcon;
        @property (strong)UIImageView *CardLikesIcon;
        @property (strong)UIImageView *GoldEarnedIcon;
        */
        self.UpgradeConfirmButton = [[UIButton alloc] initWithFrame:CGRectMake(75*DeckWRatio,400*DeckHRatio,289/1.2*DeckWRatio,107/1.3*DeckHRatio)];
          UIImage *PayToForgeImg = [UIImage imageNamed:@"FeaturedStorePurchaseButton"];

        [self.UpgradeConfirmButton setImage:PayToForgeImg forState:UIControlStateNormal];
        //broop
        [self.UpgradeConfirmButton addTarget:self action:@selector(UpgradeCard) forControlEvents:UIControlEventTouchUpInside];
        
        self.TotalCardSalesLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(400*DeckWRatio,20*DeckHRatio,150,40)];
        self.TotalCardSalesLabel.textColor = [UIColor whiteColor];
        self.TotalCardSalesLabel.backgroundColor = [UIColor clearColor];
        self.TotalCardSalesLabel.font = [UIFont fontWithName:cardMainFont size:20];
        self.TotalCardSalesLabel.textAlignment = NSTextAlignmentCenter;
        self.TotalCardSalesLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.TotalCardSalesLabel.numberOfLines = 0;
        self.TotalCardSalesLabel.strokeOn = YES;
        self.TotalCardSalesLabel.strokeColour = [UIColor blackColor];
        self.TotalCardSalesLabel.strokeThickness = 3;
        self.TotalCardSalesLabel.text = @"400";
        
        self.TotalCardLikesLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(400*DeckWRatio,60*DeckHRatio,150,40)];
        self.TotalCardLikesLabel.textColor = [UIColor whiteColor];
        self.TotalCardLikesLabel.backgroundColor = [UIColor clearColor];
        self.TotalCardLikesLabel.font = [UIFont fontWithName:cardMainFont size:20];
        self.TotalCardLikesLabel.textAlignment = NSTextAlignmentCenter;
        self.TotalCardLikesLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.TotalCardLikesLabel.numberOfLines = 0;
        self.TotalCardLikesLabel.strokeOn = YES;
        self.TotalCardLikesLabel.strokeColour = [UIColor blackColor];
        self.TotalCardLikesLabel.strokeThickness = 3;
        self.TotalCardLikesLabel.text = @"20";
        
        self.TotalGoldEarnedLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(400*DeckWRatio,60*DeckHRatio,150,40)];
        self.TotalGoldEarnedLabel.textColor = [UIColor whiteColor];
        self.TotalGoldEarnedLabel.backgroundColor = [UIColor clearColor];
        self.TotalGoldEarnedLabel.font = [UIFont fontWithName:cardMainFont size:20];
        self.TotalGoldEarnedLabel.textAlignment = NSTextAlignmentCenter;
        self.TotalGoldEarnedLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.TotalGoldEarnedLabel.numberOfLines = 0;
        self.TotalGoldEarnedLabel.strokeOn = YES;
        self.TotalGoldEarnedLabel.strokeColour = [UIColor blackColor];
        self.TotalGoldEarnedLabel.strokeThickness = 3;
        self.TotalGoldEarnedLabel.text = @"170";
        
        self.CardSalesIcon = [[UIImageView alloc] initWithFrame:CGRectMake(350*DeckWRatio,20*DeckHRatio,50,50)];
        self.CardSalesIcon.image = [UIImage imageNamed:@"CoinPile002.png"];
        
        
        self.CardLikesIcon = [[UIImageView alloc] initWithFrame:CGRectMake(350*DeckWRatio,60*DeckHRatio,50,50)];
        self.CardLikesIcon.image = [UIImage imageNamed:@"like_icon.png"];
        
        
        [self.view addSubview:self.UpgradeConfirmButton];
        [self.view addSubview:self.TotalCardSalesLabel];
        [self.view addSubview:self.TotalCardLikesLabel];
        [self.view addSubview:self.TotalGoldEarnedLabel];
        [self.view addSubview:self.CardSalesIcon];
        [self.view addSubview:self.CardLikesIcon];
        
    
    }
    
    if (mode == cardCollectionAddCard)
    {
        addCardToDeckButton.alpha = 0;
        cannotAddCardReasonLabel.alpha = 0;
        sellCardButton.alpha = 0;
        [addCardToDeckButton setEnabled:YES];
        
        [self.view addSubview:addCardToDeckButton];
        [self.view addSubview:sellCardButton];
        
        //is creator, or is starter card, cannot sell this card
        if ([currentCard.cardModel.creator isEqualToString:userPF.objectId] || currentCard.cardModel.idNumber < CARD_ID_START)
        {
            [sellCardButton setEnabled:NO];
        }
        else
        {
            [sellCardButton setEnabled:YES];
        }
        
        NSMutableArray*reasons = [self canAddCardToDeck:currentCard.cardModel];
        if (reasons.count > 0)
        {
            BOOL currentDeckValid = [self isCurrentDeckValidIgnoreTooFewCards];
            
            NSString *reasonsText = @"Cannot add this card to deck.\n";
            
            if (currentDeckValid)
            {
            for (NSString *reason in reasons)
                reasonsText = [NSString stringWithFormat:@"%@- %@\n", reasonsText, reason];
            }
            else
                reasonsText = [NSString stringWithFormat:@"%@- Target deck is currently invalid. Fix the problem first before adding any more cards.", reasonsText];
            
            cannotAddCardReasonLabel.text = reasonsText;
            [cannotAddCardReasonLabel sizeToFit];
            [self.view addSubview:cannotAddCardReasonLabel];
            [addCardToDeckButton setEnabled:NO];
        }
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             darkFilter.alpha = 0.9;
                             addCardToDeckButton.alpha = 1;
                             cannotAddCardReasonLabel.alpha = 1;
                             sellCardButton.alpha = 1;
                         }
                         completion:nil];
    }
    else if (mode == cardCollectionRemoveCard)
    {
        removeCardFromDeckButton.alpha = 0;
        [self.view addSubview:removeCardFromDeckButton];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             darkFilter.alpha = 0.9;
                             removeCardFromDeckButton.alpha = 1;
                         }
                         completion:nil];
    }
    
}

-(void)UpgradeCard
{
    //
}

-(void)unmaximizeCard:(enum CardCollectinViewMode)mode
{
    if (mode == cardCollectionAddCard)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             darkFilter.alpha = 0;
                             addCardToDeckButton.alpha = 0;
                             cannotAddCardReasonLabel.alpha = 0;
                             sellCardButton.alpha = 0;
                         }
                         completion:^(BOOL completed){
                             [darkFilter removeFromSuperview];
                             [addCardToDeckButton removeFromSuperview];
                             [sellCardButton removeFromSuperview];
                             if (cannotAddCardReasonLabel.superview!=nil)
                                 [cannotAddCardReasonLabel removeFromSuperview];
                         }];
    }
    else if (mode == cardCollectionRemoveCard)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             darkFilter.alpha = 0;
                             removeCardFromDeckButton.alpha = 0;
                         }
                         completion:^(BOOL completed){
                             [darkFilter removeFromSuperview];
                             [removeCardFromDeckButton removeFromSuperview];
                         }];
    }
}

- (void) addCardToDeckPressed
{
    _hasMadeChange = YES;
    [currentCard removeFromSuperview];
    
    [self addCardToDeckView:currentCard.cardModel];
    
    currentCard = nil;
    
    [self unmaximizeCard:cardCollectionAddCard];
    //[self.cardsView removeCellAt:currentIndex onFinish:^(void){[self updateCardsViewCards];}];
    //TODO fade it instead
    
    currentIndex = -1;
}

/** Inserts the card into the correct position in the deck view */
-(void)addCardToDeckView: (CardModel*)card
{
    NSUInteger insertionIndex = -1;
    
    //insert at the first position where card < card at index
    for (int i = 0; i < [self.deckView.currentCells count]; i++)
    {
        CardModel *cellCard = self.deckView.currentCells[i];
        if ([card compare:cellCard] == NSOrderedAscending)
        {
            insertionIndex = i;
            
            break;
        }
    }
    
    //not found index, insert at end
    if (insertionIndex == -1)
        insertionIndex = self.deckView.currentCells.count;
    
    [self.deckView.currentCells insertObject:card atIndex:insertionIndex];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:insertionIndex inSection:0];
    
    [self.deckView.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
     [self.deckView.tableView reloadInputViews];
    [self.deckView.tableView reloadData];
    
    //scroll to the newly inserted position
    [self.deckView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:insertionIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    if([self isCurrentDeckValid])
        [invalidDeckButton removeFromSuperview];
    
    [self updateCardsViewCards];
    [self updateCardsCounterLabel];
}

-(void) removeCardFromDeckPressed
{
    _hasMadeChange = YES;
    [currentCard removeFromSuperview];
    
    currentCard = nil;
    
    [self unmaximizeCard:cardCollectionRemoveCard];
    [self.deckView removeCellAt:currentIndex];
    [self updateCardsCounterLabel];
    [self updateCardsViewCards];
    [self.cardsView reloadInputViews];
    [self.cardsView.collectionView reloadData];
    currentIndex = -1;
    
    if([self isCurrentDeckValid])
        [invalidDeckButton removeFromSuperview];
}

/** Inserts the card into the correct position in the cards view */
/*
-(void)addCardToCardsView: (CardView*)card
{
    int insertionIndex = -1;
    
    //insert at the first position where card < card at index
    for (int i = 0; i < [self.cardsView.currentCardModels count]; i++)
    {
        CardModel *cellCard = self.cardsView.currentCardModels[i];
        if ([card.cardModel compare:cellCard] == NSOrderedAscending)
        {
            insertionIndex = i;
            break;
        }
    }
    
    //not found index, insert at end
    if (insertionIndex == -1)
        insertionIndex = self.cardsView.currentCardModels.count;
    
    card.cardHighlightType = cardHighlightNone;
    card.cardViewState = cardViewStateCardViewer;
    card.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_SCALE, CARD_VIEWER_SCALE);
    
    [self.cardsView.currentCardModels insertObject:card atIndex:insertionIndex];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:insertionIndex inSection:0];
    [self.cardsView.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
    [self.cardsView.collectionView reloadInputViews];
}*/

-(void) saveDeck
{
    DeckModel *deckToSave;
    if (currentDeck == nil)
    {
        //add this new deck to userModel
        DeckModel* newDeck = [[DeckModel alloc] init];
        newDeck.name = @"New Deck";
        
        for (CardModel* card in self.deckView.currentCells){
            if (newDeck.cards.count < 20) {
                [newDeck addCard:card];
            }
            
        }
        deckToSave = newDeck;
    }
    else
    {
        //clear the deck and add the new cards in
        [currentDeck.cards removeAllObjects];
        
        for (CardModel* card in self.deckView.currentCells){
            if (currentDeck.cards.count < 20) {
                [currentDeck addCard:card];
            }
            
        }
        deckToSave = currentDeck;
    }
    
    if (_nameField.text.length == 0)
        deckToSave.name = @"New Deck";
    else
        deckToSave.name = _nameField.text;
    
    if (_tagsArea.text.length > 0)
    {
        NSString *tags = [_tagsArea.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        NSArray*stringSplit = [tags componentsSeparatedByString:@" "];
        NSMutableArray*tagsNoDup = [NSMutableArray array];
        
        for (NSString*string in stringSplit)
        {
            if (![tagsNoDup containsObject:string] && string.length > 0)
                [tagsNoDup addObject:string];
        }
        
        deckToSave.tags = tagsNoDup;
    }
    
    //save the deck only if it actually exists
    if (deckToSave != nil)
    {
        [self showActivityIndicatorWithBlock:^BOOL{
            BOOL succ = [UserModel saveDeck:deckToSave];
            if (succ)
            {
                [self resetAllViews];
                return YES;
            }
            else
                return NO;
        } loadingText:@"Saving..." failedText:@"Failed to save deck."];
    }
    else
        [self resetAllViews];
}

-(void) saveDeckButtonPressed
{
    if ([self isCurrentDeckValid])
    {
        if (_hasMadeChange) //save only if made change
            [self saveDeck];
        else
            [self resetAllViews];
    }
    else
    {
        NSLog(@"not valid");
        
        /*
        DeckModel *deck = [[DeckModel alloc]init];
        for (CardModel* card in self.deckView.currentCells)
            [deck addCard:card];*/
        
        for (UIView*view in autoAddView.subviews)
            [view removeFromSuperview];
        
        autoAddCardsLabel.frame = CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT);
        
        //TODO: algorithm to automatically add decks is probably impossible (or just not very useful) because of the restriction between cards
        /*
        BOOL deckTooSmall = [DeckModel isDeckInvalidOnlyTooFewCards:deck];
        if (deckTooSmall)
        {
            autoAddCardsLabel.text = @"You haven't added enough cards to fill up the deck. Would you like them to be added automatically?";
            
            [autoAddView addSubview:autoAddCardsButton];
            [autoAddView addSubview:notAutoAddCardsButton];
        }
        else
        {*/
            autoAddCardsLabel.text = @"The deck you are trying to save is invalid. Would you like to quit anyways?";
            
            [autoAddView addSubview:notFixDeckButton];
            [autoAddView addSubview:cancelNotFixButton];
        //}
        
        [autoAddCardsLabel sizeToFit];
        
        [autoAddView addSubview:autoAddCardsLabel];
        
        autoAddView.alpha = 0;
        
        [self darkenScreen];
        [self.view addSubview:autoAddView];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             autoAddView.alpha = 1;
                         }
                         completion:^(BOOL completed){
                         }];
    }
}

-(void) updateCardsCounterLabel
{
    deckCountLabel.text = [NSString stringWithFormat:@"%d/%d", self.deckView.currentCells.count, MAX_CARDS_IN_DECK];
}


-(void) updateDeckCounterLabel
{
    deckCountLabel.text = [NSString stringWithFormat:@"%d/%d", self.deckView.currentCells.count, userDeckLimit];
}


/** Returns list of reasons why the deck is invalid. If is valid, returns empty array */
-(NSMutableArray*) canAddCardToDeck: (CardModel*) card
{
    DeckModel*deck = [[DeckModel alloc] init];
    for (CardModel* card in self.deckView.currentCells)
        [deck addCard:card];
    [deck addCard:card];
    [DeckModel validateDeckIgnoreTooFewCards:deck];
    
    return deck.invalidReasons;
}

-(BOOL) isCurrentDeckValid
{
    DeckModel*deck = [[DeckModel alloc] init];
    for (CardModel* card in self.deckView.currentCells)
        [deck addCard:card];
    [DeckModel validateDeck:deck];
    
    return !deck.isInvalid;
}

-(BOOL)isCurrentDeckValidIgnoreTooFewCards
{
    DeckModel*deck = [[DeckModel alloc] init];
    for (CardModel* card in self.deckView.currentCells)
        [deck addCard:card];
    [DeckModel validateDeckIgnoreTooFewCards:deck];
    
    return !deck.isInvalid;
}

-(void)autoAddCardsButtonPressed
{
    //TODO temporary method, just add random cards
    //TODO later needs to add cards that is actually valid
    NSMutableArray*ownedCards = [NSMutableArray array];
    for (CardModel*card in self.cardsView.currentCardModels)
        [ownedCards addObject:card];
    
    while (self.deckView.currentCells.count < MAX_CARDS_IN_DECK)
    {
        int randomIndex = [[NSNumber numberWithUnsignedInteger:arc4random_uniform(ownedCards.count - 1)] intValue];
        
        CardModel*cardModel = ownedCards[randomIndex];
        
        int insertionIndex = -1;
        
        //insert at the first position where card < card at index
        for (int i = 0; i < [self.deckView.currentCells count]; i++)
        {
            CardModel *cellCard = self.deckView.currentCells[i];
            if ([cardModel compare:cellCard] == NSOrderedAscending)
            {
                insertionIndex = i;
                break;
            }
        }
        
        //not found index, insert at end
        if (insertionIndex == -1)
            insertionIndex = self.deckView.currentCells.count;
        
        [self.deckView.currentCells insertObject:cardModel atIndex:insertionIndex];
        [ownedCards removeObjectAtIndex:randomIndex];
    }
    
    autoAddView.alpha = 1;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         autoAddView.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [autoAddView removeFromSuperview];
                     }];
    [self undarkenScreen];
    
    [self saveDeck];
}

-(void)notAutoAddCardsButtonPressed
{
    autoAddView.alpha = 1;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         autoAddView.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [autoAddView removeFromSuperview];
                     }];
    
    [self saveDeck];
    
    [self undarkenScreen];
}

-(void)notFixDeckButtonPressed
{
    autoAddView.alpha = 1;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         autoAddView.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [autoAddView removeFromSuperview];
                     }];
    
    //save the deck so they can finish it later
    [self saveDeck];
    
    [self undarkenScreen];
}

-(void)cancelNotFixButtonPressed
{
    //removes the view and makes no changes
    
    autoAddView.alpha = 1;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         autoAddView.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [autoAddView removeFromSuperview];
                     }];
    
    [self undarkenScreen];
}


/** Resets all views to when it's first opened */
-(void)resetAllViews
{
    self.isForgeCardsMode = NO;
    
    [self.deleteDeckButton removeFromSuperview];
    
    [self.cardsView removeAllCells];
    [self.deckView removeAllCells];
    currentDeck = nil;
    
    self.MyForgedCardsButton.alpha = 1;
    self.makeCardsExplanationLabel.alpha = 1;
    self.myAnvilImg.alpha = 1;
    
    _searchResult.text = @"Select Or Create A Deck To View Your Cards.";
    _searchResult.frame = CGRectMake(10*DeckWRatio, self.cardsView.frame.size.height/2 + 20*DeckHRatio, self.cardsView.frame.size.width - 20*DeckWRatio, self.cardsView.frame.size.height);
    [_searchResult sizeToFit];
    
    [saveDeckButton removeFromSuperview];
    [_filterToggleButton removeFromSuperview];
    [_deckLimitationsButton removeFromSuperview];
    
    if ([self isFilterOpen])
        [self setFilterViewState:NO];
    
    for (UIView*view in _propertiesView.subviews)
        view.alpha = 0;
    
    if (userAllDecks.count >= [userPF[@"maxDecks"] intValue])
        [addDeckButton setEnabled:NO];
    else
        [addDeckButton setEnabled:YES];
    
    [self.view insertSubview:addDeckButton aboveSubview:_footerView];
    [_footerView addSubview:backButton];
    
    //add user decks
    self.deckView.viewMode = deckTableViewDecks;
    for (DeckModel*deck in userAllDecks)
    {
        [DeckModel validateDeck:deck];
        [self.deckView.currentCells addObject:deck];
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.deckView.currentCells.count-1 inSection:0];
        [self.deckView.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        
                //scroll to the newly inserted position
        /*
         [self.deckView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.deckView.currentCells.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
         */
    }
    
    [invalidDeckButton removeFromSuperview];
    [self.deckView.tableView reloadInputViews];
    [self.deckView.tableView reloadData];
    
    [self updateDeckCounterLabel];
    
    //add ForgeCardsButton to visible/invisible
    [self.view addSubview:self.MyForgedCardsButton];
    self.ForgeNewCardButton.alpha = 0;
    [self.view addSubview:self.ForgeNewCardButton];
    
}

/** Sets up the views for Creating and Viewing Forged Cards*/
//Displays all forged cards in horizontal collection view
//Displays Back Button
//Displays Upgrade Button & Gold Cost of Upgarde When User Clicks on Card
//Displays Total Gold Earned by Purchases of Card
//Displays Large Button for Creating New Forged Card--Gold Cost Shows on Next Screen



-(void)setupForgeCardsView
{
    //reduce properties view frame
      //_propertiesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-_deckView.frame.size.width-60, _cardsView.frame.origin.y)];
    self.propertyBackground.frame = CGRectMake(0, 0, SCREEN_WIDTH*0.6*DeckWRatio, _cardsView.frame.origin.y);
    
    
    self.UserCoinBalanceView.alpha = 1;
    
    
    _deckCreateExplanationLabel.alpha = 0;
    _deckCreateExplanationLabel2.alpha = 0;
    //_makeCardsExplanationLabel.alpha = 0;
    _myAnvilImg.alpha = 0;
    self.MyForgedCardsButton.alpha = 0;
    _createCostLabel.alpha = 1;
    _makeCardsExplanationLabel.text = @"Create a New Card For 500 Coins";
    _makeCardsExplanationLabel.frame = CGRectMake(5*DeckWRatio, 12*DeckHRatio, 170*DeckWRatio, 60*DeckHRatio);
    //view cleanup code for this mode
    [addDeckButton removeFromSuperview];
    _searchResult.text = @"";
    [self.MyForgedCardsButton removeFromSuperview];
    
    //set Forge Cards Mode so cardview shows only forged cards
    _isForgeCardsMode = YES;
    
    _hasMadeChange = NO; //initialize
    
    //[backButton removeFromSuperview];
    
    for (UIView*view in _propertiesView.subviews)
        view.alpha = 0;
    
    //brian return point.
    //need to expand the horizontal collection view for forged cards
    //need to work on UI to add a new background that deals with blank deckView object
    //need to work on UI to show distinct sections of "My Forged Cards" and Forge New Card
    //need to show coin balance at top right
    //remove starter labels on forged cards view
    
    self.deckView.alpha = 0;
    self.ForgeNewCardButton.alpha = 1;
    
    //set coin balance views as visible
    
    //original dimensions of self.cardsView(0, SCREEN_HEIGHT-366-42, SCREEN_WIDTH-88, 366) collectionViewLayout:layout];
    CGRect cardViewFrame = self.cardsView.frame;
    cardViewFrame.size.width = SCREEN_WIDTH;
    [self.cardsView setFrame:cardViewFrame];
    
    CGRect collectViewFrame = CGRectMake(0,0,cardViewFrame.size.width,cardViewFrame.size.height);
    
    [self.cardsView.collectionView setFrame:collectViewFrame];
    
    
    
    
    [self.deckView removeAllCells];
    
    self.deckView.viewMode = deckTableViewCards;
    
    [_footerView addSubview:_filterToggleButton];
    
    [self reloadCardsWithFilter];
    
    //[self updateCardsCounterLabel];
    
    self.cardsView.isScrolling = NO;
    
    [self.view addSubview:_createCostLabel];
    
    //[self.cardsView.collectionView reloadData];
    //[self.cardsView.collectionView reloadInputViews];
}

/** Setups the views for deck editing. If currentDeck is nil, assuming it's a new deck */
-(void)setupDeckEditView
{
    self.isForgeCardsMode = NO;
    
    _deckCreateExplanationLabel.alpha = 0;
    _deckCreateExplanationLabel2.alpha = 0;
    _makeCardsExplanationLabel.alpha = 0;
    _myAnvilImg.alpha = 0;
    self.MyForgedCardsButton.alpha = 0;
    
    _hasMadeChange = NO; //initialize
    
    [backButton removeFromSuperview];
    
    [self.deckView.currentCells removeAllObjects];
    
    //[self.deckView removeAllCells];
    
    self.deckView.viewMode = deckTableViewCards;
    
    //get all cards in the existing deck
    if (currentDeck!=nil)
    {
        for (CardModel*card in currentDeck.cards)
            [self.deckView.currentCells addObject:[[CardModel alloc] initWithCardModel:card]];
        
        if (currentDeck.isInvalid)
            [_footerView addSubview:invalidDeckButton];
        
        [self.view addSubview:_deckLimitationsButton];
        
        _nameField.text = currentDeck.name;
        NSString*tagsString = @"";
        for (NSString *tag in currentDeck.tags)
        {
            tagsString = [NSString stringWithFormat:@"%@%@ ", tagsString, [tag lowercaseString]];
        }
        _tagsArea.text = tagsString;
    }
    else{
        _nameField.text = @"";
        _tagsArea.text = @"";
        
        [self.view addSubview:_deckLimitationsButton];
    }
    
    [_footerView addSubview:self.deleteDeckButton];
    
    [_footerView addSubview:_filterToggleButton];
    for (UIView*view in _propertiesView.subviews)
        view.alpha = 1;
    
    
    [self reloadCardsWithFilter];
    
    [self.deckView.tableView reloadInputViews];
    [self.deckView.tableView reloadData];
    
    [self updateCardsCounterLabel];
    
    [addDeckButton removeFromSuperview];
    _searchResult.text = @"";
    
    [self.view addSubview:saveDeckButton];
    
    if (_isTutorial)
        [self tutorialLimits];
    
    self.cardsView.isScrolling = NO;
    
    
    //[self.cardsView.collectionView reloadData];
    //[self.cardsView.collectionView reloadInputViews];
}

-(void)tutorialLimits
{
    [self modalScreen];
    //self.tutOkButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    //self.tutOkButton.label.text = @"Ok";
    [self.view addSubview:self.tutLabel];
    [self.view addSubview:self.tutOkButton];
    
    self.tutLabel.label.text = @"There are some restrictions in building a deck in CardForge: you cannot have cards of opposite elements, and there is a limit to how many cards with a particular ability you can have.";
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(tutorialLimitsButton) forControlEvents:UIControlEventTouchUpInside];
    [self.tutLabel.label setTextAlignment:NSTextAlignmentCenter];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.tutOkButton.alpha = 1;
                         self.tutLabel.alpha = 1;
                     }
                     completion:^(BOOL completed){
                     }];
}

-(void)tutorialLimitsButton
{
    self.tutLabel.label.text = @"You should always tap the Limits button to review them before purchasing new cards.";
    
    //TODO arrow
    
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(removeAllTutorialViews) forControlEvents:UIControlEventTouchUpInside];
    
    _isTutorial = NO; //tutorial's over
    userPF[@"deckTutorialDone"] = @(YES);
    [userPF saveInBackground]; //not important if failed
}

-(void)addDeckButtonPressed
{
    //TODO if reached limit, ask user to visit store to buy more space
    
    currentDeck = nil;
    [self setupDeckEditView];
}
-(void)ForgedButtonPressed
{
    //do stuff for forged cards
    currentDeck = nil;
    [self setupForgeCardsView];
}

-(void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)deleteButtonPressed
{
    [self darkenScreen];
    
    [self.deleteDeckConfirmButton setEnabled:NO];
    [self.deleteDeckCancelButton setEnabled:NO];
    
    self.deleteDeckConfirmButton.alpha = 0;
    self.deleteDeckCancelButton.alpha = 0;
    deleteDeckLabel.alpha = 0;
    
    [self.view addSubview:self.deleteDeckConfirmButton];
    [self.view addSubview:self.deleteDeckCancelButton];
    [self.view addSubview:deleteDeckLabel];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.deleteDeckConfirmButton.alpha = 1;
                         self.deleteDeckCancelButton.alpha = 1;
                         deleteDeckLabel.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         [self.deleteDeckConfirmButton setEnabled:YES];
                         [self.deleteDeckCancelButton setEnabled:YES];
                     }];
}

-(void)deleteDeckConfirmButtonPressed
{
    //delete the deck only if it actually exists
    if (currentDeck != nil)
    {
        [self showActivityIndicatorWithBlock:^BOOL{
            BOOL succ = [UserModel deleteDeck:currentDeck];
            if (succ)
            {
                NSLog(@"success deleting");
                [self deleteDeckCancelButtonPressed]; //just to get rid of the dialogs
                [self resetAllViews];
                return YES;
            }
            else
            {
                NSLog(@"faild deleting");
                return NO;
            }
        } loadingText:@"Deleting..." failedText:@"Failed to delete deck."];
    }
    else
    {
        NSLog(@"here");
        [self deleteDeckCancelButtonPressed]; //just to get rid of the dialogs
        [self resetAllViews];
    }
}

-(void)deleteDeckCancelButtonPressed
{
    self.deleteDeckConfirmButton.alpha = 1;
    self.deleteDeckCancelButton.alpha = 1;
    deleteDeckLabel.alpha = 1;
    
    [self.deleteDeckConfirmButton setEnabled:NO];
    [self.deleteDeckCancelButton setEnabled:NO];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.deleteDeckConfirmButton.alpha = 0;
                         self.deleteDeckCancelButton.alpha = 0;
                         deleteDeckLabel.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [self.deleteDeckConfirmButton removeFromSuperview];
                         [self.deleteDeckCancelButton removeFromSuperview];
                         [deleteDeckLabel removeFromSuperview];
                     }];
    
    [self undarkenScreen];
}

-(void)invalidDeckButtonPressed
{
    DeckModel*deck = [[DeckModel alloc] init];
    for (CardModel* card in self.deckView.currentCells)
        [deck addCard:card];
    [DeckModel validateDeck:deck];
    
    NSString *invalidDeckReasons = @"Problems with the deck:\n";
    
    for (NSString *reason in deck.invalidReasons)
        invalidDeckReasons = [NSString stringWithFormat:@"%@- %@\n", invalidDeckReasons, reason];
    
    
    //_invalidDeckReasonsLabel.frame = CGRectMake(SCREEN_WIDTH*1/10, SCREEN_HEIGHT/8, SCREEN_WIDTH*8/10, SCREEN_HEIGHT);
    _invalidDeckReasonsLabel.text = invalidDeckReasons;
    
    //[_invalidDeckReasonsLabel sizeToFit];
    
    [self darkenScreen];
    
    [self.view addSubview:_invalidDeckReasonsLabel];
    [self.view addSubview:_invalidDeckReasonsOkButton];
    
    _invalidDeckReasonsLabel.alpha = 0;
    _invalidDeckReasonsOkButton.alpha = 0;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _invalidDeckReasonsLabel.alpha = 1;
                         _invalidDeckReasonsOkButton.alpha = 1;
                     }
                     completion:^(BOOL completed){
                     }];
}

-(void)deckLimitationsButtonPressed
{
    DeckModel*deck = [[DeckModel alloc] init];
    for (CardModel* card in self.deckView.currentCells)
        [deck addCard:card];
    NSArray*limits = [DeckModel getLimits:deck];
    
    NSString *invalidDeckReasons = @"Limits in the deck:\n";
    
    for (NSString *reason in limits)
        invalidDeckReasons = [NSString stringWithFormat:@"%@- %@\n", invalidDeckReasons, reason];
    
    //_invalidDeckReasonsLabel.frame = CGRectMake(SCREEN_WIDTH*1/10, SCREEN_HEIGHT/8, SCREEN_WIDTH*8/10, SCREEN_HEIGHT);
    _invalidDeckReasonsLabel.text = invalidDeckReasons;
    
    //[_invalidDeckReasonsLabel sizeToFit];
    
    [self darkenScreen];
    
    [self.view addSubview:_invalidDeckReasonsLabel];
    [self.view addSubview:_invalidDeckReasonsOkButton];
    
    _invalidDeckReasonsLabel.alpha = 0;
    _invalidDeckReasonsOkButton.alpha = 0;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _invalidDeckReasonsLabel.alpha = 1;
                         _invalidDeckReasonsOkButton.alpha = 1;
                     }
                     completion:^(BOOL completed){
                     }];
}

-(void)invalidDeckReasonsOkButtonPressed
{
    [self undarkenScreen];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _invalidDeckReasonsLabel.alpha = 0;
                         _invalidDeckReasonsOkButton.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [_invalidDeckReasonsLabel removeFromSuperview];
                         [_invalidDeckReasonsOkButton removeFromSuperview];
                     }];
}

-(void)filterToggleButtonPressed
{
    [self setFilterViewState:![self isFilterOpen]];
}

-(BOOL)isFilterOpen
{
    return [_filterToggleButton isSelected];
}

-(void)setFilterViewState:(BOOL)state
{
    _filterToggleButton.selected = state;
    
    CGRect filterViewFrame = _filterView.frame;
    if (state)
    {
        //_searchResult.center = CGPointMake(_cardsView.bounds.size.width/2, _cardsView.bounds.size.height/5);
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_filterView setFrame:CGRectMake(filterViewFrame.origin.x, filterViewFrame.origin.y - filterViewFrame.size.height, filterViewFrame.size.width, filterViewFrame.size.height+8)];
                         }
                         completion:^(BOOL completed){
                             
                         }];
    }
    else
    {
        //_searchResult.center = CGPointMake(_cardsView.bounds.size.width/2, _cardsView.bounds.size.height/2);
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_filterView setFrame:CGRectMake(filterViewFrame.origin.x, filterViewFrame.origin.y + filterViewFrame.size.height, filterViewFrame.size.width, filterViewFrame.size.height)];
                         }
                         completion:^(BOOL completed){
                             
                         }];
    }
}

-(void)reloadCardsWithFilter
{
    [self.cardsView.currentCardModels removeAllObjects];
    
    //[self.deckView.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];


    //testaddoct18
    //[self.deckView.tableView reloadData];
    
    
    //get the CardView of every card in the deck
    for (CardModel *card in allCards.cards)
    {
        if (card.cost >= 0 && card.cost < _costFilter.count)
        {
            if ([_costFilter[card.cost] boolValue] == NO)
                continue;
        }
        
        if ((int)card.element >= 0 && (int)card.element < _elementFilter.count)
        {
            if ([_elementFilter[card.element] boolValue] == NO)
                continue;
        }
        
        if ((int)card.rarity >= 0 && (int)card.rarity < _rarityFilter.count)
        {
            if ([_rarityFilter[card.rarity] boolValue] == NO)
                continue;
        }
        
        //add a filter here when in forge mode, only add cards which are part of the set that are created by the user
        if (self.isForgeCardsMode == YES)
        {
            //check if card is forged, if not dont add
            PFUser *myUser = [PFUser currentUser];
            NSString *myUserID = myUser.objectId;
            NSString *cardCreator = card.creator;
        
            if(![cardCreator isEqualToString:myUserID])
                continue;
        }
        
        [self updateCard:card];
        [self.cardsView.currentCardModels addObject:card];
    }

    [self.cardsView.collectionView performBatchUpdates:^{
        [self.cardsView.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished){
        [self updateCardsViewCards];
    }];
    
    CGPoint searchResultCenter = _searchResult.center;
    if (self.cardsView.currentCardModels.count == 0)
    {
        _searchResult.text = @"No cards found. Please double check your filter settings.";
    }
    else
    {
        _searchResult.text = @"";
    }
    _searchResult.frame = CGRectMake(10*DeckWRatio, self.cardsView.frame.size.height/2 + 20*DeckHRatio, self.cardsView.frame.size.width - 20*DeckWRatio, self.cardsView.frame.size.height);
    [_searchResult sizeToFit];
    //_searchResult.center = searchResultCenter;
}

-(void)costFilterButtonPressed:(id)sender
{
    UIButton*senderButton = sender;
    
    int i = 0;
    for (UIButton*button in _costFilterButtons)
    {
        if (senderButton == button)
        {
            _costFilter[i] = @(!([_costFilter[i] boolValue]));
            button.alpha = [_costFilter[i] boolValue] ? 1 : 0.4;
            break;
        }
        i++;
    }
    
    [self reloadCardsWithFilter];
    
}

-(void)rarityFilterButtonPressed:(id)sender
{
    UIButton*senderButton = sender;
    
    int i = 0;
    for (UIButton*button in _rarityFilterButtons)
    {
        if (senderButton == button)
        {
            _rarityFilter[i] = @(!([_rarityFilter[i] boolValue]));
            button.alpha = [_rarityFilter[i] boolValue] ? 1 : 0.4;
            break;
        }
        i++;
    }
    
    [self reloadCardsWithFilter];
}

-(void)elementFilterButtonPressed:(id)sender
{
    UIButton*senderButton = sender;
    
    int i = 0;
    for (UIButton*button in _elementFilterButtons)
    {
        if (senderButton == button)
        {
            _elementFilter[i] = @(!([_elementFilter[i] boolValue]));
            button.alpha = [_elementFilter[i] boolValue] ? 1 : 0.4;
            break;
        }
        i++;
    }
    
    [self reloadCardsWithFilter];
}

-(void)sellCardButtonPressed
{
    //TODO more work needed later (confirmation dialog, show gold etc)
    
    [self showActivityIndicatorWithBlock:^BOOL{

      int cost = [GameStore getCardSellPrice:currentCard.cardModel];
      
      NSError*error;
      [PFCloud callFunction:@"sellCard"
             withParameters:@{@"cardNumber" : @(currentCard.cardModel.idNumber),
                              @"cost" : @(cost)}
                      error:&error];
      
      if (!error)
      {
          userGold += cost;
          [UserModel removeOwnedCard:currentCard.cardModel.idNumber];
 
          [userPF fetch]; //can have error but it's not important
          
          [self.cardsView.currentCardModels removeObject:currentCard.cardModel];
          [self.cardsView reloadInputViews];
          [self.cardsView.collectionView reloadData];
          
          [currentCard removeFromSuperview];
          currentCard = nil;
          [self unmaximizeCard:cardCollectionAddCard];
          
          
          return YES;
      }
      else
      {
          NSLog(@"%@", [error localizedDescription]);
          return NO;
      }

        
    } loadingText:@"Processing..." failedText:@"Error selling card."];
}


-(void)showActivityIndicatorWithBlock:(BOOL (^)())block loadingText:(NSString*)loadingText failedText:(NSString*)failedText
{
    _activityIndicator.alpha = 0;
    _activityLabel.text = loadingText;
    [_activityIndicator setColor:[UIColor whiteColor]];
    [self.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _activityIndicator.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         BOOL succ = block();
                         
                         if (succ)
                         {
                             [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  _activityIndicator.alpha = 0;
                                              }
                                              completion:^(BOOL completed){
                                                  [_activityIndicator stopAnimating];
                                                  [_activityIndicator removeFromSuperview];
                                              }];
                         }
                         else
                         {
                             [_activityIndicator setColor:[UIColor clearColor]];
                             _activityLabel.text = failedText;
                             _activityFailedButton.alpha = 0;
                             [_activityIndicator addSubview:_activityFailedButton];
                             [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  _activityFailedButton.alpha = 1;
                                              }
                                              completion:^(BOOL completed){
                                                  [_activityFailedButton setUserInteractionEnabled:YES];
                                              }];
                         }
                     }];
}

-(void)activityFailedButtonPressed
{
    [_activityFailedButton setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _activityIndicator.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [_activityFailedButton removeFromSuperview];
                     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}


-(void)tapRegistered
{
    [_nameField resignFirstResponder];
    [_tagsArea resignFirstResponder];
}

-(void)modalScreen
{
    _modalFilter.alpha = 3.f/255; //because apparently 0 alpha = cannot be interacted...
    [self.view addSubview:_modalFilter];
    _isModal = YES;
}

-(void)removeAllTutorialViews
{
    [self unmodalScreen];
    
    [self.tutOkButton removeFromSuperview];
    [self.tutLabel removeFromSuperview];
}

-(void)unmodalScreen
{
    _isModal = NO;
    [_modalFilter removeFromSuperview];
}

-(void)setTutLabelCenter:(CGPoint) center
{
    self.tutLabel.center = center;
    self.tutOkButton.center = CGPointMake(center.x, center.y + self.tutLabel.bounds.size.height/2 - 40);
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

- (BOOL)prefersStatusBarHidden {return YES;}

@end
