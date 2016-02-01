//
//  StoreViewController.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-02.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "StoreViewController.h"
#import "StoreViewController+Animation.h"
#import "UIConstants.h"
#import "UserModel.h"
#import "SinglePlayerCards.h"
#import "GameStore.h"
#import "PickIAPHelper.h"
#import "StorePackCell.h"
#import <QuartzCore/QuartzCore.h>

@interface StoreViewController ()


@end

@implementation StoreViewController
    


@synthesize cardsView = _cardsView;

/** Screen dimension for convinience */
float SCREEN_WIDTH, SCREEN_HEIGHT;


int STORE_INITIAL_LOAD_AMOUNT = 96;
int STORE_ADDITIONAL_INCREMENT = 16;

CGSize keyboardSize;



NSArray *_products;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //cost 0 to 10
        _costFilter = [NSMutableArray arrayWithArray: @[@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES)]];
        
        //7 elements
        _elementFilter = [NSMutableArray arrayWithArray: @[@(YES),@(YES),@(YES),@(YES),@(YES),@(YES),@(YES)]];
        
        //5 rarities
        _rarityFilter = [NSMutableArray arrayWithArray: @[@(YES),@(YES),@(YES),@(YES),@(YES)]];
        
        _ownedFilter = NO;
        _likedFilter = NO;
        _stockedFilter = NO;
        _deckTagsFilter = NO;
        
        _storeCategoryTab = storeCategoryNewest;
        cardStoreQueryID = 0;
    }
    return self;
}



