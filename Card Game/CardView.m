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
@synthesize nameLabel, costLabel, attackLabel, lifeLabel, cooldownLabel, baseAbilityLabel, addedAbilityLabel;
@synthesize previousViewIndex;
@synthesize cardImage = _cardImage;
@synthesize cardHighlightType = _cardHighlightType;

const int CARD_WIDTH_RATIO = 5;
const int CARD_HEIGHT_RATIO = 8;
const float CARD_IMAGE_RATIO = 8.f/9;

const float CARD_DEFAULT_SCALE = 0.4f;
const float CARD_DRAGGING_SCALE = 1.0f;

/** Dummy initial values, will be changed in setup */
int CARD_WIDTH = 50, CARD_HEIGHT = 80;
int CARD_FULL_WIDTH = 50, CARD_FULL_HEIGHT = 80;
int PLAYER_HERO_WIDTH = 50, PLAYER_HERO_HEIGHT = 50;

UIImage *backgroundImage, *selectHighlightImage, *targetHighlightImage, *heroSelectHighlightImage, *heroTargetHighlightImage;

+(void) loadResources
{
    backgroundImage = [UIImage imageNamed:@"card_background_front"];
    selectHighlightImage = [UIImage imageNamed:@"card_glow_select"];
    heroSelectHighlightImage = [UIImage imageNamed:@"hero_glow_select"];
    targetHighlightImage = [UIImage imageNamed:@"card_glow_target"];
    heroTargetHighlightImage = [UIImage imageNamed:@"hero_glow_target"];
}

