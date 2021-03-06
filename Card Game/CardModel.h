//
//  CardModel.h
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class CardView;
@class Ability;

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
    NOT to be confused with card types such as MonsterCard and SpellCard, which is the cardType on Parse database. This type is not stored there as only player cards are stored.
 */
@property enum CardType type;


/** For cards with the type standard, this links to the PF ID of the creator. */
@property NSString *creator;

/** For convenience, the creator's username is cached here so that it can be displayed mid-battle of a game. */
@property NSString *creatorName;

//----------------Card battle stats values----------------//

@property enum CardElement element;

/** Amount of resources it costs to deploy the card. 0 or higher */
@property int cost;

/** Stores all of the Ability's the card is currently holding. For MonsterCards, it is equivalent to all "enchantments" applied to it, which (IMPORTANT!) also includes debuffs. For SpellCards, it is simply the effects it will give when summoned.  */
@property (strong) NSMutableArray* abilities;

//----------------Functions----------------//

/** Initializes an empty card with only an id */
-(instancetype)initWithIdNumber: (long)idNumber;

/** Initializes an empty card with id and card type */
-(instancetype)initWithIdNumber:(long)idNumber type:(enum CardType) type;

/** Adds the ability and sets isBaseAbility to YES */
-(void)addBaseAbility: (Ability*)ability;

/** Loads a card's stats with data grabbed from parse. This should only used for a completely new card that cannot be cached anywhere else, e.g. a human opponent's card. Assumes the card is already allocated! */
//+(void)loadCardWithParseID:(CardModel*)card withID:(NSString*)parseID;

/** Returns the String version of the elements */
+(NSString*) elementToString:(enum CardElement) element;

/** Creates a card out of a PFObject. */
+(CardModel*) createCardFromPFObject: (PFObject*)cardPF;

/** Adds a card to the Parse database. Really only used when user creates a new card. Otherwise mainly for debugging */
+(void) addCardToParse:(CardModel*) card;

@end

enum CardRarity{
    cardRarityCommon,
    cardRarityUncommon,
    cardRarityRare,
    cardRarityExceptional,
    cardRarityLegendary,
};

enum CardType{
    cardTypeStandard, //regular cards that are created by players
    cardTypeTemporary, //temporary cards that are summoned by other cards etc.
    cardTypePlayer, //cards used to represent the player hero
    cardTypeSinglePlayer //cards used by AI during single player
};

/**
 Represents the element the ability is locked to. Each card can only pick abilities with the same element, except elementNeutral.
 
 There are 7 types of elements:
 Neutral (tan) - Basic skills, e.g. draw card, gain resource, taunt, silence
 
 And 3 pairs of elements, each opposite of another, and they cannot coexist in a deck:
 Fire (orange-red) - Direct damage, AOE damage, (maybe) burn curse
 Ice (light blue) - Cooldown increase, (maybe) freeze curse
 
 Lightning (light yellow) - Rapid damage, maybe also AOE?, cooldown decrease (maybe) shock curse
 Earth (brown) - Regeneration, growth (i.e. life, damage) gain over time (maybe) poison curse
 
 Light (light grey) - Heal, curse removal
 Dark (dark grey) - Self-damaging, curse,
 
 */
enum CardElement
{
    elementNeutral,
    elementFire,
    elementIce,
    elementLightning,
    elementEarth,
    elementLight,
    elementDark,
    //TODO single player AI cards may have other elements
};

extern const int MONSTER_CARD, SPELL_CARD;


