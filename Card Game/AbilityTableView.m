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
#import "UIConstants.h"

@class SpellCardModel;

@implementation AbilityTableView

@synthesize currentAbilities = _currentAbilities;

const int ABILITY_TABLE_VIEW_ROW_HEIGHT = 25;
int ABILITY_TABLE_VIEW_ROW_WIDTH;

- (id)initWithFrame:(CGRect)frame mode:(enum AbilityTableViewMode)viewMode
{
    self = [super initWithFrame:frame];
    if (self) {
        self.viewMode = viewMode;
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        ABILITY_TABLE_VIEW_ROW_WIDTH = frame.size.width;
        //_tableView.separatorColor = COLOUR_INTERFACE_GRAY_TRANSPARENT;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
       // _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        [_tableView registerClass:[AbilityTableViewCell class] forCellReuseIdentifier:@"abilityTableCell"];

        //[_tableView setBackgroundColor:COLOUR_INTERFACE_BLUE];
        _tableView.rowHeight = ABILITY_TABLE_VIEW_ROW_HEIGHT;
        
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        _tableView.allowsMultipleSelection = NO;
        
        [self setUserInteractionEnabled:YES];
        [self addSubview:_tableView];
        
        _currentAbilities = [NSMutableArray array];
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentAbilities count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 34.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AbilityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"abilityTableCell" forIndexPath:indexPath];
    
    AbilityWrapper*wrapper = self.currentAbilities[indexPath.row];
    
    if (wrapper.enabled)
        [cell.abilityText setTextColor:[UIColor whiteColor]];
    
    /*
     ios 7 only
     NSDictionary *userAttributes = @{NSFontAttributeName: font,
     NSForegroundColorAttributeName: [UIColor blackColor]};
     NSString *text = @"hello";
     ...
     const CGSize textSize = [text sizeWithAttributes: userAttributes];
     */
    
    NSAttributedString*abilityText = [Ability getDescription:wrapper.ability fromCard:self.currentCard];
    //NSLog(@"current card is spell card? %d", [self.currentCard isKindOfClass:[SpellCardModel class]]);
    
    CGSize textSize = [[abilityText string] sizeWithFont:[cell.abilityText font]];
    cell.abilityText.attributedText = abilityText;
    cell.abilityText.frame = CGRectMake(60,0,ABILITY_TABLE_VIEW_ROW_WIDTH * 3 / 4, cell.bounds.size.height);
    [cell.abilityText setNumberOfLines:2];
    [cell.abilityText setTextColor:[UIColor whiteColor]];
    cell.abilityMinCost.text = [NSString stringWithFormat:@"%d", wrapper.minCost];
    [cell.abilityMinCost setTextColor:[UIColor whiteColor]];
    cell.abilityPoints.text = [NSString stringWithFormat:@"%d", wrapper.currentPoints];
    cell.scrollView.frame = cell.bounds;
    [cell.scrollView setContentSize:CGSizeMake(textSize.width + 50, cell.bounds.size.height)];
    [cell.scrollView setContentOffset:CGPointMake(0,0)];
    
    //ability too expensive to add
    if ((self.cevc.maxCost - self.cevc.currentCost) < wrapper.currentPoints)
    {
        cell.abilityPoints.textColor = [UIColor redColor];
    }
    //ability would take penalty when added
    else if (wrapper.currentPoints > wrapper.basePoints)
    {
        cell.abilityPoints.textColor = [UIColor orangeColor];
    }
    //ability would take bonus when added
    else if (wrapper.currentPoints < wrapper.basePoints)
    {
        cell.abilityPoints.textColor = [UIColor greenColor];
    }
    else
    {
        cell.abilityPoints.textColor = [UIColor whiteColor];
    }
    
    if (!wrapper.enabled){
        [cell.abilityText setTextColor:COLOUR_INTERFACE_GRAY_TRANSPARENT];
        
        //mana icon becomes red if too mana too high for card
        if (wrapper.minCost > self.cevc.currentCardModel.cost)
        {
            [cell.abilityMinCost setTextColor:COLOUR_INTERFACE_RED];
        }
        
        
        [cell setUserInteractionEnabled:NO];
    }else{
        [cell setUserInteractionEnabled:YES];
    }
    
    [cell.abilityIconType setCenter:CGPointMake(ABILITY_TABLE_VIEW_ROW_WIDTH - ABILITY_TABLE_VIEW_ROW_HEIGHT/2 -5, ABILITY_TABLE_VIEW_ROW_HEIGHT/2 +5)];
    
    /*
    if (indexPath.row %2) {
        [cell.abilityIconType setImage:[UIImage imageNamed:@"CardCreateIconMute"]];
    }else{
        [cell.abilityIconType setImage:[UIImage imageNamed:@"CardCreateIconNinja"]];
    }*/
    
    /*
    NSLog(@"cell %@ scroll %@ text %@", cell.bounds, cell.scrollView.contentSize, cell.abilityText.frame);
     */
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.cevc rowSelected:self indexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.cevc rowDeselected:self];
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
