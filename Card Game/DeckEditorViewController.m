//
//  DeckEditorViewController.m
//  cardgame
//
//  Created by Macbook on 2014-06-21.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "DeckEditorViewController.h"
#import "DeckModel.h"
#import "CardView.h"
#import "CardModel.h"
#import "SinglePlayerCards.h"
#import "UserModel.h"
#import "MainScreenViewController.h"

@interface DeckEditorViewController ()

@end


@implementation DeckEditorViewController
@synthesize cardsView = _cardsView;
@synthesize deckView = _deckView;

//double CARD_VIEWER_SCALE = 0.8;
/** Screen dimension for convinience */
int SCREEN_WIDTH, SCREEN_HEIGHT;

/** UILabel used to darken the screen during card selections */
UILabel *darkFilter;

/** Currently maximized card */
CardView *currentCard;
/** Original view of the currently maximized card */
CardView *originalCurrentCard;
/** Index of currentCard in the collection */
int currentIndex = -1;

UIButton *addCardToDeckButton, *removeCardFromDeckButton;

/** Shows the number of cards currently in the deck */
UILabel *deckCountLabel;

/** Label explaining why the card cannot be added */
UILabel *cannotAddCardReasonLabel;

/** Used to add another deck */
UIButton *addDeckButton;

/** Buttons for pressing the addDeckButton when the deck is invalid */
UIButton *autoAddCardsButton, *notAutoAddCardsButton, *autoAddCardsFailedButton;
UILabel *autoAddCardsLabel, *autoAddCardsFailedLabel;

/** Used to save and return to organizing decks*/
UIButton *saveDeckButton;

/** Add a new deck */
UIButton *addDeckButton;

/** Reminder to select a deck before being able to view their cards */
UILabel *emptyCardsLabel;

/** Returns to main menu */
UIButton *backButton;

/** The current deck being organized when deckView is in card mode if is nil, a new deck is being created. */
DeckModel* currentDeck;

UILabel *deleteDeckLabel;

/** For unmaximizing */
enum CardCollectinViewMode lastVCardCollectionViewMode;

