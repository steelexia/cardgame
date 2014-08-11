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
        
        _storeCategoryTab = storeCategoryFeatured;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
    _headerView = [[UIView alloc]initWithFrame:CGRectMake(0,0,SCREEN_WIDTH, 60)];
    //_headerView.backgroundColor = [UIColor redColor];
    
    _footerView = [[UIView alloc]initWithFrame:CGRectMake(0,SCREEN_HEIGHT-40,SCREEN_WIDTH, 40)];
    _footerView.backgroundColor = [UIColor whiteColor];

    
    _cardsView = [[StoreCardsCollectionView alloc] initWithFrame:CGRectMake(0, _headerView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-_headerView.frame.size.height-_footerView.frame.size.height)];
    
    _cardsView.backgroundColor = COLOUR_INTERFACE_BLUE;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_cardsView];
    
    [self.view addSubview:_headerView];
    [self.view addSubview:_footerView];
    
    //------------------footer views------------------//
    
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, 46, 32)];
    [self.backButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [_footerView addSubview:self.backButton];
    
    UIImageView* userGoldIcon = [[UIImageView alloc] initWithImage:GOLD_ICON_IMAGE];
    userGoldIcon.frame = CGRectMake(0, 0, 38, 38);
    userGoldIcon.center = CGPointMake(SCREEN_WIDTH-40 ,20);
    [_footerView addSubview:userGoldIcon];
    
    _userGoldLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 155, 40)];
    _userGoldLabel.textAlignment = NSTextAlignmentCenter;
    _userGoldLabel.textColor = [UIColor whiteColor];
    _userGoldLabel.font = [UIFont fontWithName:cardMainFont size:20];
    _userGoldLabel.text = [NSString stringWithFormat:@"%d", userGold];
    _userGoldLabel.strokeOn = YES;
    _userGoldLabel.strokeThickness = 3;
    _userGoldLabel.strokeColour = [UIColor blackColor];
    _userGoldLabel.center = CGPointMake(SCREEN_WIDTH-40, 20);
    [_footerView addSubview:_userGoldLabel];
    
    UIImageView* userLikesIcon = [[UIImageView alloc] initWithImage:LIKE_ICON_IMAGE];
    userLikesIcon.frame = CGRectMake(0, 0, 38, 38);
    userLikesIcon.center = CGPointMake(SCREEN_WIDTH-100 ,20);
    [_footerView addSubview:userLikesIcon];
    
    _userLikesLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0, 155, 40)];
    _userLikesLabel.textAlignment = NSTextAlignmentCenter;
    _userLikesLabel.textColor = [UIColor whiteColor];
    _userLikesLabel.font = [UIFont fontWithName:cardMainFont size:20];
    _userLikesLabel.text = [NSString stringWithFormat:@"%d", [userPF[@"likes"] intValue]];
    _userLikesLabel.strokeOn = YES;
    _userLikesLabel.strokeThickness = 3;
    _userLikesLabel.strokeColour = [UIColor blackColor];
    _userLikesLabel.center = CGPointMake(SCREEN_WIDTH-100, 20);
    [_footerView addSubview:_userLikesLabel];
    
    //-----------------Card info views----------------//
    _cardInfoView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    _darkFilter = [[UIView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH, SCREEN_HEIGHT-40)];
    _darkFilter.backgroundColor = [[UIColor alloc]initWithHue:0 saturation:0 brightness:0 alpha:0.8];
    [_darkFilter setUserInteractionEnabled:YES]; //blocks all interaction behind it
    [_cardInfoView addSubview:_darkFilter];
    
    _buyButton = [[UIButton alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT - 125, 80, 60)];
    [_buyButton setImage:[UIImage imageNamed:@"buy_button"] forState:UIControlStateNormal];
    [_buyButton setImage:[UIImage imageNamed:@"buy_button_gray"] forState:UIControlStateDisabled];
    [_buyButton addTarget:self action:@selector(buyButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_cardInfoView addSubview:_buyButton];
    
    _buyHintLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    _buyHintLabel.textColor = [UIColor whiteColor];
    _buyHintLabel.font = [UIFont fontWithName:cardMainFont size:14];
    _buyHintLabel.textAlignment = NSTextAlignmentCenter;
    _buyHintLabel.strokeOn = YES;
    _buyHintLabel.strokeThickness = 2;
    _buyHintLabel.strokeColour = [UIColor blackColor];
    _buyHintLabel.center = CGPointMake(60, SCREEN_HEIGHT-55);
    [_cardInfoView addSubview:_buyHintLabel];
    
    _editButton = [[UIButton alloc] initWithFrame:CGRectMake(120, SCREEN_HEIGHT - 125, 80, 60)];
    [_editButton setImage:[UIImage imageNamed:@"edit_button"] forState:UIControlStateNormal];
    [_editButton setImage:[UIImage imageNamed:@"edit_button_gray"] forState:UIControlStateDisabled];
    [_editButton addTarget:self action:@selector(editButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_cardInfoView addSubview:_editButton];
    
    _editHintLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    _editHintLabel.textColor = [UIColor whiteColor];
    _editHintLabel.font = [UIFont fontWithName:cardMainFont size:14];
    _editHintLabel.textAlignment = NSTextAlignmentCenter;
    _editHintLabel.strokeOn = YES;
    _editHintLabel.strokeThickness = 2;
    _editHintLabel.strokeColour = [UIColor blackColor];
    _editHintLabel.center = CGPointMake(160, SCREEN_HEIGHT-55);
    [_cardInfoView addSubview:_editHintLabel];
    
    _likeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-20-80, SCREEN_HEIGHT - 125, 80, 60)];
    [_likeButton setImage:[UIImage imageNamed:@"like_button"] forState:UIControlStateNormal];
    [_likeButton setImage:[UIImage imageNamed:@"like_button_gray"] forState:UIControlStateDisabled];
    [_likeButton addTarget:self action:@selector(likeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_cardInfoView addSubview:_likeButton];
    
    _likeHintLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    _likeHintLabel.textColor = [UIColor whiteColor];
    _likeHintLabel.font = [UIFont fontWithName:cardMainFont size:14];
    _likeHintLabel.textAlignment = NSTextAlignmentCenter;
    _likeHintLabel.strokeOn = YES;
    _likeHintLabel.strokeThickness = 2;
    _likeHintLabel.strokeColour = [UIColor blackColor];
    _likeHintLabel.center = CGPointMake(SCREEN_WIDTH-60, SCREEN_HEIGHT-55);
    [_cardInfoView addSubview:_likeHintLabel];
    
    UIImageView* goldIcon = [[UIImageView alloc] initWithImage:GOLD_ICON_IMAGE];
    goldIcon.frame = CGRectMake(0, 0, 50, 50);
    goldIcon.center = CGPointMake(110 ,SCREEN_HEIGHT-168);
    [_cardInfoView addSubview:goldIcon];
    
    _goldLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    _goldLabel.textAlignment = NSTextAlignmentCenter;
    _goldLabel.textColor = [UIColor whiteColor];
    _goldLabel.font = [UIFont fontWithName:cardMainFont size:30];
    [_goldLabel setMinimumScaleFactor:10/30];
    _goldLabel.adjustsFontSizeToFitWidth = YES;
    _goldLabel.strokeOn = YES;
    _goldLabel.strokeThickness = 5;
    _goldLabel.strokeColour = [UIColor blackColor];
    _goldLabel.center = CGPointMake(110, SCREEN_HEIGHT-148);
    [_cardInfoView addSubview:_goldLabel];
    
    UIImageView* likesIcon = [[UIImageView alloc] initWithImage:LIKE_ICON_IMAGE];
    likesIcon.frame = CGRectMake(0, 0, 50, 50);
    likesIcon.center = CGPointMake(50 ,SCREEN_HEIGHT-168);
    [_cardInfoView addSubview:likesIcon];
    
    _likesLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0, 60, 40)];
    _likesLabel.textAlignment = NSTextAlignmentCenter;
    _likesLabel.textColor = [UIColor whiteColor];
    _likesLabel.font = [UIFont fontWithName:cardMainFont size:30];
    [_likesLabel setMinimumScaleFactor:10/30];
    _likesLabel.adjustsFontSizeToFitWidth = YES;
    _likesLabel.strokeOn = YES;
    _likesLabel.strokeThickness = 5;
    _likesLabel.strokeColour = [UIColor blackColor];
    _likesLabel.center = CGPointMake(50, SCREEN_HEIGHT-148);
    [_cardInfoView addSubview:_likesLabel];
    
    _rarityLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(145, SCREEN_HEIGHT-200, 150, 40)];
    _rarityLabel.textAlignment = NSTextAlignmentLeft;
    _rarityLabel.textColor = [UIColor whiteColor];
    _rarityLabel.font = [UIFont fontWithName:cardMainFont size:18];
    _rarityLabel.strokeOn = YES;
    _rarityLabel.strokeThickness = 3;
    _rarityLabel.strokeColour = [UIColor blackColor];
    _rarityLabel.text = @"Rarity:";
    [_cardInfoView addSubview:_rarityLabel];
    
    _rarityTextLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(198, SCREEN_HEIGHT-200, 150, 40)];
    _rarityTextLabel.textAlignment = NSTextAlignmentLeft;
    _rarityTextLabel.font = [UIFont fontWithName:cardMainFont size:18];
    _rarityTextLabel.strokeOn = YES;
    _rarityTextLabel.strokeThickness = 3;
    _rarityTextLabel.strokeColour = [UIColor blackColor];
    [_cardInfoView addSubview:_rarityTextLabel];
    
    _creatorLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(145, SCREEN_HEIGHT-180, 150, 40)];
    _creatorLabel.textAlignment = NSTextAlignmentLeft;
    _creatorLabel.textColor = [UIColor whiteColor];
    _creatorLabel.font = [UIFont fontWithName:cardMainFont size:18];
    _creatorLabel.strokeOn = YES;
    _creatorLabel.strokeThickness = 3;
    _creatorLabel.strokeColour = [UIColor blackColor];
    [_cardInfoView addSubview:_creatorLabel];
    
    _idLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(145, SCREEN_HEIGHT-160, 150, 40)];
    _idLabel.textAlignment = NSTextAlignmentLeft;
    _idLabel.textColor = [UIColor whiteColor];
    _idLabel.font = [UIFont fontWithName:cardMainFont size:18];
    _idLabel.strokeOn = YES;
    _idLabel.strokeThickness = 3;
    _idLabel.strokeColour = [UIColor blackColor];
    [_cardInfoView addSubview:_idLabel];
    
    _cardTagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _cardTagsLabel.textColor = [UIColor whiteColor];
    _cardTagsLabel.font = [UIFont fontWithName:cardMainFont size:16];
    _cardTagsLabel.numberOfLines = 0;
    _cardTagsLabel.textAlignment = NSTextAlignmentLeft;
    [_cardTagsLabel setUserInteractionEnabled:YES];
    _cardTagsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_cardInfoView addSubview:_cardTagsLabel];
    
    //---------------filter buttons------------------//
    _filterView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-40, self.view.bounds.size.width, 250)];
    [self.view insertSubview:_filterView aboveSubview:_cardsView];
    [_filterView setUserInteractionEnabled:YES];
    [_filterView setBackgroundColor:[UIColor whiteColor]];
    
    _filterToggleButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-40, SCREEN_HEIGHT-40-40, 80, 40)];
    [_filterToggleButton setImage:[UIImage imageNamed:@"filter_toggle_button"] forState:UIControlStateNormal];
    [_filterToggleButton addTarget:self action:@selector(filterToggleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:_filterToggleButton aboveSubview:_cardsView];
    
    _likedButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,90,25)];
    [_likedButton setImage:[UIImage imageNamed:@"filter_button"] forState:UIControlStateNormal];
    [_likedButton addTarget:self action:@selector(likedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    _likedButton.center = CGPointMake(60, 60);
    [_filterView addSubview:_likedButton];
    UILabel*likedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 90, 25)];
    likedLabel.textAlignment = NSTextAlignmentCenter;
    likedLabel.textColor = [UIColor whiteColor];
    likedLabel.backgroundColor = [UIColor clearColor];
    likedLabel.font = [UIFont fontWithName:cardMainFont size:16];
    likedLabel.text = @"Hide liked";
    [_likedButton addSubview:likedLabel];
    _likedButton.alpha = 0.4;
    
    _ownedButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,90,25)];
    [_ownedButton setImage:[UIImage imageNamed:@"filter_button"] forState:UIControlStateNormal];
    [_ownedButton addTarget:self action:@selector(ownedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    _ownedButton.center = CGPointMake(60, 88);
    [_filterView addSubview:_ownedButton];
    UILabel*ownedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 90, 25)];
    ownedLabel.textAlignment = NSTextAlignmentCenter;
    ownedLabel.textColor = [UIColor whiteColor];
    ownedLabel.backgroundColor = [UIColor clearColor];
    ownedLabel.font = [UIFont fontWithName:cardMainFont size:16];
    ownedLabel.text = @"Hide bought";
    [_ownedButton addSubview:ownedLabel];
    _ownedButton.alpha = 0.4;
    
    _stockedButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,90,25)];
    [_stockedButton setImage:[UIImage imageNamed:@"filter_button"] forState:UIControlStateNormal];
    [_stockedButton addTarget:self action:@selector(stockButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    _stockedButton.center = CGPointMake(60, 116);
    [_filterView addSubview:_stockedButton];
    UILabel*stockedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 90, 25)];
    stockedLabel.textAlignment = NSTextAlignmentCenter;
    stockedLabel.textColor = [UIColor whiteColor];
    stockedLabel.backgroundColor = [UIColor clearColor];
    stockedLabel.font = [UIFont fontWithName:cardMainFont size:16];
    stockedLabel.text = @"Hide 0 stock";
    [_stockedButton addSubview:stockedLabel];
    _stockedButton.alpha = 0.4;
    
    //deckTagsButton
    
    //cost buttons
    CGPoint costFilterStartPoint = CGPointMake(20, 20);
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
    CGPoint rarityFilterStartPoint = CGPointMake(160, 60);
    _rarityFilterButtons = [NSMutableArray arrayWithCapacity:cardRarityLegendary+1];
    for (int i = 0; i <= cardRarityLegendary; i++)
    {
        UIButton*rarityFilterButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,90,25)];
        [rarityFilterButton setImage:[UIImage imageNamed:@"filter_button"] forState:UIControlStateNormal];
        [rarityFilterButton addTarget:self action:@selector(rarityFilterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        rarityFilterButton.center = CGPointMake(rarityFilterStartPoint.x, rarityFilterStartPoint.y + i*28);
        
        [_filterView addSubview:rarityFilterButton];
        
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
        
        [_rarityFilterButtons addObject:rarityFilterButton];
    }
    
    //element buttons
    CGPoint elementFilterStartPoint = CGPointMake(260, 60);
    _elementFilterButtons = [NSMutableArray arrayWithCapacity:7];
    for (int i = 0; i < 7; i++)
    {
        UIButton*elementFilterButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,90,25)];
        [elementFilterButton setImage:[UIImage imageNamed:@"filter_button"] forState:UIControlStateNormal];
        [elementFilterButton addTarget:self action:@selector(elementFilterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        elementFilterButton.center = CGPointMake(elementFilterStartPoint.x, elementFilterStartPoint.y + i*28);
        
        [_filterView addSubview:elementFilterButton];
        
        StrokedLabel*elementLabel = [[StrokedLabel alloc]initWithFrame:CGRectMake(0, 0, 90, 25)];
        elementLabel.textAlignment = NSTextAlignmentCenter;
        elementLabel.textColor = [UIColor whiteColor];
        elementLabel.backgroundColor = [UIColor clearColor];
        elementLabel.font = [UIFont fontWithName:cardMainFont size:18];
        //elementLabel.strokeOn = YES;
        elementLabel.strokeColour = [UIColor blackColor];
        elementLabel.strokeThickness = 3;
        elementLabel.text = [CardModel elementToString:i];
        [elementFilterButton addSubview:elementLabel];
        //costLabel.center = costFilterButton.center;
        
        [_elementFilterButtons addObject:elementFilterButton];
    }
    
    //--------------category tabs---------------//
    
    _categoryTabs = [NSMutableArray arrayWithCapacity:7];
    for (int i = 0; i < 5; i++)
    {
        UIButton*categoryButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/5*i,0,SCREEN_WIDTH/5 - (i == 4 ? 0 : 1),_headerView.frame.size.height)];
        NSLog(@"%f %f", categoryButton.frame.size.width, categoryButton.frame.size.height);
        [categoryButton setImage:[UIImage imageNamed:@"category_tab_enabled"] forState:UIControlStateNormal];
        [categoryButton setImage:[UIImage imageNamed:@"category_tab_disabled"] forState:UIControlStateDisabled];
        //[categoryButton setBackgroundColor:COLOUR_INTERFACE_BLUE];
        [categoryButton addTarget:self action:@selector(categoryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [_headerView addSubview:categoryButton];
        
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
        else if (i == storeCategoryPremium)
            categoryLabel.text = @"Premium";
        [categoryButton addSubview:categoryLabel];
        //costLabel.center = costFilterButton.center;
        
        [_categoryTabs addObject:categoryButton];
        
        //default selects the first tab
        if (i == 0)
            [categoryButton setEnabled:NO];
    }
    
    
    
    //---------------purchase indicator--------------------//
    
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
    
    [self loadCards];
}

