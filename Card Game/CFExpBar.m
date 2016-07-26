//
//  CFExpBar.m
//  cardgame
//
//  Created by Steele Xia on 2016-07-22.
//  Copyright © 2016 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFExpBar.h"

#import "UIConstants.h"
#import "CardView.h"





@implementation CFExpBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _maxValue = 1;
        

        _playerLevelBackground = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height * 3 / 4)];
        [_playerLevelBackground setBackgroundColor:COLOUR_DARK]; //TODO temp
        [self addSubview:_playerLevelBackground];
        
        _playerLevelView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_playerLevelView setBackgroundColor:COLOUR_LEGENDARY]; //TODO temp
        [self addSubview:_playerLevelView];

        _playerExpLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0 , 0, _playerLevelBackground.frame.size.width, _playerLevelBackground.frame.size.height*2)];
        _playerExpLabel.center = CGPointMake(_playerLevelBackground.center.x, _playerLevelBackground.frame.size.height * 6 / 10);
        //playerExpLabel.text = [NSString stringWithFormat:@"%ld/%ld", userXP, userMaxXP];
        _playerExpLabel.textAlignment = NSTextAlignmentCenter;
        _playerExpLabel.textColor = [UIColor whiteColor];
        int fontSize = MAX(self.frame.size.height / 2, 1);
        _playerExpLabel.font = [UIFont fontWithName:cardMainFontBlack size:fontSize];
        _playerExpLabel.strokeColour = [UIColor blackColor];
        _playerExpLabel.strokeThickness = MAX(fontSize/10, 1);
        _playerExpLabel.strokeOn = YES;
        [self addSubview:_playerExpLabel];
        
        
    }
    return self;
}

-(void)updateValue:(long)value
{
    if (value == -1)
    {
        [_playerLevelView setFrame:CGRectMake(2, 2, _playerLevelBackground.frame.size.width - 4, _playerLevelBackground.frame.size.height - 4)];
        _playerExpLabel.text = [NSString stringWithFormat:@"%ld/%ld", _maxValue, _maxValue];
    }
    else if (_maxValue <= 0) //empty bar
    {
        _playerLevelView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        _playerExpLabel.text = [NSString stringWithFormat:@"%d/%ld", 0, _maxValue];
    }
    else //normal case
    {
        int maxWidth = _playerLevelBackground.frame.size.width - 4;
        [_playerLevelView setFrame:CGRectMake(2, 2, (int)((double)value/_maxValue*maxWidth), _playerLevelBackground.frame.size.height - 4)];
        _playerExpLabel.text = [NSString stringWithFormat:@"%ld/%ld", value, _maxValue];
    }
}

/*
 playerLevelBackground = [[UIImageView alloc]initWithFrame:CGRectMake(115, 50, self.frame.size.width - 115 - 10, 15)];
 [self setBackgroundColor:COLOUR_DARK]; //TODO temp
 
 /*
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
 [backgroundView addSubview:playerLevelView];*/

@end
