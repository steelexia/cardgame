//
//  AbilityViewController.m
//  cardgame
//
//  Created by Emiliano Barcia on 10/26/15.
//  Copyright © 2015 Content Games. All rights reserved.
//

#import "CardEditorViewController.h"
#import "CGPointUtilities.h"

#import "Ability.h"
#import "AbilityWrapper.h"
#import "AbilityTableViewCell.h"

#import "MainScreenViewController.h"
#import "AbilityTableView.h"
#import "CardPointsUtility.h"
#import "AbilityViewController.h"

#import "GameStore.h"

@interface AbilityViewController ()

@end

@implementation AbilityViewController

UIImage *CARD_EDITOR_EMPTY_IMAGE;

int SCREEN_WIDTH, SCREEN_HEIGHT;
const double CARD_SCALE = 1.4;

const int _MAX_NAME_FONT_SIZE = 15;

/** A monster's base stat cannot be higher than these. (not that it's even easy to get to these stats */
const int _MAX_DAMAGE = 20000, _MIN_DAMAGE = 0, _DAMAGE_INCREMENT = 100;
const int _MAX_LIFE = 20000, _MIN_LIFE = 1000, _LIFE_INCREMENT = 100;
const int _MAX_COOLDOWN = 5, _MIN_COOLDOWN = 1, _COOLDOWN_INCREMENT = 1;
const int _MIN_COST = 0, _COST_INCREMENT = 1; //maxCost is an array

UITextField *nameTextField;

UILabel*abilityValueLabel;
CFButton *abilityIncButton, *abilityDecButton, *abilityAddButton, *abilityRemoveButton;

/** Transparent views used to register touch events for enabling the buttons for editing the stats. */
UIView*damageEditArea, *lifeEditArea, *costEditArea, *cdEditArea, *imageEditArea, *elementEditArea, *abilityEditArea,*welcomeView;

CFButton *damageIncButton, *damageDecButton, *lifeIncButton, *lifeDecButton, *cdIncButton, *cdDecButton, *costIncButton, *costDecButton;

UIImage *scaledImage;
UIImageView*pointsImageBackground;

StrokedLabel*currentCostLabel, *maxCostLabel;
UIImageView*pointsImageBackground;

AbilityTableView *abilityNewTableView,*abilityExistingTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    CARD_EDITOR_EMPTY_IMAGE = [UIImage imageNamed:@"card_image_cardeditor_empty"];
    
    UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [backImage setImage:[UIImage imageNamed:@"WoodBG.jpg"]];
    [self.view addSubview:backImage];
    
    [self reloadCardView];
    [self setUpView];
    [self loadAllValidAbilities];
    
}

-(void)setUpView{
    nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0,0,96,40)];
    nameTextField.bounds = CGRectMake(0, 0, 96, 40);
    //nameTextField.center = [self.currentCardView convertPoint:self.currentCardView.nameLabel.center fromView:self.view];
    nameTextField.center = [self.view convertPoint:self.currentCardView.nameLabel.center fromView:self.currentCardView];
    
    nameTextField.textAlignment = NSTextAlignmentCenter;
    nameTextField.textColor = [UIColor blackColor];
    nameTextField.backgroundColor = [UIColor clearColor];
    nameTextField.font = [UIFont fontWithName:cardMainFont size:15];
    //nameTextField.text = self.currentCardModel.name;
    nameTextField.transform = self.currentCardView.transform;
    nameTextField.returnKeyType = UIReturnKeyDone;
    [nameTextField setPlaceholder:@"Enter name here"];
    [nameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [nameTextField addTarget:self action:@selector(nameTextFieldEdited) forControlEvents:UIControlEventEditingChanged];
    [nameTextField setMinimumFontSize:8.f];
    nameTextField.adjustsFontSizeToFitWidth = YES; //TODO doesn't work under 14
    [nameTextField setText:self.cardName];
    
    
    [nameTextField setDelegate:(id)self];
    [self.view addSubview:nameTextField];
    
    
    
    UIImageView *abilityBack = [[UIImageView alloc] initWithFrame:CGRectMake(10, (SCREEN_HEIGHT/5)*3 +10, SCREEN_WIDTH -20, (SCREEN_HEIGHT/5)*2 -10)];
    [abilityBack setImage:[UIImage imageNamed:@"CardCreateDialog.png"]];
    [self.view addSubview:abilityBack];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/5, abilityBack.frame.origin.y + abilityBack.frame.size.height -52, 50, 38)];
    [backButton setImage:[UIImage imageNamed:@"CardCreateBackButton.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH/5) *2, abilityBack.frame.origin.y + abilityBack.frame.size.height -52, 150, 40)];
    [okButton setBackgroundImage:[UIImage imageNamed:@"CardCreateForwardButton.png"] forState:UIControlStateNormal];
    [okButton setTitle:@"OK" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okButton.titleLabel setFont:[UIFont fontWithName:cardMainFontBlack size:20]];
    [okButton addTarget:self action:@selector(saveAndGoBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [self.view addSubview:okButton];
    
    
    //abilities table view
    
    abilityExistingTableView = [[AbilityTableView alloc] initWithFrame:CGRectMake(80, 242, 150, 80)  mode:abilityTableViewExisting];
    abilityExistingTableView.cevc = (id)self;
    //[abilityExistingTableView setHidden:YES];
    [abilityExistingTableView.layer setZPosition:2];
    [abilityExistingTableView setUserInteractionEnabled:YES];
    
    
  
    [self.view addSubview:abilityExistingTableView];
    
    CFLabel*abilityNewTableViewBackground = [[CFLabel alloc] initWithFrame:CGRectMake(80, 345, 186, SCREEN_HEIGHT - 345 - 28)];
    [abilityNewTableViewBackground setHidden:YES];
    [self.view addSubview:abilityNewTableViewBackground];
    
    //new
    abilityNewTableView = [[AbilityTableView alloc] initWithFrame:CGRectMake(30, (SCREEN_HEIGHT/5)*3 +20, SCREEN_WIDTH -60, (abilityBack.frame.size.height/6)*4) mode:abilityTableViewNew];
    abilityNewTableView.cevc = (id)self;
    [abilityNewTableView.layer setZPosition:2];
    [self.view addSubview:abilityNewTableView];
    
    
    abilityRemoveButton = [[CFButton alloc] initWithFrame:CGRectMake(270, 314, 46, 32)];
    [abilityRemoveButton setImage:[UIImage imageNamed:@"remove_deck_button"] forState:UIControlStateNormal];
    //[abilityRemoveButton setImage:[UIImage imageNamed:@"remove_deck_button_gray"] forState:UIControlStateDisabled];
    [abilityRemoveButton addTarget:self action:@selector(abilityRemoveButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [abilityRemoveButton setEnabled:NO];
    
   /* pointsImageBackground = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CardCreateYellowStar"]];
    pointsImageBackground.frame = CGRectMake(0,0,74, 74);
    pointsImageBackground.center = CGPointMake(40, 180);
    
    [self.view addSubview:pointsImageBackground];*/
    
    pointsImageBackground = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CardCreateYellowStar"]];
    pointsImageBackground.frame = CGRectMake(0,0,74, 74);
    pointsImageBackground.center = CGPointMake(40, 180);
    
    [self.view addSubview:pointsImageBackground];
    
    currentCostLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0,46,32)];
    currentCostLabel.center = CGPointMake(40, 175);
    currentCostLabel.textAlignment = NSTextAlignmentCenter;
    currentCostLabel.textColor = [UIColor whiteColor];
    currentCostLabel.backgroundColor = [UIColor clearColor];
    currentCostLabel.font = [UIFont fontWithName:cardMainFont size:12];
    [currentCostLabel setMinimumScaleFactor:12.f/20];
    currentCostLabel.adjustsFontSizeToFitWidth = YES;
    currentCostLabel.strokeOn = YES;
    currentCostLabel.strokeColour = [UIColor blackColor];
    currentCostLabel.strokeThickness = 2;
    
    [self.view addSubview:currentCostLabel];
    
    maxCostLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0,46,32)];
    maxCostLabel.center = CGPointMake(40, 190);
    maxCostLabel.textAlignment = NSTextAlignmentCenter;
    maxCostLabel.textColor = [UIColor whiteColor];
    maxCostLabel.backgroundColor = [UIColor clearColor];
    maxCostLabel.font = [UIFont fontWithName:cardMainFont size:12];
    [maxCostLabel setMinimumScaleFactor:12.f/20];
    maxCostLabel.adjustsFontSizeToFitWidth = YES;
    maxCostLabel.strokeOn = YES;
    maxCostLabel.strokeColour = [UIColor blackColor];
    maxCostLabel.strokeThickness = 2;
    
    [self.view addSubview:maxCostLabel];
    
    
    CGPoint attackLabelPoint = [self.view convertPoint:self.currentCardView.attackLabel.center fromView:self.currentCardView];
    damageIncButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    damageIncButton.center = CGPointMake(attackLabelPoint.x, attackLabelPoint.y - 28);
    [damageIncButton setImage:[UIImage imageNamed:@"increment_button"] forState:UIControlStateNormal];
    //[damageIncButton setImage:[UIImage imageNamed:@"increment_button_gray"] forState:UIControlStateDisabled];
    [damageIncButton addTarget:self action:@selector(damageIncButtonPressed)    forControlEvents:UIControlEventTouchDown];
    
    //[self.view addSubview:damageIncButton];
    
    damageDecButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    damageDecButton.center = CGPointMake(attackLabelPoint.x, attackLabelPoint.y + 32);
    [damageDecButton setImage:[UIImage imageNamed:@"decrement_button"] forState:UIControlStateNormal];
    //[damageDecButton setImage:[UIImage imageNamed:@"decrement_button_gray"] forState:UIControlStateDisabled];
    [damageDecButton addTarget:self action:@selector(damageDecButtonPressed)    forControlEvents:UIControlEventTouchDown];
    
   // [self.view addSubview:damageDecButton];
    
    CGPoint lifeLabelPoint = [self.view convertPoint:self.currentCardView.lifeLabel.center fromView:self.currentCardView];
    lifeIncButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    lifeIncButton.center = CGPointMake(lifeLabelPoint.x, lifeLabelPoint.y - 28);
    [lifeIncButton setImage:[UIImage imageNamed:@"increment_button"] forState:UIControlStateNormal];
    //[lifeIncButton setImage:[UIImage imageNamed:@"increment_button_gray"] forState:UIControlStateDisabled];
    [lifeIncButton addTarget:self action:@selector(lifeIncButtonPressed)    forControlEvents:UIControlEventTouchDown];
    
   // [self.view addSubview:lifeIncButton];
    
    lifeDecButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    lifeDecButton.center = CGPointMake(lifeLabelPoint.x, lifeLabelPoint.y + 32);
    [lifeDecButton setImage:[UIImage imageNamed:@"decrement_button"] forState:UIControlStateNormal];
    //[lifeDecButton setImage:[UIImage imageNamed:@"decrement_button_gray"] forState:UIControlStateDisabled];
    [lifeDecButton addTarget:self action:@selector(lifeDecButtonPressed)    forControlEvents:UIControlEventTouchDown];
    
   // [self.view addSubview:lifeDecButton];
    
    CGPoint cdLabelPoint = [self.view convertPoint:self.currentCardView.cooldownLabel.center fromView:self.currentCardView];
    cdIncButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    cdIncButton.center = CGPointMake(cdLabelPoint.x, cdLabelPoint.y - 32);
    [cdIncButton setImage:[UIImage imageNamed:@"increment_button"] forState:UIControlStateNormal];
    //[cdIncButton setImage:[UIImage imageNamed:@"increment_button_gray"] forState:UIControlStateDisabled];
    [cdIncButton addTarget:self action:@selector(cdIncButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
   // [self.view addSubview:cdIncButton];
    
    cdDecButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    cdDecButton.center = CGPointMake(cdLabelPoint.x, cdLabelPoint.y + 34);
    [cdDecButton setImage:[UIImage imageNamed:@"decrement_button"] forState:UIControlStateNormal];
    //[cdDecButton setImage:[UIImage imageNamed:@"decrement_button_gray"] forState:UIControlStateDisabled];
    [cdDecButton addTarget:self action:@selector(cdDecButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
   // [self.view addSubview:cdDecButton];
    
    CGPoint costLabelPoint = [self.view convertPoint:self.currentCardView.costLabel.center fromView:self.currentCardView];
    costIncButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    costIncButton.center = CGPointMake(costLabelPoint.x, costLabelPoint.y - 36);
    [costIncButton setImage:[UIImage imageNamed:@"increment_button"] forState:UIControlStateNormal];
    //[costIncButton setImage:[UIImage imageNamed:@"increment_button_gray"] forState:UIControlStateDisabled];
    [costIncButton addTarget:self action:@selector(costIncButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //[self.view addSubview:costIncButton];
    
    costDecButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    costDecButton.center = CGPointMake(costLabelPoint.x, costLabelPoint.y + 38);
    [costDecButton setImage:[UIImage imageNamed:@"decrement_button"] forState:UIControlStateNormal];
    //[costDecButton setImage:[UIImage imageNamed:@"decrement_button_gray"] forState:UIControlStateDisabled];
    [costDecButton addTarget:self action:@selector(costDecButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //[self.view addSubview:costDecButton];
    
    damageEditArea = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 60, 36)];
    damageEditArea.center = CGPointMake(attackLabelPoint.x, attackLabelPoint.y);
    
    //damageEditArea.backgroundColor = [UIColor redColor];
    //damageEditArea.alpha = 0.5;
    
    [self.view addSubview:damageEditArea];
    
    lifeEditArea = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 60, 36)];
    lifeEditArea.center = CGPointMake(lifeLabelPoint.x, lifeLabelPoint.y);
    
    //lifeEditArea.backgroundColor = [UIColor redColor];
    //lifeEditArea.alpha = 0.5;
    
    [self.view addSubview:lifeEditArea];
    
    costEditArea = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 56, 56)];
    costEditArea.center = CGPointMake(costLabelPoint.x, costLabelPoint.y);
    
    //costEditArea.backgroundColor = [UIColor redColor];
    //costEditArea.alpha = 0.5;
    
    [self.view addSubview:costEditArea];
    
    cdEditArea = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 40, 40)];
    cdEditArea.center = CGPointMake(cdLabelPoint.x, cdLabelPoint.y);
    
    //cdEditArea.backgroundColor = [UIColor redColor];
    //cdEditArea.alpha = 0.5;
    
    [self.view addSubview:cdEditArea];
    
    abilityEditArea = [[UIView alloc] initWithFrame: CGRectMake(80, 242, 186, 90)];
    [self.view addSubview:abilityEditArea];
    
    if (_editorMode == cardEditorModeTutorialTwo) {
        self.tutOkButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
        self.tutOkButton.label.text = @"Ok";
        
        _arrowImage = [[UIImageView alloc] initWithImage:ARROW_RIGHT_ICON_IMAGE];
        _arrowImage.frame = CGRectMake(0,0,80,80);
        
        self.tutLabel = [[CFLabel alloc] initWithFrame:CGRectMake(0,0,260,180)];
        [self setTutLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/4)];
        [self.tutLabel setIsDialog:YES];
        [self.tutLabel.label setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:_tutLabel];
        [self.view addSubview:_tutOkButton];
        [self tutorialAbility];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self setupExistingCard];
    [maxCostLabel setText:[NSString stringWithFormat:@"%d",self.maxCost]];
    [currentCostLabel setText:[NSString stringWithFormat:@"%d",self.currentCost]];
    
    if (self.currentCost > self.maxCost ) {
        [currentCostLabel setTextColor:[UIColor redColor]];
    }
}

