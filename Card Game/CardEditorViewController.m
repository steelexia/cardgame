//
//  CardEditorViewController.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-28.
//  Copyright (c) 2014 Content Games. All rights reserved.
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

@interface CardEditorViewController ()

@end

@implementation CardEditorViewController

@synthesize currentCardModel = _currentCardModel;
@synthesize currentCardView = _currentCardView;

/** Screen dimension for convinience */
int SCREEN_WIDTH, SCREEN_HEIGHT;

const double CARD_EDITOR_SCALE = 1.4;

const int MAX_NAME_FONT_SIZE = 15;

/** A monster's base stat cannot be higher than these. (not that it's even easy to get to these stats */
const int MAX_DAMAGE = 20000, MIN_DAMAGE = 0, DAMAGE_INCREMENT = 100;
const int MAX_LIFE = 20000, MIN_LIFE = 1000, LIFE_INCREMENT = 100;
const int MAX_COOLDOWN = 5, MIN_COOLDOWN = 1, COOLDOWN_INCREMENT = 1;
const int MIN_COST = 0, COST_INCREMENT = 1; //maxCost is an array

UITextField *nameTextField;
UIImage *scaledImage;
UIButton *abilityButton,*flavourButton,*elementButton;

CFButton *damageIncButton, *damageDecButton, *lifeIncButton, *lifeDecButton, *cdIncButton, *cdDecButton, *costIncButton, *costDecButton;

/** Transparent views used to register touch events for enabling the buttons for editing the stats. */
UIView*damageEditArea, *lifeEditArea, *costEditArea, *cdEditArea, *imageEditArea, *elementEditArea, *abilityEditArea,*welcomeView;

/** Spell cards can have this many extra abilities compared to Monster cards */
const int SPELL_CARD_BONUS_ABILITY_COUNT = 1;

StrokedLabel*currentCostLabel, *maxCostLabel;

/** New is for adding new abilities, existing is for editing existing abilities */
AbilityTableView *abilityExistingTableView;

UILabel*abilityValueLabel;
CFButton *abilityIncButton, *abilityDecButton, *abilityAddButton, *abilityRemoveButton;

UILabel*tagsLabel;
UITextField*tagsField;

CGSize keyboardSize;

/** Buttons for changing between card types */
UIButton *monsterCardButton, *spellCardButton;

UIButton *saveCardButton, *cancelCardButton, *customizeCardButton;

CFButton *saveCardConfirmButton, *cancelCardConfirmButton, *confirmCancelButton, *confirmErrorOkButton;

UILabel *saveCardConfirmLabel, *cancelCardConfirmLabel;

/** UILabel used to darken the screen during card selections */
UILabel *darkFilter;

/** Stuff for element selection */
StrokedLabel *neutralLabel, *fireLabel, *iceLabel, *lightningLabel, *earthLabel, *lightLabel, *darkLabel;

CFButton*elementConfirmButton;

UILabel *elementDescriptionLabel;

UIImageView*pointsImageBackground;

/** Image upload stuff */
UIView*imageUploadView;
CFButton*uploadFromFileButton, *uploadFromCameraButton, *uploadBackButton;

UIImage*CARD_EDITOR_EMPTY_IMAGE;

bool shouldSetUpView = YES;

