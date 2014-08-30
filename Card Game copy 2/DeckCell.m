//
//  DeckCell.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-02.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "DeckCell.h"
#import "UIConstants.h"

#import "CardView.h"

@implementation DeckCell
@synthesize nameLabel = _nameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        UIView *background = [[UIView alloc] initWithFrame:self.bounds];
        [background setBackgroundColor:COLOUR_NEUTRAL];
        background.layer.cornerRadius = 5;
        [background.layer setBorderColor:[UIColor blackColor].CGColor];
        [background.layer setBorderWidth:2];
        self.backgroundColor = [UIColor clearColor];
        
        _nameLabel = [[StrokedLabel alloc]initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height/2)];
        
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont fontWithName:cardMainFont size:12];
        _nameLabel.strokeOn = YES;
        _nameLabel.strokeColour = [UIColor blackColor];
        _nameLabel.strokeThickness = 2;
        _nameLabel.numberOfLines = 1;
        
        _invalidLabel = [[StrokedLabel alloc]initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.size.height/2 - 5, self.bounds.size.width, self.bounds.size.height/2)];
        _invalidLabel.textAlignment = NSTextAlignmentCenter;
        _invalidLabel.textColor = [UIColor redColor];
        _invalidLabel.font = [UIFont fontWithName:cardMainFont size:14];
        _invalidLabel.text = @"INVALID";
        _invalidLabel.strokeOn = YES;
        _invalidLabel.strokeColour = [UIColor blackColor];
        _invalidLabel.strokeThickness = 2;
        
        [self setBackgroundView:background];
        [self addSubview:_nameLabel];
    }
    return self;
}




@end