-(void)yesButtonPressed{
    [welcomeView removeFromSuperview];
    [imageEditArea setUserInteractionEnabled:YES];
    [nameTextField setUserInteractionEnabled:YES];
}

-(void)tutorialAbility
{
    [self removeAllStatButtons];
    [abilityExistingTableView setUserInteractionEnabled:YES];
    [abilityNewTableView setUserInteractionEnabled:YES];
    [damageEditArea removeFromSuperview];
    [lifeEditArea removeFromSuperview];
    [costEditArea removeFromSuperview];
    [cdEditArea removeFromSuperview];
    
    [self setTutLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/4)];
    
    self.tutLabel.label.text = @"The list below shows the abilities you can add to the card. Some abilities have adjustable values, and having different combinations of abilities can give bonuses and penalties to your points.";
    
    [self.tutOkButton addTarget:self action:@selector(removeAllTutorialViews) forControlEvents:UIControlEventTouchUpInside];
    
    _arrowImage.image = ARROW_DOWN_ICON_IMAGE;
    [self.view addSubview:_arrowImage];
    _arrowImage.center = CGPointMake(abilityNewTableView.center.x, abilityNewTableView.frame.origin.y - 40);
    _arrowImage.alpha = 1.0;
}


-(void)removeAllTutorialViews
{
    [self unmodalScreen];
    [self.tutLabel removeFromSuperview];
    [self.tutOkButton removeFromSuperview];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _arrowImage.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                     }];
    
}

-(void)tapRegistered
{
    [nameTextField resignFirstResponder];
}

-(void)nameTextFieldEdited
{
    //NSLog(@"%d", nameTextField.adjustsFontSizeToFitWidth);
    //NSLog(@"%f", nameTextField.font.pointSize);
    NSLog(@"NAME: %@",nameTextField.text);
    
    //TODO SHOULD NOT BE DOING THIS MANUALLY BUT THE AUTOMATIC ONE DOESN'T WORK
    
    //ios 7 only
    //CGSize textSize = [[label text] sizeWithAttributes:@{NSFontAttributeName:[label font]}];
    
    BOOL maximumLengthReached = NO;
    
    CGSize textSize = [[nameTextField text] sizeWithFont:[nameTextField font]];
    
    if (textSize.width > nameTextField.bounds.size.width)
    {
        NSString* text = [nameTextField text];
        while ([text hasPrefix:@" "])
            [text substringFromIndex:1];
        
        [nameTextField setText:text];
        
        do
        {
            int newSize = nameTextField.font.pointSize-1;
            
            if (newSize < 8)
            {
                maximumLengthReached = YES;
                break;
            }
            
            [nameTextField setFont:[UIFont fontWithName:nameTextField.font.familyName size:newSize]];
            textSize = [[nameTextField text] sizeWithFont:[nameTextField font]];
        }
        while (textSize.width > nameTextField.bounds.size.width);
    }
    else
    {
        do
        {
            int newSize = nameTextField.font.pointSize+1;
            
            if (newSize > _MAX_NAME_FONT_SIZE)
                break;
            
            [nameTextField setFont:[UIFont fontWithName:nameTextField.font.familyName size:newSize]];
            textSize = [[nameTextField text] sizeWithFont:[nameTextField font]];
        }
        while (textSize.width < nameTextField.bounds.size.width);
    }
    
    //reached max length, remove last character
    if (maximumLengthReached)
        nameTextField.text = [nameTextField.text substringToIndex:[nameTextField.text length]-1];
    
    //[_currentCardView.nameLabel setText:nameTextField.text];
    //[_currentCardView.nameLabel setFont:nameTextField.font];
}