- (id)initWithMode: (enum CardEditorMode)editorMode WithCard:(CardModel*)card
{
    self = [super init];
    if (self) {
        _editorMode = editorMode;
        CARD_EDITOR_EMPTY_IMAGE = [UIImage imageNamed:@"card_image_cardeditor_empty"];
        
        if (card != nil)
        {
            _currentCardModel = card;
            _originalCard = [[CardModel alloc] initWithCardModel:card];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
    //card cannot exceed this number of abilities
    
    self.view.backgroundColor = COLOUR_INTERFACE_BLUE_DARK;
    
    if (_editorMode == cardEditorModeCreation)
    {
        //no card, start with a new one
        [self setupNewMonster];
    }
    else if (_editorMode == cardEditorModeTutorialOne || _editorMode == cardEditorModeTutorialTwo || _editorMode == cardEditorModeTutorialThree)
    {
        //tutorials all start with new card
        [self setupNewMonster];
    }
    
    [self reloadCardView];
    
    //----------------card basic stats views---------------------//
    
    
    UIImageView *leftGrayView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/6 *1.8, SCREEN_HEIGHT)];
    [leftGrayView setImage:[UIImage imageNamed:@"CardCreateSidebar.png"]];
    [self.view addSubview:leftGrayView];
    UIImageView *rightTableView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/6 *1.7, 0, SCREEN_WIDTH/6 *4.4, SCREEN_HEIGHT)];
    [rightTableView setImage:[UIImage imageNamed:@"WoodBG.jpg"]];
    [self.view insertSubview:rightTableView atIndex:0];
    
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
    
    if (_editorMode == cardEditorModeVoting)
        [nameTextField setText:_currentCardModel.name];
    
    
    if(_editorMode ==cardEditorModeRarityUpdate)
    {
        [nameTextField setText:_currentCardModel.name];
         NSString *tagsList = [[_currentCardModel.tags copy] componentsJoinedByString:@" "];
        [tagsField setText:tagsList];
        
    }
    
    [nameTextField setDelegate:self];
    [self.view addSubview:nameTextField];
    
    abilityExistingTableView = [[AbilityTableView alloc] initWithFrame:CGRectMake(90, 242, 172, 90)  mode:abilityTableViewExisting];
    abilityExistingTableView.cevc = self;
    //[abilityExistingTableView setHidden:YES];
    
    //[abilityExistingTableView setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:abilityExistingTableView];
    
    damageIncButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    [damageIncButton setImage:[UIImage imageNamed:@"increment_button"] forState:UIControlStateNormal];
    //[damageIncButton setImage:[UIImage imageNamed:@"increment_button_gray"] forState:UIControlStateDisabled];
    
    
    damageDecButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    [damageDecButton setImage:[UIImage imageNamed:@"decrement_button"] forState:UIControlStateNormal];
    //[damageDecButton setImage:[UIImage imageNamed:@"decrement_button_gray"] forState:UIControlStateDisabled];
    
    
    lifeIncButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    [lifeIncButton setImage:[UIImage imageNamed:@"increment_button"] forState:UIControlStateNormal];
    //[lifeIncButton setImage:[UIImage imageNamed:@"increment_button_gray"] forState:UIControlStateDisabled];
    
    
    lifeDecButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    [lifeDecButton setImage:[UIImage imageNamed:@"decrement_button"] forState:UIControlStateNormal];
    //[lifeDecButton setImage:[UIImage imageNamed:@"decrement_button_gray"] forState:UIControlStateDisabled];
    
    
    cdIncButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    [cdIncButton setImage:[UIImage imageNamed:@"increment_button"] forState:UIControlStateNormal];
    //[cdIncButton setImage:[UIImage imageNamed:@"increment_button_gray"] forState:UIControlStateDisabled];
    
    
    cdDecButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    [cdDecButton setImage:[UIImage imageNamed:@"decrement_button"] forState:UIControlStateNormal];
    //[cdDecButton setImage:[UIImage imageNamed:@"decrement_button_gray"] forState:UIControlStateDisabled];
    
    
    costIncButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    [costIncButton setImage:[UIImage imageNamed:@"increment_button"] forState:UIControlStateNormal];
    //[costIncButton setImage:[UIImage imageNamed:@"increment_button_gray"] forState:UIControlStateDisabled];
    
    
    costDecButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    [costDecButton setImage:[UIImage imageNamed:@"decrement_button"] forState:UIControlStateNormal];
    //[costDecButton setImage:[UIImage imageNamed:@"decrement_button_gray"] forState:UIControlStateDisabled];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    if (shouldSetUpView) {
        CGPoint attackLabelPoint = [self.view convertPoint:self.currentCardView.attackLabel.center fromView:self.currentCardView];
        damageIncButton.center = CGPointMake(attackLabelPoint.x, attackLabelPoint.y - 28);
        //[self.view addSubview:damageIncButton];
        [damageIncButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [damageIncButton addTarget:self action:@selector(damageIncButtonPressed)    forControlEvents:UIControlEventTouchDown];
        
        damageDecButton.center = CGPointMake(attackLabelPoint.x, attackLabelPoint.y + 32);
        //[self.view addSubview:damageDecButton];
        [damageDecButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [damageDecButton addTarget:self action:@selector(damageDecButtonPressed)    forControlEvents:UIControlEventTouchDown];
        
        CGPoint lifeLabelPoint = [self.view convertPoint:self.currentCardView.lifeLabel.center fromView:self.currentCardView];
        
        lifeIncButton.center = CGPointMake(lifeLabelPoint.x, lifeLabelPoint.y - 28);
        //[self.view addSubview:lifeIncButton];
        [lifeIncButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [lifeIncButton addTarget:self action:@selector(lifeIncButtonPressed)    forControlEvents:UIControlEventTouchDown];
        
        lifeDecButton.center = CGPointMake(lifeLabelPoint.x, lifeLabelPoint.y + 32);
        //[self.view addSubview:lifeDecButton];
        [lifeDecButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [lifeDecButton addTarget:self action:@selector(lifeDecButtonPressed)    forControlEvents:UIControlEventTouchDown];
        
        CGPoint cdLabelPoint = [self.view convertPoint:self.currentCardView.cooldownLabel.center fromView:self.currentCardView];
        
        cdIncButton.center = CGPointMake(cdLabelPoint.x, cdLabelPoint.y - 32);
        //[self.view addSubview:cdIncButton];
        [cdIncButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [cdIncButton addTarget:self action:@selector(cdIncButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        
        cdDecButton.center = CGPointMake(cdLabelPoint.x, cdLabelPoint.y + 34);
        //[self.view addSubview:cdDecButton];
        [cdDecButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [cdDecButton addTarget:self action:@selector(cdDecButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        
        CGPoint costLabelPoint = [self.view convertPoint:self.currentCardView.costLabel.center fromView:self.currentCardView];
        
        costIncButton.center = CGPointMake(costLabelPoint.x, costLabelPoint.y - 36);
        //[self.view addSubview:costIncButton];
        [costIncButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [costIncButton addTarget:self action:@selector(costIncButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        
        costDecButton.center = CGPointMake(costLabelPoint.x, costLabelPoint.y + 38);
        //[self.view addSubview:costDecButton];
        [costDecButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [costDecButton addTarget:self action:@selector(costDecButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        
        [self updateAllIncrementButtons];
        
        //-------------------------ability views------------------------//
        
        //existing
        
        
        tagsField =  [[UITextField alloc] initWithFrame:CGRectMake(130,SCREEN_HEIGHT- 24,186,20)];
        
        tagsField.textColor = [UIColor blackColor];
        tagsField.font = [UIFont fontWithName:cardMainFont size:12];
        tagsField.returnKeyType = UIReturnKeyDone;
        [tagsField setPlaceholder:@"Enter tags separated by space"];
        [tagsField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [tagsField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [tagsField addTarget:self action:@selector(tagsFieldBegan) forControlEvents:UIControlEventEditingDidBegin];
        [tagsField addTarget:self action:@selector(tagsFieldFinished) forControlEvents:UIControlEventEditingDidEnd];
        [tagsField setDelegate:self];
        [tagsField.layer setBorderColor:[UIColor blackColor].CGColor];
        [tagsField.layer setBorderWidth:2];
        [tagsField setBackgroundColor:COLOUR_INTERFACE_BLUE_LIGHT];
        // [tagsField setHidden:YES];
        tagsField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
        //tagsField.layer.cornerRadius = 4.0;
        [tagsField addTarget:self action:@selector(tagsTextFieldEdited) forControlEvents:UIControlEventEditingChanged];
        
        [self.view addSubview:tagsField];
        
        tagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, SCREEN_HEIGHT-24, 80, 20)];
        tagsLabel.font = [UIFont fontWithName:cardMainFont size:16];
        tagsLabel.textColor = [UIColor blackColor];
        //[tagsLabel setHidden:YES];
        tagsLabel.text = @"Tags:";
        [self.view addSubview:tagsLabel];
        
        abilityIncButton = [[CFButton alloc] initWithFrame:CGRectMake(270, 222, 46, 32)];
        [abilityIncButton setImage:[UIImage imageNamed:@"increment_button"] forState:UIControlStateNormal];
        //[abilityIncButton setImage:[UIImage imageNamed:@"increment_button_gray"] forState:UIControlStateDisabled];
        [abilityIncButton addTarget:self action:@selector(abilityIncButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        [abilityIncButton setEnabled:NO];
        
        //[self.view addSubview:abilityIncButton];
        
        abilityDecButton = [[CFButton alloc] initWithFrame:CGRectMake(270, 258, 46, 32)];
        [abilityDecButton setImage:[UIImage imageNamed:@"decrement_button"] forState:UIControlStateNormal];
        //[abilityDecButton setImage:[UIImage imageNamed:@"decrement_button_gray"] forState:UIControlStateDisabled];
        [abilityDecButton addTarget:self action:@selector(abilityDecButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        [abilityDecButton setEnabled:NO];
        
        //[self.view addSubview:abilityDecButton];
        
        abilityRemoveButton = [[CFButton alloc] initWithFrame:CGRectMake(270, 314, 46, 32)];
        [abilityRemoveButton setImage:[UIImage imageNamed:@"remove_deck_button"] forState:UIControlStateNormal];
        //[abilityRemoveButton setImage:[UIImage imageNamed:@"remove_deck_button_gray"] forState:UIControlStateDisabled];
        [abilityRemoveButton addTarget:self action:@selector(abilityRemoveButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        [abilityRemoveButton setEnabled:NO];
        
        //[self.view addSubview:abilityRemoveButton];
        
        abilityAddButton = [[CFButton alloc] initWithFrame:CGRectMake(270, SCREEN_HEIGHT - 60, 46, 32)];
        [abilityAddButton setImage:[UIImage imageNamed:@"add_deck_button"] forState:UIControlStateNormal];
        //[abilityAddButton setImage:[UIImage imageNamed:@"add_deck_button_gray"] forState:UIControlStateDisabled];
        [abilityAddButton addTarget:self action:@selector(abilityAddButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        [abilityAddButton setEnabled:NO];
        [abilityAddButton setHidden:YES];
        
        [self.view addSubview:abilityAddButton];
        
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
        
        //, *lifeEditArea, *costEditArea, *cdEditArea, *imageEditArea;
        
        monsterCardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
        //[monsterCardButton setImage:[UIImage imageNamed:@"monster_button"] forState:UIControlStateNormal];
        //[monsterCardButton setImage:[UIImage imageNamed:@"monster_button_gray"] forState:UIControlStateDisabled];
        //[monsterCardButton setTextSize:11];
        /// monsterCardButton.label.text = @"Monster";
        [monsterCardButton setTitle:@"Monster" forState:UIControlStateNormal];
        [monsterCardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [monsterCardButton.titleLabel setFont:[UIFont fontWithName:cardMainFont size:11]];
        monsterCardButton.center = CGPointMake(40, 105);
        [monsterCardButton setBackgroundImage:[UIImage imageNamed:@"CardCreateBlueButton.png"] forState:UIControlStateNormal];
        [monsterCardButton addTarget:self action:@selector(monsterButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:monsterCardButton];
        
        spellCardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
        //[spellCardButton setImage:[UIImage imageNamed:@"spell_button"] forState:UIControlStateNormal];
        //[spellCardButton setImage:[UIImage imageNamed:@"spell_button_gray"] forState:UIControlStateDisabled];
        //[spellCardButton setTextSize:11];
        //spellCardButton.label.text = @"Spell";
        [spellCardButton setTitle:@"Spell" forState:UIControlStateNormal];
        [spellCardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [spellCardButton.titleLabel setFont:[UIFont fontWithName:cardMainFont size:11]];
        
        spellCardButton.center = CGPointMake(40,50);
        [spellCardButton setBackgroundImage:[UIImage imageNamed:@"CardCreateGreenButton.png"] forState:UIControlStateNormal];
        [spellCardButton addTarget:self action:@selector(spellButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:spellCardButton];
        
        saveCardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
        //[saveCardButton setImage:[UIImage imageNamed:@"save_card_button"] forState:UIControlStateNormal];
        //[saveCardButton setImage:[UIImage imageNamed:@"save_card_button_gray"] forState:UIControlStateDisabled];
        //[saveCardButton setTextSize:14];
        // saveCardButton.label.text = @"Save";
        [saveCardButton setTitle:@"Save" forState:UIControlStateNormal];
        [saveCardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [saveCardButton.titleLabel setFont:[UIFont fontWithName:cardMainFont size:11]];
        saveCardButton.center = CGPointMake(40, SCREEN_HEIGHT - 25);
        [saveCardButton setEnabled:NO];
        [saveCardButton setBackgroundImage:[UIImage imageNamed:@"CardCreateGreenButton.png"] forState:UIControlStateNormal];
        [saveCardButton addTarget:self action:@selector(saveCardButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:saveCardButton];
        
        cancelCardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
        //[cancelCardButton setImage:[UIImage imageNamed:@"cancel_card_button"] forState:UIControlStateNormal];
        //[cancelCardButton setTextSize:14];
        //cancelCardButton.label.text = @"Cancel";
        [cancelCardButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelCardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelCardButton.titleLabel setFont:[UIFont fontWithName:cardMainFont size:11]];
        [cancelCardButton setBackgroundImage:[UIImage imageNamed:@"CardCreateRedButton.png"] forState:UIControlStateNormal];
        cancelCardButton.center = CGPointMake(40, SCREEN_HEIGHT - 70);
        [cancelCardButton addTarget:self action:@selector(cancelCardButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cancelCardButton];
        
        customizeCardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
        //[customizeCardButton setTextSize:12];
        //customizeCardButton.label.text = @"Custom";
        [customizeCardButton setTitle:@"Custom" forState:UIControlStateNormal];
        [customizeCardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [customizeCardButton.titleLabel setFont:[UIFont fontWithName:cardMainFont size:11]];
        [customizeCardButton setBackgroundImage:[UIImage imageNamed:@"CardCreateBlueButton.png"] forState:UIControlStateNormal];
        customizeCardButton.center = CGPointMake(40, SCREEN_HEIGHT - 115);
        [customizeCardButton setEnabled:NO];
        [customizeCardButton addTarget:self action:@selector(customizeButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:customizeCardButton];
        
        if (_editorMode == cardEditorModeVoting)
            [customizeCardButton setEnabled:NO];
        
        //customization view
        _customizeView = [[UIView alloc] initWithFrame:self.view.bounds];
        
        _customizeBackButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
        [_customizeBackButton setTextSize:14];
        _customizeBackButton.label.text = @"Ok";
        _customizeBackButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-60);
        [_customizeBackButton addTarget:self action:@selector(customizeBackButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        [_customizeView addSubview:_customizeBackButton];
        
        _customizeBackLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        _customizeBackLabel.textAlignment = NSTextAlignmentCenter;
        _customizeBackLabel.font = [UIFont fontWithName:cardMainFont size:14];
        [_customizeBackLabel setTextColor:[UIColor whiteColor]];
        _customizeBackLabel.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-110);
        _customizeBackLabel.text = @"";
        _customizeBackLabel.strokeOn = YES;
        _customizeBackLabel.strokeColour = [UIColor blackColor];
        _customizeBackLabel.strokeThickness = 2;
        [_customizeView addSubview:_customizeBackLabel];
        
        StrokedLabel *flavourTextLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        flavourTextLabel.textAlignment = NSTextAlignmentCenter;
        flavourTextLabel.font = [UIFont fontWithName:cardMainFont size:22];
        [flavourTextLabel setTextColor:[UIColor whiteColor]];
        flavourTextLabel.center = CGPointMake(SCREEN_WIDTH/2 - 20, 60);
        flavourTextLabel.text = @"Flavour Text:";
        flavourTextLabel.strokeOn = YES;
        flavourTextLabel.strokeColour = [UIColor blackColor];
        flavourTextLabel.strokeThickness = 3;
        [_customizeView addSubview:flavourTextLabel];
        
        UIImageView *flavourTextCostImage = [[UIImageView alloc] initWithImage:GOLD_ICON_IMAGE];
        flavourTextCostImage.frame = CGRectMake(0, 0, 35, 35);
        flavourTextCostImage.center = CGPointMake(SCREEN_WIDTH/2 + 70, 55);
        
        StrokedLabel*flavourTextCostLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        flavourTextCostLabel.textAlignment = NSTextAlignmentCenter;
        flavourTextCostLabel.font = [UIFont fontWithName:cardMainFont size:20];
        [flavourTextCostLabel setTextColor:[UIColor whiteColor]];
        flavourTextCostLabel.center = CGPointMake(20, 35);
        flavourTextCostLabel.text = [NSString stringWithFormat:@"%d", FLAVOUR_TEXT_COST];
        flavourTextCostLabel.strokeOn = YES;
        flavourTextCostLabel.strokeColour = [UIColor blackColor];
        flavourTextCostLabel.strokeThickness = 3;
        [flavourTextCostImage addSubview:flavourTextCostLabel];
        
        [_customizeView addSubview:flavourTextCostImage];
        
        _flavourTextView = [[UITextView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH*2/3, 120) ];
        _flavourTextView.center = CGPointMake(SCREEN_WIDTH/2, 150);
        [_flavourTextView setFont:[UIFont fontWithName:cardFlavourTextFont size:16]];
        _flavourTextView.backgroundColor = [UIColor whiteColor];
        _flavourTextView.layer.cornerRadius = 5;
        _flavourTextView.layer.borderWidth = 2;
        [_flavourTextView setDelegate:self];
        
        //CFLabel *flavourTextBackground = [[CFLabel alloc] initWithFrame:CGRectInset(_flavourTextView.frame, -5, -5)];
        //[_customizeView addSubview:flavourTextBackground];
        [_customizeView addSubview:_flavourTextView];
        
        UIImageView *userGoldImage = [[UIImageView alloc] initWithImage:GOLD_ICON_IMAGE];
        userGoldImage.frame = CGRectMake(0, 0, 35, 35);
        userGoldImage.center = CGPointMake(SCREEN_WIDTH - 50, SCREEN_HEIGHT - 50);
        
        StrokedLabel*userGoldLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        userGoldLabel.textAlignment = NSTextAlignmentCenter;
        userGoldLabel.font = [UIFont fontWithName:cardMainFont size:20];
        [userGoldLabel setTextColor:[UIColor whiteColor]];
        userGoldLabel.center = CGPointMake(20, 35);
        userGoldLabel.text = [NSString stringWithFormat:@"%@", userPF[@"gold"]];
        userGoldLabel.strokeOn = YES;
        userGoldLabel.strokeColour = [UIColor blackColor];
        userGoldLabel.strokeThickness = 3;
        [userGoldImage addSubview:userGoldLabel];
        [_customizeView addSubview:userGoldImage];
        
        //confirmation dialogs
        saveCardConfirmLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/5, SCREEN_WIDTH*6/8, SCREEN_HEIGHT/2)];
        saveCardConfirmLabel.textColor = [UIColor whiteColor];
        saveCardConfirmLabel.backgroundColor = [UIColor clearColor];
        saveCardConfirmLabel.font = [UIFont fontWithName:cardMainFont size:25];
        saveCardConfirmLabel.textAlignment = NSTextAlignmentCenter;
        saveCardConfirmLabel.lineBreakMode = NSLineBreakByWordWrapping;
        saveCardConfirmLabel.numberOfLines = 0;
        
        //[saveCardConfirmLabel sizeToFit];
        
        saveCardConfirmButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
        [saveCardConfirmButton setTextSize:16];
        saveCardConfirmButton.label.text = @"Yes";
        saveCardConfirmButton.center = CGPointMake(SCREEN_WIDTH/2 - 80, SCREEN_HEIGHT - 60);
        //[saveCardConfirmButton setImage:[UIImage imageNamed:@"yes_button"] forState:UIControlStateNormal];
        
        confirmCancelButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
        [confirmCancelButton setTextSize:16];
        confirmCancelButton.label.text = @"No";
        confirmCancelButton.center = CGPointMake(SCREEN_WIDTH/2 + 80, SCREEN_HEIGHT - 60);
        //[confirmCancelButon setImage:[UIImage imageNamed:@"no_button"] forState:UIControlStateNormal];
        [confirmCancelButton addTarget:self action:@selector(confirmCancelButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        
        confirmErrorOkButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
        [confirmErrorOkButton setTextSize:16];
        confirmErrorOkButton.label.text = @"Ok";
        confirmErrorOkButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 60);
        [confirmErrorOkButton addTarget:self action:@selector(confirmCancelButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        
        cancelCardConfirmLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT)];
        cancelCardConfirmLabel.textColor = [UIColor whiteColor];
        cancelCardConfirmLabel.backgroundColor = [UIColor clearColor];
        cancelCardConfirmLabel.font = [UIFont fontWithName:cardMainFont size:25];
        cancelCardConfirmLabel.textAlignment = NSTextAlignmentCenter;
        cancelCardConfirmLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cancelCardConfirmLabel.numberOfLines = 0;
        cancelCardConfirmLabel.text = @"Are you sure you want to cancel? All progress will be lost.";
        [cancelCardConfirmLabel sizeToFit];
        
        cancelCardConfirmButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
        [cancelCardConfirmButton setTextSize:16];
        cancelCardConfirmButton.center = CGPointMake(SCREEN_WIDTH/2 - 80, SCREEN_HEIGHT - 60);
        cancelCardConfirmButton.label.text = @"Yes";
        //[cancelCardConfirmButton setImage:[UIImage imageNamed:@"yes_button"] forState:UIControlStateNormal];
        [cancelCardConfirmButton addTarget:self action:@selector(cancelCardConfirmButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        
        darkFilter = [[UILabel alloc] initWithFrame:self.view.bounds];
        darkFilter.backgroundColor = [[UIColor alloc]initWithHue:0 saturation:0 brightness:0 alpha:0.8];
        [darkFilter setUserInteractionEnabled:YES]; //blocks all interaction behind it
        
        _modalFilter = [[UILabel alloc] initWithFrame:self.view.bounds];
        _modalFilter.backgroundColor = [[UIColor alloc]initWithHue:0 saturation:0 brightness:0 alpha:0.8];
        [_modalFilter setUserInteractionEnabled:YES]; //blocks all interaction behind it
        
        
        //--------------------- abilities and Type buttons ---------------//
        
        elementButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 40)];
        [elementButton setTitle:@"Element" forState:UIControlStateNormal];
        [elementButton setCenter:CGPointMake(self.currentCardView.center.x, customizeCardButton.center.y - 45)];
        [elementButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [elementButton.titleLabel setFont:[UIFont fontWithName:cardMainFont size:11]];
        [elementButton setBackgroundImage:[UIImage imageNamed:@"CardCreateGreenButton.png"] forState:UIControlStateNormal];
        [elementButton addTarget:self action:@selector(openElementEditScreen) forControlEvents:UIControlEventTouchUpInside];
        if (_editorMode == cardEditorModeCreation || _editorMode == cardEditorModeTutorialTwo || _editorMode == cardEditorModeTutorialThree)
            [self.view addSubview:elementButton];
        
        abilityButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 40)];
        [abilityButton setTitle:@"Abilities" forState:UIControlStateNormal];
        [abilityButton setCenter:CGPointMake(self.currentCardView.center.x, customizeCardButton.center.y)];
        [abilityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [abilityButton.titleLabel setFont:[UIFont fontWithName:cardMainFont size:11]];
        [abilityButton setBackgroundImage:[UIImage imageNamed:@"CardCreateBlueButton.png"] forState:UIControlStateNormal];
        [abilityButton addTarget:self action:@selector(showAbilities) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:abilityButton];
        
        flavourButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 40)];
        [flavourButton setTitle:@"Flavour text" forState:UIControlStateNormal];
        [flavourButton setCenter:CGPointMake(self.currentCardView.center.x, cancelCardButton.center.y)];
        [flavourButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [flavourButton.titleLabel setFont:[UIFont fontWithName:cardMainFont size:11]];
        [flavourButton setBackgroundImage:[UIImage imageNamed:@"CardCreateRedButton.png"] forState:UIControlStateNormal];
        
        [self.view addSubview:flavourButton];
        
        
        //----------------------element edit screen--------------------//
        neutralLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
        neutralLabel.font = [UIFont fontWithName:cardMainFont size:25];
        neutralLabel.textAlignment = NSTextAlignmentCenter;
        neutralLabel.strokeOn = YES;
        neutralLabel.strokeColour = COLOUR_NEUTRAL_OUTLINE;
        neutralLabel.strokeThickness = 4;
        [neutralLabel setUserInteractionEnabled:YES];
        [neutralLabel setTextColor:COLOUR_NEUTRAL];
        [neutralLabel setText:[CardModel elementToString:elementNeutral]];
        
        fireLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
        fireLabel.font = [UIFont fontWithName:cardMainFont size:25];
        fireLabel.textAlignment = NSTextAlignmentCenter;
        fireLabel.strokeOn = YES;
        fireLabel.strokeColour = COLOUR_FIRE_OUTLINE;
        fireLabel.strokeThickness = 4;
        [fireLabel setUserInteractionEnabled:YES];
        [fireLabel setTextColor:COLOUR_FIRE];
        [fireLabel setText:[CardModel elementToString:elementFire]];
        
        iceLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
        iceLabel.font = [UIFont fontWithName:cardMainFont size:25];
        iceLabel.textAlignment = NSTextAlignmentCenter;
        iceLabel.strokeOn = YES;
        iceLabel.strokeColour = COLOUR_ICE_OUTLINE;
        iceLabel.strokeThickness = 4;
        [iceLabel setUserInteractionEnabled:YES];
        [iceLabel setTextColor:COLOUR_ICE];
        [iceLabel setText:[CardModel elementToString:elementIce]];
        
        lightningLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
        lightningLabel.font = [UIFont fontWithName:cardMainFont size:25];
        lightningLabel.textAlignment = NSTextAlignmentCenter;
        lightningLabel.strokeOn = YES;
        lightningLabel.strokeColour = COLOUR_LIGHTNING_OUTLINE;
        lightningLabel.strokeThickness = 4;
        [lightningLabel setUserInteractionEnabled:YES];
        [lightningLabel setTextColor:COLOUR_LIGHTNING];
        [lightningLabel setText:[CardModel elementToString:elementLightning]];
        
        earthLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
        earthLabel.font = [UIFont fontWithName:cardMainFont size:25];
        earthLabel.textAlignment = NSTextAlignmentCenter;
        earthLabel.strokeOn = YES;
        earthLabel.strokeColour = COLOUR_EARTH_OUTLINE;
        earthLabel.strokeThickness = 4;
        [earthLabel setUserInteractionEnabled:YES];
        [earthLabel setTextColor:COLOUR_EARTH];
        [earthLabel setText:[CardModel elementToString:elementEarth]];
        
        lightLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
        lightLabel.font = [UIFont fontWithName:cardMainFont size:25];
        lightLabel.textAlignment = NSTextAlignmentCenter;
        lightLabel.strokeOn = YES;
        lightLabel.strokeColour = COLOUR_LIGHT_OUTLINE;
        lightLabel.strokeThickness = 4;
        [lightLabel setUserInteractionEnabled:YES];
        [lightLabel setTextColor:COLOUR_LIGHT];
        [lightLabel setText:[CardModel elementToString:elementLight]];
        
        darkLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
        darkLabel.font = [UIFont fontWithName:cardMainFont size:25];
        darkLabel.textColor = COLOUR_DARK;
        darkLabel.textAlignment = NSTextAlignmentCenter;
        darkLabel.strokeOn = YES;
        darkLabel.strokeColour = COLOUR_DARK_OUTLINE;
        darkLabel.strokeThickness = 4;
        [darkLabel setUserInteractionEnabled:YES];
        [darkLabel setTextColor:COLOUR_DARK];
        [darkLabel setText:[CardModel elementToString:elementDark]];
        
        elementConfirmButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
        elementConfirmButton.center = CGPointMake(SCREEN_WIDTH/2 + 80, SCREEN_HEIGHT - 60);
        elementConfirmButton.label.text = @"Ok";
        [elementConfirmButton setTextSize:16];
        //[elementConfirmButton setImage:[UIImage imageNamed:@"ok_button"] forState:UIControlStateNormal];
        [elementConfirmButton addTarget:self action:@selector(elementConfirmButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        elementDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, SCREEN_HEIGHT/6, SCREEN_WIDTH-140-20, SCREEN_HEIGHT)];
        elementDescriptionLabel.textColor = [UIColor whiteColor];
        elementDescriptionLabel.backgroundColor = [UIColor clearColor];
        elementDescriptionLabel.font = [UIFont fontWithName:cardMainFont size:18];
        elementDescriptionLabel.textAlignment = NSTextAlignmentLeft;
        elementDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        elementDescriptionLabel.numberOfLines = 0;
        elementDescriptionLabel.text = @"";
        [elementDescriptionLabel sizeToFit];
        
        //image upload screen
        imageUploadView = [[UIView alloc] initWithFrame:self.view.bounds];
        imageUploadView.backgroundColor = [[UIColor alloc]initWithHue:0 saturation:0 brightness:0 alpha:0.8];
        [imageUploadView setUserInteractionEnabled:YES];
        
        StrokedLabel*uploadLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,40)];
        uploadLabel.textColor = [UIColor whiteColor];
        uploadLabel.font = [UIFont fontWithName:cardMainFont size:30];
        uploadLabel.textAlignment = NSTextAlignmentCenter;
        uploadLabel.center = CGPointMake(SCREEN_WIDTH/2, 60);
        uploadLabel.strokeOn = YES;
        uploadLabel.strokeColour = [UIColor blackColor];
        uploadLabel.strokeThickness = 4;
        uploadLabel.text = @"Create an image";
        [imageUploadView addSubview:uploadLabel];
        
        UILabel*upload2Label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,40)];
        upload2Label.textColor = [UIColor whiteColor];
        upload2Label.font = [UIFont fontWithName:cardMainFont size:20];
        upload2Label.textAlignment = NSTextAlignmentCenter;
        upload2Label.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 - 50);
        upload2Label.text = @"Upload from:";
        [imageUploadView addSubview:upload2Label];
        
        uploadFromFileButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        uploadFromFileButton.label.text = @"File";
        [uploadFromFileButton setTextSize:18];
        //[uploadFromFileButton setImage:[UIImage imageNamed:@"upload_from_file_button"] forState:UIControlStateNormal];
        uploadFromFileButton.center = CGPointMake(SCREEN_WIDTH/3, SCREEN_HEIGHT/2+50);
        [imageUploadView addSubview:uploadFromFileButton];
        [uploadFromFileButton addTarget:self action:@selector(uploadFromFileButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        uploadFromCameraButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        uploadFromCameraButton.label.text = @"Camera";
        [uploadFromCameraButton setTextSize:18];
        //[uploadFromCameraButton setImage:[UIImage imageNamed:@"upload_from_camera_button"] forState:UIControlStateNormal];
        //[uploadFromCameraButton setImage:[UIImage imageNamed:@"upload_from_camera_button_gray"] forState:UIControlStateDisabled];
        uploadFromCameraButton.center = CGPointMake(SCREEN_WIDTH*2/3, SCREEN_HEIGHT/2+50);
        [imageUploadView addSubview:uploadFromCameraButton];
        [uploadFromCameraButton addTarget:self action:@selector(uploadFromCameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        uploadBackButton = [[CFButton alloc] initWithFrame:CGRectMake(4, SCREEN_HEIGHT-36, 46, 32)];
        [uploadBackButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
        [uploadBackButton addTarget:self action:@selector(uploadBackButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        [imageUploadView addSubview:uploadBackButton];
        
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
            [uploadFromCameraButton setEnabled:NO];
        
        //upload indicator
        _cardUploadIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_cardUploadIndicator setFrame:self.view.bounds];
        [_cardUploadIndicator setBackgroundColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.5]];
        [_cardUploadIndicator setUserInteractionEnabled:YES];
        _cardUploadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        _cardUploadLabel.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + 60);
        _cardUploadLabel.textAlignment = NSTextAlignmentCenter;
        _cardUploadLabel.textColor = [UIColor whiteColor];
        _cardUploadLabel.font = [UIFont fontWithName:cardMainFont size:20];
        _cardUploadLabel.text = [NSString stringWithFormat:@"Uploading Card..."];
        [_cardUploadIndicator addSubview:_cardUploadLabel];
        
        _cardUploadFailedButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
        _cardUploadFailedButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 60);
        [_cardUploadFailedButton setTextSize:16];
        _cardUploadFailedButton.label.text = @"Ok";
        //[_cardUploadFailedButton setImage:[UIImage imageNamed:@"ok_button"] forState:UIControlStateNormal];
        [_cardUploadFailedButton addTarget:self action:@selector(cardUploadFailedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _cardVoteFailedButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
        [_cardVoteFailedButton setTextSize:16];
        _cardVoteFailedButton.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 60);
        _cardVoteFailedButton.label.text = @"Ok";
        //[_cardVoteFailedButton setImage:[UIImage imageNamed:@"ok_button"] forState:UIControlStateNormal];
        [_cardVoteFailedButton addTarget:self action:@selector(cardVoteFailedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
        
        keyboardSize = CGSizeMake(0, 216);
        
        [self updateCardTypeButtons];
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(tapRegistered)];
        [tapGesture setCancelsTouchesInView:NO];
        [self.view addGestureRecognizer:tapGesture];
        
        _arrowImage = [[UIImageView alloc] initWithImage:ARROW_RIGHT_ICON_IMAGE];
        _arrowImage.frame = CGRectMake(0,0,80,80);
        _arrowImage.alpha = 0.0;
        
        //------ Set Edit Areas -----//
        
        CGPoint cardImagePoint = [self.view convertPoint:self.currentCardView.cardImage.center fromView:self.currentCardView];
        imageEditArea = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.currentCardView.cardImage.frame.size.width*CARD_EDITOR_SCALE, self.currentCardView.cardImage.frame.size.height*CARD_EDITOR_SCALE -40)];
        imageEditArea.center = CGPointMake(cardImagePoint.x, cardImagePoint.y);
        
        
        //imageEditArea.backgroundColor = [UIColor redColor];
        //imageEditArea.alpha = 0.5;
        [self.view addSubview:imageEditArea];
        
        CGPoint damagePoint = [self.view convertPoint:self.currentCardView.attackLabel.center fromView:self.currentCardView];
        damageEditArea = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 60, 36)];
        damageEditArea.center = CGPointMake(damagePoint.x, damagePoint.y);
        
        //    damageEditArea.backgroundColor = [UIColor redColor];
        //    damageEditArea.alpha = 0.5;
        
        [self.view addSubview:damageEditArea];
        
        CGPoint lifePoint = [self.view convertPoint:self.currentCardView.lifeLabel.center fromView:self.currentCardView];
        
        lifeEditArea = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 60, 36)];
        lifeEditArea.center = CGPointMake(lifePoint.x, lifePoint.y);
        
        //    lifeEditArea.backgroundColor = [UIColor blueColor];
        //    lifeEditArea.alpha = 0.5;
        
        [self.view addSubview:lifeEditArea];
        
        CGPoint costPoint = [self.view convertPoint:self.currentCardView.costLabel.center fromView:self.currentCardView];
        
        costEditArea = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 56, 56)];
        costEditArea.center = CGPointMake(costPoint.x, costPoint.y);
        
        //    costEditArea.backgroundColor = [UIColor greenColor];
        //    costEditArea.alpha = 0.5;
        
        [self.view addSubview:costEditArea];
        
        CGPoint cdPoint = [self.view convertPoint:self.currentCardView.cooldownLabel.center fromView:self.currentCardView];
        
        cdEditArea = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 40, 40)];
        cdEditArea.center = CGPointMake(cdPoint.x, cdPoint.y);
        
        //    cdEditArea.backgroundColor = [UIColor grayColor];
        //    cdEditArea.alpha = 0.5;
        
        [self.view addSubview:cdEditArea];
        
        
        abilityEditArea = [[UIView alloc] initWithFrame: CGRectMake(120, 242, 186, 90)];
        
        //    abilityEditArea.backgroundColor = [UIColor lightGrayColor];
        //    abilityEditArea.alpha = 0.5;
        [self.view addSubview:abilityEditArea];
        
        //----- Customize Views ---------//
        
        if (_editorMode == cardEditorModeVoting)
            [saveCardConfirmButton addTarget:self action:@selector(voteCardConfirmButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        else
            [saveCardConfirmButton addTarget:self action:@selector(saveCardConfirmButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
        
        if (_editorMode == cardEditorModeVoting)
        {
            [tagsField setEnabled:NO];
            [tagsField setBackgroundColor:COLOUR_INTERFACE_GRAY];
            [tagsField setPlaceholder:@""];
            [tagsLabel setTextColor:COLOUR_INTERFACE_GRAY];
            [monsterCardButton setEnabled:NO];
            [spellCardButton setEnabled:NO];
            abilityExistingTableView.currentCard = _currentCardModel;
            [abilityButton setHidden:YES];
            [flavourButton setHidden:YES];
        }
        else if (_editorMode == cardEditorModeTutorialOne)
        {
            welcomeView = [[UIView alloc] initWithFrame:CGRectMake(self.currentCardView.frame.origin.x, SCREEN_HEIGHT - 200, self.currentCardView.frame.size.width, 170)];
            
            UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CardCreateDialog2"]];
            backImage.bounds = welcomeView.bounds;
            backImage.center = CGPointMake(welcomeView.frame.size.width/2, welcomeView.frame.size.height/2);
            
            [welcomeView addSubview:backImage];
            
            StrokedLabel *welcome = [[StrokedLabel alloc] initWithFrame:CGRectMake(25, 15, welcomeView.frame.size.width - 50, 45)];
            [welcome setText:@"Welcome to the Card Forge!"];
            [welcome setTextColor:[UIColor whiteColor]];
            [welcome setTextAlignment:NSTextAlignmentCenter];
            [welcome setStrokeColour:[UIColor blackColor]];
            [welcome setNumberOfLines:2];
            [welcome setFont:[UIFont fontWithName:cardMainFont size:18]];
            [welcome setStrokeOn:YES];
            [welcome setStrokeThickness:3];
            
            [welcomeView addSubview:welcome];
            
            StrokedLabel *WYL = [[StrokedLabel alloc] initWithFrame:CGRectMake(30, welcome.frame.size.height +10, welcomeView.frame.size.width -60, 50)];
            [WYL setText:@"Would you like to create a new card?"];
            [WYL setTextAlignment:NSTextAlignmentCenter];
            [WYL setNumberOfLines:2];
            [WYL setTextColor:[UIColor whiteColor]];
            [WYL setFont:[UIFont fontWithName:cardFlavourTextFont size:13]];
            
            [welcomeView addSubview:WYL];
            
            UIButton *yesButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 145, 44)];
            [yesButton setTitle:@"YES!" forState:UIControlStateNormal];
            [yesButton setTintColor:[UIColor whiteColor]];
            [yesButton.titleLabel setFont:[UIFont fontWithName:cardMainFont size:22]];
            [yesButton setBackgroundImage:[UIImage imageNamed:@"CardCreateForwardButton"] forState:UIControlStateNormal];
            [yesButton setCenter:CGPointMake(welcomeView.frame.size.width/2, welcomeView.frame.size.height - 40)];
            
            [yesButton addTarget:self action:@selector(yesButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            
            [welcomeView addSubview:yesButton];
            
            // [welcomeView setBackgroundColor:[UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0]];
            [self.view addSubview:welcomeView];
            
            //disable most views
            [damageEditArea removeFromSuperview];
            [lifeEditArea removeFromSuperview];
            [costEditArea removeFromSuperview];
            [cdEditArea removeFromSuperview];
            [elementEditArea removeFromSuperview];
            [abilityEditArea removeFromSuperview];
            [tagsField setEnabled:NO];
            [tagsField setBackgroundColor:COLOUR_INTERFACE_GRAY];
            [tagsField setPlaceholder:@""];
            [tagsLabel setTextColor:COLOUR_INTERFACE_GRAY];
            [spellCardButton setEnabled:NO];
            [monsterCardButton setEnabled:NO];
            [cancelCardButton setEnabled:NO];
            //[abilityButton setHidden:YES];
            //[flavourButton setHidden:YES];
            
            [nameTextField setUserInteractionEnabled:NO];
            [imageEditArea setUserInteractionEnabled:NO];
            
            /* CFLabel*tutorialOneLabel = [[CFLabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*3/4,  SCREEN_HEIGHT/4)];
             tutorialOneLabel.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - SCREEN_HEIGHT/3);
             tutorialOneLabel.label.text = @"This is the card forging interface. Give your card an image and a name before pressing save. We'll ignore the other buttons for now.";
             
             [self.view addSubview:tutorialOneLabel];*/
            
            [self.view addSubview:_arrowImage];
            
            _arrowImage.center = CGPointMake(yesButton.center.x - 100 + welcomeView.frame.origin.x, yesButton.center.y + welcomeView.frame.origin.y);
            
            //arow showing image
            [self performBlock:^{
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     _arrowImage.alpha = 1.0;
                                 }
                                 completion:^(BOOL finished) {
                                     [UIView animateWithDuration:0.2
                                                           delay:2
                                                         options:UIViewAnimationOptionCurveEaseInOut
                                                      animations:^{
                                                          _arrowImage.alpha = 0.0;
                                                      }
                                                      completion:^(BOOL finished) {
                                                          
                                                      }];
                                 }];
            } afterDelay:2];
            
            //arow showing image
            [self performBlock:^{
                _arrowImage.center = CGPointMake(60, 130);
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     _arrowImage.alpha = 1.0;
                                 }
                                 completion:^(BOOL finished) {
                                     [UIView animateWithDuration:0.2
                                                           delay:2
                                                         options:UIViewAnimationOptionCurveEaseInOut
                                                      animations:^{
                                                          _arrowImage.alpha = 0.0;
                                                      }
                                                      completion:^(BOOL finished) {
                                                          
                                                      }];
                                 }];
            } afterDelay:5];
            
            //arrow showing name
            [self performBlock:^{
                _arrowImage.center = CGPointMake(90, 50);
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     _arrowImage.alpha = 1.0;
                                 }
                                 completion:^(BOOL finished) {
                                     [UIView animateWithDuration:0.2
                                                           delay:2
                                                         options:UIViewAnimationOptionCurveEaseInOut
                                                      animations:^{
                                                          _arrowImage.alpha = 0.0;
                                                      }
                                                      completion:^(BOOL finished) {
                                                          
                                                      }];
                                 }];
            } afterDelay:8];
            
        }
        else if (_editorMode == cardEditorModeTutorialTwo)
        {
            if (userTutorialOneCardName != nil)
                nameTextField.text = userTutorialOneCardName;
            
            //disable element and ability views
            //[elementEditArea removeFromSuperview];
            //[abilityEditArea removeFromSuperview];
            [spellCardButton setEnabled:NO];
            [monsterCardButton setEnabled:NO];
            [cancelCardButton setEnabled:NO];
            //[abilityEditArea removeFromSuperview];
            
            //unlocked after
            [elementEditArea removeFromSuperview];
            
            //[self modalScreen];
            
            self.tutOkButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
            self.tutOkButton.label.text = @"Ok";
            
            self.tutLabel = [[CFLabel alloc] initWithFrame:CGRectMake(0,0,260,180)];
            [self setTutLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT*3/4)];
            [self.tutLabel setIsDialog:YES];
            self.tutLabel.label.text = @"You can modify the cost, damage, life, and cooldown of the card by tapping on their icons.";
            [self.tutOkButton addTarget:self action:@selector(tutorialPoints) forControlEvents:UIControlEventTouchUpInside];
            [self.tutLabel.label setTextAlignment:NSTextAlignmentCenter];
            [self.view addSubview:_tutLabel];
            [self.view addSubview:_tutOkButton];
            
            [abilityButton setHidden:NO];
            [flavourButton setHidden:NO];
            
            UIImageView *arrowImage1 = [[UIImageView alloc] initWithImage:ARROW_RIGHT_ICON_IMAGE];
            arrowImage1.frame = CGRectMake(0,0,80,80);
            arrowImage1.alpha = 0.0;
            
            [self.view addSubview:arrowImage1];
            
            //arrow showing cost
            [self performBlock:^{
                CGPoint target = [self.view convertPoint:self.currentCardView.costLabel.center fromView:self.currentCardView];
                arrowImage1.center = CGPointMake(target.x - 50, target.y);
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     arrowImage1.alpha = 1.0;
                                 }
                                 completion:^(BOOL finished) {
                                     [UIView animateWithDuration:0.2
                                                           delay:1.5
                                                         options:UIViewAnimationOptionCurveEaseInOut
                                                      animations:^{
                                                          arrowImage1.alpha = 0.0;
                                                      }
                                                      completion:^(BOOL finished) {
                                                          
                                                      }];
                                 }];
            } afterDelay:1];
            
            //arrow showing damage
            [self performBlock:^{
                CGPoint target = [self.view convertPoint:self.currentCardView.attackLabel.center fromView:self.currentCardView];
                arrowImage1.center = CGPointMake(target.x - 70, target.y);
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     arrowImage1.alpha = 1.0;
                                 }
                                 completion:^(BOOL finished) {
                                     [UIView animateWithDuration:0.2
                                                           delay:1.5
                                                         options:UIViewAnimationOptionCurveEaseInOut
                                                      animations:^{
                                                          arrowImage1.alpha = 0.0;
                                                      }
                                                      completion:^(BOOL finished) {
                                                          
                                                      }];
                                 }];
            } afterDelay:3];
            
            //arrow showing life
            [self performBlock:^{
                CGPoint target = [self.view convertPoint:self.currentCardView.lifeLabel.center fromView:self.currentCardView];
                arrowImage1.center = CGPointMake(target.x - 70, target.y);
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     arrowImage1.alpha = 1.0;
                                 }
                                 completion:^(BOOL finished) {
                                     [UIView animateWithDuration:0.2
                                                           delay:1.5
                                                         options:UIViewAnimationOptionCurveEaseInOut
                                                      animations:^{
                                                          arrowImage1.alpha = 0.0;
                                                      }
                                                      completion:^(BOOL finished) {
                                                          
                                                      }];
                                 }];
            } afterDelay:5];
            
            //arrow showing cd
            [self performBlock:^{
                CGPoint target = [self.view convertPoint:self.currentCardView.cooldownLabel.center fromView:self.currentCardView];
                arrowImage1.center = CGPointMake(target.x - 50, target.y);
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     arrowImage1.alpha = 1.0;
                                 }
                                 completion:^(BOOL finished) {
                                     [UIView animateWithDuration:0.2
                                                           delay:1.5
                                                         options:UIViewAnimationOptionCurveEaseInOut
                                                      animations:^{
                                                          arrowImage1.alpha = 0.0;
                                                      }
                                                      completion:^(BOOL finished) {
                                                          [arrowImage1 removeFromSuperview]; //deleted
                                                      }];
                                 }];
            } afterDelay:7];
            
            [saveCardButton setUserInteractionEnabled:NO];
        }
        else if (_editorMode == cardEditorModeTutorialThree)
        {
            [cancelCardButton setEnabled:NO];
            
            //just a short instruction
            self.tutOkButton = [[CFButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
            self.tutOkButton.label.text = @"Ok";
            [spellCardButton setEnabled:YES];
            
            self.tutLabel = [[CFLabel alloc] initWithFrame:CGRectMake(0,0,260,180)];
            [self setTutLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
            [self.tutLabel setIsDialog:YES];
            self.tutLabel.label.text = @"This time you're free to create any card you want.";
            [self.tutOkButton addTarget:self action:@selector(removeAllTutorialViews) forControlEvents:UIControlEventTouchUpInside];
            self.tutLabel.label.textAlignment = NSTextAlignmentCenter;
            
            [abilityButton setHidden:NO];
            [flavourButton setHidden:NO];
            
            [self modalScreen];
            
            [self.view addSubview:_tutLabel];
            [self.view addSubview:_tutOkButton];
        }
        
        //UIView*damageEditArea, *lifeEditArea, *costEditArea, *cdEditArea, *imageEditArea, *elementEditArea, *abilityEditArea;
        
        // [self resetAbilityViews];
        [self selectElement: _currentCardModel.element];
        
        if (_editorMode == cardEditorModeVoting)
        {
            [self setupExistingCard];
            [imageEditArea removeFromSuperview];
        }
        
        [self updateCost:self.currentCardModel];
        
        //opens up image selection
        if (_editorMode == cardEditorModeTutorialOne)
        {
            //[self openImageUploadScreen];
        }
    }else{
        shouldSetUpView = YES;
    }

}

-(void)yesButtonPressed{
    [saveCardButton setEnabled:YES];
    [customizeCardButton setEnabled:YES];
    [welcomeView removeFromSuperview];
    [imageEditArea setUserInteractionEnabled:YES];
    [nameTextField setUserInteractionEnabled:YES];
}

-(void)tutorialPoints
{
    [self removeAllStatButtons];
    self.tutLabel.label.text = @"The points on the star icon represents the card's overall strength. Increasing the card's strength requires more points, which can only be raised by increasing the card's resource cost.";
    
    _arrowImage.image = ARROW_LEFT_ICON_IMAGE;
    [self.view addSubview:_arrowImage];
    _arrowImage.center = CGPointMake(pointsImageBackground.center.x + 70, pointsImageBackground.center.y);
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _arrowImage.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
    
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(tutorialAbility) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tutorialAbility
{
    [self removeAllStatButtons];
    [abilityExistingTableView setUserInteractionEnabled:YES];
    [damageEditArea removeFromSuperview];
    [lifeEditArea removeFromSuperview];
    [costEditArea removeFromSuperview];
    [cdEditArea removeFromSuperview];
    //[self.view addSubview:abilityEditArea];
    
    [self setTutLabelCenter:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/4)];
    
    self.tutLabel.label.text = @"You can also change the abilities of the card by tapping on the Ability button.";
    
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(tutorialElement) forControlEvents:UIControlEventTouchUpInside];
    
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _arrowImage.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         _arrowImage.image = ARROW_DOWN_ICON_IMAGE;
                         _arrowImage.center = CGPointMake(abilityButton.center.x, abilityButton.frame.origin.y - 40);
                         
                         [UIView animateWithDuration:0.2
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              _arrowImage.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished) {
                                              
                                          }];
                     }];
    
}

-(void)tutorialElement
{
    [self.view addSubview:elementEditArea];
    self.tutLabel.label.text = @"You can also change the element of the card by tapping on the element icon, \"Neutral\" in this case. Elements do not directly affect the card, instead they allow different abilities to be added.";
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _arrowImage.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         _arrowImage.image = ARROW_RIGHT_ICON_IMAGE;
                         CGPoint target = [self.view convertPoint:self.currentCardView.elementLabel.center fromView:self.currentCardView];
                         _arrowImage.center = CGPointMake(target.x - 60, target.y);
                         
                         [UIView animateWithDuration:0.2
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              _arrowImage.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished) {
                                              
                                          }];
                     }];
    
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(tutorialTags) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tutorialTags
{
    [self modalScreen];
    
    [self.view addSubview:damageEditArea];
    [self.view addSubview:lifeEditArea];
    [self.view addSubview:costEditArea];
    [self.view addSubview:cdEditArea];
    
    self.tutLabel.label.text = @"Be sure to include at least 3 descriptive words as Tags for your card. This will help other players find it on the store. Press save after you're satisfied with everything.";
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _arrowImage.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         _arrowImage.image = ARROW_DOWN_ICON_IMAGE;
                         _arrowImage.center = CGPointMake(tagsField.center.x, tagsField.center.y - 50);
                         
                         [UIView animateWithDuration:0.2
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              _arrowImage.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished) {
                                              
                                          }];
                     }];
    
    [self.view bringSubviewToFront:self.tutOkButton];
    [self.tutOkButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.tutOkButton addTarget:self action:@selector(removeAllTutorialViews) forControlEvents:UIControlEventTouchUpInside];
}

-(void)removeAllTutorialViews
{
    [self unmodalScreen];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _arrowImage.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                     }];
    
    [saveCardButton setUserInteractionEnabled:YES];
    [self.tutOkButton removeFromSuperview];
    [self.tutLabel removeFromSuperview];
}

