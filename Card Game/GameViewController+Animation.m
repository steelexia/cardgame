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
    if (cardView.inDestructionAnimation)
        return;
    
    cardView.inDestructionAnimation=YES;
    
    CGPoint newCenter = CGPointMake(cardView.center.x, cardView.center.y);
    //NSLog(@"%f %f %f %f", cardView.center.x,cardView.center.y, cardView.originalPosition.x, cardView.originalPosition.y);
    
    [self addAnimationCounter];
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
                             cardView.inDestructionAnimation = NO;
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
        
        NSLog(@"in animation %@", cardView.cardModel.name);
    }
    else
    {
        cardView.inDamageAnimation = YES;
        NSLog(@"not in animation %@", cardView.cardModel.name);
        
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
    if (cardView.inDamageAnimation)
    {
        NSLog(@"attacking: is in animation %@", cardView.cardModel.name);
    }
    else
    {
        NSLog(@"attacking: not in animation %@", cardView.cardModel.name);
    }
    
    cardView.inDamageAnimation = YES;
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
                                          completion:^(BOOL finished) {
                                              cardView.inDamageAnimation = NO;
                                          }];
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
    lifePopup.font = [UIFont fontWithName:cardMainFontBlack size:18];
    
    [self.uiView addSubview:lifePopup];
    [self zoomIn:lifePopup inDuration:0.15];
    [self fadeOutAndRemove:lifePopup inDuration:0.5 withDelay:0.5];
}

-(void) animatePlayerTurn
{
    StrokedLabel *newTurn = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
    newTurn.center = CGPointMake(self.view.bounds.size.width + 300, self.view.center.y);
    newTurn.text = [NSString stringWithFormat:@"YOUR TURN"];
    newTurn.textAlignment = NSTextAlignmentCenter;
    newTurn.textColor = [UIColor whiteColor];
    newTurn.font = [UIFont fontWithName:cardMainFontBlack size:35];
    newTurn.strokeColour = [UIColor blackColor];
    newTurn.strokeThickness = 3;
    newTurn.strokeOn = YES;
    
    [self.uiView addSubview:newTurn];
    
    [self animateMoveToWithBounce:newTurn toPosition:self.view.center inDuration:0.5];
    [self fadeOutAndRemove:newTurn inDuration:0.5 withDelay:1.5];
}

- (void)hideViewBorder:(UIView *)view {
    [UIView animateWithDuration:0.0 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
       // view.layer.borderWidth = 0.0f;
        [view.layer setShadowOpacity:0];
    } completion:^(BOOL finished) {
        if (self.shouldBlink) {
             [self performSelector:@selector(showViewBorder:) withObject:view afterDelay:0.8];
        }
    }];
}

- (void)showViewBorder:(UIView *)view {

    [UIView animateWithDuration:0.0 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
       // view.layer.borderColor = [[UIColor colorWithRed:217/255.0f green:17/255.0f blue:42/255.0f alpha:1] CGColor];
       // view.layer.borderWidth = 3.0f;
        if (self.shouldBlink) {
            [view.layer setShadowOffset:CGSizeMake(0, 0)];
            [view.layer setShadowColor:[[UIColor colorWithRed:217/255.0f green:17/255.0f blue:42/255.0f alpha:1] CGColor]];
            [view.layer setShadowOpacity:1.0];
        }
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hideViewBorder:) withObject:view afterDelay:0.8];
    }];
}

- (void)flashOn:(UIView *)v {
    [self showViewBorder:v];
}

- (void)endFlash:(UIView *)v {
    self.shouldBlink = false;
//    v.alpha = 1;
}

- (void)startEndTurnTimer{
    
    
    self.shouldCallEndTurn = YES;
    [self.counterSubView setFrame:CGRectMake(0, 0, 0, self.counterView.frame.size.height)];
    
    //[self performSelector:@selector(showProgressView) withObject:nil afterDelay:10];
    
    self.timer = [NSTimer timerWithTimeInterval:10.0
                                         target:self
                                       selector:@selector(showProgressView)
                                       userInfo:nil
                                        repeats:NO];
    

    [self performBlock:^{
        [self.timer fire];
    } afterDelay:10.0];
    
    //[[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    
    
    [UIView animateWithDuration:25 animations:^{
        //animation
        [self.counterSubView setFrame:CGRectMake(0, 0, self.counterView.frame.size.width, self.counterView.frame.size.height)];
        
    } completion:^(BOOL finished) {
        //completion
        if (![self.counterView isHidden]) {
            [self endTurn];
        }
        
    }];
}

- (void)showProgressView{
    if (self.shouldCallEndTurn) {
        [self.timer invalidate];
        self.timer = nil;
        [self.counterView setHidden:NO];
    }
}
@end
