//
//  CardsCollectionCell.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-07-31.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CardsCollectionCell.h"

@implementation CardsCollectionCell

@synthesize cardView = _cardView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _cardView = nil;
        
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