-(void)tagsTextFieldEdited
{
//    while (tagsField.text.length > 100)
//        tagsField.text = [tagsField.text substringToIndex:[tagsField.text length]-1];
}

-(void)keyboardOnScreen:(NSNotification *)notification
{
//    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

-(void)tagsFieldBegan
{
//    int height = keyboardSize.height;
//    
//    [UIView animateWithDuration:0.4
//                          delay:0.05
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         self.view.frame = CGRectMake(0,-keyboardSize.height, SCREEN_WIDTH, SCREEN_HEIGHT);
//                     }
//                     completion:nil];
}

-(void)tagsFieldFinished
{
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                     }
                     completion:nil];
}

-(void)damageIncButtonPressed
{
    [self modifyDamage:_DAMAGE_INCREMENT];
    [self damageButtonHeld:_DAMAGE_INCREMENT];
}

-(void)damageDecButtonPressed
{
    
    [self modifyDamage:-_DAMAGE_INCREMENT];
    [self damageButtonHeld:-_DAMAGE_INCREMENT];
}

-(void)damageButtonHeld: (int)change
{
    static BOOL running; //prevents this "thread" from having more than one copy
    
    if (!running)
    {
        running = YES;
        [self performBlock:^{
            if ((change > 0 && [damageIncButton isHighlighted])
                || (change < 0 && [damageDecButton isHighlighted]))
            {
                for (int i = 0; i < 5; i++)
                    [self modifyDamage:change];
                running = NO;
                [self damageButtonHeld:change];
            }
            else
                running = NO;
        } afterDelay:0.15];
    }
}

/** Assumes currentCard is a monsterCard */
-(void)modifyDamage:(int)change
{
    MonsterCardModel*monster = (MonsterCardModel*)self.currentCardModel;
    
    if ((change > 0 && monster.baseDamage < _MAX_DAMAGE)
        || (change < 0 && monster.baseDamage > _MIN_DAMAGE))
    {
        monster.damage = monster.baseDamage + change;
        [self.currentCardView updateView];
        [self updateCost:self.currentCardModel];
        [self updateExistingAbilityList];
        [self updateNewAbilityList];
    }
    
    [self updateIncrementButton:damageDecButton];
    [self updateIncrementButton:damageIncButton];
}

-(void)lifeIncButtonPressed
{
    [self modifyLife:_LIFE_INCREMENT];
    [self lifeButtonHeld:_LIFE_INCREMENT];
}

-(void)lifeDecButtonPressed
{
    [self modifyLife:-_LIFE_INCREMENT];
    [self lifeButtonHeld:-_LIFE_INCREMENT];
}

-(void)lifeButtonHeld: (int)change
{
    static BOOL running; //prevents this "thread" from having more than one copy
    
    if (!running)
    {
        running = YES;
        [self performBlock:^{
            if ((change > 0 && [lifeIncButton isHighlighted])
                || (change < 0 && [lifeDecButton isHighlighted]))
            {
                for (int i = 0; i < 5; i++)
                    [self modifyLife:change];
                running = NO;
                [self lifeButtonHeld:change];
            }
            else
                running = NO;
        } afterDelay:0.15];
    }
}

/** Assumes currentCard is a monsterCard */
-(void)modifyLife:(int)change
{
    MonsterCardModel*monster = (MonsterCardModel*)self.currentCardModel;
    
    if ((change > 0 && monster.baseMaxLife < _MAX_LIFE)
        || (change < 0 && monster.baseMaxLife > _MIN_LIFE))
    {
        monster.maximumLife = monster.life = monster.baseMaxLife + change;
        [self.currentCardView updateView];
        [self updateCost:self.currentCardModel];
        [self updateExistingAbilityList];
        [self updateNewAbilityList];
    }
    
    [self updateIncrementButton:lifeDecButton];
    [self updateIncrementButton:lifeIncButton];
}

-(void)cdIncButtonPressed
{
    [self modifyCD:_COOLDOWN_INCREMENT];
}

-(void)cdDecButtonPressed
{
    [self modifyCD:-_COOLDOWN_INCREMENT];
}

-(void)modifyCD:(int)change
{
    MonsterCardModel*monster = (MonsterCardModel*)self.currentCardModel;
    
    if ((change > 0 && monster.baseMaxCooldown < _MAX_COOLDOWN)
        || (change < 0 && monster.baseMaxCooldown > _MIN_COOLDOWN))
    {
        monster.maximumCooldown = monster.cooldown = monster.baseMaxCooldown + change;
        [self.currentCardView updateView];
        [self updateCost:self.currentCardModel];
        [self updateExistingAbilityList];
        [self updateNewAbilityList];
    }
    
    [self updateIncrementButton:cdDecButton];
    [self updateIncrementButton:cdIncButton];
    
}

-(void)costIncButtonPressed
{
    [self modifyCost:_COST_INCREMENT];
    [abilityAddButton setEnabled:NO];
}

-(void)costDecButtonPressed
{
    [self modifyCost:-_COST_INCREMENT];
    [abilityAddButton setEnabled:NO];
}

-(void)modifyCost:(int)change
{
    //TODO there is rarity requirement for higher costs
    
    if ((change > 0 && self.currentCardModel.baseCost < [CardPointsUtility getMaxCostForCard:self.currentCardModel])
        || (change < 0 && self.currentCardModel.baseCost > _MIN_COST))
    {
        self.currentCardModel.cost = self.currentCardModel.baseCost + change;
        [self.currentCardView updateView];
        [self updateCost:self.currentCardModel];
        [self updateExistingAbilityList];
        [self updateNewAbilityList]; //changing cost may unlock new abilities
    }
    
    [self updateIncrementButton:costDecButton];
    [self updateIncrementButton:costIncButton];
}

-(void)updateIncrementButton:(UIButton*)button
{
    MonsterCardModel*monster;
    
    if ([self.currentCardModel isKindOfClass:[MonsterCardModel class]])
        monster = (MonsterCardModel*)self.currentCardModel;
    
    if (button == damageDecButton)
    {
        if (monster.baseDamage == _MIN_DAMAGE)
            [damageDecButton setEnabled:NO];
        else
            [damageDecButton setEnabled:YES];
    }
    else if (button == damageIncButton)
    {
        if (monster.baseDamage == _MAX_DAMAGE)
            [damageIncButton setEnabled:NO];
        else
            [damageIncButton setEnabled:YES];
    }
    else if (button == lifeDecButton)
    {
        if (monster.baseMaxLife == _MIN_LIFE)
            [lifeDecButton setEnabled:NO];
        else
            [lifeDecButton setEnabled:YES];
    }
    else if (button == lifeIncButton)
    {
        if (monster.baseMaxLife == _MAX_LIFE)
            [lifeIncButton setEnabled:NO];
        else
            [lifeIncButton setEnabled:YES];
    }
    else if (button == cdDecButton)
    {
        if (monster.maximumCooldown == _MIN_COOLDOWN)
            [cdDecButton setEnabled:NO];
        else
            [cdDecButton setEnabled:YES];
    }
    else if (button == cdIncButton)
    {
        if (monster.maximumCooldown == _MAX_COOLDOWN)
            [cdIncButton setEnabled:NO];
        else
            [cdIncButton setEnabled:YES];
    }
    else if (button == costDecButton)
    {
        if (self.currentCardModel.baseCost == _MIN_COST)
            [costDecButton setEnabled:NO];
        else
            [costDecButton setEnabled:YES];
    }
    else if (button == costIncButton)
    {
        if (self.currentCardModel.baseCost == [CardPointsUtility getMaxCostForCard:self.currentCardModel])
            [costIncButton setEnabled:NO];
        else
            [costIncButton setEnabled:YES];
    }
}

-(void)updateAllIncrementButtons
{
    if ([self.currentCardModel isKindOfClass:[MonsterCardModel class]])
    {
        [self updateIncrementButton:damageDecButton];
        [self updateIncrementButton:damageIncButton];
        [self updateIncrementButton:lifeDecButton];
        [self updateIncrementButton:lifeIncButton];
        [self updateIncrementButton:cdDecButton];
        [self updateIncrementButton:cdIncButton];
    }
    
    [self updateIncrementButton:costDecButton];
    [self updateIncrementButton:costIncButton];
}


