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
#import "AbilityWrapper.h"
#import "StrokedLabel.h"
#import "CustomView.h"
#import "UserModel.h"
/**
 Handles the view aspect of the card. Draws the card based on the model object.
 The attached cardModel can be any of the child classes, such as MonsterCardModel or SpellCardModel.
 */
@interface CardView : UIImageView

/** Attached model for storing data of the card */
@property (strong) CardModel *cardModel;

/** Main view used for second layer of transformations */
@property (strong)UIView*transformView;

/** Views that are visible in the front facing mode */
@property (strong)UIView*frontViews;

@property (strong)UIImageView*backgroundImageView;

/** Unique image of the card */
@property (strong) UIImageView *cardImage;

/** Highlight of the card */
@property (strong) UIImageView *highlight;

@property enum CardHighlightType cardHighlightType;

/** Labels displayed on the cards (somewhat temporary for now) */
@property (strong) StrokedLabel *nameLabel, *costLabel, *attackLabel, *lifeLabel, *cooldownLabel, *elementLabel, *reportedLabel;

@property (strong) UITextView *baseAbilityLabel;

@property (strong) NSMutableArray *abilityIcons;

/** Overlay view used for showing combat hints such as if creature will die from attack */
@property (strong) UIImageView *combatHintView;

/** Pointer for keeping track of the move history value view in move history screen */
@property (strong) UIView *moveHistoryValueView;

/** Overwritten center */
@property CGPoint center;

/** Position of the card without modifications from card state etc */
@property CGPoint originalPosition;

/** CardView's state, for positioning */
@property enum CardViewState cardViewState;

/** saves the position of its view index when being dragged */
@property int previousViewIndex;

/** Set to YES during damage animations to prevent two happening at once. */
@property BOOL inDamageAnimation;
@property BOOL inDestructionAnimation;

@property BOOL lifeViewNeedsUpdate;
@property BOOL damageViewNeedsUpdate;
@property BOOL cooldownViewNeedsUpdate;
@property BOOL isKillHintOn;

/** Sets the current mode of display for different purposes */
@property enum CardViewMode cardViewMode;

/** Used as colour mask TODO change into image to fit the card */
@property UIView* mask;

/** For animating damages */
@property StrokedLabel *damagePopup;

/** For loading image */
@property int reloadAttempts;

@property UIActivityIndicatorView*activityView;

/** When set to NO, card back is displayed instead */
@property BOOL frontFacing;

/** Initializes with attached CardModel, which should be one of its child classes */
-(instancetype)initWithModel: (CardModel*)cardModel viewMode:(enum CardViewMode)cardViewMode;

-(instancetype)initWithModel: (CardModel*)cardModel withImage:(UIImage*)cardImage viewMode:(enum CardViewMode)cardViewMode;

-(instancetype)initWithModel:(CardModel *)cardModel viewMode:(enum CardViewMode)cardViewMode viewState:(enum CardViewState)cardViewState;

-(instancetype)initWithModel:(CardModel *)cardModel withImage:(UIImage*)cardImage viewMode:(enum CardViewMode)cardViewMode viewState:(enum CardViewState)cardViewState;

/** Updates its view after values are updated (i.e. lost life) */
-(void)updateView;

/** Refreshes its transformations by setting its cardView state to itself */
-(void)resetTransformations;

-(void)setPopupDamage:(int)damage;

/** Make any necessary animation when casting an ability (e.g. castOnHit flashing when hitting) */
-(void)castedAbility:(Ability*)ability;

-(UIColor*)getRarityColor;

//-(void)switchFacingTo:(BOOL)isFront;

/** Flips the card with animation */
-(void)flipCard;

/** Loads images for drawing cards ahead of time */
+(void) loadResources;

/** Shows hint for when dragging an attack causes a creature to be killed. */
-(void)animateIsKillHintOn:(BOOL)isKilled;

/** Note that the scale will be relative to CARD_DEFAULT_SCALE, not 1. Also should not use this for any card on game board */
-(void)setZoomScale:(float)scale;

@end

/** Dimension of the card in its default state (i.e. on the field, in hand, etc.)*/
extern int CARD_WIDTH, CARD_HEIGHT;
extern int CARD_GAMEPLAY_WIDTH, CARD_GAMEPLAY_HEIGHT;

/** Dimension of the card at its maximum zoom */
extern int CARD_FULL_WIDTH, CARD_FULL_HEIGHT;
extern int CARD_GAMEPLAY_FULL_WIDTH, CARD_GAMEPLAY_FULL_HEIGHT;

/** Dimension of the hero card */
extern int PLAYER_HERO_WIDTH, PLAYER_HERO_HEIGHT;

/** Scales of the card during different states */
extern float CARD_DEFAULT_SCALE, CARD_DRAGGING_SCALE;

extern float CARD_GAMEPLAY_SCALE;

/** Dimensions' ratio */
extern int  CARD_WIDTH_RATIO, CARD_HEIGHT_RATIO;

extern float CARD_IMAGE_RATIO;

extern double CARD_VIEWER_SCALE, CARD_VIEWER_MAXED_SCALE;

extern int CARD_IMAGE_WIDTH, CARD_IMAGE_HEIGHT;

extern int CARD_NAME_SIZE;
extern int CARD_LIKE_ICON_WIDTH;

extern int CARD_DAMAGE_POPUP_SIZE;
extern float DAMAGE_POPUP_DURATION;

extern int CARD_DETAIL_BUTTON_WIDTH;
extern int CARD_DETAIL_BUTTON_HEIGHT;

/** State of the card's view for positioning */
enum CardViewState{
    cardViewStateNone,
    cardViewStateHighlighted,
    cardViewStateSelected,
    cardViewStateDragging,
    cardViewStateMaximize,
    cardViewStateCardViewer,
    cardViewStateCardViewerGray,
    cardViewStateCardViewerTransparent,
} ;

enum CardHighlightType
{
    cardHighlightNone,
    cardHighlightSelect,
    cardHighlightTarget,
};

/** For when the cardView is used for different purposes */
enum CardViewMode
{
    /** General case during in-game */
    cardViewModeIngame,
    /** When being maximized in game */
    cardViewModeZoomedIngame,
    /** When viewed in an editor outside of games. Does not animate when values change. */
    cardViewModeEditor,
    cardViewModeToValidate,
};

enum CardAbilityIcon
{
    abilityIconCastOnMove,
    abilityIconCastOnDeath,
    abilityIconCastOnHit,
    abilityIconCastOnDamaged,
    abilityIconTaunt,
    abilityIconAssassin,
    abilityIconPierce,
    abilityIconRemoveAbility,
};

enum CardOverlayObject
{
    cardOverlayObjectText,
    cardOverlayObjectDeath,
    cardOverlayObjectMulligan,
};

NSString *cardMainFont;
NSString *cardMainFontBlack, *cardFlavourTextFont;

UIImage*placeHolderImage;
UIImage*PLAYER_FIRST_CARD_IMAGE;
UIImage *killHintImage;

NSDictionary *campaignHeroImages;
