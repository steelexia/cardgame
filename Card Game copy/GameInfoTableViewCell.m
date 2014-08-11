//
//  GameInfoTableViewCell.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-07-07.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "GameInfoTableViewCell.h"
#import "UIConstants.h"
#import "CardView.h"

@implementation GameInfoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectInset(self.bounds,-6,0)];
        [self.scrollView setBackgroundColor:[UIColor clearColor]];
        
        self.abilityText = [[UILabel alloc] initWithFrame:self.scrollView.frame];
        self.abilityText.font = [UIFont fontWithName:cardMainFont size:10];
        self.abilityText.textColor = [UIColor blackColor];
        
        [self.scrollView addSubview: self.abilityText];
        [self addSubview:self.scrollView];
        [self.scrollView setUserInteractionEnabled:YES];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        
        UIView *selectedView = [[UIView alloc]initWithFrame:self.bounds];
        [selectedView setBackgroundColor:[UIColor clearColor]];
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