-(void)abilityIncButtonPressed
{
    NSIndexPath *selectedIndexPath = [abilityExistingTableView.tableView indexPathForSelectedRow];
    AbilityWrapper *wrapper = abilityExistingTableView.currentAbilities[selectedIndexPath.row];
    
    wrapper.ability.value =  [NSNumber numberWithInt:([wrapper.ability.value integerValue] + wrapper.incrementSize)];
    
    [abilityExistingTableView reloadInputViews];
    [abilityExistingTableView.tableView reloadData];
    
    [abilityExistingTableView.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    [self updateCost:self.currentCardModel];
    
    [self updateAbilityButtons:wrapper];
}

-(void)abilityDecButtonPressed
{
    NSIndexPath *selectedIndexPath = [abilityExistingTableView.tableView indexPathForSelectedRow];
    AbilityWrapper *wrapper = abilityExistingTableView.currentAbilities[selectedIndexPath.row];
    
    wrapper.ability.value = [NSNumber numberWithInt:([wrapper.ability.value integerValue] - wrapper.incrementSize)];
    
    [abilityExistingTableView reloadInputViews];
    [abilityExistingTableView.tableView reloadData];
    
    [abilityExistingTableView.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    [self updateCost:self.currentCardModel];
    
    [self updateAbilityButtons:wrapper];
}

-(void)abilityAddButtonPressed
{
    NSIndexPath *selectedIndexPath = [abilityNewTableView.tableView indexPathForSelectedRow];
    
    if (selectedIndexPath!=nil)
    {
        AbilityWrapper *wrapper = abilityNewTableView.currentAbilities[selectedIndexPath.row];
        
        /*
         [abilityNewTableView setAbilityAt:selectedIndexPath toState:NO];
         [abilityNewTableView.tableView reloadData];
         [abilityNewTableView reloadInputViews];
         */
        
        //[abilityAddButton setEnabled:NO];
        
        AbilityWrapper *dupWrapper = [[AbilityWrapper alloc] initWithAbilityWrapper:wrapper];
        if (dupWrapper.ability.otherValues.count > 0)
            dupWrapper.ability.value = dupWrapper.ability.otherValues[0];
        
        
        [abilityExistingTableView.currentAbilities addObject:dupWrapper];
        [abilityExistingTableView.tableView reloadData];
        [abilityExistingTableView reloadInputViews];
        
        //update new abilities
        [self.currentCardModel addBaseAbility:dupWrapper.ability];
        
        
        [self abilityEditAreaSetEnabled:YES];
        
     
        
        [self updateCost:self.currentCardModel];
        [self updateNewAbilityList];
    }
}

-(void)updateNewAbilityList
{
    //[self loadAllValidAbilities];
    
    //int i = 0;
    for (AbilityWrapper*wrapper in abilityNewTableView.currentAbilities)
    {
        wrapper.enabled = YES;
        
        //update the icon in the tableView
        [CardPointsUtility updateAbilityPoints:self.currentCardModel forWrapper:wrapper withWrappers:abilityExistingTableView.currentAbilities];
        
        for (AbilityWrapper*existingWrapper in abilityExistingTableView.currentAbilities)
        {
            if ([existingWrapper.ability isEqualTypeTo:wrapper.ability])
            {
                //NSLog(@"NOT ENABLED DUE TO EQUAL TYPE: %@", [[Ability getDescription:wrapper.ability fromCard:_currentCardModel]string]);
                wrapper.enabled = NO;
                break;
            }
        }
        
        if (![wrapper isCompatibleWithCardModel:self.currentCardModel])
        {
            //NSLog(@"NOT ENABLED DUE COMPATIBILITY OR COST %@", [[Ability getDescription:wrapper.ability fromCard:_currentCardModel]string]);
            wrapper.enabled = NO;
        }
        
        if (wrapper.minCost > self.currentCardModel.cost)
            wrapper.enabled = NO;
        
        //max count reached
        if ([CardPointsUtility getMaxAbilityCountForCard:self.currentCardModel] <= self.currentCardModel.abilities.count)
            wrapper.enabled = NO;
    }
    
    [abilityNewTableView.tableView reloadData];
    [abilityNewTableView reloadInputViews];
    
    NSIndexPath *selectedPath = [abilityNewTableView.tableView indexPathForSelectedRow];
    if (selectedPath != nil)
    {
        //if reached max ability limit, disable it
        if ([CardPointsUtility getMaxAbilityCountForCard:self.currentCardModel] > self.currentCardModel.abilities.count)
            [abilityAddButton setEnabled:[abilityNewTableView.currentAbilities[selectedPath.row] enabled]];
        else
            [abilityAddButton setEnabled:NO];
    }
}

/** Only for when changing the element etc., to remove abilities that are no longer compatible */
-(void)updateExistingAbilityList
{
    for (int i = abilityExistingTableView.currentAbilities.count - 1; i >= 0; i--)
    {
        AbilityWrapper*wrapper = abilityExistingTableView.currentAbilities[i];
        
        //update the icon in the tableView
        [CardPointsUtility updateAbilityPoints:self.currentCardModel forWrapper:wrapper withWrappers:abilityExistingTableView.currentAbilities];
        
        if (![wrapper isCompatibleWithCardModel:self.currentCardModel] || wrapper.minCost > self.currentCardModel.cost)
        {
            [abilityExistingTableView.currentAbilities removeObjectAtIndex:i];
            
            //remove from monster
            [self.currentCardModel.abilities removeObject:wrapper.ability];
        }
    }
    
    [abilityExistingTableView.tableView reloadData];
    [abilityExistingTableView reloadInputViews];
    [self.currentCardView updateView];
}

-(void)abilityRemoveButtonPressed
{
    NSIndexPath *selectedIndexPath = [abilityExistingTableView.tableView indexPathForSelectedRow];
    
    if (selectedIndexPath!=nil)
    {
        AbilityWrapper *wrapper = abilityExistingTableView.currentAbilities[selectedIndexPath.row];
        
        //remove from monster
        [self.currentCardModel.abilities removeObject:wrapper.ability];
        
        //enable the wrapper back in newAbilities
        for (AbilityWrapper*newWrapper in abilityNewTableView.currentAbilities)
        {
            if ([newWrapper.ability isEqualTypeTo:wrapper.ability])
            {
                newWrapper.enabled = YES;
                break;
            }
        }
        
        //remove from table
        [abilityExistingTableView.currentAbilities removeObjectAtIndex:selectedIndexPath.row];
        
        [abilityRemoveButton setEnabled:NO];
        [abilityIncButton setEnabled:NO];
        [abilityDecButton setEnabled:NO];
        
        [self updateCost:self.currentCardModel];
        
        [self updateNewAbilityList];
        [self updateExistingAbilityList];
    }
}

-(void)reloadCardView
{
    UIImage*originalImage = self.cardImage;
    [_currentCardView removeFromSuperview];
    
    
    _currentCardView = [[CardView alloc] initWithModel:self.currentCardModel withImage:originalImage viewMode:cardViewModeEditor];
    
    _currentCardView.frontFacing = YES;
    _currentCardView.cardViewState = cardViewStateCardViewer;
    _currentCardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_EDITOR_SCALE, CARD_EDITOR_SCALE);
    _currentCardView.nameLabel.alpha = 0; //don't ever show the name label, since it's taken over by nameTextField
    
    _currentCardView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/3);
    
    [_currentCardView updateView];
    [self.view addSubview:_currentCardView];
}

-(void)removeAllStatButtons
{
    [damageDecButton removeFromSuperview];
    [damageIncButton removeFromSuperview];
    [lifeDecButton removeFromSuperview];
    [lifeIncButton removeFromSuperview];
    [cdDecButton removeFromSuperview];
    [cdIncButton removeFromSuperview];
    [costDecButton removeFromSuperview];
    [costIncButton removeFromSuperview];
}

