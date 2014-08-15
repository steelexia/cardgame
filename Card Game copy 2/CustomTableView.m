//
//  CustomTableView.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-25.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CustomTableView.h"

@implementation CustomTableView

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
        [self.superview touchesEnded:touches withEvent:event];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.superview)
        [self.superview touchesCancelled:touches withEvent:event];
}

@end
