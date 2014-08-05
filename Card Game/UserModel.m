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

const int INITIAL_DECK_LIMIT = 3;

+(void)setupUser
{
    userAllCards = [NSMutableArray array];
    userAllDecks = [NSMutableArray array];
    userAllCDCards = [NSMutableArray array];
    [userAllCards addObjectsFromArray:[SinglePlayerCards getDeckOne].cards];
    userDeckLimit = INITIAL_DECK_LIMIT;
    
    [UserModel updateUser:^(void)
     {
         userGold = [userPF[@"gold"] intValue];
         if (userPF[@"cards"] == nil)
             userPF[@"cards"] = @[];
         if (userPF[@"decks"] == nil)
             userPF[@"decks"] = @[];
         [self loadAllCards]; //also loads decks
         [userPF saveInBackground];
     }
     ];
}

+(void)updateUser:(void (^)())onFinishBlock
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
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

+(void)loadAllCards
{
    NSArray *cardsIDArray = userPF[@"cards"];
    __block int loadedCards = 0;
    for (NSNumber*cardID in cardsIDArray)
    {
        PFQuery *cardQuery = [PFQuery queryWithClassName:@"Card"];
        [cardQuery whereKey:@"idNumber" equalTo:cardID];
        cardQuery.limit = 1;
        [cardQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error)
            {
                if (objects.count > 0)
                {
                    //add card
                    [userAllCards addObject:[CardModel createCardFromPFObject:objects[0]]];
                    
                    loadedCards++;
                    
                    //load all decks once all cards have been loaded
                    if (loadedCards >= cardsIDArray.count)
                        [self loadAllDecks];
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
    NSArray*decksArray = userPF[@"decks"];
    
    for (PFObject*deckPF in decksArray)
    {
        DeckModel*deck = [self getDeckFromDeckPF:deckPF];
        if (deck!= nil)
            [userAllDecks addObject:deck];
    }
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
        {
            return card;
        }
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
    [deckPF fetchIfNeeded];
    DeckModel*deck = [[DeckModel alloc]init];
    @try
    {
        deck.name = deckPF[@"name"];
        deck.tags = deckPF[@"tags"];
        
        for (NSNumber*idNumber in deckPF[@"cards"])
            [deck addCard:[self getCardFromID:[idNumber intValue]]];
    }
    @catch (NSException *e) {
        NSLog(@"%@", e);
        return nil;
    }
    return deck;
}

+(void)saveDeck:(DeckModel*)deck
{
    NSMutableArray*currentDecks = [NSMutableArray arrayWithArray:userPF[@"decks"]];
    
    BOOL foundDeck = NO;
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
            [deckPF saveInBackground];
            
            foundDeck = YES;
        }
    }
    
    if (!foundDeck)
    {
        PFObject *deckPF = [self getDeckPFFromDeck:deck];
        [deckPF saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                NSLog(@"success");
                userPF[@"decks"] = currentDecks;
                [currentDecks addObject:deckPF];
                [userPF saveInBackground];
            }
            else
            {
                NSLog(@"ERROR: FAILED TO SAVE");
            }
        }];
    }
    
    if (![userAllDecks containsObject:deck])
        [userAllDecks addObject:deck];
    
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

+(void)deleteDeck:(DeckModel*)deck
{
    NSMutableArray*currentDecks = [NSMutableArray arrayWithArray:userPF[@"decks"]];
    
    for (PFObject*deckPF in currentDecks)
    {
        if ([deckPF.objectId isEqualToString:deck.objectID])
        {
            [currentDecks removeObject:deckPF];
            [userAllDecks removeObject:deck];
            break;
        }
    }
    
    [userPF saveInBackground];
    
    
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
+(void)publishCard:(CardModel*)card
{
    [PFCloud callFunctionInBackground:@"getNewCardID" withParameters:@{}
                                block:^(NSNumber *idNumber, NSError *error) {
                                    if (!error) {
                                        card.idNumber = [idNumber integerValue];
                                        
                                        //upload card to parse
                                        [CardModel addCardToParse:card];
                                        
                                        //create a sale
                                        PFObject *sale = [PFObject objectWithClassName:@"Sale"];
                                        sale[@"cardID"] = idNumber;
                                        sale[@"likes"] = @0;
                                        sale[@"seller"] = [PFUser currentUser].objectId;
                                        sale[@"stock"] = @10;
                                        
                                        [sale saveInBackground];
                                        
                                        [self saveCard:card];
                                    }
                                    else
                                    {
                                        NSLog(@"ERROR: Failed to get an ID from cloud. Card is not uploaded");
                                        //TODO!!!
                                    }
                                }];
}

@end