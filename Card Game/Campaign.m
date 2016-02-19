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
const int NUMBER_OF_CHAPTERS = 3;

const NSString *TUTORIAL_ONE = @"d_1_c_1_l_1",*TUTORIAL_TWO = @"d_1_c_1_l_2",*TUTORIAL_THREE = @"d_1_c_1_l_3",*TUTORIAL_FOUR = @"d_1_c_1_l_4";

/** 2D array storing all levels */
NSMutableArray*campaignLevels;

Level*quickMatchLevel;

+(Level*)quickMatchLevel
{
    return quickMatchLevel;
}

+(void)loadResources
{
    [SinglePlayerCards loadCampaignCards];
    
    //special levels for special modes
    quickMatchLevel = [[Level alloc] initWithID:@"quick_match"];
    quickMatchLevel.opponentName = @"Quick Match"; //TODO
    quickMatchLevel.heroId = 0; //TODO
    quickMatchLevel.goldReward = 20;
    
    campaignLevels = [NSMutableArray arrayWithCapacity:3*3*4];
    Level *level;
    
    /**
     NOTES:
     - 3rd level should not have any rewards, because beating it goes straight to the boss fight
     */
    
    //------------difficulty 1------------//
    //----chapter 1----//
    level = [[Level alloc] initWithID:@"d_1_c_1_l_1"];
    level.opponentName = @"Level one";
    level.heroId = 1;
    level.isTutorial = YES;
    level.breakBeforeNextLevel = NO;
    level.cardReward = 1;
    level.goldReward = 150;
    level.breakBeforeNextLevel = NO;
    level.opponentShuffleDeck = NO;
    level.playerShuffleDeck = NO;
    level.opponentHealth = 25;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_1_l_2"];
    level.opponentName = @"Level two";
    level.heroId = 2;
    level.isTutorial = YES;
    level.breakBeforeNextLevel = NO;
    level.cardReward = 1;
    level.goldReward = 250;
    level.breakBeforeNextLevel = NO;
    level.opponentShuffleDeck = NO;
    level.playerShuffleDeck = NO;
    level.opponentHealth = 30;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_1_l_3"];
    level.opponentName = @"Level three";
    level.heroId = 3;
    level.isTutorial = YES;
    level.breakBeforeNextLevel = NO;
    level.opponentShuffleDeck = NO;
    level.playerShuffleDeck = NO;
    level.opponentHealth = 45;
    level.endBattleText = @"Some text talking about how the current level is beaten but a boss has shown up to stop you.";
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_1_l_4"];
    level.opponentName = @"Chapter one boss";
    level.heroId = 4;
    level.isTutorial = YES;
    level.isBossFight = YES;
    //level.opponentShuffleDeck = NO;
    level.playerShuffleDeck = NO;
    level.goldReward = 1000; //basically starting gold for the player to spend. 14 common cards + 2 created
    [campaignLevels addObject:level];
    
    //----chapter 2----//
    level = [[Level alloc] initWithID:@"d_1_c_2_l_1"];
    level.opponentName = @"Level four";
    level.heroId = 4;
    level.difficultyOffset = -1;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_2_l_2"];
    level.opponentName = @"Level five";
    level.heroId = 5;
    level.difficultyOffset = -1;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_2_l_3"];
    level.opponentName = @"Level six";
    level.heroId = 6;
    level.difficultyOffset = -1;
    level.breakBeforeNextLevel = NO;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_2_l_4"];
    level.opponentName = @"Chapter two boss";
    level.heroId = 7;
    level.difficultyOffset = -1;
    level.isBossFight = YES;
    [campaignLevels addObject:level];
    
    //----chapter 3----//
    level = [[Level alloc] initWithID:@"d_1_c_3_l_1"];
    level.opponentName = @"Level seven";
    level.heroId = 9;
    level.difficultyOffset = -1;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_3_l_2"];
    level.opponentName = @"Level eight";
    level.heroId = 10;
    level.difficultyOffset = -1;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_3_l_3"];
    level.opponentName = @"Level nine";
    level.heroId = 11;
    level.difficultyOffset = -1;
    level.breakBeforeNextLevel = NO;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_1_c_3_l_4"];
    level.opponentName = @"Chapter three boss";
    level.heroId = 12;
    level.difficultyOffset = -1;
    level.isBossFight = YES;
    [campaignLevels addObject:level];
    
    //------------difficulty 2------------//
    //----chapter 1----//
    level = [[Level alloc] initWithID:@"d_2_c_1_l_1"];
    level.opponentName = @"Level one hero";
    level.heroId = 1;
    //level.opponentHealth = 1;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_2_c_1_l_2"];
    level.opponentName = @"Level two hero";
    level.heroId = 2;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_2_c_1_l_3"];
    level.opponentName = @"Level three hero";
    level.heroId = 3;
    level.breakBeforeNextLevel = NO;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_2_c_1_l_4"];
    level.opponentName = @"Level four hero";
    level.heroId = 3;
    level.isBossFight = YES;
    [campaignLevels addObject:level];
    
    //----chapter 2----//
    level = [[Level alloc] initWithID:@"d_2_c_2_l_1"];
    level.heroId = 4;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_2_c_2_l_2"];
    level.opponentName = @"Senior General";
    level.heroId = 5;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_2_c_2_l_3"];
    level.heroId = 6;
    level.breakBeforeNextLevel = NO;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_2_c_2_l_4"];
    level.heroId = 6;
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
    level.difficultyOffset = 1;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_1_l_2"];
    level.difficultyOffset = 1;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_1_l_3"];
    level.difficultyOffset = 1;
    level.breakBeforeNextLevel = NO;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_1_l_4"];
    level.difficultyOffset = 1;
    level.isBossFight = YES;
    [campaignLevels addObject:level];
    
    //----chapter 2----//
    level = [[Level alloc] initWithID:@"d_3_c_2_l_1"];
    level.difficultyOffset = 1;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_2_l_2"];
    level.difficultyOffset = 1;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_2_l_3"];
    level.difficultyOffset = 1;
    level.breakBeforeNextLevel = NO;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_2_l_4"];
    level.difficultyOffset = 1;
    level.isBossFight = YES;
    [campaignLevels addObject:level];
    
    //----chapter 3----//
    level = [[Level alloc] initWithID:@"d_3_c_3_l_1"];
    level.difficultyOffset = 1;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_3_l_2"];
    level.difficultyOffset = 1;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_3_l_3"];
    level.difficultyOffset = 1;
    level.breakBeforeNextLevel = NO;
    [campaignLevels addObject:level];
    
    level = [[Level alloc] initWithID:@"d_3_c_3_l_4"];
    level.difficultyOffset = 1;
    level.isBossFight = YES;
    [campaignLevels addObject:level];
    
    //----Challenges----//
    level = [[Level alloc] initWithID:@"d_1_c_4_l_1"];
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

+(Level*)getNextLevelWithLevelID:(NSString*)levelID
{
    int index = -1;
    for (int i = 0; i < [campaignLevels count]; i++)
    {
        Level*level = campaignLevels[i];
        if ([level.levelID isEqualToString:levelID])
        {
            index = i;
            break;
        }
    }
    
    if (index == -1 || index+1 >= campaignLevels.count)
        return nil;
    else
        return campaignLevels[index+1];
}

+(NSString*)getChapterDescription:(int)chapter
{
    if (chapter == 1)
        return @"Chapter one description...";
    else if (chapter == 2)
        return @"Chapter two description...";
    else if (chapter == 3)
        return @"Chapter three description...";
    
    return @"NO DESCRIPTION";
}


@end