-(void)filterToggleButtonPressed
{
    //[_filterToggleButton setSelected:![_filterToggleButton isSelected]];
    [self setFilterViewState:![self isFilterOpen]];
}

-(BOOL)isFilterOpen
{
    return [_filterToggleButton isSelected];
}

-(void)setFilterViewState:(BOOL)state
{
    _filterToggleButton.selected = state;
    if (state)
    {
        CGRect filterViewFrame = _filterView.frame;
        CGRect filterButtonFrame = _filterToggleButton.frame;
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_filterView setFrame:CGRectMake(filterViewFrame.origin.x, filterViewFrame.origin.y - filterViewFrame.size.height, filterViewFrame.size.width, filterViewFrame.size.height)];
                             [_filterToggleButton setFrame:CGRectMake(filterButtonFrame.origin.x, filterButtonFrame.origin.y - filterViewFrame.size.height, filterButtonFrame.size.width, filterButtonFrame.size.height)];
                         }
                         completion:^(BOOL completed){
                             
                         }];
    }
    else
    {
        CGRect filterViewFrame = _filterView.frame;
        CGRect filterButtonFrame = _filterToggleButton.frame;
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_filterView setFrame:CGRectMake(filterViewFrame.origin.x, filterViewFrame.origin.y + filterViewFrame.size.height, filterViewFrame.size.width, filterViewFrame.size.height)];
                             [_filterToggleButton setFrame:CGRectMake(filterButtonFrame.origin.x, filterButtonFrame.origin.y + filterViewFrame.size.height, filterButtonFrame.size.width, filterButtonFrame.size.height)];
                         }
                         completion:^(BOOL completed){
                             
                         }];
    }
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
    UIButton*senderButton = sender;
    
    int i = 0;
    for (UIButton*button in _categoryTabs)
    {
        if (senderButton == button)
        {
            _storeCategoryTab = i;
            [self loadCards];
            
            [button setEnabled:NO];
        }
        else
        {
            [button setEnabled:YES];
        }
        i++;
    }
}

