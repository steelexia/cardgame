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

//card info views
@property (strong)UIView*cardInfoView;
@property (strong)UIView*darkFilter;
@property (strong)CardView*cardView;
@property (strong)PFObject*cardPF;
@property (strong)UIButton*buyButton,*editButton,*likeButton;
@property (strong)StrokedLabel*creatorLabel, *idLabel, *rarityLabel, *rarityTextLabel, *likesLabel, *goldLabel;
@property (strong)StrokedLabel*likeHintLabel, *editHintLabel, *buyHintLabel;
@property (strong)UILabel*cardTagsLabel;

@property (strong)UIActivityIndicatorView*cardPurchaseIndicator;

/** PFObjects of class Sale currenting being viewed */

@end
