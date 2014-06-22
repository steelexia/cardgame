//
//  CardView.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CardView.h"

@implementation CardView

@synthesize cardModel = _cardModel;
@synthesize center = _center;
@synthesize cardViewState = _cardViewState;
@synthesize originalPosition = _originalPosition;
@synthesize nameLabel, costLabel, attackLabel, lifeLabel, cooldownLabel, baseAbilityLabel, addedAbilityLabel, elementLabel;
@synthesize previousViewIndex;
@synthesize cardImage = _cardImage;
@synthesize cardHighlightType = _cardHighlightType;
@synthesize lifeViewNeedsUpdate = _lifeViewNeedsUpdate;
@synthesize damageViewNeedsUpdate = _damageViewNeedsUpdate;
@synthesize cooldownViewNeedsUpdate = _cooldownViewNeedsUpdate;
@synthesize cardViewMode = _cardViewMode;

const int CARD_WIDTH_RATIO = 5;
const int CARD_HEIGHT_RATIO = 8;
const float CARD_IMAGE_RATIO = 450.f/530;

const float CARD_DEFAULT_SCALE = 0.4f;
const float CARD_DRAGGING_SCALE = 1.0f;

/** Dummy initial values, will be changed in setup */
int CARD_WIDTH = 50, CARD_HEIGHT = 80;
int CARD_FULL_WIDTH = 50, CARD_FULL_HEIGHT = 80;
int PLAYER_HERO_WIDTH = 50, PLAYER_HERO_HEIGHT = 50;

UIImage *backgroundOverlayImage, *selectHighlightImage, *targetHighlightImage, *heroSelectHighlightImage, *heroTargetHighlightImage;

/** 2D array of images. First array contains elements, second array contains rarity */
NSArray*backgroundImages;

NSMutableParagraphStyle *abilityTextParagrahStyle;
NSDictionary *abilityTextAttributtes;

NSString *cardMainFont = @"EncodeSansCompressed-Bold";
NSString *cardMainFontBlack = @"EncodeSansCompressed-Black";

+(void) loadResources
{
    backgroundImages = @[
                         @[[UIImage imageNamed:@"card_background_front_neutral_common"], //TODO additional rarity here
                           ],
                         @[[UIImage imageNamed:@"card_background_front_fire_common"]],
                         @[[UIImage imageNamed:@"card_background_front_ice_common"]],
                         @[[UIImage imageNamed:@"card_background_front_lightning_common"]],
                         @[[UIImage imageNamed:@"card_background_front_earth_common"]],
                         @[[UIImage imageNamed:@"card_background_front_light_common"]],
                         @[[UIImage imageNamed:@"card_background_front_dark_common"]],
                         ];
    
    backgroundOverlayImage = [UIImage imageNamed:@"card_background_front_overlay"];
    selectHighlightImage = [UIImage imageNamed:@"card_glow_select"];
    heroSelectHighlightImage = [UIImage imageNamed:@"hero_glow_select"];
    targetHighlightImage = [UIImage imageNamed:@"card_glow_target"];
    heroTargetHighlightImage = [UIImage imageNamed:@"hero_glow_target"];
    
    abilityTextParagrahStyle = [[NSMutableParagraphStyle alloc] init];
    //[abilityTextParagrahStyle setLineSpacing:];
    [abilityTextParagrahStyle setMaximumLineHeight:10];
    abilityTextAttributtes = @{NSParagraphStyleAttributeName : abilityTextParagrahStyle,};
    
    
}

