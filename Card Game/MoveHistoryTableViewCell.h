//
//  MoveHistoryTableViewCell.h
//  cardgame
//
//  Created by Steele Xia on 2016-06-18.
//  Copyright © 2016 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoveHistory.h"

@interface MoveHistoryTableViewCell : UITableViewCell

@property MoveHistory*moveHistory;
@property int cardIndex;

@end