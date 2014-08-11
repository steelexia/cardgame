//
//  PlayerModel.h
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MonsterCardModel;

/**
 Stores of information of a player during a match. 
 This only includes the player's attributes, such as resource, life, etc.
 */
@interface PlayerModel : NSObject

/** The "life" of a player. Represented by a monster card to store life, abilities etc. Note that the card is not actually drawn using CardView */
@property (strong) MonsterCardModel *playerMonster;

/** Amount of resource a player currently has. Used to summon cards */
@property int resource;

/** Maximum amount of resource a player can currently have */
@property int maxResource;

/** Initializes with a monster card representing itself */
-(instancetype)initWithPlayerMonster: (MonsterCardModel*) playerMonster;


@end

/** Max number of resource a player can have */
extern const int MAX_RESOURCE;