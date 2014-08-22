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
        self.backgroundColor = COLOUR_INTERFACE_BLUE_LIGHT;
        
        _label = [[StrokedLabel alloc] initWithFrame:CGRectInset(self.bounds, 10, 10)];
        _label.textColor = [UIColor whiteColor];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont fontWithName:cardMainFont size:14];
        _label.textAlignment = NSTextAlignmentLeft;
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        _label.numberOfLines = 0;
        [self addSubview:_label];
    }
    return self;
}

-(void)setTextSize:(int)size
{
    _label.font = [UIFont fontWithName:cardMainFont size:size];
}

-(void)setIsDialog:(BOOL)state
{
    if (state)
        _label.frame = CGRectMake(_label.frame.origin.x, _label.frame.origin.y, _label.frame.size.width, _label.frame.size.height-50);
    else
        _label.frame = CGRectInset(self.bounds, 10, 10);
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [_border removeFromSuperlayer];
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
    
    self.label.frame = CGRectInset(self.bounds, 10, 10);
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