-(void)updateCost:(CardModel*)card
{
    self.currentCost = 0;
    
    self.maxCost = [CardPointsUtility getMaxPointsForCard:self.currentCardModel];
    
    for (int i = 0; i < abilityExistingTableView.currentAbilities.count; i++)
    {
        AbilityWrapper *wrapper = abilityExistingTableView.currentAbilities[i];
        
        [CardPointsUtility updateAbilityPoints:card forWrapper:wrapper withWrappers:abilityExistingTableView.currentAbilities];
        
        //update the icon in the tableView
        AbilityTableViewCell* cell = (AbilityTableViewCell*)[abilityExistingTableView.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.abilityPoints.text = [NSString stringWithFormat:@"%d", wrapper.currentPoints];
        
        self.currentCost += wrapper.currentPoints;
    }
    
    //monster cards add stats into cost
    if ([card isKindOfClass:[MonsterCardModel class]])
    {
        MonsterCardModel*monster = (MonsterCardModel*)card;
        self.currentCost += [CardPointsUtility getStatsPointsForMonsterCard:monster];
    }
    
    currentCostLabel.text = [NSString stringWithFormat:@"%d", self.currentCost];
    maxCostLabel.text = [NSString stringWithFormat:@"%d", self.maxCost];
    
    if (self.currentCost > self.maxCost)
    {
        currentCostLabel.textColor = [UIColor redColor];
        //[saveCardButton setEnabled:NO];
    }
    else if(_editorMode != cardEditorModeTutorialOne)
    {
        currentCostLabel.textColor = [UIColor whiteColor];
        //[saveCardButton setEnabled:YES];
    }
}

-(void)setupExistingCard
{
    //[self reloadCardView];
    
    /*
     [self resetAbilityViews];
     [self selectElement: _currentCardModel.element];
     [self updateCost:self.currentCardModel];
     */
    
    //create a new array since the original does not include otherValues
    NSArray*originalAbilities = self.currentCardModel.abilities;
    self.currentCardModel.abilities = [NSMutableArray arrayWithCapacity:originalAbilities.count];
    
    //add abilities:
    for (Ability*ability in originalAbilities)
    {
        for (AbilityWrapper *wrapper in abilityNewTableView.currentAbilities)
        {
            if ([wrapper.ability isEqualTypeTo: ability])
            {
                AbilityWrapper *dupWrapper = [[AbilityWrapper alloc] initWithAbilityWrapper:wrapper];
                wrapper.enabled = NO;
                dupWrapper.ability.value = ability.value;
                [self.currentCardModel addBaseAbility:dupWrapper.ability];
                
                [abilityExistingTableView.currentAbilities addObject:dupWrapper];
                [self abilityEditAreaSetEnabled:YES];
                break;
            }
        }
    }
    
    [_currentCardView updateView];
    
    [abilityExistingTableView.tableView reloadData];
    [abilityExistingTableView reloadInputViews];
}


-(void)monsterButtonPressed
{
    [self setupNewMonster];
    
    [self resetAbilityViews];
    [self updateCost:self.currentCardModel];
    [self selectElement: self.currentCardModel.element];
    
    [self updateCardTypeButtons];
    [self removeAllStatButtons];
    [self abilityEditAreaSetEnabled:NO];
    
    [self reloadCardView];
}

-(void)setupNewMonster
{
    MonsterCardModel*monster = [[MonsterCardModel alloc] initWithIdNumber:NO_ID];
    
    monster.life = monster.maximumLife = 1000;
    monster.damage = 1000;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    
    //TUTORIAL default stats
    if (_editorMode == cardEditorModeTutorialOne)
    {
        monster.damage = 1400;
        monster.life = monster.maximumLife = 2600;
    }
    else if (_editorMode == cardEditorModeTutorialTwo)
    {
        monster.damage = 1400;
        monster.life = monster.maximumLife = 2600;
        if (userTutorialOneCardName!=nil)
            monster.name = userTutorialOneCardName;
    }
    
    if (self.currentCardModel!=nil)
    {
        monster.name = self.currentCardModel.name;
        monster.cost = self.currentCardModel.cost;
        monster.element = self.currentCardModel.element;
    }
    else
        monster.name = @"";
    
    self.currentCardModel = monster;
    abilityNewTableView.currentCard = self.currentCardModel;
    abilityExistingTableView.currentCard = self.currentCardModel;
}

-(void)spellButtonPressed
{
    [self setupNewSpell];
    
    [self resetAbilityViews];
    [self updateCost:self.currentCardModel];
    [self selectElement: self.currentCardModel.element];
    
    [self updateCardTypeButtons];
    [self removeAllStatButtons];
    [self abilityEditAreaSetEnabled:NO];
    
    [self reloadCardView];
}

-(void)setupNewSpell
{
    SpellCardModel*spell = [[SpellCardModel alloc] initWithIdNumber:-1];
    spell.cost = 1;
    
    if (self.currentCardModel!=nil)
    {
        spell.name = self.currentCardModel.name;
        spell.cost = self.currentCardModel.cost;
        spell.element = self.currentCardModel.element;
    }
    else
        spell.name = @"";
    
    self.currentCardModel = spell;
    abilityNewTableView.currentCard = self.currentCardModel;
    abilityExistingTableView.currentCard = self.currentCardModel;
}


-(void)resetAbilityViews
{
    NSLog(@"resetting ability views");
    [abilityExistingTableView.currentAbilities removeAllObjects];
    [abilityExistingTableView.tableView reloadData];
    [abilityExistingTableView.tableView reloadInputViews];
    
    [abilityNewTableView.currentAbilities removeAllObjects];
    [self loadAllValidAbilities];
    [abilityNewTableView.tableView reloadData];
    [abilityNewTableView.tableView reloadInputViews];
}

-(void)updateCardTypeButtons
{
//    if (_editorMode == cardEditorModeCreation || _editorMode == cardEditorModeTutorialThree)
//    {
//        if ([self.currentCardModel isKindOfClass:[MonsterCardModel class]])
//        {
//            spellCardButton.enabled = YES;
//            monsterCardButton.enabled = NO;
//        }
//        else
//        {
//            spellCardButton.enabled = NO;
//            monsterCardButton.enabled = YES;
//        }
//    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

/** When OK is pressed and the card is sent to Parse database */
- (void) publishCurrentCard
{
    //get rid of the confirm screen
    [self confirmCancelButtonPressed];
    
//    _cardUploadIndicator.alpha = 0;
//    _cardUploadLabel.text = [NSString stringWithFormat:@"Uploading Card..."];
//    [_cardUploadIndicator setColor:[UIColor whiteColor]];
//    [self.view addSubview:_cardUploadIndicator];
//    [_cardUploadIndicator startAnimating];
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         _cardUploadIndicator.alpha = 1;
//                     }
//                     completion:^(BOOL completed){
//                         [self performBlock:^{
//                             BOOL succ = [UserModel publishCard:self.currentCardModel withImage:self.currentCardView.cardImage.image];
//                             
//                             if (succ)
//                             {
//                                 [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                                                  animations:^{
//                                                      _cardUploadIndicator.alpha = 0;
//                                                  }
//                                                  completion:^(BOOL completed){
//                                                      [_cardUploadIndicator stopAnimating];
//                                                      [_cardUploadIndicator removeFromSuperview];
//                                                      
//                                                      [self dismissViewControllerAnimated:YES completion:nil];
//                                                  }];
//                             }
//                             else
//                             {
//                                 [_cardUploadIndicator setColor:[UIColor clearColor]];
//                                 _cardUploadLabel.text = [NSString stringWithFormat:@"Error uploading card."];
//                                 _cardUploadFailedButton.alpha = 0;
//                                 [_cardUploadIndicator addSubview:_cardUploadFailedButton];
//                                 [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                                                  animations:^{
//                                                      _cardUploadFailedButton.alpha = 1;
//                                                  }
//                                                  completion:^(BOOL completed){
//                                                      [_cardUploadFailedButton setUserInteractionEnabled:YES];
//                                                  }];
//                             }
//                         }];
//                     }];
}

-(void)updateCardForRarity
{
    //get rid of the confirm screen
    [self confirmCancelButtonPressed];
    
//    _cardUploadIndicator.alpha = 0;
//    _cardUploadLabel.text = [NSString stringWithFormat:@"Updating Card..."];
//    [_cardUploadIndicator setColor:[UIColor whiteColor]];
//    [self.view addSubview:_cardUploadIndicator];
//    [_cardUploadIndicator startAnimating];
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         _cardUploadIndicator.alpha = 1;
//                     }
//                     completion:^(BOOL completed){
//                         [self performBlock:^{
//                             //BOOL succ = [UserModel publishCard:self.currentCardModel withImage:self.currentCardView.cardImage.image];
//                             //TODOBrianJune13, usermodel needs function to update card
//                             BOOL succ = [UserModel updateCard:self.currentCardModel];
//                             if (succ)
//                             {
//                                 [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                                                  animations:^{
//                                                      _cardUploadIndicator.alpha = 0;
//                                                  }
//                                                  completion:^(BOOL completed){
//                                                      [_cardUploadIndicator stopAnimating];
//                                                      [_cardUploadIndicator removeFromSuperview];
//                                                      
//                                                      //if the cardEditor was sprung by the cardCollectionView, notify the delegate to replace the card with the latest stats
//                                                      if(self.delegate !=nil)
//                                                      {
//                                                          [self.delegate cardUpdated:self.currentCardModel];
//                                                          
//                                                      }
//                                                      
//                                                      [self dismissViewControllerAnimated:YES completion:nil];
//                                                      
//                                                      
//                                                      
//                                                      
//                                                  }];
//                             }
//                             else
//                             {
//                                 [_cardUploadIndicator setColor:[UIColor clearColor]];
//                                 _cardUploadLabel.text = [NSString stringWithFormat:@"Error uploading card."];
//                                 _cardUploadFailedButton.alpha = 0;
//                                 [_cardUploadIndicator addSubview:_cardUploadFailedButton];
//                                 [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                                                  animations:^{
//                                                      _cardUploadFailedButton.alpha = 1;
//                                                  }
//                                                  completion:^(BOOL completed){
//                                                      [_cardUploadFailedButton setUserInteractionEnabled:YES];
//                                                  }];
//                             }
//                         }];
//                     }];
}

-(void)cardUploadFailedButtonPressed
{
//    [_cardUploadFailedButton setUserInteractionEnabled:NO];
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         _cardUploadIndicator.alpha = 0;
//                     }
//                     completion:^(BOOL completed){
//                         [_cardUploadFailedButton removeFromSuperview];
//                     }];
    
}

-(void)cardVoteFailedButtonPressed
{
//    [_cardVoteFailedButton setUserInteractionEnabled:NO];
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         _cardVoteIndicator.alpha = 0;
//                     }
//                     completion:^(BOOL completed){
//                         [_cardVoteFailedButton removeFromSuperview];
//                     }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    UIView*touchedView = touch.view;
    
    if ([self.currentCardModel isKindOfClass:[MonsterCardModel class]])
    {
        if (touchedView == damageEditArea)
        {
            [self.view addSubview:damageDecButton];
            [self.view addSubview:damageIncButton];
            damageDecButton.alpha = 0;
            damageIncButton.alpha = 0;
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 damageDecButton.alpha = 1;
                                 damageIncButton.alpha = 1;
                             }
                             completion:^(BOOL completed){
                                 
                             }];
        }
        else if (touchedView != self.currentCardView)
        {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 damageDecButton.alpha = 0;
                                 damageIncButton.alpha = 0;
                             }
                             completion:^(BOOL completed){
                                 [damageDecButton removeFromSuperview];
                                 [damageIncButton removeFromSuperview];
                             }];
        }
        
        
        if (touchedView == lifeEditArea)
        {
            [self.view addSubview:lifeDecButton];
            [self.view addSubview:lifeIncButton];
            lifeDecButton.alpha = 0;
            lifeIncButton.alpha = 0;
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 lifeDecButton.alpha = 1;
                                 lifeIncButton.alpha = 1;
                             }
                             completion:^(BOOL completed){
                                 
                             }];
        }
        else if (touchedView != self.currentCardView)
        {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 lifeDecButton.alpha = 0;
                                 lifeIncButton.alpha = 0;
                             }
                             completion:^(BOOL completed){
                                 [lifeDecButton removeFromSuperview];
                                 [lifeIncButton removeFromSuperview];
                             }];
        }
        
        if (touchedView == cdEditArea)
        {
            [self.view addSubview:cdDecButton];
            [self.view addSubview:cdIncButton];
            cdDecButton.alpha = 0;
            cdIncButton.alpha = 0;
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 cdDecButton.alpha = 1;
                                 cdIncButton.alpha = 1;
                             }
                             completion:^(BOOL completed){
                                 
                             }];
        }
        else if (touchedView != self.currentCardView)
        {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 cdDecButton.alpha = 0;
                                 cdIncButton.alpha = 0;
                             }
                             completion:^(BOOL completed){
                                 [cdDecButton removeFromSuperview];
                                 [cdIncButton removeFromSuperview];
                             }];
        }
    }
    
    if (touchedView == costEditArea)
    {
        [self.view addSubview:costDecButton];
        [self.view addSubview:costIncButton];
        costDecButton.alpha = 0;
        costIncButton.alpha = 0;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             costDecButton.alpha = 1;
                             costIncButton.alpha = 1;
                         }
                         completion:^(BOOL completed){
                             
                         }];
    }
    else if (touchedView == elementEditArea)
    {
        [self openElementEditScreen];
    }
    else if (touchedView == imageEditArea)
    {
        //[self openImageUploadScreen];
    }
    else if (touchedView != self.currentCardView)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             costDecButton.alpha = 0;
                             costIncButton.alpha = 0;
                         }
                         completion:^(BOOL completed){
                             [costDecButton removeFromSuperview];
                             [costIncButton removeFromSuperview];
                         }];
    }
    
    [self abilityEditAreaSetEnabled:touchedView == abilityEditArea];
}

