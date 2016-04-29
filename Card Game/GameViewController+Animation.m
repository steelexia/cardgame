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
    
    if (self.currentNumberOfAnimations <= 0)
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
    
    [self addAnimationCounter];
    newCenter.y -= CARD_HEIGHT/4;
    
    //brings to front so doesn't get covered by other cards that are still alive
    [[cardView superview] bringSubviewToFront:cardView];
    
    if (![cardView.cardModel isKindOfClass:[SpellCardModel class]]) {
        CardView *topImgView =  [[CardView alloc] initWithModel:cardView.cardModel viewMode:cardViewModeEditor];
        CardView *bottomImgView = [[CardView alloc] initWithModel:cardView.cardModel viewMode:cardViewModeEditor];;
        
        [topImgView setFrontFacing:YES];
        [bottomImgView setFrontFacing:YES];
        //[topImgView flipCard];
        //[bottomImgView flipCard];
        
        UIBezierPath* trianglePath = [UIBezierPath bezierPath];
        [trianglePath moveToPoint:CGPointMake(0, 0)];
        [trianglePath addLineToPoint:CGPointMake(0,CARD_FULL_HEIGHT)];
        [trianglePath addLineToPoint:CGPointMake(CARD_FULL_WIDTH, 0)];
        [trianglePath closePath];
        
        CAShapeLayer *triangleMaskLayer = [CAShapeLayer layer];
        [triangleMaskLayer setPath:trianglePath.CGPath];
        
        UIBezierPath* trianglePath2 = [UIBezierPath bezierPath];
        [trianglePath2 moveToPoint:CGPointMake(CARD_FULL_WIDTH, 0)];
        [trianglePath2 addLineToPoint:CGPointMake(0, CARD_FULL_HEIGHT)];
        [trianglePath2 addLineToPoint:CGPointMake(CARD_FULL_WIDTH,CARD_FULL_HEIGHT)];
        [trianglePath2 closePath];
        
        CAShapeLayer *triangleMaskLayer2 = [CAShapeLayer layer];
        [triangleMaskLayer2 setPath:trianglePath2.CGPath];
        
        
        //[topImgView setBackgroundColor:[UIColor blackColor]];
        
        [topImgView.layer setMask:triangleMaskLayer];
        [bottomImgView.layer setMask:triangleMaskLayer2];
        
        
        [topImgView setCenter:cardView.center];
        [bottomImgView setCenter:cardView.center];
        
        //bottomImgView.transform = CGAffineTransformMakeTranslation(bottomImgView.frame.size.width/2, 0);
        
        [[cardView superview] addSubview:topImgView];
        [[cardView superview] addSubview:bottomImgView];
        
        UIView *theView = [[UIView alloc] initWithFrame:cardView.frame];
        theView.backgroundColor = [UIColor blackColor];
        theView.center = cardView.center;
        //[[cardView superview] addSubview:theView];
        //[[cardView superview] bringSubviewToFront:topImgView];
        //[[cardView superview] bringSubviewToFront:bottomImgView];
        
        CAShapeLayer *shape = [self getLineFromCardview:cardView];
        [[cardView superview].layer addSublayer:shape];
        //[[cardView superview] sendSubviewToBack:cardView];
        [cardView setHidden:YES];
        
        float destructionDuration = 0.4f;
        
        [NSThread sleepForTimeInterval:delay];
        
        [self animateShapeBounds:shape OnView:cardView forDuration:0.1];
        [self performSelector:@selector(hideShape:) withObject:shape afterDelay:0.1];
        
        CGPoint n_top_center = topImgView.center;
        n_top_center.x -= 10;
        n_top_center.y -= 10;
        
        CGPoint n_bottom_center = bottomImgView.center;
        n_bottom_center.x += 10;
        n_bottom_center.y += 10;
        
        
   
        [UIView animateWithDuration:destructionDuration delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
            topImgView.center = n_top_center;
            topImgView.alpha = 0.0;
            bottomImgView.center = n_bottom_center;
            bottomImgView.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            [cardView removeFromSuperview];
            [self performBlock:^{
                [self updateBattlefieldView:side];
                [self decAnimationCounter];
                //cardView.inDestructionAnimation = NO;
                [topImgView removeFromSuperview];
                [bottomImgView removeFromSuperview];
            }  afterDelay:0.5];
        }];
        
    }else{
        [cardView removeFromSuperview];
        [self performBlock:^{
            [self updateBattlefieldView:side];
            [self decAnimationCounter];
            cardView.inDestructionAnimation = NO;
        }  afterDelay:0.5];
    }
    
    
    
}

