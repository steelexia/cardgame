//
//  StoreCardCell.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-02.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "StoreCardCell.h"
#import "CardView.h"

@implementation StoreCardCell

@synthesize cardView = _cardView;
@synthesize costLabel = _costLabel;
@synthesize likesLabel = _likesLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _cardView = nil;
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.frame = CGRectMake(0,0,50,50);
        _activityView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        //_activityView.backgroundColor = [UIColor blackColor];
        [self addSubview:_activityView];
        [_activityView startAnimating];
        
        _costLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 30)];
        _costLabel.textColor = [UIColor yellowColor];
        _costLabel.textAlignment = NSTextAlignmentLeft;
        _costLabel.font = [UIFont fontWithName:cardMainFont size:26];
        _costLabel.center = CGPointMake(frame.size.width/2 + 40, frame.size.height - 60);
        //[self addSubview:_costLabel];
        
        _likesLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 30)];
        _likesLabel.textColor = [UIColor blackColor];
        _likesLabel.textAlignment = NSTextAlignmentLeft;
        _likesLabel.font = [UIFont fontWithName:cardMainFont size:26];
        _likesLabel.text = @"0";
        _likesLabel.center = CGPointMake(frame.size.width/2 + 40, frame.size.height - 30);
        //[self addSubview:_likesLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
