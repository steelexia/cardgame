//
//  CampaignMenuViewController.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-12.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CampaignMenuViewController.h"
#import "Campaign.h"

@interface CampaignMenuViewController ()

@end

int SCREEN_WIDTH, SCREEN_HEIGHT;

@implementation CampaignMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
    _difficultyButtons = [NSMutableArray arrayWithCapacity:3];
    
    CGSize difficultyTabSize = CGSizeMake(100, 40);
    
    for (int i = 0; i < NUMBER_OF_DIFFICULTIES; i++)
    {
        double distanceFromCenter = i - NUMBER_OF_DIFFICULTIES/2.f;
        UIButton*difficultyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2 + distanceFromCenter * difficultyTabSize.width, difficultyTabSize.height)];
        //diff
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
