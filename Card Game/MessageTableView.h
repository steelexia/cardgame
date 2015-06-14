//
//  MessageTableView.h
//  cardgame
//
//  Created by Steele on 2014-08-31.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameInfoTableViewCell.h"
#import "UIConstants.h"
#import "MessageModel.h"

@interface MessageTableView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong) UITableView *tableView;

@property (strong) NSMutableArray *currentMessages;
@property (strong) UIViewController*parent;
@property (strong) NSMutableArray *readMessages;

-(void)removeCellAt:(int)index;

-(void)removeAllCells;


@end