-(CAShapeLayer *)getLineFromCardview:(CardView *)cardView{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(cardView.frame.origin.x + (cardView.frame.size.width/10 *1),cardView.frame.origin.y + cardView.frame.size.height/10 *9)];
    [path addLineToPoint:CGPointMake(cardView.frame.origin.x,cardView.frame.origin.y + cardView.frame.size.height)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
    shapeLayer.lineWidth = 2.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    return shapeLayer;
}

-(void)animateShapeBounds:(CAShapeLayer*)shape OnView:(CardView *)cardView forDuration:(float)duration
{
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(cardView.frame.origin.x + cardView.frame.size.width,cardView.frame.origin.y)];
    [path addLineToPoint:CGPointMake(cardView.frame.origin.x,cardView.frame.origin.y + cardView.frame.size.height)];
    
    CABasicAnimation* pathAnim = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnim.toValue = (__bridge id _Nullable)([path CGPath]);
    pathAnim.duration = duration;
    pathAnim.cumulative = NO;
    pathAnim.repeatCount = 1.0;
    pathAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    pathAnim.removedOnCompletion = YES;
    pathAnim.fillMode = kCAFillModeForwards;
    
    [shape addAnimation:pathAnim forKey:@"path"];
}

-(void)hideShape:(CAShapeLayer *)shape{
    [shape removeFromSuperlayer];
}

-(void) animateCardIceDamage:(CardView*)cardView fromSide:(int)side{
    
    NSString *imageName = @"Snowflake";
    UIImage *image = [UIImage imageNamed:imageName];
    //assert(image);
    
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    [cell setName:imageName];
    float defaultBirthRate = 70.0f;
    
    [cell setBirthRate:defaultBirthRate];
    [cell setVelocity:120];
    [cell setVelocityRange:0.0f];
    [cell setYAcceleration:0.0f];
    [cell setEmissionLongitude:-M_PI_2];
    [cell setEmissionRange:-M_PI];
    [cell setScale:0.2f];
    [cell setScaleSpeed:1.0f];
    [cell setScaleRange:0.5f];
    [cell setContents:(id)image.CGImage];
    [cell setColor:[UIColor colorWithRed:0.9 green:0.9 blue:1 alpha:0.5].CGColor];
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [cell setLifetime:6.0f];
        [cell setLifetimeRange:2.0f];
    }
    else
    {
        [cell setLifetime:0.6f];
        [cell setLifetimeRange:0.2f];
    }
    
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    [emitter setEmitterCells:@[cell]];
    CGRect CVF = CGRectMake(cardView.frame.origin.x,cardView.frame.origin.y, 20, 20);
    [emitter setFrame:CVF];
    CGPoint emitterPosition = (CGPoint) {cardView.frame.size.width/2, cardView.frame.size.height/2};
    [emitter setEmitterPosition:emitterPosition];
    [emitter setEmitterSize:(CGSize){0.5f, 0.5f}];
    [emitter setEmitterShape:kCAEmitterLayerRectangle];
    [emitter setRenderMode:kCAEmitterLayerAdditive];
    [emitter setZPosition:1];
    [[cardView superview].layer addSublayer:emitter];
    
    [self performBlock:^{
        [emitter removeFromSuperlayer];
    } afterDelay:.2];
}

