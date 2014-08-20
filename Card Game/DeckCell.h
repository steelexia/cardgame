//
//  DeckCell.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-02.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrokedLabel.h"

@interface DeckCell : UITableViewCell

@property (strong) StrokedLabel * nameLabel;
@property (strong) StrokedLabel* invalidLabel;
@property (strong) NSMutableArray* elementIcons;

@end
