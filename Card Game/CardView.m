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
@synthesize nameLabel, costLabel, attackLabel, lifeLabel, cooldownLabel;
@synthesize previousViewIndex;

const int CARD_WIDTH_RATIO = 5;
const int CARD_HEIGHT_RATIO = 8;

const float CARD_DEFAULT_SCALE = 0.4f;
const float CARD_DRAGGING_SCALE = 0.8f;

/** Dummy initial values, will be changed in setup */
int CARD_WIDTH = 50, CARD_HEIGHT = 80;
int CARD_FULL_WIDTH = 50, CARD_FULL_HEIGHT = 80;

-(instancetype)initWithModel:(CardModel *)cardModel
{
    UIImage* backgroundImage = [UIImage imageNamed:@"card_background"];
    self = [super initWithImage:backgroundImage];
    
    if (self != nil)
    {
        _cardModel = cardModel;
        cardModel.cardView = self; //point model's view back to itself
        
        self.userInteractionEnabled = true; //allows interaction
        
        self.frame = CGRectMake(0,0,CARD_FULL_WIDTH,CARD_FULL_HEIGHT);
        
        //TODO these are temporary drawing functions
        
        //draws common card elements such as name and cost
        self.nameLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.nameLabel.center = CGPointMake(CARD_FULL_WIDTH/2, 30);
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [UIFont fontWithName:@"Verdana" size:15];
        
        
        [self addSubview: nameLabel];
        
        self.costLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.costLabel.center = CGPointMake(CARD_FULL_WIDTH/2 + 5, 60);
        self.costLabel.textAlignment = NSTextAlignmentLeft;
        self.costLabel.textColor = [UIColor blackColor];
        self.costLabel.backgroundColor = [UIColor clearColor];
        self.costLabel.font = [UIFont fontWithName:@"Verdana" size:15];
        
        [self addSubview: costLabel];

        //draws specific card elements for monster card
        if ([cardModel isKindOfClass:[MonsterCardModel class]])
        {
            self.attackLabel = [[UILabel alloc] initWithFrame:self.bounds];
            self.attackLabel.center = CGPointMake(CARD_FULL_WIDTH/2 + 5, 75);
            self.attackLabel.textAlignment = NSTextAlignmentLeft;
            self.attackLabel.textColor = [UIColor blackColor];
            self.attackLabel.backgroundColor = [UIColor clearColor];
            self.attackLabel.font = [UIFont fontWithName:@"Verdana" size:15];
            
            [self addSubview: attackLabel];
            
            self.lifeLabel = [[UILabel alloc] initWithFrame:self.bounds];
            self.lifeLabel.center = CGPointMake(CARD_FULL_WIDTH/2 + 5, 90);
            self.lifeLabel.textAlignment = NSTextAlignmentLeft;
            self.lifeLabel.textColor = [UIColor blackColor];
            self.lifeLabel.backgroundColor = [UIColor clearColor];
            
            self.lifeLabel.font = [UIFont fontWithName:@"Verdana" size:15];
            
            [self addSubview: lifeLabel];
            
            self.cooldownLabel = [[UILabel alloc] initWithFrame:self.bounds];
            self.cooldownLabel.center = CGPointMake(CARD_FULL_WIDTH/2 + 5, 105);
            self.cooldownLabel.textAlignment = NSTextAlignmentLeft;
            self.cooldownLabel.textColor = [UIColor blackColor];
            self.cooldownLabel.backgroundColor = [UIColor clearColor];
            
            self.cooldownLabel.font = [UIFont fontWithName:@"Verdana" size:15];
            
            [self addSubview: cooldownLabel];
        }
        //draws specific card elements for spell card
        else if ([cardModel isKindOfClass:[SpellCardModel class]])
        {
            
            //TODO
        }
        
        //adds correct text to all of the labels
        [self updateView];
    }
    
    self.cardViewState = cardViewStateNone;
    
    return self;
}

-(void)updateView{
    self.nameLabel.text = self.cardModel.name;
    self.costLabel.text = [NSString stringWithFormat:@"Cost: %d", self.cardModel.cost];
    
    if ([self.cardModel isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel* monsterCard = (MonsterCardModel*) self.cardModel;
        self.attackLabel.text = [NSString stringWithFormat:@"Damage: %d", monsterCard.damage];
        self.lifeLabel.text = [NSString stringWithFormat:@"Health: %d", monsterCard.life];
        self.cooldownLabel.text = [NSString stringWithFormat:@"Cooldown: %d", monsterCard.cooldown];
    }
    else if ([self.cardModel isKindOfClass:[SpellCardModel class]])
    {
        SpellCardModel* spellCard = (SpellCardModel*) self.cardModel;

        //TODO
    }
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
    else{
        super.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_DEFAULT_SCALE, CARD_DEFAULT_SCALE);
        //self.transform = CGAffineTransformScale(CGAffineTransformIdentity, DEFAULT_SCALE, DEFAULT_SCALE);
        
        //revert super's position
        super.center = self.originalPosition;
    }
    
    _cardViewState = cardViewState;
}

@end
