//
//  AbilityTableViewCell.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-07-06.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "AbilityTableViewCell.h"
#import "UIConstants.h"
#import "CardView.h"
#import "AbilityTableView.h"

@implementation AbilityTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.scrollView = [[CustomScrollView alloc]initWithFrame:self.bounds];
        [self.scrollView setBackgroundColor:[UIColor clearColor]];
        
        int cellHeight = self.bounds.size.height;
        
        self.abilityMinCost = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0,ABILITY_TABLE_VIEW_ROW_HEIGHT,ABILITY_TABLE_VIEW_ROW_HEIGHT)];
        self.abilityMinCost.font = [UIFont fontWithName:cardMainFont size:14];
        self.abilityMinCost.textColor = [UIColor whiteColor];
        self.abilityMinCost.strokeOn = YES;
        self.abilityMinCost.strokeThickness = 2;
        self.abilityMinCost.strokeColour = [UIColor blackColor];
        self.abilityMinCost.textAlignment = NSTextAlignmentCenter;
        self.abilityMinCost.center = CGPointMake(ABILITY_TABLE_VIEW_ROW_HEIGHT/2,ABILITY_TABLE_VIEW_ROW_HEIGHT/2 +5);
        
        UIImageView *resourceIcon = [[UIImageView alloc] initWithImage:RESOURCE_ICON_IMAGE];
        resourceIcon.frame = CGRectMake(0,5,ABILITY_TABLE_VIEW_ROW_HEIGHT, ABILITY_TABLE_VIEW_ROW_HEIGHT);
        
        self.abilityPoints = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0,ABILITY_TABLE_VIEW_ROW_HEIGHT*1.5,ABILITY_TABLE_VIEW_ROW_HEIGHT)];
        self.abilityPoints.font = [UIFont fontWithName:cardMainFont size:14];
        [self.abilityPoints setAdjustsFontSizeToFitWidth:YES];
        [self.abilityPoints setMinimumScaleFactor:8.f/10];
        self.abilityPoints.textColor = [UIColor whiteColor];
        self.abilityPoints.strokeOn = YES;
        self.abilityPoints.strokeThickness = 2;
        self.abilityPoints.strokeColour = [UIColor blackColor];
        self.abilityPoints.textAlignment = NSTextAlignmentCenter;
        self.abilityPoints.center = CGPointMake(ABILITY_TABLE_VIEW_ROW_HEIGHT * 1.7, ABILITY_TABLE_VIEW_ROW_HEIGHT/2 +5);
        
        UIImageView *pointsIcon = [[UIImageView alloc] initWithImage:POINTS_ICON_IMAGE];
        pointsIcon.frame = CGRectMake(0,5,ABILITY_TABLE_VIEW_ROW_HEIGHT, ABILITY_TABLE_VIEW_ROW_HEIGHT);
        pointsIcon.center = CGPointMake(ABILITY_TABLE_VIEW_ROW_HEIGHT * 1.7, ABILITY_TABLE_VIEW_ROW_HEIGHT/2 +5);
        
        //NOTE this frame is changed in tableview
        self.abilityText = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.scrollView.frame.size.width, cellHeight)];
        self.abilityText.font = [UIFont fontWithName:cardFlavourTextFont size:10];
        self.abilityText.textColor = [UIColor whiteColor];
        
        self.abilityIconType = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ABILITY_TABLE_VIEW_ROW_HEIGHT, ABILITY_TABLE_VIEW_ROW_HEIGHT)];
        [self.abilityIconType setCenter:CGPointMake(0 , ABILITY_TABLE_VIEW_ROW_HEIGHT/2 +5)];
        
        
        UIImageView *separator = [[UIImageView alloc] initWithFrame:CGRectMake(0, ABILITY_TABLE_VIEW_ROW_HEIGHT +8, self.scrollView.frame.size.width, 1)];
        [separator setImage:[UIImage imageNamed:@"CardCreateDividers"]];
        
        [self.scrollView addSubview:resourceIcon];
        [self.scrollView addSubview:self.abilityMinCost];
        [self.scrollView addSubview:pointsIcon];
        [self.scrollView addSubview:self.abilityPoints];
        [self.scrollView addSubview:self.abilityText];
        [self.scrollView addSubview:self.abilityIconType];
        [self.scrollView addSubview:separator];
        [self addSubview:self.scrollView];
        [self.scrollView setUserInteractionEnabled:YES];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        
        UIView *selectedView = [[UIView alloc]initWithFrame:self.bounds];
        [selectedView setBackgroundColor:COLOUR_INTERFACE_BLUE_TRANSPARENT];
        [self setSelectedBackgroundView:selectedView];
    }
    return self;
}

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}*/

@end
