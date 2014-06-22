//
//  DeckEditorViewController.h
//  cardgame
//
//  Created by Macbook on 2014-06-21.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeckEditorViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *BackBtn;
- (IBAction)backBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *DeckSegmentedControl;
- (IBAction)DeckSegmentedControl:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *CardTypeSegmentedControl;
- (IBAction)CardTypeValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *CardListTableViewContainer;
@property (weak, nonatomic) IBOutlet UIView *DeckListView;
@property (weak, nonatomic) IBOutlet UIButton *RemoveCardsButton;
- (IBAction)RemoveAllCardsPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *SaveDeckBtn;
- (IBAction)SaveDeckPressed:(id)sender;


@end
