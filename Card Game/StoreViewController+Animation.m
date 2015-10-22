//
//  StoreViewController+Animation.m
//  cardgame
//
//  Created by Emiliano Barcia on 10/15/15.
//  Copyright © 2015 Content Games. All rights reserved.
//

#import "StoreViewController+Animation.h"


@implementation StoreViewController (Animation)

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

- (void)buyBoosterPackEffect{
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.boosterPackImageViewContainer.center = self.view.center;
                     }
                     completion:^(BOOL finished) {
                         //code
                         
                         [self flipViewFrom:self.boosterPackImageView to:self.boosterPackImageBackView withDuration:.4];
                     }];
}

-(void)flipViewFrom:(UIView*)oldView to:(UIView*)newView withDuration:(float)duration
{
    BOOL shouldAnimate = YES;
    
    NSString *dur = [NSString stringWithFormat:@"%.3f",duration];
    
    if ([dur isEqualToString:@"0.100"]) {
        [self performSelector:@selector(createBuyPackEffect) withObject:nil afterDelay:1.2];
    }else if (duration <= 0.086f){
        shouldAnimate = NO;
    }
    if (shouldAnimate) {
        [UIView transitionFromView:oldView toView:newView
                          duration:duration
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        completion:^(BOOL finished) {
                            //code
                            float auxDuration = duration;
                            if (auxDuration <= 0.1f) {
                                auxDuration -= 0.001f;
                            }else{
                                auxDuration -= 0.05f;
                            }
                            [self flipViewFrom:newView to:oldView withDuration:auxDuration];
                        }];
    }
    
}

- (void)createBuyPackEffect{
    [self.view addSubview:[self explosion]];
    [self.boosterPackImageView setHidden:YES];
    [self showBuyedCards];
}

- (UIImageView *) explosion{
    //Position the explosion image view somewhere in the middle of your current view. In my case, I want it to take the whole view.Try to make the png to mach the view size, don't stretch it
    CGRect exploFrame = CGRectMake(0, 0, self.boosterPackImageView.frame.size.height +200 , self.boosterPackImageView.frame.size.height + 200);
    UIImageView *explosion = [[UIImageView alloc] initWithFrame:exploFrame];
    explosion.center = self.storeDarkBG.center;
    
    //Add images which will be used for the animation using an array. Here I have created an array on the fly
    explosion.animationImages =  @[[UIImage imageNamed:@"poof_5.png"], [UIImage imageNamed:@"poof_4.png"],[UIImage imageNamed:@"poof_3.png"], [UIImage imageNamed:@"poof_2.png"],[UIImage imageNamed:@"poof_1.png"]];
    
    //Set the duration of the entire animation
    explosion.animationDuration = 0.4;
    
    //Set the repeat count. If you don't set that value, by default will be a loop (infinite)
    explosion.animationRepeatCount = 1;
    
    //Start the animationrepeatcount
    [explosion startAnimating];
    
    return explosion;
}

- (void)showBuyedCards{
    
    // I take 5 cards from my cards, in the future we will have to get these cards from Parse
    
    NSMutableArray *cardsView = [[NSMutableArray alloc] init];
    CGRect cardViewFrame = CGRectMake(0, 0, 142, 227);
    
    for (int i = 0; i < self.purchasedCards.count; i++) {
        [CardModel createCardFromPFObject:[self.purchasedCards objectAtIndex:i] onFinish:^(CardModel *card) {
            
            //code
            CardView *cardView = [[CardView alloc] initWithModel:card viewMode:cardViewModeToValidate viewState:card.cardViewState];
            card.cardView = cardView;
            card.cardView.frontFacing = YES;
            card.cardView.cardHighlightType = cardHighlightNone;
            card.cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            card.cardView.center = self.storeDarkBG.center;
            
            [cardsView addObject:card.cardView];
            [self.storeDarkBG addSubview:card.cardView];
        }];
        
    }
    
    CGRect bounds = self.storeDarkBG.bounds;
    
    CGRect frame1 = cardViewFrame;
    frame1.origin.x = bounds.size.width/2 - frame1.size.width;
    frame1.origin.y = bounds.size.height/2 - frame1.size.height;
    
    CGRect frame2 = cardViewFrame;
    frame2.origin.x = bounds.size.width/2;
    frame2.origin.y = bounds.size.height/2 - frame2.size.height;
    
    CGRect frame3 = cardViewFrame;
    frame3.origin.x = bounds.size.width/2 - frame3.size.width;
    frame3.origin.y = bounds.size.height/2;
    
    CGRect frame4 = cardViewFrame;
    frame4.origin.x = bounds.size.width/2;
    frame4.origin.y = bounds.size.height/2;
    
    [UIView animateWithDuration:1.5 animations:^{
        //code
        ((CardView *)[cardsView objectAtIndex:0]).frame = frame1;
        ((CardView *)[cardsView objectAtIndex:1]).frame = frame2;
        ((CardView *)[cardsView objectAtIndex:2]).frame = frame3;
        ((CardView *)[cardsView objectAtIndex:3]).frame = frame4;
        
    } completion:^(BOOL finished) {
    }];
    
}

-(void)closeBuyedCardsView{
    [self.storeDarkBG setHidden:YES];
    self.storeDarkBG = nil;
}

@end
