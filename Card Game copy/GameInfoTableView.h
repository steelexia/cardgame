//
//  GameInfoTableView.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-07-07.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardModel.h"

@interface GameInfoTableView :UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong) UITableView *tableView;

/** Stores Ability's */
@property (strong) NSMutableArray *currentStrings;
@property (strong)UILabel*titleLabel;

- (id)initWithFrame:(CGRect)frame withTitle:(NSString*)title;

-(void)removeCellAt:(int)index;

-(void)removeAllCells;


@end