-(void) animateCardFireDamage:(CardView*)cardView fromSide:(int)side{
    
    NSString *imageName = @"Smoke";
    UIImage *image = [UIImage imageNamed:imageName];
    //assert(image);
    
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    [cell setName:imageName];
    float defaultBirthRate = 70.0f;
    
    [cell setBirthRate:defaultBirthRate];
    [cell setVelocity:120];
    [cell setVelocityRange:0.0f];
    [cell setYAcceleration:0.0f];
    [cell setEmissionLongitude:-M_PI_2];
    [cell setEmissionRange:-M_PI];
    [cell setScale:0.2f];
    [cell setScaleSpeed:1.0f];
    [cell setScaleRange:0.5f];
    [cell setContents:(id)image.CGImage];
    [cell setColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5].CGColor];
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [cell setLifetime:6.0f];
        [cell setLifetimeRange:2.0f];
    }
    else
    {
        [cell setLifetime:0.6f];
        [cell setLifetimeRange:0.2f];
    }
    
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    [emitter setEmitterCells:@[cell]];
    CGRect CVF = CGRectMake(cardView.frame.origin.x,cardView.frame.origin.y, 20, 20);
    [emitter setFrame:CVF];
    CGPoint emitterPosition = (CGPoint) {cardView.frame.size.width/2, cardView.frame.size.height/2};
    [emitter setEmitterPosition:emitterPosition];
    [emitter setEmitterSize:(CGSize){0.5f, 0.5f}];
    [emitter setEmitterShape:kCAEmitterLayerRectangle];
    [emitter setRenderMode:kCAEmitterLayerAdditive];
    [emitter setZPosition:1];
    [[cardView superview].layer addSublayer:emitter];
    
    [self performBlock:^{
        [emitter removeFromSuperlayer];
    } afterDelay:.2];
}

-(void) animateCardThunderDamage:(CardView*)cardView fromSide:(int)side{
    
    NSString *imageName = @"Thunder";
    UIImage *image = [UIImage imageNamed:imageName];
    //assert(image);
    
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    [cell setName:imageName];
    float defaultBirthRate = 70.0f;
    
    [cell setBirthRate:defaultBirthRate];
    [cell setVelocity:120];
    [cell setVelocityRange:0.0f];
    [cell setYAcceleration:0.0f];
    [cell setEmissionLongitude:-M_PI_2];
    [cell setEmissionRange:-M_PI];
    [cell setScale:0.2f];
    [cell setScaleSpeed:1.0f];
    [cell setScaleRange:0.5f];
    [cell setContents:(id)image.CGImage];
    //[cell setColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5].CGColor];
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [cell setLifetime:6.0f];
        [cell setLifetimeRange:2.0f];
    }
    else
    {
        [cell setLifetime:0.6f];
        [cell setLifetimeRange:0.2f];
    }
    
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    [emitter setEmitterCells:@[cell]];
    CGRect CVF = CGRectMake(cardView.frame.origin.x,cardView.frame.origin.y, 20, 20);
    [emitter setFrame:CVF];
    CGPoint emitterPosition = (CGPoint) {cardView.frame.size.width/2, cardView.frame.size.height/2};
    [emitter setEmitterPosition:emitterPosition];
    [emitter setEmitterSize:(CGSize){0.5f, 0.5f}];
    [emitter setEmitterShape:kCAEmitterLayerRectangle];
    [emitter setRenderMode:kCAEmitterLayerAdditive];
    [emitter setZPosition:1];
    [[cardView superview].layer addSublayer:emitter];
    
    [self performBlock:^{
        [emitter removeFromSuperlayer];
    } afterDelay:.2];
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
            [self animateCardDestruction:cardView fromSide:side withDelay: 1.0];

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
                                 [self animateCardDestruction:cardView fromSide:side withDelay: 1.0];
                             //not dead, move back to position
                             //else
                                // [self animateCardIceDamage:cardView fromSide:side];
                                 //[self animateMoveToWithBounce:cardView toPosition:originalPoint inDuration:0.25 withDelay:0.4];
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
    lifePopup.font = [UIFont fontWithName:cardMainFontBlack size:CARD_DAMAGE_POPUP_SIZE];
    
    [self.uiView addSubview:lifePopup];
    [self zoomIn:lifePopup inDuration:0.15];
    [self fadeOutAndRemove:lifePopup inDuration:DAMAGE_POPUP_DURATION withDelay:0.5];
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
    [self.topView setHidden:YES];
    [self.topRightView setHidden:YES];
    [self.rightView setHidden:YES];
    [self.bottomRightView setHidden:YES];
    [self.bottomView setHidden:YES];
    [self.bottomLeftView setHidden:YES];
    [self.leftView setHidden:YES];
    [self.topLeftView setHidden:YES];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateTopRightCorner) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateRightHand) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateBottomRightCorner) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateBottomHand) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateBottomLeftCorner) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateLeftHand) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateTopleftCorner) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateTopView) object:nil];
