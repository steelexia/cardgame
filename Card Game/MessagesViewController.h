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
#import "MessageModel.h"

@interface MessagesViewController : UIViewController <UITextViewDelegate>
@property (strong) MessageTableView *messageTableView;
@property (strong) UITextView*messageBodyView;
@property (strong) UIButton *editCardButton;

@property (strong) NSArray *messagesRetrieved;
-(void)selectedMessage:(PFObject *)message;
@property (strong) NSMutableArray *readMessages;
@property (strong) NSNumber *selectedCardID;
@end