-(void)viewDidLoad{
    [super viewDidLoad];
    
    if ([userPF[@"storeTutorialDone"] boolValue] == NO)
        _isTutorial = YES;
    
    SCREEN_WIDTH = [[UIScreen mainScreen] bounds].size.width;
    SCREEN_HEIGHT = [[UIScreen mainScreen] bounds].size.height;
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT)];
    backgroundImageView.image = [UIImage imageNamed:@"WoodBG.jpg"];
    [self.view addSubview:backgroundImageView];
    
    
    _headerView = [[UIView alloc]initWithFrame:CGRectMake(0,0,SCREEN_WIDTH, 120)];
    //_headerView.backgroundColor = [UIColor redColor];
    float mockupHeight = 1136.0f;
    float mockupWidth = 640.0f;
    
    float bottomBarStartYFooter = 1024/mockupHeight;
    float bottomBarHeightFooter = 120/mockupHeight;
    _footerView = [[UIView alloc]initWithFrame:CGRectMake(0,bottomBarStartYFooter*SCREEN_HEIGHT,SCREEN_WIDTH, bottomBarHeightFooter*SCREEN_HEIGHT)];
    //_footerView.backgroundColor = [UIColor whiteColor];
    
    //change the frame of the cards view
    //July28
    //
    //_cardsView = [[StoreCardsCollectionView alloc] initWithFrame:CGRectMake(0, _headerView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-_headerView.frame.size.height-_footerView.frame.size.height)];
    
    //float storeRightEdgeXRatio = 445/mockupWidth;
    
    
    //brianJul31 Featured Store Section
    _featuredStore = [[UIScrollView alloc] initWithFrame:_cardsView.bounds];
    //_featuredStore.backgroundColor = [UIColor redColor];
    
    //booster pack dimensions
    //319x575
    float boosterPackWRatio = 319/mockupWidth*SCREEN_WIDTH*0.6;
    float boosterPackHRatio = 575/mockupHeight*SCREEN_HEIGHT*0.6;
    UIButton *boosterPack1 = [[UIButton alloc] initWithFrame:CGRectMake(120,0,boosterPackWRatio,boosterPackHRatio)];
    [boosterPack1 setImage:[UIImage imageNamed:@"FeaturedStoreCardPack001.png" ] forState:UIControlStateNormal];
    boosterPack1.tag = 101;
    UIButton *boosterPack2 = [[UIButton alloc] initWithFrame:CGRectMake(10,190,boosterPackWRatio,boosterPackHRatio)];
    [boosterPack2 setImage:[UIImage imageNamed:@"FeaturedStoreCardPack002.png" ] forState:UIControlStateNormal];
    boosterPack2.tag = 102;
    
    UIButton *boosterPack3 = [[UIButton alloc] initWithFrame:CGRectMake(120,190,boosterPackWRatio,boosterPackHRatio)];
    [boosterPack3 setImage:[UIImage imageNamed:@"FeaturedStoreCardPack003.png" ] forState:UIControlStateNormal];
    boosterPack3.tag = 103;
    
    //add functionality
    [boosterPack1 addTarget:self action:@selector(boosterPackPress:) forControlEvents:UIControlEventTouchUpInside];
    [boosterPack2 addTarget:self action:@selector(boosterPackPress:) forControlEvents:UIControlEventTouchUpInside];
    [boosterPack3 addTarget:self action:@selector(boosterPackPress:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [_featuredStore addSubview:boosterPack1];
    [_featuredStore addSubview:boosterPack2];
    [_featuredStore addSubview:boosterPack3];
    [_featuredStore setAlpha:0];
   
    
    
    
    
    [self.view addSubview:_headerView];
    
    //add the storeIcon
    UIImage *storeIconImage = [UIImage imageNamed:@"CardStoreBanner.png"];
    //image -store banner width 470, 168 h, 0x, 28Y
    float storeYStart = 15/mockupHeight*SCREEN_HEIGHT;
    float storeXStart = 0;
    float storeWidth = 470/mockupWidth*SCREEN_WIDTH;
    float storeHeight = 168/mockupHeight*SCREEN_HEIGHT;
    
    UIImageView *storeIconBanner = [[UIImageView alloc] initWithFrame:CGRectMake(storeXStart,storeYStart,storeWidth,storeHeight)];
    storeIconBanner.image = storeIconImage;
    
    UITapGestureRecognizer *storeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPendingImageCardsApproval)];
    [storeTap setNumberOfTapsRequired:1];
    
    [storeIconBanner setUserInteractionEnabled:YES];
    [storeIconBanner addGestureRecognizer:storeTap];
    
    [self.view addSubview:storeIconBanner];
    
    float cardsViewWidthRatio = 454/mockupWidth;
    _cardsView = [[StoreCardsCollectionView alloc] initWithFrame:CGRectMake(0, storeHeight, cardsViewWidthRatio*SCREEN_WIDTH, self.view.bounds.size.height-_footerView.frame.size.height)];
    _cardsView.parentViewController = self;
    _cardsView.backgroundColor = [UIColor clearColor];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_cardsView];
    
    [_featuredStore setFrame:_cardsView.frame];
     [self.view addSubview:_featuredStore];
    
    //------------------footer views------------------//
    
   
    
   // [_footerView addSubview:self.backButton];
    
    //brian July 23 add right edge and background for store
    //x445, width 200
    UIImageView *storeRightEdge = [[UIImageView alloc] init];
   
    float storeRightEdgeXRatio = 445/mockupWidth;
    float storeRightEdgeWidthRatio = 200/mockupWidth;
    
    storeRightEdge.frame = CGRectMake(storeRightEdgeXRatio*SCREEN_WIDTH,0,storeRightEdgeWidthRatio*SCREEN_WIDTH,SCREEN_HEIGHT);
    
    [storeRightEdge setImage:[UIImage imageNamed:@"CardStoreRightRow.png"]];
    
    [self.view addSubview:storeRightEdge];
    
    _userCardIcon = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 38)];
    [_userCardIcon setImage:CARD_ICON_IMAGE forState:UIControlStateNormal];
    _userCardIcon.center = CGPointMake(SCREEN_WIDTH-25 ,24);
    [_footerView addSubview:_userCardIcon];
    UIImage *plusIconImage = [UIImage imageNamed:@"CardStorePlusButton.png"];
    
    UIImageView* userCardAddIcon = [[UIImageView alloc] initWithImage:plusIconImage];
    
    //float plusButton1–62W,58H,484X,592Y
    
    userCardAddIcon.frame = CGRectMake(0, 0, 20, 20);
    
    [_userCardIcon addTarget:self action:@selector(openBlankCardView)    forControlEvents:UIControlEventTouchUpInside];
    [_userCardIcon addSubview:userCardAddIcon];
    
    /*
    _userCardLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 155, 40)];
    _userCardLabel.textAlignment = NSTextAlignmentCenter;
    _userCardLabel.textColor = [UIColor whiteColor];
    _userCardLabel.font = [UIFont fontWithName:cardMainFont size:20];
    _userCardLabel.strokeOn = YES;
    _userCardLabel.strokeThickness = 3;
    _userCardLabel.strokeColour = [UIColor blackColor];
    _userCardLabel.center = CGPointMake(SCREEN_WIDTH-25, 28);
    [_footerView addSubview:_userCardLabel];
    */
    
    //brian july 23
    //modify user gold icon to show as new style
    //-goldbagButton-502X,846Y,135,155
    float goldButtonXRatio = 498/mockupWidth;
    float goldButtonYRatio = 846/mockupHeight;
    float goldButtonWRatio = 135/mockupWidth;
    float goldButtonHRatio = 155/mockupHeight;
    
    _userGoldIcon = [[UIButton alloc] initWithFrame:CGRectMake(goldButtonXRatio*SCREEN_WIDTH, goldButtonYRatio*SCREEN_HEIGHT, goldButtonWRatio*SCREEN_WIDTH, goldButtonHRatio*SCREEN_HEIGHT)];
    UIImage *coinBagImg = [UIImage imageNamed:@"CardStoreCoins.png"];
    
    [_userGoldIcon setImage:coinBagImg forState:UIControlStateNormal];
    [_userGoldIcon addTarget:self action:@selector(openBuyGoldView)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_userGoldIcon];
    
    UIImageView* userGoldAddIcon = [[UIImageView alloc] initWithImage:ADD_ICON_IMAGE];
    userGoldAddIcon.frame = CGRectMake(0, 0, 20, 20);
    userGoldAddIcon.center = CGPointMake(_userGoldIcon.bounds.size.width,5);
    //[_userGoldIcon addSubview:userGoldAddIcon];
    
    //plusButton3-62W,58H,484X,926Y
    UIImageView *plusButton3 = [[UIImageView alloc] initWithImage:plusIconImage];
    float plusButton3XRatio = 484/mockupWidth;
    float plusButton3YRatio = 926/mockupHeight;
    float plusButton3WRatio = 62/mockupWidth;
    float plusButton3HRatio = 58/mockupHeight;
    
    plusButton3.frame = CGRectMake(plusButton3XRatio*SCREEN_WIDTH,plusButton3YRatio*SCREEN_HEIGHT,plusButton3WRatio*SCREEN_WIDTH,plusButton3HRatio*SCREEN_HEIGHT);
    [self.view addSubview:plusButton3];
    
    //label3–986Y
    _userGoldLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(_userGoldIcon.frame.origin.x, 986/mockupHeight*SCREEN_HEIGHT, _userGoldIcon.frame.size.width, 40)];
    _userGoldLabel.textAlignment = NSTextAlignmentCenter;
    _userGoldLabel.textColor = [UIColor whiteColor];
    _userGoldLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE +5];
    _userGoldLabel.strokeOn = YES;
    _userGoldLabel.strokeThickness = 3;
    _userGoldLabel.strokeColour = [UIColor blackColor];
    [self.view addSubview:_userGoldLabel];
    
    //brian Jul23
    //edit user likes icon to go on right side with new UI style
    //-likeButton 480X,686Y,145W,138H
    UIImage *likeButtonImage = [UIImage imageNamed:@"CardStoreLikeButton.png"];
    
    float likeButtonXRatio = 480/mockupWidth;
    float likeButtonYRatio = 686/mockupHeight;
    float likeButtonWRatio = 145/mockupWidth;
    float likeButtonHRatio = 138/mockupHeight;
    
    _userLikesIcon = [[UIImageView alloc] initWithImage:likeButtonImage];
    _userLikesIcon.frame = CGRectMake(likeButtonXRatio*SCREEN_WIDTH, likeButtonYRatio*SCREEN_HEIGHT, likeButtonWRatio*SCREEN_WIDTH, likeButtonHRatio*SCREEN_HEIGHT);
   
    [self.view addSubview:_userLikesIcon];
    
    //plusButton2-62W,58H,484X,758Y
    float plusButton2XRatio = 484/mockupWidth;
    float plusButton2YRatio = 758/mockupHeight;
    float plusButton2WRatio = 62/mockupWidth;
    float plusButton2HRatio = 58/mockupHeight;
    
    UIImageView *plusButton2 = [[UIImageView alloc] initWithImage:plusIconImage];
    plusButton2.frame = CGRectMake(plusButton2XRatio*SCREEN_WIDTH,plusButton2YRatio*SCREEN_HEIGHT,plusButton2WRatio*SCREEN_WIDTH,plusButton2HRatio*SCREEN_HEIGHT);
    
    [self.view addSubview:plusButton2];
    
    //brian jul23
    //label2–820Y,
    float likeLabelYRatio = 820/mockupHeight;
    
    _userLikesLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(_userLikesIcon.frame.origin.x,likeLabelYRatio*SCREEN_HEIGHT,_userLikesIcon.frame.size.width, 40)];
    _userLikesLabel.textAlignment = NSTextAlignmentCenter;
    _userLikesLabel.textColor = [UIColor whiteColor];
    _userLikesLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE +5];
    _userLikesLabel.strokeOn = YES;
    _userLikesLabel.strokeThickness = 3;
    _userLikesLabel.strokeColour = [UIColor blackColor];
    [self.view addSubview:_userLikesLabel];
    
    //-----------------Card info views----------------//
    _cardInfoView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    _darkFilter = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH, SCREEN_HEIGHT-40)];
    _darkFilter.backgroundColor = [[UIColor alloc]initWithHue:0 saturation:0 brightness:0 alpha:0.8];
    [_darkFilter setUserInteractionEnabled:YES]; //blocks all interaction behind it
    [_cardInfoView addSubview:_darkFilter];
    
    _buyButton = [[CFButton alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT -(CARD_DETAIL_BUTTON_HEIGHT*2),CARD_DETAIL_BUTTON_WIDTH , CARD_DETAIL_BUTTON_HEIGHT)];
    _buyButton.label.text = @"Buy";
    [_buyButton setTextSize:CARD_NAME_SIZE +7];
    [_buyButton addTarget:self action:@selector(buyButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_cardInfoView addSubview:_buyButton];
    
    
    _sellButton = [[CFButton alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT -(CARD_DETAIL_BUTTON_HEIGHT*2), CARD_DETAIL_BUTTON_WIDTH, CARD_DETAIL_BUTTON_HEIGHT)];
    _sellButton.label.text = @"Sell";
    [_sellButton setTextSize:CARD_NAME_SIZE +7];
    [_sellButton addTarget:self action:@selector(sellButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_cardInfoView addSubview:_sellButton];
    
    _approveButton = [[CFButton alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT -(CARD_DETAIL_BUTTON_HEIGHT*2), CARD_DETAIL_BUTTON_WIDTH, CARD_DETAIL_BUTTON_HEIGHT)];
    _approveButton.label.text = @"Approve";
    [_approveButton setTextSize:CARD_NAME_SIZE +1];
    [_approveButton addTarget:self action:@selector(approveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    //[_cardInfoView addSubview:_approveButton];
    
    _declineButton = [[CFButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 0.5 - (CARD_DETAIL_BUTTON_WIDTH/2), SCREEN_HEIGHT -(CARD_DETAIL_BUTTON_HEIGHT*2), CARD_DETAIL_BUTTON_WIDTH, CARD_DETAIL_BUTTON_HEIGHT)];
    _declineButton.label.text = @"Decline";
    [_declineButton setTextSize:CARD_NAME_SIZE +1];
    [_declineButton addTarget:self action:@selector(declineButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    //[_cardInfoView addSubview:_declineButton];
    
    _buyHintLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    _buyHintLabel.textColor = [UIColor whiteColor];
    _buyHintLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE -1];
    _buyHintLabel.textAlignment = NSTextAlignmentCenter;
    _buyHintLabel.strokeOn = YES;
    _buyHintLabel.strokeThickness = 2;
    _buyHintLabel.strokeColour = [UIColor blackColor];
    _buyHintLabel.center = CGPointMake(60, SCREEN_HEIGHT-55);
    [_cardInfoView addSubview:_buyHintLabel];
    
    _editButton = [[CFButton alloc] initWithFrame:CGRectMake(120, SCREEN_HEIGHT -(CARD_DETAIL_BUTTON_HEIGHT*2), CARD_DETAIL_BUTTON_WIDTH, CARD_DETAIL_BUTTON_HEIGHT)];
    _editButton.label.text = @"Edit";
    [_editButton setTextSize:CARD_NAME_SIZE +7];
    [_editButton addTarget:self action:@selector(editButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    //[_cardInfoView addSubview:_editButton];
    
    _restockButton = [[CFButton alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT -(CARD_DETAIL_BUTTON_HEIGHT*2), CARD_DETAIL_BUTTON_WIDTH, CARD_DETAIL_BUTTON_HEIGHT)];
    _restockButton.label.text = @"Restock";
    [_restockButton setTextSize:CARD_NAME_SIZE +3];
    [_restockButton addTarget:self action:@selector(restockButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    //[_cardInfoView addSubview:_buyButton];
    
    _bumpButton = [[CFButton alloc] initWithFrame:CGRectMake(120, SCREEN_HEIGHT -(CARD_DETAIL_BUTTON_HEIGHT*2), 100, 60)];
    _bumpButton.label.text = @"Upgrade";
    [_bumpButton setTextSize:CARD_NAME_SIZE +7];
    [_bumpButton addTarget:self action:@selector(bumpButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    //[_cardInfoView addSubview:_sellButton];
    
    _editHintLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    _editHintLabel.textColor = [UIColor whiteColor];
    _editHintLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE -1];
    _editHintLabel.textAlignment = NSTextAlignmentCenter;
    _editHintLabel.strokeOn = YES;
    _editHintLabel.strokeThickness = 2;
    _editHintLabel.strokeColour = [UIColor blackColor];
    _editHintLabel.center = CGPointMake(160, SCREEN_HEIGHT-55);
    [_cardInfoView addSubview:_editHintLabel];
    
    _likeButton = [[CFButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-20- CARD_DETAIL_BUTTON_WIDTH , SCREEN_HEIGHT -(CARD_DETAIL_BUTTON_HEIGHT*2) , CARD_DETAIL_BUTTON_WIDTH, CARD_DETAIL_BUTTON_HEIGHT)];
    _likeButton.label.text = @"Like";
    [_likeButton setTextSize:CARD_NAME_SIZE +7];
    [_likeButton addTarget:self action:@selector(likeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_cardInfoView addSubview:_likeButton];
    
    _likeHintLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    _likeHintLabel.textColor = [UIColor whiteColor];
    _likeHintLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE-1];
    _likeHintLabel.textAlignment = NSTextAlignmentCenter;
    _likeHintLabel.strokeOn = YES;
    _likeHintLabel.strokeThickness = 2;
    _likeHintLabel.strokeColour = [UIColor blackColor];
    _likeHintLabel.center = CGPointMake(SCREEN_WIDTH-60, SCREEN_HEIGHT-55);
    [_cardInfoView addSubview:_likeHintLabel];
    
    _goldIcon = [[UIImageView alloc] initWithImage:GOLD_ICON_IMAGE];
    _goldIcon.frame = CGRectMake(0, 0, CARD_LIKE_ICON_WIDTH *2, CARD_LIKE_ICON_WIDTH *2);
    _goldIcon.center = CGPointMake(110 ,SCREEN_HEIGHT-168);
    [_cardInfoView addSubview:_goldIcon];
    
    _goldLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    _goldLabel.textAlignment = NSTextAlignmentCenter;
    _goldLabel.textColor = [UIColor whiteColor];
    _goldLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE*2];
    [_goldLabel setMinimumScaleFactor:10/30];
    _goldLabel.adjustsFontSizeToFitWidth = YES;
    _goldLabel.strokeOn = YES;
    _goldLabel.strokeThickness = 5;
    _goldLabel.strokeColour = [UIColor blackColor];
    _goldLabel.center = CGPointMake(110, SCREEN_HEIGHT-148);
    [_cardInfoView addSubview:_goldLabel];
    
    _likesIcon = [[UIImageView alloc] initWithImage:LIKE_ICON_IMAGE];
    _likesIcon.frame = CGRectMake(0, 0, CARD_LIKE_ICON_WIDTH *2, CARD_LIKE_ICON_WIDTH *2);
    _likesIcon.center = CGPointMake(50 ,SCREEN_HEIGHT-168);
    [_cardInfoView addSubview:_likesIcon];
    
    _likesLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0, 60, 60)];
    _likesLabel.textAlignment = NSTextAlignmentCenter;
    _likesLabel.textColor = [UIColor whiteColor];
    _likesLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE*2];
    [_likesLabel setMinimumScaleFactor:10/30];
    _likesLabel.adjustsFontSizeToFitWidth = YES;
    _likesLabel.strokeOn = YES;
    _likesLabel.strokeThickness = 5;
    _likesLabel.strokeColour = [UIColor blackColor];
    _likesLabel.center = CGPointMake(50, SCREEN_HEIGHT-148);
    [_cardInfoView addSubview:_likesLabel];
    
    _rarityLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(145, SCREEN_HEIGHT-200, 100, 40)];
    _rarityLabel.textAlignment = NSTextAlignmentLeft;
    _rarityLabel.textColor = [UIColor whiteColor];
    _rarityLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE +3];
    _rarityLabel.strokeOn = YES;
    _rarityLabel.strokeThickness = 3;
    _rarityLabel.strokeColour = [UIColor blackColor];
    _rarityLabel.text = @"Rarity:";
    [_cardInfoView addSubview:_rarityLabel];
    
    _rarityTextLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(198, SCREEN_HEIGHT-200, 150, 40)];
    _rarityTextLabel.textAlignment = NSTextAlignmentLeft;
    _rarityTextLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE +3];
    _rarityTextLabel.strokeOn = YES;
    [_rarityTextLabel setMinimumScaleFactor:10/30];
    _rarityTextLabel.strokeThickness = 3;
    _rarityTextLabel.strokeColour = [UIColor blackColor];
    [_cardInfoView addSubview:_rarityTextLabel];
    
    _creatorLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(145, SCREEN_HEIGHT-180, 300, 40)];
    _creatorLabel.textAlignment = NSTextAlignmentLeft;
    _creatorLabel.textColor = [UIColor whiteColor];
    _creatorLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE +3];
    _creatorLabel.strokeOn = YES;
    _creatorLabel.strokeThickness = 3;
    _creatorLabel.strokeColour = [UIColor blackColor];
    [_cardInfoView addSubview:_creatorLabel];
    
    _idLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(145, SCREEN_HEIGHT-160, 150, 40)];
    _idLabel.textAlignment = NSTextAlignmentLeft;
    _idLabel.textColor = [UIColor whiteColor];
    _idLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE +3];
    _idLabel.strokeOn = YES;
    _idLabel.strokeThickness = 3;
    _idLabel.strokeColour = [UIColor blackColor];
    [_cardInfoView addSubview:_idLabel];
    
    _cardTagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _cardTagsLabel.textColor = [UIColor whiteColor];
    _cardTagsLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE +1];
    _cardTagsLabel.numberOfLines = 0;
    _cardTagsLabel.textAlignment = NSTextAlignmentLeft;
    [_cardTagsLabel setUserInteractionEnabled:YES];
    _cardTagsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_cardInfoView addSubview:_cardTagsLabel];
    
    
    _reportButton = [[CFButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 0.5 - (CARD_DETAIL_BUTTON_WIDTH/2), SCREEN_HEIGHT -(CARD_DETAIL_BUTTON_HEIGHT*2), CARD_DETAIL_BUTTON_WIDTH, CARD_DETAIL_BUTTON_HEIGHT)];
    _reportButton.label.text = @"Report";
    [_reportButton setTextSize:CARD_NAME_SIZE +1];
    [_reportButton addTarget:self action:@selector(reportButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    //[_cardInfoView addSubview:_reportButton];
    
    _reportHintLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    _reportHintLabel.textColor = [UIColor whiteColor];
    _reportHintLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE -1];
    _reportHintLabel.textAlignment = NSTextAlignmentCenter;
    _reportHintLabel.strokeOn = YES;
    _reportHintLabel.strokeThickness = 2;
    _reportHintLabel.strokeColour = [UIColor blackColor];
    _reportHintLabel.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT-55);
    [_cardInfoView addSubview:_reportHintLabel];
    
    
    UITapGestureRecognizer *cardInfoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeCardInfoView)];
    [cardInfoTap setNumberOfTapsRequired:1];
    
    [_cardInfoView setUserInteractionEnabled:YES];
    [_cardInfoView addGestureRecognizer:cardInfoTap];
    
   
    
    _searchView = [[CFLabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-40, self.view.bounds.size.width, 260)];
    [self.view insertSubview:_searchView aboveSubview:_cardsView];
    [_searchView setUserInteractionEnabled:YES];
    [_searchView setBackgroundColor:COLOUR_INTERFACE_BLUE_DARK];
    
    UILabel*searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    searchLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE +7];
    searchLabel.textColor = [UIColor blackColor];
    searchLabel.textAlignment = NSTextAlignmentCenter;
    searchLabel.text = @"Search for a card";
    searchLabel.center = CGPointMake(SCREEN_WIDTH/2, 30);
    [_searchView addSubview:searchLabel];
    
    _searchNameField =  [[UITextField alloc] initWithFrame:CGRectMake(60,60,SCREEN_WIDTH-60-20,30)];
    _searchNameField.textColor = [UIColor blackColor];
    _searchNameField.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE-3];
    _searchNameField.returnKeyType = UIReturnKeyDone;
    [_searchNameField setPlaceholder:@"Enter card name"];
    [_searchNameField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_searchNameField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_searchNameField addTarget:self action:@selector(searchFieldBegan) forControlEvents:UIControlEventEditingDidBegin];
    [_searchNameField addTarget:self action:@selector(searchFieldFinished) forControlEvents:UIControlEventEditingDidEnd];
    [_searchNameField setDelegate:self];
    [_searchNameField.layer setBorderColor:[UIColor blackColor].CGColor];
    [_searchNameField.layer setBorderWidth:2];
    _searchNameField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    //_searchNameField.layer.cornerRadius = 4.0;
    [_searchNameField setBackgroundColor:COLOUR_INTERFACE_BLUE_LIGHT];
    
    [_searchView addSubview:_searchNameField];
    
    UILabel*searchNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 60, 50, 30)];
    searchNameLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE+1];
    searchNameLabel.textColor = [UIColor blackColor];
    searchNameLabel.text = @"Name:";
    searchNameLabel.textAlignment = NSTextAlignmentRight;
    [_searchView addSubview:searchNameLabel];
    
    _searchTagsField =  [[UITextField alloc] initWithFrame:CGRectMake(60,60 + 40,SCREEN_WIDTH-60-20,30)];
    _searchTagsField.textColor = [UIColor blackColor];
    _searchTagsField.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE -3];
    _searchTagsField.returnKeyType = UIReturnKeyDone;
    [_searchTagsField setPlaceholder:@"Enter card tags separated by space"];
    [_searchTagsField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_searchTagsField addTarget:self action:@selector(searchFieldBegan) forControlEvents:UIControlEventEditingDidBegin];
    [_searchTagsField addTarget:self action:@selector(searchFieldFinished) forControlEvents:UIControlEventEditingDidEnd];
    [_searchTagsField setDelegate:self];
    [_searchTagsField.layer setBorderColor:[UIColor blackColor].CGColor];
    [_searchTagsField.layer setBorderWidth:2];
    [_searchTagsField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _searchTagsField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    //_searchTagsField.layer.cornerRadius = 4.0;
    [_searchTagsField setBackgroundColor:COLOUR_INTERFACE_BLUE_LIGHT];
    
    [_searchView addSubview:_searchTagsField];
    
    UILabel*searchTagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 60 + 40, 50, 30)];
    searchTagsLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE+1];
    searchTagsLabel.textColor = [UIColor blackColor];
    searchTagsLabel.text = @"Tags:";
    searchTagsLabel.textAlignment = NSTextAlignmentRight;
    [_searchView addSubview:searchTagsLabel];
    
    _searchIDField =  [[UITextField alloc] initWithFrame:CGRectMake(60,60 + 80,SCREEN_WIDTH-60-20,30)];
    _searchIDField.textColor = [UIColor blackColor];
    _searchIDField.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE-3];
    _searchIDField.returnKeyType = UIReturnKeyDone;
    [_searchIDField setPlaceholder:@"Enter one card number"];
    [_searchIDField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_searchIDField addTarget:self action:@selector(searchFieldBegan) forControlEvents:UIControlEventEditingDidBegin];
    [_searchIDField addTarget:self action:@selector(searchFieldFinished) forControlEvents:UIControlEventEditingDidEnd];
    [_searchIDField setDelegate:self];
    [_searchIDField.layer setBorderColor:[UIColor blackColor].CGColor];
    [_searchIDField.layer setBorderWidth:2];
    [_searchIDField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _searchIDField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    //_searchIDField.layer.cornerRadius = 4.0;
    [_searchIDField setBackgroundColor:COLOUR_INTERFACE_BLUE_LIGHT];
    
    [_searchView addSubview:_searchIDField];
    
    UILabel*searchIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 60 + 80, 50, 30)];
    searchIDLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE+1];
    searchIDLabel.textColor = [UIColor blackColor];
    searchIDLabel.text = @"ID:";
    searchIDLabel.textAlignment = NSTextAlignmentRight;
    [_searchView addSubview:searchIDLabel];
    
    CFButton*searchButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
    [searchButton setTextSize:CARD_NAME_SIZE+1];
    searchButton.label.text = @"Search";
    //[searchButton setImage:[UIImage imageNamed:@"search_button"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchButtonPressed) forControlEvents:UIControlEventTouchDown];
    searchButton.center = CGPointMake(SCREEN_WIDTH/2, 60 + 150);
    [_searchView addSubview:searchButton];
    
    //---------------filter view------------------//
    _filterView = [[CFLabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-40, self.view.bounds.size.width, 258)];
    [self.view insertSubview:_filterView aboveSubview:_searchView];
    [_filterView setUserInteractionEnabled:YES];
    [_filterView setBackgroundColor:COLOUR_INTERFACE_BLUE_DARK];
    
  
    _likedButton = [[CFButton alloc] initWithFrame:CGRectMake(0,0,90,25)];
    [_likedButton addTarget:self action:@selector(likedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_likedButton.dottedBorder removeFromSuperlayer];
    _likedButton.label.text = @"Hide liked";
    [_likedButton setTextSize:CARD_NAME_SIZE-4];
    _likedButton.center = CGPointMake(60, 60);
    [_filterView addSubview:_likedButton];
    _likedButton.alpha = 0.4;
    
    _ownedButton = [[CFButton alloc] initWithFrame:CGRectMake(0,0,90,25)];
    [_ownedButton addTarget:self action:@selector(ownedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_ownedButton.dottedBorder removeFromSuperlayer];
    _ownedButton.label.text = @"Hide owned";
    [_ownedButton setTextSize:CARD_NAME_SIZE-4];
    _ownedButton.center = CGPointMake(60, 88);
    [_filterView addSubview:_ownedButton];
    _ownedButton.alpha = 0.4;
    
    _stockedButton = [[CFButton alloc] initWithFrame:CGRectMake(0,0,90,25)];
    [_stockedButton addTarget:self action:@selector(stockButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_stockedButton.dottedBorder removeFromSuperlayer];
    _stockedButton.label.text = @"Hide 0 stock";
    [_stockedButton setTextSize:CARD_NAME_SIZE-4];
    _stockedButton.center = CGPointMake(60, 116);
    [_filterView addSubview:_stockedButton];
    _stockedButton.alpha = 0.4;
    
    _deckTagsButton = [[CFButton alloc] initWithFrame:CGRectMake(0,0,90,25)];
    [_deckTagsButton addTarget:self action:@selector(deckTagsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_deckTagsButton.dottedBorder removeFromSuperlayer];
    _deckTagsButton.label.text = @"Only deck tags";
    [_deckTagsButton setTextSize:CARD_NAME_SIZE-4];
    _deckTagsButton.center = CGPointMake(60, 144);
    [_filterView addSubview:_deckTagsButton];
    _deckTagsButton.alpha = 0.4;
    
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
        costLabel.font = [UIFont fontWithName:cardMainFontBlack size:CARD_NAME_SIZE+7];
        costLabel.strokeOn = YES;
        costLabel.strokeColour = [UIColor blackColor];
        costLabel.strokeThickness = 3;
        costLabel.text = [NSString stringWithFormat:@"%d", i];
        [costFilterButton addSubview:costLabel];
        //costLabel.center = costFilterButton.center;
        
        [_costFilterButtons addObject:costFilterButton];
    }
    
    //rarity buttons
    CGPoint rarityFilterStartPoint = CGPointMake(160, 60);
    _rarityFilterButtons = [NSMutableArray arrayWithCapacity:cardRarityLegendary+1];
    for (int i = 0; i <= cardRarityLegendary; i++)
    {
        CFButton*rarityFilterButton = [[CFButton alloc] initWithFrame:CGRectMake(0,0,90,25)];
        [rarityFilterButton setTextSize:CARD_NAME_SIZE-1];
        [rarityFilterButton.dottedBorder removeFromSuperlayer];
        //[rarityFilterButton setImage:[UIImage imageNamed:@"filter_button"] forState:UIControlStateNormal];
        [rarityFilterButton addTarget:self action:@selector(rarityFilterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        rarityFilterButton.center = CGPointMake(rarityFilterStartPoint.x, rarityFilterStartPoint.y + i*28);
        rarityFilterButton.label.text = [CardModel getRarityText:i];
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
    CGPoint elementFilterStartPoint = CGPointMake(260, 60);
    _elementFilterButtons = [NSMutableArray arrayWithCapacity:7];
   for (int i = 0; i < 7; i++)
    {
        CFButton*elementFilterButton = [[CFButton alloc] initWithFrame:CGRectMake(0,0,90,25)];
        [elementFilterButton setTextSize:CARD_NAME_SIZE-1];
        [elementFilterButton.dottedBorder removeFromSuperlayer];
        //[elementFilterButton setImage:[UIImage imageNamed:@"filter_button"] forState:UIControlStateNormal];
        [elementFilterButton addTarget:self action:@selector(elementFilterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        elementFilterButton.center = CGPointMake(elementFilterStartPoint.x, elementFilterStartPoint.y + i*28);
        elementFilterButton.label.text = [CardModel elementToString:i];
        [_filterView addSubview:elementFilterButton];
        
        //costLabel.center = costFilterButton.center;
        
        [_elementFilterButtons addObject:elementFilterButton];
    }
    
    //--------------category tabs---------------//
    
    //brianJuly23
    //changing category tabs to vertical orientation
    //category button dimensions 174, h 96, y 8, x470
    //overall screen dimensions: mockup dimensions 640x1136
   mockupHeight = 1136.0f;
    mockupWidth = 640.0f;
    
    
    float catButtonHeightRatio = 96/mockupHeight;
    float catButtonWidthRatio = 174/mockupWidth;
    float catButtonXRatio = 468/mockupWidth;
    float firstCatButtonHeight = 8/mockupHeight;
    
    _categoryTabs = [NSMutableArray arrayWithCapacity:7];
     float firstYUsed;
    for (float i = 0; i < 5; i++)
    {
        float YToUse;
       
        if(i==0)
        {
            YToUse = firstCatButtonHeight*SCREEN_HEIGHT;
            firstYUsed = YToUse;
        }
        else
        {
           
            
            YToUse = (catButtonHeightRatio*SCREEN_HEIGHT*i);
            
        }
        if(i>=2)
        {
            
            YToUse= YToUse-(catButtonHeightRatio*(1.0f/20.0f)*SCREEN_HEIGHT*i);
            
        }
        UIButton*categoryButton = [[UIButton alloc] initWithFrame:CGRectMake(catButtonXRatio*SCREEN_WIDTH,YToUse,catButtonWidthRatio*SCREEN_WIDTH,catButtonHeightRatio*SCREEN_HEIGHT)];
        
        NSLog(@"%f %f %f %f", categoryButton.frame.size.width, categoryButton.frame.size.height,categoryButton.frame.origin.x,categoryButton.frame.origin.y);
        //[categoryButton setupAsTab];
        
        //BrianJuly23 editing categoryButtons to show new UI
        UIImage *categoryButtonBG = [UIImage imageNamed:@"CardStoreBlueButton.png"];
        
        [categoryButton setBackgroundImage:categoryButtonBG forState:UIControlStateNormal];
        
        int sfontSize;
        if(SCREEN_HEIGHT<500)
        {
            sfontSize = 12;
        }
        else
        {
            sfontSize = 14;
            
        }
        
        categoryButton.titleLabel.font = [UIFont fontWithName:@"BookmanOldStyle-Bold" size:sfontSize];
       // categoryButton.titleLabel.shadowColor = [UIColor blackColor];
       //categoryButton.titleLabel.shadowOffset = CGSizeMake(2,2);
        [categoryButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        //[categoryButton setImage:[UIImage imageNamed:@"category_tab_enabled"] forState:UIControlStateNormal];
        //[categoryButton setImage:[UIImage imageNamed:@"category_tab_disabled"] forState:UIControlStateDisabled];
        //[categoryButton setBackgroundColor:COLOUR_INTERFACE_BLUE];
        [categoryButton addTarget:self action:@selector(categoryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
      
        
        [self.view addSubview:categoryButton];
        
        if (i == storeCategoryFeatured)
            [categoryButton setTitle:@"Featured"forState:UIControlStateNormal];
        else if (i == storeCategoryNewest)
            [categoryButton setTitle:@"Newest"forState:UIControlStateNormal];
        else if (i == storeCategoryPopular)
            [categoryButton setTitle:@"Popular"forState:UIControlStateNormal];
        else if (i == storeCategoryOwned)
            [categoryButton setTitle:@"Owned"forState:UIControlStateNormal];
        else if (i == storeCategoryDesigned)
            [categoryButton setTitle:@"Designed"forState:UIControlStateNormal];
        
        
        /*
        StrokedLabel*categoryLabel = [[StrokedLabel alloc]initWithFrame:categoryButton.bounds];
        categoryLabel.textAlignment = NSTextAlignmentCenter;
        categoryLabel.textColor = [UIColor whiteColor];
        categoryLabel.backgroundColor = [UIColor clearColor];
        categoryLabel.font = [UIFont fontWithName:cardMainFont size:16];
        //elementLabel.strokeOn = YES;
        categoryLabel.strokeColour = [UIColor blackColor];
        categoryLabel.strokeThickness = 3;
        if (i == storeCategoryFeatured)
            categoryLabel.text = @"Featured";
        else if (i == storeCategoryNewest)
            categoryLabel.text = @"Newest";
        else if (i == storeCategoryPopular)
            categoryLabel.text = @"Popular";
        else if (i == storeCategoryOwned)
            categoryLabel.text = @"Owned";
        else if (i == storeCategoryDesigned)
            categoryLabel.text = @"Designed";
        [categoryButton addSubview:categoryLabel];
         */
        //costLabel.center = costFilterButton.center;
        
        [_categoryTabs addObject:categoryButton];
        
        //default selects the first tab
        if (i == 0)
            [categoryButton setSelected:YES];
        else
            [categoryButton setSelected:NO];
    }
    
    //--------------blank card view-----------------//
    _blankCardView = [[UIView alloc] initWithFrame:self.view.bounds];
    _blankCardView.alpha = 0;
    UIView *blankCardDarkFilter = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH, SCREEN_HEIGHT-40)];
    blankCardDarkFilter.backgroundColor = [[UIColor alloc]initWithHue:0 saturation:0 brightness:0 alpha:0.8];
    [blankCardDarkFilter setUserInteractionEnabled:YES]; //blocks all interaction behind it
    [_blankCardView addSubview:blankCardDarkFilter];
    
    CFButton*blankCardBackButton = [[CFButton alloc] initWithFrame:CGRectMake(4, SCREEN_HEIGHT-40-40 + 4, 46, 32)];
    [blankCardBackButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [blankCardBackButton addTarget:self action:@selector(blankCardBackButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [_blankCardView addSubview:blankCardBackButton];
    
    StrokedLabel*createCardLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    createCardLabel.textAlignment = NSTextAlignmentCenter;
    createCardLabel.textColor = [UIColor whiteColor];
    createCardLabel.backgroundColor = [UIColor clearColor];
    
    if (SCREEN_HEIGHT < 568)
        createCardLabel.center = CGPointMake(SCREEN_WIDTH/2, 35);
    else
        createCardLabel.center = CGPointMake(SCREEN_WIDTH/2, 70);
    
    createCardLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE*2];
    createCardLabel.strokeOn = YES;
    createCardLabel.strokeColour = [UIColor blackColor];
    createCardLabel.strokeThickness = 5;
    createCardLabel.text = @"Forge a New Card";
    [_blankCardView addSubview:createCardLabel];
    
    //brian jul23
    //cardButton—480y,490X,128,180
    
    float CreateCardXRatio = 490/mockupWidth;
    float CreateCardYRatio = 480/mockupHeight;
    float CreateCardWidthRatio = 128/mockupWidth;
    float createCardHeightRatio = 180/mockupHeight;
    
    _createCardButton = [[UIButton alloc] initWithFrame:CGRectMake(CreateCardXRatio*SCREEN_WIDTH, CreateCardYRatio*SCREEN_HEIGHT, CreateCardWidthRatio*SCREEN_WIDTH, createCardHeightRatio*SCREEN_HEIGHT)];
    UIImage *createCardBtnImage = [UIImage imageNamed:@"CardStoreCardIcon.png"];
    
    [_createCardButton setImage:createCardBtnImage forState:UIControlStateNormal];
    [_createCardButton setImage:CARD_ICON_GRAY_IMAGE forState:UIControlStateDisabled];
    
    [_createCardButton addTarget:self action:@selector(createCardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_createCardButton];
    
    //[_blankCardView addSubview:_createCardButton];
    
    UIImage *plusIcon = [UIImage imageNamed:@"CardStorePlusButton.png"];
    //plusButton1–62W,58H,484X,592Y
    float plusIcon1XRatio = 484/mockupWidth;
    float plusIcon1YRatio = 592/mockupHeight;
    float plusIcon1WRatio = 62/mockupWidth;
    float plusIcon1HRatio = 58/mockupHeight;
    
    UIImageView* cardAddIcon = [[UIImageView alloc] initWithImage:plusIcon];
    cardAddIcon.frame = CGRectMake(plusIcon1XRatio*SCREEN_WIDTH, plusIcon1YRatio*SCREEN_HEIGHT, plusIcon1WRatio*SCREEN_WIDTH, plusIcon1HRatio*SCREEN_HEIGHT);
    [self.view addSubview:cardAddIcon];
    
    _remainingCardLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    _remainingCardLabel.textAlignment = NSTextAlignmentCenter;
    _remainingCardLabel.textColor = [UIColor whiteColor];
    _remainingCardLabel.backgroundColor = [UIColor clearColor];
    _remainingCardLabel.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 40 - 230);
    _remainingCardLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE+1];
    _remainingCardLabel.strokeOn = YES;
    _remainingCardLabel.strokeColour = [UIColor blackColor];
    _remainingCardLabel.strokeThickness = 3;
    _remainingCardLabel.text = @"";
    
    [_blankCardView addSubview:_remainingCardLabel];
    
    StrokedLabel*buyBlankCardLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    buyBlankCardLabel.textAlignment = NSTextAlignmentCenter;
    buyBlankCardLabel.textColor = [UIColor whiteColor];
    buyBlankCardLabel.backgroundColor = [UIColor clearColor];
    buyBlankCardLabel.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 40 - 195);
    buyBlankCardLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE+7];
    buyBlankCardLabel.strokeOn = YES;
    buyBlankCardLabel.strokeColour = [UIColor blackColor];
    buyBlankCardLabel.strokeThickness = 3;
    buyBlankCardLabel.text = @"Purchase additional blank cards:";
    [_blankCardView addSubview:buyBlankCardLabel];
    
    _buyBlankCardButtons = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < 3; i++)
    {
        double distanceFromCenter = i-1;
        UIButton*cardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 96)];
        [cardButton setImage:CARD_ICON_IMAGE forState:UIControlStateNormal];
        cardButton.center = CGPointMake(SCREEN_WIDTH/2 + 90 *distanceFromCenter ,SCREEN_HEIGHT - 40 - 125);
        [cardButton addTarget:self action:@selector(cardButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_buyBlankCardButtons addObject:cardButton];
        [_blankCardView addSubview:cardButton];
        
        StrokedLabel *cardLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 155, 50)];
        cardLabel.textAlignment = NSTextAlignmentCenter;
        cardLabel.textColor = [UIColor whiteColor];
        cardLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE*2 +10];
        cardLabel.strokeOn = YES;
        cardLabel.strokeThickness = 5;
        cardLabel.strokeColour = [UIColor blackColor];
        cardLabel.center = CGPointMake(SCREEN_WIDTH/2 + 90 *distanceFromCenter, SCREEN_HEIGHT - 40 - 105);
        
        if (i == 0)
            cardLabel.text = @"2";
        else if (i == 1)
            cardLabel.text = @"5";
        else if (i == 2)
            cardLabel.text = @"20";
        
        [_blankCardView addSubview:cardLabel];
        
        StrokedLabel *cardDollarLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 155, 50)];
        cardDollarLabel.textAlignment = NSTextAlignmentCenter;
        cardDollarLabel.textColor = [UIColor whiteColor];
        cardDollarLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE+11];
        cardDollarLabel.strokeOn = YES;
        cardDollarLabel.strokeThickness = 5;
        cardDollarLabel.strokeColour = [UIColor blackColor];
        cardDollarLabel.center = CGPointMake(SCREEN_WIDTH/2 + 90 *distanceFromCenter, SCREEN_HEIGHT - 40 - 60);
        
        if (i == 0)
            cardDollarLabel.text = @"$0.99";
        else if (i == 1)
            cardDollarLabel.text = @"$1.99";
        else if (i == 2)
            cardDollarLabel.text = @"$5.99";
        
        [_blankCardView addSubview:cardDollarLabel];
    }
    
    //-------------------buy gold view-------------------//
    _buyGoldView = [[UIView alloc] initWithFrame:self.view.bounds];
    _buyGoldView.alpha = 0;
    
    UIView *buyGoldDarkFilter = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH, SCREEN_HEIGHT-40)];
    buyGoldDarkFilter.backgroundColor = [[UIColor alloc]initWithHue:0 saturation:0 brightness:0 alpha:0.8];
    [buyGoldDarkFilter setUserInteractionEnabled:YES]; //blocks all interaction behind it
    [_buyGoldView addSubview:buyGoldDarkFilter];
    
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
    [_buyGoldView addSubview:buyGoldLabel];
    
    CFButton*buyGoldBackButton = [[CFButton alloc] initWithFrame:CGRectMake(4, SCREEN_HEIGHT-40-40 + 4, 46, 32)];
    [buyGoldBackButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [buyGoldBackButton addTarget:self action:@selector(buyGoldBackButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [_buyGoldView addSubview:buyGoldBackButton];
    
    _buyGoldButtons = [NSMutableArray arrayWithCapacity:6];
   /* for (int i = 0; i < 2; i++)
    {
        for (int j = 0; j < 3; j++)
        {
            double distanceFromCenter = j-1;
            UIButton*goldButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
            [goldButton setImage:GOLD_ICON_IMAGE forState:UIControlStateNormal];
            goldButton.center = CGPointMake(SCREEN_WIDTH/2 + 90 *distanceFromCenter ,SCREEN_HEIGHT/2 - 40 + (110*i));
            [goldButton addTarget:self action:@selector(buyGoldButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_buyGoldButtons addObject:goldButton];
            [_buyGoldView addSubview:goldButton];
            
            StrokedLabel *goldLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 155, 50)];
            goldLabel.textAlignment = NSTextAlignmentCenter;
            goldLabel.textColor = [UIColor whiteColor];
            goldLabel.font = [UIFont fontWithName:cardMainFont size:26];
            goldLabel.strokeOn = YES;
            goldLabel.strokeThickness = 4;
            goldLabel.strokeColour = [UIColor blackColor];
            goldLabel.center = CGPointMake(SCREEN_WIDTH/2 + 90 *distanceFromCenter, SCREEN_HEIGHT/2 - 40 + (110*i));
            
            if (i == 0)
            {
                if (j == 0)
                    goldLabel.text = @"1000";
                else if (j == 1)
                    goldLabel.text = @"2200";
                else if (j == 2)
                    goldLabel.text = @"6000";
            }
            else if (i == 1)
            {
                if (j == 0)
                    goldLabel.text = @"13000";
                else if (j == 1)
                    goldLabel.text = @"21000";
                else if (j == 2)
                    goldLabel.text = @"30000";
            }
            
            [_buyGoldView addSubview:goldLabel];
            
            StrokedLabel *goldDollarLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 155, 50)];
            goldDollarLabel.textAlignment = NSTextAlignmentCenter;
            goldDollarLabel.textColor = [UIColor whiteColor];
            goldDollarLabel.font = [UIFont fontWithName:cardMainFont size:22];
            goldDollarLabel.strokeOn = YES;
            goldDollarLabel.strokeThickness = 3;
            goldDollarLabel.strokeColour = [UIColor blackColor];
            goldDollarLabel.center = CGPointMake(SCREEN_WIDTH/2 + 90 *distanceFromCenter, SCREEN_HEIGHT/2 - 40 + 55 + (110*i));
            
            if (i == 0)
            {
                if (j == 0)
                    goldDollarLabel.text = @"$0.99";
                else if (j == 1)
                    goldDollarLabel.text = @"$1.99";
                else if (j == 2)
                    goldDollarLabel.text = @"$4.99";
            }
            else if (i == 1)
            {
                if (j == 0)
                    goldDollarLabel.text = @"$9.99";
                else if (j == 1)
                    goldDollarLabel.text = @"$14.99";
                else if (j == 2)
                    goldDollarLabel.text = @"$19.99";
            }
            
            [_buyGoldView addSubview:goldDollarLabel];
        }
    }*/
    
    //---------------activity indicator--------------------//
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_activityIndicator setFrame:self.view.bounds];
    [_activityIndicator setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.5]];
    [_activityIndicator setUserInteractionEnabled:YES];
    _activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    _activityLabel.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + 60);
    _activityLabel.textAlignment = NSTextAlignmentCenter;
    _activityLabel.textColor = [UIColor whiteColor];
    _activityLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE+5];
    _activityLabel.text = [NSString stringWithFormat:@"Processing..."];
    [_activityIndicator addSubview:_activityLabel];
    
    _activityFailedButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    _activityFailedButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 60);
    _activityFailedButton.label.text = @"Ok";
    [_activityFailedButton setTextSize:CARD_NAME_SIZE+3];
    [_activityFailedButton addTarget:self action:@selector(activityFailedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    //-----------------search result----------------//
    _searchResult = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    _searchResult.textAlignment = NSTextAlignmentCenter;
    _searchResult.textColor = [UIColor whiteColor];
    _searchResult.backgroundColor = [UIColor clearColor];
    
    _searchResult.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE*2];
    _searchResult.strokeOn = YES;
    _searchResult.strokeColour = [UIColor blackColor];
    _searchResult.strokeThickness = 4;
    _searchResult.center = CGPointMake(_cardsView.bounds.size.width/2, _cardsView.bounds.size.height/2);
    
    
    keyboardSize = CGSizeMake(0, 216);
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(tapRegistered)];
    [tapGesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGesture];
    
    [self updateFooterViews];
    [self loadCards];
    
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
        
        self.tutLabel.label.text = @"This is the card store. Here you can interact with cards designed by other players.";
        [self.tutOkButton addTarget:self action:@selector(tutorialCreateCard) forControlEvents:UIControlEventTouchUpInside];
        [self.tutLabel.label setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:_tutLabel];
        [self.view addSubview:_tutOkButton];
    }
    
    //brianJul26
    //yStart = 1024Y,106H--whole screen width
    //add bottom bar to store
    
    UIImageView *bottomBarStore = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CardStoreBottomRow.png"]];
    float bottomBarStartY = 1024/mockupHeight;
    float bottomBarHeight = 120/mockupHeight;
    bottomBarStore.frame =  _footerView.bounds;
    
    [_footerView addSubview:bottomBarStore];
    
    
    //brianJul26 add back button with style
    //backButton-0X,100W,94H
    float backButtonXRatio = 2/mockupWidth;
    float backButtonWRatio = 100/mockupWidth;
    float backButtonHRatio = 94/mockupHeight;
    float backButtonYRatio = 15/mockupHeight;
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(backButtonXRatio*SCREEN_WIDTH, backButtonYRatio*SCREEN_HEIGHT, backButtonWRatio*SCREEN_WIDTH, backButtonHRatio*SCREEN_HEIGHT)];
    
    [self.backButton setImage:[UIImage imageNamed:@"CardStoreBackButton.png"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [_footerView addSubview:self.backButton];
    
    //filterButtonStart—110X,269W,95H,15Y
  
    
    float filterButtonXRatio = 110/mockupWidth;
    float filterButtonYRatio = 15/mockupHeight;
    float filterButtonWRatio = 269/mockupWidth;
    float filterButtonHRatio = 95/mockupHeight;
    
    _filterToggleButton = [[UIButton alloc] initWithFrame:CGRectMake(filterButtonXRatio*SCREEN_WIDTH, filterButtonYRatio*SCREEN_HEIGHT,filterButtonWRatio*SCREEN_WIDTH, filterButtonHRatio*SCREEN_HEIGHT)];
    [_filterToggleButton setTitle: @"Filter" forState:UIControlStateNormal];
    [_filterToggleButton setBackgroundImage:[UIImage imageNamed:@"CardStoreBottomButtonNoWords.png"] forState:UIControlStateNormal];
     
    _filterToggleButton.selected = YES;
    //[_filterToggleButton setImage:[UIImage imageNamed:@"filter_button_small"] forState:UIControlStateNormal];
    //[_filterToggleButton setImage:[UIImage imageNamed:@"filter_button_small_selected"] forState:UIControlStateSelected];
    [_filterToggleButton addTarget:self action:@selector(filterToggleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:_filterToggleButton];
    
      //searchButton-378X,269W,95H,15Y
    //---------------search view-------------------//
    float searchButtonXRatio = 378/mockupWidth;
    float searchButtonYRatio = 15/mockupHeight;
    float searchButtonWRatio = 269/mockupWidth;
    float searchButtonHRatio = 95/mockupHeight;
    
    _searchToggleButton = [[UIButton alloc] initWithFrame:CGRectMake(searchButtonXRatio*SCREEN_WIDTH, searchButtonYRatio*SCREEN_HEIGHT, searchButtonWRatio*SCREEN_WIDTH, searchButtonHRatio*SCREEN_HEIGHT)];
    [_searchToggleButton setBackgroundImage:[UIImage imageNamed:@"CardStoreSearchButtonNoWords.png"] forState:UIControlStateNormal];
    
    [_searchToggleButton setTitle:@"Search" forState:UIControlStateNormal];
    _searchToggleButton.selected = YES;
    //[_searchToggleButton setImage:[UIImage imageNamed:@"search_button_small"] forState:UIControlStateNormal];
    //[_searchToggleButton setImage:[UIImage imageNamed:@"search_button_small_selected"] forState:UIControlStateSelected];
    [_searchToggleButton addTarget:self action:@selector(searchToggleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [_footerView addSubview:_searchToggleButton];
    
     [self.view addSubview:_footerView];
    
    [self.view addSubview:_searchResult];
    
    _storeCategoryTab =1;
}

-(void)tutorialCreateCard
{
    self.tutLabel.label.text = @"You can create more cards by tapping the card icon at the bottom right. Additional blank cards can be gained for free by playing the campaign.";
    
    //TODO arrow
    
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(removeAllTutorialViews) forControlEvents:UIControlEventTouchUpInside];
}

-(void)boosterPackPress:(id)sender
{
    UIButton *sendButton = (UIButton *)sender;
    NSInteger boosterPack = sendButton.tag;
    NSInteger option = 0;
    if(boosterPack==101)
    {
        //show this on popup view
        option =1;
    }else if (boosterPack==102){
        option = 2;
    }else if (boosterPack==103){
        option = 3;
    }
    
    [self displayBoosterPackOption:option];
}

-(void)displayBoosterPackOption:(NSInteger)option
{
    //add a dark layer above the view
    self.storeDarkBG = [[UIView alloc] initWithFrame:self.view.bounds];
    //self.storeDarkBG.backgroundColor = [UIColor blackColor];
    [self.storeDarkBG setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
    
    self.boosterPackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeBoosterBuy:)];
    [self.boosterPackTap setNumberOfTapsRequired:1];
    
    [self.storeDarkBG setUserInteractionEnabled:YES];
    [self.storeDarkBG addGestureRecognizer:self.boosterPackTap];
    
    
    float mockupHeight = 1136.0f;
    float mockupWidth = 640.0f;
    
    //booster pack image 315x568, x158, y36
    float boostPackX = 158/mockupWidth*SCREEN_WIDTH;
    float boostPackY = 36/mockupHeight*SCREEN_HEIGHT;
    float boostPackW = 315/mockupWidth*SCREEN_WIDTH;
    float boostPackH = 568/mockupHeight*SCREEN_HEIGHT;
    self.boosterPackImageViewContainer = [[UIView alloc] initWithFrame:CGRectMake(boostPackX,boostPackY,boostPackW,boostPackH)];
    self.boosterPackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,boostPackW,boostPackH)];
    
    

    //check type of booster pack and alternate the images
    if(option==1)
    {
        self.boosterPackImageView.image = [UIImage imageNamed:@"FeaturedStoreCardPack001.png"];
        
    }
    if(option==2)
    {
        self.boosterPackImageView.image = [UIImage imageNamed:@"FeaturedStoreCardPack002.png"];
    }
    if(option==3)
    {
        self.boosterPackImageView.image = [UIImage imageNamed:@"FeaturedStoreCardPack003.png"];
    }
    
    self.boosterPackImageBackView = [[UIImageView alloc] initWithFrame:self.boosterPackImageView.frame];
    [self.boosterPackImageBackView setImage:[UIImage imageNamed:@"FeaturedStoreCardPack001.png"]];
    
    [self.boosterPackImageViewContainer addSubview:self.boosterPackImageBackView];
    [self.boosterPackImageViewContainer addSubview:self.boosterPackImageView];
    [self.storeDarkBG addSubview:self.boosterPackImageViewContainer];
    
    
    //-39x, 630 y, 545 W,422H
    float featuredStoreDialogX = 42/mockupWidth *SCREEN_WIDTH;
    float featuredStoreDialogY = 630/mockupHeight*SCREEN_HEIGHT;
    float featuredStoreDialogW = 545/mockupWidth*SCREEN_WIDTH;
    float featuredStoreDialogH = 422/mockupHeight*SCREEN_HEIGHT;
    
    self.featuredStoreDialog = [[UIView alloc] initWithFrame:CGRectMake(featuredStoreDialogX,featuredStoreDialogY,featuredStoreDialogW,featuredStoreDialogH)];
    
    UIImageView *featuredDialogImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,featuredStoreDialogW,featuredStoreDialogH)];
    featuredDialogImage.image = [UIImage imageNamed:@"FeaturedStoreDialog.png"];
    [self.featuredStoreDialog addSubview:featuredDialogImage];
    
    //add labels to featuredStoreDialog
    //-label1 72X, 66Y,410W
    float label1X = 72/mockupWidth*SCREEN_WIDTH;
    float label1Y = 60/mockupHeight*SCREEN_HEIGHT;
    float label1W = 410/mockupWidth*SCREEN_WIDTH;
    float label1H = 50/mockupHeight*SCREEN_HEIGHT;
    UILabel *featuredStoreLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(label1X,label1Y,label1W,label1H)];
    featuredStoreLabel1.text = @"15 Card Booster Pack";
    featuredStoreLabel1.textAlignment = NSTextAlignmentCenter;
    [featuredStoreLabel1 setFont:[UIFont fontWithName:cardFlavourTextFont size:16]];
    [featuredStoreLabel1 setTextColor:[UIColor colorWithRed:70.0/255.0 green:55.0/255.0 blue:8.0/255.0 alpha:1]];
    
    //118X, 132H, 50H,326W
    float label2X = 101/mockupWidth*SCREEN_WIDTH;
    float label2Y = 112/mockupHeight*SCREEN_HEIGHT;
    float label2W = 360/mockupWidth*SCREEN_WIDTH;
    float label2H = 50/mockupHeight*SCREEN_HEIGHT;
    
    UILabel *featuredStoreLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(label2X,label2Y,label2W,label2H)];
    featuredStoreLabel2.textAlignment = NSTextAlignmentCenter;
    featuredStoreLabel2.text = @"10 Common Cards";
    [featuredStoreLabel2 setFont:[UIFont fontWithName:cardFlavourTextFont   size:16]];
    [featuredStoreLabel2 setTextColor:[UIColor colorWithRed:70.0/255.0 green:55.0/255.0 blue:8.0/255.0 alpha:1]];
    
    label2Y += 15;
    
    UILabel *featuredStoreLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(label2X,label2Y,label2W,label2H)];
    featuredStoreLabel3.textAlignment = NSTextAlignmentCenter;
    featuredStoreLabel3.text = @"3 Uncommon Cards";
    [featuredStoreLabel3 setFont:[UIFont fontWithName:cardFlavourTextFont   size:16]];
    [featuredStoreLabel3 setTextColor:[UIColor colorWithRed:70.0/255.0 green:55.0/255.0 blue:8.0/255.0 alpha:1]];
    
    label2Y += 15;
    
    UILabel *featuredStoreLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(label2X,label2Y,label2W,label2H)];
    featuredStoreLabel4.textAlignment = NSTextAlignmentCenter;
    featuredStoreLabel4.text = @"1 Rare Card";
    [featuredStoreLabel4 setFont:[UIFont fontWithName:cardFlavourTextFont   size:16]];
    [featuredStoreLabel4 setTextColor:[UIColor colorWithRed:70.0/255.0 green:55.0/255.0 blue:8.0/255.0 alpha:1]];
    
    //78x78
    
    float closeButtonW = 78/mockupWidth*SCREEN_WIDTH;
    float closeButtonH = 78/mockupHeight*SCREEN_HEIGHT;
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.featuredStoreDialog.frame.size.width-closeButtonW/2,-closeButtonH/2,closeButtonW,closeButtonH)];
    [closeButton addTarget:self action:@selector(closeBoosterBuy:) forControlEvents:
UIControlEventTouchUpInside];
    [closeButton setUserInteractionEnabled:YES];

    [closeButton setBackgroundImage:[UIImage imageNamed:@"toggle_button_on.png"] forState:UIControlStateNormal];
    
    [self.featuredStoreDialog addSubview:closeButton];
    
    //add button to featuredStoreDialogue
    //-greenButton, 142x, 269H, 282 W,96H
    float purchaseButtonX = 142/mockupWidth*SCREEN_WIDTH;
    float purchaseButtonY = 240/mockupHeight*SCREEN_HEIGHT;
    float purchaseButtonW = 282/mockupWidth*SCREEN_WIDTH;
    float purchaseButtonH = 60/mockupWidth *SCREEN_HEIGHT;
    UIButton *purchaseButton = [[UIButton alloc] initWithFrame:CGRectMake(purchaseButtonX,purchaseButtonY,purchaseButtonW,purchaseButtonH)];
    [purchaseButton setBackgroundImage:[UIImage imageNamed:@"FeaturedStorePurchaseButton.png" ] forState:UIControlStateNormal];
    
    [purchaseButton addTarget:self action:@selector(purchaseBooster:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *purchaseCost = [[UILabel alloc] initWithFrame:CGRectMake(purchaseButtonX + 30,purchaseButtonY , purchaseButtonW - 30, purchaseButtonH)];
    [purchaseCost setFont:[UIFont fontWithName:cardFlavourTextFont size:22]];
    [purchaseCost setTextColor:[UIColor whiteColor]];
    [purchaseCost setText:@"1,000"];
    [purchaseCost setTextAlignment:NSTextAlignmentCenter];
    [purchaseCost setShadowColor:[UIColor blackColor]];
    [purchaseCost setShadowOffset:CGSizeMake(-1.0, -1.0)];
    
    
    [self.featuredStoreDialog addSubview:featuredStoreLabel1];
    [self.featuredStoreDialog addSubview:featuredStoreLabel2];
    [self.featuredStoreDialog addSubview:featuredStoreLabel3];
    [self.featuredStoreDialog addSubview:featuredStoreLabel4];
    [self.featuredStoreDialog addSubview:purchaseButton];
    [self.featuredStoreDialog addSubview:purchaseCost];
    
    
    [self.storeDarkBG addSubview:self.featuredStoreDialog];
    
    //[_searchToggleButton setBackgroundImage:[UIImage imageNamed:@"CardStoreSearchButtonNoWords.png"] forState:UIControlStateNormal];
    
    [self.view addSubview:self.storeDarkBG];
    
}
-(void)closeBoosterBuy:(id)sender
{
    
    [self.storeDarkBG removeFromSuperview];
}

-(void)purchaseBooster:(id)sender
{
    
    [self fadeOut:self.featuredStoreDialog inDuration:1.0];
    self.boosterPackImageView.image = [UIImage imageNamed:@"FeaturedStoreCardPack002.png"];
   // [self performSelectorInBackground:@selector(buyBoosterPackEffect) withObject:nil];
    [self buyBoosterPackEffect];
    
    NSLog(@"Purchase booster pressed!!");
    
    [PFCloud callFunctionInBackground:@"buyBoosterPack" withParameters:@{} block:^(NSArray *object, NSError *error) {
        //code
        if (error) {
            NSLog(@"bought with errors: %@", error.description);
        }else
        {
            self.purchasedCards = [object mutableCopy];
            NSLog(@"bought with success!!");
        }
    }];
    
    /*[PFCloud callFunction:@"buyBoosterPack" withParameters:@{
                                                             } error:&error];
    
    if (error) {
        NSLog(@"bought with errors: %@", error.description);
    }else
    {
        NSLog(@"bought with success!!");
    }*/
}

-(void)tutorialLikeCard
{
    [self modalScreen];
    
    self.tutLabel.label.text = @"When browsing cards, you can \"Like\" cards that you are interested in. Liking a card will give you a small gold reward, and increase the likelihood of the card becoming more rare.";
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(tutorialLikeRefill) forControlEvents:UIControlEventTouchUpInside];
    
    //TODO ARROW
    
    [self.view addSubview:_tutLabel];
    [self.view addSubview:_tutOkButton];
    
    _tutLabel.alpha = 0;
    _tutOkButton.alpha = 0;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _tutLabel.alpha = 1;
                         _tutOkButton.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         
                     }];
}