-(instancetype)initWithModel:(CardModel *)cardModel cardImage:(UIImageView*)cardImage
{
    self = [super initWithImage:backgroundImage];
    
    if (self != nil)
    {
        self.cardImage = cardImage;
        self.cardImage.bounds = CGRectMake(10, 30, CARD_FULL_WIDTH - 20, (CARD_FULL_WIDTH-20) * CARD_IMAGE_RATIO);
        self.cardImage.center = CGPointMake(CARD_FULL_WIDTH/2, self.cardImage.bounds.size.height/2 + self.cardImage.bounds.origin.y);
        
        [self addSubview:self.cardImage];
        
        _cardModel = cardModel;
        cardModel.cardView = self; //point model's view back to itself
        
        self.userInteractionEnabled = true; //allows interaction
        
        self.frame = CGRectMake(0,0,CARD_FULL_WIDTH,CARD_FULL_HEIGHT);
        
        CGRect highlightBounds = CGRectMake(0,0,self.frame.size.width+10,self.frame.size.height+10);
        self.highlight = [[UIImageView alloc] initWithImage:selectHighlightImage];
        self.highlight.bounds = highlightBounds;
        self.highlight.center = CGPointMake(CARD_FULL_WIDTH/2, CARD_FULL_HEIGHT/2);
        self.highlight.alpha = 0.5;
        
        [self addSubview:self.highlight];
        
        //TODO these are temporary drawing functions
        
        //draws common card elements such as name and cost
        self.nameLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.nameLabel.center = CGPointMake(CARD_FULL_WIDTH/2, 15);
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [UIFont fontWithName:@"Verdana" size:15];
        
        [self addSubview: nameLabel];
        
        self.costLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.costLabel.center = CGPointMake(20, 15);
        self.costLabel.textAlignment = NSTextAlignmentCenter;
        self.costLabel.textColor = [UIColor blackColor];
        self.costLabel.backgroundColor = [UIColor clearColor];
        self.costLabel.font = [UIFont fontWithName:@"Verdana" size:15];
        
        [self addSubview: costLabel];
        
        CGRect abilityBound = CGRectMake(self.bounds.origin.x + 5, self.bounds.origin.y + self.bounds.size.height/2 - 5, self.bounds.size.width - 10, self.bounds.size.height/2);
        
        self.baseAbilityLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, CARD_FULL_WIDTH - 20, 140)];
       
        self.baseAbilityLabel.textColor = [UIColor blackColor];
        self.baseAbilityLabel.backgroundColor = [UIColor clearColor];
        self.baseAbilityLabel.font = [UIFont fontWithName:@"Verdana-Italic" size:10];
        self.baseAbilityLabel.numberOfLines = 6;
        self.baseAbilityLabel.textAlignment = NSTextAlignmentLeft;
        self.baseAbilityLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.baseAbilityLabel sizeToFit];
        [self addSubview: baseAbilityLabel];
        
        //draws specific card elements for monster card
        if ([cardModel isKindOfClass:[MonsterCardModel class]])
        {
            //player hero's card only has life (TODO maybe damage or spells in future)
            if (cardModel.type == cardTypePlayer)
            {
                self.nameLabel.center = CGPointMake(PLAYER_HERO_WIDTH/2, 10);
                
                self.lifeLabel = [[UILabel alloc] initWithFrame:self.bounds];
                self.lifeLabel.center = CGPointMake(PLAYER_HERO_WIDTH/2, PLAYER_HERO_HEIGHT - 10);
                self.lifeLabel.textAlignment = NSTextAlignmentCenter;
                self.lifeLabel.textColor = [UIColor blackColor];
                self.lifeLabel.backgroundColor = [UIColor clearColor];
                
                self.lifeLabel.font = [UIFont fontWithName:@"Verdana" size:20];
                
                [self addSubview: lifeLabel];
                
                //change the background and size
                self.cardImage.image = [UIImage imageNamed:@"hero_default"];
                
                //change the main image size
                self.cardImage.bounds = CGRectMake(5, 20, PLAYER_HERO_WIDTH - 10, (PLAYER_HERO_WIDTH-20) * CARD_IMAGE_RATIO);
                self.cardImage.center = CGPointMake(PLAYER_HERO_WIDTH/2, self.cardImage.bounds.size.height/2 + self.cardImage.bounds.origin.y);
                
                [self.costLabel removeFromSuperview];
                
                self.frame = CGRectMake(0,0,PLAYER_HERO_WIDTH,PLAYER_HERO_WIDTH);
                
                self.highlight.image = heroSelectHighlightImage;
                //change the highlight size
                CGRect highlightBounds = CGRectMake(0,0,self.frame.size.width+5,self.frame.size.height+5);
                self.highlight.bounds = highlightBounds;
                self.highlight.center = CGPointMake(PLAYER_HERO_WIDTH/2, PLAYER_HERO_HEIGHT/2);
            }
            //other cards
            else
            {
                self.attackLabel = [[UILabel alloc] initWithFrame:self.bounds];
                self.attackLabel.center = CGPointMake(40, 145);
                self.attackLabel.textAlignment = NSTextAlignmentCenter;
                self.attackLabel.textColor = [UIColor blackColor];
                self.attackLabel.backgroundColor = [UIColor clearColor];
                self.attackLabel.font = [UIFont fontWithName:@"Verdana" size:15];
                
                [self addSubview: attackLabel];
                
                self.lifeLabel = [[UILabel alloc] initWithFrame:self.bounds];
                self.lifeLabel.center = CGPointMake(CARD_FULL_WIDTH - 40, 145);
                self.lifeLabel.textAlignment = NSTextAlignmentCenter;
                self.lifeLabel.textColor = [UIColor blackColor];
                self.lifeLabel.backgroundColor = [UIColor clearColor];
                
                self.lifeLabel.font = [UIFont fontWithName:@"Verdana" size:15];
                
                [self addSubview: lifeLabel];
                
                self.cooldownLabel = [[UILabel alloc] initWithFrame:self.bounds];
                self.cooldownLabel.center = CGPointMake(CARD_FULL_WIDTH/2, 130);
                self.cooldownLabel.textAlignment = NSTextAlignmentCenter;
                self.cooldownLabel.textColor = [UIColor blackColor];
                self.cooldownLabel.backgroundColor = [UIColor clearColor];
                
                self.cooldownLabel.font = [UIFont fontWithName:@"Verdana" size:15];
                
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
    self.costLabel.text = [NSString stringWithFormat:@"C:%d", self.cardModel.cost];
    
    if ([self.cardModel isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel* monsterCard = (MonsterCardModel*) self.cardModel;
        
        if (monsterCard.damage != monsterCard.baseDamage)
            self.attackLabel.textColor = [UIColor redColor];
        else
            self.attackLabel.textColor = [UIColor blackColor];
        
        self.attackLabel.text = [NSString stringWithFormat:@"D:%d", monsterCard.damage];
        
        if (monsterCard.life > monsterCard.maximumLife || monsterCard.maximumLife > [monsterCard baseMaxLife])
            self.lifeLabel.textColor = [UIColor redColor];
        else
            self.lifeLabel.textColor = [UIColor blackColor];
        
        
        self.lifeLabel.text = [NSString stringWithFormat:@"L:%d", monsterCard.life];
        self.cooldownLabel.text = [NSString stringWithFormat:@"CD:%d", monsterCard.cooldown];
        //TODO: need a special view to show both current and max values
    }
    else if ([self.cardModel isKindOfClass:[SpellCardModel class]])
    {
        SpellCardModel* spellCard = (SpellCardModel*) self.cardModel;
        
        //TODO
    }
    
    self.baseAbilityLabel.text = @"";
    for (Ability *ability in self.cardModel.abilities)
    {
        if (!ability.expired)
            self.baseAbilityLabel.text = [NSString stringWithFormat:@"%@%@\n", self.baseAbilityLabel.text, [Ability getDescription:ability fromCard:self.cardModel]];
    }
    
    self.baseAbilityLabel.frame = CGRectMake(10, 150, CARD_FULL_WIDTH - 20, 140);
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

@end
