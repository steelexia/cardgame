//
//  CFPopupViewController.m
//  cardgame
//
//  Created by Brian Allen on 1/31/16.
//  Copyright © 2016 Content Games. All rights reserved.
//

#import "CFPopupViewController.h"

@interface CFPopupViewController ()

@end

@implementation CFPopupViewController

//dimensions
float width = 200;
float height = 400;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    //customize popup position by screen size.
    float SCREEN_WIDTH = self.view.bounds.size.width;
    float SCREEN_HEIGHT = self.view.bounds.size.height;
    
    //set Darcy popup Art as the background View
    self.bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FeaturedStoreDialog"]];
    
    float popupWidth = (300.0f/320.0f)*SCREEN_WIDTH;
    float popupHeight = (400.0f/960.0f)*SCREEN_HEIGHT;
   
    
    [self.bgImageView setFrame:CGRectMake((SCREEN_WIDTH-popupWidth)/2,(SCREEN_HEIGHT-popupHeight)/2,popupWidth,popupHeight)];
    
    [self.view addSubview:self.bgImageView];
    
    
    UILabel *popupTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,20,self.bgImageView.frame.size.width,50)];
    popupTitle.text = self.popupTitle;
    popupTitle.textAlignment = NSTextAlignmentCenter;
    
    [self.bgImageView addSubview:popupTitle];
    
    UILabel *popupDescription = [[UILabel alloc] initWithFrame:CGRectMake(32,50,self.bgImageView.frame.size.width-64,self.bgImageView.frame.size.height-80)];
    popupDescription.text = self.popupMessage;
    popupDescription.numberOfLines = 4;
    popupDescription.textAlignment = NSTextAlignmentCenter;
    
    [self.bgImageView addSubview:popupDescription];
    
    //button height/width
    float buttonWidth = 100.0f/320.0f*SCREEN_WIDTH;
    float buttonHeight = 80.0f/960.0f*SCREEN_HEIGHT;
    
    //place dismiss button centered near bottom of bgImageView
    UIButton *popupDismissButton = [[UIButton alloc] initWithFrame:CGRectMake((popupWidth-buttonWidth)/2,popupHeight-buttonHeight,buttonWidth,buttonHeight)];
    popupDismissButton.backgroundColor = [UIColor redColor];
    
    //[popupDismissButton addTarget:self action:@selector(pressedDismiss) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OverLayDidTap:)];
    
    tapRecog.numberOfTapsRequired = 1;
    
    [self.view addGestureRecognizer:tapRecog];
    
    [self.bgImageView addSubview:popupDismissButton];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)OverLayDidTap:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
