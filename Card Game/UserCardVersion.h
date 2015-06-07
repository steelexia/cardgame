//
//  UserCardVersion.h
//  cardgame
//
//  Created by Brian Allen on 2015-06-06.
//  Copyright (c) 2015 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserCardVersion : NSManagedObject

@property (nonatomic, retain) NSNumber * idNumber;
@property (nonatomic, retain) NSNumber * viewedVersion;

@end
