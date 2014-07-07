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

@implementation AbilityTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.scrollView = [[CustomScrollView alloc]initWithFrame:self.bounds];
        [self.scrollView setBackgroundColor:[UIColor clearColor]];
        
        self.abilityText = [[UILabel alloc] initWithFrame:self.bounds];
        self.abilityText.font = [UIFont fontWithName:cardMainFont size:14];
        self.abilityText.textColor = [UIColor blackColor];
        
        [self.scrollView addSubview: self.abilityText];
        [self addSubview:self.scrollView];
        [self.scrollView setUserInteractionEnabled:YES];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        
        UIView *selectedView = [[UIView alloc]initWithFrame:self.bounds];
        [selectedView setBackgroundColor:COLOUR_INTERFACE_BLUE_TRANSPARENT];
        [self setSelectedBackgroundView:selectedView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
