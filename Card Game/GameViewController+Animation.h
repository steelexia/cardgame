//
//  GameViewController+Animation.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-05-13.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "GameViewController.h"

/** Custom animations for the card game. Methods are placed here so they can be tweaked easily */
@interface GameViewController (Animation)


-(void) addAnimationCounter;

-(void) decAnimationCounter;

/** Fade in a view */
-(void) fadeIn: (UIView*) view inDuration: (float) duration;

/** Fade out a view */
-(void) fadeOut: (UIView*) view inDuration: (float) duration;

/** Fade out and remove a view */
-(void) fadeOutAndRemove: (UIView*) view inDuration: (float) duration withDelay:(float) delay;

/** Zoom from 0 to 100% */
-(void) zoomIn: (UIView*) view inDuration: (float) duration;

/** Slerp a UIView to a new position */
-(void) animateMoveTo: (UIView*) view toPosition: (CGPoint) target inDuration: (float) duration;

/** Slerp a UIView to a new position with delay */
-(void) animateMoveTo: (UIView*) view toPosition: (CGPoint) target inDuration: (float) duration withDelay: (float) delay;

/** Slerp a UIView to a new position with a slight bouncing effect */
-(void) animateMoveToWithBounce:(UIView *)view toPosition:(CGPoint)target inDuration:(float)duration;

/** Slerp a UIView to a new position with a slight bouncing effect, and a delay */
-(void) animateMoveToWithBounce:(UIView *)view toPosition:(CGPoint)target inDuration:(float)duration withDelay: (float) delay;

/** Used when a field card is dead */
-(void) animateCardDestruction: (CardView*) cardView fromSide: (int)side;

/** Used when a field card is dead, with a delay */
-(void) animateCardDestruction: (CardView*) cardView fromSide: (int)side withDelay: (float) delay;

/** Used to animate the damage dealt to a card */
-(void) animateCardDamage: (CardView*) cardView forDamage: (int) damage fromSide:(int) side;

/** Used to animate a card's attack animation. Damage animation should be called separately */
-(void) animateCardAttack: (CardView*) cardView fromSide:(int) side;

-(void) animateCardHeal: (CardView*) cardView forLife: (int) life;

-(void) animatePlayerTurn;

/** Blinking butttons **/

- (void)flashOff:(UIView *)v;

- (void)flashOn:(UIView *)v;

- (void)endFlash:(UIView *)v;

- (void)startEndTurnTimer;
@end