-(void)tutorialLikeRefill
{
    self.tutLabel.label.text = @"It will cost you a Like when liking cards, and these will refill by one every 30 minutes.";
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(tutorialEdit) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tutorialEdit
{
    self.tutLabel.label.text = @"After liking a card, you can click \"Edit\" to vote its stats and abilities. These votes will be tallied every day, so your cards are always changing.";
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(removeAllTutorialViews) forControlEvents:UIControlEventTouchUpInside];
    
    //TODO ARROW
    
    _isTutorial = NO;
    userPF[@"storeTutorialDone"] = @(YES);
    [userPF saveInBackground]; //not important if failed
}

-(void)filterToggleButtonPressed
{
    //[_filterToggleButton setSelected:![_filterToggleButton isSelected]];
    [self setFilterViewState:![self isFilterOpen]];
    
    if([self isFilterOpen] && [self isSearchOpen])
        [self searchToggleButtonPressed];
}

-(BOOL)isFilterOpen
{
    return ![_filterToggleButton isSelected];
}

-(void)setFilterViewState:(BOOL)state
{
    [_filterToggleButton setSelected:!state];
    
    CGRect filterViewFrame = _filterView.frame;
    if (state)
    {
        _searchResult.center = CGPointMake(_cardsView.bounds.size.width/2, _cardsView.bounds.size.height/5);
          [self.view bringSubviewToFront:_searchResult];
        [self.view bringSubviewToFront:_filterView];
        _filterView.alpha = 1;
        
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_filterView setFrame:CGRectMake(filterViewFrame.origin.x, filterViewFrame.origin.y - filterViewFrame.size.height-20, filterViewFrame.size.width, filterViewFrame.size.height)];
                         }
                         completion:^(BOOL completed){
                             
                         }];
    }
    else
    {
        _searchResult.center = CGPointMake(_cardsView.bounds.size.width/2, _cardsView.bounds.size.height/2);
        [self.view bringSubviewToFront:_searchResult];
         [self.view bringSubviewToFront:_filterView];
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_filterView setFrame:CGRectMake(filterViewFrame.origin.x, filterViewFrame.origin.y + filterViewFrame.size.height+20, filterViewFrame.size.width, filterViewFrame.size.height)];
                         }
                         completion:^(BOOL completed){
                              _filterView.alpha = 0;
                         }];
    }
}

