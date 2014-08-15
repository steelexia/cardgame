//
//  CFLabel.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-14.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CFLabel.h"
#import "UIConstants.h"
#import "CardView.h"

@implementation CFLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CAShapeLayer * _border;
        _border = [CAShapeLayer layer];
        _border.strokeColor = [UIColor blackColor].CGColor;
        _border.fillColor = nil;
        _border.lineWidth = 2;
        _border.lineDashPattern = @[@5, @8];
        CGRect boundsRect = CGRectInset(self.bounds, 5, 5);
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:boundsRect];
        _border.path = path.CGPath;
        _border.frame = self.bounds;
        [self.layer addSublayer:_border];
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        
        self.backgroundColor = COLOUR_INTERFACE_BLUE_LIGHT;
        
        _label = [[StrokedLabel alloc] initWithFrame:CGRectInset(self.bounds, 10, 5)];
        _label.textColor = [UIColor whiteColor];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont fontWithName:cardMainFont size:14];
        _label.textAlignment = NSTextAlignmentLeft;
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        _label.numberOfLines = 6;
        [self addSubview:_label];
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
