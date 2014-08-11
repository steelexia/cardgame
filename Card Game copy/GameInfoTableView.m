//
//  GameInfoTableView.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-07-07.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "GameInfoTableView.h"

#import "AbilityTableView.h"
#import "AbilityWrapper.h"
#import "CardView.h"
#import "GameInfoTableViewCell.h"
#import "CardEditorViewController.h"
#import "UIConstants.h"

@implementation GameInfoTableView

@synthesize currentStrings = _currentStrings;

- (id)initWithFrame:(CGRect)frame withTitle:(NSString*)title
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.bounds.size.width,40)];
        self.titleLabel.font = [UIFont fontWithName:cardMainFont size:14];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.text = title;
        [self.titleLabel sizeToFit];
        self.titleLabel.center = CGPointMake(self.bounds.size.width/2, 15);
        
        [self addSubview:self.titleLabel];
        
        CGRect tableViewRect = CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height-40);
        
        _tableView = [[UITableView alloc] initWithFrame:tableViewRect];
        _tableView.bounds = CGRectInset(tableViewRect, -3, -3);
        [_tableView setBackgroundColor:[UIColor whiteColor]];
        
        _tableView.layer.cornerRadius = 4;
        _tableView.layer.borderWidth = 1.5;
        
        _tableView.separatorColor = [UIColor blackColor];
        //_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        [_tableView registerClass:[GameInfoTableViewCell class] forCellReuseIdentifier:@"gameInfoTableCell"];
        
        _tableView.rowHeight = 20;
        
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        
        [self setUserInteractionEnabled:YES];
        [self addSubview:_tableView];
        
        _currentStrings = [NSMutableArray array];
    }
    return self;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentStrings count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gameInfoTableCell" forIndexPath:indexPath];
    
    /*
     ios 7 only
     NSDictionary *userAttributes = @{NSFontAttributeName: font,
     NSForegroundColorAttributeName: [UIColor blackColor]};
     NSString *text = @"hello";
     ...
     const CGSize textSize = [text sizeWithAttributes: userAttributes];
     */
    
    NSString*text = self.currentStrings[indexPath.row];
    
    CGSize textSize = [text sizeWithFont:[cell.abilityText font]];
    cell.abilityText.text = text;
    cell.abilityText.frame = CGRectMake(0,0,textSize.width, cell.bounds.size.height);
    cell.scrollView.frame = CGRectInset(cell.bounds,1.5,0);
    [cell.scrollView setContentSize:CGSizeMake(textSize.width, cell.bounds.size.height)];
    [cell.scrollView setContentOffset:CGPointMake(0,0)];
    
    return cell;
}

-(void)removeCellAt:(int)index {
    if (index < self.currentStrings.count)
    {
        [self.currentStrings removeObjectAtIndex:index];
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

-(void)removeAllCells
{
    [self.currentStrings removeAllObjects];
    [self.tableView reloadData];
}


@end