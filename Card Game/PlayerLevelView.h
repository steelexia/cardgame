//
//  PlayerLevelView.h
//  cardgame
//
//  Created by Steele Xia on 2016-07-13.
//  Copyright © 2016 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CFLabel.h"
#import "CFButton.h"
#import "CFExpBar.h"

@interface PlayerLevelView : UIView

@property BOOL elementViewOpen;
@property (strong) CFLabel*backgroundView, *elementalBackgroundView;
@property (strong) StrokedLabel*playerNameLabel, *playerLevelLabel, *playerLevelLabel2;

@property (strong) UIImageView*playerImageView;
@property (strong) CFButton*playerElementalLevelButton;
@property (strong) CFExpBar*playerExpBar, *playerFireExpBar, *playerIceExpBar,*playerEarthExpBar,*playerLightningExpBar,*playerLightExpBar,*playerDarkExpBar;
@property (strong) StrokedLabel*fireLevelLabel, *iceLevelLabel, *earthLevelLabel, *lightningLevelLabel, *lightLevelLabel, *darkLevelLabel;

@property (strong) NSMutableArray*levelLabelArray, *expBarArray;

-(void)updateValues;

@end
