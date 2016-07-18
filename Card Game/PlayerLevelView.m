//
//  PlayerLevelView.m
//  cardgame
//
//  Created by Steele Xia on 2016-07-13.
//  Copyright © 2016 Content Games. All rights reserved.
//

#import "PlayerLevelView.h"
#import "UIConstants.h"
#import "CFLabel.h"
#import "UserModel.h"
#import "CardView.h"

@implementation PlayerLevelView

CFLabel*backgroundView;
StrokedLabel*playerNameLabel, *playerLevelLabel, *playerLevelLabel2, *playerExpLabel;
UIImageView*playerLevelBackground, *playerLevelView;
UIImageView*playerImageView;

//the frame is the entire screen size
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, 0, self.frame.size.width, 80);
        
        backgroundView = [[CFLabel alloc] initWithFrame:self.bounds];
        [self addSubview:backgroundView];
        
        playerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_image_placeholder"]];
        [playerImageView setFrame:CGRectMake(10, 10, 60, 60)];
        [self addSubview:playerImageView];
        
        playerLevelBackground = [[UIImageView alloc]initWithFrame:CGRectMake(115, 50, self.frame.size.width - 115 - 10, 15)];
        [playerLevelBackground setBackgroundColor:COLOUR_DARK]; //TODO temp
        [self addSubview:playerLevelBackground];
        
        if (userMaxXP != -1)
        {
            int maxWidth = playerLevelBackground.frame.size.width - 4;
            
            playerLevelView = [[UIImageView alloc]initWithFrame:CGRectMake(115 + 2, 50 + 2, (int)((double)userXP/userMaxXP*maxWidth), 15 - 4)]; //TODO warning casting long into double
        }
        else
        {
            //max level reached, bar full
            playerLevelView = [[UIImageView alloc]initWithFrame:CGRectMake(105 + 2, 50 + 2, self.frame.size.width - 105 - 10 - 4, 15 - 4)];
        }
        
        [playerLevelView setBackgroundColor:COLOUR_LEGENDARY]; //TODO temp
        [self addSubview:playerLevelView];
        
        playerNameLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(80-2, 10, self.frame.size.width - 80, 30)];
        playerNameLabel.text = [NSString stringWithFormat:@" %@", userPF.username];
        playerNameLabel.textAlignment = NSTextAlignmentLeft;
        playerNameLabel.textColor = [UIColor whiteColor];
        playerNameLabel.font = [UIFont fontWithName:cardMainFontBlack size:20];
        playerNameLabel.strokeColour = [UIColor blackColor];
        playerNameLabel.strokeThickness = 2;
        playerNameLabel.strokeOn = YES;
        [self addSubview:playerNameLabel];
        
        playerLevelLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(80-3 , 40, self.frame.size.width - 80, 30)];
        playerLevelLabel.text = [NSString stringWithFormat:@" %d", userLevel]; //add space to fix clipping issue
        playerLevelLabel.textAlignment = NSTextAlignmentLeft;
        playerLevelLabel.textColor = [UIColor whiteColor];
        playerLevelLabel.font = [UIFont fontWithName:cardMainFontBlack size:26];
        playerLevelLabel.strokeColour = [UIColor blackColor];
        playerLevelLabel.strokeThickness = 3;
        playerLevelLabel.strokeOn = YES;
        [self addSubview:playerLevelLabel];

        playerExpLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0 , 0, playerLevelBackground.frame.size.width, playerLevelBackground.frame.size.height*2)];
        playerExpLabel.center = CGPointMake(playerLevelBackground.center.x,playerLevelBackground.center.y + 5);
        playerExpLabel.text = [NSString stringWithFormat:@"%ld/%ld", userXP, userMaxXP];
        playerExpLabel.textAlignment = NSTextAlignmentCenter;
        playerExpLabel.textColor = [UIColor whiteColor];
        playerExpLabel.font = [UIFont fontWithName:cardMainFontBlack size:10];
        playerExpLabel.strokeColour = [UIColor blackColor];
        playerExpLabel.strokeThickness = 1;
        playerExpLabel.strokeOn = YES;
        [self addSubview:playerExpLabel];
        
        
        
        //[self setBackgroundColor:COLOUR_ICE];
    }
    return self;
}

@end