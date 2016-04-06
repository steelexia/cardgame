//
//  CampaignMenuViewController.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-08-12.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CampaignMenuViewController.h"
#import "Campaign.h"
#import "CardView.h"
#import "DeckChooserViewController.h"
#import "GameViewController.h"

@interface CampaignMenuViewController ()

@end

int SCREEN_WIDTH, SCREEN_HEIGHT;

@implementation CampaignMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
    UIImageView*backgroundImageTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_background_top"]];
    backgroundImageTop.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    [self.view addSubview:backgroundImageTop];
    
    UIImageView*backgroundImageMiddle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_background_center"]];
    backgroundImageMiddle.frame = CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - 40 - 40);
    [self.view addSubview:backgroundImageMiddle];
    
    UIImageView*backgroundImageBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_background_bottom"]];
    backgroundImageBottom.frame = CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, 40);
    [self.view addSubview:backgroundImageBottom];
    
    _difficultyButtons = [NSMutableArray arrayWithCapacity:3];
    CGSize difficultyTabSize = CGSizeMake(80, 40);
    for (int i = 0; i < NUMBER_OF_DIFFICULTIES; i++)
    {
        double distanceFromCenter = i - 1;
        CFButton*difficultyButton = [[CFButton alloc]initWithFrame:CGRectMake(0, 0,  difficultyTabSize.width, difficultyTabSize.height)];
        if (SCREEN_HEIGHT >= 568)
            difficultyButton.center = CGPointMake(SCREEN_WIDTH/2 + distanceFromCenter * (difficultyTabSize.width + 4) , 50);
        else
            difficultyButton.center = CGPointMake(SCREEN_WIDTH/2 + distanceFromCenter * (difficultyTabSize.width + 4) , 40);
        difficultyButton.buttonStyle = CFButtonStyleRadio;
        
        [difficultyButton setTextSize:14];
        
        if (i == 0)
            [difficultyButton setTitle:@"Normal" forState:UIControlStateNormal];
        else if (i == 1)
            [difficultyButton setTitle:@"Hard" forState:UIControlStateNormal];
        else if (i == 2)
            [difficultyButton setTitle:@"Insane" forState:UIControlStateNormal];
        
        if (i == 0)
            [difficultyButton setSelected:YES];
        
        [difficultyButton addTarget:self action:@selector(difficultyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_difficultyButtons addObject:difficultyButton];
        
        [self.view addSubview:difficultyButton];
    }
    
    _chapterButtons = [NSMutableArray arrayWithCapacity:3];
    CGSize chapterTabSize = CGSizeMake(80, 40);
    for (int i = 0; i < NUMBER_OF_DIFFICULTIES; i++)
    {
        double distanceFromCenter = i - 1;
        CFButton*chapterButton = [[CFButton alloc]initWithFrame:CGRectMake(0, 0,  chapterTabSize.width, chapterTabSize.height)];
        
        if (SCREEN_HEIGHT >= 568)
            chapterButton.center = CGPointMake(SCREEN_WIDTH/2 + distanceFromCenter * (chapterTabSize.width + 4) , 104);
        else
            chapterButton.center = CGPointMake(SCREEN_WIDTH/2 + distanceFromCenter * (chapterTabSize.width + 4) , 84);
        chapterButton.buttonStyle = CFButtonStyleRadio;
        
        [chapterButton setTextSize:14];
        
        [chapterButton setTitle:[NSString stringWithFormat:@"Chapter %d", i+1] forState:UIControlStateNormal];
        
        if (i == 0)
            [chapterButton setSelected:YES];
        
        [chapterButton addTarget:self action:@selector(chapterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_chapterButtons addObject:chapterButton];
        [self.view addSubview:chapterButton];
    }
    
    if (SCREEN_HEIGHT >= 568)
        _chapterDescriptionLabel = [[CFLabel alloc]initWithFrame:CGRectMake(25, 135, SCREEN_WIDTH-50, 90)];
    else
        _chapterDescriptionLabel = [[CFLabel alloc]initWithFrame:CGRectMake(25, 110, SCREEN_WIDTH-50, 70)];
    
    _chapterDescriptionLabel.label.text = @"";
    [self.view addSubview:_chapterDescriptionLabel];
    
    if (SCREEN_HEIGHT >= 568)
        _levelOneDescriptionLabel = [[CFLabel alloc]initWithFrame:CGRectMake(25, 245, SCREEN_WIDTH-50, 65)];
    else
        _levelOneDescriptionLabel = [[CFLabel alloc]initWithFrame:CGRectMake(25, 191, SCREEN_WIDTH-50, 65)];
    [self.view addSubview:_levelOneDescriptionLabel];
    
    if (SCREEN_HEIGHT >= 568)
        _levelTwoDescriptionLabel = [[CFLabel alloc]initWithFrame:CGRectMake(25, 245 + 85, SCREEN_WIDTH-50, 65)];
    else
        _levelTwoDescriptionLabel = [[CFLabel alloc]initWithFrame:CGRectMake(25, 191 + 76, SCREEN_WIDTH-50, 65)];
    [self.view addSubview:_levelTwoDescriptionLabel];
    
    if (SCREEN_HEIGHT >= 568)
        _levelThreeDescriptionLabel = [[CFLabel alloc]initWithFrame:CGRectMake(25, 245 + 85*2, SCREEN_WIDTH-50, 65)];
    else
        _levelThreeDescriptionLabel = [[CFLabel alloc]initWithFrame:CGRectMake(25, 191 + 76*2, SCREEN_WIDTH-50, 65)];
    [self.view addSubview:_levelThreeDescriptionLabel];
    
    _levelOneButton = [[UIButton alloc] initWithFrame:CGRectMake(20, _levelOneDescriptionLabel.frame.origin.y - 5, 75, 75)];
    [_levelOneButton setBackgroundImage:placeHolderImage forState:UIControlStateNormal];
    [self.view addSubview:_levelOneButton];
    _levelOneButton.layer.cornerRadius = 10;
    _levelOneButton.layer.borderWidth = 2;
    _levelOneButton.layer.borderColor = [UIColor blackColor].CGColor;
    _levelOneButton.clipsToBounds = YES;
    [_levelOneButton addTarget:self action:@selector(levelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _levelTwoButton = [[UIButton alloc] initWithFrame:CGRectMake(20, _levelTwoDescriptionLabel.frame.origin.y - 5, 75, 75)];
    [_levelTwoButton setBackgroundImage:placeHolderImage forState:UIControlStateNormal];
    [self.view addSubview:_levelTwoButton];
    _levelTwoButton.layer.cornerRadius = 10;
    _levelTwoButton.layer.borderWidth = 2;
    _levelTwoButton.layer.borderColor = [UIColor blackColor].CGColor;
    _levelTwoButton.clipsToBounds = YES;
    [_levelTwoButton addTarget:self action:@selector(levelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _levelThreeButton = [[UIButton alloc] initWithFrame:CGRectMake(20, _levelThreeDescriptionLabel.frame.origin.y - 5, 75, 75)];
    [_levelThreeButton setBackgroundImage:placeHolderImage forState:UIControlStateNormal];
    [self.view addSubview:_levelThreeButton];
    _levelThreeButton.layer.cornerRadius = 10;
    _levelThreeButton.layer.borderWidth = 2;
    _levelThreeButton.layer.borderColor = [UIColor blackColor].CGColor;
    _levelThreeButton.clipsToBounds = YES;
    [_levelThreeButton addTarget:self action:@selector(levelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _backButton = [[CFButton alloc]initWithFrame:CGRectMake(0, 0,  80, 40)];
    if (SCREEN_HEIGHT >= 568)
        _backButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 25 - 25);
    else
        _backButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 15 - 25);
    [_backButton setTextSize:14];
    [_backButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.view addSubview:_backButton];
    [_backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    _difficulty = 1;
    _chapter = 1;
    
    [self updateCurrentLevelView];
    [self setToLatestChapter];
}


-(void)setToLatestChapter
{
    //slow method but there are barely any levels in total anyways
    for (int i = NUMBER_OF_DIFFICULTIES - 1; i >= 0; i--)
    {
        if ([_difficultyButtons[i] isEnabled])
        {
            [self difficultyButtonPressed:_difficultyButtons[i]];
            break;
        }
    }
    
    for (int i = NUMBER_OF_CHAPTERS - 1; i >= 0; i--)
    {
        if ([_chapterButtons[i] isEnabled])
        {
            [self chapterButtonPressed:_chapterButtons[i]];
            break;
        }
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateCurrentLevelView];
        [self setToLatestChapter];
    });
}

-(void)updateCurrentLevelView
{
    //resets states of all buttons
    NSArray*completedLevels = userPF[@"completedLevels"];
    
    for (int diffIndex = 0; diffIndex < NUMBER_OF_DIFFICULTIES; diffIndex++)
    {
        //diff 1 is always enabled
        if (diffIndex == 0)
            [_difficultyButtons[diffIndex] setEnabled:YES];
        else
        {
            //a difficulty is unlocked if the last level of the previous difficulty is beaten
            if ([completedLevels containsObject:[NSString stringWithFormat:@"d_%d_c_3_l_4", diffIndex]])
            {
                [_difficultyButtons[diffIndex] setEnabled:YES];
                
                if ([_difficultyButtons[diffIndex] isSelected])
                    _difficulty = diffIndex+1;
            }
            else
                [_difficultyButtons[diffIndex] setEnabled:NO];
        }
    }
    
    for (int chapterIndex = 0; chapterIndex < NUMBER_OF_CHAPTERS; chapterIndex++)
    {
        //chapter 1 is always enabled, since difficulty must be enabled to see this
        if (chapterIndex == 0)
            [_chapterButtons[chapterIndex] setEnabled:YES];
        else
        {
            //a chapter is unlocked if the last level of the previous chapter is beaten
            if ([completedLevels containsObject:[NSString stringWithFormat:@"d_%d_c_%d_l_4", _difficulty, chapterIndex]])
            {
                [_chapterButtons[chapterIndex] setEnabled:YES];
                
                if ([_chapterButtons[chapterIndex] isSelected])
                    _chapter = chapterIndex + 1;
            }
            else
                [_chapterButtons[chapterIndex] setEnabled:NO];
        }
    }
    
    //levels are sadly hardcoded
    
    //level one is always enabled
    
    [self setLevelEnabled:1 enabled:YES];
    
    if ([completedLevels containsObject:[NSString stringWithFormat:@"d_%d_c_%d_l_1", _difficulty, _chapter]])
        [self setLevelEnabled:2 enabled:YES];
    else
        [self setLevelEnabled:2 enabled:NO];
    
    if ([completedLevels containsObject:[NSString stringWithFormat:@"d_%d_c_%d_l_2", _difficulty, _chapter]])
        [self setLevelEnabled:3 enabled:YES];
    else
        [self setLevelEnabled:3 enabled:NO];
    
    for (int i = 1; i < 4; i++)
    {
        NSString*imageKey = [NSString stringWithFormat:@"c_%d_l_%d", _chapter, i];
        UIImage *heroImage = campaignHeroImages[imageKey];
        
        if (heroImage==nil)
        {
            heroImage = placeHolderImage;
        }
        
        if (i == 1)
        {
            [_levelOneButton setImage:heroImage forState:UIControlStateNormal];
        }
        else if (i == 2)
        {
            [_levelTwoButton setImage:heroImage forState:UIControlStateNormal];
        }
        else if (i == 3)
        {
            [_levelThreeButton setImage:heroImage forState:UIControlStateNormal];
        }
    }
    
    _chapterDescriptionLabel.label.text = [Campaign getChapterDescription:_chapter];
}

-(void)backButtonPressed
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)difficultyButtonPressed:(id)sender
{
    UIButton*senderButton = sender;
    
    int i = 0;
    for (UIButton*button in _difficultyButtons)
    {
        if (senderButton == button)
        {
            _difficulty = i+1;
            [_difficultyButtons[i] setSelected:YES];
        }
        else
        {
            if ([_difficultyButtons[i] isEnabled])
                [_difficultyButtons[i] setSelected:NO];
        }
        i++;
    }
    
    //automatically selects the first chapter
    for (int i = 0; i < _chapterButtons.count; i++)
    {
        if (i == 0)
        {
            [_chapterButtons[i] setSelected:YES];
            _chapter = i + 1;
        }
        else
            [_chapterButtons[i] setSelected:NO];
    }
    
    [self updateCurrentLevelView];
}
-(void)chapterButtonPressed:(id)sender
{
    UIButton*senderButton = sender;
    
    int i = 0;
    for (UIButton*button in _chapterButtons)
    {
        if (senderButton == button)
        {
            _chapter = i+1;
            [_chapterButtons[i] setSelected:YES];
        }
        else
        {
            if ([_chapterButtons[i] isEnabled])
                [_chapterButtons[i] setSelected:NO];
        }
        i++;
    }
    [self updateCurrentLevelView];
}

-(void)levelButtonPressed:(id)sender
{
    int levelNumber = 0;
    
    if (sender == _levelOneButton)
        levelNumber = 1;
    else if (sender == _levelTwoButton)
        levelNumber = 2;
    else if (sender == _levelThreeButton)
        levelNumber = 4; //DEBUG
    
    int chapterNumber = 0;
    for (UIButton*button in _chapterButtons)
    {
        chapterNumber++;
        if (button.isSelected)
            break;
    }
    
    int difficultyNumber = 0;
    for (UIButton*button in _difficultyButtons)
    {
        difficultyNumber++;
        if (button.isSelected)
            break;
    }
    
    Level*level = [Campaign getLevelWithDifficulty:difficultyNumber withChapter:chapterNumber withLevel:levelNumber];
    
    GameViewController *gvc = [[GameViewController alloc] initWithGameMode:GameModeSingleplayer withLevel:level];
    
    DeckChooserViewController *dcvc = [[DeckChooserViewController alloc] init];
    if (level.isTutorial)
        dcvc.noPickDeck = YES;
    dcvc.opponentName = level.opponentName;
    
    dcvc.nextScreen = gvc;
    
    [self presentViewController:dcvc animated:YES completion:nil];
}

-(void)setLevelEnabled:(int)level enabled:(BOOL)enabled
{
    if (level == 1)
    {
        [_levelOneButton setEnabled:enabled];
    }
    else if (level == 2)
    {
        [_levelTwoButton setEnabled:enabled];
    }
    else if (level == 3)
    {
        [_levelThreeButton setEnabled:enabled];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