-(instancetype)initWithModel:(CardModel *)cardModel cardImage:(UIImageView*)cardImage viewMode:(enum CardViewMode)cardViewMode
{
    self = [super init]; //does not actually make an image because highlight has to be behind it..
    
    if (self != nil)
    {
        self.cardViewMode = cardViewMode;
        
        NSArray*elementArray = backgroundImages[cardModel.element];
        //TODO
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:elementArray[0]];
        backgroundImageView.bounds = CGRectMake(0, 0, CARD_FULL_WIDTH, CARD_FULL_HEIGHT);
        backgroundImageView.center = CGPointMake(CARD_FULL_WIDTH/2, CARD_FULL_HEIGHT/2);
        [self addSubview: backgroundImageView];

        self.cardImage = cardImage;
        self.cardImage.bounds = CGRectMake(10, 30, CARD_FULL_WIDTH - 16, (CARD_FULL_WIDTH-16) * CARD_IMAGE_RATIO);
        self.cardImage.center = CGPointMake(CARD_FULL_WIDTH/2, self.cardImage.bounds.size.height/2 + self.cardImage.bounds.origin.y - 4);
        
        [self addSubview:self.cardImage];
        
        UIImageView *cardOverlay = [[UIImageView alloc] initWithImage:backgroundOverlayImage];
        cardOverlay.bounds = CGRectMake(0, 0, CARD_FULL_WIDTH, CARD_FULL_HEIGHT);
        cardOverlay.center = CGPointMake(CARD_FULL_WIDTH/2, CARD_FULL_HEIGHT/2);
        [self addSubview:cardOverlay];
        
        _cardModel = cardModel;
        cardModel.cardView = self; //point model's view back to itself
        
        self.userInteractionEnabled = true; //allows interaction
        
        self.frame = CGRectMake(0,0,CARD_FULL_WIDTH,CARD_FULL_HEIGHT);
        
        CGRect highlightBounds = CGRectMake(0,0,self.frame.size.width+14,self.frame.size.height+14);
        self.highlight = [[UIImageView alloc] initWithImage:selectHighlightImage];
        self.highlight.bounds = highlightBounds;
        self.highlight.center = CGPointMake(CARD_FULL_WIDTH/2, CARD_FULL_HEIGHT/2);
        self.highlight.alpha = 0.5;
        
        [self insertSubview:self.highlight atIndex:0];
        
        //draws common card elements such as name and cost
        self.nameLabel = [[StrokedLabel alloc] initWithFrame:self.bounds];
        self.nameLabel.center = CGPointMake(CARD_FULL_WIDTH/2 + CARD_FULL_WIDTH/10, 17);
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [UIFont fontWithName:cardMainFont size:15];
        
        [self addSubview: nameLabel];
        
        self.costLabel = [[StrokedLabel alloc] initWithFrame:self.bounds];
        self.costLabel.center = CGPointMake(21, 19);
        self.costLabel.textAlignment = NSTextAlignmentCenter;
        self.costLabel.textColor = [UIColor whiteColor];
        self.costLabel.backgroundColor = [UIColor clearColor];
        self.costLabel.font = [UIFont fontWithName:cardMainFontBlack size:24];
        self.costLabel.strokeOn = YES;
        self.costLabel.strokeColour = [UIColor blackColor];
        self.costLabel.strokeThickness = 3;
        
        [self addSubview: costLabel];
        
        self.elementLabel = [[StrokedLabel alloc] initWithFrame:self.bounds];
        self.elementLabel.center = CGPointMake(CARD_FULL_WIDTH/2, 150);
        self.elementLabel.textAlignment = NSTextAlignmentCenter;
        self.elementLabel.textColor = [UIColor whiteColor];
        self.elementLabel.backgroundColor = [UIColor clearColor];
        self.elementLabel.strokeOn = YES;
        self.elementLabel.strokeColour = [UIColor blackColor];
        self.elementLabel.strokeThickness = 2.5;
        self.elementLabel.font = [UIFont fontWithName:cardMainFont size:10];
        self.elementLabel.text = [CardModel elementToString:cardModel.element];
        
        [self addSubview: elementLabel];
        
        
        self.baseAbilityLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(10, 150, CARD_FULL_WIDTH - 20, 135)]; //NOTE changing this is useless, do it down below
       
        self.baseAbilityLabel.textColor = [UIColor blackColor];
        self.baseAbilityLabel.backgroundColor = [UIColor clearColor];
        self.baseAbilityLabel.font = [UIFont fontWithName:cardMainFont size:10];
        self.baseAbilityLabel.numberOfLines = 6;
        self.baseAbilityLabel.textAlignment = NSTextAlignmentLeft;
        self.baseAbilityLabel.lineBreakMode = NSLineBreakByWordWrapping;

        [self.baseAbilityLabel sizeToFit];
        [self addSubview: baseAbilityLabel];

        //draws specific card elements for monster card
        if ([cardModel isKindOfClass:[MonsterCardModel class]])
        {
            MonsterCardModel*monsterCard = (MonsterCardModel*)cardModel;

            //player hero's card only has life (TODO maybe damage or spells in future)
            if (cardModel.type == cardTypePlayer)
            {
                self.nameLabel.center = CGPointMake(PLAYER_HERO_WIDTH/2, 10);
                
                self.lifeLabel = [[StrokedLabel alloc] initWithFrame:self.bounds];
                self.lifeLabel.center = CGPointMake(PLAYER_HERO_WIDTH/2, PLAYER_HERO_HEIGHT - 10);
                self.lifeLabel.textAlignment = NSTextAlignmentCenter;
                self.lifeLabel.textColor = [UIColor whiteColor];
                self.lifeLabel.backgroundColor = [UIColor clearColor];
                self.lifeLabel.strokeOn = YES;
                self.lifeLabel.strokeColour = [UIColor blackColor];
                self.lifeLabel.strokeThickness = 2.5;
                self.lifeLabel.font = [UIFont fontWithName:cardMainFont size:20];
                self.lifeLabel.text = [NSString stringWithFormat:@"%d", monsterCard.life];
                
                [self addSubview: lifeLabel];
                
                //change the background and size
                self.cardImage.image = [UIImage imageNamed:@"hero_default"];
                
                //change the main image size
                self.cardImage.bounds = CGRectMake(5, 20, PLAYER_HERO_WIDTH - 10, (PLAYER_HERO_WIDTH-20) * CARD_IMAGE_RATIO);
                self.cardImage.center = CGPointMake(PLAYER_HERO_WIDTH/2, self.cardImage.bounds.size.height/2 + self.cardImage.bounds.origin.y);
                
                [self.costLabel removeFromSuperview];
                
                self.frame = CGRectMake(0,0,PLAYER_HERO_WIDTH,PLAYER_HERO_WIDTH);
                backgroundImageView.frame = CGRectMake(0,0,PLAYER_HERO_WIDTH,PLAYER_HERO_WIDTH);
                
                self.highlight.image = heroSelectHighlightImage;
                //change the highlight size
                CGRect highlightBounds = CGRectMake(0,0,self.frame.size.width+5,self.frame.size.height+5);
                self.highlight.bounds = highlightBounds;
                self.highlight.center = CGPointMake(PLAYER_HERO_WIDTH/2, PLAYER_HERO_HEIGHT/2);
                
                //removing this for now
                [cardOverlay removeFromSuperview];
                [elementLabel removeFromSuperview];
            }
            //other cards
            else
            {
                self.attackLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0,CARD_FULL_WIDTH/2,20)];
                self.attackLabel.center = CGPointMake(35, 138);
                self.attackLabel.textAlignment = NSTextAlignmentCenter;
                self.attackLabel.textColor = [UIColor whiteColor];
                self.attackLabel.backgroundColor = [UIColor clearColor];
                self.attackLabel.font = [UIFont fontWithName:cardMainFont size:18];
                self.attackLabel.strokeOn = YES;
                self.attackLabel.strokeColour = [UIColor blackColor];
                self.attackLabel.strokeThickness = 2.5;
                self.attackLabel.text = [NSString stringWithFormat:@"%d", monsterCard.damage];
                
                [self addSubview: attackLabel];
                
                self.lifeLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0,CARD_FULL_WIDTH/2,20)];
                self.lifeLabel.center = CGPointMake(CARD_FULL_WIDTH - 33, 138);
                self.lifeLabel.textAlignment = NSTextAlignmentCenter;
                self.lifeLabel.textColor = [UIColor whiteColor];
                self.lifeLabel.backgroundColor = [UIColor clearColor];
                self.lifeLabel.strokeOn = YES;
                self.lifeLabel.strokeColour = [UIColor blackColor];
                self.lifeLabel.strokeThickness = 2.5;
                self.lifeLabel.font = [UIFont fontWithName:cardMainFont size:18];
                self.lifeLabel.text = [NSString stringWithFormat:@"%d", monsterCard.life];
                
                [self addSubview: lifeLabel];
                
                self.cooldownLabel = [[StrokedLabel alloc] initWithFrame:self.bounds];
                self.cooldownLabel.center = CGPointMake(CARD_FULL_WIDTH/2, 129);
                self.cooldownLabel.textAlignment = NSTextAlignmentCenter;
                self.cooldownLabel.textColor = [UIColor whiteColor];
                self.cooldownLabel.backgroundColor = [UIColor clearColor];
                self.cooldownLabel.strokeOn = YES;
                self.cooldownLabel.strokeColour = [UIColor blackColor];
                self.cooldownLabel.strokeThickness = 2.5;
                self.cooldownLabel.font = [UIFont fontWithName:cardMainFont size:18];
                self.cooldownLabel.text = [NSString stringWithFormat:@"%d", monsterCard.cooldown];
                
                [self addSubview: cooldownLabel];
            }
        }
        //draws specific card elements for spell card
        else if ([cardModel isKindOfClass:[SpellCardModel class]])
        {
            
            //TODO
        }
        
        //adds correct text to all of the labels
        [self updateView];
    }
    
    self.cardHighlightType = cardHighlightNone;
    self.cardViewState = cardViewStateNone;
    
    return self;
}

