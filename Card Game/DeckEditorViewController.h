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

@interface DeckEditorViewController : UIViewController

@property (strong) CardsCollectionView *cardsView;

@property (strong) DeckTableView *deckView;

@property (strong) UIButton *deleteDeckButton;

@property (strong) UIButton *deleteDeckConfirmButton, *deleteDeckCancelButton;

-(void)cardsViewFinishedScrollingAnimation;

@end

enum CardCollectinViewMode
{
    cardCollectionAddCard,
    cardCollectionRemoveCard,
};

