//
//  LoginViewController.m
//  cardgame
//
//  Created by Steele on 2014-09-12.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "LoginViewController.h"
#import "UserModel.h"
#import "CardView.h"
#import "UIConstants.h"
#import "MainScreenViewController.h"
#import "AVFoundation/AVAudioPlayer.h"
#import "CFButton.h"
#import "CFLabel.h"


@implementation LoginViewController

int SCREEN_WIDTH, SCREEN_HEIGHT;
UILabel *loadingLabel;

CGSize keyboardSize;

const NSString*SERVICE_NAME = @"com.contentgames.cardgame";
const NSString*ACCOUNT_NAME = @"username";
const NSString*PASSWORD_NAME = @"password";

CFButton*loginButton;
UIButton*signupButton;
CFLabel *passwordFieldBackground;
UILabel *passwordFieldLabel;
BOOL isNewDevice;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
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
    
    UIImageView*menuLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_logo"]];
    menuLogo.frame = CGRectMake(0,0,250,200);
    menuLogo.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/4);
    
    CFLabel*menuLogoBackground = [[CFLabel alloc] initWithFrame:CGRectInset(menuLogo.frame, 0, 15)];
    menuLogoBackground.center = menuLogo.center;
    [self.view addSubview:menuLogoBackground];
    [self.view addSubview:menuLogo];
    
    UILabel*usernameFieldLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    usernameFieldLabel.text = @"Username:";
    [usernameFieldLabel setFont:[UIFont fontWithName:cardMainFont size:12]];
    [usernameFieldLabel setTextAlignment:NSTextAlignmentRight];
    usernameFieldLabel.center = CGPointMake(SCREEN_WIDTH/2 - 130, SCREEN_HEIGHT*2/3 - 30);
    [self.view addSubview:usernameFieldLabel];
    
    _usernameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 160, 30)];
    [_usernameField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_usernameField setFont:[UIFont fontWithName:cardMainFont size:12]];
    _usernameField.center = CGPointMake(SCREEN_WIDTH/2 + 25, SCREEN_HEIGHT*2/3 - 30);
    [_usernameField setReturnKeyType:UIReturnKeyDone];
    [_usernameField setDelegate:self];
    [_usernameField addTarget:self action:@selector(fieldBegan) forControlEvents:UIControlEventEditingDidBegin];
    [_usernameField addTarget:self action:@selector(fieldFinished) forControlEvents:UIControlEventEditingDidEnd];
    
    CFLabel *usernameFieldBackground = [[CFLabel alloc] initWithFrame:CGRectInset(_usernameField.frame, -6, -4)];
    [usernameFieldBackground setBackgroundColor:COLOUR_INTERFACE_BLUE_LIGHT];
    [self.view addSubview:usernameFieldBackground];
    [self.view addSubview:_usernameField];
    
    passwordFieldLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    passwordFieldLabel.text = @"Password:";
    [passwordFieldLabel setFont:[UIFont fontWithName:cardMainFont size:12]];
    [passwordFieldLabel setTextAlignment:NSTextAlignmentRight];
    passwordFieldLabel.center = CGPointMake(SCREEN_WIDTH/2 - 130, SCREEN_HEIGHT*2/3 + 30);
    [self.view addSubview:passwordFieldLabel];
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 160, 30)];
    [_passwordField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _passwordField.secureTextEntry = YES;
    [_passwordField setFont:[UIFont fontWithName:cardMainFont size:12]];
    _passwordField.center = CGPointMake(SCREEN_WIDTH/2 + 25, SCREEN_HEIGHT*2/3 + 30);
    [_passwordField setReturnKeyType:UIReturnKeyDone];
    [_passwordField setDelegate:self];
    [_passwordField addTarget:self action:@selector(fieldBegan) forControlEvents:UIControlEventEditingDidBegin];
    [_passwordField addTarget:self action:@selector(fieldFinished) forControlEvents:UIControlEventEditingDidEnd];
    
    passwordFieldBackground = [[CFLabel alloc] initWithFrame:CGRectInset(_passwordField.frame, -6, -4)];
    [passwordFieldBackground setBackgroundColor:COLOUR_INTERFACE_BLUE_LIGHT];
    [self.view addSubview:passwordFieldBackground];
    [self.view addSubview:_passwordField];
    
    loginButton = [[CFButton alloc] initWithFrame:CGRectMake(0,0,80,40)];
    [loginButton setTextSize:12];
    loginButton.label.text = @"Log In";
    loginButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT*2/3 + 100);
    [loginButton addTarget:self action:@selector(loginButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    signupButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    [signupButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [signupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    signupButton.center = CGPointMake(SCREEN_WIDTH/5 *4, SCREEN_HEIGHT*2/3 + 130);
    [signupButton.titleLabel setFont:[UIFont fontWithName:cardFlavourTextFont size:12]];
    [signupButton addTarget:self action:@selector(signupButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signupButton];
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(tapRegistered)];
    [tapGesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGesture];
    
    keyboardSize = CGSizeMake(0, 216);
    
    _gameLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_gameLoadingView setColor:COLOUR_INTERFACE_BLUE];
    [_gameLoadingView setFrame:self.view.bounds];
    [_gameLoadingView setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:1 alpha:0.8]];
    [_gameLoadingView setUserInteractionEnabled:YES];
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 40, 80)];
    loadingLabel.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2 + 60);
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.textColor = COLOUR_INTERFACE_BLUE;
    loadingLabel.font = [UIFont fontWithName:cardMainFont size:20];
    loadingLabel.numberOfLines = 0;
    [_gameLoadingView addSubview:loadingLabel];
    
    _loginMessageButton = [[CFButton alloc] initWithFrame:CGRectMake(0,0,80,40)];
    [_loginMessageButton setTextSize:12];
    _loginMessageButton.label.text = @"Ok";
    _loginMessageButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT*4/5);
    [_loginMessageButton addTarget:self action:@selector(closeLoadingView)    forControlEvents:UIControlEventTouchUpInside];
    
    isNewDevice = [self checkIsNewDevice];
    
    if (!isNewDevice) {
        [self loginButtonPressed];
    }
}

