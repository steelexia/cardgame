//
//  DeckCollectionView.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-25.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "DeckTableView.h"
#import "CardView.h"
#import "DeckModel.h"

@implementation DeckTableView

@synthesize tableView = _tableView;
@synthesize currentCells = _currentCells;
@synthesize viewMode = _viewMode;

const double DECK_EDITOR_CARD_SCALE = 0.6;

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.viewMode = deckTableViewCards;
        
        _tableView = [[CustomTableView alloc] initWithFrame:self.bounds];
        
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"deckTableCardCell"];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"deckTableDeckCell"];
        [_tableView setBackgroundColor:COLOUR_INTERFACE_BLUE];
        _tableView.rowHeight = 40;
        
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        
        [self setUserInteractionEnabled:YES];
        [self addSubview:_tableView];
        
        _currentCells = [NSMutableArray array];
    }
    
    return self;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentCells count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (self.viewMode == deckTableViewCards)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"deckTableCardCell" forIndexPath:indexPath];
        CardView*cardView = self.currentCells[indexPath.row];
        //cardView.frame = CGRectMake(0,0,CARD_FULL_WIDTH,CARD_FULL_HEIGHT);
        cardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, DECK_EDITOR_CARD_SCALE, DECK_EDITOR_CARD_SCALE);
        
        cardView.center = CGPointMake(cell.center.x, 68);
        [cell addSubview:cardView];
    }
    else if (self.viewMode == deckTableViewDecks)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"deckTableDeckCell" forIndexPath:indexPath];
        
        DeckModel*deck = self.currentCells[indexPath.row];
        
        //not a real button, just for the rounded rect look
        UIButton *background = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        background.frame = cell.bounds;
        [background setUserInteractionEnabled:NO];
        [background setBackgroundColor:[UIColor colorWithHue:0.11 saturation:0.36 brightness:0.82 alpha:1]];
        [background.layer setBorderColor:[UIColor blackColor].CGColor];
        [background.layer setBorderWidth:2];
        
        //CGRect nameLabelFrame = ;
        
        StrokedLabel * nameLabel = [[StrokedLabel alloc]initWithFrame:CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y, cell.bounds.size.width, cell.bounds.size.height/2)];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont fontWithName:cardMainFont size:12];
        nameLabel.strokeOn = YES;
        nameLabel.strokeColour = [UIColor blackColor];
        nameLabel.strokeThickness = 2;
        nameLabel.text = deck.name;
        
        [cell addSubview:background];
        [cell addSubview:nameLabel];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    //greatly improves performance but freezes scale?
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return cell;
}

-(void)removeCellAt:(int)index {
    if (index < self.currentCells.count)
    {
        [self.currentCells removeObjectAtIndex:index];
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

-(void)removeAllCells
{
    [self.currentCells removeAllObjects];
    [self.tableView reloadData];
    
    //clear all cells
    //while([self.tableView dequeueReusableCellWithIdentifier:@"deckTableCell"]!=nil);
}

@end
