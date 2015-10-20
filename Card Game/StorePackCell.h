//
//  StorePackCell.h
//  cardgame
//
//  Created by Emiliano Barcia on 10/19/15.
//  Copyright © 2015 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PackView.h"

@interface StorePackCell : UICollectionViewCell

@property (strong) PackView *packView;

- (id)initWithFrame:(CGRect)frame;

@end
