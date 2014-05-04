//
//  CardView.h
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardModel.h"
#import "MonsterCardModel.h"
#import "SpellCardModel.h"

/** 
 Handles the view aspect of the card. Draws the card based on the model object.
 The attached cardModel can be any of the child classes, such as MonsterCardModel or SpellCardModel. 
 */
@interface CardView : UIImageView

/** Attached model for storing data of the card */
@property (strong) CardModel *cardModel;

/** Labels displayed on the cards (somewhat temporary for now) */
@property (strong) UILabel *nameLabel, *costLabel, *attackLabel, *lifeLabel;

/** Initializes with attached CardModel, which should be one of its child classes */
-(instancetype)initWithModel: (CardModel*)cardModel;

/** Updates its view after values are updated (i.e. lost life) */
-(void)updateView;

@end