-(void)searchToggleButtonPressed
{
    [self setSearchViewState:![self isSearchOpen]];
    
    if([self isFilterOpen] && [self isSearchOpen])
        [self filterToggleButtonPressed];
}

-(BOOL)isSearchOpen
{
    return ![_searchToggleButton isSelected];
}

-(void)setSearchViewState:(BOOL)state
{
    [_searchToggleButton setSelected:!state];
    CGRect searchViewFrame = _searchView.frame;
    
    if (state)
    {
        _searchResult.center = CGPointMake(_cardsView.bounds.size.width/2, _cardsView.bounds.size.height/5);
        [self.view bringSubviewToFront:self.searchView];
        self.searchView.alpha = 1;
        
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_searchView setFrame:CGRectMake(searchViewFrame.origin.x, searchViewFrame.origin.y - searchViewFrame.size.height-20, searchViewFrame.size.width, searchViewFrame.size.height)];
                         }
                         completion:^(BOOL completed){
                             
                         }];
    }
    else
    {
        _searchResult.center = CGPointMake(_cardsView.bounds.size.width/2, _cardsView.bounds.size.height/2);
        [self.view bringSubviewToFront:self.searchView];
        
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_searchView setFrame:CGRectMake(searchViewFrame.origin.x, searchViewFrame.origin.y + searchViewFrame.size.height+20, searchViewFrame.size.width, searchViewFrame.size.height)];
                         }
                         completion:^(BOOL completed){
                             self.searchView.alpha = 0;
                             
                         }];
    }
}