//    v.alpha = 1;
}

- (void)startEndTurnTimer{
    
    
    self.shouldCallEndTurn = YES;

    [self setTimerFrames];
    [self animateTopRightCorner];
   
}

-(void)animateTopRightCorner{
    if (self.shouldCallEndTurn) {
        CABasicAnimation *radarHand;
        
        radarHand = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        
        radarHand.fromValue = [NSNumber numberWithFloat:0];
        
        radarHand.byValue = [NSNumber numberWithFloat:((90*M_PI)/180)];
        
        radarHand.duration = 2.0f;
        radarHand.delegate = self;
        
        radarHand.repeatCount = 1;
        [radarHand setRemovedOnCompletion:YES];
        
        [self.topRightView setCenter:CGPointMake(self.topRightView.frame.origin.x, self.topRightView.frame.origin.y + self.topRightView.frame.size.height)];
        [self.topRightView.layer addAnimation:radarHand forKey:nil];
        [self.topRightView.layer setAnchorPoint:CGPointMake(0,1)];
        [self performSelector:@selector(animateRightHand) withObject:nil afterDelay:1.6f];
    }
}

-(void)animateRightHand{
    if (self.shouldCallEndTurn) {
        [self.topRightView setHidden:YES];
        [UIView animateWithDuration:4.0 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
            
            self.rightView.frame = CGRectMake(self.rightView.frame.origin.x, self.rightView.frame.origin.y + self.rightView.frame.size.height, self.rightView.frame.size.width, 0);
            
        } completion:^(BOOL finished) {
            //code
            //[self animateBottomRightCorner];
        }];
        
        [self performSelector:@selector(animateBottomRightCorner) withObject:nil afterDelay:3.5];
    }
}

-(void)animateBottomRightCorner{
    
    if (self.shouldCallEndTurn) {
        CABasicAnimation *radarHand;
        
        radarHand = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        
        radarHand.fromValue = [NSNumber numberWithFloat:M_PI_2];
        
        radarHand.byValue = [NSNumber numberWithFloat:((180*M_PI_2)/180)]; //((360*M_PI)/180)
        
        radarHand.duration = 2.0f;
        radarHand.delegate = self;
        
        radarHand.repeatCount = 1;
        [radarHand setRemovedOnCompletion:YES];
        
        [self.bottomRightView setCenter:CGPointMake(self.bottomRightView.frame.origin.x, self.bottomRightView.frame.origin.y)];
        [self.bottomRightView.layer addAnimation:radarHand forKey:nil];
        [self.bottomRightView.layer setAnchorPoint:CGPointMake(0,1)];
        [self performSelector:@selector(animateBottomHand) withObject:nil afterDelay:1.6f];
    }
}

