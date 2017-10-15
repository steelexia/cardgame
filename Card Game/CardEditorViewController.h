//
//  CardEditorViewController.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-28.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CardModel;
@class CardView;
@class StrokedTextField;
@class CustomTextField;
@class AbilityTableView;
@class GKImagePicker;
@class CardVote;
@class CFButton;
@class CFLabel;
#import "GKImagePicker.h"
#import "StrokedLabel.h"


@protocol MyCardEditDelegate

- (void)cardUpdated:(CardModel *)card;
- (void)updateAbilities:(NSMutableArray *)abilities;

@end

@interface CardEditorViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, GKImagePickerDelegate,MyCardEditDelegate>

@property (nonatomic, weak) id<MyCardEditDelegate> delegate;

@property CardModel*currentCardModel;
/** Used for voting. Will not edit it */
@property CardModel*originalCard;
@property (strong) CardView*currentCardView;
@property int currentCost;
@property int maxCost;
@property (strong) GKImagePicker *imagePicker;
@property (strong) UIActivityIndicatorView*cardUploadIndicator, *cardVoteIndicator;
@property (strong) UILabel*cardUploadLabel;
@property (strong) CFButton*cardUploadFailedButton,*cardVoteFailedButton;
@property (strong) UIView*modalFilter;
@property (strong) CFLabel*tutLabel;
@property (strong) CFButton*tutOkButton;
@property (strong) UIImageView*arrowImage;
@property (strong) UIView*customizeView;
@property (strong) UITextView *flavourTextView;
@property (strong) StrokedLabel *customizeBackLabel;
@property (strong) CFButton* customizeBackButton;

@property enum CardEditorMode editorMode;
/** Set to YES if save button is pressed during voting */
@property BOOL voteConfirmed;

- (id)initWithMode: (enum CardEditorMode)editorMode WithCard:(CardModel*)card;

-(void)rowSelected:(AbilityTableView*)tableView indexPath:(NSIndexPath *)indexPath;
-(void)rowDeselected:(AbilityTableView*)tableView ;

@end

extern const double CARD_EDITOR_SCALE;

enum CardEditorMode{
    cardEditorModeCreation,
    cardEditorModeVoting,
    /** Immediately opens the upload image screen, can only change the card's name. Stats are pre-set. Not uploaded and only used for first level */
    cardEditorModeTutorialOne,
    /** Allowed to change cost, damage, life, cooldown, abilities, and tags. Only monster card allowed */
    cardEditorModeTutorialTwo,
    /** Everything allowed, but helps to describe the abilities a bit */
    cardEditorModeTutorialThree,
    cardEditorModeRarityUpdate
};
