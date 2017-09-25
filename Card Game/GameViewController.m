//
//  ViewController.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "GameViewController.h"
#import "GameViewController+Animation.h"
#import "GameViewController+Tutorial.h"
#import "CardView.h"
#import "MonsterCardModel.h"
#import "CGPointUtilities.h"
#import "MainScreenViewController.h"
#import "GameInfoTableView.h"
#import "Campaign.h"
#import "BossBattleScreenViewController.h"
#import "DHConstraintUtility.h"
@import SceneKit;
@import SpriteKit;

@interface GameViewController ()

//brian Oct 9
//new properties for tracking 3d scene
@property (nonatomic) SCNNode *cameraNode;
@property (nonatomic) SCNCamera *firstCam;
@property (nonatomic) SCNNode *secondaryCamera;
@property (nonatomic) SCNCamera *secondCam;
@property (nonatomic) SCNView *myView;
@property (nonatomic) BOOL isZoomed;

@end

@implementation GameViewController

@synthesize gameModel                 = _gameModel;
@synthesize handsView, fieldView, uiView, backgroundView;
@synthesize currentAbilities          = _currentAbilities;
@synthesize endTurnButton             = _endTurnButton;
@synthesize currentNumberOfAnimations = _currentNumberOfAnimations;
@synthesize tutLabel                  = _tutLabel;
@synthesize tutOkButton               = _tutOkButton;
@synthesize quickMatchDeck            = _quickMatchDeck;
@synthesize quickMatchDeckLoaded      = _quickMatchDeckLoaded;
@synthesize currentSpellCard;
@synthesize hintedMonsters = _hintedMonsters;



/** Screen dimension for convinience */
int SCREEN_WIDTH, SCREEN_HEIGHT;

float CARD_DRAW_DELAY = 1.2f;

/** current side's turn, i.e. current player */
int currentSide;

/** eloRating old and new */

int oldEloRating;
int newEloRating;

const float FIELD_CENTER_Y_RATIO = 3/8.f;

/** UILabel used to darken the screen during card selections */
UIView *darkFilter;

/** label for representing the attack line when targetting monsters (may improve visual in future) */
UILabel *attackLine;

/** stores array of two label for showing the current player's resource */
NSArray *resourceLabels;
NSArray *healthLabels;

UIImageView *playerFieldHighlight, *opponentFieldHighlight, *playerFieldEdge, *opponentFieldEdge;

UIImageView *battlefieldBackground,*backEndTurn;

CFButton *quitConfirmButton, *quitCancelButton;

UILabel *quitConfirmLabel;

CGRect topFrame,topRightFrame,rightFrame,bottomRightFrame,bottomFrame,bottomLeftFrame,leftFrame,topLeftFrame;

@synthesize topView,topRightView,rightView,bottomRightView,bottomView,bottomLeftView,leftView,topLeftView;

StrokedLabel *pickATargetLabel;
CFButton *giveupAbilityButton;

GameInfoTableView*extraAbilityView, *abilityDescriptionView;

/** Stores the current UI action being performed */
enum GameControlState gameControlState;

enum GameControlState{
    gameControlStateNone, //not performing anything
    //gameControlStateSelectedHandCard, //selected a card in hand
    //gameControlStateSelectedFieldCard, //selected a card in field
    gameControlStateDraggingHandCard,
    gameControlStateDraggingFieldCard,
} ;

/** Currently selected card. The actual card depends on gameControlState. E.g. during gameControlStateSelectedHandCard this card is a card in the hand */
CardModel* currentCard;

/** Used to reduce amount of calculation needed for viewing hand cards via dragging. This flag is set when a touch enters/leaves the zone so it only needs to be updated once */
BOOL leftHandViewZone = NO;

/** remembers if move history is open */
BOOL moveHistoryOpen = NO;
/** remembers if pick card/mulligan screen is open */
BOOL pickingCards = NO;

// ------------------------------------------------------------------------------------------------
- (instancetype) initWithGameMode: (enum GameMode)  gameMode
                        withLevel: (Level*)         level
// ------------------------------------------------------------------------------------------------
{
    self = [super init];
    
    if (self)
    {
        _gameMode = gameMode;
        _level = level;
        
        currentSide = PLAYER_SIDE;
        
        if (level!=nil)
        {
            if (level.playerGoesFirst)
                currentSide = PLAYER_SIDE;
            else
                currentSide = OPPONENT_SIDE;
            
            if (!level.breakBeforeNextLevel)
            {
                _nextLevel = [Campaign getNextLevelWithLevelID:level.levelID];
            }
            
            _isTutorial = _level.isTutorial;
        }
        
        //inits array
        self.currentAbilities = [NSMutableArray array];
        self.hintedMonsters = [NSMutableArray array];
        
        _quickMatchDeckLoaded = FALSE;
        
        if (level == [Campaign quickMatchLevel])
        {
        [self performBlockInBackground:^{
            _quickMatchDeck = [[DeckModel alloc] init];
            [GameModel loadQuickMatchDeck:_quickMatchDeck];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _quickMatchDeckLoaded = TRUE;
                
                if (self.gameModel != nil)
                {
                    [self undarkenScreen];
                    [self loadDeckFinished];
                    
                    NSArray*decks = @[self.gameModel.decks[PLAYER_SIDE], _quickMatchDeck];
                    
                    self.gameModel.decks = decks;
                    [self.gameModel startGame];
                    if (!_isTutorial && !self.shouldCallEndTurn && self.gameMode == GameModeMultiplayer)
                        [self startEndTurnTimer];
                }
            });
        }];
        }
        
        
    }
    oldEloRating = [[userPF objectForKey:@"eloRating"] intValue];
    
    return self;
}
// ------------------------------------------------------------------------------------------------
- (void)viewDidLoad
// ------------------------------------------------------------------------------------------------
{
    [super viewDidLoad];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
    [self tutorialSetup];
    
    gameControlState = gameControlStateNone;
    
    //inits the game model storing the game's data
    self.gameModel = [[GameModel alloc] initWithViewController:(self) gameMode:_gameMode withLevel:_level];
    self.gameModel.opponentDeck = _opponentDeck;
    
    //TODO this is really stupid, currentSide should be gameModel's property..
    PlayerModel *player = self.gameModel.players[currentSide];
    player.maxResource++;
    player.resource = player.maxResource;
    
    //contains most of the code for initialzing and positioning the UI objects
    [self setupUI];
    
    //start a new game, each player draws three cards
    if ([TUTORIAL_ONE isEqualToString:_level.levelID]   ||
        [TUTORIAL_TWO isEqualToString:_level.levelID]   ||
        [TUTORIAL_THREE isEqualToString:_level.levelID] ||
        [TUTORIAL_FOUR isEqualToString:_level.levelID])
    {
        //these tutorials do not start game immediately
    }
    /*
    else if (_gameMode == GameModeMultiplayer)
    {
        //gotta wait for cards to arrive before starting
    }*/
    else
    {
        if (_gameMode == GameModeMultiplayer)
        {
            [_gameModel setPlayerSeed:_playerSeed];
            [_gameModel setOpponentSeed:_opponentSeed];
            [_gameModel loadDecks];
        }
        
        if (_level == [Campaign quickMatchLevel])
        {
            if (!_quickMatchDeckLoaded)
            {
                [self loadDeckStart];
                NSLog(@"loading quick match");
            }
        }
        else
        {
            NSLog(@"not loading quick match");
            [self.gameModel startGame];
        }
        
    }
    //add all cards onto screen
    [self updateHandsView: PLAYER_SIDE];
    [self updateHandsView: OPPONENT_SIDE];
    [self updateResourceView: PLAYER_SIDE];
    [self updateResourceView: OPPONENT_SIDE];
    
    self.currentNumberOfAnimations = 0; //init
    
    if (_isTutorial)
    {
        CFButton*skipButton = [[CFButton alloc] initWithFrame:CGRectMake(0,0,80,40)];
        [skipButton setTextSize:12];
        skipButton.label.text = @"Skip";
        skipButton.center = CGPointMake(42, 30);
        [skipButton addTarget:self
                       action:@selector(skipButtonPressed)
             forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:skipButton];
        [self tutorialMessageGameStart];
    }
    
    
}
// ------------------------------------------------------------------------------------------------
- (void) skipButtonPressed
// ------------------------------------------------------------------------------------------------
{
    
    userPF[@"completedLevels"] = @[@"d_1_c_1_l_1",@"d_1_c_1_l_2",@"d_1_c_1_l_4"];
    NSError *error;
    [userPF save:&error];
    
    //Create a deck
    if ([userAllDecks count] == 0) {
        DeckModel* newDeck = [[DeckModel alloc] init];
        newDeck.name = @"New Deck";
        
        for (CardModel* card in userAllCards){
            if (newDeck.cards.count < 20) {
                [newDeck addCard:card];
            }else
                break;
           
        }
        [UserModel saveDeck:newDeck];
    }
   
    
    MainScreenViewController *mainController = [[MainScreenViewController alloc] init];
    mainController.loadedTutorial = YES;
    [self presentViewController:mainController animated:YES completion:nil];
}

