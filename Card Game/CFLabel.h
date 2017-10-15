//
//  CFLabel.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-14.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StrokedLabel;



@interface CFLabel : UIView

@property (strong)StrokedLabel*label;
@property (strong)CAShapeLayer * border;
-(void)setTextSize:(int)size;
/** Didn't have time to make a dialog class so this just makes it look better as a dialog box */
-(void)setIsDialog:(BOOL)state;

@end
