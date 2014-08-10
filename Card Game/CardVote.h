//
//  CardVote.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-08.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "CardModel.h"
#import "MonsterCardModel.h"
#import "AbilityWrapper.h"

@interface CardVote : NSObject

@property double averageCost, averageDamage, averageLife, averageCD;
@property int totalVotes;
@property PFObject*votedCard;

/** Stores array of arrays. Second array stores 3 numbers: ability ID, total votes, average value */
@property (strong) NSMutableArray*abilities;

/** Init with a PFObject if it's non-nil. */
-(instancetype) initWithPFObject:(PFObject*)cardVotePF;

/** Init with CardModel for newly created cards that don't have a CardVote PFObject yet */
-(instancetype) initWithCardModel:(CardModel*)cardModel;

/** Updates the CardVote by voting with the states of another cardModel */
-(void)addVote:(CardModel*)cardModel;

/** Stores its data into the PFObject. Can be existing or new. Will not save object. */
-(void)updateToPFObject:(PFObject*)cardVotePF;

/** Generated VotedCard in the voteCard property using the cardModel. Also updates the card model (accident) */
-(void)generatedVotedCard:(CardModel*)cardModel;

@end
