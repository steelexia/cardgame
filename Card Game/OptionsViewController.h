//
//  OptionsViewController.h
//  cardgame
//
//  Created by Steele on 2014-09-01.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CFButton;
@class CFLabel;

//#import "CFLabel.h"

#import "SSKeychain.h"

@interface OptionsViewController : UIViewController

@property (strong) CFButton *passwordButton, *logoutButton;

@end
