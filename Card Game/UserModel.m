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
}

+(void)loadAllCards
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Card"
                                              inManagedObjectContext:userCDContext];
    [fetchRequest setEntity:entity];
    
    NSArray *fetchedObjects = [userCDContext executeFetchRequest:fetchRequest error:&error];
    
    for (CDCardModel *card in fetchedObjects) {
        [userAllCards addObject:[self cardFromCDCard:card]];
    }
}

+(void)loadAllDecks
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Deck"
                                              inManagedObjectContext:userCDContext];
    [fetchRequest setEntity:entity];
    
    NSArray *fetchedObjects = [userCDContext executeFetchRequest:fetchRequest error:&error];
    
    for (CDDeckModel *deck in fetchedObjects) {
        [userAllDecks addObject:[self deckFromCD:deck]];
    }
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
    cdCard.name = card.name;
    cdCard.creator = card.creator;
    cdCard.creatorName = card.creatorName;
    
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
    card.name = cdCard.name;
    card.creator = cdCard.creator;
    card.creatorName = cdCard.creatorName;
    
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

+(void)saveDeck:(DeckModel*)deck
{
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
}

+(void)deleteDeck:(DeckModel*)deck
{
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
}

//maybe not put it here?
+(void)publishCard:(CardModel*)card
{
    [PFCloud callFunctionInBackground:@"getNewCardID" withParameters:@{}
                                block:^(NSNumber *idNumber, NSError *error) {
                                    if (!error) {
                                        card.idNumber = [idNumber integerValue];
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