-(void)tapRegistered
{
    [nameTextField resignFirstResponder];
    [tagsField resignFirstResponder];
    [_flavourTextView resignFirstResponder];
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
            
            if (newSize > MAX_NAME_FONT_SIZE)
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
    while (tagsField.text.length > 100)
        tagsField.text = [tagsField.text substringToIndex:[tagsField.text length]-1];
}

-(void)keyboardOnScreen:(NSNotification *)notification
{
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

-(void)tagsFieldBegan
{
    int height = keyboardSize.height;
    
    [UIView animateWithDuration:0.4
                          delay:0.05
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.frame = CGRectMake(0,-keyboardSize.height, SCREEN_WIDTH, SCREEN_HEIGHT);
                     }
                     completion:nil];
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
    [self modifyDamage:DAMAGE_INCREMENT];
    [self damageButtonHeld:DAMAGE_INCREMENT];
}

-(void)damageDecButtonPressed
{
    
    [self modifyDamage:-DAMAGE_INCREMENT];
    [self damageButtonHeld:-DAMAGE_INCREMENT];
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
    
    if ((change > 0 && monster.baseDamage < MAX_DAMAGE)
        || (change < 0 && monster.baseDamage > MIN_DAMAGE))
    {
        monster.damage = monster.baseDamage + change;
        [self.currentCardView updateView];
        [self updateCost:self.currentCardModel];
        [self updateExistingAbilityList];
    }
    
    [self updateIncrementButton:damageDecButton];
    [self updateIncrementButton:damageIncButton];
}

