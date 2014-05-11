//
//  ViewController.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "GameViewController.h"
#import "CardView.h"
#import "MonsterCardModel.h"

//TODO!!!!!!!!!!!!! put views into subviews (UI view, card view, background view)

@interface GameViewController ()

@end

@implementation GameViewController

@synthesize gameModel = _gameModel;

/** Screen dimension for convinience */
int SCREEN_WIDTH, SCREEN_HEIGHT;

/** current side's turn, i.e. current player */
int currentSide;

/** label for showing the current player */
UILabel *currentSideLabel;

/** TODO: temporary label for representing the attack line when targetting monsters */
UILabel *attackLine;

/** stores array of two label for showing the current player's resource */
NSArray *resourceLabels;

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
    
    currentSide = PLAYER_SIDE;//TODO not always player begins later
    currentSideLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 20, 150, 20)];
    currentSideLabel.text = @"Player's turn"; //TODO
    
    [self.view addSubview: currentSideLabel];
    
    attackLine = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0, 0)];
    attackLine.backgroundColor = [UIColor redColor];
    
    //TODO positions are temporary
    resourceLabels = @[[[UILabel alloc] initWithFrame: CGRectMake(SCREEN_WIDTH - 20, SCREEN_HEIGHT - 100, 50, 20)], [[UILabel alloc] initWithFrame: CGRectMake(SCREEN_WIDTH - 20,  40, 50, 20)]];
    [self.view addSubview:resourceLabels[PLAYER_SIDE]];
    [self.view addSubview:resourceLabels[OPPONENT_SIDE]];
    
    //variable setups TODO probably move elsewhere
    //card's size is determined based on screen width, assuming height>width TODO: NOT the case for ipad in landscape
    CARD_WIDTH = ((SCREEN_WIDTH / 5) * 0.9);
    CARD_HEIGHT = (CARD_WIDTH *  CARD_HEIGHT_RATIO / CARD_WIDTH_RATIO);
    
    CARD_FULL_WIDTH = CARD_WIDTH/CARD_DEFAULT_SCALE;
    CARD_FULL_HEIGHT = CARD_HEIGHT/CARD_DEFAULT_SCALE;
    
    self.gameModel = [[GameModel alloc] initWithViewController:(self)];
    
    //TODO end turn button gotta move to a function
    UIImage* endTurnImage = [UIImage imageNamed:@"end_turn_button_up.png"];
    UIButton* endTurnButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    endTurnButton.frame = CGRectMake(0, 0, 60, 60);
    //[button setTitle:@"test" forState:UIControlStateNormal];
    [endTurnButton setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
    [endTurnButton setBackgroundImage:endTurnImage forState:UIControlStateNormal];
    [endTurnButton addTarget:self action:@selector(endTurnButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    endTurnButton.center = CGPointMake(SCREEN_WIDTH - 40, SCREEN_HEIGHT - 40);
    [self.view addSubview: endTurnButton];
    
    //TODO player 1 begins with one extra resource (because starts first)
    PlayerModel *player = self.gameModel.players[currentSide];
    player.resource++;
    
    //add all cards onto screen
    [self updateHandsView: PLAYER_SIDE];
    [self updateHandsView: OPPONENT_SIDE];
    [self updateResourceView: PLAYER_SIDE];
    [self updateResourceView: OPPONENT_SIDE];
}

-(void) endTurnButtonPressed{
    
    
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
    
    //new turn effects to all cards (e.g. deduct cooldown)
    for (MonsterCardModel* monsterCard in self.gameModel.battlefield[currentSide])
    {
        [self.gameModel cardNewTurn:monsterCard];
        [monsterCard.cardView updateView];
    }
    
    //draws another card
    [self.gameModel drawCard:currentSide];
    [self updateHandsView:currentSide];
    
    //add a resource and update it
    PlayerModel *player = self.gameModel.players[currentSide];
    player.resource++;
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
        CardModel *card = hand[i];
        
        //if card has no view, create one
        if (card.cardView == nil)
        {
            CardView *cardView = [[CardView alloc] initWithModel:card];
            card.cardView = cardView;
            [self.view addSubview:card.cardView];
        }
        
        //positions the hand by laying them out from the center TODO no need to collapse when has enough space
        card.cardView.center = CGPointMake((i-handCenterIndex) * CARD_WIDTH/2 + ((hand.count+1)%2 * CARD_WIDTH/4) + SCREEN_WIDTH/2, height);
    }
}

-(void)updateBattlefieldView: (int)side
{
    NSArray *field = self.gameModel.battlefield[side];
    
    //TODO probably make the cards line up in a curve
    
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
        
        //if card has no view, create one
        if (card.cardView == nil)
        {
            CardView *cardView = [[CardView alloc] initWithModel:card];
            card.cardView = cardView;
            [self.view addSubview:card.cardView];
        }
        
        //positions the hand by laying them out from the center TODO no need to collapse when has enough space
        card.cardView.center = CGPointMake((i-battlefieldCenterIndex) * CARD_WIDTH + ((field.count+1)%2 * CARD_WIDTH/2) + SCREEN_WIDTH/2, height);
    }
    
}

