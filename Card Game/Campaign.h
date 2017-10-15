//
//  Campaign.h
//
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-12.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Level.h"

@interface Campaign : NSObject

+(void)loadResourcesCampaign;
+(Level*)getLevelWithDifficulty:(int)difficulty withChapter:(int)chapter withLevel:(int)level;
+(Level*)getNextLevelWithLevelID:(NSString*)levelID;
+(NSString*)getChapterDescription:(int)chapter;

+(Level*)quickMatchLevel;

@end

extern const int NUMBER_OF_DIFFICULTIES, NUMBER_OF_CHAPTERS;

//for easier access by GVC
extern const NSString *TUTORIAL_ONE,*TUTORIAL_TWO,*TUTORIAL_THREE,*TUTORIAL_FOUR;
