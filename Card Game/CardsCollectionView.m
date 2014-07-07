//
//  CardsCollectionView.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-24.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CardsCollectionView.h"
#import "CardView.h"
#import "DeckEditorViewController.h"

@implementation CardsCollectionView

@synthesize currentCardViews = _currentCardViews;
@synthesize collectionView = _collectionView;
@synthesize parentViewController = _parentViewController;
@synthesize isScrolling = _isScrolling;



- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout: (UICollectionViewLayout*)layout
{
    self = [super initWithFrame:frame];
    if (self) {
        self.collectionView = [[CustomCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        
        self.currentCardViews = [NSMutableArray array];
        
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cardsCollectionCell"];
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
    return [self.currentCardViews count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cardsCollectionCell" forIndexPath:indexPath];
    
    //clear all subviews in the cell
    //[[cell subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    //cell.backgroundColor=[UIColor greenColor];
    CardView*cardView = self.currentCardViews[indexPath.row];
    cardView.center = cell.center;
    cardView.frame = CGRectMake(0,0,CARD_FULL_WIDTH,CARD_FULL_HEIGHT);
    
    [cell addSubview:cardView];
    
    //greatly improves performance but freezes scale?
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CARD_FULL_WIDTH*CARD_VIEWER_SCALE,CARD_FULL_HEIGHT*CARD_VIEWER_SCALE);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0); //removes insets
}

-(void)removeCellAt:(int)index onFinish:(void (^)())block
{
    if (index < self.currentCardViews.count)
    {
        [self.collectionView performBatchUpdates:^{
            [self.currentCardViews removeObjectAtIndex:index];
            NSIndexPath *indexPath =[NSIndexPath indexPathForRow:index inSection:0];
            [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        } completion:^(BOOL finished) {
            block();
        }];
    }
}

-(void)removeAllCells
{
    [self.currentCardViews removeAllObjects];
    [self.collectionView reloadData];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.superview)
        [self.superview touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.superview)
        [self.superview touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.superview)
    {
        [self.superview touchesEnded:touches withEvent:event];
    }
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.superview)
        [self.superview touchesCancelled:touches withEvent:event];
}


-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.isScrolling = NO;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isScrolling = NO;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.isScrolling = NO;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.isScrolling = YES;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
