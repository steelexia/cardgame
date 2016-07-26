//
//  CFExpBar.h
//  cardgame
//
//  Created by Steele Xia on 2016-07-22.
//  Copyright © 2016 Content Games. All rights reserved.
//

#import "StrokedLabel.h"

@interface CFExpBar : UIView

@property long maxValue;

@property (strong) UIImageView*playerLevelBackground, *playerLevelView;

@property (strong)StrokedLabel*playerExpLabel;

-(void)updateValue:(long)value;

@end