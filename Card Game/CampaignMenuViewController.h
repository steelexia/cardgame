//
//  CampaignMenuViewController.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-12.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CFButton.h"
#import "CFLabel.h"
#import "UserModel.h"

@interface CampaignMenuViewController : UIViewController

@property (strong) NSMutableArray*difficultyButtons, *chapterButtons, *levelButtons;

@property (strong) CFLabel*chapterDescriptionLabel;
@property (strong) CFLabel*levelOneDescriptionLabel,*levelTwoDescriptionLabel, *levelThreeDescriptionLabel, *levelBossDescriptionLabel;
@property (strong)UIButton *levelOneButton,*levelTwoButton,*levelThreeButton;
@property (strong)CFButton*backButton;

@property int difficulty, chapter;
@end
