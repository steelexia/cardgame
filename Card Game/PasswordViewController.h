//
//  PasswordViewController.h
//  cardgame
//
//  Created by Steele on 2014-09-01.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CFButton.h"
#import "CFLabel.h"
#import "UIConstants.h"

@interface PasswordViewController : UIViewController

@property BOOL isSetup;

@property (strong) UITextField *passwordOldField, *passwordNewField, *passwordNewConfirmField;

@property (strong)UIActivityIndicatorView*activityIndicator;
@property(strong) UILabel *activityLabel;
@property (strong)CFButton*activityFailedButton;

- (id)initWithIsSetup:(BOOL)isSetup;

@end

