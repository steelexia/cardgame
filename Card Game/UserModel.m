//
//  UserModel.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-27.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "UserModel.h"
#import "SinglePlayerCards.h"
#import "CDCardModel.h"
#import "CDDeckModel.h"
#import "AbilityWrapper.h"

@implementation UserModel

+(void)setupUser
{
    userAllCards = [NSMutableArray array];
    userAllDecks = [NSMutableArray array];
    userAllCDCards = [NSMutableArray array];
    //[userAllCards addObjectsFromArray:[SinglePlayerCards getDeckOne].cards];
    
    //TODO SOME TEMPORARY STUFF DELETE AFTER
    
    /*
    PFQuery *salesQuery = [PFQuery queryWithClassName:@"Sale"];
    [salesQuery findObjectsInBackgroundWithBlock:^(NSArray *sales, NSError *error) {
        if(!error){
            PFQuery *cardsQuery = [PFQuery queryWithClassName:@"Card"];
            [cardsQuery findObjectsInBackgroundWithBlock:^(NSArray *cards, NSError *error) {
                if(!error){
                    for (PFObject *salePF in sales)
                    {
                        int cardID = [salePF[@"cardID"] intValue];
                        
                        for (PFObject *cardPF in cards)
                        {
                            if ([cardPF[@"idNumber"] intValue] == cardID)
                            {
                                int newID = cardID + 1000;
                                
                                salePF[@"cardID"] = @(newID);
                                cardPF[@"idNumber"] = @(newID);
                                
                                [salePF saveInBackground];
                                [cardPF saveInBackground];
                                break;
                            }
                        }
                    }
                    
                    NSLog(@"all done");
                }
                else
                {
                    NSLog(@"ERROR SEARCHING SALES");
                }
            }];
            
            
        }
        else
        {
            NSLog(@"ERROR SEARCHING SALES");
        }
    }];*/
    
    
    
    
    [UserModel updateUser:^(void)
     {
         //set initials values here
         //#CLOUD but kinda lazy
         if (userPF[@"decks"] == nil)
             userPF[@"decks"] = @[];
         if (userPF[@"gold"] == nil)
             userPF[@"gold"] = @(99999);
         if (userPF[@"likes"] == nil)
             userPF[@"likes"] = @(99);
         if (userPF[@"interactedCards"] == nil)
             userPF[@"interactedCards"] = @{};
         //TODO: note that this should start at 2, since there are two free cards for tutorial
         if (userPF[@"blankCards"] == nil)
             userPF[@"blankCards"] = @(50);
         if (userPF[@"completedLevels"] == nil)
             userPF[@"completedLevels"] = @[];
         if (userPF[@"passwordSetup"] == nil)
             userPF[@"passwordSetup"] = @(NO);
         if (userPF[@"messages"] == nil)
             userPF[@"messages"] = @[];
         if (userPF[@"maxDecks"] == nil)
             userPF[@"maxDecks"] = @(8);
         if (userPF[@"deckTutorialDone"] == nil)
             userPF[@"deckTutorialDone"] = @(NO);
         if (userPF[@"storeTutorialDone"] == nil)
             userPF[@"storeTutorialDone"] = @(NO);
         
         //this variable useless and should be removed later
         userGold = [userPF[@"gold"] intValue];
         
         userDeckLimit = [userPF[@"maxDecks"] intValue];
         
         [self loadAllCards]; //also loads decks
         
         NSError *error;
         [userPF save:&error];
         
         if (error)
             userInitError = YES;
         else
             userInfoLoaded = YES; //TODO move this if other things are loaded
     }
     ];
}

+(void)updateUser:(void (^)())onFinishBlock
{
    //TODO fix this mess
    NSLog(@"called this");
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    [query includeKey:@"decks"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            if (objects.count > 0)
            {
                userPF = objects[0];
                onFinishBlock();
            }
            else
            {
                NSLog(@"ERROR: COULD NOT FIND USER!");
            }
        }
        else
        {
            NSLog(@"ERROR: ERROR FINDING USER!");
        }
    }];
}