// ------------------------------------------------------------------------------------------------
/** Purely for organization, called once when the view is first set up */
- (void) setupUI
// ------------------------------------------------------------------------------------------------
{
    //brian oct 9 2016
        //updating to add new 3d battle screen in background to main game view controller
        self.myView = [[SCNView alloc] init];
        self.myView.frame = self.view.frame;
        self.myView.scene = [SCNScene sceneNamed:@"battle_bg.dae"];
        self.isZoomed = FALSE;
        
        self.secondaryCamera = [SCNNode node];
    //old value 440
    
        self.secondaryCamera.position = SCNVector3Make(0, 0, 480);
        self.secondaryCamera.rotation = SCNVector4Zero;
        self.secondCam = [SCNCamera camera];
        self.secondCam.zNear = 109;
        self.secondCam.zFar = 27350;
    //70 before nov-30-2016
        self.secondCam.yFov = 60;
        self.secondaryCamera.camera = self.secondCam;
        //self.cameraNode.camera.zNear = 109;
        //self.cameraNode.camera.zFar = 27350;
        [self.myView.scene.rootNode addChildNode:self.secondaryCamera];
        
        self.cameraNode = [SCNNode node];
    //old value 840
        self.cameraNode.position = SCNVector3Make(0,0,980);
        self.cameraNode.rotation = SCNVector4Zero;
        self.cameraNode.camera = self.secondCam;
        //self.cameraNode = self.myView.pointOfView;
        [self.myView.scene.rootNode addChildNode:self.cameraNode];
        
        SCNNode *povNode = self.myView.pointOfView;
    
        povNode.position = SCNVector3Make(0,0,980);
        SCNCamera *checkCamDetails = povNode.camera;
        
        self.myView.pointOfView = povNode;
        
        SCNScene *cfButtonScene = [SCNScene sceneNamed:@"battle_button.dae"];
        SCNVector3 cfButtonVector = cfButtonScene.rootNode.position;
        cfButtonVector.z +=00;
        [cfButtonScene.rootNode setPosition:cfButtonVector];
        
        for (SCNNode* objectNode in cfButtonScene.rootNode.childNodes)
        {
            [self.myView.scene.rootNode addChildNode:objectNode];
        }
        
        SCNScene *enemy_life = [SCNScene sceneNamed:@"battle_enemy_life.dae"];
        [self.myView.scene.rootNode addChildNode:enemy_life.rootNode];
        
        SCNScene *playerLife = [SCNScene sceneNamed:@"battle_player_life.dae"];
        [self.myView.scene.rootNode addChildNode:playerLife.rootNode];
        
        SCNScene *enemyCardArea = [SCNScene sceneNamed:@"enemy_played_card.dae"];
        [self.myView.scene.rootNode addChildNode:enemyCardArea.rootNode];
        
        SCNScene *enemyMana = [SCNScene sceneNamed:@"battle_enemy_mana.dae"];
        [self.myView.scene.rootNode addChildNode:enemyMana.rootNode];
        
        SCNScene *playerMana = [SCNScene sceneNamed:@"battle_player_mana.dae"];
        [self.myView.scene.rootNode addChildNode:playerMana.rootNode];
        
        SCNScene *playerPortrait = [SCNScene sceneNamed:@"battle_player_portrait.dae"];
        [self.myView.scene.rootNode addChildNode:playerPortrait.rootNode];
        
        SCNScene *enemyPortrait = [SCNScene sceneNamed:@"battle_enemy_portrait.dae"];
        [self.myView.scene.rootNode addChildNode:enemyPortrait.rootNode];
        
        SCNCamera *povCamera = self.myView.pointOfView.camera;
        
        povCamera.xFov = 00;
        povCamera.yFov = 60;
        
        //[self.myView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped:)]];
        
        self.myView.allowsCameraControl = NO;
        self.myView.autoenablesDefaultLighting = NO;
        self.myView.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:self.myView];
    
    //end brian oct 9
    
    //set up UI
    darkFilter = [[UIView alloc] initWithFrame:self.view.bounds];
    darkFilter.backgroundColor = [[UIColor alloc]initWithHue:0 saturation:0 brightness:0 alpha:0.8];
    [darkFilter setUserInteractionEnabled:YES]; //blocks all interaction behind it
    
    //----Main view layers used to group relevant objects together----//
    handsView = [[ViewLayer alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    fieldView = [[ViewLayer alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    uiView = [[ViewLayer alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    backgroundView = [[ViewLayer alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    handsView.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    fieldView.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    uiView.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    backgroundView.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    backgroundView.backgroundColor = [UIColor clearColor];
    
    
    [self.myView addSubview:backgroundView];
    [self.myView addSubview:fieldView];
    [self.myView addSubview:handsView];
    [self.myView addSubview:uiView];
    
    /*
    battlefieldBackground  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"battle_background_0"]];
    battlefieldBackground.center = self.view.center;
    battlefieldBackground.frame = self.view.frame;
    [backgroundView addSubview:battlefieldBackground];
    */
    
    //----set up the attack line----//
    attackLine = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0, 0)];
    attackLine.backgroundColor = [UIColor colorWithRed:0.67 green:0.08 blue:0 alpha:0.6];
    
    //----set up the resource labels----//
    //brianMar27
    //customize resourceSection for iPad UI
    float baseScreenHeight = 1334.0f/2.0f;
    float baseScreenWidth = 750.0f/2.0f;
    
    
    float labelSizeWidth = 60/baseScreenWidth*SCREEN_WIDTH;
    float labelSizeHeight = 30/baseScreenHeight*SCREEN_HEIGHT;
    
    int iPadManaGemFont = 40;
    int iPhoneManaGemFont = 20;
    
    int manaGemFont;
    
    if (IS_IPAD)
    {
        manaGemFont = iPadManaGemFont;
    }
    else
    {
        manaGemFont = iPhoneManaGemFont;
    }
    
    //brian oct 9
    //add dimension changes relative to screen size and move the mana icons
    
    StrokedLabel*playerResourceLabel              = [[StrokedLabel alloc] initWithFrame: CGRectMake(0, 0, labelSizeWidth, labelSizeHeight)];
    playerResourceLabel.center                    = CGPointMake(60/baseScreenWidth*SCREEN_WIDTH, SCREEN_HEIGHT - (60/baseScreenHeight*SCREEN_HEIGHT));
    playerResourceLabel.textAlignment             = NSTextAlignmentCenter;
    playerResourceLabel.textColor                 = [UIColor whiteColor];
    playerResourceLabel.backgroundColor           = [UIColor clearColor];
    playerResourceLabel.font                      = [UIFont fontWithName:cardMainFont size:manaGemFont];
    playerResourceLabel.adjustsFontSizeToFitWidth = YES;
    playerResourceLabel.strokeColour              = [UIColor blackColor];
    playerResourceLabel.strokeOn                  = YES;
    playerResourceLabel.strokeThickness           = 3;
    UIImageView *playerResourceIcon               = [[UIImageView alloc] initWithImage:RESOURCE_ICON_IMAGE];
    
    float playerResourceIconWidth = 45/baseScreenWidth*SCREEN_WIDTH;
    float playerResourceIconHeight = 45/baseScreenWidth*SCREEN_WIDTH;
    playerResourceIcon.frame                      = CGRectMake(0, 0, playerResourceIconWidth, playerResourceIconHeight);
    
    playerResourceIcon.center                     = playerResourceLabel.center;
    
    StrokedLabel*opponentResourceLabel              = [[StrokedLabel alloc] initWithFrame: CGRectMake(0,0, labelSizeWidth, labelSizeHeight)];
    opponentResourceLabel.center                    = CGPointMake(60/baseScreenWidth*SCREEN_WIDTH, 50/baseScreenHeight*SCREEN_HEIGHT);
    opponentResourceLabel.textAlignment             = NSTextAlignmentCenter;
    opponentResourceLabel.textColor                 = [UIColor whiteColor];
    opponentResourceLabel.backgroundColor           = [UIColor clearColor];
    opponentResourceLabel.font                      = [UIFont fontWithName:cardMainFont size:manaGemFont];
    opponentResourceLabel.adjustsFontSizeToFitWidth = YES;
    opponentResourceLabel.strokeColour              = [UIColor blackColor];
    opponentResourceLabel.strokeOn                  = YES;
    opponentResourceLabel.strokeThickness           = 3;
    UIImageView *opponentResourceIcon               = [[UIImageView alloc] initWithImage:RESOURCE_ICON_IMAGE];
    opponentResourceIcon.frame                      = CGRectMake(0, 0, playerResourceIconWidth, playerResourceIconHeight);
    opponentResourceIcon.center                     = opponentResourceLabel.center;
    resourceLabels                                  = @[playerResourceLabel,opponentResourceLabel];
    
    [self.uiView addSubview:playerResourceIcon];
    [self.uiView addSubview:opponentResourceIcon];
    [self.uiView addSubview:resourceLabels[PLAYER_SIDE]];
    [self.uiView addSubview:resourceLabels[OPPONENT_SIDE]];
    
    //brian nov 13
    //add player and opponent health icons/labels
    StrokedLabel*playerHealthLabel              = [[StrokedLabel alloc] initWithFrame: CGRectMake(0, 0, labelSizeWidth, labelSizeHeight)];
    playerHealthLabel.center                    = CGPointMake(315/baseScreenWidth*SCREEN_WIDTH, SCREEN_HEIGHT - (60/baseScreenHeight*SCREEN_HEIGHT));
    playerHealthLabel.textAlignment             = NSTextAlignmentCenter;
    playerHealthLabel.textColor                 = [UIColor whiteColor];
    playerHealthLabel.backgroundColor           = [UIColor clearColor];
    playerHealthLabel.font                      = [UIFont fontWithName:cardMainFont size:manaGemFont];
    playerHealthLabel.adjustsFontSizeToFitWidth = YES;
    playerHealthLabel.strokeColour              = [UIColor blackColor];
    playerHealthLabel.strokeOn                  = YES;
    playerHealthLabel.strokeThickness           = 3;
    UIImageView *playerHealthIcon               = [[UIImageView alloc] initWithImage:RESOURCE_ICON_IMAGE];
    
    float playerHealthIconWidth = 45/baseScreenWidth*SCREEN_WIDTH;
    float playerHealthIconHeight = 45/baseScreenWidth*SCREEN_WIDTH;
    playerHealthIcon.frame                      = CGRectMake(0, 0, playerHealthIconWidth, playerHealthIconHeight);
    
    playerHealthIcon.center                     = playerHealthLabel.center;
    
    StrokedLabel*opponentHealthLabel              = [[StrokedLabel alloc] initWithFrame: CGRectMake(0,0, labelSizeWidth, labelSizeHeight)];
    opponentHealthLabel.center                    = CGPointMake(315/baseScreenWidth*SCREEN_WIDTH, 50/baseScreenHeight*SCREEN_HEIGHT);
    opponentHealthLabel.textAlignment             = NSTextAlignmentCenter;
    opponentHealthLabel.textColor                 = [UIColor whiteColor];
    opponentHealthLabel.backgroundColor           = [UIColor clearColor];
    opponentHealthLabel.font                      = [UIFont fontWithName:cardMainFont size:manaGemFont];
    opponentHealthLabel.adjustsFontSizeToFitWidth = YES;
    opponentHealthLabel.strokeColour              = [UIColor blackColor];
    opponentHealthLabel.strokeOn                  = YES;
    opponentHealthLabel.strokeThickness           = 3;
    UIImageView *opponentHealthIcon               = [[UIImageView alloc] initWithImage:RESOURCE_ICON_IMAGE];
    opponentHealthIcon.frame                      = CGRectMake(0, 0, playerResourceIconWidth, playerResourceIconHeight);
    opponentHealthIcon.center                     = opponentHealthLabel.center;
    healthLabels                                  = @[playerHealthLabel,opponentHealthLabel];
    
    [self.uiView addSubview:playerHealthIcon];
    [self.uiView addSubview:opponentHealthIcon];
    [self.uiView addSubview:healthLabels[PLAYER_SIDE]];
    [self.uiView addSubview:healthLabels[OPPONENT_SIDE]];
    
    
    //----set up the field highlights----//
    playerFieldHighlight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_highlight"]];
    opponentFieldHighlight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_highlight"]];
    
    //brian oct 9 change to not show edges
    //todo--find a better way to fix this than making these an unknown image.
    //original images are pngs
    
    playerFieldEdge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GameBoardPlayedCardsBorder2.pnr"]];
    opponentFieldEdge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GameBoardPlayedCardsBorder2.pnr"]];
    
    
    //half of the distance between the two fields
    int fieldsDistanceHalf = 5;
    
    //fields are not at center Y, instead move up a little since opponent has no end button
    int fieldsYOffset = 0; //TODO probably make this dynamic
    
    
    //brian mar27 trying to fix hero position and card fields position
    //opponent field position y = 400/1344.0f;
    //player field position y = 680/1344.0f
    
    
    if (IS_IPAD)
    {
        
        playerFieldHighlight.bounds = CGRectMake(0,0,(CARD_GAMEPLAY_WIDTH *5) + CARD_GAMEPLAY_HEIGHT*0.1f, CARD_GAMEPLAY_HEIGHT + CARD_GAMEPLAY_HEIGHT * 0.1);
        playerFieldHighlight.center = CGPointMake(SCREEN_WIDTH/2, 800/1344.0f*SCREEN_HEIGHT) ;
        
        playerFieldEdge.bounds = CGRectMake(0,0,(CARD_GAMEPLAY_WIDTH*5)  + CARD_GAMEPLAY_HEIGHT * 0.1, CARD_GAMEPLAY_HEIGHT + CARD_GAMEPLAY_HEIGHT * 0.1);
        playerFieldEdge.center = CGPointMake(SCREEN_WIDTH/2, 800/1344.0f*SCREEN_HEIGHT) ;
        
        opponentFieldHighlight.bounds = CGRectMake(0,0,(CARD_GAMEPLAY_WIDTH*5)  + CARD_GAMEPLAY_HEIGHT * 0.1, CARD_GAMEPLAY_HEIGHT + CARD_GAMEPLAY_HEIGHT * 0.1);
        opponentFieldHighlight.center = CGPointMake(SCREEN_WIDTH/2, 450/1344.0f*SCREEN_HEIGHT) ;
        
        opponentFieldEdge.bounds = CGRectMake(0,0,(CARD_GAMEPLAY_WIDTH*5) + CARD_GAMEPLAY_HEIGHT * 0.1, CARD_GAMEPLAY_HEIGHT + CARD_GAMEPLAY_HEIGHT * 0.1);
        opponentFieldEdge.center = CGPointMake(SCREEN_WIDTH/2, 450/1344.0f*SCREEN_HEIGHT) ;
        
      
        playerFieldHighlight.bounds = CGRectMake(0,0,(CARD_WIDTH * 5)  + CARD_HEIGHT * 0.1, CARD_HEIGHT + CARD_HEIGHT * 0.1);
        playerFieldHighlight.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/3 + fieldsDistanceHalf + playerFieldHighlight.bounds.size.height/2 + fieldsYOffset) ;
        
        playerFieldEdge.bounds = CGRectMake(0,0,(CARD_WIDTH * 5)  + CARD_HEIGHT * 0.1, CARD_HEIGHT + CARD_HEIGHT * 0.1);
        playerFieldEdge.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/3 + fieldsDistanceHalf + playerFieldEdge.bounds.size.height/2 + fieldsYOffset) ;
        
    }
    else if (IS_IPHONE)
    {
        playerFieldHighlight.bounds = CGRectMake(0,0,(CARD_WIDTH * 5)  + CARD_HEIGHT * 0.1, CARD_HEIGHT + CARD_HEIGHT * 0.1);
        playerFieldHighlight.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + fieldsDistanceHalf + playerFieldHighlight.bounds.size.height/2 + fieldsYOffset) ;
        
        playerFieldEdge.bounds = CGRectMake(0,0,(CARD_WIDTH * 5)  + CARD_HEIGHT * 0.1, CARD_HEIGHT + CARD_HEIGHT * 0.1);
        playerFieldEdge.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + fieldsDistanceHalf + playerFieldEdge.bounds.size.height/2 + fieldsYOffset) ;
        
        opponentFieldHighlight.bounds = CGRectMake(0,0,(CARD_WIDTH * 5)  + CARD_HEIGHT * 0.1, CARD_HEIGHT + CARD_HEIGHT * 0.1);
        opponentFieldHighlight.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - fieldsDistanceHalf - opponentFieldHighlight.bounds.size.height/2 + fieldsYOffset) ;
        
        opponentFieldEdge.bounds = CGRectMake(0,0,(CARD_WIDTH * 5)  + CARD_HEIGHT * 0.1, CARD_HEIGHT + CARD_HEIGHT * 0.1);
        opponentFieldEdge.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - fieldsDistanceHalf - opponentFieldEdge.bounds.size.height/2 + fieldsYOffset) ;

    }
    
    playerFieldHighlight.alpha = 0;
    
    [self.backgroundView addSubview:playerFieldHighlight];
    [self.backgroundView addSubview:playerFieldEdge];
    
    
    opponentFieldHighlight.alpha = 0;
    
    [self.backgroundView addSubview:opponentFieldHighlight];
    [self.backgroundView addSubview:opponentFieldEdge];
    
    //brianMar27 update player hero code for iPad UI
    //-----Player's heroes-----//
    
    CardView *playerHeroView = [[CardView alloc] initWithModel:((PlayerModel*)self.gameModel.players[PLAYER_SIDE]).playerMonster viewMode:cardViewModeIngame];
    playerHeroView.frontFacing = YES;
    float playerHeroYCenter = 545/baseScreenHeight*SCREEN_HEIGHT;
    playerHeroView.center = CGPointMake((SCREEN_WIDTH/2), playerHeroYCenter);
    playerHeroView.cardModel.name = userPF.username;
    [playerHeroView updateView];
    [self.fieldView addSubview:playerHeroView];
    
    if (_level!=nil && !_level.isBossFight) //boss fight's is not the same
    {
        ((PlayerModel*)self.gameModel.players[OPPONENT_SIDE]).playerMonster.idNumber = _level.heroId;
    }
    
    CardView *opponentHeroView = [[CardView alloc] initWithModel:((PlayerModel*)self.gameModel.players[OPPONENT_SIDE]).playerMonster viewMode:cardViewModeIngame];
    opponentHeroView.frontFacing = YES;
    float opponentHeroYCenter = 104/baseScreenHeight*SCREEN_HEIGHT;
    opponentHeroView.center = CGPointMake((SCREEN_WIDTH/2), opponentHeroYCenter);
    
    //brian nov 13
    //set exact position of opponent hero view
    
    
    if (_level != nil)
    {
        if (_level.isBossFight)
            opponentHeroView.center = CGPointMake(SCREEN_WIDTH/2, opponentFieldHighlight.center.y);
    }
    [self.fieldView addSubview:opponentHeroView];
    
    self.playerHeroViews = @[playerHeroView, opponentHeroView];
    
    //----set up counter view-------//
    self.counterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
    self.counterView.backgroundColor = [UIColor whiteColor];
    [self.counterView setHidden:YES];
    [self.counterView.layer setZPosition:0.0];
    [self.counterView setCenter:CGPointMake(SCREEN_WIDTH/2 - self.counterView.frame.size.width/4, playerFieldEdge.frame.origin.y + playerFieldEdge.frame.size.height + self.counterView.frame.size.height/2)];
    self.counterSubView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 50, self.counterView.frame.size.height)];
    [self.counterSubView setBackgroundColor:[UIColor redColor]];
    
    [self.counterView addSubview:self.counterSubView];
    [self.view addSubview:self.counterView];
    
    
    /*UIView*backgroundOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"battle_background_0_overlay"]];
    backgroundOverlay.frame = self.view.bounds;
    [self.backgroundView addSubview:backgroundOverlay];*/
    
    //----end turn button----//
    //UIImage* endTurnImage = [UIImage imageNamed:@"end_turn_button_up.png"]; //TODO all these images to load function
    //UIImage* endTurnDisabledImage = [UIImage imageNamed:@"end_turn_button_disabled.png"];
    
    self.endTurnButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 35)];
    
    [self.endTurnButton setImage:[UIImage imageNamed:@"end_turn_button_up"] forState:UIControlStateNormal];
    [self.endTurnButton setImage:[UIImage imageNamed:@"end_turn_button_disabled"] forState:UIControlStateDisabled];
    //self.endTurnButton.buttonStyle = CFButtonStyleWarning;
    //self.endTurnButton.label.text = @"END\nTURN";
    //[self.endTurnButton setTextSize:13];
    //[button setTitle:@"test" forState:UIControlStateNormal];
    [self.endTurnButton setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
    
    //[self.endTurnButton setBackgroundImage:endTurnImage forState:UIControlStateNormal];
    //[self.endTurnButton setBackgroundImage:endTurnDisabledImage forState:UIControlStateDisabled];
    [self.endTurnButton addTarget:self action:@selector(endTurn)    forControlEvents:UIControlEventTouchUpInside];
    
    
    backEndTurn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
    [backEndTurn setImage:[UIImage imageNamed:@"timer_background"]];
    backEndTurn.center =   CGPointMake(SCREEN_WIDTH - (SCREEN_WIDTH - playerFieldEdge.bounds.size.width)/2 - self.endTurnButton.frame.size.width/2, playerFieldEdge.center.y + playerFieldEdge.bounds.size.height/2 + fieldsDistanceHalf*2 + self.endTurnButton.frame.size.height/2);
    
    [self.backgroundView addSubview:backEndTurn];

    
    ////// ADD COUNTER GREEN INDICATOR //////////////
    
    topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 3)];
    [topView setImage:[UIImage imageNamed:@"timer_rect"]];
    
    topRightFrame = CGRectMake(0, 0, 8, 8);
    topRightView = [[UIImageView alloc] initWithFrame:topRightFrame];
    [topRightView setImage:[UIImage imageNamed:@"timer_curve"]];
    
    
    rightView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 3)];
    [rightView setImage:[UIImage imageNamed:@"timer_rect"]];
    rightView.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    bottomRightFrame = CGRectMake(0, 0, 8, 8);
    bottomRightView = [[UIImageView alloc] initWithFrame:bottomRightFrame];
    [bottomRightView setImage:[UIImage imageNamed:@"timer_curve"]];
    bottomRightView.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 3)];
    [bottomView setImage:[UIImage imageNamed:@"timer_rect"]];
    
    bottomLeftFrame = CGRectMake(0, 0, 8, 8);
    bottomLeftView = [[UIImageView alloc] initWithFrame: bottomLeftFrame];
    [bottomLeftView setImage:[UIImage imageNamed:@"timer_curve"]];
    bottomLeftView.transform = CGAffineTransformMakeRotation(M_PI);
    
    leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 3)];
    [leftView setImage:[UIImage imageNamed:@"timer_rect"]];
    leftView.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    topLeftFrame = CGRectMake(0, 0, 8, 8);
    topLeftView = [[UIImageView alloc] initWithFrame:topLeftFrame];
    [topLeftView setImage:[UIImage imageNamed:@"timer_curve"]];
    topLeftView.transform = CGAffineTransformMakeRotation(- M_PI_2);
    
    
    topLeftView.center = CGPointMake(backEndTurn.frame.origin.x +topLeftView.frame.size.width/2 + 2, backEndTurn.frame.origin.y + topLeftView.frame.size.height/2 + 2);
    [self.backgroundView addSubview:topLeftView];
    
    topView.center = CGPointMake(topLeftView.frame.origin.x + topLeftView.frame.size.width +topView.frame.size.width/2, backEndTurn.frame.origin.y + topView.frame.size.height/2 +2.5);
    [self.backgroundView addSubview:topView];
    
    topRightView.center = CGPointMake(backEndTurn.frame.origin.x + backEndTurn.frame.size.width -topLeftView.frame.size.width/2 - 2, backEndTurn.frame.origin.y + topLeftView.frame.size.height/2 + 2);
    [self.backgroundView addSubview:topRightView];
    
    rightView.center = CGPointMake(backEndTurn.frame.origin.x + backEndTurn.frame.size.width -rightView.frame.size.width/2 - 2.5, backEndTurn.center.y);
    [self.backgroundView addSubview:rightView];
    
    bottomRightView.center = CGPointMake(backEndTurn.frame.origin.x + backEndTurn.frame.size.width -topLeftView.frame.size.width/2 - 2, backEndTurn.frame.origin.y + backEndTurn.frame.size.height - bottomRightView.frame.size.height/2 -2.5);
    [self.backgroundView addSubview:bottomRightView];
    
    bottomView.center = CGPointMake(backEndTurn.center.x, backEndTurn.frame.origin.y + backEndTurn.frame.size.height - bottomView.frame.size.height/2 -2.5);
    [self.backgroundView addSubview:bottomView];
    
    bottomLeftView.center = CGPointMake(backEndTurn.frame.origin.x +bottomLeftView.frame.size.width/2 + 2, backEndTurn.frame.origin.y + backEndTurn.frame.size.height - bottomLeftView.frame.size.height/2 -2);
    [self.backgroundView addSubview:bottomLeftView];
    
    leftView.center = CGPointMake(backEndTurn.frame.origin.x +leftView.frame.size.width/2 + 2.5, backEndTurn.center.y);
    [self.backgroundView addSubview:leftView];
    
    topFrame = topView.frame;
    rightFrame = rightView.frame;
    bottomFrame = bottomView.frame;
    leftFrame = leftView.frame;
    
    /////////////////////////////////////////////////////

    
    //end button is aligned with field's right border and has same distance away as the distance between the two fields
    self.endTurnButton.center = CGPointMake(SCREEN_WIDTH - (SCREEN_WIDTH - playerFieldEdge.bounds.size.width)/2 - self.endTurnButton.frame.size.width/2, playerFieldEdge.center.y + playerFieldEdge.bounds.size.height/2 + fieldsDistanceHalf*2 + self.endTurnButton.frame.size.height/2);
    [self.backgroundView addSubview: self.endTurnButton];
    
    if (currentSide != PLAYER_SIDE)
        [self.endTurnButton setEnabled:NO];
    
    //quit button
    //brian oct 9
    //float baseScreenHeight = 1334.0f/2.0f;
    //float baseScreenWidth = 750.0f/2.0f;
    //rescaling button to screen size and moving to top right
    _quitButton = [[CFButton alloc] initWithFrame:CGRectMake(290/baseScreenWidth *SCREEN_WIDTH, 105/baseScreenHeight*SCREEN_HEIGHT, 60/baseScreenWidth*SCREEN_WIDTH, 40/baseScreenHeight*SCREEN_HEIGHT)];
    [_quitButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [_quitButton addTarget:self action:@selector(quitButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.uiView addSubview:_quitButton];
    
    //brian oct 9
    //set dimensions for move history relative to screen size
    //_moveHistoryButton = [[CFButton alloc] initWithFrame:CGRectMake(4, 104, 60, 32)];
    
   
    _moveHistoryButton = [[CFButton alloc] initWithFrame:CGRectMake(4/baseScreenWidth*SCREEN_WIDTH, 104/baseScreenHeight *SCREEN_HEIGHT, 90/baseScreenWidth*SCREEN_WIDTH, 32/baseScreenHeight*SCREEN_HEIGHT)];
    _moveHistoryButton.label.text = @"History";
    [_moveHistoryButton setTextSize:12];
    [_moveHistoryButton addTarget:self action:@selector(openMoveHistoryScreen)    forControlEvents:UIControlEventTouchUpInside];
    [self.uiView addSubview:_moveHistoryButton];
   
    if (_level.isTutorial)
    {
        NSArray*completedLevels = userPF[@"completedLevels"];
        
        //cannot quit if playing the tutorial level for first time
        if (![completedLevels containsObject:_level.levelID])
        {
            [_quitButton setEnabled:NO];
        }
        
        [topView setHidden:YES];
        [topRightView setHidden:YES];
        [rightView setHidden:YES];
        [bottomRightView setHidden:YES];
        [bottomView setHidden:YES];
        [bottomLeftView setHidden:YES];
        [leftView setHidden:YES];
        [topLeftView setHidden:YES];
    }
    
    quitConfirmLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT)];
    quitConfirmLabel.textColor = [UIColor whiteColor];
    quitConfirmLabel.backgroundColor = [UIColor clearColor];
    quitConfirmLabel.font = [UIFont fontWithName:cardMainFont size:25];
    quitConfirmLabel.textAlignment = NSTextAlignmentCenter;
    quitConfirmLabel.lineBreakMode = NSLineBreakByWordWrapping;
    quitConfirmLabel.numberOfLines = 0;
    quitConfirmLabel.text = @"Are you sure you want to quit? You will lose this game.";
    [quitConfirmLabel sizeToFit];
    
    quitConfirmButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    quitConfirmButton.center = CGPointMake(SCREEN_WIDTH/2 - 80, SCREEN_HEIGHT - 60);
    quitConfirmButton.label.text = @"Yes";
    [quitConfirmButton setTextSize:16];
    //[quitConfirmButton setImage:[UIImage imageNamed:@"yes_button"] forState:UIControlStateNormal];
    [quitConfirmButton addTarget:self action:@selector(quitConfirmButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    quitCancelButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    quitCancelButton.center = CGPointMake(SCREEN_WIDTH/2 + 80, SCREEN_HEIGHT - 60);
    quitCancelButton.label.text = @"No";
    [quitCancelButton setTextSize:16];
    //[quitCancelButton setImage:[UIImage imageNamed:@"no_button"] forState:UIControlStateNormal];
    [quitCancelButton addTarget:self action:@selector(quitCancelButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    
    
    //-----ability extra description-----//
    extraAbilityView = [[GameInfoTableView alloc] initWithFrame:CGRectMake(0, 0, 80, SCREEN_HEIGHT*2/5) withTitle:@"Added Abilities"];
    extraAbilityView.center = CGPointMake(45, SCREEN_HEIGHT/2);
    
    abilityDescriptionView  = [[GameInfoTableView alloc] initWithFrame:CGRectMake(0, 0, 80, SCREEN_HEIGHT*2/5) withTitle:@"Keywords"];
    abilityDescriptionView.center = CGPointMake(SCREEN_WIDTH-45, SCREEN_HEIGHT/2);
    
    //-----ability targetting hint & give up-----//
    pickATargetLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    pickATargetLabel.center = CGPointMake(self.view.bounds.size.width/2 + 20, self.view.bounds.size.height-120);
    pickATargetLabel.text = [NSString stringWithFormat:@"Select a target"];
    pickATargetLabel.textAlignment = NSTextAlignmentCenter;
    pickATargetLabel.textColor = [UIColor whiteColor];
    pickATargetLabel.font = [UIFont fontWithName:cardMainFontBlack size:26];
    pickATargetLabel.strokeColour = [UIColor blackColor];
    pickATargetLabel.strokeThickness = 2;
    pickATargetLabel.strokeOn = YES;
    
    giveupAbilityButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 60, 45)];
    giveupAbilityButton.center = CGPointMake(self.view.bounds.size.width/2 + 20, self.view.bounds.size.height-60);
    giveupAbilityButton.buttonStyle = CFButtonStyleWarning;
    giveupAbilityButton.label.text = @"No Target";
    [giveupAbilityButton setTextSize:10];
    //[giveupAbilityButton setImage:[UIImage imageNamed:@"no_target_button"] forState:UIControlStateNormal];
    [giveupAbilityButton addTarget:self action:@selector(noTargetButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    _gameOverBlockingView = [[UIView alloc] initWithFrame:self.view.bounds];
    [_gameOverBlockingView setUserInteractionEnabled:YES];
    
    //------------------gameover screen------------------//
    
    _gameOverScreen = [[UIView alloc] initWithFrame:self.view.bounds];
    
    _resultsLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    _resultsLabel.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/4);
    _resultsLabel.textAlignment = NSTextAlignmentCenter;
    _resultsLabel.textColor = [UIColor whiteColor];
    _resultsLabel.font = [UIFont fontWithName:cardMainFontBlack size:50];
    _resultsLabel.strokeColour = [UIColor blackColor];
    _resultsLabel.strokeThickness = 8;
    _resultsLabel.strokeOn = YES;
    
    [_gameOverScreen addSubview:_resultsLabel];
    
    _eloRating = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    _eloRating.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/4 + 70);
    _eloRating.textAlignment = NSTextAlignmentCenter;
    _eloRating.textColor = [UIColor whiteColor];
    _eloRating.font = [UIFont fontWithName:cardMainFontBlack size:40];
    _eloRating.strokeColour = [UIColor blackColor];
    _eloRating.strokeThickness = 8;
    _eloRating.strokeOn = YES;
    
    [_gameOverScreen addSubview:_eloRating];
    
    _eloRatingDiff = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    _eloRatingDiff.center = CGPointMake(SCREEN_WIDTH/4 *3, SCREEN_HEIGHT/4 + 70);
    _eloRatingDiff.textAlignment = NSTextAlignmentCenter;
    _eloRatingDiff.textColor = [UIColor greenColor];
    _eloRatingDiff.font = [UIFont fontWithName:cardMainFontBlack size:30];
    _eloRatingDiff.strokeColour = [UIColor blackColor];
    _eloRatingDiff.strokeThickness = 8;
    _eloRatingDiff.strokeOn = YES;
    
    [_gameOverScreen addSubview:_eloRatingDiff];
    
    _rewardsLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    _rewardsLabel.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    _rewardsLabel.textAlignment = NSTextAlignmentCenter;
    _rewardsLabel.textColor = [UIColor whiteColor];
    _rewardsLabel.font = [UIFont fontWithName:cardMainFont size:24];
    _rewardsLabel.strokeColour = [UIColor blackColor];
    _rewardsLabel.strokeThickness = 4;
    _rewardsLabel.strokeOn = YES;
    _rewardsLabel.text = @"Rewards:";
    
    _rewardGoldImage = [[UIImageView alloc] initWithImage:GOLD_ICON_IMAGE];
    _rewardGoldImage.frame = CGRectMake(0, 0, 60, 60);
    
    _rewardGoldLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    _rewardGoldLabel.textAlignment = NSTextAlignmentCenter;
    _rewardGoldLabel.textColor = [UIColor whiteColor];
    _rewardGoldLabel.font = [UIFont fontWithName:cardMainFont size:30];
    _rewardGoldLabel.strokeColour = [UIColor blackColor];
    _rewardGoldLabel.strokeThickness = 4;
    _rewardGoldLabel.strokeOn = YES;
    
    _rewardGoldLabel.center = CGPointMake(_rewardGoldImage.bounds.size.width/2, _rewardGoldImage.bounds.size.height*4/3);
    [_rewardGoldImage addSubview:_rewardGoldLabel];
    
    _xpIncreaseLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    _xpIncreaseLabel.textAlignment = NSTextAlignmentCenter;
    _xpIncreaseLabel.textColor = [UIColor whiteColor];
    _xpIncreaseLabel.font = [UIFont fontWithName:cardMainFont size:30];
    _xpIncreaseLabel.strokeColour = [UIColor blackColor];
    _xpIncreaseLabel.strokeThickness = 4;
    _xpIncreaseLabel.strokeOn = YES;
    _xpIncreaseLabel.text = @"400";
    
    _xpIncreaseLabel.center = CGPointMake(100,100);
    [_gameOverScreen addSubview:_xpIncreaseLabel];
    
    _overallLevelLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0,100,50)];
    _overallLevelLabel.textAlignment = NSTextAlignmentCenter;
    _overallLevelLabel.font = [UIFont fontWithName:cardMainFont size:40];
    _overallLevelLabel.strokeColour = [UIColor blackColor];
    _overallLevelLabel.strokeThickness = 4;
    _overallLevelLabel.strokeOn = YES;
    _overallLevelLabel.text = @"99";
    _overallLevelLabel.center = CGPointMake(50,100);
    _overallLevelLabel.backgroundColor = [UIColor whiteColor];
    
    
    _rewardCardImage = [[UIImageView alloc] initWithImage:CARD_ICON_IMAGE];
    _rewardCardImage.frame = CGRectMake(0, 0, 38, 60);
    
    _rewardCardLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    _rewardCardLabel.textAlignment = NSTextAlignmentCenter;
    _rewardCardLabel.textColor = [UIColor whiteColor];
    _rewardCardLabel.font = [UIFont fontWithName:cardMainFont size:30];
    _rewardCardLabel.strokeColour = [UIColor blackColor];
    _rewardCardLabel.strokeThickness = 4;
    _rewardCardLabel.strokeOn = YES;
    
    
    
    _rewardCardLabel.center = CGPointMake(_rewardCardImage.bounds.size.width/2, _rewardCardImage.bounds.size.height * 4/3);
    [_rewardCardImage addSubview:_rewardCardLabel];
    
    _gameOverOkButton = [[CFButton alloc]initWithFrame:CGRectMake(0, 0,  80, 40)];
    _gameOverOkButton.label.text = @"Ok";
    _gameOverOkButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 60);
    [_gameOverOkButton setTextSize:15];
    
    _gameOverProgressIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _gameOverProgressIndicator.frame = CGRectOffset(self.view.bounds, 0, -50);
    
    _gameOverSaveLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    _gameOverSaveLabel.textAlignment = NSTextAlignmentCenter;
    _gameOverSaveLabel.textColor = [UIColor whiteColor];
    _gameOverSaveLabel.font = [UIFont fontWithName:cardMainFont size:22];
    _gameOverSaveLabel.numberOfLines = 0;
    _gameOverSaveLabel.strokeColour = [UIColor blackColor];
    _gameOverSaveLabel.strokeThickness = 3;
    _gameOverSaveLabel.strokeOn = YES;
    
    _gameOverRetryButton = [[CFButton alloc]initWithFrame:CGRectMake(0, 0,  80, 40)];
    _gameOverRetryButton.label.text = @"Retry";
    _gameOverRetryButton.center = CGPointMake(SCREEN_WIDTH/2 - 50, SCREEN_HEIGHT - 60);
    [_gameOverRetryButton addTarget:self action:@selector(gameOverRetryButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [_gameOverRetryButton setTextSize:15];
    
    _gameOverNoRetryButton = [[CFButton alloc]initWithFrame:CGRectMake(0, 0,  80, 40)];
    _gameOverNoRetryButton.label.text = @"Quit";
    _gameOverNoRetryButton.center = CGPointMake(SCREEN_WIDTH/2 + 50, SCREEN_HEIGHT - 60);
    [_gameOverNoRetryButton addTarget:self action:@selector(gameOverNoRetryButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [_gameOverNoRetryButton setTextSize:15];
    
    //------------------move history screen------------------//
    _moveHistoryScreen = [[UIView alloc] initWithFrame:self.view.bounds];
    
    _moveHistoryLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    _moveHistoryLabel.center = CGPointMake(SCREEN_WIDTH/2, 50);
    _moveHistoryLabel.textAlignment = NSTextAlignmentCenter;
    _moveHistoryLabel.textColor = [UIColor whiteColor];
    _moveHistoryLabel.font = [UIFont fontWithName:cardMainFontBlack size:30];
    _moveHistoryLabel.strokeColour = [UIColor blackColor];
    _moveHistoryLabel.strokeThickness = 4;
    _moveHistoryLabel.strokeOn = YES;
    [_moveHistoryLabel setText:@"Move History"];
    [_moveHistoryScreen addSubview:_moveHistoryLabel];
    
    _moveHistoryBackButton = [[CFButton alloc]initWithFrame:CGRectMake(0, 0,  80, 40)];
    _moveHistoryBackButton.label.text = @"Back";
    _moveHistoryBackButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 60);
    [_moveHistoryBackButton addTarget:self action:@selector(closeMoveHistoryScreen)    forControlEvents:UIControlEventTouchUpInside];
    [_moveHistoryBackButton setTextSize:15];
    [_moveHistoryScreen addSubview:_moveHistoryBackButton];
    
    _moveHistoryTableView = [[MoveHistoryTableView alloc] initWithFrame:CGRectMake(10, 80, SCREEN_WIDTH - 20, SCREEN_HEIGHT - 80 - 100)];
    [_moveHistoryScreen addSubview:_moveHistoryTableView];
    _moveHistoryTableView.currentMoveHistories = _gameModel.moveHistories; //use same pointer
    
    //------------------card picker screen------------------//
    _cardPickerView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    _cardPickerLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    _cardPickerLabel.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/5);
    _cardPickerLabel.textAlignment = NSTextAlignmentCenter;
    _cardPickerLabel.textColor = [UIColor whiteColor];
    _cardPickerLabel.font = [UIFont fontWithName:cardMainFontBlack size:30];
    _cardPickerLabel.strokeColour = [UIColor blackColor];
    _cardPickerLabel.strokeThickness = 5;
    _cardPickerLabel.strokeOn = YES;
    [_cardPickerView addSubview:_cardPickerLabel];
    
    _cardPickerLabel2 = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    _cardPickerLabel2.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT*4/5);
    _cardPickerLabel2.textAlignment = NSTextAlignmentCenter;
    _cardPickerLabel2.textColor = [UIColor whiteColor];
    _cardPickerLabel2.font = [UIFont fontWithName:cardMainFontBlack size:20];
    _cardPickerLabel2.strokeColour = [UIColor blackColor];
    _cardPickerLabel2.strokeThickness = 3;
    _cardPickerLabel2.strokeOn = YES;
    [_cardPickerView addSubview:_cardPickerLabel2];
    
    _cardPickerDoneButton = [[CFButton alloc]initWithFrame:CGRectMake(0, 0,  120, 50)];
    _cardPickerDoneButton.label.text = @"Done";
    _cardPickerDoneButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT*9/10);
    [_cardPickerDoneButton addTarget:self action:@selector(cardPickerDoneButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [_cardPickerDoneButton setTextSize:18];
    //[_cardPickerView addSubview:_cardPickerDoneButton];
    
    _cardPickerToggleButton = [[CFButton alloc]initWithFrame:CGRectMake(0, 0,  80, 40)];
    _cardPickerToggleButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT*3/5);
    [_cardPickerToggleButton addTarget:self action:@selector(cardPickerToggleButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [_cardPickerToggleButton setTextSize:16];
    
    //for target selection
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(tapRegistered:)];
    [tapGesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGesture];
}
// ------------------------------------------------------------------------------------------------
- (void) setTimerFrames
// ------------------------------------------------------------------------------------------------
{
    
    [topRightView setHidden:NO];
    [bottomRightView setHidden:NO];
    [bottomLeftView setHidden:NO];
    [topLeftView setHidden:NO];
    [topView setHidden:NO];
    [rightView setHidden:NO];
    [bottomView setHidden:NO];
    [leftView setHidden:NO];
    
    [topRightView.layer setAnchorPoint:CGPointMake(.5, .5)];
    [bottomRightView.layer setAnchorPoint:CGPointMake(.5, .5)];
    [bottomLeftView.layer setAnchorPoint:CGPointMake(.5, .5)];
    [topLeftView.layer setAnchorPoint:CGPointMake(.5, .5)];
    
    [topView setFrame:topFrame];
    [topRightView setFrame:topRightFrame];
    [rightView setFrame:rightFrame];
    [bottomRightView setFrame:bottomRightFrame];
    [bottomView setFrame:bottomFrame];
    [bottomLeftView setFrame:bottomLeftFrame];
    [leftView setFrame:leftFrame];
    [topLeftView setFrame:topLeftFrame];
    
    topLeftView.center = CGPointMake(backEndTurn.frame.origin.x +topLeftView.frame.size.width/2 + 2, backEndTurn.frame.origin.y + topLeftView.frame.size.height/2 + 2);
    topRightView.center = CGPointMake(backEndTurn.frame.origin.x + backEndTurn.frame.size.width -topLeftView.frame.size.width/2 - 2, backEndTurn.frame.origin.y + topLeftView.frame.size.height/2 + 2);
    bottomRightView.center = CGPointMake(backEndTurn.frame.origin.x + backEndTurn.frame.size.width -topLeftView.frame.size.width/2 - 2, backEndTurn.frame.origin.y + backEndTurn.frame.size.height - bottomRightView.frame.size.height/2 -2.5);
    bottomLeftView.center = CGPointMake(backEndTurn.frame.origin.x +bottomLeftView.frame.size.width/2 + 2, backEndTurn.frame.origin.y + backEndTurn.frame.size.height - bottomLeftView.frame.size.height/2 -2);
}
// ------------------------------------------------------------------------------------------------
- (void) newGame
// ------------------------------------------------------------------------------------------------
{
    if (currentSide == PLAYER_SIDE){
        [self animatePlayerTurn];
        if (![self checkMovementsLeft]) {
            //NSLog(@"No movements Available");
            if (!self.shouldBlink) {
                self.shouldBlink = YES;
                [self flashOn:self.endTurnButton];
            }
        }
        if (!_isTutorial && !self.shouldCallEndTurn && self.gameMode == GameModeMultiplayer)
            [self startEndTurnTimer];
    }
}
// ------------------------------------------------------------------------------------------------
- (void) setCurrentSide: (int) newSide
// ------------------------------------------------------------------------------------------------
{
    currentSide = newSide;
}
// ------------------------------------------------------------------------------------------------
- (void) opponentEndTurn
// ------------------------------------------------------------------------------------------------
{
    [self endTurn];
    if (![self checkMovementsLeft]) {
        //NSLog(@"No movements Available");
        if (!self.shouldBlink) {
            self.shouldBlink = YES;
            [self flashOn:self.endTurnButton];
        }
    }
}

-(void)tapRegistered: (UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.view];
    UIView *hitView = [self.view hitTest:location withEvent:nil];
    
    //selecting ability target, don't view cards
    //if picking a target for abilities and touched a card
    if ([self.currentAbilities count] > 0)
    {
        if ([hitView isKindOfClass:[CardView class]])
        {
            MonsterCardModel *target = (MonsterCardModel*)((CardView*)hitView).cardModel;
            
            //if card is highlighted, then it must be valid target
            if (target.cardView.cardHighlightType == cardHighlightTarget)
            {
                if (_gameMode == GameModeMultiplayer)
                {
                    int targetIndex = [self.gameModel getTargetIndex:target];
                    //[_networkingEngine sendSummonCard:_currentCardIndex withTarget:targetIndex];
                    [self.MPDataHandler sendSummonCard:_currentCardIndex withTarget:targetIndex];
                }
                
                //cast all abilities at this card
                for (Ability *ability in self.currentAbilities){
                    NSArray*targets = [self.gameModel castAbility:ability byMonsterCard:nil toMonsterCard:target fromSide:PLAYER_SIDE];
                    
                    //add all targets to current move history
                    if (self.gameModel.currentMoveHistory != nil)
                    {
                        for (int i = 0; i < targets.count; i++)
                            [self.gameModel.currentMoveHistory addTarget:targets[i]];
                    }
                    
                    [target.cardView updateView];
                }
                
                [self.gameModel.currentMoveHistory updateAllValues];
                
                NSLog(@"==================HISTORY RECORDED==================");
                NSLog(@"CASTER: %@", self.gameModel.currentMoveHistory.caster.name);
                
                for (int i = 0; i < self.gameModel.currentMoveHistory.targets.count; i++)
                {
                    NSLog(@"TARGET: %@, VALUE: %@", [self.gameModel.currentMoveHistory.targets[i] name], self.gameModel.currentMoveHistory.targetsValues[i]);
                }
                
                NSLog(@"====================================================");
                
                //add history to list
                [self.gameModel.moveHistories addObject:self.gameModel.currentMoveHistory];
                [_moveHistoryTableView.tableView reloadInputViews];
                [_moveHistoryTableView.tableView reloadData];
                
                self.gameModel.currentMoveHistory = nil;

                //reset all cards' highlight back to none
                
                for (MonsterCardModel *card in self.gameModel.battlefield[PLAYER_SIDE])
                    card.cardView.cardHighlightType = cardHighlightNone;
                for (MonsterCardModel *card in self.gameModel.battlefield[OPPONENT_SIDE])
                    card.cardView.cardHighlightType = cardHighlightNone;
                PlayerModel *player = self.gameModel.players[PLAYER_SIDE];
                player.playerMonster.cardView.cardHighlightType = cardHighlightNone;
                PlayerModel *opponent = self.gameModel.players[OPPONENT_SIDE];
                opponent.playerMonster.cardView.cardHighlightType = cardHighlightNone;
                
                //ability casted successfully
                [self.currentAbilities removeAllObjects];
                //[self updateBattlefieldView:OPPONENT_SIDE];
                [self updateBattlefieldView:PLAYER_SIDE]; //update player's highlights
                [self updateHandsView:PLAYER_SIDE];
                
                //re-enable the disabled views
                [self.handsView setUserInteractionEnabled:YES];
                //[self.uiView setUserInteractionEnabled:YES];
                [self.backgroundView setUserInteractionEnabled:YES];
                [self.endTurnButton setUserInteractionEnabled:YES];
                
                [self fadeOutAndRemove:pickATargetLabel inDuration:0.2 withDelay:0];
                [self fadeOutAndRemove:giveupAbilityButton inDuration:0.2 withDelay:0];
                
                return; //prevent the other events happening
            }
        }
        
        //TODO add a button to give up casting the spell
        //did not select a valid target, ability given up
        /*
         [self.currentAbilities removeAllObjects];
         [self updateBattlefieldView:OPPONENT_SIDE];
         [self updateBattlefieldView:PLAYER_SIDE];
         [self updateHandsView:PLAYER_SIDE];
         
         //re-enable the disabled views
         [self.handsView setUserInteractionEnabled:YES];
         [self.uiView setUserInteractionEnabled:YES];
         [self.backgroundView setUserInteractionEnabled:YES];
         */
    }
    
    if (self.viewingCardView == nil)
    {
        BOOL tappedOnACard = NO;
        
        for (CardModel*card in self.gameModel.battlefield[PLAYER_SIDE])
        {
            if (hitView == card.cardView)
            {
                [self zoomFieldCard:card];
                tappedOnACard = YES;
                break;
            }
        }
        
        if (!tappedOnACard)
            for (CardModel*card in self.gameModel.battlefield[OPPONENT_SIDE])
            {
                if (hitView == card.cardView && card.cardView.frontFacing)
                {
                    [self zoomFieldCard:card];
                    tappedOnACard = YES;
                    break;
                }
            }
        
        //DEBUG: remove for tapping on enemy hand's cards
        /*
         if (!tappedOnACard)
         for (CardModel*card in self.gameModel.hands[OPPONENT_SIDE])
         {
         if (hitView == card.cardView)
         {
         [self zoomFieldCard:card];
         tappedOnACard = YES;
         break;
         }
         }
         */
        //will not remove highlights if selecting target of ability
        if (tappedOnACard && self.currentAbilities.count == 0)
        {
            gameControlState = gameControlStateNone;
            [attackLine removeFromSuperview];
            
            //remove all the highlights on enemies
            for (MonsterCardModel *enemy in self.gameModel.battlefield[OPPONENT_SIDE])
                enemy.cardView.cardHighlightType = cardHighlightNone;
            
            if (!_level.isBossFight)
            {
                PlayerModel*opponent = self.gameModel.players[OPPONENT_SIDE];
                opponent.playerMonster.cardView.cardHighlightType = cardHighlightNone;
            }
            
        }
    }
    if (hitView == self.viewingCardView)
    {
        gameControlState = gameControlStateNone;
        
        [self.viewingCardView setUserInteractionEnabled:NO];
        
        [self setAllViews:YES];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.viewingCardView.alpha = 0;
                             abilityDescriptionView.alpha = 0;
                             extraAbilityView.alpha = 0;
                         }
                         completion:^(BOOL completed){
                             [self.viewingCardView removeFromSuperview];
                             [abilityDescriptionView removeFromSuperview];
                             [extraAbilityView removeFromSuperview];
                             self.viewingCardView = nil;
                         }];
    }
}

