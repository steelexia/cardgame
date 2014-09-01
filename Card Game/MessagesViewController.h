//
//  MessagesViewController.h
//  cardgame
//
//  Created by Steele on 2014-08-31.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CFLabel.h"
#import "MessageTableView.h"
#import "CFButton.h"

@interface MessagesViewController : UIViewController <UITextViewDelegate>
@property (strong) MessageTableView *messageTableView;
@property (strong) UITextView*messageBodyView;

@end
