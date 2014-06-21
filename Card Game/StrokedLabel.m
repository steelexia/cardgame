//
//  StrokedLabel.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-18.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "StrokedLabel.h"

@implementation StrokedLabel

@synthesize strokeThickness = _strokeThickness;
@synthesize strokeColour = _strokeColour;
@synthesize strokeOn = _strokeOn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.strokeThickness = 1;
        self.strokeColour = [UIColor blackColor];
        self.strokeOn = NO;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    
    CGSize shadowOffset = self.shadowOffset;
    UIColor *textColor = self.textColor;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, self.strokeThickness);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    
    if (self.strokeOn)
    {
        CGContextSetTextDrawingMode(c, kCGTextStroke);
        self.textColor = self.strokeColour;
        [super drawTextInRect:rect];
    }
    
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeMake(0, 0);
    [super drawTextInRect:rect];
    
    self.shadowOffset = shadowOffset;
}

@end