-(void)updateFilter
{
    _cardsView.currentSales = [NSMutableArray array];
    
    for (PFObject *salePF in _currentLoadedCards)
    {
        PFObject *cardPF = salePF[@"card"];
        
        int cost = [cardPF[@"cost"] intValue];
        int element = [cardPF[@"element"] intValue];
        int rarity = [cardPF[@"rarity"] intValue];
        
        if (cost >= 0 && cost < _costFilter.count)
        {
            if ([_costFilter[cost] boolValue] == NO)
                continue;
        }
        
        if (element >= 0 && element < _elementFilter.count)
        {
            if ([_elementFilter[element] boolValue] == NO)
                continue;
        }
        
        if (rarity >= 0 && rarity < _rarityFilter.count)
        {
            if ([_rarityFilter[rarity] boolValue] == NO)
                continue;
        }
        
        //hide cards with stock 0
        if (_stockedFilter && [salePF[@"stock"] intValue] == 0)
            continue;
        
        //hide cards already liked
        if (_likedFilter && [UserModel getLikedCardID:[cardPF[@"idNumber"] intValue]])
            continue;
        
        //hide cards already owned
        if (_ownedFilter && [UserModel getOwnedCardID:[cardPF[@"idNumber"] intValue]])
            continue;
        
        //TODO only cards with same tags as decks
        
        [_cardsView.currentSales addObject:salePF];
    }
    
    _cardsView.currentCards = [NSMutableArray arrayWithCapacity:_cardsView.currentSales.count];
    _cardsView.currentCardsPF = [NSMutableArray arrayWithCapacity:_cardsView.currentSales.count];
    for (int i = 0; i < _cardsView.currentSales.count; i++)
        [_cardsView.currentCards addObject:[NSNull null]];
    for (int i = 0; i < _cardsView.currentSales.count; i++)
        [_cardsView.currentCardsPF addObject:[NSNull null]];
    
    [self.cardsView reloadInputViews];
    [self.cardsView.collectionView reloadData];
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
        
        if ([self isFilterOpen])
        {
            [self setFilterViewState:NO];
        }
    }
}

