//
//  StoreViewController.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-02.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreCardsCollectionView.h"
#import "CardView.h"
#import "StrokedLabel.h"
#import "CardEditorViewController.h"

@interface StoreViewController : UIViewController <UITextFieldDelegate>

@property (strong) StoreCardsCollectionView *cardsView;

@property (strong)UIButton*backButton;
@property (strong)UIViewController*previousScreen;
@property (strong)StrokedLabel *userGoldLabel, *userLikesLabel, *userCardLabel;
/** Cards loaded from last query. No query is required if only filters are being changed. */
@property (strong)NSMutableArray*currentLoadedCards;

@property (strong)StrokedLabel*searchResult;
@property(strong)UIButton* userGoldIcon, *userCardIcon;
@property(strong)UIImageView*userLikesIcon;

//card info views
@property (strong)UIView*headerView, *footerView;
@property (strong)UIView*cardInfoView;
@property (strong)UIView*darkFilter;
@property (strong)CardView*cardView;
@property (strong)PFObject*cardPF;
@property (strong)UIButton*buyButton,*sellButton,*editButton,*likeButton;
@property (strong)StrokedLabel*creatorLabel, *idLabel, *rarityLabel, *rarityTextLabel, *likesLabel, *goldLabel;
@property (strong)StrokedLabel*likeHintLabel, *editHintLabel, *buyHintLabel;
@property (strong)UILabel*cardTagsLabel;

@property (strong)UIActivityIndicatorView*activityIndicator;
@property(strong) UILabel *activityLabel;
@property (strong)UIButton*activityFailedButton;

//search views
@property (strong)UIView*searchView;
@property (strong)UIButton*searchToggleButton;
@property (strong)UITextField*searchNameField, *searchTagsField, *searchIDField;

//filter views
@property (strong)UIView*filterView;
@property (strong)UIButton*filterToggleButton;
@property (strong)UIButton*likedButton, *ownedButton, *stockedButton, *deckTagsButton;
@property (strong)NSMutableArray*costFilterButtons,*rarityFilterButtons,*elementFilterButtons;

/** Hides card already owned if YES */
@property BOOL ownedFilter;
/** Hides card already liked if YES */
@property BOOL likedFilter;
/** Hides card with stock of 0 if YES */
@property BOOL stockedFilter;
@property BOOL deckTagsFilter;

//filter settings
@property(strong)NSMutableArray*costFilter;
@property(strong)NSMutableArray*elementFilter;
@property(strong)NSMutableArray*rarityFilter;

@property enum StoreCategoryTab storeCategoryTab;

//blank card view
@property (strong) UIView*blankCardView;
@property (strong) NSMutableArray*buyBlankCardButtons;
@property (strong) StrokedLabel*remainingCardLabel;
@property (strong) UIButton*createCardButton;

//buy gold view
@property (strong) UIView*buyGoldView;
@property (strong) NSMutableArray*buyGoldButtons;

//tabs, stores UIButtons
@property(strong)NSMutableArray*categoryTabs;

/** Index number for the first object in the collection view. */
@property int currentQueryLocation;

/** PFObjects of class Sale currenting being viewed */

@property BOOL scrolledToDatabaseEnd;

@property BOOL loadingMoreCards;

/** Called by StoreCardsCollectionView */
-(void)storeScrolledToEnd;



@end

enum StoreCategoryTab
{
    storeCategoryFeatured,
    storeCategoryNewest,
    storeCategoryPopular,
    storeCategoryOwned,
    storeCategoryDesigned,
};

/** Used for cells to know that loaded card is out of date when a new query has been called. This variable increments every time a new query is called. */
int cardStoreQueryID;