-(void)updateView{
    self.nameLabel.text = self.cardModel.name;
    self.costLabel.text = [NSString stringWithFormat:@"%d", self.cardModel.cost];
    
    if ([self.cardModel isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel* monsterCard = (MonsterCardModel*) self.cardModel;

        //update damage label
        UIColor *newDamageColour;
        if (monsterCard.damage != monsterCard.baseDamage)
            newDamageColour = [UIColor redColor];
        else
            newDamageColour = [UIColor whiteColor];
        
        NSString *newDamageString = [NSString stringWithFormat:@"%d", monsterCard.damage];
        
        if ((self.damageViewNeedsUpdate || ![newDamageString isEqualToString:self.attackLabel.text]) && self.cardViewMode == cardViewModeIngame)
        {
            self.damageViewNeedsUpdate = NO;
            [CardView animateUILabelChange:self.attackLabel changeTo:newDamageString newColour:newDamageColour];
        }
        else
        {
            self.attackLabel.text = newDamageString;
            self.attackLabel.textColor = newDamageColour;
        }
        
        //update life label
        UIColor *newLifeColour;
        if (monsterCard.life > monsterCard.maximumLife || monsterCard.maximumLife > [monsterCard baseMaxLife])
            newLifeColour = [UIColor redColor];
        else
            newLifeColour = [UIColor whiteColor];
        
        NSString *newLifeString = [NSString stringWithFormat:@"%d", monsterCard.life];
        
        if (self.lifeViewNeedsUpdate && self.cardViewMode == cardViewModeIngame)
        {
            self.lifeViewNeedsUpdate = NO;
            [CardView animateUILabelChange:self.lifeLabel changeTo:newLifeString newColour:newLifeColour];
        }
        else
        {
            self.lifeLabel.text = newLifeString;
            self.lifeLabel.textColor = newLifeColour;
        }
        
        //update cooldown label
        UIColor *newCooldownColour;
        if (monsterCard.cooldown > monsterCard.maximumCooldown || monsterCard.cooldown > monsterCard.baseMaxCooldown || monsterCard.maximumCooldown > monsterCard.baseMaxCooldown)
            newCooldownColour = [UIColor redColor];
        else if (monsterCard.cooldown == 0)
            newCooldownColour = [UIColor greenColor]; //green when at 0 cooldown
        else
            newCooldownColour = [UIColor whiteColor];
        
        NSString* newCooldownString = [NSString stringWithFormat:@"%d", monsterCard.cooldown];
        
        if (self.cooldownViewNeedsUpdate && self.cardViewMode == cardViewModeIngame)
        {
            self.cooldownViewNeedsUpdate = NO;
            [CardView animateUILabelChange:self.cooldownLabel changeTo:newCooldownString newColour:newCooldownColour];
        }
        else
        {
            self.cooldownLabel.text = newCooldownString;
            self.cooldownLabel.textColor = newCooldownColour;
        }
        
        //TODO: need a special view to show both current and max values
    }
    else if ([self.cardModel isKindOfClass:[SpellCardModel class]])
    {
        SpellCardModel* spellCard = (SpellCardModel*) self.cardModel;
        
        //TODO
    }
    
    NSString *abilityDescription = @"";
    for (Ability *ability in self.cardModel.abilities)
    {
        if (!ability.expired)
            abilityDescription = [NSString stringWithFormat:@"%@%@\n", abilityDescription, [Ability getDescription:ability fromCard:self.cardModel]];
    }
    
    self.baseAbilityLabel.attributedText = [[NSAttributedString alloc] initWithString:abilityDescription
                                                                           attributes:abilityTextAttributtes];
    
    self.baseAbilityLabel.frame = CGRectMake(10, 157, CARD_FULL_WIDTH - 20, 140);
    [self.baseAbilityLabel sizeToFit];
}

/** Overwritten center getter. Returns the position based on the card's state */
-(CGPoint)center
{
    /*
     if (self.cardViewState == cardViewStateHighlighted)
     {
     CGPoint newPoint = super.center;
     newPoint.y -= 30;
     return newPoint;
     }
     else if (self.cardViewState == cardViewStateSelected)
     {
     CGPoint newPoint = super.center;
     newPoint.y -= 50;
     return newPoint;
     }*/
    return super.center;
}

/** overwritten center */
-(void)setCenter: (CGPoint)center
{
    self.originalPosition = center;
    super.center = center;
}

-(enum CardViewState) cardViewState
{
    return _cardViewState;
}

-(void)setCardViewState:(enum CardViewState)cardViewState
{
    if (cardViewState == cardViewStateHighlighted)
    {
        //set super position higher
        CGPoint newPoint = self.originalPosition;
        newPoint.y -= 20;
        
        super.center = newPoint;
    }
    else if (cardViewState == cardViewStateSelected)
    {
        //set super position higher
        CGPoint newPoint = self.originalPosition;
        newPoint.y -= 50;
        
        super.center = newPoint;
    }
    else if (cardViewState == cardViewStateDragging)
    {
        super.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_DRAGGING_SCALE, CARD_DRAGGING_SCALE);
        //self.transform = CGAffineTransformScale(CGAffineTransformIdentity, DRAGGING_SCALE, DRAGGING_SCALE);
        
        //set super position higher
        super.center = self.originalPosition;
    }
    else if (cardViewState == cardViewStateMaximize)
    {
        super.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    }
    else{
        if (self.cardModel.type != cardTypePlayer)
        {
            super.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_DEFAULT_SCALE, CARD_DEFAULT_SCALE);
        }
        
        //revert super's position
        super.center = self.originalPosition;
    }
    
    _cardViewState = cardViewState;
}

