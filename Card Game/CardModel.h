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

//----------------Card battle stats values----------------//

/** Amount of resources it costs to deploy the card. 0 or higher */
@property int cost;

//----------------Functions----------------//

/** Initializes an empty card with only an id */
-(instancetype)initWithIdNumber: (long)idNumber;

@end
