//
//  MoveHistoryTableView.h
//  cardgame
//
//  Created by Steele Xia on 2016-06-18.
//  Copyright © 2016 Content Games. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "CardModel.h"

@interface MoveHistoryTableView :UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong) UITableView *tableView;

/** Stores MoveHistory's */
@property (strong) NSMutableArray *currentMoveHistories;

@end
