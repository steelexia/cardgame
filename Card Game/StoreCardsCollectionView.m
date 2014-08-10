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
        _loadingCells = [NSMutableArray array];
        
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        self.collectionView = [[CustomCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        
        [self.collectionView registerClass:[StoreCardCell class] forCellWithReuseIdentifier:@"storeCardsCollectionCell"];
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
        
        [self.collectionView setDataSource:self];
        [self.collectionView setDelegate:self];
        //self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
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
    StoreCardCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"storeCardsCollectionCell" forIndexPath:indexPath];
    
    //cell.backgroundColor=[UIColor greenColor];
    //if (cell.cardView != nil)
    [cell.cardView removeFromSuperview];
    [cell.statsView removeFromSuperview];
    
    [cell addSubview:cell.activityView];
    [cell.activityView startAnimating];
    
    if (indexPath.row >= 0 && indexPath.row < self.currentCards.count)
    {
        CardModel*card = self.currentCards[indexPath.row];
        
        //card may be null at this point (hasn't been loaded)
        if (card == (id)[NSNull null] && ![_loadingCells containsObject:indexPath])
        {
            [self loadCellAtIndexPath:indexPath];
        }
        //loaded
        else if (![_loadingCells containsObject:indexPath]) //i.e. not loading
        {
            NSLog(@"%d got into non null", indexPath.row);
            
            //CardModel*card = self.currentCards[indexPath.row];
            PFObject*cardPF = self.currentCardsPF[indexPath.row];
            
            cell.cardView = [[CardView alloc] initWithModel:card viewMode:cardViewStateMaximize viewState:card.cardViewState];
            cell.cardView.cardHighlightType = cardHighlightNone;
            cell.cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, STORE_CARD_SCALE, STORE_CARD_SCALE);
            cell.cardView.center = cell.center;
            cell.cardView.frame = CGRectMake(0,0,CARD_FULL_WIDTH*STORE_CARD_SCALE,CARD_FULL_HEIGHT*STORE_CARD_SCALE + 50);
            cell.costLabel.text = [NSString stringWithFormat:@"%d", [GameStore getCardCost:card]];
            cell.likesLabel.text = [NSString stringWithFormat:@"%d", [cardPF[@"likes"] intValue]];
            
            [cell addSubview:cell.cardView];
            [cell addSubview:cell.statsView];
            
            [cell.activityView stopAnimating];
            [cell.activityView removeFromSuperview];
        }
    }
    return cell;
}

//this function prevents loading for the wrong cell when scrolling is too fast
-(void)loadCellAtIndexPath:(NSIndexPath*)indexPath
{
    [_loadingCells addObject:indexPath];
    
    NSLog(@"%d got into null", indexPath.row);
    //[self performBlockInBackground:^(void){
    int i = indexPath.row;
    
    PFObject *sale = self.currentSales[i];
    
    PFQuery *cardQuery = [PFQuery queryWithClassName:@"Card"];
    cardQuery.limit = 1;
    [cardQuery whereKey:@"idNumber" equalTo:sale[@"cardID"]];
    [cardQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(!error && objects.count >= 1){
            PFObject *cardPF = objects[0];
            self.currentCardsPF[i] = cardPF;
            [self performBlockInBackground:^(void){
            [CardModel createCardFromPFObject:cardPF onFinish:^(CardModel*cardModel){
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    self.currentCards[i] = cardModel;
                    StoreCardCell *cell = (StoreCardCell *)[_collectionView cellForItemAtIndexPath:indexPath];
                    cell.cardView = [[CardView alloc] initWithModel:cardModel viewMode:cardViewStateMaximize viewState:cardModel.cardViewState];
                    cell.cardView.cardHighlightType = cardHighlightNone;
                    cell.cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, STORE_CARD_SCALE, STORE_CARD_SCALE);
                    cell.cardView.center = cell.center;
                    cell.cardView.frame = CGRectMake(0,0,CARD_FULL_WIDTH*STORE_CARD_SCALE,CARD_FULL_HEIGHT*STORE_CARD_SCALE + 50);
                    cell.costLabel.text = [NSString stringWithFormat:@"%d", [GameStore getCardCost:cardModel]];
                    cell.likesLabel.text = [NSString stringWithFormat:@"%d", [cardPF[@"likes"] intValue]];
                    
                    [cell.activityView stopAnimating];
                    [cell.activityView removeFromSuperview];
                    
                    [cell addSubview:cell.cardView];
                    [cell addSubview:cell.statsView];
                    
                    [self.collectionView reloadInputViews];
                    
                    [_loadingCells removeObject:indexPath];
                });
            }];
            } onFinish:nil];
            //}];
        }
        else
        {
            NSLog(@"ERROR SEARCHING SALES");
        }
        
    }];
    //} onFinish:nil];
    
}

- (void)performBlockInBackground:(void (^)())block onFinish:(void (^)())onFinish {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (block!=nil)
            block();
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (onFinish!=nil)
                onFinish();
        });
    });
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CARD_FULL_WIDTH*STORE_CARD_SCALE,CARD_FULL_HEIGHT*STORE_CARD_SCALE + 50);
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