-(void)lifeIncButtonPressed
{
    [self modifyLife:LIFE_INCREMENT];
    [self lifeButtonHeld:LIFE_INCREMENT];
}

-(void)lifeDecButtonPressed
{
    [self modifyLife:-LIFE_INCREMENT];
    [self lifeButtonHeld:-LIFE_INCREMENT];
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
    
    if ((change > 0 && monster.baseMaxLife < MAX_LIFE)
        || (change < 0 && monster.baseMaxLife > MIN_LIFE))
    {
        monster.maximumLife = monster.life = monster.baseMaxLife + change;
        [self.currentCardView updateView];
        [self updateCost:self.currentCardModel];
        [self updateExistingAbilityList];
    }
    
    [self updateIncrementButton:lifeDecButton];
    [self updateIncrementButton:lifeIncButton];
}

-(void)cdIncButtonPressed
{
    [self modifyCD:COOLDOWN_INCREMENT];
}

-(void)cdDecButtonPressed
{
    [self modifyCD:-COOLDOWN_INCREMENT];
}

-(void)modifyCD:(int)change
{
    MonsterCardModel*monster = (MonsterCardModel*)self.currentCardModel;
    
    if ((change > 0 && monster.baseMaxCooldown < MAX_COOLDOWN)
        || (change < 0 && monster.baseMaxCooldown > MIN_COOLDOWN))
    {
        monster.maximumCooldown = monster.cooldown = monster.baseMaxCooldown + change;
        [self.currentCardView updateView];
        [self updateCost:self.currentCardModel];
        [self updateExistingAbilityList];
    }
    
    [self updateIncrementButton:cdDecButton];
    [self updateIncrementButton:cdIncButton];
    
}

