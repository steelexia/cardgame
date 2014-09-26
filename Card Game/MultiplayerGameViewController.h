//
//  MultiplayerGameViewController.h
//  cardgame
//
//  Created by Brian Allen on 2014-09-09.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiplayerNetworking.h"
#import "CFButton.h"
#import "CFLabel.h"

@interface MultiplayerGameViewController : UIViewController<MultiplayerNetworkingProtocol>
@property (nonatomic, copy) void (^gameOverBlock)(BOOL didWin);
@property (nonatomic, copy) void (^gameEndedBlock)();

@property (weak, nonatomic) IBOutlet UILabel *messageStateLabel;
@property (nonatomic, strong) MultiplayerNetworking *networkingEngine;


//loading view
@property (strong)UIActivityIndicatorView*activityIndicator;
@property(strong) UILabel *activityLabel;
@property (strong)CFButton*activityFailedButton;


@end