-(void)selectElement:(enum CardElement)element
{
//    if (element == elementNeutral)
//    {
//        [self zoomElementLabel:neutralLabel];
//        self.currentCardModel.element = elementNeutral;
//        elementDescriptionLabel.text = @"Neutral cards don't have particularily power abilities of their own, but they are compatible with all other elements, making them a good addition in any deck.";
//    }
//    else if (element == elementFire)
//    {
//        [self zoomElementLabel:fireLabel];
//        self.currentCardModel.element = elementFire;
//        elementDescriptionLabel.text = @"Fire cards excel in dealing massive, direct damage. They also have many area-of-effect abilities that can quickly wipe their opponent's board. They cannot coexist with Ice cards in a deck.";
//    }
//    else if (element == elementIce)
//    {
//        [self zoomElementLabel:iceLabel];
//        self.currentCardModel.element = elementIce;
//        elementDescriptionLabel.text = @"Ice cards specialize in defensive abilities such as cooldown extension to stall their opponent's attack. They cannot coexist with Fire cards in a deck.";
//    }
//    else if (element == elementLightning)
//    {
//        [self zoomElementLabel:lightningLabel];
//        self.currentCardModel.element = elementLightning;
//        elementDescriptionLabel.text = @"Thunder cards deals rapid, and often random attacks that can quickly overwhelm their opponents if they are unprepared. They cannot coexist with Earth cards in a deck.";
//    }
//    else if (element == elementEarth)
//    {
//        [self zoomElementLabel:earthLabel];
//        self.currentCardModel.element = elementEarth;
//        elementDescriptionLabel.text = @"Earth cards often start out as weak minions, but if left unchecked, can grow to become incredibly powerful. They cannot coexist with Thunder cards in a deck.";
//    }
//    else if (element == elementLight)
//    {
//        [self zoomElementLabel:lightLabel];
//        self.currentCardModel.element = elementLight;
//        elementDescriptionLabel.text = @"Light cards focuses on healing and strengthening friendly creatures. They are able to increase the effectiveness of even the weakest creatures. They cannot coexist with Dark cards in a deck.";
//    }
//    else if (element == elementDark)
//    {
//        [self zoomElementLabel:darkLabel];
//        self.currentCardModel.element = elementDark;
//        elementDescriptionLabel.text = @"Dark cards usually have extremely powerful minions and abilities that require sacrifices from the caster. They cannot coexist with Light cards in a deck.";
//    }
//    
//    [elementDescriptionLabel setFrame: CGRectMake(140, SCREEN_HEIGHT/6, SCREEN_WIDTH-140-20, SCREEN_HEIGHT)];
//    [elementDescriptionLabel sizeToFit];
}

-(void)zoomElementLabel:(UIView*)view
{
    [self resetAllElementLabelsExcept:view];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
                     }
                     completion:^(BOOL completed){
                         
                     }];
}

-(void)resetAllElementLabelsExcept:(UIView*)view
{
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         if (neutralLabel != view)
//                             neutralLabel.transform = CGAffineTransformIdentity;
//                         if (fireLabel != view)
//                             fireLabel.transform = CGAffineTransformIdentity;
//                         if (iceLabel != view)
//                             iceLabel.transform = CGAffineTransformIdentity;
//                         if (lightningLabel != view)
//                             lightningLabel.transform = CGAffineTransformIdentity;
//                         if (earthLabel != view)
//                             earthLabel.transform = CGAffineTransformIdentity;
//                         if (lightLabel != view)
//                             lightLabel.transform = CGAffineTransformIdentity;
//                         if (darkLabel != view)
//                             darkLabel.transform = CGAffineTransformIdentity;
//                     }
//                     completion:^(BOOL completed){
//                         
//                     }];
}

-(void)abilityEditAreaSetEnabled:(BOOL)state
{
    //enable
    if (state )
    {
        //if there are no active abilities, do not show these buttons
        if([self.currentCardModel.abilities count] ==0)
        {
            return;
            
        }

        
        [abilityAddButton setEnabled:NO]; //turn off the other table's buttons/
        [abilityNewTableView.tableView deselectRowAtIndexPath:abilityNewTableView.tableView.indexPathForSelectedRow animated:YES];
        
        //enable editing buttons
        [self.view addSubview:abilityIncButton];
        [self.view addSubview:abilityDecButton];
        [self.view addSubview:abilityRemoveButton];
        [self.view insertSubview:abilityExistingTableView aboveSubview:abilityEditArea];
        abilityIncButton.alpha = 0;
        abilityDecButton.alpha = 0;
        abilityRemoveButton.alpha = 0;
        abilityExistingTableView.alpha = 0;
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             abilityIncButton.alpha = 1;
                             abilityDecButton.alpha = 1;
                             abilityRemoveButton.alpha = 1;
                             abilityExistingTableView.alpha = 1;
                             
                             self.currentCardView.baseAbilityLabel.alpha = 0; //hide base ability
                         }
                         completion:^(BOOL completed){
                             
                         }];
    }
    else
    {
        [self.currentCardView updateView];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             abilityIncButton.alpha = 0;
                             abilityDecButton.alpha = 0;
                             abilityRemoveButton.alpha = 0;
                             abilityExistingTableView.alpha = 0;
                             
                             self.currentCardView.baseAbilityLabel.alpha = 1;
                         }
                         completion:^(BOOL completed){
                             [abilityIncButton removeFromSuperview];
                             [abilityDecButton removeFromSuperview];
                             [abilityRemoveButton removeFromSuperview];
                             [abilityExistingTableView removeFromSuperview];
                         }];
    }
}

-(void)openElementEditScreen
{
    [self darkenScreen];
    
    int yDistance = SCREEN_HEIGHT/8;
    int xDistance = 70;
    
//    neutralLabel.center = CGPointMake(xDistance, yDistance * 1);
//    fireLabel.center = CGPointMake(xDistance, yDistance * 2);
//    iceLabel.center = CGPointMake(xDistance, yDistance * 3);
//    lightningLabel.center = CGPointMake(xDistance, yDistance * 4);
//    earthLabel.center = CGPointMake(xDistance, yDistance * 5);
//    lightLabel.center = CGPointMake(xDistance, yDistance * 6);
//    darkLabel.center = CGPointMake(xDistance, yDistance * 7);
//    
//    neutralLabel.alpha = 0;
//    fireLabel.alpha = 0;
//    iceLabel.alpha = 0;
//    lightningLabel.alpha = 0;
//    earthLabel.alpha = 0;
//    lightLabel.alpha = 0;
//    darkLabel.alpha = 0;
//    elementConfirmButton.alpha = 0;
//    elementDescriptionLabel.alpha = 0;
//    
//    [self.view addSubview:neutralLabel];
//    [self.view addSubview:fireLabel];
//    [self.view addSubview:iceLabel];
//    [self.view addSubview:lightningLabel];
//    [self.view addSubview:earthLabel];
//    [self.view addSubview:lightLabel];
//    [self.view addSubview:darkLabel];
//    [self.view addSubview:elementConfirmButton];
//    [self.view addSubview:elementDescriptionLabel];
//    
//    [elementDescriptionLabel setFrame: CGRectMake(140, SCREEN_HEIGHT/6, SCREEN_WIDTH-140-20, SCREEN_HEIGHT)];
//    elementDescriptionLabel.numberOfLines = 0;
//    elementDescriptionLabel.textAlignment = NSTextAlignmentLeft;
//    elementDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    [elementDescriptionLabel sizeToFit];
//    
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         neutralLabel.alpha = 1;
//                         fireLabel.alpha = 1;
//                         iceLabel.alpha = 1;
//                         lightningLabel.alpha = 1;
//                         earthLabel.alpha = 1;
//                         lightLabel.alpha = 1;
//                         darkLabel.alpha = 1;
//                         elementConfirmButton.alpha = 1;
//                         elementDescriptionLabel.alpha = 1;
//                     }
//                     completion:^(BOOL completed){
//                     }];
}

