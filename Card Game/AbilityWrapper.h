//
//  AbilityWrapper.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-04.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardModel.h"
#import "Ability.h"

@class PFObject;

/** 
 While Ability class represents raw abilities that are used for calculations and such, AbilityWrapper is used for representing the actual specific abilities that exists in the game. This presents a list of abilities users can choose from, and would not include the large number of abilities that does not make any sense.
 This class makes it much easier to send ability data, as one number would represent a combination of settings (castType, durationType, etc.). Use this for all store and similar purposes.
 Note that this really is only a convenience class, as it's impossible to manage the almost infinitely many combinations Ability can have. For example, OP single player abilities can be added directly with Ability without needing to use this at all.
 There is also no ID number stored for each AbilityWrapper. Instead its index to the allAbilities array is used as the ID.
 */
@interface AbilityWrapper : NSObject

/** Specific combination of ability settings. Its description may be  */
@property Ability *ability;
/** Locks the ability to a specific type of element. */
@property enum CardElement element;
/** The minimum rarity required before a card can pick this ability */
@property enum CardRarity rarity;
/** The number of points the ability costs for a card when designing the card. minPoints represents the cost for the smallest number for otherValues. (if smaller number is better ability, minPoints would actually be bigger number than maxPoints) */
@property int minPoints;
/** The number of points the ability costs for a card when designing the card. maxPoints represents the cost for the largest number for otherValues. (if smaller number is better ability, minPoints would actually be bigger number than maxPoints) */
@property int maxPoints;
/** Maximum number of cards with this ability allowed per deck. Most abilities should be around 1-2 since there can be different duration and cast types.*/
@property int maxCount;

/** Finds the id of the ability wrapper that is identical to the ability in terms of the types. (value doesn't matter) Returns -1 if it cannot find one that matches. */
+(int)getIdWithAbility:(Ability*)ability;

/** Loads the database of every pickable ability in the game. Once this is called, getAbilityWithId can be called to obtain all abilities */
+(void)loadAllAbilities;

/** Gets a specific ability combination with the idNumber and the values. */
+(Ability*)getAbilityWithId: (int)idNumber value:(NSNumber*)value otherValues:(NSArray*)otherValues;

/** Gets a specific ability combination with the PFObject. */
+(Ability*)getAbilityWithPFObject:(PFObject*)abilityPF;

@end

/** Represents the element the ability is locked to. Each card can only pick abilities with the same element, except elementNeutral. */
enum CardElement
{
    elementNeutral
};