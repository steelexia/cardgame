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

@interface DeckEditorViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (strong) CardsCollectionView *cardsView;

@property (strong) DeckTableView *deckView;

@property (strong)StrokedLabel*searchResult;

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

/** Set itself automatically */
@property BOOL isTutorial;

/** Made changes to the current deck. */
@property BOOL hasMadeChange;

-(void)cardsViewFinishedScrollingAnimation;

@end

enum CardCollectinViewMode
{
    cardCollectionAddCard,
    cardCollectionRemoveCard,
};

