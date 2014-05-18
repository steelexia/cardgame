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
}

/** Card flies up while fading out. On finish it is removed from superview and the battlefield is updated */
-(void) animateCardDestruction: (CardView*) cardView fromSide: (int)side
{
    [self animateCardDestruction:cardView fromSide:side withDelay:0];
}

/** Card flies up while fading out. On finish it is removed from superview and the battlefield is updated */
-(void) animateCardDestruction: (CardView*) cardView fromSide: (int)side withDelay: (float) delay
{
    CGPoint newCenter = cardView.center;
    newCenter.y -= CARD_HEIGHT/4;
    
    [UIView animateWithDuration:0.4 delay:delay options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         cardView.alpha = 0.0;
                         cardView.center = newCenter;
                     }
                     completion:^(BOOL finished){
                         [cardView removeFromSuperview];
                         [self updateBattlefieldView:side];
                     }];
}

-(void) animateCardDamage: (CardView*) cardView forDamage: (int) damage fromSide: (int) side
{
    float power = (damage / 1000.f) + (damage / 1000.f) * arc4random_uniform(100) * 0.01/5 ;
    
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
    
    UILabel *damagePopup = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    damagePopup.text = [NSString stringWithFormat:@"-%d", damage];
    damagePopup.center = cardView.center;
    damagePopup.textAlignment = NSTextAlignmentCenter;
    damagePopup.textColor = [UIColor redColor];
    damagePopup.backgroundColor = [UIColor clearColor];
    damagePopup.font = [UIFont fontWithName:@"Verdana-Bold" size:18];
    
    [self.uiView addSubview:damagePopup];
    [self zoomIn:damagePopup inDuration:0.15];
    
    //card hit by damage and shakes
    [UIView animateWithDuration:0.125 * power + 0.1
                          delay:0
         usingSpringWithDamping:0.001
          initialSpringVelocity:velocity
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