-(void)costIncButtonPressed
{
    [self modifyCost:COST_INCREMENT];
    [abilityAddButton setEnabled:NO];
}

-(void)costDecButtonPressed
{
    [self modifyCost:-COST_INCREMENT];
    [abilityAddButton setEnabled:NO];
}

-(void)modifyCost:(int)change
{
    //TODO there is rarity requirement for higher costs
    
    if ((change > 0 && self.currentCardModel.baseCost < [CardPointsUtility getMaxCostForCard:self.currentCardModel])
        || (change < 0 && self.currentCardModel.baseCost > MIN_COST))
    {
        self.currentCardModel.cost = self.currentCardModel.baseCost + change;
        [self.currentCardView updateView];
        [self updateCost:self.currentCardModel];
        [self updateExistingAbilityList];
       
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
        if (monster.baseDamage == MIN_DAMAGE)
            [damageDecButton setEnabled:NO];
        else
            [damageDecButton setEnabled:YES];
    }
    else if (button == damageIncButton)
    {
        if (monster.baseDamage == MAX_DAMAGE)
            [damageIncButton setEnabled:NO];
        else
            [damageIncButton setEnabled:YES];
    }
    else if (button == lifeDecButton)
    {
        if (monster.baseMaxLife == MIN_LIFE)
            [lifeDecButton setEnabled:NO];
        else
            [lifeDecButton setEnabled:YES];
    }
    else if (button == lifeIncButton)
    {
        if (monster.baseMaxLife == MAX_LIFE)
            [lifeIncButton setEnabled:NO];
        else
            [lifeIncButton setEnabled:YES];
    }
    else if (button == cdDecButton)
    {
        if (monster.maximumCooldown == MIN_COOLDOWN)
            [cdDecButton setEnabled:NO];
        else
            [cdDecButton setEnabled:YES];
    }
    else if (button == cdIncButton)
    {
        if (monster.maximumCooldown == MAX_COOLDOWN)
            [cdIncButton setEnabled:NO];
        else
            [cdIncButton setEnabled:YES];
    }
    else if (button == costDecButton)
    {
        if (self.currentCardModel.baseCost == MIN_COST)
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


/** Only for when changing the element etc., to remove abilities that are no longer compatible */
-(void)updateExistingAbilityList
{
    for (int i = abilityExistingTableView.currentAbilities.count - 1; i >= 0; i--)
    {
        AbilityWrapper*wrapper = abilityExistingTableView.currentAbilities[i];
        
        //update the icon in the tableView
        [CardPointsUtility updateAbilityPoints:self.currentCardModel forWrapper:wrapper withWrappers:abilityExistingTableView.currentAbilities];
        
        if (![wrapper isCompatibleWithCardModel:_currentCardModel] || wrapper.minCost > _currentCardModel.cost)
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
        
        
        
        //remove from table
        [abilityExistingTableView.currentAbilities removeObjectAtIndex:selectedIndexPath.row];
        
        
        [self updateExistingAbilityList];
        
        [abilityRemoveButton setEnabled:NO];
        [abilityIncButton setEnabled:NO];
        [abilityDecButton setEnabled:NO];
        
        [self updateCost:self.currentCardModel];
    }
}

-(void)reloadCardView
{
    UIImage*originalImage = _currentCardView.cardImage.image;
    
    NSInteger index = [self.view indexOfAccessibilityElement:_currentCardView];
    [_currentCardView removeFromSuperview];
    
    if (_editorMode == cardEditorModeTutorialTwo)
    {
        if (PLAYER_FIRST_CARD_IMAGE!=nil)
            _currentCardView = [[CardView alloc] initWithModel:_currentCardModel withImage:PLAYER_FIRST_CARD_IMAGE viewMode:cardViewModeEditor];
        else
            _currentCardView = [[CardView alloc] initWithModel:_currentCardModel withImage:originalImage viewMode:cardViewModeEditor];
    }
    else if (_currentCardModel.idNumber == NO_ID && originalImage == nil)
        _currentCardView = [[CardView alloc] initWithModel:_currentCardModel withImage:CARD_EDITOR_EMPTY_IMAGE viewMode:cardViewModeEditor];
    else
        _currentCardView = [[CardView alloc] initWithModel:_currentCardModel withImage:originalImage viewMode:cardViewModeEditor];
    
    _currentCardView.frontFacing = YES;
    _currentCardView.cardViewState = cardViewStateCardViewer;
    _currentCardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_EDITOR_SCALE, CARD_EDITOR_SCALE);
    _currentCardView.nameLabel.alpha = 0; //don't ever show the name label, since it's taken over by nameTextField
    
    _currentCardView.center = CGPointMake(210, 185);
    
    [_currentCardView updateView];
    [self.view insertSubview:_currentCardView atIndex:1];
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
        [saveCardButton setEnabled:NO];
    }
    else if(_editorMode != cardEditorModeTutorialOne)
    {
        currentCostLabel.textColor = [UIColor whiteColor];
        [saveCardButton setEnabled:YES];
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
    NSArray*originalAbilities = _currentCardModel.abilities;
    _currentCardModel.abilities = [NSMutableArray arrayWithCapacity:originalAbilities.count];
    
    //add abilities:
    
     NSArray*allAbilities = [AbilityWrapper allAbilities];
    
    for (Ability*ability in originalAbilities)
    {
        for (AbilityWrapper *wrapper in allAbilities)
        {
            if ([wrapper.ability isEqualTypeTo: ability])
            {
                AbilityWrapper *dupWrapper = [[AbilityWrapper alloc] initWithAbilityWrapper:wrapper];
                wrapper.enabled = NO;
                dupWrapper.ability.value = ability.value;
                [_currentCardModel addBaseAbility:dupWrapper.ability];
                
                [abilityExistingTableView.currentAbilities addObject:dupWrapper];
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
    [self selectElement: _currentCardModel.element];
    
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
    
    _currentCardModel = monster;
    abilityExistingTableView.currentCard = _currentCardModel;
}

-(void)spellButtonPressed
{
    [self setupNewSpell];
    
    [self resetAbilityViews];
    [self updateCost:self.currentCardModel];
    [self selectElement: _currentCardModel.element];
    
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
    
    _currentCardModel = spell;
    abilityExistingTableView.currentCard = _currentCardModel;
}


-(void)resetAbilityViews
{
    NSLog(@"resetting ability views");
    [abilityExistingTableView.currentAbilities removeAllObjects];
    [abilityExistingTableView.tableView reloadData];
    [abilityExistingTableView.tableView reloadInputViews];
    
}

-(void)updateCardTypeButtons
{
    if (_editorMode == cardEditorModeCreation || _editorMode == cardEditorModeTutorialThree)
    {
        if ([self.currentCardModel isKindOfClass:[MonsterCardModel class]])
        {
            spellCardButton.enabled = YES;
            monsterCardButton.enabled = NO;
        }
        else
        {
            spellCardButton.enabled = NO;
            monsterCardButton.enabled = YES;
        }
    }
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
    
    _cardUploadIndicator.alpha = 0;
    _cardUploadLabel.text = [NSString stringWithFormat:@"Uploading Card..."];
    [_cardUploadIndicator setColor:[UIColor whiteColor]];
    [self.view addSubview:_cardUploadIndicator];
    [_cardUploadIndicator startAnimating];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _cardUploadIndicator.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         [self performBlock:^{
                             BOOL succ = [UserModel publishCard:self.currentCardModel withImage:self.currentCardView.cardImage.image];
                             
                             if (succ)
                             {
                                 [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                                  animations:^{
                                                      _cardUploadIndicator.alpha = 0;
                                                  }
                                                  completion:^(BOOL completed){
                                                      [_cardUploadIndicator stopAnimating];
                                                      [_cardUploadIndicator removeFromSuperview];
                                                      //shouldSetUpView = NO;
                                                      [self dismissViewControllerAnimated:YES completion:nil];
                                                  }];
                             }
                             else
                             {
                                 [_cardUploadIndicator setColor:[UIColor clearColor]];
                                 _cardUploadLabel.text = [NSString stringWithFormat:@"Error uploading card."];
                                 _cardUploadFailedButton.alpha = 0;
                                 [_cardUploadIndicator addSubview:_cardUploadFailedButton];
                                 [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                                  animations:^{
                                                      _cardUploadFailedButton.alpha = 1;
                                                  }
                                                  completion:^(BOOL completed){
                                                      [_cardUploadFailedButton setUserInteractionEnabled:YES];
                                                  }];
                             }
                         }];
                     }];
}

-(void)updateCardForRarity
{
    //get rid of the confirm screen
    [self confirmCancelButtonPressed];
    
    _cardUploadIndicator.alpha = 0;
    _cardUploadLabel.text = [NSString stringWithFormat:@"Updating Card..."];
    [_cardUploadIndicator setColor:[UIColor whiteColor]];
    [self.view addSubview:_cardUploadIndicator];
    [_cardUploadIndicator startAnimating];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _cardUploadIndicator.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         [self performBlock:^{
                             //BOOL succ = [UserModel publishCard:self.currentCardModel withImage:self.currentCardView.cardImage.image];
                             //TODOBrianJune13, usermodel needs function to update card
                             BOOL succ = [UserModel updateCard:self.currentCardModel];
                             if (succ)
                             {
                                 [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                                  animations:^{
                                                      _cardUploadIndicator.alpha = 0;
                                                  }
                                                  completion:^(BOOL completed){
                                                      [_cardUploadIndicator stopAnimating];
                                                      [_cardUploadIndicator removeFromSuperview];
                                                      
                                                       //if the cardEditor was sprung by the cardCollectionView, notify the delegate to replace the card with the latest stats
                                                      if(self.delegate !=nil)
                                                      {
                                                          [self.delegate cardUpdated:self.currentCardModel];
                                                          
                                                      }
                                                     // shouldSetUpView = NO;
                                                      [self dismissViewControllerAnimated:YES completion:nil];
                                                      
                                                   
                                                     
                                                      
                                                  }];
                             }
                             else
                             {
                                 [_cardUploadIndicator setColor:[UIColor clearColor]];
                                 _cardUploadLabel.text = [NSString stringWithFormat:@"Error uploading card."];
                                 _cardUploadFailedButton.alpha = 0;
                                 [_cardUploadIndicator addSubview:_cardUploadFailedButton];
                                 [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                                  animations:^{
                                                      _cardUploadFailedButton.alpha = 1;
                                                  }
                                                  completion:^(BOOL completed){
                                                      [_cardUploadFailedButton setUserInteractionEnabled:YES];
                                                  }];
                             }
                         }];
                     }];
}

