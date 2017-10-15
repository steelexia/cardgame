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
#import "GameModel.h"
#import "CFLabel.h"
#import "CFButton.h"
#import "StrokedLabel.h"
#import "CardView.h"

@implementation GameViewController (Tutorial)

BOOL tutorialAbilityDone;

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
        self.tutLabel.label.text = @"CardForge is a card battle game where two heroes take turns playing cards to defeat each other.";
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
        
        NSArray*completedLevels = userPF[@"completedLevels"];
        if (![completedLevels containsObject:self.level.levelID] && userPF[@"cardOneID"] == nil)
            [self.tutOkButton addTarget:self action:@selector(openCardEditorTutorialTwo) forControlEvents:UIControlEventTouchUpInside];
        else
        {
            [self.tutOkButton addTarget:self action:@selector(tutorialTwoRetry) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else if ([TUTORIAL_THREE isEqualToString:self.level.levelID])
    {
        [self setAllViews:NO];
        
        self.tutLabel = [[CFLabel alloc] initWithFrame:CGRectMake(0,0,260,200)];
        [self.tutLabel setIsDialog:YES];
        self.tutLabel.label.text = @"Before we begin, let's forge your second card.";
        [self.tutLabel.label setTextAlignment:NSTextAlignmentCenter];
        [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
        [self.view addSubview:self.tutLabel];
        
        [self.view addSubview:self.tutOkButton];
        
        NSArray*completedLevels = userPF[@"completedLevels"];
        
        //NOTE: hardcoded the string because lvl 3 actually is never "completed"
        if (![completedLevels containsObject:@"d_1_c_1_l_4"] && userPF[@"cardTwoID"] == nil)
                [self.tutOkButton addTarget:self action:@selector(openCardEditorTutorialThree) forControlEvents:UIControlEventTouchUpInside];
        else
            [self.tutOkButton addTarget:self action:@selector(tutorialThreeRetry) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([TUTORIAL_FOUR isEqualToString:self.level.levelID])
    {
        [self setAllViews:NO];
        
        self.tutLabel = [[CFLabel alloc] initWithFrame:CGRectMake(0,0,260,200)];
        [self.tutLabel setIsDialog:YES];
        self.tutLabel.label.text = @"The last level of every chapter always includes a boss battle. During boss battles, your opponent's hero is a powerful heroic creature that is immune to abilities that target regular creatures.";
        [self.tutLabel.label setTextAlignment:NSTextAlignmentCenter];
        [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT*3/4)];
        [self.view addSubview:self.tutLabel];
        [self.view addSubview:self.tutOkButton];
        
        [self.tutOkButton addTarget:self action:@selector(tutorialBoss) forControlEvents:UIControlEventTouchUpInside];
        
        CardModel *cardOne;
        if (userPF[@"cardOneID"] != nil)
        {
            int cardOneID = [userPF[@"cardOneID"] intValue];
            
            for (CardModel *card in userAllCards)
            {
                if (card.idNumber == cardOneID)
                {
                    cardOne = [[CardModel alloc] initWithCardModel:card];
                    break;
                }
            }
        }
            //this only happens if there was an error uploading the cardOneID earlier. In this case, grab the first card the user owns. NOTE that this will always end up as a duplicate from the starting hand..
        if (cardOne == nil)
            if (userAllCards.count > 0)
                cardOne = [[CardModel alloc] initWithCardModel:userAllCards[0]];
        
        
        CardModel *cardTwo;
        if (userPF[@"cardTwoID"] != nil)
        {
            int cardTwoID = [userPF[@"cardTwoID"] intValue];
            
            for (CardModel *card in userAllCards)
            {
                if (card.idNumber == cardTwoID)
                {
                    cardTwo = [[CardModel alloc] initWithCardModel:card];
                    break;
                }
            }
        }
            //this only happens if there was an error uploading the cardOneID earlier. In this case, grab the first card the user owns
        if (cardTwo == nil)
            if (userAllCards.count > 1)
                cardTwo = [[CardModel alloc] initWithCardModel:userAllCards[1]];
        
        DeckModel *playerDeck = self.gameModel.decks[PLAYER_SIDE];
        
        if (cardTwo != nil)
            [playerDeck insertCard:cardTwo atIndex:0];
        if (cardOne != nil)
            [playerDeck insertCard:cardOne atIndex:0];
        
        [self.gameModel startGame];
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
        userPF[@"cardOneID"] = self.cevc.currentCardModel.cardPF[@"idNumber"];
        [userPF saveInBackground]; //if this failed, not too big of a deal. next time will just search for first owned card
        
        CardModel *customCard = [[CardModel alloc] initWithCardModel:self.cevc.currentCardModel];
        DeckModel *playerDeck = self.gameModel.decks[PLAYER_SIDE];
        [playerDeck insertCard:customCard atIndex:0];
        
        //destroy the cevc to save space
        self.cevc = nil;
        
        [self.gameModel startGame];
        
        [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/3)];
        [self.view addSubview:self.tutLabel];
        
        [self tutorialHand];
    }
    else if ([TUTORIAL_THREE isEqualToString:self.level.levelID])
    {
        userPF[@"cardTwoID"] = self.cevc.currentCardModel.cardPF[@"idNumber"];
        [userPF saveInBackground]; //if this failed, not too big of a deal. next time will just search for first owned card
        
        CardModel *customCard = [[CardModel alloc] initWithCardModel:self.cevc.currentCardModel];
        DeckModel *playerDeck = self.gameModel.decks[PLAYER_SIDE];
        [playerDeck insertCard:customCard atIndex:0];
        
        //get card one
        CardModel *cardOne;
        if (userPF[@"cardOneID"] != nil)
        {
            int cardOneID = [userPF[@"cardOneID"] intValue];
            
            for (CardModel *card in userAllCards)
            {
                if (card.idNumber == cardOneID)
                {
                    cardOne = [[CardModel alloc] initWithCardModel:card];
                    break;
                }
            }
        }
            //this only happens if there was an error uploading the cardOneID earlier. In this case, grab the first card the user owns
        if (cardOne == nil)
            if (userAllCards.count > 0)
                cardOne = [[CardModel alloc] initWithCardModel:userAllCards[0]];
        
        [playerDeck insertCard:cardOne atIndex:0];
        
        //destroy the cevc to save space
        self.cevc = nil;
        
        [self.gameModel startGame];
        
        [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/3)];
        [self.view addSubview:self.tutLabel];
        
        [self tutorialThreeBegin];
    }
}

-(void)summonedCardTutorial:(CardModel*)card fromSide:(int)side
{
    if ([TUTORIAL_ONE isEqualToString:self.level.levelID])
    {
        if (side == PLAYER_SIDE && self.gameModel.turnNumber == 0)
        {
            [self tutorialCooldown];
        }
        //spearman
        else if (side == OPPONENT_SIDE && card.idNumber == 1002)
        {
            if (!tutorialAbilityDone)
            {
                [self tutorialAbilitiy];
                tutorialAbilityDone = YES;
            }
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
    if ([TUTORIAL_TWO isEqualToString:self.level.levelID])
    {
        if (self.gameModel.turnNumber == 2)
        {
            [self tutorialSpell];
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
    self.tutLabel.label.text = @"To summon the card you forged, drag it up to the battlefield, marked by the yellow box.";
    //[self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    //[self.tutOkButton addTarget:self action:@selector(tutorialCooldown) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tutorialCooldown
{
    [self setAllViews:NO];
    [self modalScreen];
    [self.view bringSubviewToFront:self.tutOkButton];
    [self.tutLabel setIsDialog:YES];
    self.tutLabel.label.text = @"All creatures' cooldowns decrease by 1 at the start of every turn, and they can attack once it reaches 0.";
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
    
    self.tutLabel.label.text = @"You can now order it to attack by dragging it across to your opponent's creature or your opponent's hero.";
    
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
    
    self.tutLabel.label.text = @"Each creature has a Damage and Life value. It dies when its life reaches 0.\nBoth creatures take damage when attacking each other.";
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
    self.tutLabel.label.text = @"Summoning a card costs resources indicated by the blue icon on the top left corner of the card.\nYour resources, shown at the bottom right, refill and increase by one every turn.";
    
    self.arrowImage.image = ARROW_RIGHT_ICON_IMAGE;
    self.arrowImage.center = CGPointMake(SCREEN_WIDTH - 90, SCREEN_HEIGHT - 30);
    [self fadeIn:self.arrowImage inDuration:0.2];
    
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
    self.tutLabel.label.text = @"The icons appearing at the bottom of the card serve as reminders for these abilities. You can also tap the card or drag it into the help box at the bottom left corner to view them.";
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(tutorialOneWin) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tutorialOneWin
{
    self.tutLabel.label.text = @"Now, defeat your opponent!";
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(removeAllTutorialViews) forControlEvents:UIControlEventTouchUpInside];
}

//-----------tutorial two---------------//

//this happens if the player fails the tutorial, or decides to play again later. They do not get to create another card.
-(void)tutorialTwoRetry
{
    CardModel *cardOne;
    if (userPF[@"cardOneID"] != nil)
    {
        int cardOneID = [userPF[@"cardOneID"] intValue];
        
        for (CardModel *card in userAllCards)
        {
            if (card.idNumber == cardOneID)
            {
                cardOne = [[CardModel alloc] initWithCardModel:card];
                break;
            }
        }
    }
        //this only happens if there was an error uploading the cardOneID earlier. In this case, grab the first card the user owns
    if (cardOne == nil)
        if (userAllCards.count > 0)
        {
            cardOne = [[CardModel alloc] initWithCardModel:userAllCards[0]];
        }
    
    if (cardOne != nil) //should never be nil, but if really happened then player don't get the card
    {
        DeckModel *playerDeck = self.gameModel.decks[PLAYER_SIDE];
        [playerDeck insertCard:cardOne atIndex:0];
    }
    
    [self.gameModel startGame];
    
    [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/3)];
    [self.view addSubview:self.tutLabel];
    
    [self tutorialHand];
}

-(void)openCardEditorTutorialTwo
{
    self.arrowImage.alpha = 0;
    self.cevc = [[CardEditorViewController alloc] initWithMode:cardEditorModeTutorialTwo WithCard:nil];
    [self presentViewController:self.cevc animated:YES completion:nil];
}

-(void)tutorialHand
{
    [self removeAllTutorialViews];
    
    //TODO probably say something else
    /*
    [self setAllViews:NO];
    [self modalScreen];
    
    [self.view addSubview:self.tutOkButton];
    
    self.tutLabel.label.text = @"When you have several cards in your hand, it can be easier to view the cards by dragging horizontally.";
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(removeAllTutorialViews) forControlEvents:UIControlEventTouchUpInside];
     */
}

-(void)tutorialSpell
{
    [self setAllViews:NO];
    [self modalScreen];
    
    self.tutLabel.label.text = @"Other than creature cards, spell cards are single-use cards that have an effect when casted.";
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(tutorialCastSpell) forControlEvents:UIControlEventTouchUpInside];
    
    self.arrowImage.image = ARROW_RIGHT_ICON_IMAGE;
    [self.view addSubview:self.arrowImage];
    self.arrowImage.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 50);
    [self fadeIn:self.arrowImage inDuration:0.2];
    
    [self.view addSubview:self.tutLabel];
    [self.view addSubview:self.tutOkButton];
    [self fadeIn:self.tutLabel inDuration:0.2];
    [self fadeIn:self.tutOkButton inDuration:0.2];
}

-(void)tutorialCastSpell
{
    self.tutLabel.label.text = @"To cast a spell, drag it onto the battlefield just like when summoning a creature. If the spell requires picking a target, tap the target you chose.";
    
    [self fadeOut:self.arrowImage inDuration:0.2];
    
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(removeAllTutorialViews) forControlEvents:UIControlEventTouchUpInside];
}

//-----------tutorial three---------------//

-(void)openCardEditorTutorialThree
{
    self.arrowImage.alpha = 0;
    self.cevc = [[CardEditorViewController alloc] initWithMode:cardEditorModeTutorialThree WithCard:nil];
    [self presentViewController:self.cevc animated:YES completion:nil];
}

-(void)tutorialThreeRetry
{
    CardModel *cardOne;
    if (userPF[@"cardOneID"] != nil)
    {
        int cardOneID = [userPF[@"cardOneID"] intValue];
        
        for (CardModel *card in userAllCards)
        {
            if (card.idNumber == cardOneID)
            {
                cardOne = [[CardModel alloc] initWithCardModel:card];
                break;
            }
        }
    }
        //this only happens if there was an error uploading the cardOneID earlier. In this case, grab the first card the user owns
    if (cardOne == nil)
        if (userAllCards.count > 0)
        {
            cardOne = [[CardModel alloc] initWithCardModel:userAllCards[0]];
        }
    
    CardModel *cardTwo;
    if (userPF[@"cardTwoID"] != nil)
    {
        int cardTwoID = [userPF[@"cardTwoID"] intValue];
        
        for (CardModel *card in userAllCards)
        {
            if (card.idNumber == cardTwoID)
            {
                cardTwo = [[CardModel alloc] initWithCardModel:card];
                break;
            }
        }
    }
        //this only happens if there was an error uploading the cardOneID earlier. In this case, grab the first card the user owns
    if (cardTwo == nil)
        if (userAllCards.count > 1)
        {
            cardTwo = [[CardModel alloc] initWithCardModel:userAllCards[1]];
        }
    
    DeckModel *playerDeck = self.gameModel.decks[PLAYER_SIDE];
    
    if (cardTwo != nil)
        [playerDeck insertCard:cardTwo atIndex:0];
    if (cardOne != nil)
        [playerDeck insertCard:cardOne atIndex:0];
    
    [self.gameModel startGame];
    
    [self setLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/3)];
    [self.view addSubview:self.tutLabel];
    
    [self tutorialThreeBegin];
}

-(void)tutorialThreeBegin
{
    [self setAllViews:NO];
    [self modalScreen];
    
    [self.view addSubview:self.tutOkButton];
    
    self.tutLabel.label.text = @"Now, defeat your opponent!";
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(removeAllTutorialViews) forControlEvents:UIControlEventTouchUpInside];
}

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
                         //[self.arrowImage removeFromSuperview];
                     }];
       
}

@end