-(void)openCardInfoView:(CardModel*)cardModel
{
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
        return;
    }
     
    [_cardView removeFromSuperview];
    
    CardView*originalView = cardModel.cardView;
    _cardView = [[CardView alloc] initWithModel:cardModel viewMode:cardViewModeEditor];
    cardModel.cardView = originalView;
    _cardView.cardViewState = cardViewStateCardViewer;
    
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
    
    [_cardInfoView addSubview:_cardView];
    
    //TODO when viewing own cards, don't show the buy buttons etc. use if sale.seller == current user
    
    _goldLabel.text = [NSString stringWithFormat:@"%d", [GameStore getCardCost:_cardView.cardModel]];
    _likesLabel.text = [NSString stringWithFormat:@"%d", [_cardPF[@"likes"] intValue]];
    
    _rarityTextLabel.textColor = [_cardView getRarityColor];
    _rarityTextLabel.text = [CardModel getRarityText:_cardView.cardModel.rarity];
    _creatorLabel.text = [NSString stringWithFormat:@"Creator: %@", self.cardView.cardModel.creatorName];
    _idLabel.text = [NSString stringWithFormat:@"No. %d", self.cardView.cardModel.idNumber];
    
    _buyHintLabel.text = @"";
    _likeHintLabel.text = @"";
    _editHintLabel.text = @"";
    
    //cannot buy if already owns it, or not enough gold
    if ([UserModel getOwnedCard:cardModel])
    {
        _buyHintLabel.text = @"Already bought";
        [_buyButton setEnabled:NO];
    }
    else if ([userPF[@"gold"] intValue] < [GameStore getCardCost:cardModel])
    {
        _buyHintLabel.text = @"Not enough gold";
        [_buyButton setEnabled:NO];
    }
    else
        [_buyButton setEnabled:YES];
    
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
    
    if ([UserModel getLikedCard:cardModel] && ![UserModel getEditedCard:cardModel])
    {
        [_editButton setEnabled:YES];
    }
    else
    {
        _editHintLabel.text = @"Like it first";
        [_editButton setEnabled:NO];
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
    
    [self.view insertSubview:_cardPurchaseIndicator  aboveSubview:_footerView];
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
                    
                    [UserModel setOwnedCard:_cardView.cardModel];
                    [self updateCardInfoView:_cardView.cardModel];
                    
                    //[userPF saveInBackground]; //saved by setOwnedCard
                    
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
    //TODO put in thread
    userPF[@"likes"] = @([userPF[@"likes"] intValue] - 1);
    
    BOOL succ = [UserModel setLikedCard:_cardView.cardModel];
    
    if (succ)
        NSLog(@"success liking card");
    else
        NSLog(@"failed to like card");
    
    _cardPF[@"likes"] = @([_cardPF[@"likes"] intValue] + 1);
    [_cardPF saveInBackground]; //TODO check success
    
    int currentCardIndex = [_cardsView.currentCards indexOfObject:_cardView.cardModel];
    PFObject *salePF = _cardsView.currentSales[currentCardIndex];
    salePF[@"likes"] = _cardPF[@"likes"];
    [salePF saveInBackground]; //TODO
    
    int index = [_cardsView.currentCardsPF indexOfObject:_cardPF];
    [_cardsView.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    _likesLabel.text = [NSString stringWithFormat:@"%d", [_cardPF[@"likes"] intValue]];
    
    [self updateCardInfoView:_cardView.cardModel];
    
    [userPF saveInBackground]; //TODO
    
    [self.likeButton setEnabled:NO];
    [self.editButton setEnabled:YES];
}

-(void)editButtonPressed
{
    CardModel*cardCopy = [[CardModel alloc] initWithCardModel:_cardView.cardModel];
    
    CardEditorViewController *cevc = [[CardEditorViewController alloc] initWithMode:cardEditorModeVoting WithCard:cardCopy];
    
    [self presentViewController:cevc animated:YES completion:^{
        //processing done in cevc
        [self updateCardInfoView:_cardView.cardModel];
    }];
}

-(void)loadCards
{
    //clear all cells
    _cardsView.currentSales = [NSMutableArray array];
    _cardsView.currentCards = [NSMutableArray array];
    _cardsView.currentCardsPF = [NSMutableArray array];
    [self.cardsView reloadInputViews];
    [self.cardsView.collectionView reloadData];
    
    if (_storeCategoryTab != storeCategoryPremium)
    {
        NSLog(@"load card start");
        PFQuery *salesQuery = [PFQuery queryWithClassName:@"Sale"];
        salesQuery.limit = 100; //TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
            [salesQuery orderByAscending:@"likes"];
        }
        else if (_storeCategoryTab == storeCategoryOwned)
        {
            salesQuery.limit = 0;
            //TODO
        }
        
        [salesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                //load all sales without the cards
                _currentLoadedCards = [NSMutableArray arrayWithArray: objects];
                
                [self updateFilter];
            }
            else
            {
                NSLog(@"ERROR SEARCHING SALES");
            }
        }];
    }
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

@end
