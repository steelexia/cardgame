//
//  AbilityViewController.h
//  cardgame
//
//  Created by Emiliano Barcia on 10/26/15.
//  Copyright © 2015 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardModel.h"
#import "CardView.h"
#import "CFLabel.h"
#import "CFButton.h"
#import "GKImagePicker.h"
#import "CardEditorViewController.h"

@interface AbilityViewController : UIViewController<GKImagePickerDelegate>

@property (weak, nonatomic) id<MyCardEditDelegate> delegate;

@property CardModel*originalCard;
@property CardView*currentCardView;
@property (strong) UIImage *cardImage;
@property (strong) NSString *cardName;
@property int currentCost;
@property int maxCost;
@property (strong) GKImagePicker *imagePicker;
@property (strong) UIImageView*arrowImage;
@property enum CardEditorMode editorMode;
@end
