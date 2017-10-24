//
//  DeckEditorViewController.h
//  cardgame
//
//  Created by Macbook on 2014-06-21.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardsCollectionView.h"
#import "DeckTableView.h"
#import "CFButton.h"
#import "CFLabel.h"
#import "GameStore.h"

@interface DeckEditorViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (strong) CardsCollectionView *cardsView;

@property (strong) DeckTableView *deckView;

@property (strong)StrokedLabel*searchResult;
@property (strong)StrokedLabel *makeCardsExplanationLabel;
@property (strong)StrokedLabel *deckCreateExplanationLabel;
@property (strong)StrokedLabel *deckCreateExplanationLabel2;
@property (strong)StrokedLabel *createCostLabel;
@property (strong) UIImageView *myAnvilImg;

//UIView Collection For Coin Balance & Free Cards
@property(strong)UIView *UserCoinBalanceView;
@property(strong)StrokedLabel *UserCoinBalanceLabel;
@property(strong)StrokedLabel *UserFreeCardsLabel;
@property(strong)UIButton *UserCoinBalanceButton;
@property(strong)UIImageView *myCoinBalanceFrame;
@property(strong)UIImageView *myCoinPileImg;
@property(strong)UIImageView *myFreeCardsImg;


@property (strong) CFButton *deleteDeckButton;

@property (strong) CFButton *deleteDeckConfirmButton, *deleteDeckCancelButton;

@property (strong)UIActivityIndicatorView*activityIndicator;
@property(strong) UILabel *activityLabel;
@property (strong)CFButton*activityFailedButton;

@property(strong)UITextView*invalidDeckReasonsLabel;
@property(strong)CFButton*invalidDeckReasonsOkButton;

@property(strong)CFButton*filterToggleButton;

@property (strong)CFButton*deckLimitationsButton;

@property(strong)UIView*footerView;

//new views for forge cards and update forge cards
@property(strong) UIImageView *propertyBackground;
@property(strong)UIButton *MyForgedCardsButton;
@property(strong)UIButton *ForgeNewCardButton;

//buy gold view
@property (strong) UIView*buyGoldViewDeck;
@property (strong) NSMutableArray*buyGoldButtonsDeck;


//view with properties of the deck, name and tags
@property(strong)UIView*propertiesView;
@property(strong)UITextField*nameField;
@property(strong)UITextView*tagsArea;
@property(strong)CFButton*tagsPopularButton;

//filter view
@property(strong)UIView*filterView;
@property(strong)CFButton*deckTagsButton;
@property (strong)NSMutableArray*costFilterButtons,*rarityFilterButtons,*elementFilterButtons;
@property(strong)NSMutableArray*costFilter;
@property(strong)NSMutableArray*elementFilter;
@property(strong)NSMutableArray*rarityFilter;

@property (strong) CFLabel*tutLabel;
@property (strong) CFButton*tutOkButton;
@property (strong) UIView*modalFilter;
@property BOOL isModal;

//forge card maximize views & buttons
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



@property (strong)NSMutableArray *indexOfNewCards;
@property (strong)NSMutableArray *indexOfStarterCards;

/** Set itself automatically */
@property BOOL isTutorial;
@property BOOL isForgeCardsMode;

/** Made changes to the current deck. */
@property BOOL hasMadeChange;

-(void)cardsViewFinishedScrollingAnimation;

@end

enum CardCollectinViewMode
{
    cardCollectionAddCard,
    cardCollectionRemoveCard,
    cardCollectionForgeCard
};

