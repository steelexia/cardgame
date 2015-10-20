//
//  StoreViewController+Animation.h
//  cardgame
//
//  Created by Emiliano Barcia on 10/15/15.
//  Copyright © 2015 Content Games. All rights reserved.
//

#import "StoreViewController.h"

@interface StoreViewController (Animation)

/** Fade in a view */
-(void) fadeIn: (UIView*) view inDuration: (float) duration;

/** Fade out a view */
-(void) fadeOut: (UIView*) view inDuration: (float) duration;

- (void)buyBoosterPackEffect;

-(void)flipViewFrom:(UIView*)oldView to:(UIView*)newView withDuration:(float)duration;

-(void)createBuyPackEffect;

@end