- (void)showPendingImageCardsApproval
{
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Store" message:@"Store Icon Tapped" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];*/
    _currentLoadedSales = _currentPendingImageCards;
    [self updateFilter];
}

- (void)likedButtonPressed
{
    _likedButton.selected = !_likedButton.selected;
    _likedFilter = !_likedFilter;
    _likedButton.alpha = _likedFilter ? 1 : 0.4;
    
    [self updateFilter];
}

-(void)ownedButtonPressed
{
    _ownedButton.selected = !_ownedButton.selected;
    _ownedFilter = !_ownedFilter;
    _ownedButton.alpha = _ownedFilter ? 1 : 0.4;
    
    [self updateFilter];
}

-(void)stockButtonPressed
{
    _stockedButton.selected = !_stockedButton.selected;
    _stockedFilter = !_stockedFilter;
    _stockedButton.alpha = _stockedFilter ? 1 : 0.4;
    
    [self updateFilter];
}

-(void)deckTagsButtonPressed
{
    _deckTagsButton.selected = !_deckTagsButton.selected;
    _deckTagsFilter = !_deckTagsFilter;
    _deckTagsButton.alpha = _deckTagsFilter ? 1 : 0.4;
    
    [self updateFilter];
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
    
    [self updateFilter];
    
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
    
    [self updateFilter];
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
    
    [self updateFilter];
}

-(void)categoryButtonPressed:(id)sender
{
    _isSearching = NO;
    UIButton*senderButton = sender;
    
    int i = 0;
    for (UIButton*button in _categoryTabs)
    {
        if (senderButton == button)
        {
            _storeCategoryTab = i;
            
            if(i==0)
            {
                //show featured Store
                _featuredStore.alpha = 0;
                _cardsView.alpha = 1;
                
            }
            else
            {
                _featuredStore.alpha = 0;
                _cardsView.alpha = 1;
                
            }
            [self loadCards];
            
            [button setSelected:YES];
        }
        else
        {
            [button setSelected:NO];
        }
        i++;
    }
    
    if ([self isFilterOpen])
        [self setFilterViewState:NO];
    if ([self isSearchOpen])
        [self setSearchViewState:NO];
}