+(BOOL)ownsCardWithID:(int)idNumber
{
    for (CardModel*card in userAllCards)
    {
        //NOTE: just for temporary when some cards are single player cards
        if (card.type == cardTypeStandard && card.idNumber == idNumber)
            return YES;
    }
    return NO;
}

+(NSArray*)loadAllCardIDs
{
    NSMutableArray*cardIDs = [NSMutableArray array];
    NSDictionary*dic = userPF[@"interactedCards"];
    
    if (dic != nil)
    {
        for (NSString*idString in dic)
        {
            int idNumber = [idString intValue];
            if (idNumber < CARD_ID_START) //skip starting cards
                continue;
            
            if ([UserModel getOwnedCardID:idNumber])
                [cardIDs addObject:@(idNumber)];
        }
    }
    
    return cardIDs;
}

+(void)loadAllCards
{
    NSArray *cardsIDArray = [UserModel loadAllCardIDs];

    //__block int loadedCards = 0;
    
    if (cardsIDArray.count == 0)
    {
        [userAllCards addObjectsFromArray:[SinglePlayerCards getStartingDeck].cards];
        [self loadAllDecks];
    }
    else
    {
        __block int loadingCards = cardsIDArray.count;
        
        //for (NSNumber *cardID in cardsIDArray)
        //{
            //skip starting cards because they're not on database
        /*
        for (int i = cardsIDArray.count-1; i >= 0; i--)
        {
            NSNumber *cardID = cardsIDArray[i];
            if ([cardID intValue] < CARD_ID_START)
                [cardsIDArray remo]
                
        }
         */
        //        loadingCards--;
        
        PFQuery *cardQuery = [PFQuery queryWithClassName:@"Card"];
        [cardQuery whereKey:@"idNumber" containedIn:cardsIDArray];
        cardQuery.limit = 1000; //TODO this is bad but no one would have this many cards..
        [cardQuery includeKey:@"abilities"];
        NSError *error;
        NSArray*objects = [cardQuery findObjects:&error];
        if (!error)
        {
            loadingCards = objects.count;
            __block int counter = 0;
            NSLog(@"%d", loadingCards);
            //NSLog(@"number of cards to load: %d", loadingCards);
            for (PFObject *cardPF in objects)
            {
                //add card
                [self performBlockInBackground:^{
                    //NSLog(@"pre-pre-start");
                    CardModel*cardModel = [CardModel createCardFromPFObject:cardPF onFinish:nil];
                    //NSLog(@"pre-start");
                    
                    //dispatch_async(dispatch_get_main_queue(), ^{
                        //NSLog(@"start");
                        if (cardModel == nil)
                        {
                            NSLog(@"ERROR: Create card from parse returned nil in UserModel %d %d", [cardPF[@"idNumber"] intValue], counter++);
                            //TODO might have to show error to restart game
                        }
                        else
                        {
                            NSLog(@"before add %d", userAllCards.count);
                            [userAllCards addObject:cardModel];
                            NSLog(@"after add %d", userAllCards.count);
                            NSLog(@"Added card %d %d", [cardPF[@"idNumber"] intValue], counter++);
                        }
                        loadingCards--;
                    //});
                    //counter++;
                    //NSLog(@"%d", counter);
                }];
            }
        }
        else
        {
            NSLog(@"ERROR: ERROR FINDING USER!");
            loadingCards = 0;
        }
        //}
        
        //wait until cards are all loaded
        while(loadingCards != 0)
        {
            //NSLog(@"%d", loadingCards);
            sleep(1);
        }
        
        //loads the starting deck
        [userAllCards addObjectsFromArray:[SinglePlayerCards getStartingDeck].cards];
        
        //load all decks once all cards have been loaded
        [self loadAllDecks];
    }
    
    //TODO: load from CD if Parse's hasn't been updated
    /*
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card"
                                              inManagedObjectContext:userCDContext];
    [fetchRequest setEntity:entity];
    
    NSArray *fetchedObjects = [userCDContext executeFetchRequest:fetchRequest error:&error];
    
    for (CDCardModel *card in fetchedObjects) {
        [userAllCards addObject:[self cardFromCDCard:card]];
    }
     */
}

