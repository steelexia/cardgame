//
//  MultiplayerGameViewController.h
//  cardgame
//
//  Created by Brian Allen on 2014-09-09.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiplayerNetworking.h"

@interface MultiplayerGameViewController : UIViewController<MultiplayerNetworkingProtocol>
@property (nonatomic, copy) void (^gameOverBlock)(BOOL didWin);
@property (nonatomic, copy) void (^gameEndedBlock)();
@property (nonatomic, strong) MultiplayerNetworking *networkingEngine;
@end