DeckModel * allCards;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
    //get the single player deck TODO
    //allCards = userAllCards;
    allCards = [[DeckModel alloc] init];
    
    for (CardModel* card in userAllCards)
    {
        [allCards addCard:card]; //don't thnk it will ever be edited here so it should be safe, plus userAllCards is just a copy of Parse data anyways
    }
    
    //sort the cards
    [allCards.cards sortUsingComparator:^(CardModel* a, CardModel* b){
         return [a compare:b];
     }];
    
    //set up cards view
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.cardsView = [[CardsCollectionView alloc] initWithFrame:CGRectMake(0, 74, 230, 366) collectionViewLayout:layout];
    self.cardsView.parentViewController = self; //for callbacks
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.cardsView];
    
    [self.view setUserInteractionEnabled:YES];
    [self.cardsView setUserInteractionEnabled:YES];
    
    //set up deck view
    self.deckView = [[DeckTableView alloc] initWithFrame:CGRectMake(230,0,90,SCREEN_HEIGHT-40)];
    
    [self.view addSubview:self.deckView];
    [self.deckView setUserInteractionEnabled:YES];
    
    //set up UI
    darkFilter = [[UILabel alloc] initWithFrame:self.view.bounds];
    darkFilter.backgroundColor = [[UIColor alloc]initWithHue:0 saturation:0 brightness:0 alpha:0.8];
    [darkFilter setUserInteractionEnabled:YES]; //blocks all interaction behind it
    
    addCardToDeckButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    addCardToDeckButton.center = CGPointMake(SCREEN_WIDTH - 45, SCREEN_HEIGHT-85);
    [addCardToDeckButton setImage:[UIImage imageNamed:@"add_button"] forState:UIControlStateNormal];
    [addCardToDeckButton setImage:[UIImage imageNamed:@"add_button_gray"] forState:UIControlStateDisabled];
    [addCardToDeckButton addTarget:self action:@selector(addCardToDeckPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    removeCardFromDeckButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    removeCardFromDeckButton.center = CGPointMake(SCREEN_WIDTH - 50, SCREEN_HEIGHT-80);
    [removeCardFromDeckButton setImage:[UIImage imageNamed:@"remove_button"] forState:UIControlStateNormal];
    
    [removeCardFromDeckButton addTarget:self action:@selector(removeCardFromDeckPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //deck count label
    deckCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 115, SCREEN_HEIGHT - 42, 90, 40)];
    deckCountLabel.textAlignment = NSTextAlignmentCenter;
    deckCountLabel.textColor = [UIColor blackColor];
    deckCountLabel.backgroundColor = [UIColor clearColor];
    deckCountLabel.font = [UIFont fontWithName:cardMainFont size:16];
    [self.view addSubview:deckCountLabel];
    
    cannotAddCardReasonLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT - 120, 200, 120)];
    cannotAddCardReasonLabel.textColor = [UIColor redColor];
    cannotAddCardReasonLabel.backgroundColor = [UIColor clearColor];
    cannotAddCardReasonLabel.font = [UIFont fontWithName:cardMainFont size:14];
    cannotAddCardReasonLabel.textAlignment = NSTextAlignmentLeft;
    cannotAddCardReasonLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cannotAddCardReasonLabel.numberOfLines = 6;
    
    //save deck button
    saveDeckButton = [[UIButton alloc] initWithFrame:CGRectMake(4, SCREEN_HEIGHT-36, 46, 32)];
    [saveDeckButton setImage:[UIImage imageNamed:@"save_deck_button"] forState:UIControlStateNormal];
    [saveDeckButton addTarget:self action:@selector(saveDeckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:saveDeckButton];
    
    addDeckButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, SCREEN_HEIGHT-36, 46, 32)];
    [addDeckButton setImage:[UIImage imageNamed:@"add_deck_button"] forState:UIControlStateNormal];
    [addDeckButton addTarget:self action:@selector(addDeckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    backButton = [[UIButton alloc] initWithFrame:CGRectMake(4, SCREEN_HEIGHT-36, 46, 32)];
    [backButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    self.deleteDeckButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, SCREEN_HEIGHT-36, 46, 32)];
    [self.deleteDeckButton setImage:[UIImage imageNamed:@"remove_deck_button"] forState:UIControlStateNormal];
    [self.deleteDeckButton addTarget:self action:@selector(deleteButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //save deck dialog
    autoAddCardsLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT)];
    autoAddCardsLabel.textColor = [UIColor whiteColor];
    autoAddCardsLabel.backgroundColor = [UIColor clearColor];
    autoAddCardsLabel.font = [UIFont fontWithName:cardMainFont size:25];
    autoAddCardsLabel.textAlignment = NSTextAlignmentCenter;
    autoAddCardsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    autoAddCardsLabel.numberOfLines = 0;
    autoAddCardsLabel.text = @"You haven't added enough cards to fill up the deck. Would you like them to be added automatically? You will lose all your changes if you don't.";
    [autoAddCardsLabel sizeToFit];
    
    autoAddCardsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    autoAddCardsButton.center = CGPointMake(SCREEN_WIDTH/2 - 80, SCREEN_HEIGHT - 60);
    [autoAddCardsButton setImage:[UIImage imageNamed:@"yes_button"] forState:UIControlStateNormal];
    [autoAddCardsButton addTarget:self action:@selector(autoAddCardsButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    notAutoAddCardsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    notAutoAddCardsButton.center = CGPointMake(SCREEN_WIDTH/2 + 80, SCREEN_HEIGHT - 60);
    [notAutoAddCardsButton setImage:[UIImage imageNamed:@"no_button"] forState:UIControlStateNormal];
    [notAutoAddCardsButton addTarget:self action:@selector(notAutoAddCardsButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    autoAddCardsFailedLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT)];
    autoAddCardsFailedLabel.textColor = [UIColor whiteColor];
    autoAddCardsFailedLabel.backgroundColor = [UIColor clearColor];
    autoAddCardsFailedLabel.font = [UIFont fontWithName:cardMainFont size:25];
    autoAddCardsFailedLabel.textAlignment = NSTextAlignmentCenter;
    autoAddCardsFailedLabel.lineBreakMode = NSLineBreakByWordWrapping;
    autoAddCardsFailedLabel.numberOfLines = 0;
    autoAddCardsFailedLabel.text = @"Sorry, you don't have enough valid cards to fill up this deck. Please try again with different cards.";
    [autoAddCardsFailedLabel sizeToFit];
    
    autoAddCardsFailedButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    autoAddCardsFailedButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 60);
    [autoAddCardsFailedButton setImage:[UIImage imageNamed:@"ok_button"] forState:UIControlStateNormal];
    //[saveDeckButton addTarget:self action:@selector(saveDeckButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //delete deck dialog
    deleteDeckLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT/2)];
    deleteDeckLabel.textColor = [UIColor whiteColor];
    deleteDeckLabel.backgroundColor = [UIColor clearColor];
    deleteDeckLabel.font = [UIFont fontWithName:cardMainFont size:25];
    deleteDeckLabel.textAlignment = NSTextAlignmentCenter;
    deleteDeckLabel.lineBreakMode = NSLineBreakByWordWrapping;
    deleteDeckLabel.numberOfLines = 0;
    deleteDeckLabel.text = @"Are you sure you want to delete this deck?";
    [autoAddCardsLabel sizeToFit];
    
    self.deleteDeckConfirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    self.deleteDeckConfirmButton.center = CGPointMake(SCREEN_WIDTH/2 - 80, SCREEN_HEIGHT - 60);
    [self.deleteDeckConfirmButton setImage:[UIImage imageNamed:@"yes_button"] forState:UIControlStateNormal];
    [self.deleteDeckConfirmButton addTarget:self action:@selector(deleteDeckConfirmButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    self.deleteDeckCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    self.deleteDeckCancelButton.center = CGPointMake(SCREEN_WIDTH/2 + 80, SCREEN_HEIGHT - 60);
    [self.deleteDeckCancelButton setImage:[UIImage imageNamed:@"no_button"] forState:UIControlStateNormal];
    [self.deleteDeckCancelButton addTarget:self action:@selector(deleteDeckCancelButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    
    emptyCardsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.cardsView.frame.origin.x + 10, self.cardsView.frame.origin.y + self.cardsView.frame.size.height/2 - 40, self.cardsView.frame.size.width - 20, self.cardsView.frame.size.height)];
    emptyCardsLabel.textColor = [UIColor blackColor];
    emptyCardsLabel.backgroundColor = [UIColor clearColor];
    emptyCardsLabel.font = [UIFont fontWithName:cardMainFont size:20];
    emptyCardsLabel.textAlignment = NSTextAlignmentCenter;
    emptyCardsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    emptyCardsLabel.numberOfLines = 0;
    emptyCardsLabel.text = @"Select or create a deck to view your cards.";
    [emptyCardsLabel sizeToFit];
    
    
    
    
    //DeckModel*deck = [[DeckModel alloc] init];
    //deck.name = @"New Deck";
    //[userAllDecks addObject:deck];
    
    //[self updateCardsViewCards];
    [self resetAllViews];
}

/** Update all cards to ensure cards that cannot be added are grayed out */
- (void) updateCardsViewCards
{
    for (CardView* card in self.cardsView.currentCardViews)
    {
        if ([self canAddCardToDeck: card])
            card.cardViewState = cardViewStateCardViewer;
        else
            card.cardViewState = cardViewStateCardViewerGray;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    UIView*touchedView = touch.view;
    
    //touched a card in current list of cards
    if ([touchedView isKindOfClass:[CardView class]])
    {
        CardView*cardView = (CardView*)touchedView;
        UIView*view = cardView.superview;
        
        //cardsView
        if ([cardView.superview isKindOfClass:[UICollectionViewCell class]])
        {
            if (cardView != currentCard && currentCard == nil)
            {
                CardView*newMaximizedView = [[CardView alloc] initWithModel:cardView.cardModel cardImage: [[UIImageView alloc] initWithImage:cardView.cardImage.image]viewMode:cardViewModeEditor]; //constructor also modifies monster's cardView pointer
                [newMaximizedView setCardViewState:cardView.cardViewState];
                
                newMaximizedView.cardModel.cardView = cardView; //recover the pointer
                
                //find index of cardView
                for (int i = 0; i < self.cardsView.currentCardViews.count; i++)
                    if (self.cardsView.currentCardViews[i] == cardView)
                    {
                        currentIndex = i;
                        break;
                    }
                
                //store this card as currentCard
                currentCard = newMaximizedView;
                originalCurrentCard = cardView;
                
                CGPoint cardViewCenter = [self.view convertPoint:cardView.center fromView:cardView];
                
                //scrolls to left or right side depending on current position (TODO: may feel kinda weird)
                enum UICollectionViewScrollPosition scrollDir;
                
                if (cardViewCenter.x < self.cardsView.frame.origin.x + self.cardsView.frame.size.width/2)
                    scrollDir = UICollectionViewScrollPositionLeft;
                else
                    scrollDir = UICollectionViewScrollPositionRight;
                
                [self.cardsView.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]  animated:YES scrollPosition:scrollDir];
                
                //NSLog(@"%@ %@", NSStringFromCGRect(cardViewRect), NSStringFromCGRect(self.cardsView.frame));
                
                
                //[self.cardsView.collectionView scrollRectToVisible:CGRectMake(cardViewTopLeft.x, cardViewTopLeft.y, cardView.frame.size.width, cardView.frame.size.height) animated:YES];
                
                [self maximizeCardAnimation:newMaximizedView originalCard:cardView mode:cardCollectionAddCard];
            }
        }
        else if ([cardView.superview isKindOfClass:[UIScrollView class]])
        {
            //TODO
            //NSLog(@"clicked one in table view");

            //nearly identical code with cardview
            if (cardView != currentCard && currentCard == nil)
            {
                CardView*newMaximizedView = [[CardView alloc] initWithModel:cardView.cardModel cardImage: [[UIImageView alloc] initWithImage:cardView.cardImage.image]viewMode:cardViewModeEditor]; //constructor also modifies monster's cardView pointer
                [newMaximizedView setCardViewState:cardView.cardViewState];
                
                newMaximizedView.cardModel.cardView = cardView; //recover the pointer
                
                //find index of cardView in table
                for (int i = 0; i < self.deckView.currentCells.count; i++)
                    if (self.deckView.currentCells[i] == cardView)
                    {
                        currentIndex = i;
                        break;
                    }
                
                //store this card as currentCard
                currentCard = newMaximizedView;
                originalCurrentCard = cardView;
                
                CGPoint cardViewCenter = [self.view convertPoint:cardView.center fromView:cardView];
                
                [self maximizeCardAnimation:newMaximizedView originalCard:cardView mode:cardCollectionRemoveCard];
            }
        }
        else if (cardView == currentCard)
        {
            //[self addCardToDeckPressed];
            
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 currentCard.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_SCALE, CARD_VIEWER_SCALE);
                                 currentCard.center = [self.view convertPoint:originalCurrentCard.center fromView:originalCurrentCard];
                             }
                             completion:^(BOOL completed){
                                 [currentCard removeFromSuperview];
                                 currentCard = nil;
                             }];
            
            [self unmaximizeCard:lastVCardCollectionViewMode];
        }
    }
    else
    {
        //selecting an existing deck
        NSIndexPath *indexPath = [self.deckView.tableView indexPathForRowAtPoint:[touch locationInView:self.deckView]];
        
        if (indexPath)
        {
            //because for whatever reason it's possible to select a card view here
            if ([self.deckView.currentCells[indexPath.row] isKindOfClass:[DeckModel class]])
            {
                currentDeck = self.deckView.currentCells[indexPath.row];
                [self setupDeckEditView];
            }
        }
    }
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(BOOL)isRowVisible: (int)row {
    NSArray *indexes = [self.cardsView.collectionView indexPathsForVisibleItems];
    for (NSIndexPath *index in indexes)
        if (index.row == row)
            return YES;
    
    return NO;
}