+(void)loadAllDecks
{
    //[UserModel performBlockInBackground:^(void){
    NSArray*decksArray = userPF[@"decks"];
    
    for (PFObject*deckPF in decksArray)
    {
        DeckModel*deck = [self getDeckFromDeckPF:deckPF];
        if (deck!= nil)
            [userAllDecks addObject:deck];
    }
    
    NSLog(@"all decks loaded");
    
    //}];
    /*
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Deck"
                                              inManagedObjectContext:userCDContext];
    [fetchRequest setEntity:entity];
    
    NSArray *fetchedObjects = [userCDContext executeFetchRequest:fetchRequest error:&error];
    
    for (CDDeckModel *deck in fetchedObjects) {
        [userAllDecks addObject:[self deckFromCD:deck]];
    }
     */
}



+(CardModel*)getCardFromID:(int)idNumber
{
    for (CardModel*card in userAllCards)
    {
        if (idNumber == card.idNumber)
            return card;
    }
    return nil;
}

//don't think is needed
+(void)saveAllCards
{
    /*
     CDCardModel *card = [NSEntityDescription
     insertNewObjectForEntityForName:@"Card"
     inManagedObjectContext:context];
     card.name = @"Card name";
     card.cardId = @1;
     card.cardType = @1;
     */
}