-(void)signupButtonPressed
{
    
    
    if (isNewDevice)
    {
        NSLog(@"new device");
        [_passwordField removeFromSuperview];
        [passwordFieldBackground removeFromSuperview];
        [passwordFieldLabel removeFromSuperview];
        
        loginButton.label.text = @"Sign Up";
        [loginButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [loginButton addTarget:self action:@selector(logInDefaultUser)    forControlEvents:UIControlEventTouchUpInside];
        [signupButton setTitle:@"Log in" forState:UIControlStateNormal];
        isNewDevice = NO;
    }
    else
    {
        [self.view addSubview:_passwordField];
        [self.view addSubview:passwordFieldBackground];
        [self.view addSubview:passwordFieldLabel];
        
        loginButton.label.text = @"Log In";
        [loginButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [loginButton addTarget:self action:@selector(loginButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        [signupButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        isNewDevice = YES;
        NSLog(@"not new device");
        //[self loginButtonPressed];
    }

}

-(void)logInDefaultUser
{
    NSString *username = _usernameField.text;
    
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *password = idfv;
    
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    
    [self loginView:@"Signing up..."];
    
    NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
    s = [s invertedSet];
    
    if (username.length < 5)
    {
        loadingLabel.text = [NSString stringWithFormat:@"Your username must be 5 or more characters long."];
        [_gameLoadingView addSubview:_loginMessageButton];
    }
    else if ([username rangeOfCharacterFromSet:s].location != NSNotFound)
    {
        loadingLabel.text = [NSString stringWithFormat:@"Your username can only contain alphabets, numbers, and underscore."];
        [_gameLoadingView addSubview:_loginMessageButton];
    }
    else
    {
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error)
            {
                BOOL succ = [self saveUserLogin:username password:password];
                
                if (succ)
                {
                    [self loadGame];
                    [UserModel setupUser];
                }
                //failed to store keychain
                else
                {
                    [user delete]; //tries to delete the user
                    loadingLabel.text = [NSString stringWithFormat:@"Failed to store account info on your device. Please try again."];
                    [_gameLoadingView addSubview:_loginMessageButton];
                }
            }
            else
            {
                NSString*errorString = [error userInfo][@"error"];
                loadingLabel.text = [NSString stringWithFormat:@"%@.", errorString.capitalizedString];
                [_gameLoadingView addSubview:_loginMessageButton];
            }
        }];
    }
}

-(BOOL)checkIsNewDevice
{
    BOOL userNotFound = NO;
    
    //for debugging: wipes data
    /*
    [SSKeychain deletePasswordForService:SERVICE_NAME account:ACCOUNT_NAME];
    [SSKeychain deletePasswordForService:SERVICE_NAME account:PASSWORD_NAME];
    
    return NO;
    */
    
    //log in
    NSError*error;
    NSString *account = [SSKeychain passwordForService:SERVICE_NAME account:ACCOUNT_NAME error:&error];
    
    if (error)
    {
        //-25300 is when it's not found
        if (error.code == -25300)
        {
            userNotFound = YES;
        }
        else
        {
            NSLog(@"ERROR GETTING ACCOUNT: %@", [error localizedDescription]);
        }
    }
    else{
        _usernameField.text = account;
    }
    
    NSString *password = [SSKeychain passwordForService:SERVICE_NAME account:PASSWORD_NAME error:&error];
    
    if (error)
    {
        //-25300 is when it's not found
        if (error.code == -25300)
        {
            if (userNotFound) //no user or password keychain ever stored, must be new device
                return YES;
        }
        else
        {
            NSLog(@"ERROR GETTING PASSWORD: %@", [error localizedDescription]);
        }
    }
    else{
        _passwordField.text = password;
    }
    
    return NO;
}

-(BOOL)saveUserLogin:(NSString*)user password:(NSString*)password
{
    NSError*error;
    [SSKeychain setPassword:user forService:SERVICE_NAME account:ACCOUNT_NAME error:&error];
    
    if (error)
    {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    [SSKeychain setPassword:password forService:SERVICE_NAME account:PASSWORD_NAME error:&error];
    
    if (error)
    {
        NSLog(@"%@", [error localizedDescription]);
        
        //tries to delete the username, NOTE if this fails, user will lose their default account
        [SSKeychain deletePasswordForService:SERVICE_NAME account:ACCOUNT_NAME];
        return NO;
    }
    
    return YES; //successful
}

-(void)loginView:(NSString*)message
{
    loadingLabel.text = message;
    [_loginMessageButton removeFromSuperview];
    
    _gameLoadingView.alpha = 0;
    [self.view addSubview:_gameLoadingView];
    [_gameLoadingView startAnimating];
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _gameLoadingView.alpha = 1;
                     }
                     completion:nil];
}

-(void)loadGame
{
    loadingLabel.text = [NSString stringWithFormat:@"Loading data..."];
    [self checkForLoadFinish];
}

-(void)loginButtonPressed
{
    NSLog(@"logging in");
    NSString *username = _usernameField.text;
    NSString *password = _passwordField.text;
    
    if (username.length == 0 && password.length == 0)
        return;
    
    [self loginView: @"Logging in..."];
    
    [self saveUserLogin:username password:password];
    
    [PFUser logInWithUsernameInBackground:username password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            [self loadGame];
                                            [UserModel setupUser];
                                        } else {
                                            if(error)
                                            {
                                                NSInteger errorCode = [error code];
                                                if (errorCode == 101)
                                                    loadingLabel.text = [NSString stringWithFormat:@"Error: Invalid login credentials."];
                                                //unknown
                                                else
                                                    loadingLabel.text = [NSString stringWithFormat:@"Error: Couldn't log in."];
                                            }
                                            else
                                            {
                                                loadingLabel.text = @"Error: Unknown Error";
                                            }
                                            
                                            [_gameLoadingView addSubview:_loginMessageButton];
                                        }
                                    }];

}

