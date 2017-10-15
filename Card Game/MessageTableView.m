//
//  MessageTableView.m
//  cardgame
//
//  Created by Steele on 2014-08-31.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "MessageTableView.h"
#import "MessagesViewController.h"
#import "UIConstants.h"
#import "GameInfoTableViewCell.h"
#import "MessageModel.h"

@implementation MessageTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentMessages = [NSMutableArray array];
        
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        
        [_tableView setBackgroundColor:[UIColor clearColor]];
        
        _tableView.rowHeight = 20;
        [_tableView registerClass:[GameInfoTableViewCell class] forCellReuseIdentifier:@"messageTableCell"];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.separatorColor = COLOUR_INTERFACE_GRAY_TRANSPARENT;
        
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        
        [_tableView setUserInteractionEnabled:YES];
        [self setUserInteractionEnabled:YES];
        [self addSubview:_tableView];
    }
    return self;
}

-(long)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentMessages count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageTableCell" forIndexPath:indexPath];
    
    /*
     ios 7 only
     NSDictionary *userAttributes = @{NSFontAttributeName: font,
     NSForegroundColorAttributeName: [UIColor blackColor]};
     NSString *text = @"hello";
     ...
     const CGSize textSize = [text sizeWithAttributes: userAttributes];
     */
    
    PFObject *message = self.currentMessages[indexPath.row];
    NSString*text = [message objectForKey:@"title"];
    
    
    [cell.abilityText setFont: [UIFont fontWithName:cell.abilityText.font.familyName size:16]];
    CGSize textSize = [text sizeWithFont:[cell.abilityText font]];
    [cell.abilityText setTextColor:[UIColor whiteColor]];
    cell.abilityText.text = text;
    cell.abilityText.frame = CGRectMake(0,0,textSize.width, cell.bounds.size.height);
    cell.scrollView.frame = CGRectInset(cell.bounds,1.5,0);
    [cell.scrollView setContentSize:CGSizeMake(textSize.width, cell.bounds.size.height)];
    [cell.scrollView setContentOffset:CGPointMake(0,0)];
    [cell setUserInteractionEnabled:YES];
    UIView *selectedView = [[UIView alloc]initWithFrame:self.bounds];
    [selectedView setBackgroundColor:COLOUR_INTERFACE_BLUE_TRANSPARENT];
    [cell setSelectedBackgroundView:selectedView];
    
    
    NSNumber *checkNumber = [NSNumber numberWithInteger:indexPath.row];
    if([self.readMessages containsObject:checkNumber])
    {
        [cell.abilityText setTextColor:[UIColor grayColor]];
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([_parent isKindOfClass:[MessagesViewController class]])
    {
        GameInfoTableViewCell *cell = (GameInfoTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        MessagesViewController *mvc = (MessagesViewController*)_parent;
        PFObject *message = self.currentMessages[indexPath.row];
        UIColor *cellTextColor = [UIColor grayColor];
        
        
        if(cell.abilityText.textColor ==cellTextColor)
        {
            //do nothing
            return;
        }
       
        [mvc selectedMessage:message];
        
        NSNumber *msgReadIndex = [NSNumber numberWithInteger:indexPath.row];
        
        [self.readMessages addObject:msgReadIndex];
        
        cell.abilityText.textColor = [UIColor grayColor];
        
    }
}

-(void)removeCellAt:(int)index {
    if (index < self.currentMessages.count)
    {
        [self.currentMessages removeObjectAtIndex:index];
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

-(void)removeAllCells
{
    [self.currentMessages removeAllObjects];
    [self.tableView reloadData];
}


@end