-(void)cardsViewFinishedScrollingAnimation
{
   
}

/** Performs the animation of the card maximizing. Will wait for cardsView's scrolling to finish before playing. */
-(void) maximizeCardAnimation:(CardView*)newMaximizedView originalCard:(CardView*)cardView mode:(enum CardCollectinViewMode)mode
{
    [self performBlock:^{
        if (self.cardsView.isScrolling)
        {
            [self maximizeCardAnimation:newMaximizedView originalCard:cardView mode:mode];
        }
        else
        {
            //darken the background (also disables views)
            [self maximizeCard:mode];
            
            //[currentCard setCardViewState:cardViewStateMaximize];
            
            //for the maximizing animation, the new card starts out in the same size and pos as the original card
            currentCard.transform = originalCurrentCard.transform;
            currentCard.center = [self.view convertPoint:originalCurrentCard.center fromView:originalCurrentCard];
            
            //the new view is a maxed card for closing viewing
            [self.view addSubview:currentCard];
            
            //animate the maximizing
            [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 currentCard.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_MAXED_SCALE, CARD_VIEWER_MAXED_SCALE);
                                 currentCard.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - 40);
                             }
                             completion:nil];
        }
    } afterDelay:0.05];
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

-(void)maximizeCard:(enum CardCollectinViewMode)mode
{
    lastVCardCollectionViewMode = mode;
    darkFilter.alpha = 0;
    
    [self.view addSubview:darkFilter];
    
    if (mode == cardCollectionAddCard)
    {
        addCardToDeckButton.alpha = 0;
        cannotAddCardReasonLabel.alpha = 0;
        [addCardToDeckButton setEnabled:YES];
        
        [self.view addSubview:addCardToDeckButton];
        
        NSMutableArray*reasons = [self canAddCardToDeckWithReason:currentCard];
        if (reasons.count > 0)
        {
            NSString *reasonsText = @"Cannot add this card to deck.\n";
            for (NSString *reason in reasons)
            {
                reasonsText = [NSString stringWithFormat:@"%@- %@\n", reasonsText, reason];
            }
            
            cannotAddCardReasonLabel.text = reasonsText;
            [cannotAddCardReasonLabel sizeToFit];
            [self.view addSubview:cannotAddCardReasonLabel];
            [addCardToDeckButton setEnabled:NO];
        }
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             darkFilter.alpha = 0.9;
                             addCardToDeckButton.alpha = 1;
                             cannotAddCardReasonLabel.alpha = 1;
                         }
                         completion:nil];
    }
    else if (mode == cardCollectionRemoveCard)
    {
        removeCardFromDeckButton.alpha = 0;
        [self.view addSubview:removeCardFromDeckButton];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             darkFilter.alpha = 0.9;
                             removeCardFromDeckButton.alpha = 1;
                         }
                         completion:nil];
    }
}

