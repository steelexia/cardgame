//
//  PlayerLevelView.m
//  cardgame
//
//  Created by Steele Xia on 2016-07-13.
//  Copyright © 2016 Content Games. All rights reserved.
//

#import "PlayerLevelView.h"
#import "UIConstants.h"

#import "UserModel.h"
#import "CardView.h"

#import "CardModel.h"

@implementation PlayerLevelView

UIImage*buttonOpenImage,*buttonCloseImage;

//the frame is the entire screen size
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, 0, self.frame.size.width, 160);
        
        _elementViewOpen = NO;
        
        //----main panel----//
        _backgroundView = [[CFLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 80)];
        [self addSubview:_backgroundView];
        
        _playerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_image_placeholder"]];
        [_playerImageView setFrame:CGRectMake(10, 10, 60, 60)];
        [_backgroundView addSubview:_playerImageView];
        
        _playerNameLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(80-2, 10, self.frame.size.width - 80, 30)];
        _playerNameLabel.text = [NSString stringWithFormat:@" %@", userPF.username];
        _playerNameLabel.textAlignment = NSTextAlignmentLeft;
        _playerNameLabel.textColor = [UIColor whiteColor];
        _playerNameLabel.font = [UIFont fontWithName:cardMainFontBlack size:20];
        _playerNameLabel.strokeColour = [UIColor blackColor];
        _playerNameLabel.strokeThickness = 2;
        _playerNameLabel.strokeOn = YES;
        [_backgroundView addSubview:_playerNameLabel];
        
        _playerLevelLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(80-3 , 40, self.frame.size.width - 80, 30)];
        _playerLevelLabel.text = [NSString stringWithFormat:@" %d", userLevel]; //add space to fix clipping issue
        _playerLevelLabel.textAlignment = NSTextAlignmentLeft;
        _playerLevelLabel.textColor = [UIColor whiteColor];
        _playerLevelLabel.font = [UIFont fontWithName:cardMainFontBlack size:26];
        _playerLevelLabel.strokeColour = [UIColor blackColor];
        _playerLevelLabel.strokeThickness = 3;
        _playerLevelLabel.strokeOn = YES;
        [_backgroundView addSubview:_playerLevelLabel];
        
        
        _playerExpBar = [[CFExpBar alloc] initWithFrame:CGRectMake(115, 50, self.frame.size.width - 115 - 10, 20)];
        _playerExpBar.maxValue = userMaxXP;
        [_playerExpBar updateValue:userXP];
        [_backgroundView addSubview:_playerExpBar];

        //----elemental panel----//
        _elementalBackgroundView = [[CFLabel alloc] initWithFrame:CGRectMake(0, _backgroundView.frame.size.height - 150, self.frame.size.width, 150)];
        [self insertSubview:_elementalBackgroundView atIndex:0];
        
        _levelLabelArray = [NSMutableArray arrayWithCapacity:6];
        //@[fireLevelLabel, iceLevelLabel, lightningLevelLabel, earthLevelLabel, lightLevelLabel, darkLevelLabel];
        _expBarArray = [NSMutableArray arrayWithCapacity:6];
        //@[playerFireExpBar, playerIceExpBar, playerLightningExpBar, playerEarthExpBar, playerLightExpBar, playerDarkExpBar];
        
        for (int j = 0 ; j < 3; j++)
        {
            for (int i = 0 ; i < 2; i++)
            {
                int index = j * 2 + i;
                
                CFExpBar*elementExpBar = [[CFExpBar alloc] initWithFrame:CGRectMake(40 + (i*self.frame.size.width/2), _elementalBackgroundView.bounds.size.height/4 * (j+1), self.frame.size.width/2 - 50, 15)];
                //elementExpBar.maxValue = userMaxFireXP;
                //[elementExpBar updateValue:userFireXP];
                [_elementalBackgroundView addSubview:elementExpBar];
                [_expBarArray addObject:elementExpBar];
                
                StrokedLabel*elementLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
                elementLabel.text = [CardModel elementToString:elementFire+index];
                elementLabel.textAlignment = NSTextAlignmentCenter;
                elementLabel.textColor = [UIColor whiteColor];
                elementLabel.font = [UIFont fontWithName:cardMainFontBlack size:14];
                elementLabel.strokeColour = [UIColor blackColor];
                elementLabel.strokeThickness = 2;
                elementLabel.strokeOn = YES;
                elementLabel.center = CGPointMake(elementExpBar.center.x, _elementalBackgroundView.bounds.size.height/4 * (j+1) - 12);
                [_elementalBackgroundView addSubview:elementLabel];
                
                StrokedLabel *levelLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(10 + (i*self.frame.size.width/2), 25 + _elementalBackgroundView.bounds.size.height/4 * j, self.frame.size.width, 30)];
                
                //levelLabel.text = [NSString stringWithFormat:@" %d", userFireLevel];
                levelLabel.textAlignment = NSTextAlignmentLeft;
                levelLabel.textColor = [UIColor whiteColor];
                levelLabel.font = [UIFont fontWithName:cardMainFontBlack size:18];
                levelLabel.strokeColour = [UIColor blackColor];
                levelLabel.strokeThickness = 2;
                levelLabel.strokeOn = YES;
                [_elementalBackgroundView addSubview:levelLabel];
                [_levelLabelArray addObject: levelLabel];
                
                
            }
        }
        
        _playerElementalLevelButton = [[CFButton alloc] initWithFrame:CGRectMake(0, _backgroundView.frame.size.height- 10, 40, 25)];
        [_playerElementalLevelButton setImage:[UIImage imageNamed:@"decrement_button"] forState:UIControlStateNormal];
        [_playerElementalLevelButton setImage:[UIImage imageNamed:@"increment_button"] forState:UIControlStateSelected];
        
        [_playerElementalLevelButton addTarget:self action:@selector(elementButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playerElementalLevelButton];
    }
    return self;
}

