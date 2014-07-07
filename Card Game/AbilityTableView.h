//
//  AbilityView.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-29.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardModel.h"
@class CardEditorViewController;

@interface AbilityTableView :UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong) UITableView *tableView;

/** Stores Ability's */
@property (strong) NSMutableArray *currentAbilities;

@property (strong) CardEditorViewController*cevc;

@property enum AbilityTableViewMode viewMode;

@property (strong) CardModel*currentCard;

- (id)initWithFrame:(CGRect)frame mode:(enum AbilityTableViewMode)viewMode;

-(void)removeCellAt:(int)index;

-(void)removeAllCells;


@end


enum AbilityTableViewMode
{
    abilityTableViewExisting,
    abilityTableViewNew,
};