-(void)zoomFieldCard: (CardModel*)card
{
    CardView*originalView = card.cardView; //save original view to point back
    
    self.viewingCardView = [[CardView alloc] initWithModel:card viewMode:cardViewModeZoomedIngame]; //constructor also modifies monster's cardView pointer
    self.viewingCardView.frontFacing = originalView.frontFacing;
    card.cardView = originalView; //recover the pointer
    
    [self.viewingCardView setCardViewState:cardViewStateMaximize];
    self.viewingCardView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    [self setAllViews:NO];
    
    [extraAbilityView.currentStrings removeAllObjects];
    for (Ability *ability in card.abilities)
        if (!ability.isBaseAbility && !ability.expired)
            [extraAbilityView.currentStrings addObject:[[Ability getDescription:ability fromCard:card] string]];
    [extraAbilityView.tableView reloadData];
    
    abilityDescriptionView.currentStrings = [Ability getAbilityKeywordDescriptions:card];
    [abilityDescriptionView.tableView reloadData];
    
    self.viewingCardView.alpha = 0;
    abilityDescriptionView.alpha = 0;
    extraAbilityView.alpha = 0;
    
    [self.viewingCardView setUserInteractionEnabled:NO];
    
    [self.view addSubview:self.viewingCardView];
    
    //only add these if there are actually anything to display
    if ([abilityDescriptionView.currentStrings count]>0)
        [self.view addSubview:abilityDescriptionView];
    if ([extraAbilityView.currentStrings count]>0)
        [self.view addSubview:extraAbilityView];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.viewingCardView.alpha = 1;
                         abilityDescriptionView.alpha = 1;
                         extraAbilityView.alpha = 1;
                     }
                     completion:^(BOOL finished){[self.viewingCardView setUserInteractionEnabled:YES];}];
}