-(void)animateBottomHand{
    if (self.shouldCallEndTurn) {
        [self.bottomRightView setHidden:YES];
        [UIView animateWithDuration:6.0 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
            
            self.bottomView.frame = CGRectMake(self.bottomView.frame.origin.x, self.bottomView.frame.origin.y, 0, self.bottomView.frame.size.height);
            
        } completion:^(BOOL finished) {
            //code
            //[self animateBottomLeftCorner];
        }];
        [self performSelector:@selector(animateBottomLeftCorner) withObject:nil afterDelay:5.5];
    }
}

-(void)animateBottomLeftCorner{
   
    if (self.shouldCallEndTurn) {
        CABasicAnimation *radarHand;
        
        radarHand = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        
        radarHand.fromValue = [NSNumber numberWithFloat:M_PI];
        
        radarHand.byValue = [NSNumber numberWithFloat:((180*M_PI_2)/180)]; //((360*M_PI)/180)
        
        radarHand.duration = 2.0f;
        radarHand.delegate = self;
        
        radarHand.repeatCount = 1;
        [radarHand setRemovedOnCompletion:YES];
        
        [self.bottomLeftView setCenter:CGPointMake(self.bottomLeftView.frame.origin.x + self.bottomLeftView.frame.size.width, self.bottomLeftView.frame.origin.y)];
        [self.bottomLeftView.layer addAnimation:radarHand forKey:nil];
        [self.bottomLeftView.layer setAnchorPoint:CGPointMake(0,1)];
        [self performSelector:@selector(animateLeftHand) withObject:nil afterDelay:1.6f];
    }
}

-(void)animateLeftHand{
    if (self.shouldCallEndTurn) {
        [self.bottomLeftView setHidden:YES];
        [UIView animateWithDuration:4.0 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
            
            self.leftView.frame = CGRectMake(self.leftView.frame.origin.x , self.leftView.frame.origin.y, self.leftView.frame.size.width, 0);
            
        } completion:^(BOOL finished) {
            //code
            //[self animateTopleftCorner];
        }];
        [self performSelector:@selector(animateTopleftCorner) withObject:nil afterDelay:3.5];
    }
}

-(void)animateTopleftCorner{
    if (self.shouldCallEndTurn) {
        CABasicAnimation *radarHand;
        
        radarHand = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        
        radarHand.fromValue = [NSNumber numberWithFloat:(- M_PI_2)];
        
        radarHand.byValue = [NSNumber numberWithFloat:(M_PI_2)]; //
        
        radarHand.duration = 2.0f;
        radarHand.delegate = self;
        
        radarHand.repeatCount = 1;
        [radarHand setRemovedOnCompletion:YES];
        
        [self.topLeftView setCenter:CGPointMake(self.topLeftView.frame.origin.x +self.topLeftView.frame.size.width , self.topLeftView.frame.origin.y + self.topLeftView.frame.size.height)];
        [self.topLeftView.layer addAnimation:radarHand forKey:nil];
        [self.topLeftView.layer setAnchorPoint:CGPointMake(0,1)];
        [self performSelector:@selector(animateTopView) withObject:nil afterDelay:1.6f];
    }
}

-(void)animateTopView{
    if (self.shouldCallEndTurn) {
        [self.topLeftView setHidden:YES];
        [UIView animateWithDuration:6.0 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
            
            self.topView.frame = CGRectMake(self.topView.frame.origin.x + self.topView.frame.size.width, self.topView.frame.origin.y, 0, self.topView.frame.size.height);
            
        } completion:^(BOOL finished) {
            
            if (self.shouldCallEndTurn) {
                [self endTurn];
                [self.topLeftView setHidden:YES];
            }
        }];
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag{
    NSLog(@"on animationDidStop");
}

- (void)showProgressView{
    if (self.shouldCallEndTurn) {
        [self.timer invalidate];
        self.timer = nil;
        [self.counterView setHidden:NO];
    }
}
@end
