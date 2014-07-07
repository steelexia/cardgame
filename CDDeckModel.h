//
//  CDDeckModel.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-07-06.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface CDDeckModel : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * cards;

@end
