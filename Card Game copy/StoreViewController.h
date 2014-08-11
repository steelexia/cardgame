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

@interface StoreViewController : UIViewController

@property (strong) StoreCardsCollectionView *cardsView;

@property (strong)UIButton*backButton;
@property (strong)UIViewController*previousScreen;
@property (strong)StrokedLabel *userGoldLabel, *userLikesLabel;
/** Cards loaded from last query. No query is required if only filters are being changed. */
@property (strong)NSMutableArray*currentLoadedCards;

//card info views
@property (strong)UIView*headerView, *footerView;
@property (strong)UIView*cardInfoView;
@property (strong)UIView*darkFilter;
@property (strong)CardView*cardView;
@property (strong)PFObject*cardPF;
@property (strong)UIButton*buyButton,*editButton,*likeButton;
@property (strong)StrokedLabel*creatorLabel, *idLabel, *rarityLabel, *rarityTextLabel, *likesLabel, *goldLabel;
@property (strong)StrokedLabel*likeHintLabel, *editHintLabel, *buyHintLabel;
@property (strong)UILabel*cardTagsLabel;

@property (strong)UIActivityIndicatorView*cardPurchaseIndicator;

//filter views
@property (strong)UIView*filterView;
@property (strong)UIButton*likedButton, *ownedButton, *stockedButton, *deckTagsButton;
@property (strong)NSMutableArray*costFilterButtons,*rarityFilterButtons,*elementFilterButtons;

//filter settings
@property(strong)NSMutableArray*costFilter;
@property(strong)NSMutableArray*elementFilter;
@property(strong)NSMutableArray*rarityFilter;
/** Hides card already owned if YES */
@property BOOL ownedFilter;
/** Hides card already liked if YES */
@property BOOL likedFilter;
/** Hides card with stock of 0 if YES */
@property BOOL stockedFilter;
@property BOOL deckTagsFilter;
@property enum StoreCategoryTab storeCategoryTab;
@property (strong)UIButton*filterToggleButton;

//tabs, stores UIButtons
@property(strong)NSMutableArray*categoryTabs;

/** PFObjects of class Sale currenting being viewed */

@end

enum StoreCategoryTab
{
    storeCategoryFeatured,
    storeCategoryNewest,
    storeCategoryPopular,
    storeCategoryOwned,
    storeCategoryPremium,
};