-(void)mulliganCards:(NSMutableArray*)cards
{
    _currentPickingCards = cards;
    pickingCards = YES;
    [self darkenScreen];
    [self setAllViews:NO];
    [self.view addSubview:_cardPickerView];
    
    [_cardPickerLabel setText:@"Opening Hand"];
    [_cardPickerLabel2 setText:@"Choose cards to replace"];
    _cardPickerLabel.alpha = 0;
    _cardPickerLabel2.alpha = 0;
    
    int borderInset = 10;
    int cardDistance = (SCREEN_WIDTH - borderInset * 2) / (cards.count + 1);

    for (int i = 0; i < cards.count; i++)
    {
        CardModel*card = cards[i];
        CardView*cardView = [[CardView alloc] initWithModel:card viewMode:cardViewModeIngame];
        cardView.frontFacing = NO;
        
        //positions the hand by laying them out from the center TODO use up available space!
        CGPoint newCenter = CGPointMake(borderInset + ((i+1)*cardDistance), SCREEN_HEIGHT/2);
        
        card.cardView = cardView;
        card.cardView.center = CGPointMake(SCREEN_WIDTH + CARD_WIDTH, SCREEN_HEIGHT-CARD_HEIGHT);
        [_cardPickerView addSubview:cardView];
        [cardView flipCard];
        
        [UIView animateWithDuration:0.5 delay:0.5f + i * 0.2f options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             cardView.center = newCenter;
                             //cardView.transform = CGAffineTransformMakeScale(1, 1);
                         }
                         completion:^(BOOL finished) {
                             [_cardPickerView addSubview:_cardPickerDoneButton];
                         }];
    }
    
    [UIView animateWithDuration:0.4 delay:0.5f + 0.2f * cards.count options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _cardPickerLabel.alpha = 1;
                         _cardPickerLabel2.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                     }];
    
    //TODO WARNING NEED TO ADD MULTIPLAYER PART
}

-(void)cardPickerDoneButtonPressed
{
    pickingCards = NO;
    [_cardPickerDoneButton removeFromSuperview];
    [_cardPickerToggleButton removeFromSuperview];
    
    NSMutableArray*mulliganedCards = [NSMutableArray array];
    
    for (int i = 0; i < _currentPickingCards.count; i++)
    {
        
        CardModel*card = _currentPickingCards[i];
        if (card.cardView.cardOverlayObjectMode == cardOverlayObjectMulligan)
        {
            [mulliganedCards addObject:card];
            _currentPickingCards[i] = [NSNull null]; //clear this array to be filled in later
        }
        else
        {
            //kept cards are moved to front
            CardView* cardView = card.cardView;
            [cardView removeFromSuperview];
            [_cardPickerView addSubview:cardView];
        }
    }
    
    //TODO WARNING: need to wait for opponent in multiplayer
    
    //mulliganed cards leave
    for (int i = 0; i < mulliganedCards.count; i++)
    {
        CardView*cardView = [mulliganedCards[i] cardView];
        CGPoint newCenter = CGPointMake(SCREEN_WIDTH + CARD_WIDTH, SCREEN_HEIGHT-CARD_HEIGHT);
        [cardView setZoomScale:1];
        
        [UIView animateWithDuration:0.4 delay:0.5f + i * 0.2f options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             cardView.center = newCenter;
                         }
                         completion:^(BOOL finished) {
                             [cardView removeFromSuperview];
                         }];
    }
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _cardPickerLabel2.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [_cardPickerLabel2 removeFromSuperview];
                     }];
    
    NSMutableArray *swappedCards = [_gameModel swapCards:mulliganedCards side:PLAYER_SIDE];
    
    
    float totalDelay = 0.5f + mulliganedCards.count * 0.2f;
    //add some extra delay
    totalDelay += 1.0f;
    
    //no delay if didn't mulligan
    if (mulliganedCards.count == 0)
        totalDelay = 0;
    
    [self performBlock:^{
        
        //put swapped cards back into currentPickingCards
        int j = 0;
        for (int i = 0; i < _currentPickingCards.count; i++)
        {
            if (_currentPickingCards[i] == [NSNull null])
            {
                _currentPickingCards[i] = swappedCards[j++];
            }
        }
        
        int borderInset = 10;
        int cardDistance = (SCREEN_WIDTH - borderInset * 2) / (_currentPickingCards.count + 1);
        
        //swapped cards enter screen
        for (int i = 0; i < _currentPickingCards.count; i++)
        {
            CardModel*card = _currentPickingCards[i];
            if (card.cardView == nil)
            {
                CardView*cardView = [[CardView alloc] initWithModel:card viewMode:cardViewModeIngame];
                cardView.frontFacing = NO;
                cardView.center = CGPointMake(SCREEN_WIDTH + CARD_WIDTH, SCREEN_HEIGHT-CARD_HEIGHT);
                
                [_cardPickerView insertSubview:cardView atIndex:0]; //insert at 0 so they appear behind
                [cardView flipCard];
                
                CGPoint newCenter = CGPointMake(borderInset + ((i+1)*cardDistance), SCREEN_HEIGHT/2);
                
                [UIView animateWithDuration:0.4 delay:i * 0.2f options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     cardView.center = newCenter;
                                 }
                                 completion:^(BOOL finished) {
                                 }];
            }
            
            
        }
        
        [self performBlock:^{
            //close mulligan views
            
            [self undarkenScreen];
            
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 _cardPickerLabel.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 [_cardPickerLabel removeFromSuperview];
                             }];
            
            [self performBlock:^{
                //close mulligan views
                //reorder all cards in order for hands
                for (int i = 0; i < _currentPickingCards.count; i++)
                {
                    CardView*cardView = [_currentPickingCards[i] cardView];
                    [cardView removeFromSuperview];
                    [handsView addSubview:cardView];
                }
                
                [_gameModel.hands[PLAYER_SIDE] addObjectsFromArray:_currentPickingCards];
                [self updateHandsView:PLAYER_SIDE];
                
                [self performBlock:^{
                    [_cardPickerView removeFromSuperview];
                    [self setAllViews:YES];
                    [self newGame];
                } afterDelay:0.5f];
            } afterDelay:0.4f]; //screen undarken delay
            
        } afterDelay:2.0f];

    } afterDelay:totalDelay];
    
    
}

-(void)cardPickerToggleButtonPressed
{
    if (_cardPickerCardView != nil)
    {
        if (_cardPickerCardView.cardOverlayObjectMode == cardOverlayObjectMulligan)
        {
            [_cardPickerCardView setCardOverlayObject: cardOverlayObjectNone];
            [_cardPickerToggleButton.label setText:@"Replace"];
        }
        else
        {
            [_cardPickerCardView setCardOverlayObject: cardOverlayObjectMulligan];
            [_cardPickerToggleButton.label setText:@"Keep"];
        }
    }
}

