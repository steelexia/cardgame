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
#import "StrokedLabel.h"
#import "CardModel.h"
#import "CustomTableView.h"

@class SpellCardModel;

@implementation MoveHistoryTableView

@synthesize currentMoveHistories = _currentMoveHistories;

int CELL_HEIGHT;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[CustomTableView alloc] initWithFrame:self.bounds];
        [_tableView setBackgroundColor:[UIColor clearColor]];

        //_tableView.separatorColor = COLOUR_INTERFACE_GRAY_TRANSPARENT;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        // _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.allowsSelection = NO;
        
        [_tableView registerClass:[MoveHistoryTableViewCell class] forCellReuseIdentifier:@"moveHistoryTableViewCell"];
        
        //[_tableView setBackgroundColor:COLOUR_INTERFACE_BLUE];
        CELL_HEIGHT = CARD_HEIGHT + 10 + 10;
        _tableView.rowHeight = CELL_HEIGHT;
        
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        _tableView.allowsMultipleSelection = NO;
        
        //[self setUserInteractionEnabled:YES];
        [self addSubview:_tableView];
        
        _currentMoveHistories = [NSMutableArray array];
        
        //set up UI
        _darkFilter = [[UIView alloc] initWithFrame:_tableView.bounds];
        _darkFilter.backgroundColor = [[UIColor alloc]initWithHue:0 saturation:0 brightness:0 alpha:0.8];
        [_darkFilter setUserInteractionEnabled:YES]; //blocks all interaction behind it
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_currentMoveHistories count];
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MoveHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"moveHistoryTableViewCell" forIndexPath:indexPath];
    //MoveHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"moveHistoryTableViewCell"];
    
    /*
    if (cell == nil)
    {
        cell = [[MoveHistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"moveHistoryTableViewCell"];
        NSLog(@"CELL IS NIL????????????????????????????");
    }*/
    
    MoveHistory *moveHistory = _currentMoveHistories[_currentMoveHistories.count - indexPath.row - 1];
    
    if (moveHistory.side == OPPONENT_SIDE)
        [cell setBackgroundColor:COLOUR_ENEMY_TRANSPARENT];
    else
        [cell setBackgroundColor:COLOUR_FRIENDLY_TRANSPARENT];
    
    cell.moveHistory = moveHistory;
    //[cell setText:@"TEST"];
    
    CardModel*casterCard = moveHistory.caster;
    CardView*oldCardView = casterCard.cardView;
    CardView*casterCardView;
    
    if (cell.cardViews != nil)
    {
        for (CardView*cardView in cell.cardViews)
        {
            [cardView removeFromSuperview];
        }
    }
    
    cell.cardViews = [NSMutableArray array];
    casterCardView = [[CardView alloc] initWithModel:casterCard viewMode:cardViewModeEditor];
    [cell.cardViews addObject:casterCardView];
    casterCard.cardView = oldCardView;
    casterCardView.cardViewState = cardViewStateNone;
    
    [casterCardView updateView];
    casterCardView.center = CGPointMake(casterCardView.frame.size.width/2 + 10, cell.frame.size.height/2);
    //UIView*valueView = [self getViewForValue:moveHistory.casterValue withCardModel:casterCardView.cardModel];
    //[casterCardView addSubview:valueView];
    //casterCardView.moveHistoryValueView = valueView;
    //valueView.center = CGPointMake(casterCardView.bounds.size.width/2, casterCardView.bounds.size.height/2);
    
    [casterCardView setCardOverlayText:moveHistory.casterValue];
    [casterCardView setCardOverlayObject:cardOverlayObjectText]; //do not need to check if dead
    
    [cell addSubview:casterCardView];
    //NSLog(@"%@", cell);


    //taget cards
    //wont draw more than 20 correctly, but logically there can only be 12 on board at once
    
    int targetCardsCount = MIN((int)moveHistory.targets.count, 20);
    
    if (targetCardsCount > 0)
    {
        if (cell.targetCardsView == nil)
        {
            cell.targetCardsView = [[UIView alloc] initWithFrame:CGRectMake(10 + CARD_WIDTH + 30, 10, cell.bounds.size.width - (10 + CARD_WIDTH + 30) - 10, cell.bounds.size.height - 10 - 10)];
            [cell addSubview:cell.targetCardsView];
        }
        
        UIView*targetCardsView = cell.targetCardsView;
        
        //[targetCardsView setBackgroundColor:COLOUR_FIRE];
        //calculate how many columns needed
        int currentColumnCount = 1;
        int cardsPerColumn = 1;

        while(true)
        {
            //current cards per column, may be too many
            cardsPerColumn = ceil((float)targetCardsCount / currentColumnCount);
            int totalWidth = (cardsPerColumn * (CARD_WIDTH / currentColumnCount)) + (cardsPerColumn-1)*10;
            
            //current column count fits
            if (totalWidth < targetCardsView.bounds.size.width)
            {
                break;
            }
            //current column count doesn't fit, increase column count
            else
            {
                currentColumnCount++;
            }
        }
        
        //fill as many cards possible per column
        cardsPerColumn = (targetCardsView.bounds.size.width + 10) / (CARD_WIDTH / currentColumnCount + 10);
        
        float cardScale = 1.0f / currentColumnCount;
        int cardWidth = CARD_WIDTH / currentColumnCount;
        
        for (int i = 0; i < targetCardsCount; i++)
        {
            int row = i % cardsPerColumn;
            int column = i / cardsPerColumn;
            
            CardModel*targetCard = moveHistory.targets[i];
            CardView*oldCardView = targetCard.cardView;
            CardView*targetCardView = [[CardView alloc] initWithModel:targetCard viewMode:cardViewModeEditor];
            [cell.cardViews addObject:targetCardView];
            targetCard.cardView = oldCardView;
            targetCardView.cardViewState = cardViewStateNone;
            
            [targetCardView updateView];
            
            /*UIView*valueView = [self getViewForValue:moveHistory.targetsValues[i] withCardModel:targetCardView.cardModel];
            [targetCardView addSubview:valueView];
            targetCardView.moveHistoryValueView = valueView;
            valueView.center = CGPointMake(targetCardView.bounds.size.width/2, targetCardView.bounds.size.height/2);*/
            
            [targetCardView setCardOverlayText:moveHistory.targetsValues[i]];
            [targetCardView setCardOverlayObject:cardOverlayObjectText]; //do not need to check if dead
            
            
            if (targetCard.type == cardTypePlayer)
                [targetCardView setZoomScale:cardScale * 1.6f];
            else
                [targetCardView setZoomScale:cardScale];
            
            targetCardView.center = CGPointMake(row * (cardWidth + 10) + cardWidth/2, targetCardsView.bounds.size.height / (currentColumnCount + 1) * (column + 1));
            [targetCardsView addSubview:targetCardView];
        }
    }
    
    return cell;
}