-(void)unmaximizeCard:(enum CardCollectinViewMode)mode
{
    if (mode == cardCollectionAddCard)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             darkFilter.alpha = 0;
                             addCardToDeckButton.alpha = 0;
                             cannotAddCardReasonLabel.alpha = 0;
                         }
                         completion:^(BOOL completed){
                             [darkFilter removeFromSuperview];
                             [addCardToDeckButton removeFromSuperview];
                             if (cannotAddCardReasonLabel.superview!=nil)
                                 [cannotAddCardReasonLabel removeFromSuperview];
                         }];
    }
    else if (mode == cardCollectionRemoveCard)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             darkFilter.alpha = 0;
                             removeCardFromDeckButton.alpha = 0;
                         }
                         completion:^(BOOL completed){
                             [darkFilter removeFromSuperview];
                             [removeCardFromDeckButton removeFromSuperview];
                         }];
    }
}

- (void) addCardToDeckPressed
{
    //TODO
    [currentCard removeFromSuperview];
    
    [self addCardToDeckView:currentCard];
    
    currentCard = nil;
    
    [self unmaximizeCard:cardCollectionAddCard];
    [self.cardsView removeCellAt:currentIndex onFinish:^(void){[self updateCardsViewCards];}];
    
    currentIndex = -1;
}