-(void)closeLoadingView
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _gameLoadingView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [_gameLoadingView stopAnimating];
                         [_gameLoadingView removeFromSuperview];
                     }];
}

-(void)keyboardOnScreen:(NSNotification *)notification
{
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

-(void)fieldBegan
{
    [UIView animateWithDuration:0.4
                          delay:0.05
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.frame = CGRectMake(0,-keyboardSize.height, SCREEN_WIDTH, SCREEN_HEIGHT);
                     }
                     completion:nil];
}

-(void)fieldFinished
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                     }
                     completion:nil];
    return NO;
}

//checks for userInfoLoaded flag to be set to YES. Once it does, remove the loading screen.
-(void)checkForLoadFinish
{
    if (userInitError)
    {
        loadingLabel.text = @"Error loading game.";
        [_gameLoadingView setColor:[UIColor clearColor]];
    }
    else if (userInfoLoaded)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _gameLoadingView.alpha = 0;
                         }
                         completion:^(BOOL completed){
                             [_gameLoadingView stopAnimating];
                             [_gameLoadingView removeFromSuperview];
                             
                             
                             MainScreenViewController *msvc = [[MainScreenViewController alloc] init];
                             [self presentViewController:msvc animated:NO completion:nil];
                         }];
    }
    else
    {
        //keep checking
        [self performBlock:^{
            [self checkForLoadFinish];
        } afterDelay:0.2];
    }
}

-(void)tapRegistered
{
    [self performBlock:^{
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                             [_passwordField resignFirstResponder];
                             [_usernameField resignFirstResponder];
                         }
                         completion:nil];
    } afterDelay:0.1];
    
    
}

//block delay functions
- (void)performBlock:(void (^)())block
{
    block();
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay
{
    void (^block_)() = [block copy]; // autorelease this if you're not using ARC
    [self performSelector:@selector(performBlock:) withObject:block_ afterDelay:delay];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
