//
//  StorePackCell.m
//  cardgame
//
//  Created by Emiliano Barcia on 10/19/15.
//  Copyright © 2015 Content Games. All rights reserved.
//

#import "StorePackCell.h"

@implementation StorePackCell

int PACK_FULL_WIDTH = 90, PACK_FULL_HEIGHT = 160;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.packView = [[PackView alloc] initWithFrame:CGRectMake(10, 10, PACK_FULL_WIDTH, PACK_FULL_HEIGHT)];
        
        [self addSubview:self.packView];
    }
    return self;
}

@end