/** Inserts the card into the correct position in the deck view */
-(void)addCardToDeckView: (CardView*)card
{
    int insertionIndex = -1;
    
    //insert at the first position where card < card at index
    for (int i = 0; i < [self.deckView.currentCells count]; i++)
    {
        CardView *cellCard = self.deckView.currentCells[i];
        if ([card.cardModel compare:cellCard.cardModel] == NSOrderedAscending)
        {
            insertionIndex = i;
            break;
        }
    }
    
    //not found index, insert at end
    if (insertionIndex == -1)
        insertionIndex = self.deckView.currentCells.count;
    
    [self.deckView.currentCells insertObject:card atIndex:insertionIndex];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:insertionIndex inSection:0];
    [self.deckView.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.deckView.tableView reloadInputViews];
    
    //scroll to the newly inserted position
    [self.deckView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:insertionIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    [self updateCardsCounterLabel];
}

-(void) removeCardFromDeckPressed
{
    [currentCard removeFromSuperview];
    
    [self addCardToCardsView:currentCard];
    
    currentCard = nil;
    
    [self unmaximizeCard:cardCollectionRemoveCard];
    [self.deckView removeCellAt:currentIndex];
    [self updateCardsCounterLabel];
    [self updateCardsViewCards];
    currentIndex = -1;
}