/*
-(UIView*)getViewForValue:(NSString*)value withCardModel:(CardModel*)cardModel
{
    if (value == MOVE_HISTORY_VALUE_DEATH)
    {
        UIImageView* killView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,killHintImage.size.width,killHintImage.size.height)];
        [killView setImage:killHintImage];
        
        return killView;
    }
    else
    {
        StrokedLabel* label = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
        label.text = value;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:cardMainFontBlack size:50];
        label.strokeColour = [UIColor blackColor];
        label.strokeThickness = 6;
        label.strokeOn = YES;
    
        //player views use a different scale
        if (cardModel.type == cardTypePlayer)
            label.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6f, 0.6f);
    
        //TODO probably need a graphic here (i.e. background for the text)
        return label;
    }
}*/


-(void)darkenScreen
{
    _darkFilter.alpha = 0;
    [_tableView addSubview:_darkFilter];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _darkFilter.alpha = 0.9;
                     }
                     completion:nil];
}

-(void)undarkenScreen
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _darkFilter.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [_darkFilter removeFromSuperview];
                     }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.superview)
        [self.superview touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.superview)
        [self.superview touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.superview)
    {
        [self.superview touchesEnded:touches withEvent:event];
    }
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.superview)
        [self.superview touchesCancelled:touches withEvent:event];
}



@end