-(void)elementButtonPressed
{
    if (_elementViewOpen)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _elementalBackgroundView.center = CGPointMake(_backgroundView.frame.size.width/2, _backgroundView.frame.size.height - _elementalBackgroundView.frame.size.height/2);
                         }
                         completion:^(BOOL completed){
                             _elementViewOpen = NO;
                             [_playerElementalLevelButton setSelected:NO];
                         }];
        
    }
    else
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _elementalBackgroundView.center = CGPointMake(_backgroundView.frame.size.width/2, _backgroundView.frame.size.height + _elementalBackgroundView.frame.size.height/2);
                         }
                         completion:^(BOOL completed){
                             _elementViewOpen = YES;
                             [_playerElementalLevelButton setSelected:YES];
                         }];
    }
}

-(void)updateValues
{
    for (int i = 0; i < 6; i++)
    {
        CFExpBar* expBar = _expBarArray[i];
        StrokedLabel* levelLabel = _levelLabelArray[i];
        
        if (i == 0)
        {
            expBar.maxValue = userMaxFireXP;
            [expBar updateValue:userFireXP];
            [levelLabel setText: [NSString stringWithFormat:@" %d", userFireLevel]];
        }
        else if (i == 1)
        {
            expBar.maxValue = userMaxIceXP;
            [expBar updateValue:userIceXP];
            [levelLabel setText: [NSString stringWithFormat:@" %d", userIceLevel]];
        }
        else if (i == 2)
        {
            expBar.maxValue = userMaxEarthXP;
            [expBar updateValue:userEarthXP];
            [levelLabel setText: [NSString stringWithFormat:@" %d", userEarthLevel]];
        }
        //these 3 not yet implemented
        else if (i == 3)
        {
            expBar.maxValue = 1;
            [expBar updateValue:0];
            [levelLabel setText: [NSString stringWithFormat:@" %d", 1]];
        }
        else if (i == 4)
        {
            expBar.maxValue = 1;
            [expBar updateValue:0];
            [levelLabel setText: [NSString stringWithFormat:@" %d", 1]];
        }
        else if (i == 5)
        {
            expBar.maxValue = 1;
            [expBar updateValue:0];
            [levelLabel setText: [NSString stringWithFormat:@" %d", 1]];
        }
    }
}

@end