-(void) endTurn{
    
   /* UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(topRightView.frame.origin.x, topRightView.frame.origin.y + topRightView.frame.size.height)
                                   radius:topRightView.frame.size.height
                               startAngle:-M_PI_2
                                 endAngle:-M_PI_4
                                clockwise:YES];
    path.lineWidth = 2;

    
    //[path drawLayer:topRightView.layer inContext:(__bridge CGContextRef _Nonnull)(self.backgroundView)];
    
    UIGraphicsBeginImageContextWithOptions(path.bounds.size, NO, 0.0); //size of the image, opaque, and scale (set to screen default with 0)
    [path fill]; //or [path stroke]
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    topRightView.image = image;
    UIGraphicsEndImageContext();*/
    
    
    [self.timer invalidate];
    self.timer = nil;
    self.shouldCallEndTurn = NO;
    [self.counterView setHidden:YES];
    self.shouldBlink = NO;
    [self endFlash:self.endTurnButton];
    
    if (giveupAbilityButton.superview != nil)
    {
        [self noTargetButtonPressed];
    }
    
    if (currentSide == PLAYER_SIDE)
        //[_networkingEngine sendEndTurn];
        [self.MPDataHandler sendEndTurn];
    
    //tell the gameModel to end turn
    [self.gameModel endTurn: currentSide];
    
    [self endTurnTutorial];
    
    int previousSide = currentSide;
    
    //switch player after turn's over
    if (currentSide == PLAYER_SIDE)
    {
        currentSide = OPPONENT_SIDE;
        
        //cancels all card
    }
    else
    {
        currentSide = PLAYER_SIDE;
        if (!_isTutorial && !self.shouldCallEndTurn && self.gameMode == GameModeMultiplayer)
            [self startEndTurnTimer];
    }
    
    //update turn ender's views
    [self updateHandsView:previousSide];
    [self updateBattlefieldView:previousSide];
    [self updateResourceView: previousSide];
    
    //tell the gameModel a new turn has started
    [self.gameModel newTurn: currentSide];
    
    //update new player's views after the turn end
    [self updateHandsView:currentSide];
    [self updateBattlefieldView:currentSide];
    [self updateResourceView: currentSide];
    
    //disable and enable endTurnButton accordingly depending on who's turn it is
    if (currentSide == PLAYER_SIDE)
    {
        [self animatePlayerTurn];
        [self.endTurnButton setEnabled:YES];
        if (![self checkMovementsLeft]) {
            //NSLog(@"No movements Available");
            if (!self.shouldBlink) {
                self.shouldBlink = YES;
                [self flashOn:self.endTurnButton];
            }
        }
    }
    else
        [self.endTurnButton setEnabled:NO];
    
    //if playing against AI, AI now makes a move
    if (self.gameModel.gameMode == GameModeSingleplayer && currentSide == OPPONENT_SIDE)
        [self.gameModel.aiPlayer newTurn];
    
    
}

-(void)updateHandsView: (int)side
{
    NSArray *hand = self.gameModel.hands[side];
    
    float handCenterIndex = hand.count/2; //for positioning the cards
    
    //predetermine the y position of the card depending on which side it's on
    int height = 0;
    
    if (side == PLAYER_SIDE)
        height = SCREEN_HEIGHT - CARD_HEIGHT/2;
    else if (side == OPPONENT_SIDE)
        //height = CARD_HEIGHT/2;
        height = CARD_HEIGHT/4;
    
    self.handMovementsLeft = NO;
    //iterate through all player's hand's cards and set their views correctly
    for (int i = 0; i < hand.count; i++)
    {
        float distanceFromCenter;
        
        if (hand.count % 2 == 0)
            distanceFromCenter = i - handCenterIndex + 0.5;
        else
            distanceFromCenter = i - handCenterIndex;
        
        CardModel *card = hand[i];
        
        //positions the hand by laying them out from the center TODO use up available space!
        //brian Oct 9
        //repositioning opponent cards
        CGPoint newCenter;
        //old x value 1.8
        if(side== PLAYER_SIDE)
        {
             newCenter = CGPointMake((i-handCenterIndex+0.5) * CARD_WIDTH/2.3 + ((hand.count+1)%2 * CARD_WIDTH/4) + SCREEN_WIDTH/2.3, height + fabsf(distanceFromCenter) * 3);
        }
        else
        {
            newCenter = CGPointMake((i-handCenterIndex+0.5) * CARD_WIDTH/2.3 + ((hand.count+1)%2 * CARD_WIDTH/4) + SCREEN_WIDTH/2.3, height + fabsf(distanceFromCenter) * 3);
            
        }
      
        
        //if card has no view, create one
        if (card.cardView == nil)
        {
            CardView *cardView = [[CardView alloc] initWithModel:card viewMode:cardViewModeIngame];
            card.cardView = cardView;
            if (side == PLAYER_SIDE) // NOTE: remove this for debugging
                [card.cardView flipCard];
            [self.handsView addSubview:card.cardView];
            
            //assuming new cards are always drawn from the deck (TODO: NOT ACTUALLY TRUE! May be summoned from ability etc)
            if(side == PLAYER_SIDE)
                card.cardView.center = CGPointMake(SCREEN_WIDTH + CARD_WIDTH, SCREEN_HEIGHT-CARD_HEIGHT);
            else if (side == OPPONENT_SIDE)
                //card.cardView.center = CGPointMake(SCREEN_WIDTH + CARD_WIDTH, CARD_HEIGHT) ;
                card.cardView.center = CGPointMake(SCREEN_WIDTH + CARD_WIDTH, CARD_HEIGHT) ;
        }
        
        [card.cardView resetTransformations];
        
        //if (hand.count != 1)
        card.cardView.transform = CGAffineTransformConcat(card.cardView.transform, CGAffineTransformMakeRotation(M_PI_4/12 * distanceFromCenter));
        
        //show suggestion glow if it's player's turn and the card can be used, but no suggestion during targetting a spell
        if (currentSide == PLAYER_SIDE &&  side == PLAYER_SIDE && [self.gameModel canSummonCard:card side:currentSide] && [self.currentAbilities count] == 0){
            card.cardView.cardHighlightType = cardHighlightSelect;
            self.handMovementsLeft = YES;
        }
        else
            card.cardView.cardHighlightType = cardHighlightNone;
        
        //slerp to the position
        [self animateMoveToWithBounce:card.cardView toPosition:newCenter inDuration:0.7];
    }
}

-(float)getFieldCardXWithCount: (int)count withIndex:(int)i
{
    float battlefieldCenterIndex = count/2; //for positioning the cards
    
    return (i-battlefieldCenterIndex) * CARD_WIDTH + ((count+1)%2 * CARD_WIDTH/2) + SCREEN_WIDTH/2;
}

-(void)updateBattlefieldView: (int)side
{
    NSArray *field = self.gameModel.battlefield[side];
    
    //predetermine the y position of the card depending on which side it's on
    int height = 0;
    
    if (side == PLAYER_SIDE)
        height = playerFieldHighlight.center.y;
    else if (side == OPPONENT_SIDE)
        height = opponentFieldHighlight.center.y;
    
    
    self.battleMovementsLeft = NO;
    //iterate through all field cards and set their views correctly
    for (int i = 0; i < field.count; i++)
    {
        MonsterCardModel *card = field[i];
        
        if (card.dead) //dead cards are in the process of being removed, don't update it
            continue;
        
        //positions the hand by laying them out from the center
        CGPoint newCenter = CGPointMake([self getFieldCardXWithCount:(int)field.count withIndex:i], height);
        
        //if card has no view, create one
        if (card.cardView == nil)
        {
            CardView *cardView = [[CardView alloc] initWithModel:card viewMode:cardViewModeIngame];
            cardView.frontFacing = YES; //TODO ability can change this
            
            card.cardView = cardView;
            
            cardView.alpha = 0;
            [self.fieldView addSubview:card.cardView];
            [self fadeIn:cardView inDuration:0.2];
            
            card.cardView.center = newCenter; //TODO
        }
        else
        {
            [card.cardView updateView];
            //slerp to the position
            [self animateMoveToWithBounce:card.cardView toPosition:newCenter inDuration:0.5];
        }
        
        //show suggestion glow if it's player's turn and the card can be used, but no suggestion if targetting a spell
        if (currentSide == PLAYER_SIDE && side == PLAYER_SIDE && [self.gameModel canAttack:card fromSide:side] && [self.currentAbilities count] == 0)
        {
            card.cardView.cardHighlightType = cardHighlightSelect;
            self.battleMovementsLeft = YES;
        //if not currently trying to summon an ability, reset highlight to none
        }
        else if ([self.currentAbilities count] == 0 || card.cardView.cardHighlightType != cardHighlightTarget)
        {
            card.cardView.cardHighlightType = cardHighlightNone;
        }
    }
    
    //brian nov 13
    CardView*player = (CardView*)self.playerHeroViews[PLAYER_SIDE];
    CardView*opponent = (CardView*)self.playerHeroViews[OPPONENT_SIDE];
    
    MonsterCardModel *opponentmonster = (MonsterCardModel*)opponent.cardModel;
    MonsterCardModel *heromonster = (MonsterCardModel*)player.cardModel;
    
    [self updateHealthView:PLAYER_SIDE newLife:heromonster.life newMax:heromonster.maximumLife];
    [self updateHealthView:OPPONENT_SIDE newLife:opponentmonster.life newMax:opponentmonster.maximumLife];
    
    //update hero
    //CardView*player = self.playerHeroViews[side];
    if ([self.currentAbilities count] == 0)
        player.cardHighlightType = cardHighlightNone;
}

/** check if has movements left */

-(BOOL) checkMovementsLeft{
    BOOL toReturn = NO;
    NSArray *hand = self.gameModel.hands[PLAYER_SIDE];
    NSArray *fields = self.gameModel.battlefield[PLAYER_SIDE];
    
    
    for (int i = 0; i < fields.count; i++)
    {
        MonsterCardModel *card = fields[i];
        
        if (card.dead) //dead cards are in the process of being removed, don't update it
            continue;
        
        if (currentSide == PLAYER_SIDE && [self.gameModel canAttack:card fromSide:PLAYER_SIDE] && [self.currentAbilities count] == 0)
            toReturn = YES;
    }
    
    for (int i = 0; i < hand.count; i++)
    {
        CardModel *card = hand[i];
        
        if (currentSide == PLAYER_SIDE && [self.gameModel canSummonCard:card side:PLAYER_SIDE] && [self.currentAbilities count] == 0)
            toReturn = YES;
    }
    
    return toReturn;
}

/** update the corresponding resource label with the number of resource the player has */
-(void)updateResourceView: (int)side
{
    PlayerModel *player = self.gameModel.players[side];
    [resourceLabels[side] setText:[NSString stringWithFormat:@"%d/%d", player.resource, player.maxResource]];
  
}

-(void)updateHealthView: (int)side newLife:(int)newLifeTotal newMax:(int)newLifeMax
{
    
    [healthLabels[side] setText:[NSString stringWithFormat:@"%d/%d", newLifeTotal, newLifeMax]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_gameModel.gameOver || _viewsDisabled)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    //this is handeled in tap
    if ([self.currentAbilities count] > 0)
        return;
    
    //below card height, dragging cycles through cards
    if (currentPoint.y > SCREEN_HEIGHT - CARD_HEIGHT)
    {
        /*
         int closestDistanceFromTouch = 999999;
         CardView*closestCard = nil;
         
         NSArray*playerHand = self.gameModel.hands[PLAYER_SIDE];
         for (int i = 0; i < playerHand.count; i++)
         {
         CardModel* cardModel = playerHand[i];
         CardView*cardView = cardModel.cardView;
         
         int distanceFromTouch = abs(cardView.center.x - currentPoint.x);
         
         if (distanceFromTouch < closestDistanceFromTouch)
         {
         closestDistanceFromTouch = distanceFromTouch;
         closestCard = cardView;
         }
         }
         
         if (closestCard!=nil && closestDistanceFromTouch < CARD_WIDTH*2/3)
         {
         closestCard.cardViewState = cardViewStateDragging;
         //cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, DEFAULT_SCALE, DEFAULT_SCALE);
         
         gameControlState = gameControlStateDraggingHandCard;
         currentCard = closestCard.cardModel;
         
         closestCard.center = CGPointMake(closestCard.center.x, (SCREEN_HEIGHT-CARD_FULL_HEIGHT*2/3));
         
         //saves the index in the view before bringing it to the front
         closestCard.previousViewIndex = [self.handsView.subviews indexOfObject:closestCard];
         [self.handsView bringSubviewToFront:closestCard];
         
         //cardView.center = [touch locationInView: self.handsView];
         //CGPoint newCenter = [touch locationInView: self.view];
         //newCenter.y -= cardView.frame.size.height*2/3;
         
         //cardView.center = newCenter;
         
         return; //TODO this is assuming nothing will be done after this
         }*/
        
        gameControlState = gameControlStateDraggingHandCard;
        [self touchesMoved:touches withEvent:event];
        
        return;
    }
    
    //drag line of attack
    if (currentSide == PLAYER_SIDE)
    {
        //touched a card on battlefield, drag a line for picking a target to attack
        for (CardModel *card in self.gameModel.battlefield[PLAYER_SIDE]) //only player side allowed
        {
            CardView *cardView = card.cardView;
            
            if ([touch view] == cardView)
            {
                //check if card can attack
                MonsterCardModel *monsterCard = (MonsterCardModel*) card;
                if ([self.gameModel canAttack:monsterCard fromSide: currentSide])
                {
                    //cardView.cardViewState = cardViewStateDragging; //don't change it for now
                    gameControlState = gameControlStateDraggingFieldCard;
                    currentCard = cardView.cardModel;
                    
                    attackLine.frame = CGRectMake(0,0,0,0);
                    attackLine.center = [touch locationInView:self.uiView];
                    [self.uiView addSubview:attackLine];
                    [self.uiView bringSubviewToFront:attackLine];
                    
                    //mark all valid enemy targets with highlight
                    if (currentSide == PLAYER_SIDE)
                    {
                        for (MonsterCardModel *enemy in self.gameModel.battlefield[OPPONENT_SIDE])
                            if ([self.gameModel validAttack:monsterCard target:enemy])
                                enemy.cardView.cardHighlightType = cardHighlightTarget;
                        
                        if (!_level.isBossFight)
                        {
                            PlayerModel*opponent = self.gameModel.players[OPPONENT_SIDE];
                            if ([self.gameModel validAttack:monsterCard target:opponent.playerMonster])
                                opponent.playerMonster.cardView.cardHighlightType = cardHighlightTarget;
                        }
                    }
                }
                
                break; //break even if cannot attack
            }
        }
    }
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_gameModel.gameOver || _viewsDisabled)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView: self.view];
    
    //hand card follows drag
    if (gameControlState == gameControlStateDraggingHandCard)
    {
        //below card height, dragging cycles through cards
        if (currentPoint.y > SCREEN_HEIGHT - CARD_HEIGHT)
        {
            if (leftHandViewZone)
            {
                [self updateHandsView:PLAYER_SIDE];
                leftHandViewZone = NO;
            }
            
            int closestDistanceFromTouch = 999999;
            CardView*closestCard = nil;
            
            NSArray*playerHand = self.gameModel.hands[PLAYER_SIDE];
            for (int i = 0; i < playerHand.count; i++)
            {
                CardModel* cardModel = playerHand[i];
                CardView*cardView = cardModel.cardView;
                
                //int offsetedX = currentPoint.x + CARD_WIDTH*0.33;
                int offsetedX = currentPoint.x;
                
                int distanceFromTouch = abs(cardView.center.x - offsetedX);
                
                if (distanceFromTouch < closestDistanceFromTouch)
                {
                    closestDistanceFromTouch = distanceFromTouch;
                    closestCard = cardView;
                }
                
                //from 0 to 50 pixels left to right, 55 means within 10 pixels y is the same
                double cardScaleIdentity = (55 - distanceFromTouch)/50.f;
                
                //clamp to 0, now it's [0,1]
                if (cardScaleIdentity < 0)
                    cardScaleIdentity = 0;
                if (cardScaleIdentity > 1)
                    cardScaleIdentity = 1;
                
                if (cardScaleIdentity == 0)
                    continue;
                
                //give a non-linear feel
                cardScaleIdentity = pow(cardScaleIdentity, 3);
                
                //now [CARD_DEFAULT_SCALE, CARD_DRAGGING_SCALE]
                double cardScale = (cardScaleIdentity*(CARD_DRAGGING_SCALE-CARD_DEFAULT_SCALE)) + CARD_DEFAULT_SCALE;
                
                //NSLog(@"%f", cardScale);
                
                float handCenterIndex = playerHand.count/2; //for positioning the cards
                
                //predetermine the y position of the card depending on which side it's on
                float distanceFromCenter;
                
                if (playerHand.count % 2 == 0)
                    distanceFromCenter = i - handCenterIndex + 0.5;
                else
                    distanceFromCenter = i - handCenterIndex;
                
                float maxZoomPosition = (SCREEN_HEIGHT-CARD_FULL_HEIGHT*2/3);
                
                //note that these can't go into the animation since it'll cause wiggling (due to resetting the transform)
                cardView.transform = CGAffineTransformIdentity;
                cardView.transform = CGAffineTransformScale(cardView.transform, cardScale, cardScale);
                cardView.transform = CGAffineTransformConcat(cardView.transform, CGAffineTransformMakeRotation(M_PI_4/12 * distanceFromCenter));
                
                [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     cardView.center = CGPointMake(cardView.center.x, maxZoomPosition + (1-cardScaleIdentity)*(CARD_FULL_HEIGHT*2/3-CARD_HEIGHT/2));
                                 }
                                 completion:nil];
            }
            
            //must be close enough to a new card before changing
            if (closestCard!=nil && closestDistanceFromTouch < CARD_WIDTH/2)
            {
                //reinsert previous currentCard
                if (currentCard != closestCard.cardModel)
                {
                    if (currentCard!=nil)
                    {
                        //reinsert previous card back to the old position
                        [self.handsView insertSubview:currentCard.cardView atIndex:currentCard.cardView.previousViewIndex];
                    }
                    
                    currentCard = closestCard.cardModel;
                    //saves the index in the view before bringing it to the front
                    closestCard.previousViewIndex = [self.handsView.subviews indexOfObject:closestCard];
                    [self.handsView bringSubviewToFront:closestCard];
                }
            }
        }
        //above card height, will only be moving the card that has been selected
        else
        {
            if (!leftHandViewZone)
            {
                for (CardModel*card in self.gameModel.hands[PLAYER_SIDE])
                {
                    if (card != currentCard)
                        card.cardView.cardViewState = cardViewStateNone;
                }
                
                [self updateHandsView:PLAYER_SIDE];
                leftHandViewZone = YES;
            }
            
            CGPoint newCenter = currentPoint;
            newCenter.y -= currentCard.cardView.frame.size.height/2;
            
            currentCard.cardView.center = newCenter;
            
            [self scaleDraggingCard:currentCard.cardView atPoint:currentPoint];
            
            //highlight field only if can summon the card
            if (currentSide == PLAYER_SIDE && [self.gameModel canSummonCard:currentCard side:currentSide])
            {
                UIImageView *fieldHighlight = playerFieldHighlight;
                
                CGPoint relativePoint = [fieldHighlight convertPoint:currentPoint fromView:self.view];
                
                //when dragging on top of the field, highlight it
                if (CGRectContainsPoint(fieldHighlight.bounds, relativePoint))
                {
                    if (fieldHighlight.alpha == 0)
                        [self fadeIn:fieldHighlight inDuration:0.2];
                }
                else if (fieldHighlight.alpha != 0) //fade out if not
                    [self fadeOut:fieldHighlight inDuration:0.2];
            }
        }
    }
    //field card drags a line for targetting
    else if (gameControlState == gameControlStateDraggingFieldCard)
    {
        CGPoint p1 = currentCard.cardView.center;
        CGPoint p2 = [touch locationInView:self.view];
        
        //attack line, just a label with red background (red rect)
        attackLine.center = CGPointAdd(p1, CGPointDivideScalar((CGPointSubtract(p2, p1)), 2));
        int length = (int)CGPointDistance(p1, p2);
        attackLine.bounds = CGRectMake(0,-10,(int)(length*1),4);
        [attackLine setTransform: CGAffineTransformMakeRotation(CGPointAngle(p1,p2))];
        
        // Reset all hinted states to NO until checking all
        for (MonsterCardModel* monster in _hintedMonsters)
        {
            monster.cardView.cardOverlayObjectMode = cardOverlayObjectNone;
        }
        
        //check if drag is over an attackable creature
        MonsterCardModel * targetMonster = [self getMonsterAtPoint:currentPoint];
        if (targetMonster != nil && [self.gameModel validAttack:currentCard target:targetMonster])
        {
            NSArray*deadMonsters = [_gameModel getDeadMonsterWithAttacker:(MonsterCardModel*)currentCard target:targetMonster];
            for (MonsterCardModel* monster in deadMonsters)
            {
                //new monster not hinted yet
                if (![_hintedMonsters containsObject:monster])
                {
                    [monster.cardView setCardOverlayObject: cardOverlayObjectDeath];
                    [_hintedMonsters addObject:monster];
                }
                //hinted in last update, just keep variable to YES
                else
                {
                    monster.cardView.cardOverlayObjectMode = cardOverlayObjectDeath;
                }
            }
        }
        
        //return to check all monsters, play unhint animation if still NO
        for (int i = (int)_hintedMonsters.count - 1; i >= 0; i--)
        {
            MonsterCardModel* monster = _hintedMonsters [i];
            if (monster.cardView.cardOverlayObjectMode == cardOverlayObjectNone)
            {
                [monster.cardView setCardOverlayObject: cardOverlayObjectNone];
                [_hintedMonsters removeObject:monster];
            }
        }
    }
}


