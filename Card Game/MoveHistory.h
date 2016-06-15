//
//  MoveHistory.h
//  cardgame
//
//  Created by Steele on 2014-10-13.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardModel.h"
#import "MonsterCardModel.h"

@interface MoveHistory : NSObject

@property (strong) CardModel*caster;
/* text to display over the caster card. can be used for damage dealt or health restored etc. */
@property (strong) NSString* casterValue;

/* array of MonsterCardModel of the targets */
@property (strong) NSMutableArray*targets;
/* array of NSString to display on the targets */
@property (strong) NSMutableArray*targetsValues;

/* copy of all monsters on the board before the move history began */
@property (strong) NSMutableArray*allMonsters;

@property enum MoveType moveType;

/* side the move was made on */
@property int side;

-(instancetype)initWithCaster:(CardModel*)caster withTargets:(NSMutableArray*)targets withMoveType:(enum MoveType) moveType withSide:(int)side withBoardState:(NSMutableArray*)allMonsters;
-(void)addTarget:(MonsterCardModel*)target;
/* Called once at the end of the move for cards to check against their original card to see the difference */
-(void)updateAllValues;

@end

enum MoveType
{
    MoveTypeSummon,
    MoveTypeAttack,
    MoveTypeOnMove,
    MoveTypeOnEndOfTurn,
    MoveTypeOnDamaged,
    MoveTypeOnDeath,
};