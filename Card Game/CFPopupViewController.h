//
//  CFPopupViewController.h
//  cardgame
//
//  Created by Brian Allen on 1/31/16.
//  Copyright © 2016 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CFPopupViewController : UIViewController

@property (strong)NSString *popupTitle;
@property (strong)NSString *popupMessage;
@property (strong)NSString *popupType;
@property (strong)UIImageView *cardImage;

@property (strong) UIImageView *bgImageView;

@end
