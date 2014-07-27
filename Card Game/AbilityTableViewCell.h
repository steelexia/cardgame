//
//  AbilityTableViewCell.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-07-06.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomScrollView.h"
#import "StrokedLabel.h"

@interface AbilityTableViewCell : UITableViewCell

@property CustomScrollView*scrollView;
@property UILabel*abilityText;
@property StrokedLabel*abilityMinCost, *abilityPoints;

@end