-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_gameModel.gameOver)
        return;
    //dragging card from hand, reverts action
    if (gameControlState == gameControlStateDraggingHandCard)
    {
        currentCard.cardView.cardViewState = cardViewStateNone;
        gameControlState = gameControlStateNone;
        [currentCard.cardView removeFromSuperview];
        [self.handsView insertSubview:currentCard.cardView atIndex:currentCard.cardView.previousViewIndex];
        currentCard = nil;
    }
    //dragging card from field, reverts action
    else if (gameControlState == gameControlStateDraggingFieldCard)
    {
        [attackLine removeFromSuperview];
        gameControlState = gameControlStateNone;
        currentCard.cardView.cardViewState = cardViewStateNone;
        currentCard = nil;
    }
    
    //Put the card back to position
    [self updateHandsView:currentSide];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_gameModel.gameOver)
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView: self.view];

    //move history window open, may tap on card
    if (moveHistoryOpen)
    {
        if ([[touch view] isKindOfClass:[CardView class]])
        {
            if (_moveHistoryTableView.currentCardView == nil)
            {
                CardView*cardView = (CardView*)[touch view];
                CardModel*originalCardModel = cardView.cardModel;
                _moveHistoryTableView.currentCardView = [[CardView alloc] initWithModel:cardView.cardModel viewMode:cardViewModeEditor];
                _moveHistoryTableView.currentCardView.cardViewState = cardViewStateMaximize;
            
                if (originalCardModel.type == cardTypePlayer)
                    [_moveHistoryTableView.currentCardView setZoomScale:3.0f];
                
                //TODO might be OK to not copy this view, but if so need a way to dup it
                //[_moveHistoryTableView.currentCardView addSubview:cardView.moveHistoryValueView];
                cardView.cardModel = originalCardModel;
                
                [_moveHistoryTableView darkenScreen];
                
                [self.moveHistoryScreen addSubview:_moveHistoryTableView.currentCardView];
                [_moveHistoryTableView.currentCardView updateView];
                [_moveHistoryTableView.currentCardView setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
                [_moveHistoryTableView.tableView setUserInteractionEnabled:NO];
                
            }
        }
        else
        {
            if (_moveHistoryTableView.currentCardView != nil)
            {
                [_moveHistoryTableView.currentCardView removeFromSuperview];
                _moveHistoryTableView.currentCardView = nil;
                [_moveHistoryTableView.tableView setUserInteractionEnabled:YES];
                [_moveHistoryTableView undarkenScreen];
            }
        }
        
    }
    else if (pickingCards)
    {
        if ([[touch view] isKindOfClass:[CardView class]])
        {
            CardView*cardView = (CardView*)[touch view];
            
            if (_cardPickerCardView != cardView)
            {
                if (_cardPickerCardView != nil)
                {
                    _cardPickerCardView.cardViewState = cardViewModeIngame;
                    [_cardPickerCardView updateView];
                }
                
                cardView.cardViewState = cardViewStateMaximize;
                [cardView updateView];
                _cardPickerCardView = cardView;
                [_cardPickerCardView removeFromSuperview];
                [_cardPickerView addSubview:_cardPickerCardView]; //re-add to move to front
                [_cardPickerView addSubview:_cardPickerToggleButton];
                _cardPickerToggleButton.center = CGPointMake(cardView.center.x, _cardPickerCardView.center.y + _cardPickerCardView.bounds.size.height/2 + 20);
                
                if (_cardPickerCardView.cardOverlayObjectMode == cardOverlayObjectMulligan)
                {
                    [_cardPickerToggleButton.label setText:@"Keep"];
                }
                else
                {
                    [_cardPickerToggleButton.label setText:@"Replace"];
                }
            }
        }
        else if (_cardPickerCardView != nil)
        {
            _cardPickerCardView.cardViewState = cardViewModeIngame;
            [_cardPickerCardView updateView];
            _cardPickerCardView = nil;
            [_cardPickerToggleButton removeFromSuperview];
        }
    }
    //when dragging hand card, card is deployed
    else if (gameControlState == gameControlStateDraggingHandCard)
    {
        //TODO!!! These are only temporary while two-player is enabled, don't need it afterwards
        UIImageView *fieldRect;
        if(currentSide == PLAYER_SIDE)
            fieldRect =  playerFieldHighlight;
        else
            fieldRect = opponentFieldHighlight;
        
        CGPoint relativePoint = [fieldRect convertPoint:currentPoint fromView:self.view];
        
        for (CardModel*card in self.gameModel.hands[PLAYER_SIDE])
            card.cardView.cardViewState = cardViewStateNone;
        
        //is possible to summon card as touchesStart checks the possibility
        //must be able to summon this card (e.g. enough space, enough resource)
        if ([currentCard isKindOfClass: [SpellCardModel class]]) {
            currentSpellCard = currentCard;
        }
        
        if (CGRectContainsPoint(fieldRect.bounds, relativePoint) && [self.gameModel canSummonCard:currentCard side:currentSide] && currentSide == PLAYER_SIDE)
        {
            [self summonCard:currentCard fromSide:PLAYER_SIDE];
        }
        else
        {
            //revert the states
            currentCard.cardView.cardViewState = cardViewStateNone;
            gameControlState = gameControlStateNone;
            
            //re-insert the card back at its original index in the view
            //[currentCard.cardView removeFromSuperview];
            [self.handsView insertSubview:currentCard.cardView atIndex:currentCard.cardView.previousViewIndex];
            
            //update hand's view at the end
            [self updateHandsView:PLAYER_SIDE];
        }
        
        currentCard = nil;
    }
    //when dragging field card, attacks target the touch is on top of
    else if (gameControlState == gameControlStateDraggingFieldCard)
    {
        //remove all enemy targetting highlights
        if (currentSide == PLAYER_SIDE)
        {
            for (MonsterCardModel *enemy in self.gameModel.battlefield[OPPONENT_SIDE])
                enemy.cardView.cardHighlightType = cardHighlightNone;
            
            PlayerModel*opponent = self.gameModel.players[OPPONENT_SIDE];
            opponent.playerMonster.cardView.cardHighlightType = cardHighlightNone;
        }
        
        //remove all hints
        for (int i = (int)_hintedMonsters.count - 1; i >= 0; i--)
        {
            MonsterCardModel* monster = _hintedMonsters [i];
            [monster.cardView setCardOverlayObject: cardOverlayObjectNone];
            [_hintedMonsters removeObject:monster];
        }
        
        MonsterCardModel * monster = [self getMonsterAtPoint:currentPoint];
        int oppositeSide = currentSide == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
        
        //if on a monster and can attack it
        if (monster != nil && [self.gameModel validAttack:currentCard target:monster])
        {
            if (monster.type == cardTypePlayer)
            {
                if (_gameModel.gameMode == GameModeMultiplayer)
                {
                    int attackerPosition = [_gameModel getTargetIndex:(MonsterCardModel*)currentCard];
                    
                    //[_networkingEngine sendAttackCard:attackerPosition withTarget:positionHeroB];
                    [self.MPDataHandler sendAttackCard:attackerPosition withTarget:positionHeroB];
                    
                }
                
                CardView* enemyHeroView = ((CardView*)self.playerHeroViews[oppositeSide]);
                [self attackHero:currentCard target:(MonsterCardModel*) enemyHeroView.cardModel fromSide:currentSide];
                [self cardAttacksTutorial];
                //brian nov 13
                //update these functions to update the playerHealthLabels as well as the card
                
            }
            else
            {
                if (_gameModel.gameMode == GameModeMultiplayer)
                {
                    int attackerPosition = [_gameModel getTargetIndex:(MonsterCardModel*)currentCard];
                    int targetPosition = [_gameModel getTargetIndex:monster];
                    
                    //[_networkingEngine sendAttackCard:attackerPosition withTarget:targetPosition];
                    [self.MPDataHandler sendAttackCard:attackerPosition withTarget:targetPosition];
                    
                }
                
                [self attackCard:currentCard target:(MonsterCardModel*)monster fromSide:currentSide];
                [self cardAttacksTutorial];
            }
        }
        
        //remove the attack line from view and revert states
        [attackLine removeFromSuperview];
    }
    
    if (![self checkMovementsLeft]) {
        //NSLog(@"No movements Available");
        if (!self.shouldBlink) {
            self.shouldBlink = YES;
            [self flashOn:self.endTurnButton];
        }
    }else{
       // self.shouldBlink = NO;
       // [self endFlash:self.endTurnButton];
    }

}


/** TODO this only gets enemy creatures, need to do some reorganizing for friendly */
-(MonsterCardModel*)getMonsterAtPoint:(CGPoint)currentPoint
{
    MonsterCardModel* monster = nil;
    
    int oppositeSide = currentSide == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
    
    //first step check enemy players
    CardView* enemyHeroView = ((CardView*)self.playerHeroViews[oppositeSide]);
    
    CGPoint relativePoint = [self.playerHeroViews[oppositeSide] convertPoint:currentPoint fromView:self.view];
    if (CGRectContainsPoint(enemyHeroView.bounds, relativePoint))
    {
        monster = (MonsterCardModel*)enemyHeroView.cardModel;
    }
    else
    {
        //then check for targeted an enemy monster card
        for (CardModel *card in self.gameModel.battlefield[oppositeSide])
        {
            CardView *cardView = card.cardView;
            
            //convert touch point to point relative to the card
            CGPoint relativePoint = [cardView convertPoint:currentPoint fromView:self.view];
            
            //found enemy card
            if (CGRectContainsPoint(cardView.bounds, relativePoint))
            {
                monster = (MonsterCardModel*)card;
            }
        }
    }
    
    return monster;
}

-(void) attackCard: (CardModel*) card target:(MonsterCardModel*)targetCard fromSide: (int) side
{
    int oppositeSide = currentSide == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
    
    NSLog(@"not even attacked yet, in animation: %d", card.cardView.inDamageAnimation);
    
    //animate the damage effects, if card dies, death animation is played
    [self animateCardAttack:card.cardView fromSide:side];
    
    //deal the damage and return it to animate
    NSArray *damages = [self.gameModel attackCard:card fromSide:side target:targetCard];
    
    [self performBlock:^{
        if (card.element == elementIce) {
            [self animateCardIceDamage:targetCard.cardView fromSide:oppositeSide];
        }else if(card.element == elementFire){
            [self animateCardFireDamage:targetCard.cardView fromSide:oppositeSide];
        }else if(card.element == elementLightning){
            [self animateCardThunderDamage:targetCard.cardView fromSide:oppositeSide];
        }
        
        
        [self animateCardDamage:targetCard.cardView forDamage:[damages[0] integerValue] fromSide:oppositeSide];
    } afterDelay:0.1];
    
    //animate damage to attacker if defender dealt damage
    
    if (damages[1] > 0)
        [self performBlock:^{
            [self animateCardDamage:card.cardView forDamage:[damages[1] integerValue] fromSide:side];
        } afterDelay:0.4];
    
    //update views after the attack
    [card.cardView updateView];
    [targetCard.cardView updateView];
    
    //update hero views after attack (may be pierced)
    [_playerHeroViews[PLAYER_SIDE] updateView];
    [_playerHeroViews[OPPONENT_SIDE] updateView];
    
    CardView*player = (CardView*)self.playerHeroViews[PLAYER_SIDE];
    CardView*opponent = (CardView*)self.playerHeroViews[OPPONENT_SIDE];
    
    MonsterCardModel *opponentmonster = (MonsterCardModel*)opponent.cardModel;
    MonsterCardModel *heromonster = (MonsterCardModel*)player.cardModel;
    
    [self updateHealthView:PLAYER_SIDE newLife:heromonster.life newMax:heromonster.maximumLife];
    [self updateHealthView:OPPONENT_SIDE newLife:opponentmonster.life newMax:opponentmonster.maximumLife];
    
    if (side == PLAYER_SIDE)
    {
        gameControlState = gameControlStateNone;
        currentCard.cardView.cardViewState = cardViewStateNone;
        card.cardView.cardHighlightType = cardHighlightNone;
        currentCard = nil;
    }
    
    [self performBlock:^{
        //[self updateBattlefieldView:currentSide];
    }  afterDelay:2];
    
    [self updateHandsView:currentSide]; //a card may have died, freeing up more space to deploy
}