-(void)cardUploadFailedButtonPressed
{
    [_cardUploadFailedButton setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _cardUploadIndicator.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [_cardUploadFailedButton removeFromSuperview];
                     }];
    
}

-(void)cardVoteFailedButtonPressed
{
    [_cardVoteFailedButton setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _cardVoteIndicator.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [_cardVoteFailedButton removeFromSuperview];
                     }];
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
        //[self openElementEditScreen];
    }
    else if (touchedView == imageEditArea)
    {
        [self openImageUploadScreen];
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
    
    
    //element select
    if (touchedView == neutralLabel)
    {
        [self selectElement: elementNeutral];
    }
    else if (touchedView == fireLabel)
    {
        [self selectElement:  elementFire];
    }
    else if (touchedView == iceLabel)
    {
        [self selectElement:  elementIce];
    }
    else if (touchedView == lightningLabel)
    {
        [self selectElement:  elementLightning];
    }
    else if (touchedView == earthLabel)
    {
        [self selectElement: elementEarth];
    }
    else if (touchedView == lightLabel)
    {
        [self selectElement: elementLight];
    }
    else if (touchedView == darkLabel)
    {
        [self selectElement: elementDark];
    }
    
    [self abilityEditAreaSetEnabled:touchedView == abilityEditArea];
}