/** update the corresponding resource label with the number of resource the player has */
-(void)updateResourceView: (int)side
{
    PlayerModel *player = self.gameModel.players[side];
    [resourceLabels[side] setText:[NSString stringWithFormat:@"%d", player.resource]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"began");
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
            cardView.previousViewIndex = [self.view.subviews indexOfObject:cardView];
            [self.view bringSubviewToFront:cardView];
            cardView.center = [touch locationInView: self.view];
            
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
                attackLine.center = [touch locationInView:self.view];
                [self.view addSubview:attackLine];
                [self.view bringSubviewToFront:attackLine];
            }
            
            break; //break even if cannot attack
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    //hand card follows drag
    if (gameControlState == gameControlStateDraggingHandCard)
    {
        currentCard.cardView.center = [touch locationInView: self.view];
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
    NSLog(@"cancelled");
    
    //TODO these are not the right stuff yet
    
    //dragging card from hand, reverts action
    if (gameControlState == gameControlStateDraggingHandCard)
    {
        currentCard.cardView.cardViewState = cardViewStateNone;
        gameControlState = gameControlStateNone;
        [currentCard.cardView removeFromSuperview];
        [self.view insertSubview:currentCard.cardView atIndex:currentCard.cardView.previousViewIndex];
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
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView: self.view];
    
    //when dragging hand card, card is deployed
    if (gameControlState == gameControlStateDraggingHandCard)
    {
        //if dragged into deployment rect TODO temp position
        if (currentPoint.y > SCREEN_HEIGHT/4 && currentPoint.y < SCREEN_HEIGHT - SCREEN_HEIGHT/4)
        {
            //attempts to summon card and see if is successful
            if ([self.gameModel summonCard: currentCard side: currentSide])
            {
                //summon successful, update views
                [self updateBattlefieldView:currentSide];
                [self updateResourceView: currentSide];
            }
        }
        
        //revert the states
        currentCard.cardView.cardViewState = cardViewStateNone;
        gameControlState = gameControlStateNone;
        
        //re-insert the card back at its original index in the view
        [currentCard.cardView removeFromSuperview];
        [self.view insertSubview:currentCard.cardView atIndex:currentCard.cardView.previousViewIndex];
        
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
                [self.gameModel attackCard:currentCard fromSide:currentSide target:targetCard];
                
                //update views after the attack
                [currentCard.cardView updateView];
                [cardView updateView];
                
                //target died, update field view and remove it from screen
                if (targetCard.dead)
                {
                    [targetCard.cardView removeFromSuperview];
                    [self updateBattlefieldView:oppositeSide];
                }
                
                break;
            }
        }
        
        //remove the attack line form view and revert states
        [attackLine removeFromSuperview];
        gameControlState = gameControlStateNone;
        currentCard.cardView.cardViewState = cardViewStateNone;
        currentCard = nil;
    }
    
    
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
