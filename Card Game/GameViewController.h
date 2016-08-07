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
#import "Level.h"
#import "CFButton.h"
#import "CFLabel.h"
#import "CardEditorViewController.h"
#import "MultiplayerNetworking.h"
#import "multiplayerDataHandler.h"
#import "MoveHistoryTableView.h"
@class GameModel;

/**
 Main class of the game that handles the view and controls
 */

@interface GameViewController : UIViewController <MultiplayerGameProtocol,multiplayerDataHandlerDelegate,MPGameProtocol>

@property (strong) GameModel *gameModel;

/** Layer that stores the hand cards */
@property (strong) ViewLayer *handsView;

/** Layer that stores the field*/
@property (strong) ViewLayer *fieldView;

/** Layer that stores the overlaying UI */
@property (strong) ViewLayer *uiView;

/** Layer that stores the background, behind everything else */
@property (strong) ViewLayer *backgroundView;

@property UIView*gameOverBlockingView;

/** Array storing the two player hero's views */
@property (strong) NSArray *playerHeroViews;

/** Holds an array of abilities that are currently waiting to be casted on a selected target. Assumes all targetType is identical to the first ability. If this array is not empty, then it is assumed that the game is waiting for the player to pick a target. */
@property (strong) NSMutableArray *currentAbilities;

@property (strong) UIButton* endTurnButton;

/** The card that has currently been maximized for viewing. While this is open, all other actions are disabled. This not only shows the card in large but also all the applied abilities that don't fit on the card. */
@property (strong) CardView* viewingCardView;

/** Counts the number of gameModel effecting animations that are happening. Do not access directly, use addAnimationCounter and decAnimationCounter */
@property int currentNumberOfAnimations;

@property enum GameMode gameMode;

/** Just a convinence variable. If this is set to YES then level must be non-nil */
@property BOOL isTutorial;

/** Cards are annoying as disabling their parent view doesn't work */
@property BOOL viewsDisabled;

/** Will know how many viewControllers to dismiss. General levels has a deck selector, but tutorials don't. When set to YES, will only dismiss one */
@property BOOL noPreviousView;

@property (strong) UIImageView *topView,*topRightView,*rightView,*bottomRightView,*bottomView,*bottomLeftView,*leftView,*topLeftView;

/** Note that while level is the current level, nextLevel is the level that will be immediately played following the current level. This should only be the case for the 3rd level, where it goes straight to the boss fight */ 
@property (strong)Level *level, *nextLevel;

//move history screen stuff
@property (strong)UIView*moveHistoryScreen;
@property (strong)StrokedLabel*moveHistoryLabel;
@property (strong)CFButton*moveHistoryBackButton;

@property (strong)MoveHistoryTableView*moveHistoryTableView;

//victory screen stuff
@property (strong)UIView*gameOverScreen;
@property (strong)StrokedLabel*resultsLabel, *rewardsLabel, *rewardGoldLabel, *rewardCardLabel, *eloRating, *eloRatingDiff;
@property (strong) StrokedLabel *overallLevelLabel, *xpIncreaseLabel;

@property (strong)UIImageView*rewardGoldImage, *rewardCardImage;
@property (strong)CFButton*gameOverOkButton, *gameOverRetryButton, *gameOverNoRetryButton;
@property (strong)UIActivityIndicatorView *gameOverProgressIndicator;
@property (strong)StrokedLabel*gameOverSaveLabel;
@property (assign) bool shouldBlink;
@property (assign) bool handMovementsLeft;
@property (assign) bool battleMovementsLeft;
@property (strong) CardModel* currentSpellCard;

@property (strong)CFButton*quitButton, *moveHistoryButton;

//tutorial stuff
@property (strong) CFLabel *tutLabel;
@property (strong) CFButton*tutOkButton;
@property (strong) UIImageView*arrowImage;
/** Keeps the CEVC to access the card that has been created for tutorial one */
@property (strong)CardEditorViewController *cevc;

/** Quick match deck stored here before GameModel is created */
@property (strong)DeckModel*quickMatchDeck;
@property BOOL quickMatchDeckLoaded;

/** for multiplayer */
@property (nonatomic, strong) MultiplayerNetworking *networkingEngine;
@property (nonatomic,strong) multiplayerDataHandler *MPDataHandler;

/** For multiplayer */
@property (strong) DeckModel*opponentDeck;
/** For when picking ability targets */
@property int currentCardIndex;
@property (nonatomic) uint32_t playerSeed, opponentSeed;

@property (strong) NSTimer *timer;
@property (strong) UIView *counterView;
@property (strong) UIView *counterSubView;
@property (assign) BOOL shouldCallEndTurn;

/* Card picker stuff */
@property (strong) UIView*cardPickerView;
@property (strong) StrokedLabel*cardPickerLabel, *cardPickerLabel2;
@property (strong) CardView*cardPickerCardView;
@property (strong) CFButton*cardPickerDoneButton, *cardPickerToggleButton;
//stores card models
@property (strong) NSMutableArray*currentPickingCards;

/* list of monsters will visual hint during combat (e.g. will die from attacking) */
@property (strong) NSMutableArray *hintedMonsters;

/** updates the position of all hands with the gameModel, adding views to cards that don't have one yet */
//-(void)updateHandsView;

-(instancetype)initWithGameMode:(enum GameMode)gameMode withLevel:(Level*)level;

/** Updates the views of the cards in hand */
-(void)updateHandsView: (int)side;

/** Gets X coordinate of a card on field  */
-(float)getFieldCardXWithCount: (int)count withIndex:(int)i;

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

-(void)newGame;

-(void)modalScreen;
-(void)unmodalScreen;
 
/** Quickly enable/disable all views */
-(void)setAllViews:(BOOL)state;

- (void)performBlock:(void (^)())block;

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;

-(void)gameOver;
-(void)setOpponentDeck: (DeckModel*)deck;
-(void)setCurrentSide:(int)side;
-(void)opponentSummonedCard:(int)cardIndex withTarget:(int)target;
-(void)setTimerFrames;

/* Note that this only exists for the player, will not see opponent picking */
-(void)mulliganCards:(NSMutableArray*)cards;

@end

int SCREEN_WIDTH, SCREEN_HEIGHT;

/* time between card draws when drawing multiple */
float CARD_DRAW_DELAY;