-(void)elementConfirmButtonPressed
{
    [self undarkenScreen];
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         neutralLabel.alpha = 0;
//                         fireLabel.alpha = 0;
//                         iceLabel.alpha = 0;
//                         lightningLabel.alpha = 0;
//                         earthLabel.alpha = 0;
//                         lightLabel.alpha = 0;
//                         darkLabel.alpha = 0;
//                         elementConfirmButton.alpha = 0;
//                         elementDescriptionLabel.alpha = 0;
//                     }
//                     completion:^(BOOL completed){
//                         [neutralLabel removeFromSuperview];
//                         [fireLabel removeFromSuperview];
//                         [iceLabel removeFromSuperview];
//                         [lightningLabel removeFromSuperview];
//                         [earthLabel removeFromSuperview];
//                         [lightLabel removeFromSuperview];
//                         [darkLabel removeFromSuperview];
//                         [elementConfirmButton removeFromSuperview];
//                         [elementDescriptionLabel removeFromSuperview];
//                     }];
    
    //[self resetAbilityViews];
    [self updateExistingAbilityList];
    [abilityNewTableView.currentAbilities removeAllObjects];
    [self loadAllValidAbilities];
    [self updateNewAbilityList];
    [self reloadCardView];
    [self updateCost:self.currentCardModel];
}



-(void)rowSelected:(AbilityTableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    if (tableView == abilityNewTableView)
    {
        if (indexPath.row < 0 || indexPath.row >= abilityNewTableView.currentAbilities.count) //being defensive
            return;
        
        if ([CardPointsUtility getMaxAbilityCountForCard:self.currentCardModel] > self.currentCardModel.abilities.count)
            //[abilityAddButton setEnabled:[abilityNewTableView.currentAbilities[indexPath.row] enabled]];
            [self abilityAddButtonPressed];
        else
            [abilityAddButton setEnabled:NO];
        
        //[self abilityEditAreaSetEnabled:NO]; //turn off the other table's buttons
        
        [self removeAllStatButtons];
    }
    else if (tableView == abilityExistingTableView)
    {
        if (indexPath.row < 0 || indexPath.row >= abilityExistingTableView.currentAbilities.count) //being defensive
            return;
        
        [abilityRemoveButton setEnabled:YES];
        
        AbilityWrapper *wrapper = abilityExistingTableView.currentAbilities[indexPath.row];
        
        [self updateAbilityButtons:wrapper];
    }
}

-(void)updateAbilityButtons:(AbilityWrapper*)wrapper
{
    Ability *ability = wrapper.ability;
    
    //enable the abilityInc and Dec buttons
    if (ability.value != nil && ability.otherValues.count >= 2)
    {
        if ([ability.value integerValue] > [ability.otherValues[0] integerValue])
            [abilityDecButton setEnabled:YES];
        else
            [abilityDecButton setEnabled:NO];
        
        if ([ability.value integerValue] < [ability.otherValues[1] integerValue])
            [abilityIncButton setEnabled:YES];
        else
            [abilityIncButton setEnabled:NO];
    }
    else
    {
        [abilityIncButton setEnabled:NO];
        [abilityDecButton setEnabled:NO];
    }
}

/** Loads all valid abilities (i.e. matches the rarity and element type) into the new ability table */
-(void)loadAllValidAbilities
{
    NSArray*allAbilities = [AbilityWrapper allAbilities];
    
    NSMutableArray*cardAbilitiesBackup;
    if (_editorMode == cardEditorModeVoting)
    {
        //clear the abilities temporarily to prevent some abilities not added to the list
        cardAbilitiesBackup = self.currentCardModel.abilities;
        self.currentCardModel.abilities = [NSMutableArray array];
    }
    
    for (AbilityWrapper*wrapper in allAbilities)
    {
        //must be valid element and rarity
        if ([wrapper isCompatibleWithCardModel:self.currentCardModel])
        {
            if ([self.currentCardModel.abilities containsObject:wrapper]) {
                wrapper.enabled = false;
            }
            
            [abilityNewTableView.currentAbilities addObject:wrapper];
            if (wrapper.ability.otherValues != nil && wrapper.ability.otherValues.count >= 2)
            {
                NSNumber *valueA = wrapper.ability.otherValues[0];
                NSNumber *valueB = wrapper.ability.otherValues[1];
                wrapper.ability.value = abs(wrapper.minPoints) < abs(wrapper.maxPoints) ? valueA : valueB;
            }
            else
                wrapper.ability.value = 0;
        }
    }
    
    if (_editorMode == cardEditorModeVoting)
        self.currentCardModel.abilities = cardAbilitiesBackup;
    
    //sort the valid abilities
    [abilityNewTableView.currentAbilities sortUsingComparator:^(AbilityWrapper* a, AbilityWrapper* b){
        NSString *aString = [[Ability getDescription:a.ability fromCard:self.currentCardModel] string];
        NSString *bString = [[Ability getDescription:b.ability fromCard:self.currentCardModel] string];
        return [aString compare:bString];
    }];
    
    [self updateNewAbilityList];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void)tutorialThreeSaveWarning
{
    
}

-(void)saveCardButtonPressed
{
    [self darkenScreen];
    
    BOOL tutThreeWarning = NO;
    
    //tutorial one has no confirmation since the card is not actually sent online
//    if (_editorMode == cardEditorModeTutorialOne)
//    {
//        [self saveCardConfirmButtonPressed];
//        return;
//    }
//    else if (_editorMode == cardEditorModeTutorialThree)
//    {
//        NSNumber *cardOneID = userPF[@"cardOneID"];
//        if (cardOneID != nil)
//        {
//            for (CardModel*card in userAllCards)
//            {
//                if (card.idNumber == [cardOneID intValue])
//                {
//                    //put the two cards into a deck to check its validity
//                    DeckModel*tempDeck = [[DeckModel alloc]init];
//                    [tempDeck addCard:_currentCardModel];
//                    [tempDeck addCard:card];
//                    
//                    [DeckModel validateDeckIgnoreTooFewCards:tempDeck];
//                    if (tempDeck.isInvalid)
//                        tutThreeWarning = YES;
//                    
//                    break;
//                }
//            }
//        }
//    }
//    
//    NSMutableArray *noDupTags = [self getTags];
//    
//    saveCardConfirmLabel.alpha = 0;
//    saveCardConfirmButton.alpha = 0;
//    confirmCancelButton.alpha = 0;
//    confirmErrorOkButton.alpha = 0;
//    
//    //check for errors
//    if ([nameTextField text].length == 0 && _editorMode != cardEditorModeVoting)
//    {
//        saveCardConfirmLabel.text = @"Please enter a name for your card.";
//        [self.view addSubview:confirmErrorOkButton];
//    }
//    else if (_currentCardView.cardImage.image == CARD_EDITOR_EMPTY_IMAGE && _editorMode != cardEditorModeVoting)
//    {
//        saveCardConfirmLabel.text = @"Please choose an image for your card.";
//        [self.view addSubview:confirmErrorOkButton];
//    }
//    else if (noDupTags.count < 3 && _editorMode != cardEditorModeVoting)
//    {
//        saveCardConfirmLabel.text = @"Please enter 3 or more different tags, separated by spaces.";
//        [self.view addSubview:confirmErrorOkButton];
//    }
//    else
//    {
//        if (tutThreeWarning)
//            saveCardConfirmLabel.text = @"Warning: This card is not compatible with your last card and cannot be placed into the same deck after the tutorial. Are you sure you want to create it?";
//        else if (_editorMode == cardEditorModeVoting)
//            saveCardConfirmLabel.text = @"Are you sure you want to cast your vote? You will not be able to edit it again.";
//        else if(_editorMode ==cardEditorModeRarityUpdate)
//        {
//            saveCardConfirmLabel.text = @"Are you sure you want to update your card with these stats/abilities?  You will not be able to edit it again.";
//        }
//        else
//            saveCardConfirmLabel.text = @"Are you sure you want to create this card? You will not be able to edit it again.";
//        [self.view addSubview:saveCardConfirmButton];
//        [self.view addSubview:confirmCancelButton];
//    }
//    
//    [self.view addSubview:saveCardConfirmLabel];
//    
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         saveCardConfirmLabel.alpha = 1;
//                         saveCardConfirmButton.alpha = 1;
//                         confirmCancelButton.alpha = 1;
//                         confirmErrorOkButton.alpha = 1;
//                     }
//                     completion:^(BOOL completed){
//                     }];
}

-(void)cancelCardButtonPressed
{
    [self darkenScreen];
    
//    cancelCardConfirmLabel.alpha = 0;
//    cancelCardConfirmButton.alpha = 0;
//    confirmCancelButton.alpha = 0;
//    
//    [self.view addSubview:cancelCardConfirmLabel];
//    [self.view addSubview:cancelCardConfirmButton];
//    [self.view addSubview:confirmCancelButton];
//    
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         cancelCardConfirmLabel.alpha = 1;
//                         cancelCardConfirmButton.alpha = 1;
//                         confirmCancelButton.alpha = 1;
//                     }
//                     completion:^(BOOL completed){
//                     }];
}

