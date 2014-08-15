//
//  ViewController.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "GameViewController.h"
#import "GameViewController+Animation.h"
#import "CardView.h"
#import "MonsterCardModel.h"
#import "CGPointUtilities.h"
#import "MainScreenViewController.h"
#import "GameInfoTableView.h"


@interface GameViewController ()

@end

@implementation GameViewController

@synthesize gameModel = _gameModel;
@synthesize handsView, fieldView, uiView, backgroundView;
@synthesize currentAbilities = _currentAbilities;
@synthesize endTurnButton = _endTurnButton;
@synthesize currentNumberOfAnimations = _currentNumberOfAnimations;

/** Screen dimension for convinience */
int SCREEN_WIDTH, SCREEN_HEIGHT;

/** current side's turn, i.e. current player */
int currentSide;

const float FIELD_CENTER_Y_RATIO = 3/8.f;

/** UILabel used to darken the screen during card selections */
UIView *darkFilter;

/** TODO: temporary label for representing the attack line when targetting monsters */
UILabel *attackLine;

/** stores array of two label for showing the current player's resource */
NSArray *resourceLabels;

UIImageView *playerFieldHighlight, *opponentFieldHighlight, *playerFieldEdge, *opponentFieldEdge;

UIImageView *battlefieldBackground;

UIButton *quitButton, *quitConfirmButton, *quitCancelButton;
UILabel *quitConfirmLabel;

StrokedLabel *pickATargetLabel;
UIButton *giveupAbilityButton;

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

