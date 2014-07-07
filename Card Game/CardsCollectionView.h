//
//  CardsCollectionView.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-24.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCollectionView.h"
#import "UIConstants.h"

@interface CardsCollectionView:UIView <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>

/** Array of CardView's that is currently being displayed */
@property (strong) NSMutableArray*currentCardViews;

@property (strong) CustomCollectionView *collectionView;

@property (weak) UIViewController *parentViewController;

@property BOOL isScrolling;

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout: (UICollectionViewLayout*)layout;


-(void)removeCellAt:(int)index onFinish:(void (^)())block;

-(void)removeAllCells;

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end