/** Limits the flavour text's size */
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
//    if (textView == _flavourTextView)
//    {
//        NSString *string = _flavourTextView.text;
//        int lineCount = [text length] - [[text stringByReplacingOccurrencesOfString:@"\n" withString:@""] length];
//        
//        if (lineCount > 4)
//            return NO;
//        
//        int characterCount = textView.text.length + (text.length - range.length);
//        
//        if (characterCount > 80)
//            return NO;
//        else
//            return YES;
//    }
    return YES;
};

-(void)textViewDidChange:(UITextView *)textView
{
//    if (textView == _flavourTextView)
//    {
//        [_customizeBackButton setEnabled:YES];
//        
//        //has text, will cost gold
//        if (_flavourTextView.text.length > 0)
//        {
//            if ([userPF[@"gold"] intValue] < FLAVOUR_TEXT_COST)
//            {
//                _customizeBackLabel.text = @"Not enough gold";
//                
//                [_customizeBackButton setEnabled:NO];
//            }
//            else
//                _customizeBackLabel.text = @"";
//        }
//        else
//            _customizeBackLabel.text = @"";
//    }
}


-(void)customizeButtonPressed
{
    [self darkenScreen];
    
//    _customizeView.alpha = 0;
//    [self.view addSubview:_customizeView];
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         _customizeView.alpha = 1;
//                     }
//                     completion:^(BOOL completed){
//                     }];
    
}

-(void)customizeBackButtonPressed
{
    [self undarkenScreen];
    
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         _customizeView.alpha = 0;
//                     }
//                     completion:^(BOOL completed){
//                         [_customizeView removeFromSuperview];
//                         _currentCardModel.flavourText = _flavourTextView.text;
//                         [_currentCardView updateView];
//                     }];
}

-(void)saveCardConfirmButtonPressed
{
    self.currentCardModel.name = nameTextField.text; //TODO not exactly the best place
    if (self.currentCardModel.name.length > 100)
        [self.currentCardModel.name substringToIndex:100];
    
    //first tutorial's card is not actually published
//    if (_editorMode == cardEditorModeTutorialOne)
//    {
//        [self dismissViewControllerAnimated:YES completion:nil];
//        return;
//    }
//    
//    NSMutableArray *noDupTags = [self getTags];
//    
//    self.currentCardModel.tags = noDupTags;
//    [userAllCards addObject:self.currentCardModel];
//    
//    if(_editorMode == cardEditorModeRarityUpdate)
//    {
//        //do update of card instead of publish
//        
//        [self updateCardForRarity];
//        
//        return;
//        
//    }
//    [self publishCurrentCard];
}

-(NSMutableArray*) getTags
{
//    NSString *lowerTags = [tagsField.text lowercaseString];
//    if (lowerTags.length > 100)
//        [lowerTags substringToIndex:100];
//    
//    NSMutableArray*lowerTagsArray = [NSMutableArray arrayWithArray:[lowerTags componentsSeparatedByString:@" "]];
    NSMutableArray*noDupTags = [NSMutableArray array];
    
//    for (NSString*string in lowerTagsArray)
//    {
//        if (![noDupTags containsObject:string] && string.length > 0)
//            [noDupTags addObject:string];
//    }
    
    return noDupTags;
}

-(void)voteCardConfirmButtonPressed
{
//    _cardUploadIndicator.alpha = 0;
//    _cardUploadLabel.text = [NSString stringWithFormat:@"Casting vote..."];
//    [_cardUploadIndicator setColor:[UIColor whiteColor]];
//    [self.view addSubview:_cardUploadIndicator];
//    [_cardUploadIndicator startAnimating];
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         _cardUploadIndicator.alpha = 1;
//                     }
//                     completion:^(BOOL completed){
//                         PFObject*cardPF = _currentCardModel.cardPF;
//                         
//                         CardVote *cardVote;
//                         PFObject*cardVotePF;
//                         
//                         //this is not actually supposed to happen, as it shouldn't be a nil, but this is just for debug cards that didn't have cardVotes when created
//                         if (cardPF[@"cardVote"] == nil)
//                         {
//                             NSLog(@"creating card vote from nil");
//                             cardVote = [[CardVote alloc] initWithCardModel:_currentCardModel];
//                             cardVotePF = [PFObject objectWithClassName:@"CardVote"];
//                         }
//                         //normal case: just update the votes
//                         else
//                         {
//                             NSLog(@"creating card vote from existing object");
//                             cardVotePF = cardPF[@"cardVote"];
//                             [cardVotePF fetch];
//                             cardVote = [[CardVote alloc] initWithPFObject:cardVotePF];
//                             [cardVote addVote:_currentCardModel];
//                         }
//                         
//                         NSLog(@"created card vote");
//                         
//                         [cardVote generatedVotedCard:_currentCardModel];
//                         [cardVote updateToPFObject:cardVotePF];
//                         
//                         NSLog(@"saving card vote");
//                         
//                         cardPF[@"cardVote"] = cardVotePF;
//                         
//                         //maybe the uploading part should be in cloud, but probably not that dangerous
//                         [cardPF saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                             if (succeeded)
//                             {
//                                 [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                                                  animations:^{
//                                                      _cardUploadIndicator.alpha = 0;
//                                                  }
//                                                  completion:^(BOOL completed){
//                                                      [_cardUploadIndicator stopAnimating];
//                                                      [_cardUploadIndicator removeFromSuperview];
//                                                      
//                                                      _voteConfirmed = YES;
//                                                      [self dismissViewControllerAnimated:YES completion:nil];
//                                                  }];
//                             }
//                             else
//                             {
//                                 [_cardUploadIndicator setColor:[UIColor clearColor]];
//                                 _cardUploadLabel.text = [NSString stringWithFormat:@"Error casting vote."];
//                                 _cardVoteFailedButton.alpha = 0;
//                                 [_cardUploadIndicator addSubview:_cardVoteFailedButton];
//                                 [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                                                  animations:^{
//                                                      _cardVoteFailedButton.alpha = 1;
//                                                  }
//                                                  completion:^(BOOL completed){
//                                                      [_cardVoteFailedButton setUserInteractionEnabled:YES];
//                                                  }];
//                             }
//                         }];
//                         
//                     }];
}

-(void)cancelCardConfirmButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)confirmCancelButtonPressed
{
    [self undarkenScreen];
    
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         saveCardConfirmLabel.alpha = 0;
//                         saveCardConfirmButton.alpha = 0;
//                         cancelCardConfirmLabel.alpha = 0;
//                         cancelCardConfirmButton.alpha = 0;
//                         confirmCancelButton.alpha = 0;
//                         confirmErrorOkButton.alpha = 0;
//                     }
//                     completion:^(BOOL completed){
//                         [saveCardConfirmLabel removeFromSuperview];
//                         [saveCardConfirmButton removeFromSuperview];
//                         [cancelCardConfirmLabel removeFromSuperview];
//                         [cancelCardConfirmButton removeFromSuperview];
//                         [confirmCancelButton removeFromSuperview];
//                         [confirmErrorOkButton removeFromSuperview];
//                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)darkenScreen
{
//    darkFilter.alpha = 0;
//    [self.view addSubview:darkFilter];
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         darkFilter.alpha = 0.9;
//                     }
//                     completion:nil];
}

-(void)undarkenScreen
{
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         darkFilter.alpha = 0;
//                     }
//                     completion:^(BOOL completed){
//                         [darkFilter removeFromSuperview];
//                     }];
}


//-(void)setCurrentCardModel:(CardModel *)currentCardModel
//{
//    self.currentCardModel = currentCardModel;
//    
//    //update the points for the two views
//    if (abilityNewTableView != nil)
//        abilityNewTableView.currentCard = currentCardModel;
//    if (abilityExistingTableView != nil)
//        abilityExistingTableView.currentCard = currentCardModel;
//}

//-(CardModel*)currentCardModel
//{
//    return self.currentCardModel;
//}

+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void)modalScreen
{
//    _modalFilter.alpha = 3.f/255; //because apparently 0 alpha = cannot be interacted...
//    [self.view addSubview:_modalFilter];
}

-(void)unmodalScreen
{
   // [_modalFilter removeFromSuperview];
}

-(void)setTutLabelCenter:(CGPoint) center
{
    self.tutLabel.center = center;
    self.tutOkButton.center = CGPointMake(center.x, center.y + self.tutLabel.bounds.size.height/2 - 40);
}

//block delay functions
- (void)performBlock:(void (^)())block
{
    block();
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay
{
    void (^block_)() = [block copy]; // autorelease this if you're not using ARC
    [self performSelector:@selector(performBlock:) withObject:block_ afterDelay:delay];
}

- (BOOL)prefersStatusBarHidden {return YES;}


-(void)goBack{
    abilityExistingTableView.currentAbilities = [[NSMutableArray alloc] init];
    abilityNewTableView.currentAbilities = [[NSMutableArray alloc] init];
     self.currentCardModel.abilities = [[NSMutableArray alloc] init];
    self.originalCard.abilities = [[NSMutableArray alloc] init];
    if(self.delegate !=nil)
    {
        [self.delegate cardUpdated:self.currentCardModel];
        [self.delegate updateAbilities:abilityExistingTableView.currentAbilities];
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)saveAndGoBack{
    
    if(self.currentCost>self.maxCost)
    {
        UIAlertView *costAlert = [[UIAlertView alloc] initWithTitle:@"Cost Too High" message:@"Reduce Abilities or ATK/HP To Create Card" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [costAlert show];
        return;
        
    }
    
    if(self.delegate !=nil)
    {
        [self.delegate cardUpdated:self.currentCardModel];
        [self.delegate updateAbilities:abilityExistingTableView.currentAbilities];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
