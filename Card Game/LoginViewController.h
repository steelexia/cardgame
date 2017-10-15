//
//  LoginViewController.h
//  cardgame
//
//  Created by Steele on 2014-09-12.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CFButton;

#import <Parse/Parse.h>
#import "SSKeychain.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (strong) UIActivityIndicatorView*gameLoadingView;

@property (strong) UITextField *usernameField, *passwordField;

@property (strong) CFButton*loginMessageButton;

extern const NSString*SERVICE_NAME, *ACCOUNT_NAME, *PASSWORD_NAME;

@end
