//
//  BossBattleScreenViewController.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-17.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "BossBattleScreenViewController.h"
#import "UIConstants.h"
#import "CFLabel.h"
#import "CFButton.h"
#import "StrokedLabel.h"

@interface BossBattleScreenViewController ()

@end
/** Screen dimension for convinience */
int SCREEN_WIDTH, SCREEN_HEIGHT;

@implementation BossBattleScreenViewController

- (id)init
{
    self = [super init];
    if (self) {
        _message = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    UIColor *bgCol = COLOUR_BACKGROUND_GRAY;
    [self.view setBackgroundColor:bgCol];
    
    CFLabel *messageLabel = [[CFLabel alloc] initWithFrame:CGRectMake(20,SCREEN_HEIGHT/4, SCREEN_WIDTH-40, SCREEN_HEIGHT/2)];
    messageLabel.label.text = _message;
    [messageLabel setTextSize:20];
    
    [self.view addSubview:messageLabel];
    
    CFButton*continueButton = [[CFButton alloc] initWithFrame:CGRectMake(0,0,80,40)];
    continueButton.label.text = @"Continue";
    continueButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-60);
    [continueButton addTarget:self action:@selector(continueButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
}

-(void)continueButtonPressed
{
    [self presentViewController:_nextScreen animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
