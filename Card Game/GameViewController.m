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

//TODO!!!!!!!!!!!!! put views into subviews (UI view, card view, background view)

@interface GameViewController ()

@end

@implementation GameViewController

@synthesize gameModel = _gameModel;
@synthesize handsView, fieldView, uiView, backgroundView;
@synthesize currentAbilities = _currentAbilities;
@synthesize endTurnButton = _endTurnButton;

/** Screen dimension for convinience */
int SCREEN_WIDTH, SCREEN_HEIGHT;

/** current side's turn, i.e. current player */
int currentSide;

const float FIELD_CENTER_Y_RATIO = 3/8.f;

/** label for showing the current player */
UILabel *currentSideLabel;

/** TODO: temporary label for representing the attack line when targetting monsters */
UILabel *attackLine;

/** stores array of two label for showing the current player's resource */
NSArray *resourceLabels;

UIImageView *playerFieldHighlight, *opponentFieldHighlight, *playerFieldEdge, *opponentFieldEdge;

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

+(void) loadResources
{
    [CardView loadResources];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
    [GameViewController loadResources];
    
    gameControlState = gameControlStateNone;
    
    //variable setups TODO probably move elsewhere
    //card's size is determined based on screen width, assuming height>width TODO: NOT the case for ipad in landscape
    CARD_WIDTH = ((SCREEN_WIDTH / 5) * 0.9);
    CARD_HEIGHT = (CARD_WIDTH *  CARD_HEIGHT_RATIO / CARD_WIDTH_RATIO);
    
    CARD_FULL_WIDTH = CARD_WIDTH/CARD_DEFAULT_SCALE;
    CARD_FULL_HEIGHT = CARD_HEIGHT/CARD_DEFAULT_SCALE;
    
    PLAYER_HERO_WIDTH = PLAYER_HERO_HEIGHT = CARD_HEIGHT;
    
    currentSide = PLAYER_SIDE; //TODO not always player begins later
    
    //inits the game model storing the game's data
    self.gameModel = [[GameModel alloc] initWithViewController:(self) matchType:matchSinglePlayer];
    
    //inits array
    self.currentAbilities = [NSMutableArray array];
    
    //contains most of the code for initialzing and positioning the UI objects
    [self setupUI];
    
    //TODO player 1 begins with one extra resource (because starts first)
    PlayerModel *player = self.gameModel.players[currentSide];
    player.maxResource++;
    player.resource = player.maxResource;
    
    //add all cards onto screen
    [self updateHandsView: PLAYER_SIDE];
    [self updateHandsView: OPPONENT_SIDE];
    [self updateResourceView: PLAYER_SIDE];
    [self updateResourceView: OPPONENT_SIDE];
}

/** Purely for organization, called once when the view is first set up */
-(void) setupUI
{
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
    
    //TODO temporary side label
    currentSideLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 20, 150, 20)];
    currentSideLabel.text = @"Player's turn"; //TODO
    
    [self.uiView addSubview: currentSideLabel];
    
    //----set up the attack line----//
    attackLine = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0, 0)];
    attackLine.backgroundColor = [UIColor redColor];
    
    //----set up the resource labels----//
    //TODO positions are temporary
    resourceLabels = @[[[UILabel alloc] initWithFrame: CGRectMake(SCREEN_WIDTH - 30, SCREEN_HEIGHT - 30, 50, 20)], [[UILabel alloc] initWithFrame: CGRectMake(SCREEN_WIDTH - 30,  40, 50, 20)]];
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
    
    //----end turn button----//
    UIImage* endTurnImage = [UIImage imageNamed:@"end_turn_button_up.png"];
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
    
    //-----Player's heroes-----//
    
    CardView *playerHeroView = [[CardView alloc] initWithModel:((PlayerModel*)self.gameModel.players[PLAYER_SIDE]).playerMonster cardImage:[[UIImageView alloc]initWithImage: [UIImage imageNamed:@"hero_default"]]];
    playerHeroView.center = CGPointMake((SCREEN_WIDTH - playerFieldEdge.bounds.size.width)/2 + PLAYER_HERO_WIDTH/2, playerFieldEdge.center.y + playerFieldEdge.bounds.size.height/2 + fieldsDistanceHalf*2 + PLAYER_HERO_HEIGHT/2);
    [self.fieldView addSubview:playerHeroView];
    
    CardView *opponentHeroView = [[CardView alloc] initWithModel:((PlayerModel*)self.gameModel.players[OPPONENT_SIDE]).playerMonster cardImage:[[UIImageView alloc]initWithImage: [UIImage imageNamed:@"hero_default"]]];
    opponentHeroView.center = CGPointMake((SCREEN_WIDTH - opponentFieldEdge.bounds.size.width)/2 + PLAYER_HERO_WIDTH/2, opponentFieldEdge.center.y - opponentFieldEdge.bounds.size.height/2 - fieldsDistanceHalf*2 - PLAYER_HERO_HEIGHT/2);
    [self.fieldView addSubview:opponentHeroView];
    
    self.playerHeroViews = @[playerHeroView, opponentHeroView];
}