-(void)selectElement:(enum CardElement)element
{
    if (element == elementNeutral)
    {
        [self zoomElementLabel:neutralLabel];
        self.currentCardModel.element = elementNeutral;
        elementDescriptionLabel.text = @"Neutral cards don't have particularily power abilities of their own, but they are compatible with all other elements, making them a good addition in any deck.";
    }
    else if (element == elementFire)
    {
        [self zoomElementLabel:fireLabel];
        self.currentCardModel.element = elementFire;
        elementDescriptionLabel.text = @"Fire cards excel in dealing massive, direct damage. They also have many area-of-effect abilities that can quickly wipe their opponent's board. They cannot coexist with Ice cards in a deck.";
    }
    else if (element == elementIce)
    {
        [self zoomElementLabel:iceLabel];
        self.currentCardModel.element = elementIce;
        elementDescriptionLabel.text = @"Ice cards specialize in defensive abilities such as cooldown extension to stall their opponent's attack. They cannot coexist with Fire cards in a deck.";
    }
    else if (element == elementLightning)
    {
        [self zoomElementLabel:lightningLabel];
        self.currentCardModel.element = elementLightning;
        elementDescriptionLabel.text = @"Thunder cards deals rapid, and often random attacks that can quickly overwhelm their opponents if they are unprepared. They cannot coexist with Earth cards in a deck.";
    }
    else if (element == elementEarth)
    {
        [self zoomElementLabel:earthLabel];
        self.currentCardModel.element = elementEarth;
        elementDescriptionLabel.text = @"Earth cards often start out as weak minions, but if left unchecked, can grow to become incredibly powerful. They cannot coexist with Thunder cards in a deck.";
    }
    else if (element == elementLight)
    {
        [self zoomElementLabel:lightLabel];
        self.currentCardModel.element = elementLight;
        elementDescriptionLabel.text = @"Light cards focuses on healing and strengthening friendly creatures. They are able to increase the effectiveness of even the weakest creatures. They cannot coexist with Dark cards in a deck.";
    }
    else if (element == elementDark)
    {
        [self zoomElementLabel:darkLabel];
        self.currentCardModel.element = elementDark;
         elementDescriptionLabel.text = @"Dark cards usually have extremely powerful minions and abilities that require sacrifices from the caster. They cannot coexist with Light cards in a deck.";
    }
    
    [elementDescriptionLabel setFrame: CGRectMake(140, SCREEN_HEIGHT/6, SCREEN_WIDTH-140-20, SCREEN_HEIGHT)];
    [elementDescriptionLabel sizeToFit];
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
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (neutralLabel != view)
                             neutralLabel.transform = CGAffineTransformIdentity;
                         if (fireLabel != view)
                             fireLabel.transform = CGAffineTransformIdentity;
                         if (iceLabel != view)
                             iceLabel.transform = CGAffineTransformIdentity;
                         if (lightningLabel != view)
                             lightningLabel.transform = CGAffineTransformIdentity;
                         if (earthLabel != view)
                             earthLabel.transform = CGAffineTransformIdentity;
                         if (lightLabel != view)
                             lightLabel.transform = CGAffineTransformIdentity;
                         if (darkLabel != view)
                             darkLabel.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL completed){
                         
                     }];
}

-(void)abilityEditAreaSetEnabled:(BOOL)state
{
    [abilityExistingTableView setCenter:CGPointMake(_currentCardView.center.x, _currentCardView.center.y + _currentCardView.frame.size.height/3 -10)];
    //enable
    if (state)
    {
        [abilityAddButton setEnabled:NO]; //turn off the other table's buttons/
   
        //if there are no active abilities, do not show these buttons
        if([self.currentCardModel.abilities count] ==0)
        {
            return;
            
        }
        
        //enable editing buttons
        [self.view addSubview:abilityIncButton];
        [self.view addSubview:abilityDecButton];
        [self.view addSubview:abilityRemoveButton];
        [self.view insertSubview:abilityExistingTableView aboveSubview:abilityEditArea];
        //[self.view bringSubviewToFront:abilityExistingTableView];
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
    
    neutralLabel.center = CGPointMake(xDistance, yDistance * 1);
    fireLabel.center = CGPointMake(xDistance, yDistance * 2);
    iceLabel.center = CGPointMake(xDistance, yDistance * 3);
    lightningLabel.center = CGPointMake(xDistance, yDistance * 4);
    earthLabel.center = CGPointMake(xDistance, yDistance * 5);
    lightLabel.center = CGPointMake(xDistance, yDistance * 6);
    darkLabel.center = CGPointMake(xDistance, yDistance * 7);
    
    neutralLabel.alpha = 0;
    fireLabel.alpha = 0;
    iceLabel.alpha = 0;
    lightningLabel.alpha = 0;
    earthLabel.alpha = 0;
    lightLabel.alpha = 0;
    darkLabel.alpha = 0;
    elementConfirmButton.alpha = 0;
    elementDescriptionLabel.alpha = 0;
    
    [self.view addSubview:neutralLabel];
    [self.view addSubview:fireLabel];
    [self.view addSubview:iceLabel];
    [self.view addSubview:lightningLabel];
    [self.view addSubview:earthLabel];
    [self.view addSubview:lightLabel];
    [self.view addSubview:darkLabel];
    [self.view addSubview:elementConfirmButton];
    [self.view addSubview:elementDescriptionLabel];
    
    [elementDescriptionLabel setFrame: CGRectMake(140, SCREEN_HEIGHT/6, SCREEN_WIDTH-140-20, SCREEN_HEIGHT)];
    elementDescriptionLabel.numberOfLines = 0;
    elementDescriptionLabel.textAlignment = NSTextAlignmentLeft;
    elementDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [elementDescriptionLabel sizeToFit];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         neutralLabel.alpha = 1;
                         fireLabel.alpha = 1;
                         iceLabel.alpha = 1;
                         lightningLabel.alpha = 1;
                         earthLabel.alpha = 1;
                         lightLabel.alpha = 1;
                         darkLabel.alpha = 1;
                         elementConfirmButton.alpha = 1;
                         elementDescriptionLabel.alpha = 1;
                     }
                     completion:^(BOOL completed){
                     }];
}

-(void)elementConfirmButtonPressed
{
    [self undarkenScreen];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         neutralLabel.alpha = 0;
                         fireLabel.alpha = 0;
                         iceLabel.alpha = 0;
                         lightningLabel.alpha = 0;
                         earthLabel.alpha = 0;
                         lightLabel.alpha = 0;
                         darkLabel.alpha = 0;
                         elementConfirmButton.alpha = 0;
                         elementDescriptionLabel.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [neutralLabel removeFromSuperview];
                         [fireLabel removeFromSuperview];
                         [iceLabel removeFromSuperview];
                         [lightningLabel removeFromSuperview];
                         [earthLabel removeFromSuperview];
                         [lightLabel removeFromSuperview];
                         [darkLabel removeFromSuperview];
                         [elementConfirmButton removeFromSuperview];
                         [elementDescriptionLabel removeFromSuperview];
                     }];
    
    //[self resetAbilityViews];
    [self updateExistingAbilityList];
    [self loadAllValidAbilities];
    [self reloadCardView];
    [self updateCost:_currentCardModel];
}

-(void)openImageUploadScreen
{
    [self.view addSubview:imageUploadView];
    imageUploadView.alpha = 0;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         imageUploadView.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         
                     }];
}

-(void)uploadFromFileButtonPressed
{
    self.imagePicker = [[GKImagePicker alloc] init];
    self.imagePicker.cropSize = CGSizeMake(CARD_IMAGE_WIDTH, CARD_IMAGE_HEIGHT);
    
    [self.imagePicker.imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    self.imagePicker.delegate = self;
    
    [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
}

-(void)uploadFromCameraButtonPressed
{
    self.imagePicker = [[GKImagePicker alloc] init];
    self.imagePicker.cropSize = CGSizeMake(CARD_IMAGE_WIDTH, CARD_IMAGE_HEIGHT);
    
    [self.imagePicker.imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    self.imagePicker.delegate = self;
    
    [self presentViewController:self.imagePicker.imagePickerController animated:YES completion:nil];
}

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image
{
    scaledImage = [CardEditorViewController imageWithImage:image scaledToSize:CGSizeMake(CARD_IMAGE_WIDTH, CARD_IMAGE_HEIGHT)];
    self.currentCardView.cardImage.image = scaledImage;
    
    //NSLog(@"view %f %f, image %f %f", self.currentCardView.cardImage.frame.size.width, self.currentCardView.cardImage.frame.size.height, image.size.width, image.size.height);
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         imageUploadView.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [imageUploadView removeFromSuperview];
                     }];
    
    //[self.imageView setImage:image];
    //[self dismissViewControllerAnimated:YES completion:nil];
    shouldSetUpView = NO;
    [imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

-(void)uploadBackButtonPressed
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         imageUploadView.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [imageUploadView removeFromSuperview];
                     }];
}