-(void) attackHero: (CardModel*) card target:(MonsterCardModel*)targetCard fromSide: (int) side
{
    int oppositeSide = side == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
    
    NSLog(@"not even attacked yet, in animation: %d", card.cardView.inDamageAnimation);
    
    //animate the damage effects for defender, if card dies, death animation is played
    [self animateCardAttack:card.cardView fromSide:side];
    
    //deal the damage and return it to animate
    NSArray *damages = [self.gameModel attackCard:card fromSide:side target:targetCard];
    
    
    
    [self performBlock:^{
        if (card.element == elementIce) {
            [self animateCardIceDamage:targetCard.cardView fromSide:oppositeSide];
        }else if(card.element == elementFire){
            [self animateCardFireDamage:targetCard.cardView fromSide:oppositeSide];
        }else if(card.element == elementLightning){
            [self animateCardThunderDamage:targetCard.cardView fromSide:oppositeSide];
        }

        [self animateCardDamage:targetCard.cardView forDamage:[damages[0] integerValue] fromSide:oppositeSide];
    } afterDelay:0.1];
    
    //animate damage to attacker if hero somehow dealt damage
    if (damages[1] > 0)
        [self performBlock:^{
            [self animateCardDamage:card.cardView forDamage:[damages[1] integerValue] fromSide:side];
        } afterDelay:0.4];
    
    //update views after the attack
    [card.cardView updateView];
    [targetCard.cardView updateView];
    
    //brian nov 13 update resource label
    CardView*player = (CardView*)self.playerHeroViews[PLAYER_SIDE];
    CardView*opponent = (CardView*)self.playerHeroViews[OPPONENT_SIDE];
    
    MonsterCardModel *opponentmonster = (MonsterCardModel*)opponent.cardModel;
    MonsterCardModel *heromonster = (MonsterCardModel*)player.cardModel;
    
    [self updateHealthView:PLAYER_SIDE newLife:heromonster.life newMax:heromonster.maximumLife];
    [self updateHealthView:OPPONENT_SIDE newLife:opponentmonster.life newMax:opponentmonster.maximumLife];
    
    if (side == PLAYER_SIDE)
    {
        gameControlState = gameControlStateNone;
        currentCard.cardView.cardViewState = cardViewStateNone;
        card.cardView.cardHighlightType = cardHighlightNone;
        currentCard = nil;
    }
    
    /*
     [self performBlock:^{
     [self updateBattlefieldView:currentSide];
     }  afterDelay:2];
     */
}


/** Since the opponent is not meant to be controlled, this method must only be called for the player side */
-(void) scaleDraggingCard: (CardView*) card atPoint: (CGPoint) point
{
    float scale = CARD_DRAGGING_SCALE;
    
    //Scales between two ends at a and b
    float a = SCREEN_HEIGHT - SCREEN_HEIGHT*FIELD_CENTER_Y_RATIO + CARD_HEIGHT * 0.5;
    float b = SCREEN_HEIGHT - CARD_HEIGHT * 1;
    
    if (point.y < a)
        scale = CARD_DEFAULT_SCALE;
    else if (point.y > b)
        scale = CARD_DRAGGING_SCALE;
    else
    {
        //slerp x from a to b, used as the scale
        float x = (point.y-a)/(b-a);
        
        //use only [0,pi/2] of the function for a better effect
        scale =  (1 - cos(x*M_PI_2)) * (CARD_DRAGGING_SCALE-CARD_DEFAULT_SCALE) + CARD_DEFAULT_SCALE;
    }
    
    currentCard.cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
}

-(void)pickAbilityTarget: (Ability*) ability castedBy:(CardModel*)caster
{
    //cannot be used for opponent/AI
    if (currentSide != PLAYER_SIDE)
        return;
    
    //has no applicable target, don't bother
    if (![self.gameModel abilityHasValidTargets:ability castedBy:caster side:PLAYER_SIDE])
        return;
    
    [self.currentAbilities addObject:ability];
    [self updateBattlefieldView:PLAYER_SIDE];
    
    CardView*player = (CardView*)self.playerHeroViews[PLAYER_SIDE];
    CardView*opponent = (CardView*)self.playerHeroViews[OPPONENT_SIDE];
    
    MonsterCardModel *opponentmonster = (MonsterCardModel*)opponent.cardModel;
    MonsterCardModel *heromonster = (MonsterCardModel*)player.cardModel;
    
    [self updateHealthView:PLAYER_SIDE newLife:heromonster.life newMax:heromonster.maximumLife];
    [self updateHealthView:OPPONENT_SIDE newLife:opponentmonster.life newMax:opponentmonster.maximumLife];
    
    //disable all other views as player must choose a target (no cancelling, for now at least..)
    [self.handsView setUserInteractionEnabled:NO];
    //[self.uiView setUserInteractionEnabled:NO];
    [self.backgroundView setUserInteractionEnabled:NO];
    [self.endTurnButton setUserInteractionEnabled:NO];
    
    if (pickATargetLabel.superview == nil)
    {
        [self.uiView addSubview:pickATargetLabel];
        [self.view addSubview:giveupAbilityButton];
        pickATargetLabel.alpha = 0;
        giveupAbilityButton.alpha = 0;
        [self fadeIn:pickATargetLabel inDuration:0.2];
        [self fadeIn:giveupAbilityButton inDuration:0.2];
    }
}

-(void)summonCard: (CardModel*)card fromSide: (int)side
{
    //opponent summoning has extra animation: maximizes to the left to show the card
    if (side == OPPONENT_SIDE)
    {
        
        CardView*originalView = card.cardView;
        if (card.adminPhotoCheck != 1 && card.adminPhotoCheck != nil) {
            card.cardView.cardImage.image = placeHolderImage;
        }
        if (!originalView.frontFacing) //TODO depends on skill
            [originalView flipCard];
        
        CardView *cardView = [[CardView alloc] initWithModel:card viewMode:cardViewModeZoomedIngame];
        cardView.frontFacing = YES; //TODO depends on skill
        
        card.cardView = originalView;
        
        cardView.center = card.cardView.center; //TODO
        if (card.adminPhotoCheck != 1 && card.adminPhotoCheck != nil) {
            card.cardView.cardImage.image = placeHolderImage;
          //  cardView.image = placeHolderImage;
        }
        [self.uiView addSubview:cardView];
        
        CardView*player = (CardView*)self.playerHeroViews[PLAYER_SIDE];
        CardView*opponent = (CardView*)self.playerHeroViews[OPPONENT_SIDE];
        
        MonsterCardModel *opponentmonster = (MonsterCardModel*)opponent.cardModel;
        MonsterCardModel *heromonster = (MonsterCardModel*)player.cardModel;
        
        [self updateHealthView:PLAYER_SIDE newLife:heromonster.life newMax:heromonster.maximumLife];
        [self updateHealthView:OPPONENT_SIDE newLife:opponentmonster.life newMax:opponentmonster.maximumLife];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             cardView.center = CGPointMake(CARD_FULL_WIDTH/2 + 5,self.view.center.y);
                             cardView.transform = CGAffineTransformMakeScale(CARD_DRAGGING_SCALE, CARD_DRAGGING_SCALE);
                         }
                         completion:^(BOOL finished){
                             [self fadeOutAndRemove:cardView inDuration:0.2 withDelay:1.5];
                         }];
        
        
        //cardView.center = self.view.center;
    }
    
    if (side == PLAYER_SIDE && _gameMode == GameModeMultiplayer)
    {
        //player side during multiplayer requires sending info to opponent
        NSMutableArray*hand = _gameModel.hands[PLAYER_SIDE];
        _currentCardIndex = (int)[hand indexOfObject:card];
        
        [self.gameModel summonCard:card side:side];
        
        //if you summon a minion and it displays a button to give up the ability (cancel the ability), the minion should not be summoned until the user actually decides to cancel the ability
       
        
        
        //only send if no abilities, otherwise player is busy choosing ability
        /*
        if (giveupAbilityButton.superview == nil) //TODO
        {
            //int targetIndex = [self.gameModel getCurrentTargetIndex];
            //[_networkingEngine sendSummonCard:_currentCardIndex withTarget:positionNoPosition];
            [self.MPDataHandler sendSummonCard:_currentCardIndex withTarget:positionNoPosition];
        }*/
        
    }
    else
    {
        //opponent playing or single player
        [self.gameModel summonCard:card side:side];
    }
    
    if ([card isKindOfClass: [MonsterCardModel class]])
    {
        //summon successful, update views
        [card.cardView removeFromSuperview];
        [self.fieldView addSubview:card.cardView];
        [self updateBattlefieldView: side];
    }
    else if ([card isKindOfClass: [SpellCardModel class]])
    {
        //spell card is destroyed right after summoning
        [self animateCardDestruction:card.cardView fromSide:side];
    }
    
    [self updateResourceView: side];
    
    card.cardView.cardViewState = cardViewStateNone;
    if (side == PLAYER_SIDE)
        gameControlState = gameControlStateNone;
    
    [self fadeOut:playerFieldHighlight inDuration:0.2];
    [self fadeOut:opponentFieldHighlight inDuration:0.2];
    
    //update hand's view at the end
    [self updateHandsView:side];
    
    //update player life totals
    //brian nov 13 update resource label
    //get hero cards
    CardView*player = (CardView*)self.playerHeroViews[PLAYER_SIDE];
    CardView*opponent = (CardView*)self.playerHeroViews[OPPONENT_SIDE];
    
    MonsterCardModel *opponentmonster = (MonsterCardModel*)opponent.cardModel;
    MonsterCardModel *heromonster = (MonsterCardModel*)player.cardModel;
    
    [self updateHealthView:PLAYER_SIDE newLife:heromonster.life newMax:heromonster.maximumLife];
    [self updateHealthView:OPPONENT_SIDE newLife:opponentmonster.life newMax:opponentmonster.maximumLife];
    
    if (_isTutorial)
        [self summonedCardTutorial:card fromSide:side];
}

-(void)setAllViews:(BOOL)state
{
    [self.handsView setUserInteractionEnabled:state];
    //[self.uiView setUserInteractionEnabled:state];
    [self.backgroundView setUserInteractionEnabled:state];
    [self.fieldView setUserInteractionEnabled:state];
    [self.endTurnButton setUserInteractionEnabled:state];
    _viewsDisabled = !state;
}

-(void)quitButtonPressed
{
    [self darkenScreen];
    
    quitConfirmButton.alpha = 0;
    quitCancelButton.alpha = 0;
    quitConfirmLabel.alpha = 0;
    
    [self.view addSubview:quitConfirmButton];
    [self.view addSubview:quitCancelButton];
    [self.view addSubview:quitConfirmLabel];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         quitConfirmButton.alpha = 1;
                         quitCancelButton.alpha = 1;
                         quitConfirmLabel.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         
                     }];
}

-(void)quitConfirmButtonPressed
{
    if (_gameMode == GameModeMultiplayer)
    {
        //[_networkingEngine sendOpponentForfeit];
        
        if(quitConfirmButton.tag ==4)
            //player shouldn't forfeit, should just reset all MP stuff
        {
              [self.MPDataHandler resetAllMPVariables];
        }
        else
        {
            [self.MPDataHandler sendOpponentForfeit];
            _gameModel.playerOneDefeated = YES;
             [self.MPDataHandler resetAllMPVariables];
        }
    }
    [self endGame];
}

-(void)completeTutorial{
    userPF[@"completedLevels"] = @[@"d_1_c_1_l_1",@"d_1_c_1_l_2",@"d_1_c_1_l_4"];
    NSError *error;
    [userPF save:&error];
    
    //Create a deck
    if ([userAllDecks count] == 0) {
        DeckModel* newDeck = [[DeckModel alloc] init];
        newDeck.name = @"New Deck";
        
        for (CardModel* card in userAllCards){
            if (newDeck.cards.count < 20) {
                [newDeck addCard:card];
            }else
                break;
            
        }
        [UserModel saveDeck:newDeck];
    }
    
    if (_noPreviousView)
        [self.presentingViewController
         dismissViewControllerAnimated:YES completion:nil];
    else
        [self.presentingViewController.presentingViewController
         dismissViewControllerAnimated:YES completion:nil];
}

-(void)endGame
{
    //needs to tell MPengine to disconnect and call to end the match
    
    if (_gameMode == GameModeMultiplayer)
    {
        [self.MPDataHandler resetAllMPVariables];
        
        if (_gameModel.playerOneDefeated && _gameModel.playerTwoDefeated)
        {
            //draw
            //[_networkingEngine gameOver:-1];
            [self.MPDataHandler gameOver:-1];
            
        }
        else if (_gameModel.playerOneDefeated)
        {
            //[_networkingEngine gameOver:OPPONENT_SIDE];
            [self.MPDataHandler gameOver:OPPONENT_SIDE];
        }
        else if (_gameModel.playerTwoDefeated)
        {
           // [_networkingEngine gameOver:PLAYER_SIDE];
            [self.MPDataHandler gameOver:PLAYER_SIDE];
        }
        else
            //[_networkingEngine gameOver:-1];
            [self.MPDataHandler gameOver:-1];
    }
    
    if (_noPreviousView)
        [self.presentingViewController
         dismissViewControllerAnimated:YES completion:nil];
    else
        [self.presentingViewController.presentingViewController
         dismissViewControllerAnimated:YES completion:nil];
}

-(void)quitCancelButtonPressed
{
    [self undarkenScreen];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         quitConfirmButton.alpha = 0;
                         quitCancelButton.alpha = 0;
                         quitConfirmLabel.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [quitConfirmButton removeFromSuperview];
                         [quitCancelButton removeFromSuperview];
                         [quitConfirmLabel removeFromSuperview];
                     }];
}

-(void)noTargetButtonPressed
{
    [self.gameModel.currentMoveHistory updateAllValues];
    
    NSLog(@"==================HISTORY RECORDED==================");
    NSLog(@"CASTER: %@", self.gameModel.currentMoveHistory.caster.name);
    
    for (int i = 0; i < self.gameModel.currentMoveHistory.targets.count; i++)
    {
        NSLog(@"TARGET: %@, VALUE: %@", [self.gameModel.currentMoveHistory.targets[i] name], self.gameModel.currentMoveHistory.targetsValues[i]);
    }
    
    NSLog(@"====================================================");
    
    //add history to list
    [self.gameModel.moveHistories addObject:self.gameModel.currentMoveHistory];
    [_moveHistoryTableView.tableView reloadInputViews];
    [_moveHistoryTableView.tableView reloadData];
    
    self.gameModel.currentMoveHistory = nil;

    
    //reset all cards' highlight back to none
    for (MonsterCardModel *card in self.gameModel.battlefield[PLAYER_SIDE])
        card.cardView.cardHighlightType = cardHighlightNone;
    for (MonsterCardModel *card in self.gameModel.battlefield[OPPONENT_SIDE])
        card.cardView.cardHighlightType = cardHighlightNone;
    PlayerModel *player = self.gameModel.players[PLAYER_SIDE];
    player.playerMonster.cardView.cardHighlightType = cardHighlightNone;
    PlayerModel *opponent = self.gameModel.players[OPPONENT_SIDE];
    opponent.playerMonster.cardView.cardHighlightType = cardHighlightNone;
    
    [self.currentAbilities removeAllObjects];
    [self updateBattlefieldView:PLAYER_SIDE]; //update attack highlights
    
    //re-enable the disabled views
    [self.handsView setUserInteractionEnabled:YES];
    [self.uiView setUserInteractionEnabled:YES];
    [self.backgroundView setUserInteractionEnabled:YES];
    [self.endTurnButton setUserInteractionEnabled:YES];
    
    [self fadeOutAndRemove:pickATargetLabel inDuration:0.2 withDelay:0];
    [self fadeOutAndRemove:giveupAbilityButton inDuration:0.2 withDelay:0];
    
    if (_gameMode == GameModeMultiplayer)
        //[_networkingEngine sendSummonCard:_currentCardIndex withTarget:positionNoPosition];
        [self.MPDataHandler sendSummonCard:_currentCardIndex withTarget:positionNoPosition];
    
}

-(void)gameOver
{
    [self.view addSubview:_gameOverBlockingView];
    [userPF fetch];
    newEloRating = [[userPF objectForKey:@"eloRating"] intValue];
    [UserModel increaseUserXP:UMXPGainType_Large];
    [self performBlock:^{
        [self openGameOverScreen];
    } afterDelay:2];
}

