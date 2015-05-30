//
//  LeaderboardsViewController.h
//  cardgame
//
//  Created by Brian Allen on 2015-05-24.
//  Copyright (c) 2015 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CFButton.h"
#import "CFLabel.h"

@interface LeaderboardsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong,nonatomic) UITableView *leaderboardTableView;
@property (strong,nonatomic) NSArray *playersArray;


@end