+(void)saveCard:(CardModel*)card
{
    BOOL foundCard = NO;
    for (CDCardModel *cdCard in userAllCDCards)
    {
        //this card already exists, just update its values
        if ([cdCard.idNumber integerValue] == card.idNumber)
        {
            [self updateCDCard:cdCard withCardModel:card];
            foundCard = YES;
            break;
        }
    }
    
    if (!foundCard)
    {
        //if reached here, this is a new card
        CDCardModel *cdCard = [NSEntityDescription
                               insertNewObjectForEntityForName:@"Card"
                               inManagedObjectContext:userCDContext];
        [self updateCDCard:cdCard withCardModel:card];
        [userAllCDCards addObject:cdCard];
    }
    
    NSError *error;
    if (![userCDContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    else
    {
        NSLog(@"Done saving card.");
    }
}

+(void)updateCDCard:(CDCardModel*)cdCard withCardModel:(CardModel*)card
{
    cdCard.idNumber = [NSNumber numberWithInt:card.idNumber];
    cdCard.cost = [NSNumber numberWithInt:card.cost];
    cdCard.rarity = [NSNumber numberWithInt:card.rarity];
    cdCard.element = [NSNumber numberWithInt:card.element];
    cdCard.name = card.name;
    cdCard.creator = card.creator;
    cdCard.creatorName = card.creatorName;
    cdCard.likes = @(card.likes);
    
    cdCard.abilities = @"";
    
    for (Ability *ability in card.abilities)
    {
        
        //CDAbilityModel *cdAbility = [NSEntityDescription
        //                             insertNewObjectForEntityForName:@"Ability"
        //                             inManagedObjectContext:userCDContext];
        //.idNumber = [NSNumber numberWithInt:idNumber];
        //cdAbility.value = cdAbility.value;
        //[cdAbilities addObject:cdAbility];
        //NSString*abilityString = AbilityWrapper get;
        cdCard.abilities = [NSString stringWithFormat:@"%@%@,", cdCard.abilities, [AbilityWrapper abilityToString:ability]];
    }
    
    
    if ([card isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel*monster = (MonsterCardModel*)card;
        
        cdCard.damage = [NSNumber numberWithInt:monster.baseDamage];
        cdCard.life = [NSNumber numberWithInt:monster.baseMaxLife];
        cdCard.cooldown = [NSNumber numberWithInt:monster.baseMaxCooldown];
        cdCard.cardType = [NSNumber numberWithInt:MONSTER_CARD];
    }
    else if ([card isKindOfClass:[SpellCardModel class]])
    {
        cdCard.cardType = [NSNumber numberWithInt:SPELL_CARD];
    }
}

+(CardModel*)cardFromCDCard:(CDCardModel*)cdCard
{
    CardModel*card;
    
    int idNumber = [cdCard.idNumber intValue];
    
    if ([cdCard.cardType isEqualToNumber: [NSNumber numberWithInt:MONSTER_CARD]])
    {
        card = [[MonsterCardModel alloc] initWithIdNumber:idNumber];
        MonsterCardModel*monster = (MonsterCardModel*)card;
        monster.damage = [cdCard.damage intValue];
        monster.life = monster.maximumLife = [cdCard.life intValue];
        monster.cooldown = monster.maximumCooldown = [cdCard.cooldown intValue];
    }
    else if ([cdCard.cardType isEqualToNumber: [NSNumber numberWithInt:SPELL_CARD]])
    {
        card = [[SpellCardModel alloc] initWithIdNumber:idNumber];
    }
    
    card.cost = [cdCard.cost intValue];
    card.rarity = [cdCard.rarity intValue];
    card.element = [cdCard.element intValue];
    card.name = cdCard.name;
    card.creator = cdCard.creator;
    card.creatorName = cdCard.creatorName;
    card.likes = [cdCard.likes intValue];
    
    if (cdCard.abilities!=nil)
    {
        NSArray* abilityStrings = [cdCard.abilities componentsSeparatedByString:@","];
        
        for (NSString*cdAbility in abilityStrings)
        {
            if ([cdAbility isEqualToString:@""])
                continue;
            
            Ability*ability = [AbilityWrapper getAbilityWithString:cdAbility];
            if (ability==nil)
            {
                NSLog(@"ERROR: Failed to add an ability from CD: %@", cdAbility);
                continue;
            }
            [card addBaseAbility:ability];
        }
    }
    
    return card;
}

+(DeckModel*)deckFromCD:(CDDeckModel*)cdDeck
{
    DeckModel *deck = [[DeckModel alloc] init];
    
    deck.name = cdDeck.name;
    deck.tags = [NSMutableArray arrayWithArray:[cdDeck.tags componentsSeparatedByString:@" "]];
    
    NSArray*cardsString = [cdDeck.cards componentsSeparatedByString:@" "];
    for (NSString*cardString in cardsString)
    {
        int idNumber = [cardString intValue];
        
        for (CardModel*card in userAllCards)
        {
            if (idNumber == card.idNumber)
            {
                [deck addCard:card];
                break;
            }
        }
    }
    
    deck.cdDeck = cdDeck;
    
    return deck;
}

+(PFObject*)getDeckPFFromDeck:(DeckModel*)deck
{
    PFObject *deckPF = [PFObject objectWithClassName:@"Deck"];
    deckPF[@"name"] = deck.name;
    deckPF[@"tags"] = deck.tags;
        
    NSMutableArray*cardsID = [NSMutableArray arrayWithCapacity:deck.cards.count];
    for (CardModel*card in deck.cards)
        [cardsID addObject:@(card.idNumber)];
    deckPF[@"cards"] = cardsID;
    
    return deckPF;
}

+(DeckModel*)getDeckFromDeckPF:(PFObject*)deckPF
{
    //[deckPF fetchIfNeeded]; //used includeKey in userPF fetch
    DeckModel*deck = [[DeckModel alloc]init];
    @try
    {
        deck.name = deckPF[@"name"];
        deck.tags = deckPF[@"tags"];
        deck.objectID = deckPF.objectId;
        
        for (NSNumber*idNumber in deckPF[@"cards"])
        {
            CardModel*card = [self getCardFromID:[idNumber intValue]];
            
            //a card may have been lost (sold, destroyed)
            if (card!=nil)
                [deck addCard:card];
            else
            {
                NSLog(@"ERROR: getDeckFromDeckPF couldn't get %d", [idNumber intValue]);
            }
        }
    }
    @catch (NSException *e) {
        NSLog(@"ERROR: getDeckFromDeckPF: %@", e);
        return nil;
    }
    return deck;
}

+(DeckModel*)downloadDeckFromPF:(PFObject*)deckPF
{
    DeckModel*deck = [[DeckModel alloc]init];
    @try
    {
        deck.name = deckPF[@"name"];
        deck.tags = deckPF[@"tags"];
        deck.objectID = deckPF.objectId;
        
        PFQuery *cardQuery = [PFQuery queryWithClassName:@"Card"];
        cardQuery.limit = 100;
        [cardQuery whereKey:@"idNumber" containedIn:deckPF[@"cards"]];
        NSError *error;
        NSArray*cardPFs = [cardQuery findObjects:&error];
        
        if (error)
            return nil;
        else if (cardPFs.count != [deckPF[@"cards"] count])
        {
            NSLog(@"cardPF doesn't match deck cards count");
            return nil;
        }
        else
        {
            for (PFObject *cardPF in cardPFs)
            {
                CardModel *card = [CardModel createCardFromPFObject:cardPF onFinish:nil];
                
                if (card == nil)
                {
                    NSLog(@"Error creating a card from cardPF");
                    return nil;
                }
                [deck addCard:card];
            }
        }
    }
    @catch (NSException *e) {
        NSLog(@"%@", e);
        return nil;
    }
    return deck;
}

+(BOOL)saveDeck:(DeckModel*)deck
{
    NSMutableArray*currentDecks = [NSMutableArray arrayWithArray:userPF[@"decks"]];
    
    BOOL foundDeck = NO;
    
    //try to see if the deck exists first, if so, simply modify it
    for (PFObject*deckPF in currentDecks)
    {
        if ([deckPF.objectId isEqualToString:deck.objectID])
        {
            NSLog(@"found deck");
            
            deckPF[@"name"] = deck.name;
            deckPF[@"tags"] = deck.tags;
            
            NSMutableArray*cardsID = [NSMutableArray arrayWithCapacity:deck.cards.count];
            for (CardModel*card in deck.cards)
                [cardsID addObject:@(card.idNumber)];
            deckPF[@"cards"] = cardsID;
            
            NSError *error;
            [deckPF save:&error];
            if (error)
                return NO;
            
            foundDeck = YES;
            break;
        }
    }
    
    //not deck found, this is a new deck
    if (!foundDeck)
    {
        PFObject *deckPF = [self getDeckPFFromDeck:deck];
        
        NSError*error;
        [deckPF save:&error];
        
        if (error)
            return NO;
        
        userPF[@"decks"] = currentDecks;
        [currentDecks addObject:deckPF];
        
        [userPF save:&error];
        
        if (error)
        {
            //failed to save the deck, delete it
            [deckPF deleteEventually];
            return NO;
        }
        
        deck.objectID = deckPF.objectId;
        NSLog(@"objectID: %@", deck.objectID);
    }
    
    if (![userAllDecks containsObject:deck])
        [userAllDecks addObject:deck];
    
    return YES;
    //TODO readd these later
    /*
    CDDeckModel *cdDeck;
    
    if (deck.cdDeck == nil)
    {
        cdDeck = [NSEntityDescription
                           insertNewObjectForEntityForName:@"Deck"
                           inManagedObjectContext:userCDContext];
        deck.cdDeck = cdDeck;
    }
    else
        cdDeck = deck.cdDeck;
    
    cdDeck.name = deck.name;
    
    NSString *deckTagsString = @"";
    for (NSString *deckTag in deck.tags)
        deckTagsString = [NSString stringWithFormat:@"%@%@ ", deckTagsString, deckTag];
    
    cdDeck.tags = deckTagsString;
    
    NSString *cardsString = @"";
    for (CardModel *card in deck.cards)
    {
        cardsString = [NSString stringWithFormat:@"%@%d ", cardsString, card.idNumber];
    }
    
    cdDeck.cards = cardsString;
    
    NSError *error;
    if (![userCDContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    else
    {
        NSLog(@"Done saving deck.");
    }
    
    if (![userAllDecks containsObject:deck])
        [userAllDecks addObject:deck];
     */
}

+(BOOL)deleteDeck:(DeckModel*)deck
{
    NSMutableArray*currentDecks = [NSMutableArray arrayWithArray:userPF[@"decks"]];
    
    for (PFObject*deckPF in currentDecks)
    {
        if ([deckPF.objectId isEqualToString:deck.objectID])
        {
            NSLog(@"found deck to delete");
            [currentDecks removeObject:deckPF];
            NSError *error;
            [deckPF delete:&error];
            
            if (error)
                return NO;
            else
                NSLog(@"deleted");
            break;
        }
    }
    
    NSLog(@"deletion no error");
    
    [userAllDecks removeObject:deck];
    userPF[@"decks"] = currentDecks;
    NSError *error;
    [userPF save:&error];
    if (error)
        return NO;
    
    return YES;
    //TODO readd these later
    /*
    if (deck.cdDeck!=nil)
    {
        [userCDContext deleteObject:deck.cdDeck];
        deck.cdDeck = nil;
        
        NSError *error;
        if (![userCDContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        else
        {
            NSLog(@"Done saving deck.");
        }
    }
    
    [userAllDecks removeObject:deck];
     */
}

//maybe not put it here?
+(BOOL)publishCard:(CardModel*)card withImage:(UIImage*)image
{
    //#REMOVE
    /*
    NSNumber *idNumber = [PFCloud callFunction:@"getNewCardID" withParameters:@{}];
    if (idNumber == nil)
        return NO;*/
    card.idNumber = NO_ID; //card has no id at this point
    
    //upload card to parse
    NSError *error = [CardModel addCardToParse:card withImage:image];
    if (error)
        return NO;
    
    [PFCloud callFunction:@"publishCard" withParameters:@{
                                                      @"cardID" : card.cardPF.objectId,
                                                      } error:&error];
    
    if (!error)
    {
        [userPF fetch];
        [card.cardPF fetch];
        card.idNumber = [card.cardPF[@"idNumber"] intValue];
    }
    else
    {
        //attempt to delete the card
        [card.cardPF delete];
        card.cardPF = nil;
    }
    
    /*
    PFObject *sale = [PFObject objectWithClassName:@"Sale"];
    sale[@"cardID"] = idNumber;
    sale[@"likes"] = @0;
    sale[@"seller"] = [PFUser currentUser].objectId;
    sale[@"stock"] = @10;
    sale[@"card"] = card.cardPF;
    sale[@"name"] = card.name;
    sale[@"tags"] = card.cardPF[@"tags"];
    
    NSError *saleError = nil;
    [sale save:&saleError]; //TODO this is only temporary for now, later
    
    if (saleError)
        return NO;
    
    userPF[@"blankCards"] = @([userPF[@"blankCards"] intValue] - 1);
    BOOL succ = [self setOwnedCard:card];
    
    if (!succ)
        return NO;
     */
    //[userPF save];
    
    //[self saveCard:card];
    
    NSLog(@"card successfully uploaded!");
    
    return YES;
}

+(BOOL)setLikedCard:(CardModel*)card
{
    return [self setCardInteraction:card.idNumber atBit:0 state:YES];
}

+(BOOL)setEditedCard:(CardModel*)card
{
    return [self setCardInteraction:card.idNumber atBit:1 state:YES];
}

+(BOOL)setOwnedCard:(CardModel*)card
{
    return [self setCardInteraction:card.idNumber atBit:2 state:YES];
}

+(BOOL)setNotOwnedCard:(CardModel*)card
{
    return [self setCardInteraction:card.idNumber atBit:2 state:NO];
}

+(BOOL)setCardInteraction:(int)idNumber atBit:(int)bit state:(BOOL)state
{
    NSDictionary*dic = userPF[@"interactedCards"];
    if (dic == nil)
        dic = @{};
    
    NSMutableDictionary *interactedCards = [[NSMutableDictionary alloc] initWithDictionary:dic];
    
    NSNumber *interactions = interactedCards[[NSString stringWithFormat:@"%d", idNumber]];
    if (interactions == nil)
    {
        if (state)
            interactions = @(0x1 << bit);
        else
            interactions = @(0x0);
    }
    else
    {
        if (state)
            interactions = @([interactions intValue] | 0x1 << bit);
        else
            interactions = @([interactions intValue] & ~(0x1 << bit));
    }
    NSLog(@"interaction %d", [interactions intValue]);
    
    [interactedCards setObject:interactions forKey:[NSString stringWithFormat:@"%d", idNumber]];
    userPF[@"interactedCards"] = interactedCards;
    
    NSError *error;
    [userPF save:&error]; //NOTE: Do not remove this as others depend on this save
    
    if (error)
        return NO;
    else
        return YES;
}

+(BOOL)getLikedCard:(CardModel*)card
{
    return [self getCardInteraction:card.idNumber atBit:0];
}

+(BOOL)getEditedCard:(CardModel*)card
{
    return [self getCardInteraction:card.idNumber atBit:1];
}

+(BOOL)getOwnedCard:(CardModel*)card
{
    return [self getCardInteraction:card.idNumber atBit:2];
}

+(BOOL)getLikedCardID:(int)idNumber
{
    return [self getCardInteraction:idNumber atBit:0];
}

+(BOOL)getOwnedCardID:(int)idNumber
{
    return [self getCardInteraction:idNumber atBit:2];
}

+(void)removeOwnedCard:(int)idNumber
{
    //remove card for userAllCards
    for (int i = 0; i < userAllCards.count; i++)
    {
        CardModel*card = userAllCards[i];
        if (card.idNumber == idNumber)
            [userAllCards removeObjectAtIndex:i];
    }
    
    for (DeckModel *deck in userAllDecks)
    {
        for (int i = 0; i < deck.count; i++)
        {
            CardModel*card = [deck getCardAtIndex:i];
            if (card.idNumber == idNumber)
                [deck removeCardAtIndex:i];
        }
    }
}

+(NSArray*)getAllOwnedCardID
{
    NSMutableArray *ownedCardIDs = [NSMutableArray array];
    NSDictionary*dic = userPF[@"interactedCards"];
    if (dic == nil)
        return ownedCardIDs;
    for (NSString*key in dic.allKeys)
    {
        int idNumber = [key intValue];
        if ([self getOwnedCardID:idNumber])
            [ownedCardIDs addObject:@(idNumber)];
    }
    
    return ownedCardIDs;
}


+(BOOL)getCardInteraction:(int)idNumber atBit:(int)bit
{
    NSDictionary*dic = userPF[@"interactedCards"];
    if (dic == nil)
        return NO;
    
    NSMutableDictionary *interactedCards = [[NSMutableDictionary alloc] initWithDictionary:dic];
    
    NSNumber *interactions = interactedCards[[NSString stringWithFormat:@"%d", idNumber]];
    if (interactions == nil)
        return NO;
    else
    {
        int integer = [interactions intValue];
        if ((integer >> bit) % 2 == 1) //checks the last bit after pushing it off
            return YES;
    }
    return NO;
}

+ (void)performBlockInBackground:(void (^)())block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        block();
    });
}



@end