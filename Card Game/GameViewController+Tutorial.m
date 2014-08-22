//
//  GameViewController+Tutorial.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-19.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "GameViewController+Tutorial.h"
#import "GameViewController+Animation.h"
#import "Campaign.h"
#import "UIConstants.h"
#import "CardEditorViewController.h"
#import "UserModel.h"

@implementation GameViewController (Tutorial)


/** Screen dimension for convinience */
int SCREEN_WIDTH, SCREEN_HEIGHT;

-(void)tutorialSetup
{
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
    self.tutOkButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    self.tutOkButton.label.text = @"Ok";
    self.tutOkButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 60);
    
    self.arrowImage = [[UIImageView alloc] initWithImage:ARROW_LEFT_ICON_IMAGE];
    self.arrowImage.frame = CGRectMake(0,0,80,80);
    self.arrowImage.alpha = 0;
}

-(void)tutorialMessageGameStart
{
    if ([TUTORIAL_ONE isEqualToString:self.level.levelID])
    {
        [self setAllViews:NO];
        
        self.tutLabel = [[CFLabel alloc] initWithFrame:CGRectMake(0,0,260,200)];
        [self.tutLabel setIsDialog:YES];
        self.tutLabel.label.text = @"CardForge is a card battle game where two opponents take turns in playing cards to defeat each other.";
        [self.tutLabel.label setTextAlignment:NSTextAlignmentCenter];
        [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
        [self.view addSubview:self.tutLabel];
        [self.view addSubview:self.tutOkButton];
        [self.view addSubview:self.arrowImage];
        
        [self.tutOkButton addTarget:self action:@selector(tutorialHowToWin) forControlEvents:UIControlEventTouchUpInside];
        
        [self.endTurnButton setUserInteractionEnabled:NO];
    }
    else if ([TUTORIAL_TWO isEqualToString:self.level.levelID])
    {
        [self setAllViews:NO];
        
        self.tutLabel = [[CFLabel alloc] initWithFrame:CGRectMake(0,0,260,200)];
        [self.tutLabel setIsDialog:YES];
        self.tutLabel.label.text = @"Before starting this battle, let's publish the card you forged first.";
        [self.tutLabel.label setTextAlignment:NSTextAlignmentCenter];
        [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
        [self.view addSubview:self.tutLabel];
        
        [self.view addSubview:self.tutOkButton];
        
        [self.tutOkButton addTarget:self action:@selector(openCardEditorTutorialTwo) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([TUTORIAL_THREE isEqualToString:self.level.levelID])
    {
        [self setAllViews:NO];
        
        self.tutLabel = [[CFLabel alloc] initWithFrame:CGRectMake(0,0,260,200)];
        [self.tutLabel setIsDialog:YES];
        self.tutLabel.label.text = @"Defeat your opponent!";
        [self.tutLabel.label setTextAlignment:NSTextAlignmentCenter];
        [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
        [self.view addSubview:self.tutLabel];
        
        [self.view addSubview:self.tutOkButton];
        
        [self.tutOkButton addTarget:self action:@selector(removeAllTutorialViews) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([TUTORIAL_FOUR isEqualToString:self.level.levelID])
    {
        [self setAllViews:NO];
        
        self.tutLabel = [[CFLabel alloc] initWithFrame:CGRectMake(0,0,260,200)];
        [self.tutLabel setIsDialog:YES];
        self.tutLabel.label.text = @"The last level of every chapter always includes a boss battle. During boss battles, your opponent hero is a powerful heroic creature that is immune to abilities that target regular creatures.";
        [self.tutLabel.label setTextAlignment:NSTextAlignmentCenter];
        [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT*3/4)];
        [self.view addSubview:self.tutLabel];
        
        [self.view addSubview:self.tutOkButton];
        
        [self.tutOkButton addTarget:self action:@selector(tutorialBoss) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)returnedFromCardEditorTutorial
{
    if ([TUTORIAL_ONE isEqualToString:self.level.levelID])
    {
        CardModel*customCard = self.cevc.currentCardModel;
        PLAYER_FIRST_CARD_IMAGE = customCard.cardView.cardImage.image; //save the image
        userTutorialOneCardName = customCard.name;
        customCard.idNumber = PLAYER_FIRST_CARD_ID;
        customCard.type = cardTypeSinglePlayer;
        customCard.cardView = nil; //delete the original card view from cevc
        DeckModel *playerDeck = self.gameModel.decks[PLAYER_SIDE];
        [playerDeck insertCard:customCard atIndex:0];
        
        //destroy the cevc to save space
        self.cevc = nil;
        
        [self.gameModel startGame];
        
        [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/3)];
        [self.view addSubview:self.tutLabel];
        
        [self tutorialHowToPlayCards];
    }
    else if ([TUTORIAL_TWO isEqualToString:self.level.levelID])
    {
        //still uses a fake local copy rather than online copy just to be lazy
        CardModel*customCard = self.cevc.currentCardModel;
        PLAYER_FIRST_CARD_IMAGE = customCard.cardView.cardImage.image; //save the image
        userTutorialOneCardName = customCard.name;
        customCard.idNumber = PLAYER_FIRST_CARD_ID;
        customCard.type = cardTypeSinglePlayer;
        customCard.cardView = nil; //delete the original card view from cevc
        DeckModel *playerDeck = self.gameModel.decks[PLAYER_SIDE];
        [playerDeck insertCard:customCard atIndex:0];
        
        //destroy the cevc to save space
        self.cevc = nil;
        
        [self.gameModel startGame];
        
        [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/3)];
        [self.view addSubview:self.tutLabel];
        
        [self tutorialHowToPlayCards];
    }
}

-(void)summonedCardTutorial:(CardModel*)card fromSide:(int)side
{
    if ([TUTORIAL_ONE isEqualToString:self.level.levelID])
    {
        if (side == PLAYER_SIDE && card.idNumber == PLAYER_FIRST_CARD_ID)
        {
            [self tutorialCooldown];
        }
        //spearman
        else if (side == OPPONENT_SIDE && card.idNumber == 1002)
        {
            [self tutorialAbilitiy];
        }
    }
}

-(void)endTurnTutorial
{
    if ([TUTORIAL_ONE isEqualToString:self.level.levelID])
    {
        if (self.gameModel.turnNumber == 1)
        {
            [self fadeOut:self.tutLabel inDuration:0.2];
        }
        else if (self.gameModel.turnNumber == 2)
        {
            [self tutorialAttack];
        }
    }
}

-(void)cardAttacksTutorial
{
    if ([TUTORIAL_ONE isEqualToString:self.level.levelID])
    {
        if (self.gameModel.turnNumber == 2)
        {
            [self tutorialStats];
        }
    }
}

-(void)setLabelCenter:(CGPoint) center
{
    self.tutLabel.center = center;
    self.tutOkButton.center = CGPointMake(center.x, center.y + self.tutLabel.bounds.size.height/2 - 40);
}

//-----------tutorial one---------------//

-(void)tutorialHowToWin
{
    self.tutLabel.label.text = @"To win, you must reduce your opponent's hero to 0 life.";
    UIView*enemyHeroView = self.playerHeroViews[OPPONENT_SIDE];
    self.arrowImage.center = CGPointMake(enemyHeroView.frame.origin.x + enemyHeroView.frame.size.width + 50, enemyHeroView.frame.origin.y + enemyHeroView.frame.size.height/2);
    //self.arrowImage.center = CGPointMake(SCREEN_WIDTH/2, 60);
    [self fadeIn:self.arrowImage inDuration:0.2];
    
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(tutorialHowToLose) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tutorialHowToLose
{
    self.tutLabel.label.text = @"On the other side, you will lose if your own hero's life is reduced to 0.";
    
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(tutorialCraftFirstCard) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.arrowImage.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         UIView*playerHeroView = self.playerHeroViews[PLAYER_SIDE];
                         self.arrowImage.center = CGPointMake(playerHeroView.frame.origin.x + playerHeroView.frame.size.width + 50, playerHeroView.frame.origin.y + playerHeroView.frame.size.height/2);
                         
                         [self fadeIn:self.arrowImage inDuration:0.2];
                     }];
}

-(void)tutorialCraftFirstCard
{
    [self setAllViews:YES];
    [self fadeOut:self.arrowImage inDuration:0.2];
    self.tutLabel.label.text = @"The most basic way to defeat your opponent is to play creature cards. As a Card Forger, it's time to forge your first card!";
    
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    //[self.tutOkButton addTarget:self action:@selector(removeAllTutorialViews) forControlEvents:UIControlEventTouchUpInside];
    [self.tutOkButton addTarget:self action:@selector(openCardEditorTutorialOne) forControlEvents:UIControlEventTouchUpInside];
    //[self.tutOkButton addTarget:self action:@selector(tutorialHowToPlayCards) forControlEvents:UIControlEventTouchUpInside];
}

-(void)openCardEditorTutorialOne
{
    self.arrowImage.alpha = 0;
    self.cevc = [[CardEditorViewController alloc] initWithMode:cardEditorModeTutorialOne WithCard:nil];
    [self presentViewController:self.cevc animated:YES completion:nil];
}

-(void)tutorialHowToPlayCards
{
    [self.endTurnButton setUserInteractionEnabled:NO];
    [self.tutLabel setIsDialog:NO];
    self.tutLabel.frame = CGRectMake(0,0,260,170);
    [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/4)]; //reset button position
    self.tutLabel.label.text = @"To summon the card you forged, drag it into the battlefield, marked by the yellow box.";
    //[self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    //[self.tutOkButton addTarget:self action:@selector(tutorialCooldown) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tutorialCooldown
{
    [self setAllViews:NO];
    [self modalScreen];
    [self.view bringSubviewToFront:self.tutOkButton];
    [self.tutLabel setIsDialog:YES];
    self.tutLabel.label.text = @"Creature cards all have cooldown, indicated by the number on the hourglass icon. Their cooldown decrease by 1 at the start of every turn, and they can attack once it reaches 0.";
    [self.view addSubview:self.tutOkButton];

    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(tutorialEndTurn) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tutorialEndTurn
{
    [self unmodalScreen];
    [self setAllViews:YES];
    [self.tutLabel setIsDialog:NO];
    [self.endTurnButton setUserInteractionEnabled:YES];
    self.tutLabel.label.text = @"Press the End Turn button to end your turn.";
    
    self.tutOkButton.alpha = 0;
}

-(void)tutorialAttack
{
    self.tutLabel.frame = CGRectMake(0,0,260,100);
    [self.endTurnButton setUserInteractionEnabled:NO];
    [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT*4/5)];
    
    self.tutLabel.label.text = @"Now that the cooldown is 0, you can order it to attack by dragging it across to your opponent's creature, or your opponent's hero.";
    
    [self fadeIn:self.tutLabel inDuration:0.2];
}

-(void)tutorialStats
{
    [self setAllViews:NO];
    [self modalScreen];
    [self.view bringSubviewToFront:self.tutOkButton];
    self.tutLabel.frame = CGRectMake(0,0,260,170);
    [self.tutLabel setIsDialog:YES];
    [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT*4/5)];
    
    self.tutLabel.label.text = @"Each creature has a Damage and Life value. It dies when its life reaches 0. Both creatures take damage when attacking each other.";
    self.tutOkButton.alpha = 1;

    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(tutorialResource) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tutorialResource
{
    [self setAllViews:NO];
    self.tutLabel.frame = CGRectMake(0,0,260,200);
    [self.tutLabel setIsDialog:YES];
    [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
    self.tutLabel.label.text = @"You can also summon the new card you have drawn this turn. Each card costs resources indicated by the blue icon on the top left corner of the card. Your resource, shown at the bottom right, refill and increase by one every turn.";
    
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(removeAllTutorialViews) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tutorialAbilitiy
{
    [self setAllViews:NO];
    [self modalScreen];
    
    self.tutLabel.alpha = 0;
    self.tutOkButton.alpha = 0;
    self.tutLabel.frame = CGRectMake(0,0,260,170);
    [self.tutLabel setIsDialog:YES];
    [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT*4/5)];
    
    self.tutLabel.label.text = @"Some creatures have abilities. For example, this creature's ability, Guardian, forces its opponent to attack it instead of its hero or other creatures.";
    
    [self.view addSubview:self.tutLabel];
    [self.view addSubview:self.tutOkButton];
    [self fadeIn:self.tutLabel inDuration:0.2];
    [self fadeIn:self.tutOkButton inDuration:0.2];
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(tutorialAbilitiyHint) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tutorialAbilitiyHint
{
    self.tutLabel.label.text = @"The icons appearing at the bottom of the card serve as reminders for these abilities. You can also tap the card or drag it into the help box at the bottom left corner to view its abilities.";
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(tutorialOneWin) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tutorialOneWin
{
    self.tutLabel.label.text = @"Now defeat your opponent!";
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(removeAllTutorialViews) forControlEvents:UIControlEventTouchUpInside];
}

//-----------tutorial two---------------//

-(void)openCardEditorTutorialTwo
{
    self.arrowImage.alpha = 0;
    self.cevc = [[CardEditorViewController alloc] initWithMode:cardEditorModeTutorialTwo WithCard:nil];
    [self presentViewController:self.cevc animated:YES completion:nil];
}

-(void)tutorialHand
{
    self.tutLabel.label.text = @"When you have several cards in your hand, it can be easier to view the cards by dragging horizontally.";
}

-(void)tutorialSpell
{
    self.tutLabel.label.text = @"Other than creature cards, spell cards are single-use cards that have an effect when casted.";
    //[self.tutOkButton addTarget:self action:@selector(tutorialHowToPlayCards) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tutorialCastSpell
{
    self.tutLabel.label.text = @"To cast a spell, drag it onto the battlefield just like when summoning a creature. If the spell allows picking the target, you can choose to abandon it, if you don't have a good target.";
    //[self.tutOkButton addTarget:self action:@selector(tutorialHowToPlayCards) forControlEvents:UIControlEventTouchUpInside];
}

//-----------tutorial three---------------//



//-----------tutorial four---------------//
-(void)tutorialBoss
{
    self.tutLabel.label.text = @"This is the last tutorial battle. Good luck!";
    [self.tutOkButton addTarget:self action:@selector(removeAllTutorialViews) forControlEvents:UIControlEventTouchUpInside];
}

-(void)removeAllTutorialViews
{
    [self unmodalScreen];
    [self setAllViews:YES];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.tutLabel.alpha = 0;
                         self.tutOkButton.alpha = 0;
                         self.arrowImage.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [self.tutLabel removeFromSuperview];
                         [self.tutOkButton removeFromSuperview];
                         [self.arrowImage removeFromSuperview];
                     }];
       
}

@end
