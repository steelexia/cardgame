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
#import "Ability.h"

/**
 Handles the view aspect of the card. Draws the card based on the model object.
 The attached cardModel can be any of the child classes, such as MonsterCardModel or SpellCardModel.
 */
@interface CardView : UIImageView

/** Attached model for storing data of the card */
@property (strong) CardModel *cardModel;

/** Labels displayed on the cards (somewhat temporary for now) */
@property (strong) UILabel *nameLabel, *costLabel, *attackLabel, *lifeLabel, *cooldownLabel, *baseAbilityLabel, *addedAbilityLabel;

/** Overwritten center */
@property CGPoint center;

/** Position of the card without modifications from card state etc */
@property CGPoint originalPosition;

/** CardView's state, for positioning */
@property enum CardViewState cardViewState;

/** saves the position of its view index when being dragged */
@property int previousViewIndex;

/** Initializes with attached CardModel, which should be one of its child classes */
-(instancetype)initWithModel: (CardModel*)cardModel;

/** Updates its view after values are updated (i.e. lost life) */
-(void)updateView;

/** Refreshes its transformations by setting its cardView state to itself */
-(void)resetTransformations;

@end

/** Dimension of the card in its default state (i.e. on the field, in hand, etc.)*/
extern int CARD_WIDTH, CARD_HEIGHT;
/** Dimension of the card at its maximum zoom */
extern int CARD_FULL_WIDTH, CARD_FULL_HEIGHT;

/** Scales of the card during different states */
extern const float CARD_DEFAULT_SCALE, CARD_DRAGGING_SCALE;

/** Dimensions' ratio */
extern const int  CARD_WIDTH_RATIO, CARD_HEIGHT_RATIO;

/** State of the card's view for positioning */
enum CardViewState{
    cardViewStateNone,
    cardViewStateHighlighted,
    cardViewStateSelected,
    cardViewStateDragging
} ;