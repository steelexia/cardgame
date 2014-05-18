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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
    gameControlState = gameControlStateNone;
    
    //variable setups TODO probably move elsewhere
    //card's size is determined based on screen width, assuming height>width TODO: NOT the case for ipad in landscape
    CARD_WIDTH = ((SCREEN_WIDTH / 5) * 0.9);
    CARD_HEIGHT = (CARD_WIDTH *  CARD_HEIGHT_RATIO / CARD_WIDTH_RATIO);
    
    CARD_FULL_WIDTH = CARD_WIDTH/CARD_DEFAULT_SCALE;
    CARD_FULL_HEIGHT = CARD_HEIGHT/CARD_DEFAULT_SCALE;
    
    currentSide = PLAYER_SIDE; //TODO not always player begins later
    
    //inits the game model storing the game's data
    self.gameModel = [[GameModel alloc] initWithViewController:(self)];
    
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
    resourceLabels = @[[[UILabel alloc] initWithFrame: CGRectMake(SCREEN_WIDTH - 30, SCREEN_HEIGHT - 100, 50, 20)], [[UILabel alloc] initWithFrame: CGRectMake(SCREEN_WIDTH - 30,  40, 50, 20)]];
    [self.uiView addSubview:resourceLabels[PLAYER_SIDE]];
    [self.uiView addSubview:resourceLabels[OPPONENT_SIDE]];
    
    //----set up the field highlights----//
    playerFieldHighlight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_highlight"]];
    opponentFieldHighlight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_highlight"]];
    
    playerFieldEdge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_edge"]];
    opponentFieldEdge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"field_edge"]];
    
    playerFieldHighlight.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - SCREEN_HEIGHT * FIELD_CENTER_Y_RATIO) ;
    playerFieldHighlight.bounds = CGRectMake(0,0,(CARD_WIDTH * 5)  + CARD_HEIGHT * 0.1, CARD_HEIGHT + CARD_HEIGHT * 0.1);
    
    playerFieldEdge.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - SCREEN_HEIGHT * FIELD_CENTER_Y_RATIO) ;
    playerFieldEdge.bounds = CGRectMake(0,0,(CARD_WIDTH * 5)  + CARD_HEIGHT * 0.1, CARD_HEIGHT + CARD_HEIGHT * 0.1);
    
    playerFieldHighlight.alpha = 0;
    
    [self.backgroundView addSubview:playerFieldHighlight];
    [self.backgroundView addSubview:playerFieldEdge];
    
    opponentFieldHighlight.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT * FIELD_CENTER_Y_RATIO) ;
    opponentFieldHighlight.bounds = CGRectMake(0,0,(CARD_WIDTH * 5)  + CARD_HEIGHT * 0.1, CARD_HEIGHT + CARD_HEIGHT * 0.1);
    
    opponentFieldEdge.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT * FIELD_CENTER_Y_RATIO) ;
    opponentFieldEdge.bounds = CGRectMake(0,0,(CARD_WIDTH * 5)  + CARD_HEIGHT * 0.1, CARD_HEIGHT + CARD_HEIGHT * 0.1);
    
    opponentFieldHighlight.alpha = 0;
    
    [self.backgroundView addSubview:opponentFieldHighlight];
    [self.backgroundView addSubview:opponentFieldEdge];
    
    //----end turn button----//
    UIImage* endTurnImage = [UIImage imageNamed:@"end_turn_button_up.png"];
    UIButton* endTurnButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    endTurnButton.frame = CGRectMake(0, 0, 60, 60);
    //[button setTitle:@"test" forState:UIControlStateNormal];
    [endTurnButton setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
    [endTurnButton setBackgroundImage:endTurnImage forState:UIControlStateNormal];
    [endTurnButton addTarget:self action:@selector(endTurnButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    endTurnButton.center = CGPointMake(SCREEN_WIDTH - 40, SCREEN_HEIGHT - 40);
    [self.uiView addSubview: endTurnButton];
}

-(void) endTurnButtonPressed{
    //tell the gameModel to end turn
    [self.gameModel endTurn: currentSide];
    
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
    
    //tell the gameModel a new turn has started
    [self.gameModel newTurn: currentSide];
    
    //update views after the turn end
    [self updateHandsView:currentSide];
    [self updateResourceView: currentSide];
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
        CGPoint newCenter = CGPointMake((i-handCenterIndex+0.5) * CARD_WIDTH/2 + ((hand.count+1)%2 * CARD_WIDTH/4) + SCREEN_WIDTH/2, height + abs(distanceFromCenter) * 3);
        
        //if card has no view, create one
        if (card.cardView == nil)
        {
            CardView *cardView = [[CardView alloc] initWithModel:card];
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
        card.cardView.transform = CGAffineTransformConcat(card.cardView.transform, CGAffineTransformMakeRotation(M_PI_4/8 * distanceFromCenter));
        
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
        height = SCREEN_HEIGHT/2 + CARD_HEIGHT/3*2;
    else if (side == OPPONENT_SIDE)
        height = SCREEN_HEIGHT/2 - CARD_HEIGHT/3*2;
    
    //iterate through all player's hand's cards and set their views correctly
    for (int i = 0; i < field.count; i++)
    {
        CardModel *card = field[i];
        
        //positions the hand by laying them out from the center
        CGPoint newCenter = CGPointMake((i-battlefieldCenterIndex) * CARD_WIDTH + ((field.count+1)%2 * CARD_WIDTH/2) + SCREEN_WIDTH/2, height);
        
        //if card has no view, create one
        if (card.cardView == nil)
        {
            CardView *cardView = [[CardView alloc] initWithModel:card];
            card.cardView = cardView;
            [self.fieldView addSubview:card.cardView];
            
            card.cardView.center = newCenter; //TODO
        }
        else
        {
            //slerp to the position
            [self animateMoveToWithBounce:card.cardView toPosition:newCenter inDuration:0.25];
        }
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
    
    //touched a hands card
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
    for (CardModel *card in self.gameModel.battlefield[currentSide])
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
        //above certain height is dragging card to field
        //if (currentPoint.y < SCREEN_HEIGHT-CARD_HEIGHT/2)
        //{
        currentCard.cardView.center = currentPoint;
        
        //TODO remove this if once game no longer allows controlling both players
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
                [self fadeIn:fieldHighlight inDuration:0.2];
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
            [self.gameModel summonCard: currentCard side: currentSide];
            
            //summon successful, update views
            [self updateBattlefieldView: currentSide];
            [self updateResourceView: currentSide];
            
            currentCard.cardView.cardViewState = cardViewStateNone;
            gameControlState = gameControlStateNone;
            
            [self fadeOut:playerFieldHighlight inDuration:0.2];
            [self fadeOut:opponentFieldHighlight inDuration:0.2];
            
        }
        else
        {
            //revert the states
            currentCard.cardView.cardViewState = cardViewStateNone;
            gameControlState = gameControlStateNone;
            
            //re-insert the card back at its original index in the view
            [currentCard.cardView removeFromSuperview];
            [self.handsView insertSubview:currentCard.cardView atIndex:currentCard.cardView.previousViewIndex];
        }
        
        currentCard = nil;
        
        //update hand's view at the end
        [self updateHandsView:currentSide];
    }
    //when dragging field card, attacks target the touch is on top of
    else if (gameControlState == gameControlStateDraggingFieldCard)
    {
        int oppositeSide = currentSide == PLAYER_SIDE ? OPPONENT_SIDE : PLAYER_SIDE;
        
        //targetted an enemy monster card
        for (CardModel *card in self.gameModel.battlefield[oppositeSide])
        {
            CardView *cardView = card.cardView;
            
            //convert touch point to point relative to the card
            CGPoint relativePoint = [cardView convertPoint:currentPoint fromView:self.view];
            
            //found enemy card
            if (CGRectContainsPoint(cardView.bounds, relativePoint))
            {
                //attack it
                MonsterCardModel* targetCard = (MonsterCardModel*) cardView.cardModel;
                
                //deal the damage and return it to animate
                int damage = [self.gameModel attackCard:currentCard fromSide:currentSide target:targetCard];

                //animate the damage effects, if card dies, death animation is played
                [self animateCardDamage:card.cardView forDamage:damage fromSide:oppositeSide];
                
                //update views after the attack
                [currentCard.cardView updateView];
                [cardView updateView];
                break;
            }
        }
        
        //remove the attack line from view and revert states
        [attackLine removeFromSuperview];
        gameControlState = gameControlStateNone;
        currentCard.cardView.cardViewState = cardViewStateNone;
        currentCard = nil;
    }
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
