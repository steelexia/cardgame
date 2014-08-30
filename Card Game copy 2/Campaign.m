//
//  Campaign.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-12.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "Campaign.h"
#import "SinglePlayerCards.h"

@implementation Campaign

const int NUMBER_OF_DIFFICULTIES = 3;
const int NUMBER_OF_ACTS = 3;

/** 2D array storing all levels */
NSMutableArray*campaignLevels;

+(void)loadResources
{
    campaignLevels = [NSMutableArray arrayWithCapacity:3*3*4];
    Level *level;
    
    //------------difficulty 1------------//
    //----chapter 1----//
    level = [[Level alloc] initWithID:@"d_1_c_1_l_1"];
    level.isTutorial = YES;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_1_l_2"];
    level.isTutorial = YES;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_1_l_3"];
    level.isTutorial = YES;
    level.breakBeforeNextLevel = NO;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_1_l_4"];
    level.isTutorial = YES;
    level.isBossFight = YES;
    [campaignLevels addObject:level];
    
    //----chapter 2----//
    level = [[Level alloc] initWithID:@"d_1_c_2_l_1"];
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_2_l_2"];
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_2_l_3"];
    level.breakBeforeNextLevel = NO;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_2_l_4"];
    level.isBossFight = YES;
    [campaignLevels addObject:level];
    
    //----chapter 3----//
    level = [[Level alloc] initWithID:@"d_1_c_3_l_1"];
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_3_l_2"];
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_3_l_3"];
    level.breakBeforeNextLevel = NO;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_3_l_4"];
    level.isBossFight = YES;
    [campaignLevels addObject:level];
    
    //------------difficulty 2------------//
    //----chapter 1----//
    level = [[Level alloc] initWithID:@"d_2_c_1_l_1"];
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_2_c_1_l_2"];
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_2_c_1_l_3"];
    level.breakBeforeNextLevel = NO;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_2_c_1_l_4"];
    level.isBossFight = YES;
    [campaignLevels addObject:level];
    
    //----chapter 2----//
    level = [[Level alloc] initWithID:@"d_2_c_2_l_1"];
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_2_c_2_l_2"];
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_2_c_2_l_3"];
    level.breakBeforeNextLevel = NO;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_2_c_2_l_4"];
    level.isBossFight = YES;
    [campaignLevels addObject:level];
    
    //----chapter 3----//
    level = [[Level alloc] initWithID:@"d_2_c_3_l_1"];
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_2_c_3_l_2"];
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_2_c_3_l_3"];
    level.breakBeforeNextLevel = NO;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_2_c_3_l_4"];
    level.isBossFight = YES;
    [campaignLevels addObject:level];
    //------------difficulty 3-----------//
    //----chapter 1----//
    level = [[Level alloc] initWithID:@"d_3_c_1_l_1"];
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_1_l_2"];
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_1_l_3"];
    level.breakBeforeNextLevel = NO;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_1_l_4"];
    level.isBossFight = YES;
    [campaignLevels addObject:level];
    
    //----chapter 2----//
    level = [[Level alloc] initWithID:@"d_3_c_2_l_1"];
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_2_l_2"];
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_2_l_3"];
    level.breakBeforeNextLevel = NO;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_2_l_4"];
    level.isBossFight = YES;
    [campaignLevels addObject:level];
    
    //----chapter 3----//
    level = [[Level alloc] initWithID:@"d_3_c_3_l_1"];
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_3_l_2"];
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_3_l_3"];
    level.breakBeforeNextLevel = NO;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_3_l_4"];
    level.isBossFight = YES;
    [campaignLevels addObject:level];
}

+(Level*)getLevelWithDifficulty:(int)difficulty withChapter:(int)chapter withLevel:(int)level
{
    NSString *levelID = [NSString stringWithFormat:@"d_%d_c_%d_l_%d", difficulty, chapter, level];
    
    for (Level *level in campaignLevels)
    {
        if ([level.levelID isEqualToString:levelID])
            return level;
    }
    
    return nil;
}

@end