/** Inserts the card into the correct position in the cards view */
-(void)addCardToCardsView: (CardView*)card
{
    int insertionIndex = -1;
    
    //insert at the first position where card < card at index
    for (int i = 0; i < [self.cardsView.currentCardViews count]; i++)
    {
        CardView *cellCard = self.cardsView.currentCardViews[i];
        if ([card.cardModel compare:cellCard.cardModel] == NSOrderedAscending)
        {
            insertionIndex = i;
            break;
        }
    }
    
    //not found index, insert at end
    if (insertionIndex == -1)
        insertionIndex = self.cardsView.currentCardViews.count;
    
    card.cardHighlightType = cardHighlightNone;
    card.cardViewState = cardViewStateCardViewer;
    card.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_SCALE, CARD_VIEWER_SCALE);
    
    [self.cardsView.currentCardViews insertObject:card atIndex:insertionIndex];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:insertionIndex inSection:0];
    [self.cardsView.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
    [self.cardsView.collectionView reloadInputViews];
}

-(void) saveDeckButtonPressed
{
    if ([self isCurrentDeckValid])
    {
        NSLog(@"is valid");
        if (currentDeck == nil)
        {
            //add this new deck to userModel
            DeckModel* newDeck = [[DeckModel alloc] init];
            newDeck.name = @"New Deck";
            
            for (CardView* cardView in self.deckView.currentCells)
                [newDeck addCard:cardView.cardModel];
            
            //TODO also store this on Parse
            [UserModel saveDeck:newDeck];
        }
        else
        {
            //clear the deck and add the new cards in
            [currentDeck.cards removeAllObjects];
            
            for (CardView* cardView in self.deckView.currentCells)
                [currentDeck addCard:cardView.cardModel];
            
            [UserModel saveDeck:currentDeck];
        }
        
        [self resetAllViews];
    }
    else
    {
        NSLog(@"not valid");
        [self darkenScreen];
        
        [autoAddCardsLabel setEnabled:NO];
        [autoAddCardsButton setEnabled:NO];
        [notAutoAddCardsButton setEnabled:NO];
        
        autoAddCardsLabel.alpha = 0;
        autoAddCardsButton.alpha = 0;
        notAutoAddCardsButton.alpha = 0;
        
        [self.view addSubview:autoAddCardsLabel];
        [self.view addSubview:autoAddCardsButton];
        [self.view addSubview:notAutoAddCardsButton];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             autoAddCardsLabel.alpha = 1;
                             autoAddCardsButton.alpha = 1;
                             notAutoAddCardsButton.alpha = 1;
                         }
                         completion:^(BOOL completed){
                             [autoAddCardsLabel setEnabled:YES];
                             [autoAddCardsButton setEnabled:YES];
                             [notAutoAddCardsButton setEnabled:YES];
                         }];
    }
}

-(void) updateCardsCounterLabel
{
    deckCountLabel.text = [NSString stringWithFormat:@"%d/%d", self.deckView.currentCells.count, MAX_CARDS_IN_DECK];
}


-(void) updateDeckCounterLabel
{
    deckCountLabel.text = [NSString stringWithFormat:@"%d/%d", self.deckView.currentCells.count, userDeckLimit];
}


/** Returns empty array if can add to card, otherwise array of NSString as reasons to why card cannot be added. */
-(NSMutableArray*) canAddCardToDeckWithReason: (CardView*) card
{
    NSMutableArray* reasons = [NSMutableArray array];
    if (self.deckView.currentCells.count >= MAX_CARDS_IN_DECK) //TODO extra card ability
    {
        [reasons addObject:@"Maximum card limit reached."];
    }
    //TODO element, ability limit
    
    return reasons;
}

/** Simply returns YES or NO. */
-(BOOL) canAddCardToDeck: (CardView*) card
{
    if (self.deckView.currentCells.count >= MAX_CARDS_IN_DECK) //TODO extra card ability
        return NO;
    //TODO element, ability limit
    
    return YES;
}

