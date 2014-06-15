//
//  ViewController.h
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameModel.h"
#import "ViewLayer.h"
@class GameModel;

/**
 Main class of the game that handles the view and controls
 */
@interface GameViewController : UIViewController

@property (strong) GameModel *gameModel;

/** Layer that stores the hand cards */
@property (strong) ViewLayer *handsView;

/** Layer that stores the field*/
@property (strong) ViewLayer *fieldView;

/** Layer that stores the overlaying UI */
@property (strong) ViewLayer *uiView;

/** Layer that stores the background, behind everything else */
@property (strong) ViewLayer *backgroundView;

/** Array storing the two player hero's views */
@property (strong) NSArray *playerHeroViews;

/** Holds an array of abilities that are currently waiting to be casted on a selected target. Assumes all targetType is identical to the first ability. If this array is not empty, then it is assumed that the game is waiting for the player to pick a target. */
@property (strong) NSMutableArray *currentAbilities;

@property (strong) UIButton* endTurnButton;

/** The card that has currently been maximized for viewing. While this is open, all other actions are disabled. This not only shows the card in large but also all the applied abilities that don't fit on the card. */
@property (strong) CardView* viewingCardView;
@property (strong) CardModel* viewingCardStart;
@property CGPoint touchStartPoint;

/** updates the position of all hands with the gameModel, adding views to cards that don't have one yet */
//-(void)updateHandsView;

/** Updates the views of the cards in hand */
-(void)updateHandsView: (int)side;

/** Updates the views of the cards in field */
-(void)updateBattlefieldView: (int)side;

/** Updates the resource lable */
-(void)updateResourceView: (int)side;

/** Informed by the model to pick a target for all the abilities. This adds the ability to currentAbilities and sets the UI model to selecting target so it can be called several times by a single card. Note that this cannot be used by the AI, and only by the Player. caster should be the MonsterCardModel or SpellCardModel that is casting the ability. */
-(void)pickAbilityTarget: (Ability*) ability castedBy:(CardModel*)caster;

/** Called to perform the views necessary to summon the card. Calls GameModel's summon card method. */
-(void)summonCard: (CardModel*)card fromSide: (int)side;

/** Called to perform the end turn event */
-(void) endTurn;

-(void) attackCard: (CardModel*) card target:(MonsterCardModel*)targetCard fromSide: (int) side;

-(void) attackHero: (CardModel*) card target:(MonsterCardModel*)targetCard fromSide: (int) side;

- (void)performBlock:(void (^)())block;

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;

@end