-(enum CardHighlightType) cardHighlightType
{
    return _cardHighlightType;
}

-(void)setCardHighlightType:(enum CardHighlightType)cardHighlightType
{
    if(cardHighlightType == cardHighlightNone)
    {
        self.highlight.alpha = 0;
        //[self stopCardHighlightAnimation:self.highlight];
        [self.highlight.layer removeAllAnimations];
    }
    else if (cardHighlightType == cardHighlightSelect)
    {
        if (self.cardModel.type == cardTypePlayer)
            self.highlight.image = heroSelectHighlightImage;
        else
            self.highlight.image = selectHighlightImage;
        
        self.highlight.alpha = 0.5;
        [self animateCardHighlightBrighten:self.highlight];
    }
    else if (cardHighlightType == cardHighlightTarget)
    {
        if (self.cardModel.type == cardTypePlayer)
            self.highlight.image = heroTargetHighlightImage;
        else
            self.highlight.image = targetHighlightImage;
        
        self.highlight.alpha = 0.5;
        [self animateCardHighlightBrighten:self.highlight];
    }
    
    _cardHighlightType = cardHighlightType;
}

-(void)resetTransformations
{
    self.cardViewState = self.cardViewState; //this causes the setCardViewState to be called again
}

-(void)animateCardHighlightBrighten: (UIImageView*)highlight
{
    
    [UIView animateWithDuration:3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{highlight.alpha = 1;}
                     completion:^(BOOL finished){
                         if (!finished)return; //stops the animation on removal
                         [self animateCardHighlightDim:highlight];
                     }];
}

-(void)animateCardHighlightDim: (UIImageView*)highlight
{
    [UIView animateWithDuration:3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{highlight.alpha = 0.5;}
                     completion:^(BOOL finished){
                         if (!finished)return; //stops the animation on removal
                         [self animateCardHighlightBrighten:highlight];
                     }];
}

+(void)animateUILabelChange: (UILabel*)label changeTo:(NSString*)newString newColour:(UIColor*)newColour
{
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         label.transform = CGAffineTransformMakeScale(2, 2);
                     }
                     completion:^(BOOL finished){
                         label.text = newString;
                         label.textColor = newColour;
                         [UIView animateWithDuration:0.25 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              label.transform = CGAffineTransformMakeScale(1, 1);
                                          }
                                          completion:nil];
                     }];
}

@end