-(void)openGameOverScreen
{
    [self darkenScreen];
    
    CGPoint resultsLabelOriginalPoint = _resultsLabel.center;
    CGPoint rewardsLabelOriginalPoint = _rewardsLabel.center;
    
    _resultsLabel.center = CGPointMake(_resultsLabel.center.x + SCREEN_WIDTH, _resultsLabel.center.y);
    _rewardsLabel.center = CGPointMake(_rewardsLabel.center.x + SCREEN_WIDTH, _rewardsLabel.center.y);
    
    [_gameOverScreen addSubview:_rewardsLabel];
    _gameOverScreen.alpha = 0;
    [self.view addSubview:_gameOverScreen];
    
    int goldReward = 0;
    int cardReward = 0;
    
    BOOL levelAlreadyCompleted = NO;
    //no reward if already completed
    for (NSString*completedLevel in userPF[@"completedLevels"])
    {
        if ([_level.levelID isEqualToString:completedLevel])
        {
            levelAlreadyCompleted = YES;
            break;
        }
    }
    
    NSMutableArray*rewards = [NSMutableArray array];
    
    //won
    if (_gameModel.playerTwoDefeated && !_gameModel.playerOneDefeated)
    {
        //no next level
        //if (_nextLevel == nil)
        //{
        
        //if hasn't completed current level
        if (_level != nil && !levelAlreadyCompleted)
        {
            //next level is not a boss fight (tutorial), save progress. OR no next level
            if ((_nextLevel != nil && !_nextLevel.isBossFight) || _nextLevel == nil)
            {
                goldReward = _level.goldReward;
                cardReward = _level.cardReward;
                
                [_gameOverOkButton addTarget:self action:@selector(saveLevelProgress)    forControlEvents:UIControlEventTouchUpInside];
            }
            //next level is boss fight, just go
            else if (_nextLevel != nil && _nextLevel.isBossFight)
            {
                [_gameOverOkButton addTarget:self action:@selector(beginNextLevel)    forControlEvents:UIControlEventTouchUpInside];
            }
            //no next level, quit
            /*else
            {
                [_gameOverOkButton addTarget:self action:@selector(quitConfirmButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
            }*/
        }
        //already completed, simply quits TODO: also gets gold from regular battles
        else
        {
            _gameOverSaveLabel.text = @"";
            
            if (_gameMode == GameModeMultiplayer)
            {
                
                [self.MPDataHandler handlePlayerVictory];
                 newEloRating = [[userPF objectForKey:@"eloRating"] intValue];
                
            }
            //begin next level immediately if exists
            if (_nextLevel != nil)
            {
                [_gameOverOkButton addTarget:self action:@selector(beginNextLevel)    forControlEvents:UIControlEventTouchUpInside];
            }
            //back to main menu
            else
            {
                [_gameOverOkButton addTarget:self action:@selector(quitConfirmButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
                
                //setting tag to 4 when opponent wins so it knows not to forfeit
                _gameOverOkButton.tag = 4;
                
            }
        }
        /*}
        //has next level
        else
        {
            [_gameOverOkButton addTarget:self action:@selector(beginNextLevel)    forControlEvents:UIControlEventTouchUpInside];
        }*/
        
        if (goldReward > 0)
        {
            _rewardGoldLabel.text = [NSString stringWithFormat:@"%d", goldReward];
            [rewards addObject:_rewardGoldImage];
        }else if(_gameMode == GameModeMultiplayer){
            goldReward = 10;
            
            _rewardGoldLabel.text = [NSString stringWithFormat:@"%d", goldReward];
            [rewards addObject:_rewardGoldImage];
            
            userPF[@"gold"] = @([userPF[@"gold"] intValue] + goldReward);
            [userPF save];
        }
        
        if (cardReward > 0)
        {
            _rewardCardLabel.text = [NSString stringWithFormat:@"%d", cardReward];
            [rewards addObject:_rewardCardImage];
        }
        
        //brian May012016
        //adding code for handling XP rewards based on cards used
        
        
        
        _resultsLabel.text = @"Victory!";
    }
    else
    {
        if (_gameModel.playerTwoDefeated && _gameModel.playerOneDefeated)
        {
            _resultsLabel.text = @"Draw!";
        }
        else if (!_gameModel.playerTwoDefeated && _gameModel.playerOneDefeated)
        {
            _resultsLabel.text = @"Defeat!";
            [self.MPDataHandler handlePlayerDefeat];
             newEloRating = [[userPF objectForKey:@"eloRating"] intValue];
        }
        
        [_gameOverOkButton addTarget:self action:@selector(endGame)    forControlEvents:UIControlEventTouchUpInside];
    }
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _gameOverScreen.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         //results animation
                         
                         _gameOverOkButton.alpha = 0;
                         [_gameOverScreen addSubview:_gameOverOkButton];
                         
                         
                         
                         [UIView animateWithDuration:0.2
                                               delay:2
                              usingSpringWithDamping:0.6
                               initialSpringVelocity:0.5
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              _gameOverOkButton.alpha = 1;
                                          }
                                          completion:nil];
                         
                         [UIView animateWithDuration:0.2
                                               delay:0
                              usingSpringWithDamping:0.6
                               initialSpringVelocity:0.5
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              _resultsLabel.center = resultsLabelOriginalPoint;
                                          }
                                          completion:^(BOOL completed){
                                              float delay = 1.0;
                                             // NSLog(@"Old: %d , New: %d", oldEloRating, newEloRating);
                                              for (int i = oldEloRating; i <= newEloRating; i++) {
                                                  [self performSelector:@selector(updateEloRating:) withObject:[NSNumber numberWithInt:i] afterDelay:0.2 * delay];
                                                  delay++;
                                                  //_eloRating.text = [NSString stringWithFormat:@"%d",i];
                                              }
                                              
                                              for (int i = oldEloRating; i >= newEloRating; i--) {
                                                  [self performSelector:@selector(updateEloRating:) withObject:[NSNumber numberWithInt:i] afterDelay:0.2 * delay];
                                                  delay++;
                                              }
                                              
                                              if (newEloRating > oldEloRating) {
                                                  int diff = newEloRating - oldEloRating;
                                                  [self performSelector:@selector(showEloRatingDiff:) withObject:[NSNumber numberWithInt:diff] afterDelay:0.2 * delay];
                                              }else if(oldEloRating > newEloRating){
                                                  int diff = oldEloRating - newEloRating;
                                                  [self performSelector:@selector(showEloRatingDiff:) withObject:[NSNumber numberWithInt:-diff] afterDelay:0.2 * delay];
                                              }
                                              
                                          }];
                         
                         if ((goldReward > 0 || cardReward > 0) && _gameModel.playerTwoDefeated && !_gameModel.playerOneDefeated)
                         {
                             int i = 0;
                             double centerPosition = (rewards.count - 1)/2.f;
                             for (UIView*rewardView in rewards)
                             {
                                 rewardView.transform = CGAffineTransformMakeScale(0, 0);
                                 [_gameOverScreen addSubview:rewardView];
                                 rewardView.center = CGPointMake(SCREEN_WIDTH/2 + (i-centerPosition)*75, SCREEN_HEIGHT/2 + 70);
                                 i++;
                             }
                             
                             //rewards animation
                             [UIView animateWithDuration:0.2
                                                   delay:0.6
                                  usingSpringWithDamping:0.6
                                   initialSpringVelocity:0.5
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  _rewardsLabel.center = rewardsLabelOriginalPoint;
                                              }
                                              completion:^(BOOL completed){
                                                  
                                                  //rewards animation
                                                  [UIView animateWithDuration:0.3
                                                                        delay:0.4
                                                       usingSpringWithDamping:0.6
                                                        initialSpringVelocity:0.5
                                                                      options:UIViewAnimationOptionCurveEaseInOut
                                                                   animations:^{
                                                                       for (UIView*rewardView in rewards)
                                                                           rewardView.transform = CGAffineTransformMakeScale(1, 1);
                                                                   }
                                                                   completion:^(BOOL completed){
                                                                       
                                                                   }];
                                                  
                                              }];
                             
                         }
                         
                     }];
}

-(void)openMoveHistoryScreen
{
    [self darkenScreen];
    [self setAllViews:NO];
    
    _moveHistoryScreen.alpha = 0;
    [self.view addSubview:_moveHistoryScreen];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _moveHistoryScreen.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         moveHistoryOpen = YES;
                     }];
     
}

-(void)closeMoveHistoryScreen
{
    [self undarkenScreen];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _moveHistoryScreen.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [self.view addSubview:_moveHistoryScreen];
                         [self setAllViews:YES];
                         moveHistoryOpen = NO;
                     }];
}

-(void)updateEloRating:(NSNumber*)rating{
    if (_gameMode == GameModeMultiplayer) {
        _eloRating.text = [NSString stringWithFormat:@"%d",rating.intValue];
    }
}

-(void)showEloRatingDiff:(NSNumber*)diff{
    if (oldEloRating > newEloRating) {
        _eloRatingDiff.textColor = [UIColor redColor];
        _eloRatingDiff.text = [NSString stringWithFormat:@"%d",diff.intValue];
    }else{
        _eloRatingDiff.textColor = [UIColor greenColor];
        _eloRatingDiff.text = [NSString stringWithFormat:@"+%d",diff.intValue];
    }
}

-(void)beginNextLevel
{
    if (_nextLevel.isBossFight)
    {
        BossBattleScreenViewController *bbsvc = [[BossBattleScreenViewController alloc] init];
        bbsvc.message = _level.endBattleText;
        GameViewController * nextLevelController = [[GameViewController alloc] initWithGameMode:GameModeSingleplayer withLevel:_nextLevel];
        bbsvc.nextScreen = nextLevelController;
        
        UIViewController*vc;
        
        if (_noPreviousView)
        {
            vc = self.presentingViewController;
        }
        else
            vc = self.presentingViewController.presentingViewController;
        
        [vc dismissViewControllerAnimated:NO completion:^{
            //dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"switched");
                [vc presentViewController:bbsvc animated:NO completion:nil];
            //});
        }];
    }
    //this must be tutorial
    else{
        GameViewController * nextLevelController = [[GameViewController alloc] initWithGameMode:GameModeSingleplayer withLevel:_nextLevel];
        
        UIViewController*vc;
        
        if (_noPreviousView)
        {
            vc = self.presentingViewController;
            nextLevelController.noPreviousView = YES;
        }
        else
        {
            vc = self.presentingViewController.presentingViewController;
        }
        
        
        
        [self dismissViewControllerAnimated:NO completion:^{
            //dispatch_sync(dispatch_get_main_queue(), ^{
                [vc presentViewController:nextLevelController animated:NO completion:nil];
            //});
        }];
    }
    
}

-(void)loadDeckStart
{
    //for (UIView*view in _gameOverScreen.subviews)
    //    [view removeFromSuperview];
    
    [_gameOverScreen addSubview:_gameOverProgressIndicator];
    [_gameOverProgressIndicator startAnimating];
    
    _gameOverSaveLabel.frame = CGRectMake(40, SCREEN_HEIGHT/2, SCREEN_WIDTH-80, SCREEN_HEIGHT/3);
    _gameOverSaveLabel.text = @"Loading Game...";
    //[_gameOverSaveLabel sizeToFit];
    [_gameOverScreen addSubview:_gameOverSaveLabel];
    
    [self darkenScreen];
    [self.view addSubview:_gameOverScreen];
}

-(void)loadDeckFinished
{
    [_gameOverScreen removeFromSuperview];
    [_gameOverProgressIndicator stopAnimating];
    [_gameOverSaveLabel removeFromSuperview];
    if (!_isTutorial && !self.shouldCallEndTurn && self.gameMode == GameModeMultiplayer)
        [self startEndTurnTimer];
}

-(void)saveLevelProgress
{
    for (UIView*view in _gameOverScreen.subviews)
        [view removeFromSuperview];
    
    NSMutableArray*completedLevels = [NSMutableArray arrayWithArray: userPF[@"completedLevels"]];
    if (![completedLevels containsObject:_level.levelID])
    {
        [_gameOverScreen addSubview:_gameOverProgressIndicator];
        [_gameOverProgressIndicator startAnimating];
        
        _gameOverSaveLabel.frame = CGRectMake(40, SCREEN_HEIGHT/2, SCREEN_WIDTH-80, SCREEN_HEIGHT/3);
        _gameOverSaveLabel.text = @"Saving Progress...";
        //[_gameOverSaveLabel sizeToFit];
        [_gameOverScreen addSubview:_gameOverSaveLabel];
        
        /*
         int goldReward = 0;
         int cardReward = 0;
         
         if (_level != nil)
         {
         goldReward = _level.goldReward;
         cardReward = _level.cardReward;
         }
         //dont need to store the level rewards on there. also let server add the completed level
         userPF[@"gold"] = @([userPF[@"gold"] intValue] + goldReward);
         userPF[@"blankCards"] = @([userPF[@"blankCards"] intValue] + cardReward);
         [completedLevels addObject:_level.levelID];
         userPF[@"completedLevels"] = completedLevels;
         
         [self updateUserModel];
         */
        
        int goldReward = 0;
        int cardReward = 0;
        
        if (_level != nil)
        {
            goldReward = _level.goldReward;
            cardReward = _level.cardReward;
        }
        
        [self performBlockInBackground:^{
            NSError* error;
            [PFCloud callFunction:@"levelComplete" withParameters:@{
                                                                    @"levelID" : _level.levelID,
                                                                    @"gold" : @(goldReward),
                                                                    @"blankCards" : @(cardReward)
                                                                    } error:&error];
            if (!error){
                [userPF fetch];
                
                NSLog(@"Progress saved");
                if (_nextLevel != nil)
                    [self beginNextLevel];
                else{
                    if (_level.isTutorial) {
                        [self completeTutorial];
                    }else{
                        [self endGame]; 
                    }
                }
            }
            else{
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    NSLog(@"ERROR: FAILED TO SAVE LEVEL PROGRESS!!!");
                    
                    [_gameOverProgressIndicator stopAnimating];
                    
                    _gameOverSaveLabel.frame = CGRectMake(40, SCREEN_HEIGHT/2, SCREEN_WIDTH-80, SCREEN_HEIGHT/3);
                    _gameOverSaveLabel.text = @"Failed to save progress. Please check your internet connection and try again. If you quit now, your progress will not be saved.";
                    [_gameOverSaveLabel sizeToFit];
                    
                    [_gameOverScreen addSubview:_gameOverRetryButton];
                    [_gameOverScreen addSubview:_gameOverNoRetryButton];
                });
            }
        }];
    }
    else{
        //not supposed to happen, but here anyways
        [self endGame];
    }
}

-(void)updateUserModel
{
    
}

-(void)setOpponentDeck: (DeckModel*)deck
{
    _opponentDeck = deck;
    
    NSLog(@"set opponent deck");
}

-(void)gameOverRetryButtonPressed
{
    _gameOverSaveLabel.frame = CGRectMake(40, SCREEN_HEIGHT/2, SCREEN_WIDTH-80, SCREEN_HEIGHT/3);
    _gameOverSaveLabel.text = @"Retrying...";
    [_gameOverProgressIndicator startAnimating];
    [_gameOverRetryButton removeFromSuperview];
    [_gameOverNoRetryButton removeFromSuperview];
    //[_gameOverSaveLabel sizeToFit];
    [self saveLevelProgress];
}

-(void)gameOverNoRetryButtonPressed
{
    [self quitConfirmButtonPressed];
}

-(void)darkenScreen
{
    darkFilter.alpha = 0;
    [self.view addSubview:darkFilter];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         darkFilter.alpha = 0.9;
                     }
                     completion:nil];
}

-(void)undarkenScreen
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         darkFilter.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [darkFilter removeFromSuperview];
                     }];
}

-(void)viewWillAppear:(BOOL)animated
{
    UIViewController *vc = [self presentedViewController];
    
    if (_isTutorial)
    {
        
        if ([vc isKindOfClass:[CardEditorViewController class]])
        {
            [self returnedFromCardEditorTutorial];
        }
    }
}

-(void)modalScreen
{
    darkFilter.alpha = 3.f/255; //because apparently 0 alpha = cannot be interacted...
    [self.view addSubview:darkFilter];
    
    [self.handsView setUserInteractionEnabled:NO];
    //[self.uiView setUserInteractionEnabled:NO];
    [self.backgroundView setUserInteractionEnabled:NO];
    [self.endTurnButton setUserInteractionEnabled:NO];
    [self.fieldView setUserInteractionEnabled:NO];
}

-(void)unmodalScreen
{
    [darkFilter removeFromSuperview];
    
    [self.handsView setUserInteractionEnabled:YES];
    //[self.uiView setUserInteractionEnabled:YES];
    [self.backgroundView setUserInteractionEnabled:YES];
    [self.endTurnButton setUserInteractionEnabled:YES];
    [self.fieldView setUserInteractionEnabled:YES];
}

//block delay functions
- (void)performBlock:(void (^)())block
{
    block();
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay
{
    void (^block_)() = [block copy]; // autorelease this if you're not using ARC
    [self performSelector:@selector(performBlock:) withObject:block_ afterDelay:delay];
}

- (BOOL)prefersStatusBarHidden {return YES;}

- (void)performBlockInBackground:(void (^)())block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        block();
    });
}

#pragma mark MultiplayerGameProtocol
//BA MAY14 changed the underscore properties to (atomic), keep track to see if there are any issues.

-(void)setPlayerSeed:(uint32_t)seed
{
    _playerSeed = seed;
}

-(void)setOpponentSeed:(uint32_t)seed
{
    _opponentSeed = seed;
}

-(void)opponentSummonedCard:(int)cardIndex withTarget:(int)target
{
    NSMutableArray *hand = _gameModel.hands[OPPONENT_SIDE];
    
    if (cardIndex < 0 || cardIndex >= hand.count)
    {
        NSLog(@"ERROR: Opponent tried to summon a card with invalid index");
    }
    else
    {
        //TODO there might be problems if a number of these all get called at once (<0.4 sec, since gamemodel take delay before casting)
        
        [_gameModel setOpponentTarget: [_gameModel getTarget:target]];
        NSLog(@"opponent current target set as %@ in game view controller", [_gameModel getOpponentTarget]);
        
        [self summonCard:hand[cardIndex] fromSide:OPPONENT_SIDE];
    }
}

-(void)opponentAttackCard:(int)attackerPosition withTarget:(int)target
{
    MonsterCardModel *attacker = [_gameModel getTarget:attackerPosition];
    MonsterCardModel *victim = [_gameModel getTarget:target];
    
    if (target == positionHeroA || target == positionHeroB)
    {
        [self attackHero:attacker target:victim fromSide:OPPONENT_SIDE];
    }
    else
    {
        [self attackCard:attacker target:victim fromSide:OPPONENT_SIDE];
    }
    
}

-(void)opponentForfeit
{
    //TODO say opponent quit
    _gameModel.playerTwoDefeated = YES;
    [_gameModel checkForGameOver];
}

@end