-(instancetype)initWithGameMode:(enum GameMode)gameMode withLevel:(Level*)level
{
    self = [super init];
    
    if (self)
    {
        _gameMode = gameMode;
        _level = level;
        
        currentSide = PLAYER_SIDE;//TODO multiplayer
        
        if (level!=nil)
        {
            if (level.playerGoesFirst)
                currentSide = PLAYER_SIDE;
            else
                currentSide = OPPONENT_SIDE;
        }
    
        //inits array
        self.currentAbilities = [NSMutableArray array];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
    gameControlState = gameControlStateNone;
    
    //inits the game model storing the game's data
    self.gameModel = [[GameModel alloc] initWithViewController:(self) gameMode:_gameMode withLevel:_level];
    
    //TODO this is really stupid, currentSide should be gameModel's property..
    PlayerModel *player = self.gameModel.players[currentSide];
    player.maxResource++;
    player.resource = player.maxResource;
    
    //contains most of the code for initialzing and positioning the UI objects
    [self setupUI];
    
    //start a new game, each player draws three cards
    [self.gameModel startGame];
    
    //add all cards onto screen
    [self updateHandsView: PLAYER_SIDE];
    [self updateHandsView: OPPONENT_SIDE];
    [self updateResourceView: PLAYER_SIDE];
    [self updateResourceView: OPPONENT_SIDE];
    
    self.currentNumberOfAnimations = 0; //init
}

/** Purely for organization, called once when the view is first set up */
-(void) setupUI
{
    //for checking fonts
    /*
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
*/
    
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
    
    [self.view addSubview:backgroundView];
    [self.view addSubview:fieldView];
    [self.view addSubview:handsView];
    [self.view addSubview:uiView];
    
    battlefieldBackground  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"battle_background_0"]];
    battlefieldBackground.center = self.view.center;
    battlefieldBackground.frame = self.view.frame;
    [backgroundView addSubview:battlefieldBackground];
    
    //----set up the attack line----//
    attackLine = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0, 0)];
    attackLine.backgroundColor = [UIColor colorWithRed:0.67 green:0.08 blue:0 alpha:0.6];
    
    //----set up the resource labels----//
    StrokedLabel*playerResourceLabel = [[StrokedLabel alloc] initWithFrame: CGRectMake(0, 0, 60, 30)];
    playerResourceLabel.center = CGPointMake(SCREEN_WIDTH - 30, SCREEN_HEIGHT - 30);
    playerResourceLabel.textAlignment = NSTextAlignmentCenter;
    playerResourceLabel.textColor = [UIColor whiteColor];
    playerResourceLabel.backgroundColor = [UIColor clearColor];
    playerResourceLabel.font = [UIFont fontWithName:cardMainFont size:20];
    playerResourceLabel.adjustsFontSizeToFitWidth = YES;
    playerResourceLabel.strokeColour = [UIColor blackColor];
    playerResourceLabel.strokeOn = YES;
    playerResourceLabel.strokeThickness = 3;
    UIImageView *playerResourceIcon = [[UIImageView alloc] initWithImage:RESOURCE_ICON_IMAGE];
    playerResourceIcon.frame = CGRectMake(0, 0, 45, 45);
    playerResourceIcon.center = playerResourceLabel.center;
    
    StrokedLabel*opponentResourceLabel = [[StrokedLabel alloc] initWithFrame: CGRectMake(0,0, 60, 30)];
    opponentResourceLabel.center = CGPointMake(SCREEN_WIDTH - 30, 30);
    opponentResourceLabel.textAlignment = NSTextAlignmentCenter;
    opponentResourceLabel.textColor = [UIColor whiteColor];
    opponentResourceLabel.backgroundColor = [UIColor clearColor];
    opponentResourceLabel.font = [UIFont fontWithName:cardMainFont size:20];
    opponentResourceLabel.adjustsFontSizeToFitWidth = YES;
    opponentResourceLabel.strokeColour = [UIColor blackColor];
    opponentResourceLabel.strokeOn = YES;
    opponentResourceLabel.strokeThickness = 3;
    UIImageView *opponentResourceIcon = [[UIImageView alloc] initWithImage:RESOURCE_ICON_IMAGE];
    opponentResourceIcon.frame = CGRectMake(0, 0, 45, 45);
    opponentResourceIcon.center = opponentResourceLabel.center;
    resourceLabels = @[playerResourceLabel,opponentResourceLabel];
    [self.uiView addSubview:playerResourceIcon];
    [self.uiView addSubview:opponentResourceIcon];
    [self.uiView addSubview:resourceLabels[PLAYER_SIDE]];
    [self.uiView addSubview:resourceLabels[OPPONENT_SIDE]];
    
    //----set up the field highlights----//
    playerFieldHighlight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_highlight"]];
    opponentFieldHighlight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_highlight"]];
    
    playerFieldEdge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_edge"]];
    opponentFieldEdge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_edge"]];
    
    //half of the distance between the two fields
    int fieldsDistanceHalf = 5;
    
    //fields are not at center Y, instead move up a little since opponent has no end button
    int fieldsYOffset = 0; //TODO probably make this dynamic
    
    playerFieldHighlight.bounds = CGRectMake(0,0,(CARD_WIDTH * 5)  + CARD_HEIGHT * 0.1, CARD_HEIGHT + CARD_HEIGHT * 0.1);
    playerFieldHighlight.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + fieldsDistanceHalf + playerFieldHighlight.bounds.size.height/2 + fieldsYOffset) ;
    
    playerFieldEdge.bounds = CGRectMake(0,0,(CARD_WIDTH * 5)  + CARD_HEIGHT * 0.1, CARD_HEIGHT + CARD_HEIGHT * 0.1);
    playerFieldEdge.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + fieldsDistanceHalf + playerFieldEdge.bounds.size.height/2 + fieldsYOffset) ;
    
    playerFieldHighlight.alpha = 0;
    
    [self.backgroundView addSubview:playerFieldHighlight];
    [self.backgroundView addSubview:playerFieldEdge];
    
    opponentFieldHighlight.bounds = CGRectMake(0,0,(CARD_WIDTH * 5)  + CARD_HEIGHT * 0.1, CARD_HEIGHT + CARD_HEIGHT * 0.1);
    opponentFieldHighlight.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - fieldsDistanceHalf - opponentFieldHighlight.bounds.size.height/2 + fieldsYOffset) ;
    
    opponentFieldEdge.bounds = CGRectMake(0,0,(CARD_WIDTH * 5)  + CARD_HEIGHT * 0.1, CARD_HEIGHT + CARD_HEIGHT * 0.1);
    opponentFieldEdge.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - fieldsDistanceHalf - opponentFieldEdge.bounds.size.height/2 + fieldsYOffset) ;
    
    opponentFieldHighlight.alpha = 0;
    
    [self.backgroundView addSubview:opponentFieldHighlight];
    [self.backgroundView addSubview:opponentFieldEdge];
    
    UIView*backgroundOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"battle_background_0_overlay"]];
    backgroundOverlay.frame = self.view.bounds;
    [self.backgroundView addSubview:backgroundOverlay];
    
    //----end turn button----//
    UIImage* endTurnImage = [UIImage imageNamed:@"end_turn_button_up.png"]; //TODO all these images to load function
    UIImage* endTurnDisabledImage = [UIImage imageNamed:@"end_turn_button_disabled.png"];
    self.endTurnButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.endTurnButton.frame = CGRectMake(0, 0, 60, 45);
    //[button setTitle:@"test" forState:UIControlStateNormal];
    [self.endTurnButton setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
    [self.endTurnButton setBackgroundImage:endTurnImage forState:UIControlStateNormal];
    [self.endTurnButton setBackgroundImage:endTurnDisabledImage forState:UIControlStateDisabled];
    [self.endTurnButton addTarget:self action:@selector(endTurn)    forControlEvents:UIControlEventTouchUpInside];
    
    //end button is aligned with field's right border and has same distance away as the distance between the two fields
    self.endTurnButton.center = CGPointMake(SCREEN_WIDTH - (SCREEN_WIDTH - playerFieldEdge.bounds.size.width)/2 - self.endTurnButton.frame.size.width/2, playerFieldEdge.center.y + playerFieldEdge.bounds.size.height/2 + fieldsDistanceHalf*2 + self.endTurnButton.frame.size.height/2);
    [self.backgroundView addSubview: self.endTurnButton];
    
    //quit button
    quitButton = [[UIButton alloc] initWithFrame:CGRectMake(4, SCREEN_HEIGHT-36, 46, 32)];
    [quitButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [quitButton addTarget:self action:@selector(quitButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.uiView addSubview:quitButton];
    
    quitConfirmLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT)];
    quitConfirmLabel.textColor = [UIColor whiteColor];
    quitConfirmLabel.backgroundColor = [UIColor clearColor];
    quitConfirmLabel.font = [UIFont fontWithName:cardMainFont size:25];
    quitConfirmLabel.textAlignment = NSTextAlignmentCenter;
    quitConfirmLabel.lineBreakMode = NSLineBreakByWordWrapping;
    quitConfirmLabel.numberOfLines = 0;
    quitConfirmLabel.text = @"Are you sure you want to quit? You will lose this game.";
    [quitConfirmLabel sizeToFit];
    
    quitConfirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    quitConfirmButton.center = CGPointMake(SCREEN_WIDTH/2 - 80, SCREEN_HEIGHT - 60);
    [quitConfirmButton setImage:[UIImage imageNamed:@"yes_button"] forState:UIControlStateNormal];
    [quitConfirmButton addTarget:self action:@selector(quitConfirmButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    quitCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    quitCancelButton.center = CGPointMake(SCREEN_WIDTH/2 + 80, SCREEN_HEIGHT - 60);
    [quitCancelButton setImage:[UIImage imageNamed:@"no_button"] forState:UIControlStateNormal];
    [quitCancelButton addTarget:self action:@selector(quitCancelButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //-----Player's heroes-----//
    
    CardView *playerHeroView = [[CardView alloc] initWithModel:((PlayerModel*)self.gameModel.players[PLAYER_SIDE]).playerMonster viewMode:cardViewModeIngame];
    playerHeroView.center = CGPointMake((SCREEN_WIDTH - playerFieldEdge.bounds.size.width)/2 + PLAYER_HERO_WIDTH/2, playerFieldEdge.center.y + playerFieldEdge.bounds.size.height/2 + fieldsDistanceHalf*2 + PLAYER_HERO_HEIGHT/2);
    [self.fieldView addSubview:playerHeroView];
    
    CardView *opponentHeroView = [[CardView alloc] initWithModel:((PlayerModel*)self.gameModel.players[OPPONENT_SIDE]).playerMonster viewMode:cardViewModeIngame];
    opponentHeroView.center = CGPointMake((SCREEN_WIDTH - opponentFieldEdge.bounds.size.width)/2 + PLAYER_HERO_WIDTH/2, opponentFieldEdge.center.y - opponentFieldEdge.bounds.size.height/2 - fieldsDistanceHalf*2 - PLAYER_HERO_HEIGHT/2);
    [self.fieldView addSubview:opponentHeroView];
    
    self.playerHeroViews = @[playerHeroView, opponentHeroView];
    
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
    
    giveupAbilityButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 45)];
    giveupAbilityButton.center = CGPointMake(self.view.bounds.size.width/2 + 20, self.view.bounds.size.height-60);
    [giveupAbilityButton setImage:[UIImage imageNamed:@"no_target_button"] forState:UIControlStateNormal];
    [giveupAbilityButton addTarget:self action:@selector(noTargetButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //for target selection
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(tapRegistered:)];
    [tapGesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGesture];
}

-(void)newGame
{
    [self animatePlayerTurn];
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
                //cast all abilities at this card
                for (Ability *ability in self.currentAbilities){
                    [self.gameModel castAbility:ability byMonsterCard:nil toMonsterCard:target fromSide:PLAYER_SIDE];
                    [target.cardView updateView];
                }
                
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
                //[self updateBattlefieldView:PLAYER_SIDE];
                [self updateHandsView:PLAYER_SIDE];
                
                //re-enable the disabled views
                [self.handsView setUserInteractionEnabled:YES];
                [self.uiView setUserInteractionEnabled:YES];
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
                if (hitView == card.cardView)
                {
                    [self zoomFieldCard:card];
                    tappedOnACard = YES;
                    break;
                }
            }
        
        //temporary for debugging
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
        
        if (tappedOnACard)
        {
            gameControlState = gameControlStateNone;
            [attackLine removeFromSuperview];
        }
    }
    if (hitView == self.viewingCardView)
    {
        gameControlState = gameControlStateNone;
        
        [self.viewingCardView setUserInteractionEnabled:NO];
        
        [self unmodalScreen];
        
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
    
    card.cardView = originalView; //recover the pointer
    
    [self.viewingCardView setCardViewState:cardViewStateMaximize];
    self.viewingCardView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    [self modalScreen];
    
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


-(void) endTurn{
    //tell the gameModel to end turn
    [self.gameModel endTurn: currentSide];
    
    int previousSide = currentSide;
    
    //switch player after turn's over
    if (currentSide == PLAYER_SIDE)
    {
        currentSide = OPPONENT_SIDE;
    }
    else
    {
        currentSide = PLAYER_SIDE;
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
        height = CARD_HEIGHT/2;
    
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
        CGPoint newCenter = CGPointMake((i-handCenterIndex+0.5) * CARD_WIDTH/2.3 + ((hand.count+1)%2 * CARD_WIDTH/4) + SCREEN_WIDTH/1.8, height + abs(distanceFromCenter) * 3);
        
        //if card has no view, create one
        if (card.cardView == nil)
        {
            CardView *cardView = [[CardView alloc] initWithModel:card viewMode:cardViewModeIngame];
            card.cardView = cardView;
            [self.handsView addSubview:card.cardView];
            
            //assuming new cards are always drawn from the deck (TODO: NOT ACTUALLY TRUE! May be summoned from ability etc)
            if(side == PLAYER_SIDE)
                card.cardView.center = CGPointMake(SCREEN_WIDTH + CARD_WIDTH, SCREEN_HEIGHT-CARD_HEIGHT);
            else if (side == OPPONENT_SIDE)
                card.cardView.center = CGPointMake(SCREEN_WIDTH + CARD_WIDTH, CARD_HEIGHT) ;
        }
        
        [card.cardView resetTransformations];
        
        //if (hand.count != 1)
        card.cardView.transform = CGAffineTransformConcat(card.cardView.transform, CGAffineTransformMakeRotation(M_PI_4/12 * distanceFromCenter));
        
        //show suggestion glow if it's player's turn and the card can be used, but no suggestion during targetting a spell
        if (currentSide == PLAYER_SIDE &&  side == PLAYER_SIDE && [self.gameModel canSummonCard:card side:currentSide] && [self.currentAbilities count] == 0)
            card.cardView.cardHighlightType = cardHighlightSelect;
        else
            card.cardView.cardHighlightType = cardHighlightNone;
        
        //slerp to the position
        [self animateMoveToWithBounce:card.cardView toPosition:newCenter inDuration:0.5];
    }
}

-(void)updateBattlefieldView: (int)side
{
    NSArray *field = self.gameModel.battlefield[side];
    
    float battlefieldCenterIndex = field.count/2; //for positioning the cards
    
    //predetermine the y position of the card depending on which side it's on
    int height = 0;
    
    if (side == PLAYER_SIDE)
        height = playerFieldHighlight.center.y;
    else if (side == OPPONENT_SIDE)
        height = opponentFieldHighlight.center.y;
    
    //iterate through all field cards and set their views correctly
    for (int i = 0; i < field.count; i++)
    {
        MonsterCardModel *card = field[i];
        
        if (card.dead) //dead cards are in the process of being removed, don't update it
            continue;
        
        //positions the hand by laying them out from the center
        CGPoint newCenter = CGPointMake((i-battlefieldCenterIndex) * CARD_WIDTH + ((field.count+1)%2 * CARD_WIDTH/2) + SCREEN_WIDTH/2, height);
        
        //if card has no view, create one
        if (card.cardView == nil)
        {
            CardView *cardView = [[CardView alloc] initWithModel:card viewMode:cardViewModeIngame];
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
            card.cardView.cardHighlightType = cardHighlightSelect;
        //if not currently trying to summon an ability, reset highlight to none
        else if ([self.currentAbilities count] == 0 || card.cardView.cardHighlightType != cardHighlightTarget)
            card.cardView.cardHighlightType = cardHighlightNone;
    }
    
    //update hero
    CardView*player = self.playerHeroViews[side];
    player.cardHighlightType = cardHighlightNone;
}

/** update the corresponding resource label with the number of resource the player has */
-(void)updateResourceView: (int)side
{
    PlayerModel *player = self.gameModel.players[side];
    [resourceLabels[side] setText:[NSString stringWithFormat:@"%d/%d", player.resource, player.maxResource]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    //this is handeled in tap
    if ([self.currentAbilities count] > 0)
        return;
    
    //below card height, dragging cycles through cards
    if (currentPoint.y > SCREEN_HEIGHT - CARD_HEIGHT && currentSide == PLAYER_SIDE)
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
                    
                    PlayerModel*opponent = self.gameModel.players[OPPONENT_SIDE];
                    if ([self.gameModel validAttack:monsterCard target:opponent.playerMonster])
                        opponent.playerMonster.cardView.cardHighlightType = cardHighlightTarget;
                }
            }
            
            break; //break even if cannot attack
        }
    }
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
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
            if ([self.gameModel canSummonCard:currentCard side:currentSide])
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
        
        //TODO: temporary attack line, just a label with red background (red rect)
        attackLine.center = CGPointAdd(p1, CGPointDivideScalar((CGPointSubtract(p2, p1)), 2));
        int length = (int)CGPointDistance(p1, p2);
        attackLine.bounds = CGRectMake(0,-10,(int)(length*1),4);
        [attackLine setTransform: CGAffineTransformMakeRotation(CGPointAngle(p1,p2))];
    }
}


