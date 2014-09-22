//
//  PasswordViewController.m
//  cardgame
//
//  Created by Steele on 2014-09-01.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "PasswordViewController.h"
#import "CardView.h"
#import "UserModel.h"
#import "SSKeychain.h"
#import "LoginViewController.h"

@interface PasswordViewController ()

@end

@implementation PasswordViewController

int SCREEN_WIDTH, SCREEN_HEIGHT;

int MINIMUM_PASSWORD_LENGTH = 6;

- (id)initWithIsSetup:(BOOL)isSetup
{
    self = [super init];
    if (self) {
        _isSetup = isSetup;
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
    menuLogoBackground.label.text = @"Password";
    [self.view addSubview:menuLogoBackground];
    
    if (_isSetup)
    {
        UILabel*oldPasswordFieldLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
        oldPasswordFieldLabel.text = @"Old Password:";
        [oldPasswordFieldLabel setFont:[UIFont fontWithName:cardMainFont size:12]];
        [oldPasswordFieldLabel setTextAlignment:NSTextAlignmentRight];
        oldPasswordFieldLabel.center = CGPointMake(SCREEN_WIDTH/2 - 75, 140);
        [self.view addSubview:oldPasswordFieldLabel];
        
        _passwordOldField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
        _passwordOldField.secureTextEntry = YES;
        [_passwordOldField setFont:[UIFont fontWithName:cardMainFont size:12]];
        _passwordOldField.center = CGPointMake(SCREEN_WIDTH/2 + 65, 140);
        [_passwordOldField setReturnKeyType:UIReturnKeyDone];
        
        CFLabel *oldPasswordFieldBackground = [[CFLabel alloc] initWithFrame:CGRectInset(_passwordOldField.frame, -6, -4)];
        [oldPasswordFieldBackground setBackgroundColor:COLOUR_INTERFACE_BLUE_LIGHT];
        [self.view addSubview:oldPasswordFieldBackground];
        [self.view addSubview:_passwordOldField];
    }
    
    UILabel*newPasswordFieldLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    newPasswordFieldLabel.text = @"New Password:";
    [newPasswordFieldLabel setFont:[UIFont fontWithName:cardMainFont size:12]];
    [newPasswordFieldLabel setTextAlignment:NSTextAlignmentRight];
    newPasswordFieldLabel.center = CGPointMake(SCREEN_WIDTH/2 - 75, 195);
    [self.view addSubview:newPasswordFieldLabel];
    
    _passwordNewField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    _passwordNewField.secureTextEntry = YES;
    [_passwordNewField setFont:[UIFont fontWithName:cardMainFont size:12]];
    _passwordNewField.center = CGPointMake(SCREEN_WIDTH/2 + 65, 195);
    [_passwordNewField setReturnKeyType:UIReturnKeyDone];
    
    CFLabel *newPasswordFieldBackground = [[CFLabel alloc] initWithFrame:CGRectInset(_passwordNewField.frame, -6, -4)];
    [newPasswordFieldBackground setBackgroundColor:COLOUR_INTERFACE_BLUE_LIGHT];
    [self.view addSubview:newPasswordFieldBackground];
    [self.view addSubview:_passwordNewField];
    
    
    UILabel*newConfirmPasswordFieldLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    newConfirmPasswordFieldLabel.text = @"Confirm New Password:";
    [newConfirmPasswordFieldLabel setFont:[UIFont fontWithName:cardMainFont size:12]];
    [newConfirmPasswordFieldLabel setTextAlignment:NSTextAlignmentRight];
    newConfirmPasswordFieldLabel.center = CGPointMake(SCREEN_WIDTH/2 - 75, 250);
    [self.view addSubview:newConfirmPasswordFieldLabel];
    
    _passwordNewConfirmField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    _passwordNewConfirmField.secureTextEntry = YES;
    [_passwordNewConfirmField setFont:[UIFont fontWithName:cardMainFont size:12]];
    _passwordNewConfirmField.center = CGPointMake(SCREEN_WIDTH/2 + 65, 250);
    [_passwordNewConfirmField setReturnKeyType:UIReturnKeyDone];
    
    CFLabel *newConfirmPasswordFieldBackground = [[CFLabel alloc] initWithFrame:CGRectInset(_passwordNewConfirmField.frame, -6, -4)];
    [newConfirmPasswordFieldBackground setBackgroundColor:COLOUR_INTERFACE_BLUE_LIGHT];
    [self.view addSubview:newConfirmPasswordFieldBackground];
    [self.view addSubview:_passwordNewConfirmField];
    
    
    CFButton *confirmButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    confirmButton.label.text = @"Confirm";
    [confirmButton setTextSize:16];
    confirmButton.center = CGPointMake(SCREEN_WIDTH/2 - 55, SCREEN_HEIGHT - 60);
    [confirmButton addTarget:self action:@selector(confirmButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
    
    
    CFButton *cancelButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    cancelButton.label.text = @"Cancel";
    [cancelButton setTextSize:16];
    cancelButton.center = CGPointMake(SCREEN_WIDTH/2 + 55, SCREEN_HEIGHT - 60);
    [cancelButton addTarget:self action:@selector(backButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    
    //---------------activity indicator--------------------//
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_activityIndicator setFrame:self.view.bounds];
    [_activityIndicator setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.5]];
    [_activityIndicator setUserInteractionEnabled:YES];
    _activityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    _activityLabel.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + 60);
    _activityLabel.textAlignment = NSTextAlignmentCenter;
    _activityLabel.textColor = [UIColor whiteColor];
    _activityLabel.font = [UIFont fontWithName:cardMainFont size:20];
    _activityLabel.text = [NSString stringWithFormat:@"Processing..."];
    _activityLabel.numberOfLines = 0;
    [_activityIndicator addSubview:_activityLabel];
    
    _activityFailedButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    _activityFailedButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 60);
    _activityFailedButton.label.text = @"Ok";
    [_activityFailedButton setTextSize:18];
    [_activityFailedButton addTarget:self action:@selector(activityFailedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(tapRegistered)];
    [tapGesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGesture];
}

-(void)tapRegistered
{
    [_passwordOldField resignFirstResponder];
    [_passwordNewField resignFirstResponder];
    [_passwordNewConfirmField resignFirstResponder];
}

-(void)confirmButtonPressed
{
    //passwords don't match
    if (![_passwordNewField.text isEqualToString:_passwordNewConfirmField.text])
    {
        [self showActivityIndicatorWithBlock:^BOOL{
            return NO;
        } loadingText:@"" failedText:@"Your passwords do not match."];
        return;
    }
    
    //password too short
    if (_passwordNewField.text.length < MINIMUM_PASSWORD_LENGTH)
    {
        [self showActivityIndicatorWithBlock:^BOOL{
            return NO;
        } loadingText:@"" failedText:@"Your password must be at least\n6 characters long."];
        return;
    }
    
    if (_isSetup)
    {
        //old password doesn't match
        if (![_passwordOldField.text isEqualToString:userPF.password])
        {
            [self showActivityIndicatorWithBlock:^BOOL{
                return NO;
            } loadingText:@"" failedText:@"Your old password is incorrect."];
            return;
        }
    }
    
    [self showActivityIndicatorWithBlock:^BOOL{
        BOOL oldIsSetup = _isSetup;
        NSString *oldPassword = userPF.password;
        userPF.password = _passwordNewField.text;
        userPF[@"passwordSetup"] = @(YES);
        NSError *error;
        [userPF save:&error];
        if (error)
        {
            userPF.password = oldPassword;
            userPF[@"passwordSetup"] = @(oldIsSetup);
            return NO;
        }
        _isSetup = YES;
        
        [SSKeychain setPassword:userPF.password forService:SERVICE_NAME account:PASSWORD_NAME error:&error];
        [self backButtonPressed];
        
        return YES;
    } loadingText:@"Processing..." failedText:@"Error while changing your password."];
    
}

-(void)backButtonPressed
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)activityFailedButtonPressed
{
    [_activityFailedButton setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _activityIndicator.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [_activityFailedButton removeFromSuperview];
                     }];
}

-(void)showActivityIndicatorWithBlock:(BOOL (^)())block loadingText:(NSString*)loadingText failedText:(NSString*)failedText
{
    _activityIndicator.alpha = 0;
    _activityLabel.text = loadingText;
    [_activityIndicator setColor:[UIColor whiteColor]];
    [self.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _activityIndicator.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         BOOL succ = block();
                         
                         if (succ)
                         {
                             [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  _activityIndicator.alpha = 0;
                                              }
                                              completion:^(BOOL completed){
                                                  [_activityIndicator stopAnimating];
                                                  [_activityIndicator removeFromSuperview];
                                              }];
                         }
                         else
                         {
                             [_activityIndicator setColor:[UIColor clearColor]];
                             _activityLabel.text = failedText;
                             _activityFailedButton.alpha = 0;
                             [_activityIndicator addSubview:_activityFailedButton];
                             [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  _activityFailedButton.alpha = 1;
                                              }
                                              completion:^(BOOL completed){
                                                  [_activityFailedButton setUserInteractionEnabled:YES];
                                              }];
                         }
                     }];
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
