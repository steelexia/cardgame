//
//  CardEditorViewController.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-28.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardModel.h"
#import "CardView.h"
#import "StrokedTextField.h"
#import "CustomTextField.h"
#import "AbilityTableView.h"
#import "GKImagePicker.h"
#import "CardVote.h"

@interface CardEditorViewController : UIViewController <UITextFieldDelegate, GKImagePickerDelegate>

@property CardModel*currentCardModel;
/** Used for voting. Will not edit it */
@property CardModel*originalCard;
@property CardView*currentCardView;
@property int currentCost;
@property int maxCost;
@property (strong)GKImagePicker *imagePicker;
@property (strong)UIActivityIndicatorView*cardUploadIndicator, *cardVoteIndicator;
@property (strong)UILabel*cardUploadLabel;
@property (strong)UIButton*cardUploadFailedButton,*cardVoteFailedButton;
@property enum CardEditorMode editorMode;
/** Set to YES if save button is pressed during voting */
@property BOOL voteConfirmed;

- (id)initWithMode: (enum CardEditorMode)editorMode WithCard:(CardModel*)card;

-(void)rowSelected:(AbilityTableView*)tableView indexPath:(NSIndexPath *)indexPath;

@end

extern const double CARD_EDITOR_SCALE;

enum CardEditorMode{
    cardEditorModeCreation,
    cardEditorModeVoting,
};