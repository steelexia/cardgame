//
//  LeaderboardsViewController.m
//  cardgame
//
//  Created by Brian Allen on 2015-05-24.
//  Copyright (c) 2015 Content Games. All rights reserved.
//

#import "LeaderboardsViewController.h"
#import <Parse/Parse.h>

@interface LeaderboardsViewController ()

@end

@implementation LeaderboardsViewController

/** Screen dimension for convinience */
int SCREEN_WIDTH, SCREEN_HEIGHT;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
    //background view
    UIImageView*backgroundImageTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_background_top"]];
    backgroundImageTop.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    [self.view addSubview:backgroundImageTop];
    
    UIImageView*backgroundImageMiddle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_background_center"]];
    backgroundImageMiddle.frame = CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - 40 - 40);
    [self.view addSubview:backgroundImageMiddle];
    
    UIImageView*backgroundImageBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_background_bottom"]];
    backgroundImageBottom.frame = CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, 40);
    [self.view addSubview:backgroundImageBottom];
    
    
    CFLabel*menuLogoBackground = [[CFLabel alloc] initWithFrame:CGRectMake(0,0,250,100)];
    menuLogoBackground.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/4);
    menuLogoBackground.label.textAlignment = NSTextAlignmentCenter;
    [menuLogoBackground setTextSize:30];
    menuLogoBackground.label.text = @"Leaderboards";
    [self.view addSubview:menuLogoBackground];
    
    self.leaderboardTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,SCREEN_HEIGHT-300,SCREEN_WIDTH,300)];
    self.leaderboardTableView.dataSource = self;
    self.leaderboardTableView.delegate = self;
    
    
    [self.view addSubview:self.leaderboardTableView];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    //query in background for PFUser Class
    PFQuery *userQuery = [PFQuery queryWithClassName:@"_User"];
    NSNumber *myComparisonNumber = [NSNumber numberWithInteger:1];
    
    [userQuery whereKey:@"eloRating" greaterThan:myComparisonNumber];
    [userQuery orderByDescending:@"eloRating"];
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.playersArray = objects;
        [self.leaderboardTableView reloadData];
        
    }];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.playersArray.count;    //count number of row from counting array hear cataGorry is An Array
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"leaderboardCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    UILabel *userNameLabel;
    UILabel *userRankLabel;
    UILabel *userEloLabel;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier];
        userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,0,200,50)];
        userRankLabel = [[UILabel alloc] initWithFrame:CGRectMake(2,0,18,50)];
        userEloLabel = [[UILabel alloc] initWithFrame:CGRectMake(255,0,100,50)];
        
        userNameLabel.tag = 1;
        [cell addSubview:userNameLabel];
        userRankLabel.tag = 2;
        [cell addSubview:userRankLabel];
        userEloLabel.tag = 3;
        [cell addSubview:userEloLabel];
        
        
    }
    
    // Here we use the provided setImageWithURL: method to load the web image
    // Ensure you use a placeholder image otherwise cells will be initialized with no image
    PFUser *userObjectAtIndex = [self.playersArray objectAtIndex:indexPath.row];
    NSNumber *playerElo = [userObjectAtIndex objectForKey:@"eloRating"];
    NSString *playerName = [userObjectAtIndex objectForKey:@"username"];
    
    userNameLabel = (UILabel *)[cell viewWithTag:1];
    userRankLabel = (UILabel *)[cell viewWithTag:2];
    userEloLabel = (UILabel *)[cell viewWithTag:3];
    
    NSString *userRankString = [NSString stringWithFormat:@"%ld",indexPath.row+1];
    userRankLabel.text = userRankString;
    userNameLabel.text = playerName;
    userEloLabel.text = [playerElo stringValue];
    
    //cell.textLabel.text =[playerElo stringValue];
    
    
    return cell;
}

@end
