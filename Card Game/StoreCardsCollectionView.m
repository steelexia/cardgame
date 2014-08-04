//
//  StoreCardsCollectionView.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-02.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "StoreCardsCollectionView.h"
#import "StoreCardCell.h"
#import "GameStore.h"

@implementation StoreCardsCollectionView

@synthesize currentCards = _currentCards;
@synthesize collectionView = _collectionView;

const float STORE_CARD_SCALE = 1.1f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentCards = [NSMutableArray array];
        
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        self.collectionView = [[CustomCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        
        [self.collectionView registerClass:[StoreCardCell class] forCellWithReuseIdentifier:@"cardsCollectionCell"];
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
        
        [self.collectionView setDataSource:self];
        [self.collectionView setDelegate:self];
        [self setUserInteractionEnabled:YES];
        
        [self addSubview:self.collectionView];
 
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.currentSales count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    StoreCardCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cardsCollectionCell" forIndexPath:indexPath];
    
    //cell.backgroundColor=[UIColor greenColor];
    //if (cell.cardView != nil)
    [cell.cardView removeFromSuperview];
    
    if (indexPath.row >= 0 && indexPath.row < self.currentCards.count)
    {
        CardModel*card = self.currentCards[indexPath.row];
        
        //card may be null at this point (hasn't been loaded)
        if (card != (id)[NSNull null])
        {
            CardModel*card = self.currentCards[indexPath.row];
            cell.cardView = [[CardView alloc] initWithModel:card cardImage:[[UIImageView alloc]initWithImage: [UIImage imageNamed:@"card_image_placeholder"]] viewMode:cardViewStateMaximize viewState:card.cardViewState];
            cell.cardView.cardHighlightType = cardHighlightNone;
            cell.cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, STORE_CARD_SCALE, STORE_CARD_SCALE);
            cell.cardView.center = cell.center;
            cell.cardView.frame = CGRectMake(0,0,CARD_FULL_WIDTH*STORE_CARD_SCALE,CARD_FULL_HEIGHT*STORE_CARD_SCALE + 80);
            cell.costLabel.text = [NSString stringWithFormat:@"%d", [GameStore getCardCost:card]];
            
            [cell addSubview:cell.cardView];
            
            [cell addSubview:cell.likesLabel];
            [cell addSubview:cell.costLabel];
            
            [cell.activityView stopAnimating];
            [cell.activityView removeFromSuperview];
        }
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CARD_FULL_WIDTH*STORE_CARD_SCALE,CARD_FULL_HEIGHT*STORE_CARD_SCALE + 80);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0); //removes insets
}

@end