-(void)cardButtonPressed:(id)sender
{
    UIButton*senderButton = sender;
    
    int i = 0;
    for (UIButton*button in _buyBlankCardButtons)
    {
        if (senderButton == button)
        {
            //TODO
            break;
        }
        i++;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateFooterViews];
    [self updateBlankCardView];
}

-(void)buyGoldButtonPressed:(id)sender
{
    UIButton*senderButton = sender;
    
    int i = 0;
    for (UIButton*button in _buyGoldButtons)
    {
        if (senderButton == button)
        {
            //TODO
            break;
        }
        i++;
    }
}

-(void)createCardButtonPressed
{
    CardEditorViewController *viewController = [[CardEditorViewController alloc] initWithMode:cardEditorModeCreation WithCard:nil];
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)openBuyGoldView
{
    [self.view insertSubview:_buyGoldView belowSubview:_footerView];
    [_backButton setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _buyGoldView.alpha = 1;
                         _backButton.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              _blankCardView.alpha = 0;
                                          }completion:nil];
                     }];
}


-(void)buyGoldBackButtonPressed
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _buyGoldView.alpha = 0;
                         _backButton.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         [_backButton setUserInteractionEnabled:YES];
                         [_buyGoldView removeFromSuperview];
                     }];
}

-(BOOL)shouldFilterCardPF:(PFObject*)cardPF withSalePF:(PFObject*)salePF
{
    int cost = [cardPF[@"cost"] intValue];
    int element = [cardPF[@"element"] intValue];
    int rarity = [cardPF[@"rarity"] intValue];
    
    if (cost >= 0 && cost < _costFilter.count)
    {
        if ([_costFilter[cost] boolValue] == NO)
            return NO;
    }
    
    if (element >= 0 && element < _elementFilter.count)
    {
        if ([_elementFilter[element] boolValue] == NO)
            return NO;
    }
    
    if (rarity >= 0 && rarity < _rarityFilter.count)
    {
        if ([_rarityFilter[rarity] boolValue] == NO)
            return NO;
    }
    
    //hide cards with stock 0
    if (_stockedFilter && [salePF[@"stock"] intValue] == 0)
        return NO;
    
    //hide cards already liked
    if (_likedFilter && [UserModel getLikedCardID:[cardPF[@"idNumber"] intValue]])
        return NO;
    
    //hide cards already owned (owns or creator is user
    if (_ownedFilter && ([UserModel getOwnedCardID:[cardPF[@"idNumber"] intValue]] || [userPF.objectId isEqualToString:cardPF[@"creator"]]))
        return NO;
    
    //if ([UserModel getReportedCardID:[cardPF[@"idNumber"] intValue]])
        //return NO;
    
    if (_deckTagsFilter)
    {
        NSMutableArray*deckTags = [NSMutableArray array];
        for (DeckModel *deck in userAllDecks)
        {
            for (NSString *tag in deck.tags)
            {
                if (![deckTags containsObject:tag])
                    [deckTags addObject:tag];
            }
        }
        
        BOOL foundTag = NO;
        for (NSString*cardTag in cardPF[@"tags"])
        {
            for (NSString *deckTag in deckTags)
            {
                if ([cardTag isEqualToString:deckTag])
                {
                    foundTag = YES;
                    break;
                }
            }
            
            if (foundTag)
                break;
        }
        
        if (!foundTag)
            return NO;
    }
    
    return YES;
}

-(void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
        
        if ([self isFilterOpen])
            [self setFilterViewState:NO];
        if ([self isSearchOpen])
            [self setSearchViewState:NO];
    }else if([touchedView.superview isKindOfClass:[StorePackCell class]]){
        StorePackCell *packCell = (StorePackCell*)touchedView.superview;
        int option = 1;
        if (packCell != nil) {
            option = packCell.packView.tag;
        }
        [self displayBoosterPackOption:option];
    }
}

-(void)openCardInfoView:(CardModel*)cardModel
{
    if ([UserModel getReportedCardID:cardModel.idNumber])
        cardModel.userReported = YES;
    _cardInfoView.alpha = 0;
    [self updateCardInfoView:(CardModel*)cardModel];
    
    [self.view insertSubview:_cardInfoView belowSubview:_footerView];
    [_backButton setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _cardInfoView.alpha = 1;
                         _backButton.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         if (_isTutorial)
                         {
                             [self tutorialLikeCard];
                         }
                     }];
}

-(void)updateCardInfoView:(CardModel*)cardModel
{
    //store the PFObject for use later
    NSNumber*cardID = @(cardModel.idNumber);
    
    BOOL foundCardPF = NO;
    
    for (PFObject *cardPF in self.cardsView.currentCardsPF)
    {
        if (cardPF != [NSNull null] && [cardID isEqualToNumber:cardPF[@"idNumber"]])
        {
            _cardPF = cardPF;
            foundCardPF = YES;
            break;
        }
    }
    
    //this shouldn't happen, since the cardView will exist only if the cardPF has been loaded
    if (!foundCardPF)
    {
        NSLog(@"ERROR: Could not find cardPF for a card that's already loaded");
        [self closeCardInfoView];
        return;
    }
    
    [_cardView removeFromSuperview];
    
    CardView*originalView = cardModel.cardView;
    _cardView = [[CardView alloc] initWithModel:cardModel viewMode:cardViewModeToValidate];
    _cardView.frontFacing = YES;
    cardModel.cardView = originalView;
    _cardView.cardViewState = cardViewStateCardViewer;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (SCREEN_HEIGHT < 568)
        {
            _cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
            _cardView.center = CGPointMake(_cardView.frame.size.width/2+10, 150);
        }
        else
        {
            _cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
            _cardView.center = CGPointMake(_cardView.frame.size.width/2+10, 200);
        }
        
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        _cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
        _cardView.center = CGPointMake(_cardView.frame.size.width/2+10, _cardView.frame.size.height/2+10);
        int goldLabelY = _cardView.frame.origin.y + _cardView.frame.size.height + _goldLabel.frame.size.height;
        _goldLabel.center = CGPointMake(SCREEN_WIDTH/3, goldLabelY + _goldIcon.frame.size.height/3);
        _goldIcon.center = CGPointMake(SCREEN_WIDTH/3, goldLabelY);
        _likesLabel.center = CGPointMake(SCREEN_WIDTH/7, goldLabelY + _likesIcon.frame.size.height/3);
        _likesIcon.center = CGPointMake(SCREEN_WIDTH/7, goldLabelY);
        int rarityX = _goldIcon.center.x + _goldIcon.frame.size.width + (_rarityLabel.frame.size.width/2);
        int rarityY = _goldIcon.frame.origin.y + _rarityLabel.frame.size.height/2;
        _rarityLabel.center = CGPointMake(rarityX, rarityY);
        int creatorY = rarityY + _creatorLabel.frame.size.height;
        int creatorX = _goldIcon.center.x + _goldIcon.frame.size.width + (_creatorLabel.frame.size.width/2);
        _creatorLabel.center = CGPointMake(creatorX, creatorY);
        int idY = creatorY + _idLabel.frame.size.height;
        int idLabelX = _goldIcon.center.x + _goldIcon.frame.size.width + (_idLabel.frame.size.width/2);
        _idLabel.center = CGPointMake(idLabelX, idY);
        
        int rarityTextX = _rarityLabel.frame.origin.x + _rarityLabel.frame.size.width + (_rarityTextLabel.frame.size.width/2);
        _rarityTextLabel.center = CGPointMake(rarityTextX, rarityY);
    }
    
    [_cardInfoView addSubview:_cardView];
    
    /*if (self.cardsView.isFeaturedCard) {
        self.featuredBanner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FeaturedStoreCardOfTheWeekBanner.png"]];
        [self.featuredBanner setFrame:CGRectMake(_cardView.frame.origin.x, _cardView.frame.origin.y,_cardView.frame.size.width/6 *5, _cardView.frame.size.height/2)];
        [_cardInfoView addSubview:self.featuredBanner];
    }*/
    
    //TODO when viewing own cards, don't show the buy buttons etc. use if sale.seller == current user
    
    _goldLabel.text = [NSString stringWithFormat:@"%d", [GameStore getCardCost:_cardView.cardModel]];
    _likesLabel.text = [NSString stringWithFormat:@"%d", [_cardPF[@"likes"] intValue]];
    
    _rarityTextLabel.textColor = [_cardView getRarityColor];
    _rarityTextLabel.text = [CardModel getRarityText:_cardView.cardModel.rarity];
    _creatorLabel.text = [NSString stringWithFormat:@"Creator: %@", self.cardView.cardModel.creatorName];
    _idLabel.text = [NSString stringWithFormat:@"No. %d", self.cardView.cardModel.idNumber];
    
    _buyHintLabel.text = @"";
    _likeHintLabel.text = @"";
    _reportHintLabel.text = @"";
    _editHintLabel.text = @"";
    
    int currentCardIndex = (int)[_cardsView.currentCards indexOfObject:_cardView.cardModel];
    if (currentCardIndex >= _cardsView.currentSales.count || currentCardIndex < 0)
    {
        //invalid index
        NSLog(@"ERROR: Invalid index for a card that's already loaded");
        [self closeCardInfoView]; //TODO maybe move this to parent function so cardview won't even pop up at all
        return;
    }
    
    [_buyButton removeFromSuperview];
    [_sellButton removeFromSuperview];
    [_cardInfoView addSubview:_likeButton];
    [_cardInfoView addSubview:_reportButton];
    //[_cardInfoView addSubview:_editButton];
    
    PFObject *salePF = _cardsView.currentSales[currentCardIndex];
    
    //cannot buy if already owns it, or not enough gold
    if ([UserModel getOwnedCard:cardModel])
    {
        _buyHintLabel.text = [NSString stringWithFormat:@"Sell for %d gold", [GameStore getCardSellPrice:cardModel]];
        [_cardInfoView addSubview:_sellButton];
    }
    else if ([userPF[@"gold"] intValue] < [GameStore getCardCost:cardModel])
    {
        _buyHintLabel.text = @"Not enough gold";
        [_cardInfoView addSubview:_buyButton];
        [_buyButton setEnabled:NO];
    }
    else if ([salePF[@"stock"] intValue] <= 0)
    {
        _buyHintLabel.text = @"Out of stock!";
        [_cardInfoView addSubview:_buyButton];
        [_buyButton setEnabled:NO];
    }
    else
    {
        [_cardInfoView addSubview:_buyButton];
        [_buyButton setEnabled:YES];
    }
    
    if ([UserModel getLikedCard:cardModel])
    {
        _likeHintLabel.text = @"Already liked";
        [_likeButton setEnabled:NO];
    }
    else if ([userPF[@"likes"] intValue] <= 0)
    {
        _likeHintLabel.text = @"Not enough likes";
        [_likeButton setEnabled:NO];
    }
    else
        [_likeButton setEnabled:YES];
    
    if ([UserModel getReportedCard:cardModel])
    {
        _reportHintLabel.text = @"Already reported";
        [_reportButton setEnabled:NO];
    }
    else
        [_reportButton setEnabled:YES];
    
    if ([UserModel getLikedCard:cardModel] && ![UserModel getEditedCard:cardModel])
    {
        [_editButton setEnabled:YES];
    }
    else
    {
        //_editHintLabel.text = @"Like it first";
        [_editButton setEnabled:NO];
    }
    
    //do not get the three buttons if is the card's creator
    if ([_cardView.cardModel.creator isEqualToString:userPF.objectId])
    {
        [_buyButton removeFromSuperview];
        [_editButton removeFromSuperview];
        [_sellButton removeFromSuperview];
        [_likeButton removeFromSuperview];
        [_reportButton removeFromSuperview];
        
        _buyHintLabel.text = @"";
        _likeHintLabel.text = @"";
        _reportHintLabel.text = @"";
        _editHintLabel.text = @"";
        
        [_cardInfoView addSubview: _restockButton];
        NSString *rarityUpdate = _cardView.cardModel.rarityUpdateAvailable;
        
        if([rarityUpdate isEqualToString:@"YES"])
        {
            [_cardInfoView addSubview: _bumpButton];
        }
        
        [_cardInfoView addSubview:_buyHintLabel];
        [_cardInfoView addSubview:_editHintLabel];
        
        //lazy
        _buyHintLabel.text = @"TODO gold";
        _editHintLabel.text = @"TODO gold";
        //TODO additional stuff in future, such as bumping to featured
    }
    else
    {
        [_restockButton removeFromSuperview];
        [_bumpButton removeFromSuperview];
    }
    
    NSString*tagString = @"Tags:\n";
    
    for (NSString*tag in _cardView.cardModel.tags)
        tagString = [NSString stringWithFormat:@"%@%@\n", tagString, tag];
    
    _cardTagsLabel.text = tagString;
    int cardTagsLabelX = _cardView.frame.size.width + 20;
    int cardTagsMaxHeight = SCREEN_HEIGHT - 220;
    _cardTagsLabel.frame = CGRectMake(cardTagsLabelX, 30, SCREEN_WIDTH-cardTagsLabelX-10, cardTagsMaxHeight);
    [_cardTagsLabel sizeToFit];
    if (_cardTagsLabel.frame.size.height > cardTagsMaxHeight)
    {
        _cardTagsLabel.frame = CGRectMake(_cardTagsLabel.frame.origin.x, _cardTagsLabel.frame.origin.y, _cardTagsLabel.frame.size.width, cardTagsMaxHeight);
    }
    
    if ([_cardPF[@"adminPhotoCheck"] intValue] == 0) {
        [_buyButton removeFromSuperview];
        [_reportButton removeFromSuperview];
        [_likeButton removeFromSuperview];
        [_cardInfoView addSubview:_approveButton];
        [_cardInfoView addSubview:_declineButton];
    }
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

-(void)updateBlankCardView
{
    int blankCards = 0;
    
    if (userPF[@"blankCards"] != nil)
        blankCards = [userPF[@"blankCards"] intValue];
    
    _remainingCardLabel.text = [NSString stringWithFormat:@"Remaining cards: %d",blankCards];
    
    if (blankCards > 0)
        [_createCardButton setEnabled:YES];
    else
        [_createCardButton setEnabled:NO];
}

-(void)openBlankCardView
{
    [self updateBlankCardView];
        
    [self.view insertSubview:_blankCardView belowSubview:_footerView];
    [_backButton setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _blankCardView.alpha = 1;
                         _backButton.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              _buyGoldView.alpha = 0;
                                          }completion:nil];
                     }];
}

-(void)blankCardBackButtonPressed
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _blankCardView.alpha = 0;
                         _backButton.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         [_backButton setUserInteractionEnabled:YES];
                         [_blankCardView removeFromSuperview];
                     }];
}

