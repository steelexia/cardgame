//
//  CDCardModel.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-07-06.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface CDCardModel : NSManagedObject


@property (nonatomic, retain) NSNumber * idNumber;
@property (nonatomic, retain) NSNumber * cost;
@property (nonatomic, retain) NSNumber * rarity;
@property (nonatomic, retain) NSNumber * cardType;
@property (nonatomic, retain) NSNumber * damage;
@property (nonatomic, retain) NSNumber * life;
@property (nonatomic, retain) NSNumber * cooldown;
@property (nonatomic, retain) NSNumber * element;
@property (nonatomic, retain) NSNumber * likes;
@property (nonatomic, retain) NSNumber * reports;

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * creator;
@property (nonatomic, retain) NSString * creatorName;

@property (nonatomic, retain) NSString * abilities;

@end
