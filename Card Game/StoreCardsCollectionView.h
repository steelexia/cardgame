//
//  StoreCardsCollectionView.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-02.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCollectionView.h"

@interface StoreCardsCollectionView : UIView <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>

/** Array of CardModel's that is currently being displayed. May be empty if haven't been loaded */
@property NSMutableArray*currentCards;

/** Stores the sale info. Its card may not have been loaded. */
@property (strong) NSMutableArray*currentSales;
@property (strong) NSMutableArray*currentCardsPF;

@property (strong) CustomCollectionView *collectionView;

@end
