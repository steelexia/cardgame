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
@synthesize nameLabel, costLabel, attackLabel, lifeLabel;

/** dimensions of card */
int const WIDTH = 50, HEIGHT = 80; //TODO should be bigger and scales

-(instancetype)initWithModel:(CardModel *)cardModel
{
    UIImage* img = [UIImage imageNamed:@"card_background"];
    self = [super initWithImage:img];
    
    if (self != nil)
    {
        _cardModel = cardModel;
        cardModel.cardView = self; //point model's view back to itself
        
        self.frame = CGRectMake(0,0,WIDTH,HEIGHT);
        
        //TODO these are temporary drawing functions
        
        //draws common card elements such as name and cost
        self.nameLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.nameLabel.center = CGPointMake(WIDTH/2, 10);
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [UIFont fontWithName:@"Verdana" size:5];
        
        [self addSubview: nameLabel];
        
        self.costLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.costLabel.center = CGPointMake(WIDTH/2 + 5, 30);
        self.costLabel.textAlignment = NSTextAlignmentLeft;
        self.costLabel.textColor = [UIColor blackColor];
        self.costLabel.backgroundColor = [UIColor clearColor];
        self.costLabel.font = [UIFont fontWithName:@"Verdana" size:5];
        
        [self addSubview: costLabel];
        
        //draws specific card elements for monster card
        if ([cardModel isKindOfClass:[MonsterCardModel class]])
        {
            self.attackLabel = [[UILabel alloc] initWithFrame:self.bounds];
            self.attackLabel.center = CGPointMake(WIDTH/2 + 5, 35);
            self.attackLabel.textAlignment = NSTextAlignmentLeft;
            self.attackLabel.textColor = [UIColor blackColor];
            self.attackLabel.backgroundColor = [UIColor clearColor];
            self.attackLabel.font = [UIFont fontWithName:@"Verdana" size:5];
            
            [self addSubview: attackLabel];
            
            self.lifeLabel = [[UILabel alloc] initWithFrame:self.bounds];
            self.lifeLabel.center = CGPointMake(WIDTH/2 + 5, 40);
            self.lifeLabel.textAlignment = NSTextAlignmentLeft;
            self.lifeLabel.textColor = [UIColor blackColor];
            self.lifeLabel.backgroundColor = [UIColor clearColor];
            
            self.lifeLabel.font = [UIFont fontWithName:@"Verdana" size:5];
            
            [self addSubview: lifeLabel];
        }
        //draws specific card elements for spell card
        else if ([cardModel isKindOfClass:[SpellCardModel class]])
        {
            
            //TODO
        }
        
        //adds correct text to all of the labels
        [self updateView];
    }
    
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
    }
    else if ([self.cardModel isKindOfClass:[SpellCardModel class]])
    {
        SpellCardModel* spellCard = (SpellCardModel*) self.cardModel;

        //TODO
    }
}

@end
