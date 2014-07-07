//
//  GameViewController+Animation.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-05-13.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "GameViewController+Animation.h"
#import "CardView.h"

@implementation GameViewController (Animation)

-(void) addAnimationCounter
{
    self.currentNumberOfAnimations++;
    
    [self setAllViews:NO];
}

-(void) decAnimationCounter
{
    self.currentNumberOfAnimations--;
    
    if (self.currentNumberOfAnimations == 0)
        [self setAllViews:YES];
}

-(void) fadeIn: (UIView*) view inDuration: (float) duration
{
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.alpha = 1;
                     }
                     completion:nil];
}

-(void) fadeOut: (UIView*) view inDuration: (float) duration
{
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.alpha = 0;
                     }
                     completion:nil];
}

-(void) fadeOutAndRemove: (UIView*) view inDuration: (float) duration withDelay:(float) delay
{
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [view removeFromSuperview];
                     }];
}

-(void) zoomIn: (UIView*) view inDuration: (float) duration
{
    view.transform = CGAffineTransformMakeScale(0, 0);
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(1, 1);
                     }
                     completion:nil];
}

-(void) animateMoveTo: (UIView*) view toPosition: (CGPoint) target inDuration: (float) duration
{
    [self animateMoveTo:view toPosition:target inDuration:duration withDelay:0];
}

-(void) animateMoveTo: (UIView*) view toPosition: (CGPoint) target inDuration: (float) duration withDelay: (float) delay
{
    
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.center = target;
                     }
                     completion:nil];
}



-(void) animateMoveToWithBounce:(UIView *)view toPosition:(CGPoint)target inDuration:(float)duration
{
    [self animateMoveToWithBounce:view toPosition:target inDuration:duration withDelay:0];
}

-(void) animateMoveToWithBounce:(UIView *)view toPosition:(CGPoint)target inDuration:(float)duration withDelay: (float) delay
{
    [UIView animateWithDuration:duration
                          delay:delay
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{view.center = target;}
                     completion:nil];
    
    //older than iOS 7 use this:
    /*
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{view.center = target;}
                     completion:nil];
     */
}

/** Card flies up while fading out. On finish it is removed from superview and the battlefield is updated */
-(void) animateCardDestruction: (CardView*) cardView fromSide: (int)side
{
    [self animateCardDestruction:cardView fromSide:side withDelay:0];
}

/** Card flies up while fading out. It is first placed to the top of the view. On finish it is removed from superview and the battlefield is updated */
-(void) animateCardDestruction: (CardView*) cardView fromSide: (int)side withDelay: (float) delay
{
    [self addAnimationCounter];
    CGPoint newCenter = cardView.center;
    newCenter.y -= CARD_HEIGHT/4;
    
    //brings to front so doesn't get covered by other cards that are still alive
    [[cardView superview] bringSubviewToFront:cardView];
    
    [UIView animateWithDuration:0.6 delay:delay options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         cardView.alpha = 0.0;
                         cardView.center = newCenter;
                     }
                     completion:^(BOOL finished){
                         [cardView removeFromSuperview];
                         [self performBlock:^{
                             [self updateBattlefieldView:side];
                             [self decAnimationCounter];
                         }  afterDelay:0.5];
                     }];
}

-(void) animateCardDamage: (CardView*) cardView forDamage: (int) damage fromSide: (int) side
{
    //no animation if no damage
    if (damage == 0)
        return;
    
    [self addAnimationCounter];
    
    [cardView setPopupDamage:damage];
    //[self zoomIn:damagePopup inDuration:0.15];
    
    //already animating damage, don't have two shakes at once
    if (cardView.inDamageAnimation)
    {
        //target died, update field view and remove it from screen
        if (((MonsterCardModel*)cardView.cardModel).dead)
            [self animateCardDestruction:cardView fromSide:side withDelay: 0.4];

        //[self fadeOutAndRemove:damagePopup inDuration:0.5 withDelay:0.5];
        [self decAnimationCounter];
    }
    else
    {
        cardView.inDamageAnimation = YES;
        
        float power = (damage / 1000.f) + (damage / 1000.f) * arc4random_uniform(100) * 0.01/5 + 1;
        
        CGPoint originalPoint = cardView.center;
        CGPoint targetPoint = cardView.center;
        
        int velocity;
        
        if (side == PLAYER_SIDE){
            targetPoint.y += power;
            velocity = power;
        }
        else{
            targetPoint.y -= power;
            velocity = -power;
        }
        
        double duration = 0.125 * power + 0.1;
        if (duration > 1) //capped
            duration = 1;
        
        //card hit by damage and shakes
        [UIView animateWithDuration:duration
                              delay:0
             usingSpringWithDamping:0.001
              initialSpringVelocity:velocity
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{cardView.center = targetPoint;}
                         completion:^(BOOL finished){
                             cardView.inDamageAnimation = NO;
                             //target died, update field view and remove it from screen
                             if (((MonsterCardModel*)cardView.cardModel).dead)
                                 [self animateCardDestruction:cardView fromSide:side withDelay: 0.4];
                             //not dead, move back to position
                             else
                                 [self animateMoveToWithBounce:cardView toPosition:originalPoint inDuration:0.25 withDelay:0.4];
                             //[self fadeOutAndRemove:damagePopup inDuration:0.5 withDelay:0.5];
                             [self decAnimationCounter];
                         }
         ];
    }
    
    //older than iOS 7 use this:
    /*
    [UIView animateWithDuration:0.125 * power + 0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{cardView.center = targetPoint;}
                     completion:^(BOOL finished){
                         //target died, update field view and remove it from screen
                         if (((MonsterCardModel*)cardView.cardModel).dead)
                             [self animateCardDestruction:cardView fromSide:side withDelay: 0.5];
                         //not dead, move back to position
                         else
                             [self animateMoveToWithBounce:cardView toPosition:originalPoint inDuration:0.1 withDelay:0.5];
                         [self fadeOutAndRemove:damagePopup inDuration:0.5 withDelay:0.5];
                     }
     ];
     */
}

-(void) animateCardAttack: (CardView*) cardView fromSide:(int) side
{
    CGPoint startPosition = cardView.center;
    
    CGPoint target = startPosition;
    if (side == PLAYER_SIDE)
        target.y -= CARD_HEIGHT/5;
    else
        target.y += CARD_HEIGHT/5;
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         cardView.center = target;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              cardView.center = startPosition;
                                          }
                                          completion:nil];
                     }];
}

-(void) animateCardHeal: (CardView*) cardView forLife: (int) life
{
    UILabel *lifePopup = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    lifePopup.text = [NSString stringWithFormat:@"+%d", life];
    lifePopup.center = cardView.center;
    lifePopup.textAlignment = NSTextAlignmentCenter;
    lifePopup.textColor = [UIColor greenColor];
    lifePopup.backgroundColor = [UIColor clearColor];
    lifePopup.font = [UIFont fontWithName:@"Verdana-Bold" size:18];
    
    [self.uiView addSubview:lifePopup];
    [self zoomIn:lifePopup inDuration:0.15];
    [self fadeOutAndRemove:lifePopup inDuration:0.5 withDelay:0.5];
}

@end
