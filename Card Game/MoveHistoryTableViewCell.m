//
//  MoveHistoryTableViewCell.m
//  cardgame
//
//  Created by Steele Xia on 2016-06-18.
//  Copyright © 2016 Content Games. All rights reserved.
//

#import "MoveHistoryTableViewCell.h"

@implementation MoveHistoryTableViewCell

@synthesize moveHistory = _moveHistory;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _moveHistory = nil;
        _cardViews = [NSMutableArray array];
        _targetCardsView = nil;
        
        //greatly improves performance but freezes scale?
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }
    return self;
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
