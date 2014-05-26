//
//  CardModel.h
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CardView;

/** 
 Abstract class that is the parent of specific card types, such as MonsterCardModel and SpellCardModel.
 Stores the common properties that is used in all cards
 */
@interface CardModel : NSObject

/** Attached view for drawing the card. Note that view is weak */
@property (weak) CardView *cardView;

//----------------Card info stats----------------//

/** Each card has an unique id used to identify itself */
@property (readonly) long idNumber;

/** Name of the card, can have duplicate with other cards? */
@property (strong) NSString* name;

/** Rarity of the card. Affects its appearance and possible abilites */
@property enum CardRarity rarity;

/** The technical type of the card (i.e. if it is a temporary card from an ability, or if it's the card representing the player). Card types such as cardTypeTemporary's idNumber would have no purpose.
    NOT to be confused with card types such as MonsterCard and SpellCard.
 */
@property enum CardType type;

//----------------Card battle stats values----------------//

/** Amount of resources it costs to deploy the card. 0 or higher */
@property int cost;

/** Stores all of the Ability's the card is currently holding. For MonsterCards, it is equivalent to all "enchantments" applied to it, which (IMPORTANT!) also includes debuffs. For SpellCards, it is simply the effects it will give when summoned.  */
@property (strong) NSMutableArray* abilities;

//----------------Functions----------------//

/** Initializes an empty card with only an id */
-(instancetype)initWithIdNumber: (long)idNumber;

/** Initializes an empty card with id and card type */
-(instancetype)initWithIdNumber:(long)idNumber type:(enum CardType) type;

@end

enum CardRarity{
    cardRarityCommon,
    cardRarityUncommon,
    cardRarityRare,
    cardRarityEpic, //not sure about this yet
    cardRarityLegendary,
};

enum CardType{
    cardTypeStandard, //regular cards that are created by players
    cardTypeTemporary, //temporary cards that are summoned by other cards etc.
    cardTypePlayer, //cards used to represent the player hero
    cardTypeSinglePlayer //cards used by AI during single player
};