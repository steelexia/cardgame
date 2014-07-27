//
//  AbilityView.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-29.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "AbilityTableView.h"
#import "AbilityWrapper.h"
#import "CardView.h"
#import "AbilityTableViewCell.h"
#import "CardEditorViewController.h"

@implementation AbilityTableView

@synthesize currentAbilities = _currentAbilities;

const int ABILITY_TABLE_VIEW_ROW_HEIGHT = 20;

- (id)initWithFrame:(CGRect)frame mode:(enum AbilityTableViewMode)viewMode
{
    self = [super initWithFrame:frame];
    if (self) {
        self.viewMode = viewMode;
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        
        //_tableView.separatorColor = [UIColor clearColor];
        //_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        [_tableView registerClass:[AbilityTableViewCell class] forCellReuseIdentifier:@"abilityTableCell"];

        //[_tableView setBackgroundColor:COLOUR_INTERFACE_BLUE];
        _tableView.rowHeight = ABILITY_TABLE_VIEW_ROW_HEIGHT;
        
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        
        [self setUserInteractionEnabled:YES];
        [self addSubview:_tableView];
        
        _currentAbilities = [NSMutableArray array];
    }
    return self;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentAbilities count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AbilityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"abilityTableCell" forIndexPath:indexPath];
    
    AbilityWrapper*wrapper = self.currentAbilities[indexPath.row];
    
    if (wrapper.enabled)
        [cell.abilityText setTextColor:[UIColor blackColor]];
    
    /*
     ios 7 only
     NSDictionary *userAttributes = @{NSFontAttributeName: font,
     NSForegroundColorAttributeName: [UIColor blackColor]};
     NSString *text = @"hello";
     ...
     const CGSize textSize = [text sizeWithAttributes: userAttributes];
     */
    
    NSAttributedString*abilityText = [Ability getDescription:wrapper.ability fromCard:self.currentCard];
    
    CGSize textSize = [[abilityText string] sizeWithFont:[cell.abilityText font]];
    cell.abilityText.attributedText = abilityText;
    cell.abilityText.frame = CGRectMake(50,0,textSize.width, cell.bounds.size.height);
    cell.abilityMinCost.text = [NSString stringWithFormat:@"%d", wrapper.minCost];
    cell.abilityPoints.text = [NSString stringWithFormat:@"%d", wrapper.minPoints];
    cell.scrollView.frame = cell.bounds;
    [cell.scrollView setContentSize:CGSizeMake(textSize.width + 50, cell.bounds.size.height)];
    [cell.scrollView setContentOffset:CGPointMake(0,0)];
    
    if (!wrapper.enabled)
    [cell.abilityText setTextColor:[UIColor lightGrayColor]];
    
    /*
    NSLog(@"cell %@ scroll %@ text %@", cell.bounds, cell.scrollView.contentSize, cell.abilityText.frame);
     */
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.cevc rowSelected:self indexPath:indexPath];
}

-(void)removeCellAt:(int)index {
    if (index < self.currentAbilities.count)
    {
        [self.currentAbilities removeObjectAtIndex:index];
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

-(void)removeAllCells
{
    [self.currentAbilities removeAllObjects];
    [self.tableView reloadData];
}


@end
