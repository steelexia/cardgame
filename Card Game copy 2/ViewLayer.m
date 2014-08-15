//
//  ViewLayer.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-05-14.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "ViewLayer.h"

@implementation ViewLayer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *subview = [super hitTest:point withEvent:event];
    return subview == self ? nil : subview;
}


@end