-(void)rowSelected:(AbilityTableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    if (tableView == abilityExistingTableView)
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
        cardAbilitiesBackup = _currentCardModel.abilities;
        _currentCardModel.abilities = [NSMutableArray array];
    }
    
    for (AbilityWrapper*wrapper in allAbilities)
    {
        //must be valid element and rarity
        if ([wrapper isCompatibleWithCardModel:_currentCardModel])
        {
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
        _currentCardModel.abilities = cardAbilitiesBackup;

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
    if (_editorMode == cardEditorModeTutorialOne)
    {
        [self saveCardConfirmButtonPressed];
        return;
    }
    else if (_editorMode == cardEditorModeTutorialThree)
    {
        NSNumber *cardOneID = userPF[@"cardOneID"];
        if (cardOneID != nil)
        {
            for (CardModel*card in userAllCards)
            {
                if (card.idNumber == [cardOneID intValue])
                {
                    //put the two cards into a deck to check its validity
                    DeckModel*tempDeck = [[DeckModel alloc]init];
                    [tempDeck addCard:_currentCardModel];
                    [tempDeck addCard:card];
                    
                    [DeckModel validateDeckIgnoreTooFewCards:tempDeck];
                    if (tempDeck.isInvalid)
                        tutThreeWarning = YES;
                    
                    break;
                }
            }
        }
    }
    
    NSMutableArray *noDupTags = [self getTags];
    
    saveCardConfirmLabel.alpha = 0;
    saveCardConfirmButton.alpha = 0;
    confirmCancelButton.alpha = 0;
    confirmErrorOkButton.alpha = 0;
    
    //check for errors
    if ([nameTextField text].length == 0 && _editorMode != cardEditorModeVoting)
    {
        saveCardConfirmLabel.text = @"Please enter a name for your card.";
        [self.view addSubview:confirmErrorOkButton];
    }
    else if (_currentCardView.cardImage.image == CARD_EDITOR_EMPTY_IMAGE && _editorMode != cardEditorModeVoting)
    {
        saveCardConfirmLabel.text = @"Please choose an image for your card.";
        [self.view addSubview:confirmErrorOkButton];
    }
    else if (noDupTags.count < 3 && _editorMode != cardEditorModeVoting)
    {
        saveCardConfirmLabel.text = @"Please enter 3 or more different tags, separated by spaces.";
        [self.view addSubview:confirmErrorOkButton];
    }
    else
    {
        if (tutThreeWarning)
            saveCardConfirmLabel.text = @"Warning: This card is not compatible with your last card and cannot be placed into the same deck after the tutorial. Are you sure you want to create it?";
        else if (_editorMode == cardEditorModeVoting)
            saveCardConfirmLabel.text = @"Are you sure you want to cast your vote? You will not be able to edit it again.";
        else if(_editorMode ==cardEditorModeRarityUpdate)
        {
            saveCardConfirmLabel.text = @"Are you sure you want to update your card with these stats/abilities?  You will not be able to edit it again.";
        }
        else
            saveCardConfirmLabel.text = @"Are you sure you want to create this card? You will not be able to edit it again.";
        [self.view addSubview:saveCardConfirmButton];
        [self.view addSubview:confirmCancelButton];
    }
    
    [self.view addSubview:saveCardConfirmLabel];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         saveCardConfirmLabel.alpha = 1;
                         saveCardConfirmButton.alpha = 1;
                         confirmCancelButton.alpha = 1;
                         confirmErrorOkButton.alpha = 1;
                     }
                     completion:^(BOOL completed){
                     }];
}

-(void)cancelCardButtonPressed
{
    [self darkenScreen];
    
    cancelCardConfirmLabel.alpha = 0;
    cancelCardConfirmButton.alpha = 0;
    confirmCancelButton.alpha = 0;
    
    [self.view addSubview:cancelCardConfirmLabel];
    [self.view addSubview:cancelCardConfirmButton];
    [self.view addSubview:confirmCancelButton];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         cancelCardConfirmLabel.alpha = 1;
                         cancelCardConfirmButton.alpha = 1;
                         confirmCancelButton.alpha = 1;
                     }
                     completion:^(BOOL completed){
                     }];
}

/** Limits the flavour text's size */
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView == _flavourTextView)
    {
        NSString *string = _flavourTextView.text;
        int lineCount = [text length] - [[text stringByReplacingOccurrencesOfString:@"\n" withString:@""] length];
        
        if (lineCount > 4)
            return NO;
        
        int characterCount = textView.text.length + (text.length - range.length);
        
        if (characterCount > 80)
            return NO;
        else
            return YES;
    }
    return YES;
};

-(void)textViewDidChange:(UITextView *)textView
{
    if (textView == _flavourTextView)
    {
        [_customizeBackButton setEnabled:YES];
        
        //has text, will cost gold
        if (_flavourTextView.text.length > 0)
        {
            if ([userPF[@"gold"] intValue] < FLAVOUR_TEXT_COST)
            {
                _customizeBackLabel.text = @"Not enough gold";
                
                [_customizeBackButton setEnabled:NO];
            }
            else
                _customizeBackLabel.text = @"";
        }
        else
            _customizeBackLabel.text = @"";
    }
}


-(void)customizeButtonPressed
{
    [self darkenScreen];
    
    _customizeView.alpha = 0;
    [self.view addSubview:_customizeView];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _customizeView.alpha = 1;
                     }
                     completion:^(BOOL completed){
                     }];
    
}

-(void)customizeBackButtonPressed
{
    [self undarkenScreen];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _customizeView.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [_customizeView removeFromSuperview];
                         _currentCardModel.flavourText = _flavourTextView.text;
                         [_currentCardView updateView];
                     }];
}

-(void)saveCardConfirmButtonPressed
{
    self.currentCardModel.name = nameTextField.text; //TODO not exactly the best place
    if (self.currentCardModel.name.length > 100)
        [self.currentCardModel.name substringToIndex:100];

    //first tutorial's card is not actually published
    if (_editorMode == cardEditorModeTutorialOne)
    {
        //shouldSetUpView = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
   
    NSMutableArray *noDupTags = [self getTags];
    
    self.currentCardModel.tags = noDupTags;
    [userAllCards addObject:self.currentCardModel];
    
    if(_editorMode == cardEditorModeRarityUpdate)
    {
        //do update of card instead of publish
        
        [self updateCardForRarity];
        
        return;
        
    }
    [self publishCurrentCard];
}

-(NSMutableArray*) getTags
{
    NSString *lowerTags = [tagsField.text lowercaseString];
    if (lowerTags.length > 100)
        [lowerTags substringToIndex:100];
    
    NSMutableArray*lowerTagsArray = [NSMutableArray arrayWithArray:[lowerTags componentsSeparatedByString:@" "]];
    NSMutableArray*noDupTags = [NSMutableArray array];
    
    for (NSString*string in lowerTagsArray)
    {
        if (![noDupTags containsObject:string] && string.length > 0)
            [noDupTags addObject:string];
    }
    
    return noDupTags;
}

-(void)voteCardConfirmButtonPressed
{
    _cardUploadIndicator.alpha = 0;
    _cardUploadLabel.text = [NSString stringWithFormat:@"Casting vote..."];
    [_cardUploadIndicator setColor:[UIColor whiteColor]];
    [self.view addSubview:_cardUploadIndicator];
    [_cardUploadIndicator startAnimating];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _cardUploadIndicator.alpha = 1;
                     }
                     completion:^(BOOL completed){
                         PFObject*cardPF = _currentCardModel.cardPF;
                         
                         CardVote *cardVote;
                         PFObject*cardVotePF;
                         
                         //this is not actually supposed to happen, as it shouldn't be a nil, but this is just for debug cards that didn't have cardVotes when created
                         if (cardPF[@"cardVote"] == nil)
                         {
                             NSLog(@"creating card vote from nil");
                             cardVote = [[CardVote alloc] initWithCardModel:_currentCardModel];
                             cardVotePF = [PFObject objectWithClassName:@"CardVote"];
                         }
                         //normal case: just update the votes
                         else
                         {
                             NSLog(@"creating card vote from existing object");
                             cardVotePF = cardPF[@"cardVote"];
                             [cardVotePF fetch];
                             cardVote = [[CardVote alloc] initWithPFObject:cardVotePF];
                             [cardVote addVote:_currentCardModel];
                         }
                         
                         NSLog(@"created card vote");
                         
                         [cardVote generatedVotedCard:_currentCardModel];
                         [cardVote updateToPFObject:cardVotePF];
                         
                         NSLog(@"saving card vote");
                         
                         cardPF[@"cardVote"] = cardVotePF;
                         
                         //maybe the uploading part should be in cloud, but probably not that dangerous
                         [cardPF saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                             if (succeeded)
                             {
                                 [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                                  animations:^{
                                                      _cardUploadIndicator.alpha = 0;
                                                  }
                                                  completion:^(BOOL completed){
                                                      [_cardUploadIndicator stopAnimating];
                                                      [_cardUploadIndicator removeFromSuperview];
                                                      
                                                      _voteConfirmed = YES;
                                                     // shouldSetUpView = NO;
                                                      [self dismissViewControllerAnimated:YES completion:nil];
                                                  }];
                             }
                             else
                             {
                                 [_cardUploadIndicator setColor:[UIColor clearColor]];
                                 _cardUploadLabel.text = [NSString stringWithFormat:@"Error casting vote."];
                                 _cardVoteFailedButton.alpha = 0;
                                 [_cardUploadIndicator addSubview:_cardVoteFailedButton];
                                 [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                                  animations:^{
                                                      _cardVoteFailedButton.alpha = 1;
                                                  }
                                                  completion:^(BOOL completed){
                                                      [_cardVoteFailedButton setUserInteractionEnabled:YES];
                                                  }];
                             }
                         }];
                         
                     }];
}

-(void)cancelCardConfirmButtonPressed
{
    //shouldSetUpView = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)confirmCancelButtonPressed
{
    [self undarkenScreen];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         saveCardConfirmLabel.alpha = 0;
                         saveCardConfirmButton.alpha = 0;
                         cancelCardConfirmLabel.alpha = 0;
                         cancelCardConfirmButton.alpha = 0;
                         confirmCancelButton.alpha = 0;
                         confirmErrorOkButton.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [saveCardConfirmLabel removeFromSuperview];
                         [saveCardConfirmButton removeFromSuperview];
                         [cancelCardConfirmLabel removeFromSuperview];
                         [cancelCardConfirmButton removeFromSuperview];
                         [confirmCancelButton removeFromSuperview];
                         [confirmErrorOkButton removeFromSuperview];
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)darkenScreen
{
    darkFilter.alpha = 0;
    [self.view addSubview:darkFilter];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         darkFilter.alpha = 0.9;
                     }
                     completion:nil];
}

-(void)undarkenScreen
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         darkFilter.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [darkFilter removeFromSuperview];
                     }];
}


-(void)setCurrentCardModel:(CardModel *)currentCardModel
{
    _currentCardModel = currentCardModel;
    
    //update the points for the two views
    if (abilityExistingTableView != nil)
        abilityExistingTableView.currentCard = currentCardModel;
}

-(CardModel*)currentCardModel
{
    return _currentCardModel;
}

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
    _modalFilter.alpha = 3.f/255; //because apparently 0 alpha = cannot be interacted...
    [self.view addSubview:_modalFilter];
}

-(void)unmodalScreen
{
    [_modalFilter removeFromSuperview];
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

-(void)showAbilities{
    
    AbilityViewController *AVC = [[AbilityViewController alloc] init];
    
    [self removeAllStatButtons];
    
    [AVC setOriginalCard:self.currentCardModel];
    [AVC setCurrentCardModel:self.currentCardModel];
    [AVC setCardImage:scaledImage];
    [AVC setCardName:nameTextField.text];
    [AVC setEditorMode:_editorMode];
    [AVC setCurrentCost:self.currentCost];
    [AVC setMaxCost:self.maxCost];
    [AVC setDelegate:self];
    
    [self presentViewController:AVC animated:YES completion:nil];
}

- (void)cardUpdated:(CardModel *)card{
    self.currentCardModel = card;
    [self reloadCardView];
    //[self updateCost:card];
    //[self addAbilitiesToTableView];
   
}

- (void)updateAbilities:(NSMutableArray *)abilities{
    abilityExistingTableView.currentAbilities = abilities;
    [abilityExistingTableView reloadInputViews];
    [abilityExistingTableView.tableView reloadData];
}

- (void)addAbilitiesToTableView{
    
    abilityExistingTableView.currentAbilities = [[NSMutableArray alloc] init];
    
    for (AbilityWrapper*wrapper in self.currentCardModel.abilities)
    {
        [abilityExistingTableView.currentAbilities addObject:wrapper];
    }
    
    [abilityExistingTableView reloadInputViews];
    [abilityExistingTableView.tableView reloadData];
}

@end