-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
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
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView: self.view];
    
    UIView*view = [touch view];
    
    //when dragging hand card, card is deployed
    if (gameControlState == gameControlStateDraggingHandCard)
    {
        //if dragged into deployment rect TODO temp position
        
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
        if (CGRectContainsPoint(fieldRect.bounds, relativePoint) && [self.gameModel canSummonCard:currentCard side:currentSide])
        {
            [self summonCard:currentCard fromSide:PLAYER_SIDE];
        }
        else
        {
            //revert the states
            currentCard.cardView.cardViewState = cardViewStateNone;
            gameControlState = gameControlStateNone;
            
            //re-insert the card back at its original index in the view
            [currentCard.cardView removeFromSuperview];
            [self.handsView insertSubview:currentCard.cardView atIndex:currentCard.cardView.previousViewIndex];
            
            //update hand's view at the end
            [self updateHandsView:currentSide];
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
        
        int oppositeSide = currentSide == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
        
        //first step check enemy players
        CardView* enemyHeroView = ((CardView*)self.playerHeroViews[oppositeSide]);
        
        CGPoint relativePoint = [self.playerHeroViews[oppositeSide] convertPoint:currentPoint fromView:self.view];
        if (CGRectContainsPoint(enemyHeroView.bounds, relativePoint))
        {
            if ([self.gameModel validAttack:currentCard target:(MonsterCardModel*)enemyHeroView.cardModel])
                [self attackHero:currentCard target:(MonsterCardModel*) enemyHeroView.cardModel fromSide:currentSide];
        }
        else
        {
            //then check for targetted an enemy monster card
            for (CardModel *card in self.gameModel.battlefield[oppositeSide])
            {
                CardView *cardView = card.cardView;
                
                //convert touch point to point relative to the card
                CGPoint relativePoint = [cardView convertPoint:currentPoint fromView:self.view];
                
                //found enemy card
                if (CGRectContainsPoint(cardView.bounds, relativePoint))
                {
                    if ([self.gameModel validAttack:currentCard target:(MonsterCardModel*)card])
                        [self attackCard:currentCard target:(MonsterCardModel*)card fromSide:currentSide];
                    break;
                }
            }
        }
        
        //remove the attack line from view and revert states
        [attackLine removeFromSuperview];
    }
}