-(BOOL) isCurrentDeckValid
{
    if (self.deckView.currentCells.count == MAX_CARDS_IN_DECK) //TODO extra card ability
        return YES;
    return NO;
}

-(void)autoAddCardsButtonPressed
{
    //TODO temporary method, just as random cards
    //TODO later needs to add cards that is actually valid
    NSMutableArray*ownedCards = [NSMutableArray array];
    for (CardView*cardView in self.cardsView.currentCardViews)
        [ownedCards addObject:cardView];
    
    while (self.deckView.currentCells.count < MAX_CARDS_IN_DECK)
    {
        int randomIndex = [[NSNumber numberWithUnsignedInteger:arc4random_uniform(ownedCards.count - 1)] intValue];
        
        CardView*cardView = ownedCards[randomIndex];
        
        int insertionIndex = -1;
        
        //insert at the first position where card < card at index
        for (int i = 0; i < [self.deckView.currentCells count]; i++)
        {
            CardView *cellCard = self.deckView.currentCells[i];
            if ([cardView.cardModel compare:cellCard.cardModel] == NSOrderedAscending)
            {
                insertionIndex = i;
                break;
            }
        }
        
        //not found index, insert at end
        if (insertionIndex == -1)
            insertionIndex = self.deckView.currentCells.count;
        
        
        [self.deckView.currentCells insertObject:cardView atIndex:insertionIndex];
        [ownedCards removeObjectAtIndex:randomIndex];
    }
    
    autoAddCardsLabel.alpha = 1;
    autoAddCardsButton.alpha = 1;
    notAutoAddCardsButton.alpha = 1;
    
    [autoAddCardsLabel setEnabled:NO];
    [autoAddCardsButton setEnabled:NO];
    [notAutoAddCardsButton setEnabled:NO];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         autoAddCardsLabel.alpha = 0;
                         autoAddCardsButton.alpha = 0;
                         notAutoAddCardsButton.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [autoAddCardsLabel removeFromSuperview];
                         [autoAddCardsButton removeFromSuperview];
                         [notAutoAddCardsButton removeFromSuperview];
                     }];
    [self undarkenScreen];
    
    [self saveDeckButtonPressed];
}

-(void)notAutoAddCardsButtonPressed
{
    autoAddCardsLabel.alpha = 1;
    autoAddCardsButton.alpha = 1;
    notAutoAddCardsButton.alpha = 1;
    
    [autoAddCardsLabel setEnabled:NO];
    [autoAddCardsButton setEnabled:NO];
    [notAutoAddCardsButton setEnabled:NO];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         autoAddCardsLabel.alpha = 0;
                         autoAddCardsButton.alpha = 0;
                         notAutoAddCardsButton.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [autoAddCardsLabel removeFromSuperview];
                         [autoAddCardsButton removeFromSuperview];
                         [notAutoAddCardsButton removeFromSuperview];
                     }];
    
    [self resetAllViews];
    
    [self undarkenScreen];
}

/** Resets all views to when it's first opened */
-(void)resetAllViews
{
    [self.deleteDeckButton removeFromSuperview];
    
    [self.cardsView removeAllCells];
    [self.deckView removeAllCells];
    currentDeck = nil;
    
    [self.view addSubview:emptyCardsLabel];
    [saveDeckButton removeFromSuperview];
    [self.view addSubview:addDeckButton];
    [self.view addSubview:backButton];
    
    //add user decks
    self.deckView.viewMode = deckTableViewDecks;
    for (DeckModel*deck in userAllDecks)
    {
        [self.deckView.currentCells addObject:deck];
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.deckView.currentCells.count-1 inSection:0];
        [self.deckView.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        
                //scroll to the newly inserted position
        /*
         [self.deckView.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.deckView.currentCells.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
         */
    }
    [self.deckView.tableView reloadInputViews];
    [self.deckView.tableView reloadData];
    [self updateDeckCounterLabel];
}

