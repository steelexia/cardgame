//
//  Campaign.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-12.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Level.h"

@interface Campaign : NSObject

+(void)loadResources;
+(Level*)getLevelWithDifficulty:(int)difficulty withChapter:(int)chapter withLevel:(int)level;

@end

extern const int NUMBER_OF_DIFFICULTIES, NUMBER_OF_ACTS;