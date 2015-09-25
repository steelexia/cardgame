
//
//  OptionsViewController.m
//  cardgame
//
//  Created by Steele on 2014-09-01.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "OptionsViewController.h"
#import "UserModel.h"
#import "PasswordViewController.h"

@interface OptionsViewController ()

@end

@implementation OptionsViewController

int SCREEN_WIDTH, SCREEN_HEIGHT;


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    CFLabel*menuLogoBackground = [[CFLabel alloc] initWithFrame:CGRectMake(0,0,250,60)];
    menuLogoBackground.center = CGPointMake(SCREEN_WIDTH/2, 70);
    menuLogoBackground.label.textAlignment = NSTextAlignmentCenter;
    [menuLogoBackground setTextSize:30];
    menuLogoBackground.label.text = @"Options";
    [self.view addSubview:menuLogoBackground];
    
    UIButton* backButton = [[CFButton alloc] initWithFrame:CGRectMake(35, SCREEN_HEIGHT - 32 - 20, 46, 32)];
    [backButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    
    _passwordButton = [[CFButton alloc] initWithFrame:CGRectMake(0,0,140,50)];
    [_passwordButton setTextSize:16];
    if ([userPF[@"passwordSetup"] boolValue])
    {
        _passwordButton.label.text = @"Change Password";
    }
    else
    {
        _passwordButton.label.text = @"Setup Password";
    }
    
    [_passwordButton addTarget:self action:@selector(passwordButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    _passwordButton.center = CGPointMake(SCREEN_WIDTH/2, 100 + 20 + 25 );
    [self.view addSubview:_passwordButton];
    
    _logoutButton = [[CFButton alloc] initWithFrame:CGRectMake(0,0,140,50)];
    [_logoutButton setTextSize:16];
    _logoutButton.label.text = @"Logout";
    [_logoutButton addTarget:self action:@selector(logoutButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    _logoutButton.center = CGPointMake(SCREEN_WIDTH/2, 100 + 20 + 25 + 75 * 1 );
    [self.view addSubview:_logoutButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([userPF[@"passwordSetup"] boolValue] == YES)
        _passwordButton.label.text = @"Change Password";
    else
        _passwordButton.label.text = @"Setup Password";
}

-(void)passwordButtonPressed
{
    PasswordViewController *pvc = [[PasswordViewController alloc] initWithIsSetup:[userPF[@"passwordSetup"] boolValue]];
    [self presentViewController:pvc animated:NO completion:nil];
}

-(void)setupPasswordPressed
{
    PasswordViewController *pvc = [[PasswordViewController alloc] initWithIsSetup:YES];
    [self presentViewController:pvc animated:NO completion:nil];
}

-(void)logoutButtonPressed
{
   // [PFUser logOut];
    [UserModel logout];
    [SSKeychain deletePasswordForService:@"com.contentgames.cardgame" account:@"username"];
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backButtonPressed
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
