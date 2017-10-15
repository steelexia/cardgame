//
//  MoveHistoryTableView.h
//  cardgame
//
//  Created by Steele Xia on 2016-06-18.
//  Copyright © 2016 Content Games. All rights reserved.
//


#import <UIKit/UIKit.h>
@class CardModel;
@class CustomTableView;
@class CardView;
//#import "CardModel.h"
//#import "CustomTableView.h"

@interface MoveHistoryTableView :UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong) CustomTableView *tableView;

/** Stores MoveHistory's */
@property (strong) NSMutableArray *currentMoveHistories;

@property (strong) CardView*currentCardView;

@property(strong)UIView*darkFilter;

-(void)darkenScreen;
-(void)undarkenScreen;

@end
