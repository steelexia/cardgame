//
//  MoveHistoryTableView.m
//  cardgame
//
//  Created by Steele Xia on 2016-06-18.
//  Copyright © 2016 Content Games. All rights reserved.
//

#import "MoveHistoryTableView.h"
#import "AbilityWrapper.h"
#import "CardView.h"
#import "MoveHistoryTableViewCell.h"
#import "UIConstants.h"
#import "GameModel.h"

@class SpellCardModel;

@implementation MoveHistoryTableView

@synthesize currentMoveHistories = _currentMoveHistories;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        [_tableView setBackgroundColor:[UIColor clearColor]];

        //_tableView.separatorColor = COLOUR_INTERFACE_GRAY_TRANSPARENT;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        // _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.allowsSelection = NO;
        
        [_tableView registerClass:[MoveHistoryTableViewCell class] forCellReuseIdentifier:@"moveHistoryTableViewCell"];
        
        //[_tableView setBackgroundColor:COLOUR_INTERFACE_BLUE];
        _tableView.rowHeight = 200;
        
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        _tableView.allowsMultipleSelection = NO;
        
        //[self setUserInteractionEnabled:YES];
        [self addSubview:_tableView];
        
        _currentMoveHistories = [NSMutableArray array];
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_currentMoveHistories count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MoveHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"moveHistoryTableViewCell" forIndexPath:indexPath];
    
    
    MoveHistory *moveHistory = _currentMoveHistories[indexPath.row];
    
    if (moveHistory.side == OPPONENT_SIDE)
        [cell setBackgroundColor:COLOUR_ENEMY_TRANSPARENT];
    else
        [cell setBackgroundColor:COLOUR_FRIENDLY_TRANSPARENT];
    
    cell.moveHistory = moveHistory;
    //[cell setText:@"TEST"];
    
    CardModel*casterCard = moveHistory.caster;
    CardView*casterCardView = [[CardView alloc] initWithModel:casterCard viewMode:cardViewModeEditor];
    
    [casterCardView updateView];
    casterCardView.center = CGPointMake(casterCardView.frame.size.width/2 + 10, cell.frame.size.height/2);
    [cell addSubview:casterCardView];

    //TODO
    
    return cell;
}


@end
