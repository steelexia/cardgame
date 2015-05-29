//
//  AutoSizeChatCellTableViewCell.m
//  cardgame
//
//  Created by Brian Allen on 2015-05-29.
//  Copyright (c) 2015 Content Games. All rights reserved.
//

#import "AutoSizeChatCellTableViewCell.h"

@implementation AutoSizeChatCellTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 3;
        self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        //self.textLabel.contentMode = UIViewContentModeTop;
       
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-1-[bodyLabel]-1-|" options:0 metrics:nil views:@{ @"bodyLabel": self.textLabel }]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[bodyLabel]-1-|" options:0 metrics:nil views:@{ @"bodyLabel": self.textLabel }]];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.textLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.textLabel.frame);
}


@end