-(void)sellButtonPressed
{
    [self showActivityIndicatorWithBlock:^BOOL{
        int currentCardIndex = (int)[_cardsView.currentCards indexOfObject:_cardView.cardModel];
        
        if (currentCardIndex >= 0 && currentCardIndex < _cardsView.currentSales.count)
        {
            /*
            userGold += cost;
            if (userGold < 0)
                userGold = 0; //not suppose to happen anyways
            userPF[@"gold"] = @(userGold);
            
            BOOL succ = [UserModel setNotOwnedCard:_cardView.cardModel];
            
            if (!succ)
            {
                userGold -= cost;
                userPF[@"gold"] = @(userGold);
                return NO;
            }
            
            [UserModel removeOwnedCard:_cardView.cardModel.idNumber];
            
            [self animateGoldChange:cost];
            [self updateCardInfoView:_cardView.cardModel];
            [self updateFooterViews];
            
            //[userPF saveInBackground]; //saved by setOwnedCard
            */
            
            int cost = [GameStore getCardSellPrice:_cardView.cardModel];
            
            NSError*error;
            [PFCloud callFunction:@"sellCard" withParameters:@{
                                                               @"cardNumber" : @(_cardView.cardModel.idNumber),
                                                               @"cost" : @(cost)} error:&error];
            
            if (!error)
            {
                userGold += cost;
                [UserModel removeOwnedCard:_cardView.cardModel.idNumber];
                
                [self animateGoldChange:cost];
                
                [userPF fetch]; //can have error but it's not important
                
                [self updateCardInfoView:_cardView.cardModel];
                [self updateFooterViews];
            }
            else
                NSLog(@"%@", [error localizedDescription]);
            
            return YES;
        }
        else
        {
            NSLog(@"ERROR: FAILED TO FIND SALE IN ARRAY");
            return NO;
            //TODO
        }
    } loadingText:@"Processing..." failedText:@"Error selling card."];
}

-(void)approveButtonPressed
{
    [self showActivityIndicatorWithBlock:^BOOL{
        int currentCardIndex = (int)[_cardsView.currentCards indexOfObject:_cardView.cardModel];
        NSLog(@"Current Card Index: %d",currentCardIndex);
        if (currentCardIndex >= 0 && currentCardIndex < _cardsView.currentSales.count)
        {
            NSError*error;
            [PFCloud callFunction:@"approveCardImage" withParameters:@{
                                                               @"cardID" : _cardView.cardModel.cardPF.objectId} error:&error];
            
            if (!error)
            {
                [self closeCardInfoView];
                
                [_currentLoadedSales removeObjectAtIndex:currentCardIndex];
                [self updateFilter];
                
                [self updateFooterViews];
            }
            else
                NSLog(@"%@", [error localizedDescription]);
            
            return YES;
        }
        else
        {
            NSLog(@"ERROR: FAILED TO FIND SALE IN ARRAY");
            return NO;
            //TODO
        }
    } loadingText:@"Processing..." failedText:@"Error approving card image."];
}

- (void)declineButtonPressed
{
    [self showActivityIndicatorWithBlock:^BOOL{
        int currentCardIndex = (int)[_cardsView.currentCards indexOfObject:_cardView.cardModel];
        NSLog(@"Current Card Index: %d",currentCardIndex);
        if (currentCardIndex >= 0 && currentCardIndex < _cardsView.currentSales.count)
        {
            
            NSError*error;
            [PFCloud callFunction:@"declineCardImage" withParameters:@{
                                                                       @"cardID" : _cardView.cardModel.cardPF.objectId} error:&error];
            
            if (!error)
            {
                [self closeCardInfoView];
                [_currentLoadedSales removeObjectAtIndex:currentCardIndex];
                [self updateFilter];
                [self updateFooterViews];
            }
            else
                NSLog(@"%@", [error localizedDescription]);
            
            return YES;
        }
        else
        {
            NSLog(@"ERROR: FAILED TO FIND SALE IN ARRAY");
            return NO;
            //TODO
        }
    } loadingText:@"Processing..." failedText:@"Error declining card image."];
}

-(void)updateFooterViews
{
    _userCardLabel.text = [NSString stringWithFormat:@"%d", [userPF[@"blankCards"] intValue]];
    _userGoldLabel.text = [NSString stringWithFormat:@"%d", userGold];
    _userLikesLabel.text = [NSString stringWithFormat:@"%d", [userPF[@"likes"] intValue]];
}

-(void)buyButtonPressed
{
    [self showActivityIndicatorWithBlock:^BOOL{
        int currentCardIndex = (int)[_cardsView.currentCards indexOfObject:_cardView.cardModel];

        if (currentCardIndex >= 0 && currentCardIndex < _cardsView.currentSales.count)
        {
            PFObject *salePF = _cardsView.currentSales[currentCardIndex];
            NSError *error;
            [salePF refresh:&error];
            
            if (!error)
            {
                NSNumber *stockSize = salePF[@"stock"];
                
                if (stockSize > 0)
                {
                    /*
                    stockSize = @([stockSize intValue] - 1);
                    salePF[@"stock"] = stockSize;
                    
                    NSError*error;
                    
                    [salePF save:&error];
                    if (error)
                        return NO;
                    
                    int cost = [GameStore getCardCost:_cardView.cardModel];
                    
                    userGold -= cost;
                    if (userGold < 0)
                        userGold = 0; //not suppose to happen anyways
                    userPF[@"gold"] = @(userGold);
                    
                    [userAllCards addObject:_cardView.cardModel];
                    //[UserModel saveCard:_cardView.cardModel]; //old CD stuff
                    
                    BOOL succ = [UserModel setOwnedCard:_cardView.cardModel];
                    
                    if (!succ)
                    {
                        userGold += cost;
                        userPF[@"gold"] = @(userGold);
                        return NO;
                    }
                    
                    [self animateGoldChange:-cost];
                    
                    [self updateCardInfoView:_cardView.cardModel];
                    [self updateFooterViews];
                    
                    //[userPF saveInBackground]; //saved by setOwnedCard
                    */
                    
                    int cost = [GameStore getCardCost:_cardView.cardModel];
                    
                    [PFCloud callFunction:@"buyCard" withParameters:@{
                                                                       @"cardID" : _cardView.cardModel.cardPF.objectId,
                                                                       @"saleID" : salePF.objectId,
                                                                       @"cost" : @(cost)
                                                                    } error:&error];
                    
                    if (!error)
                    {
                        userGold -= cost;
                        [userAllCards addObject:_cardView.cardModel];
                        
                        [self animateGoldChange:-cost];
                        
                        //unimportant fetches
                        [userPF fetch];
                        [salePF fetch]; //stock has been updated
                        
                        [self updateCardInfoView:_cardView.cardModel];
                        [self updateFooterViews];
                        [self closeCardInfoView];
                    }
                    else
                        NSLog(@"%@", [error localizedDescription]);
                    
                    return YES;
                }
                else{
                    //TODO
                    NSLog(@"TODO: No stock left");
                    return NO;
                }
            }
            else
            {
                NSLog(@"ERROR: FAILED TO FIND SALE");
                return NO;
            }
        }
        else
        {
            NSLog(@"ERROR: FAILED TO FIND SALE IN ARRAY");
            return NO;
            //TODO
        }
    } loadingText:@"Processing..." failedText:@"Error purchasing card."];
}

-(void)likeButtonPressed
{
    [self showActivityIndicatorWithBlock:^BOOL{
        /*
        NSNumber *originalLikes = userPF[@"likes"];
        userPF[@"likes"] = @([userPF[@"likes"] intValue] - 1);
        
        BOOL succ = [UserModel setLikedCard:_cardView.cardModel];
        
        if (!succ)
        {
            userPF[@"likes"] = originalLikes;
            return NO;
        }
        
        [self updateFooterViews];
        
        _cardPF[@"likes"] = @([_cardPF[@"likes"]intValue] + 1);
        
        int currentCardIndex = [_cardsView.currentCards indexOfObject:_cardView.cardModel];
        PFObject *salePF = _cardsView.currentSales[currentCardIndex];
        salePF[@"likes"] = _cardPF[@"likes"];
        
        NSError*error;
        [salePF save:&error];
        
        if (error)
        {
            return NO;
        }
        
        int index = [_cardsView.currentCardsPF indexOfObject:_cardPF];
        [_cardsView.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
        _likesLabel.text = [NSString stringWithFormat:@"%d", [_cardPF[@"likes"] intValue]];
        
        //gain gold from liking a card TODO show a message
        int originalGold = userGold;
        userGold += LIKE_CARD_GOLD_GAIN;
        userPF[@"gold"] = @(userGold);
        
        [userPF save:&error];
        
        if (error)
        {
            userGold = originalGold;
            userPF[@"gold"] = @(userGold);
            return NO;
        }
        
        [self animateLikeChange:-1];
        [self animateGoldChange:LIKE_CARD_GOLD_GAIN];
        
        [self updateCardInfoView:_cardView.cardModel];
        [self updateFooterViews];
        */
        
        //used for updating client-side stuff
        int originalLikes = _cardView.cardModel.likes;
        
        int currentCardIndex = [_cardsView.currentCards indexOfObject:_cardView.cardModel];
        PFObject *salePF = _cardsView.currentSales[currentCardIndex];
        
        NSLog(@"%@",  userPF.objectId);
        
        NSError*error;
        [PFCloud callFunction:@"likeCard" withParameters:@{
                                                               @"cardID" : _cardView.cardModel.cardPF.objectId,
                                                               @"saleID" : salePF.objectId} error:&error];
        
        if (!error)
        {
            userGold += LIKE_CARD_GOLD_GAIN;
            
            //play animation
            [self animateLikeChange:-1];
            [self animateGoldChange:LIKE_CARD_GOLD_GAIN];
            
            int currentCardIndex = [_cardsView.currentCards indexOfObject:_cardView.cardModel];
            PFObject *salePF = _cardsView.currentSales[currentCardIndex];
            
            //these fetches failing is not critical, only client will get wrong data
            [salePF fetch];
            [_cardPF fetch];
            [userPF fetch];
            
            int index = [_cardsView.currentCardsPF indexOfObject:_cardPF];
            [_cardsView.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
            _likesLabel.text = [NSString stringWithFormat:@"%d", [_cardPF[@"likes"] intValue]];
            
            [self updateCardInfoView:_cardView.cardModel];
            
            [self updateFooterViews];
        }
        else
            NSLog(@"%@", [error localizedDescription]);
        
        return error == nil;
        
    } loadingText:@"Processing..." failedText:@"Error liking card."];
}



-(void)reportButtonPressed
{
    [self showActivityIndicatorWithBlock:^BOOL{
        
        int currentCardIndex = [_cardsView.currentCards indexOfObject:_cardView.cardModel];
        PFObject *salePF = _cardsView.currentSales[currentCardIndex];

        
        NSLog(@"%@",  userPF.objectId);
        
        NSError*error;
        [PFCloud callFunction:@"reportCard" withParameters:@{
                                                             @"cardID" : _cardView.cardModel.cardPF.objectId,
                                                             @"saleID" : salePF.objectId} error:&error];
        
        if (!error)
        {
            [_reportButton removeFromSuperview];
            
            int currentCardIndex = [_cardsView.currentCards indexOfObject:_cardView.cardModel];
            PFObject *salePF = _cardsView.currentSales[currentCardIndex];
            
            //these fetches failing is not critical, only client will get wrong data
            [salePF fetch];
            [_cardPF fetch];
            [userPF fetch];
            
            int index = [_cardsView.currentCardsPF indexOfObject:_cardPF];
            [_cardsView.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
            _cardView.cardModel.userReported = true;
            [self updateCardInfoView:_cardView.cardModel];
        }
        else
            NSLog(@"%@", [error localizedDescription]);
        [self updateFilter];
        return error == nil;
        
    } loadingText:@"Processing..." failedText:@"Error reporting card."];

}

-(void)animateGoldChange:(int)change
{
    CGPoint iconStartPoint = _userGoldIcon.center;
    UIImageView* goldButton = [[UIImageView alloc] initWithImage:GOLD_ICON_IMAGE];
    goldButton.frame = CGRectMake(0, 0, 38, 38);
    goldButton.center = iconStartPoint;
    [_footerView addSubview:goldButton];
    
    StrokedLabel *goldLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0, 155, 40)];
    goldLabel.textAlignment = NSTextAlignmentCenter;
    if (change >= 0)
        goldLabel.textColor = [UIColor whiteColor];
    else
        goldLabel.textColor = [UIColor redColor];
    goldLabel.font = [UIFont fontWithName:cardMainFont size:24];
    goldLabel.strokeOn = YES;
    goldLabel.strokeThickness = 3;
    goldLabel.strokeColour = [UIColor blackColor];
    goldLabel.text = [NSString stringWithFormat:@"%@%d", change >= 0 ? @"+" : @"", change];
    goldLabel.center = iconStartPoint;
    [_footerView addSubview:goldLabel];
    
    [UIView animateWithDuration:2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         goldButton.center = CGPointMake(iconStartPoint.x, iconStartPoint.y-75);
                         goldButton.alpha = 0;
                         goldLabel.center = CGPointMake(iconStartPoint.x, iconStartPoint.y-75);
                         goldLabel.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [goldButton removeFromSuperview];
                         [goldLabel removeFromSuperview];
                     }];
}

-(void)animateLikeChange:(int)change
{
    CGPoint iconStartPoint = _userLikesIcon.center;
    UIImageView* likeButton = [[UIImageView alloc] initWithImage:LIKE_ICON_IMAGE];
    likeButton.frame = CGRectMake(0, 0, 38, 38);
    likeButton.center = iconStartPoint;
    [_footerView addSubview:likeButton];
    
    StrokedLabel *likesLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0, 155, 40)];
    likesLabel.textAlignment = NSTextAlignmentCenter;
    if (change >= 0)
        likesLabel.textColor = [UIColor whiteColor];
    else
        likesLabel.textColor = [UIColor redColor];
    likesLabel.font = [UIFont fontWithName:cardMainFont size:24];
    likesLabel.strokeOn = YES;
    likesLabel.strokeThickness = 3;
    likesLabel.strokeColour = [UIColor blackColor];
    likesLabel.text = [NSString stringWithFormat:@"%@%d", change >= 0 ? @"+" : @"", change];
    likesLabel.center = iconStartPoint;
    [_footerView addSubview:likesLabel];
    
    [UIView animateWithDuration:2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         likeButton.center = CGPointMake(iconStartPoint.x, iconStartPoint.y-75);
                         likeButton.alpha = 0;
                         likesLabel.center = CGPointMake(iconStartPoint.x, iconStartPoint.y-75);
                         likesLabel.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [likeButton removeFromSuperview];
                         [likesLabel removeFromSuperview];
                     }];
}