-(void) endTurn{
    //tell the gameModel to end turn
    [self.gameModel endTurn: currentSide];
    
    int previousSide = currentSide;
    
    //switch player after turn's over
    if (currentSide == PLAYER_SIDE)
    {
        currentSide = OPPONENT_SIDE;
        currentSideLabel.text = @"Opponent's turn";
    }
    else
    {
        currentSide = PLAYER_SIDE;
        currentSideLabel.text = @"Player's turn";
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
        [self.endTurnButton setEnabled:YES];
    else
        [self.endTurnButton setEnabled:NO];
    
    
    //if playing against AI, AI now makes a move
    if (self.gameModel.matchType == matchSinglePlayer && currentSide == OPPONENT_SIDE)
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
        CGPoint newCenter = CGPointMake((i-handCenterIndex+0.5) * CARD_WIDTH/2.5 + ((hand.count+1)%2 * CARD_WIDTH/4) + SCREEN_WIDTH/1.7, height + abs(distanceFromCenter) * 3);
        
        //if card has no view, create one
        if (card.cardView == nil)
        {
            CardView *cardView = [[CardView alloc] initWithModel:card cardImage:[[UIImageView alloc]initWithImage: [UIImage imageNamed:@"card_image_placeholder"]]];
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
        [self animateMoveToWithBounce:card.cardView toPosition:newCenter inDuration:0.25];
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
    
    //iterate through all player's hand's cards and set their views correctly
    for (int i = 0; i < field.count; i++)
    {
        MonsterCardModel *card = field[i];
        
        //positions the hand by laying them out from the center
        CGPoint newCenter = CGPointMake((i-battlefieldCenterIndex) * CARD_WIDTH + ((field.count+1)%2 * CARD_WIDTH/2) + SCREEN_WIDTH/2, height);
        
        //if card has no view, create one
        if (card.cardView == nil)
        {
            CardView *cardView = [[CardView alloc] initWithModel:card cardImage:[[UIImageView alloc]initWithImage: [UIImage imageNamed:@"card_image_placeholder"]]];
            card.cardView = cardView;
            [self.fieldView addSubview:card.cardView];
            
            card.cardView.center = newCenter; //TODO
        }
        else
        {
            [card.cardView updateView];
            //slerp to the position
            [self animateMoveToWithBounce:card.cardView toPosition:newCenter inDuration:0.25];
        }
        
        //show suggestion glow if it's player's turn and the card can be used, but no suggestion if targetting a spell
        if (currentSide == PLAYER_SIDE && side == PLAYER_SIDE && [self.gameModel canAttack:card fromSide:side] && [self.currentAbilities count] == 0)
            card.cardView.cardHighlightType = cardHighlightSelect;
        //if not currently trying to summon an ability, reset highlight to none
        else if ([self.currentAbilities count] == 0 || card.cardView.cardHighlightType != cardHighlightTarget)
            card.cardView.cardHighlightType = cardHighlightNone;
    }
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
    
    //if picking a target for abilities and touched a card
    if ([self.currentAbilities count] > 0 && [[touch view] isKindOfClass:[CardView class]])
    {
        UIView *touchView = [touch view];
        MonsterCardModel *target = (MonsterCardModel*)((CardView*)[touch view]).cardModel;
        
        //if card is highlighted, then it must be valid target
        if (target.cardView.cardHighlightType == cardHighlightTarget)
        {
            //cast all abilities at this card
            for (Ability *ability in self.currentAbilities){
                [self.gameModel castAbility:ability byMonsterCard:nil toMonsterCard:target fromSide:PLAYER_SIDE];
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
            [self updateBattlefieldView:OPPONENT_SIDE];
            [self updateBattlefieldView:PLAYER_SIDE];
            
            //re-enable the disabled views
            [self.handsView setUserInteractionEnabled:YES];
            [self.uiView setUserInteractionEnabled:YES];
            [self.backgroundView setUserInteractionEnabled:YES];
            
            return; //prevent the other events happening
        }
    }
    
    //touched a hands card
    //TODO for now allow dragging opponent's hand cards for debugging, but disable later
    for (CardModel *card in self.gameModel.hands[currentSide])
    {
        CardView *cardView = card.cardView;
        
        if ([touch view] == cardView)
        {
            cardView.cardViewState = cardViewStateDragging;
            //cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, DEFAULT_SCALE, DEFAULT_SCALE);
            
            gameControlState = gameControlStateDraggingHandCard;
            currentCard = cardView.cardModel;
            
            //saves the index in the view before bringing it to the front
            cardView.previousViewIndex = [self.handsView.subviews indexOfObject:cardView];
            [self.handsView bringSubviewToFront:cardView];
            cardView.center = [touch locationInView: self.handsView];
            
            
            return; //TODO this is assuming nothing will be done after this
        }
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
        currentCard.cardView.center = currentPoint;
        
        //TODO remove this once game no longer allows controlling both players
        if (currentSide == PLAYER_SIDE)
            [self scaleDraggingCard:currentCard.cardView atPoint:currentPoint];
        
        //highlight field only if can summon the card
        if ([self.gameModel canSummonCard:currentCard side:currentSide])
        {
            //TODO!!! These are only temporary while two-player is enabled, don't need it afterwards
            UIImageView *fieldHighlight;
            if(currentSide == PLAYER_SIDE)
                fieldHighlight =  playerFieldHighlight;
            else
                fieldHighlight = opponentFieldHighlight;
            
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
    //field card drags a line for targetting
    else if (gameControlState == gameControlStateDraggingFieldCard)
    {
        CGPoint p1 = currentCard.cardView.center;
        CGPoint p2 = [touch locationInView:self.view];
        
        //TODO: temporary attack line, just a label with red background (red rect)
        attackLine.center = CGPointAdd(p1, CGPointDivideScalar((CGPointSubtract(p2, p1)), 2));
        int length = (int)CGPointDistance(p1, p2);
        attackLine.bounds = CGRectMake(0,-10,(int)(length*1),10);
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
    [self animateCardDamage:targetCard.cardView forDamage:[damages[0] integerValue] fromSide:oppositeSide];
    
    //animate damage to attacker if defender dealt damage
    if (damages[1] > 0)
        [self animateCardDamage:card.cardView forDamage:[damages[1] integerValue] fromSide:side];
    
    //update views after the attack
    [card.cardView updateView];
    [targetCard.cardView updateView];
    
    if (side == PLAYER_SIDE)
    {
        gameControlState = gameControlStateNone;
        currentCard.cardView.cardViewState = cardViewStateNone;
        currentCard = nil;
    }
    [self updateBattlefieldView:currentSide];

}

-(void) attackHero: (CardModel*) card target:(MonsterCardModel*)targetCard fromSide: (int) side
{
    int oppositeSide = currentSide == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
    
    //deal the damage and return it to animate
    NSArray *damages = [self.gameModel attackCard:card fromSide:side target:targetCard];
    
    //animate the damage effects for defender, if card dies, death animation is played
    [self animateCardDamage:targetCard.cardView forDamage: [damages[0] integerValue] fromSide:oppositeSide];
    
    //animate damage to attacker if hero somehow dealt damage
    if (damages[1] > 0)
        [self animateCardDamage:card.cardView forDamage:[damages[1] integerValue] fromSide:side];
    
    //update views after the attack
    [card.cardView updateView];
    [targetCard.cardView updateView];
    
    
    if (side == PLAYER_SIDE)
    {
        gameControlState = gameControlStateNone;
        currentCard.cardView.cardViewState = cardViewStateNone;
        currentCard = nil;
    }
    [self updateBattlefieldView:currentSide];
    
    //check victory
    [self.gameModel checkForGameOver];
}


/** Since the opponent is not meant to be controlled, this method must only be called for the player side */
-(void) scaleDraggingCard: (CardView*) card atPoint: (CGPoint) point
{
    float scale = CARD_DRAGGING_SCALE;
    
    //Scales between two ends at a and b
    float a = SCREEN_HEIGHT - SCREEN_HEIGHT*FIELD_CENTER_Y_RATIO;
    float b = SCREEN_HEIGHT - CARD_HEIGHT * 1.5;
    
    if (point.y < a)
        scale = CARD_DEFAULT_SCALE;
    else if (point.y > b)
        scale = CARD_DRAGGING_SCALE;
    else
    {
        //slerp x from a to b, used as the scale
        float x = (currentCard.cardView.center.y-a)/(b-a);
        
        //use only [0,pi/2] of the function for a better effect
        scale =  (1 - cos(x*M_PI_2)) * (CARD_DRAGGING_SCALE-CARD_DEFAULT_SCALE) + CARD_DEFAULT_SCALE;
    }
    
    currentCard.cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
}

-(void)pickAbilityTarget: (Ability*) ability
{
    [self.currentAbilities addObject:ability];
    [self updateBattlefieldView:PLAYER_SIDE];
    
    //disable all other views as player must choose a target (no cancelling, for now at least..)
    [self.handsView setUserInteractionEnabled:NO];
    [self.uiView setUserInteractionEnabled:NO];
    [self.backgroundView setUserInteractionEnabled:NO];
}

-(void)summonCard: (CardModel*)card fromSide: (int)side
{
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

//apparently there's no built-in function for operations on points
//TODO move elsewhere

CGPoint CGPointAdd(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}

CGPoint CGPointSubtract(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x - p2.x, p1.y - p2.y);
}

CGPoint CGPointMultiplyScalar(CGPoint p1, float s)
{
    return CGPointMake(p1.x * s, p1.y * s);
}
CGPoint CGPointDivideScalar(CGPoint p1, float s)
{
    return CGPointMake(p1.x / s, p1.y / s);
}

/** returns the absolute distance between p1 and p2 */
float CGPointDistance(CGPoint p1, CGPoint p2)
{
    return abs(sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2)));
}

/** returns the angle in radians between p1 and p2 */
float CGPointAngle(CGPoint p1, CGPoint p2)
{
    return atan2(p2.y-p1.y, p2.x - p1.x);
}

@end
