//
//  StoreCardCell.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-02.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardView.h"

@interface StoreCardCell : UICollectionViewCell

@property (strong) CardView*cardView;

@property (strong) UILabel*costLabel, *likesLabel;

@property UIActivityIndicatorView *activityView;

@end