-(void)editButtonPressed
{
    CardModel*cardCopy = [[CardModel alloc] initWithCardModel:_cardView.cardModel];
    
    CardEditorViewController *cevc = [[CardEditorViewController alloc] initWithMode:cardEditorModeRarityUpdate WithCard:cardCopy];
    cevc.delegate = self;
    
    
    [self presentViewController:cevc animated:YES completion:^{
        //processing done in cevc
        [self updateCardInfoView:_cardView.cardModel];
    }];
}

-(void)restockButtonPressed
{
    //TODO
}

-(void)bumpButtonPressed
{
    //TODO
    [self editButtonPressed];
    
}

-(void)applyFiltersToQuery:(PFQuery*)salesQuery
{
    _currentQueryLocation = 0;
    [salesQuery includeKey:@"card"];
    
    if (_storeCategoryTab == storeCategoryFeatured)
    {
        //[salesQuery orderByDescending:@"likes"];
        [salesQuery orderByDescending:@"bumpedAt,createdAt"];
        //TODO
    }
    else if (_storeCategoryTab == storeCategoryNewest)
    {
        [salesQuery orderByDescending:@"createdAt"];
    }
    else if (_storeCategoryTab == storeCategoryPopular)
    {
        [salesQuery orderByDescending:@"likes"];
    }
    else if (_storeCategoryTab == storeCategoryOwned)
    {
        NSArray*allOwnedCards = [UserModel getAllOwnedCardID];
        [salesQuery whereKey:@"cardID" containedIn:allOwnedCards];
        [salesQuery orderByDescending:@"createdAt"];
    }
    else if (_storeCategoryTab == storeCategoryDesigned)
    {
        [salesQuery whereKey:@"seller" equalTo:userPF.objectId];
        [salesQuery orderByDescending:@"createdAt"];
    }
}

//initial search
-(void)loadCards
{
    _scrolledToDatabaseEnd = NO;
    _searchResult.text = @"Searching...";
    cardStoreQueryID++;
    //clear all cells
    _cardsView.currentSales = [NSMutableArray array];
    _cardsView.currentCards = [NSMutableArray array];
    _cardsView.currentCardsPF = [NSMutableArray array];
    [self.cardsView reloadInputViews];
    [self.cardsView.collectionView reloadData];
    
    if (_storeCategoryTab == 0) {
        PFQuery *featuredCardQuery = [PFQuery queryWithClassName:@"Card"];
        
        [featuredCardQuery setLimit:1];
        
        [featuredCardQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                //load all sales without the cards
                _currentLoadedSales = [NSMutableArray arrayWithArray: objects];
                [self.cardsView setIsFeaturedCard:YES];
                [self updateFilter];
                
            }
            else
            {
                _searchResult.text = @"Error while searching.";
                NSLog(@"ERROR SEARCHING SALES");
            }
        }];
    }else{
        NSLog(@"load card start");
        PFQuery *salesQuery = [PFQuery queryWithClassName:@"Sale"];
        salesQuery.limit = STORE_INITIAL_LOAD_AMOUNT;
        
        [self applyFiltersToQuery:salesQuery];
        
        PFQuery *cardQuery = [PFQuery queryWithClassName:@"Card"];
        [cardQuery whereKey:@"adminPhotoCheck" equalTo:@(1)];
        [salesQuery     whereKey:@"card" matchesQuery:cardQuery];
        
        [salesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                //load all sales without the cards
                _currentLoadedSales = [NSMutableArray arrayWithArray: objects];
                
                [self.cardsView setIsFeaturedCard:NO];
                
                [self updateFilter];
            }
            else
            {
                _searchResult.text = @"Error while searching.";
                NSLog(@"ERROR SEARCHING SALES");
            }
        }];
        
        PFQuery *pendingCardQuery = [PFQuery queryWithClassName:@"Card"];
        [pendingCardQuery whereKey:@"adminPhotoCheck" equalTo:@(0)];
        [pendingCardQuery orderByDescending:@"createdAt"];
        
        [pendingCardQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                //load all sales without the cards
                _currentPendingImageCards = [NSMutableArray arrayWithArray: objects];
                
            }
            else
            {
                _searchResult.text = @"Error while searching.";
                NSLog(@"ERROR SEARCHING SALES");
            }
        }];
    }

}

//TODO: this and updateFilterToExistingSearchToObjects are buggy as crap and needs to be fixed eventually, but less terrible when store increment is set to 16. Often has duplication when set to 2 and has filters on
-(void)loadMoreCardsFromBottom
{
    if (_scrolledToDatabaseEnd) //nothing to load
        return;
    
    [self performBlockInBackground:^{
        while (_loadingMoreCards) //already loading
            sleep(0.1);
        
        _loadingMoreCards = YES;
        
        //clear all cells
        NSLog(@"load more card start");
        PFQuery *salesQuery = [PFQuery queryWithClassName:@"Sale"];
        salesQuery.limit = STORE_ADDITIONAL_INCREMENT;
        salesQuery.skip = _currentQueryLocation + _currentLoadedSales.count;
        NSLog(@"SKIPPING: %d",salesQuery.skip);
        [self applyFiltersToQuery:salesQuery];
        
        PFQuery *cardQuery = [PFQuery queryWithClassName:@"Card"];
        [cardQuery whereKey:@"adminPhotoCheck" equalTo:@(1)];
        [salesQuery     whereKey:@"card" matchesQuery:cardQuery];
        
        if (_isSearching)
            [self applySearchFiltersToQuery:salesQuery];
        
        [salesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                if (objects.count == 0)
                {
                    _scrolledToDatabaseEnd = YES; //no more to search
                    if (_cardsView.currentSales.count == 0)
                        _searchResult.text = @"Found no match.";
                    else
                        _searchResult.text = @"";
                }
                else
                {
                    //load all sales without the cards
                    [_currentLoadedSales addObjectsFromArray:objects];
                    NSLog(@"CURRENT TOTAL: %d",_currentLoadedSales.count);
                    
                    [self updateFilterToExistingSearchToObjects:objects];
                }
            }
            else
            {
                _searchResult.text = @"Error while searching.";
                NSLog(@"ERROR SEARCHING SALES");
            }
            
            _loadingMoreCards = NO; //done
        }];
    }];
    
}


-(void)updateFilter
{
    int originalCount = _cardsView.currentSales.count;
    
    _searchResult.text = @"Searching...";
    cardStoreQueryID++;
    _cardsView.currentSales = [NSMutableArray array];
    
    for (PFObject *salePF in _currentLoadedSales)
    {
        PFObject *cardPF = salePF[@"card"];
        
        BOOL shouldFilter = [self shouldFilterCardPF:cardPF withSalePF:salePF];
        
        NSLog(@"shouldFilter: %d %d", shouldFilter, [_cardsView.currentSales containsObject:salePF]);
        
        if (shouldFilter && ![_cardsView.currentSales containsObject:salePF])
            [_cardsView.currentSales addObject:salePF];
       
        if ([self.cardsView isFeaturedCard]) {
            for (int i =0; i <3; i++) {
                [_cardsView.currentSales addObject:salePF];
            }
        }
    }
    
    _cardsView.currentCards = [NSMutableArray arrayWithCapacity:_cardsView.currentSales.count];
    _cardsView.currentCardsPF = [NSMutableArray arrayWithCapacity:_cardsView.currentSales.count];
    
    for (int i = 0; i < _cardsView.currentSales.count; i++)
        [_cardsView.currentCards addObject:[NSNull null]];
    for (int i = 0; i < _cardsView.currentSales.count; i++)
        [_cardsView.currentCardsPF addObject:[NSNull null]];
    
    [self.cardsView.loadingCells removeAllObjects];
    [self.cardsView reloadInputViews];
    [self.cardsView.collectionView reloadData];
    
    NSLog(@"currentCards %d", _cardsView.currentCards.count);
    
    /*
     if (_cardsView.currentCards.count == 0)
     _searchResult.text = @"Found no match.";
     else
     _searchResult.text = @"";
     */
    
    if (originalCount == _cardsView.currentSales.count)
        [self loadMoreCardsFromBottom];
    else
    {
        if (_cardsView.currentSales.count == 0)
            _searchResult.text = @"Found no match.";
        else
            _searchResult.text = @"";
    }
    
}

-(void)updateFilterToExistingSearchToObjects:(NSArray*)salePFArray
{
    int oldSaleSize = _cardsView.currentSales.count;
    
    cardStoreQueryID++;
    NSMutableArray *updateArray = [NSMutableArray arrayWithCapacity:salePFArray.count];
    for (int i = 0; i < salePFArray.count; i++)
    {
        PFObject *salePF = salePFArray[i];
        PFObject *cardPF = salePF[@"card"];
        
        BOOL shouldInclude = [self shouldFilterCardPF:cardPF withSalePF:salePF];
        
        if (shouldInclude && ![_cardsView.currentSales containsObject:salePF])
        {
            [_cardsView.currentSales addObject:salePF];
            //NSLog(@"%d", _cardsView.currentSales.count-1);
            [updateArray addObject: [NSIndexPath indexPathForRow:_cardsView.currentSales.count-1 inSection:0]];
        }
    }
    
    for (int i = 0; i < salePFArray.count; i++)
        [_cardsView.currentCards addObject:[NSNull null]];
    for (int i = 0; i < salePFArray.count; i++)
        [_cardsView.currentCardsPF addObject:[NSNull null]];
    
    if (updateArray.count > 0)
    {
        //if the first one is 0 then it crashes
        if ([updateArray[0] row] == 0)
            [self.cardsView.collectionView reloadData];
        else
            [self.cardsView.collectionView insertItemsAtIndexPaths:updateArray];
    }
    
    //[self.cardsView reloadInputViews];
    /*
     @try {
     [self.cardsView.collectionView insertItemsAtIndexPaths:updateArray];
     }
     @catch (NSException *exception) {
     NSLog(@"%@", exception);
     }*/
    
    //if didn't load any more with this configuration, keep loading
    if (oldSaleSize == _cardsView.currentSales.count && !_scrolledToDatabaseEnd)
    {
        _searchResult.text = @"";
        NSLog(@"keep loading");
        [self loadMoreCardsFromBottom];
    }
    else if (_cardsView.currentSales.count == 0)
    {
        _searchResult.text = @"Found no match.";
    }
    else
        _searchResult.text = @"";
}


-(void)searchCards
{
    _searchResult.text = @"Searching...";
    cardStoreQueryID++;
    //clear all cells
    _cardsView.currentSales = [NSMutableArray array];
    _cardsView.currentCards = [NSMutableArray array];
    _cardsView.currentCardsPF = [NSMutableArray array];
    [self.cardsView reloadInputViews];
    [self.cardsView.collectionView reloadData];
    
    NSLog(@"load card start");
    PFQuery *salesQuery = [PFQuery queryWithClassName:@"Sale"];
    
    [self applyFiltersToQuery:salesQuery];
    
    [self applySearchFiltersToQuery:salesQuery];
    
    PFQuery *cardQuery = [PFQuery queryWithClassName:@"Card"];
    [cardQuery whereKey:@"adminPhotoCheck" equalTo:@(1)];
    [salesQuery     whereKey:@"card" matchesQuery:cardQuery];
    
    [salesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            //load all sales without the cards
            _currentLoadedSales = [NSMutableArray arrayWithArray: objects];
            NSLog(@"%d", _currentLoadedSales.count);
            
            [self updateFilter];
        }
        else
        {
            _searchResult.text = @"Error while searching.";
            NSLog(@"ERROR SEARCHING SALES");
        }
    }];
}

-(void)applySearchFiltersToQuery:(PFQuery *)query
{
    //search filters
    NSString*nameSearch = _searchNameField.text;
    NSString*tagsSearch = _searchTagsField.text;
    NSString*idSearch = _searchIDField.text;
    
    if (nameSearch.length > 0)
    {
        NSArray*names = [nameSearch componentsSeparatedByString:@" "];
        
        for (NSString*string in names)
        {
            if (string.length > 0){
                [query whereKey:@"name" matchesRegex:string modifiers:@"i"];
            }
        }
    }
    
    if (tagsSearch.length > 0)
    {
        NSArray*tags = [tagsSearch componentsSeparatedByString:@" "];
        
        for (NSString*string in tags)
        {
            NSString *lowerString = [string lowercaseString];
            [query whereKey:@"tags" equalTo:lowerString];
        }
    }
    
    if (idSearch.length > 0)
    {
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        NSNumber * idNumber = [formatter numberFromString:idSearch];
        
        if (idNumber != nil)
        {
            query.limit = 1;
            [query whereKey:@"cardID" equalTo:idNumber];
        }
        //don't search if invalid
        else
            query.limit = 0;
    }

}

-(void)searchButtonPressed
{
    //close keyboard
    [_searchNameField resignFirstResponder];
    [_searchTagsField resignFirstResponder];
    [_searchIDField resignFirstResponder];
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                     }
                     completion:nil];
    
    //close search view
    [self setSearchViewState:NO];
    
    _isSearching = YES;
    
    [self searchCards];
}

-(void)keyboardOnScreen:(NSNotification *)notification
{
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

-(void)searchFieldBegan
{
    int height = keyboardSize.height;
    
    [UIView animateWithDuration:0.4
                          delay:0.05
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.frame = CGRectMake(0,-height, SCREEN_WIDTH, SCREEN_HEIGHT);
                     }
                     completion:nil];
}

-(void)searchFieldFinished
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                     }
                     completion:nil];
    return NO;
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

-(void)tapRegistered
{
    [_searchNameField resignFirstResponder];
    [_searchTagsField resignFirstResponder];
    [_searchIDField resignFirstResponder];
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                     }
                     completion:nil];
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

-(void)storeScrolledToEnd
{
    //[self loadMoreCardsFromBottom];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)performBlockInBackground:(void (^)())block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        block();
    });
}

- (BOOL)prefersStatusBarHidden {return YES;}

-(void)viewDidAppear:(BOOL) animated{
    [self getIAPData];
}

- (void)getIAPData {
    _products = nil;
    
    [[PickIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            //[self setPricesAndValues];
            
            //[HUD hide:YES];
            
        }
        else
        {
            NSLog(@"failure on get iap data");
            
        }
        
    }];
}

- (void)cardUpdated:(CardModel *)card;
{
    int indexCounter = 0;
    for(CardModel* eachcard in _cardsView.currentCards)
    {
    
        if(eachcard.idNumber == card.idNumber)
        {
            break;
        }
        else
        {
            indexCounter = indexCounter+1;
        }
        
        
    }
    [_cardsView.currentCards replaceObjectAtIndex:indexCounter withObject:card];
    
    [self updateCardInfoView:card];  
    [self.cardsView.loadingCells removeAllObjects];
    [self.cardsView reloadInputViews];
    [self.cardsView.collectionView reloadData];
    
    
}

@end