-(void) attackCard: (CardModel*) card target:(MonsterCardModel*)targetCard fromSide: (int) side
{
    int oppositeSide = currentSide == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
    
    //deal the damage and return it to animate
    NSArray *damages = [self.gameModel attackCard:card fromSide:side target:targetCard];
    
    //animate the damage effects, if card dies, death animation is played
    [self animateCardAttack:card.cardView fromSide:side];
    
    [self performBlock:^{
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
    
    //deal the damage and return it to animate
    NSArray *damages = [self.gameModel attackCard:card fromSide:side target:targetCard];
    
    //animate the damage effects for defender, if card dies, death animation is played
    [self animateCardAttack:card.cardView fromSide:side];
    
    [self performBlock:^{
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
    
    //disable all other views as player must choose a target (no cancelling, for now at least..)
    [self.handsView setUserInteractionEnabled:NO];
    [self.uiView setUserInteractionEnabled:NO];
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
        CardView *cardView = [[CardView alloc] initWithModel:card viewMode:cardViewModeZoomedIngame];
        card.cardView = originalView;
        
        cardView.center = card.cardView.center; //TODO
        
        [self.uiView addSubview:cardView];
        
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
    
    [self.gameModel summonCard: card side: side];
    
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
    gameControlState = gameControlStateNone;
    
    [self fadeOut:playerFieldHighlight inDuration:0.2];
    [self fadeOut:opponentFieldHighlight inDuration:0.2];
    
    //update hand's view at the end
    [self updateHandsView:side];
}

-(void)setAllViews:(BOOL)state
{
    [self.handsView setUserInteractionEnabled:state];
    [self.uiView setUserInteractionEnabled:state];
    [self.backgroundView setUserInteractionEnabled:state];
    [self.fieldView setUserInteractionEnabled:state];
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
    MainScreenViewController *viewController = [[MainScreenViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
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
    
    //re-enable the disabled views
    [self.handsView setUserInteractionEnabled:YES];
    [self.uiView setUserInteractionEnabled:YES];
    [self.backgroundView setUserInteractionEnabled:YES];
    [self.endTurnButton setUserInteractionEnabled:YES];
    
    [self fadeOutAndRemove:pickATargetLabel inDuration:0.2 withDelay:0];
    [self fadeOutAndRemove:giveupAbilityButton inDuration:0.2 withDelay:0];
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

-(void)modalScreen
{
    darkFilter.alpha = 0.1; //because apparently 0 alpha = cannot be interacted...
    [self.view addSubview:darkFilter];
}

-(void)unmodalScreen
{
    [darkFilter removeFromSuperview];
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

@end