/** Setups the views for deck editing. If currentDeck is nil, assuming it's a new deck */
-(void)setupDeckEditView
{
    [backButton removeFromSuperview];
    
    [self.deckView removeAllCells];
    
    self.deckView.viewMode = deckTableViewCards;
    
    //get all cards in the existing deck
    if (currentDeck!=nil)
    {
        for (CardModel*card in currentDeck.cards)
        {
            //create a card view and set it up
            CardView *cardView = [[CardView alloc] initWithModel:card cardImage:[[UIImageView alloc]initWithImage: [UIImage imageNamed:@"card_image_placeholder"]]viewMode:cardViewModeEditor];
            card.cardView = cardView;
            cardView.cardHighlightType = cardHighlightNone;
            cardView.cardViewState = cardViewStateCardViewer;
            [self.deckView.currentCells addObject:cardView];
        }
        [self.view addSubview:self.deleteDeckButton];
    }
    
    [self.deckView.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
    //get the CardView of every card in the deck
    for (CardModel *card in allCards.cards)
    {
        //skip if the card already exists
        if ([currentDeck.cards containsObject:card])
            continue;
        
        //create a card view and set it up
        CardView *cardView = [[CardView alloc] initWithModel:card cardImage:[[UIImageView alloc]initWithImage: [UIImage imageNamed:@"card_image_placeholder"]]viewMode:cardViewModeEditor];
        card.cardView = cardView;
        cardView.cardHighlightType = cardHighlightNone;
        cardView.cardViewState = cardViewStateCardViewer;
        cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_SCALE, CARD_VIEWER_SCALE);
        
        //[self.cardsView.currentCardViews addObject:card.cardView];
        [self.cardsView.currentCardViews addObject:card.cardView];
    }
    
    [self updateCardsViewCards];
    
    
    //} completion:nil];
    
    [self updateCardsCounterLabel];
    
    [addDeckButton removeFromSuperview];
    [emptyCardsLabel removeFromSuperview];
    
    [self.view addSubview:saveDeckButton];
    
    [self.cardsView.collectionView performBatchUpdates:^{
        [self.cardsView.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
    //[self.cardsView.collectionView reloadData];
    //[self.cardsView.collectionView reloadInputViews];
}

-(void)addDeckButtonPressed
{
    //TODO if reached limit, ask user to visit store to buy more space
    
    currentDeck = nil;
    [self setupDeckEditView];
}

-(void)backButtonPressed
{
    //TODO all these back buttons should use a variable and not use a hard switch
    MainScreenViewController *viewController = [[MainScreenViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)deleteButtonPressed
{
    [self darkenScreen];
    
    [self.deleteDeckConfirmButton setEnabled:NO];
    [self.deleteDeckCancelButton setEnabled:NO];
    
    self.deleteDeckConfirmButton.alpha = 0;
    self.deleteDeckCancelButton.alpha = 0;
    deleteDeckLabel.alpha = 0;
    
    [self.view addSubview:self.deleteDeckConfirmButton];
    [self.view addSubview:self.deleteDeckCancelButton];
    [self.view addSubview:deleteDeckLabel];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.deleteDeckConfirmButton.alpha = 1;
                         self.deleteDeckCancelButton.alpha = 1;
                         deleteDeckLabel.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         [self.deleteDeckConfirmButton setEnabled:YES];
                         [self.deleteDeckCancelButton setEnabled:YES];
                     }];
}

-(void)deleteDeckConfirmButtonPressed
{
    [UserModel deleteDeck:currentDeck];
    [self deleteDeckCancelButtonPressed]; //just to get rid of the dialogs
    [self resetAllViews];
}

-(void)deleteDeckCancelButtonPressed
{
    self.deleteDeckConfirmButton.alpha = 1;
    self.deleteDeckCancelButton.alpha = 1;
    deleteDeckLabel.alpha = 1;
    
    [self.deleteDeckConfirmButton setEnabled:NO];
    [self.deleteDeckCancelButton setEnabled:NO];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.deleteDeckConfirmButton.alpha = 0;
                         self.deleteDeckCancelButton.alpha = 0;
                         deleteDeckLabel.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [self.deleteDeckConfirmButton removeFromSuperview];
                         [self.deleteDeckCancelButton removeFromSuperview];
                         [deleteDeckLabel removeFromSuperview];
                     }];
    
    [self undarkenScreen];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

/*
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.currentCardViews.count;
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
     
     
     
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cardCell" forIndexPath:indexPath];
 
     CardView *card = self.currentCardViews[indexPath.row];
     [cell addSubview:card];
     
     
     //cardimg = s
     
     //UILabel *attackLabel = (UILabel *)[cell viewWithTag:4];
     
     //attackLabel.text = thisCard.creator;
     
    
     
     
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


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
