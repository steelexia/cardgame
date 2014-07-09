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
const int MAX_LIFE = 20000, MIN_LIFE = 100, LIFE_INCREMENT = 100;
const int MAX_COOLDOWN = 5, MIN_COOLDOWN = 1, COOLDOWN_INCREMENT = 1;
const int MIN_COST = 0, COST_INCREMENT = 1; //maxCost is an array

UITextField *nameTextField;

UIButton *damageIncButton, *damageDecButton, *lifeIncButton, *lifeDecButton, *cdIncButton, *cdDecButton, *costIncButton, *costDecButton;

/** Transparent views used to register touch events for enabling the buttons for editing the stats. */
UIView*damageEditArea, *lifeEditArea, *costEditArea, *cdEditArea, *imageEditArea, *elementEditArea, *abilityEditArea;

/** Maximum cost and count allowed for each rarity */
NSArray* rarityMaxCosts, *rarityMaxAbilityCount;
/** Spell cards can have this many extra abilities compared to Monster cards */
const int SPELL_CARD_BONUS_ABILITY_COUNT = 1;

/** New is for adding new abilities, existing is for editing existing abilities */
AbilityTableView *abilityNewTableView, *abilityExistingTableView;

UILabel*abilityValueLabel;
UIButton *abilityIncButton, *abilityDecButton, *abilityAddButton, *abilityRemoveButton;

UITextField*abilitySearchField;

CGSize keyboardSize;

/** Buttons for changing between card types */
UIButton *monsterCardButton, *spellCardButton;

UIButton *saveCardButton, *cancelCardButton, *randomizeCardButton;

UIButton *saveCardConfirmButton, *cancelCardConfirmButton, *confirmCancelButon;

UILabel *saveCardConfirmLabel, *cancelCardConfirmLabel;

/** UILabel used to darken the screen during card selections */
UILabel *darkFilter;

- (id)initWithCard:(CardModel*)card
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SCREEN_WIDTH = self.view.bounds.size.width;
    SCREEN_HEIGHT = self.view.bounds.size.height;
    
    if (_currentCardModel == nil)
    {
        //no card, start with a new one
        [self setupNewMonster];
    }
    
    rarityMaxCosts = @[
                       @10, //common TODO!!!!!!!!!!!!!!!!!!!!!!!!!!! 10 right now just for testing
                       @7, //uncommon
                       @8, //rare
                       @9, //exceptional
                       @10, //legendary
                       ];
    
    //card cannot exceed this number of abilities
    rarityMaxAbilityCount = @[
                              @4, //common TODO!!!!!!!!!!!!!!!!!!!!!!!!!!! 10 right now just for testing, should be 2
                              @2, //uncommon
                              @3, //rare
                              @3, //exceptional
                              @4, //legendary
                              ];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [self.view addSubview:_currentCardView];
    
    //----------------card basic stats views---------------------//
    
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
    [nameTextField setPlaceholder:@"Type name here"];
    [nameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [nameTextField addTarget:self action:@selector(nameTextFieldEdited) forControlEvents:UIControlEventEditingChanged];
    [nameTextField setMinimumFontSize:8.f];
    nameTextField.adjustsFontSizeToFitWidth = YES; //TODO doesn't work under 14
    
    [nameTextField setDelegate:self];
    [self.view addSubview:nameTextField];
    
    CGPoint attackLabelPoint = [self.view convertPoint:self.currentCardView.attackLabel.center fromView:self.currentCardView];
    damageIncButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    damageIncButton.center = CGPointMake(attackLabelPoint.x, attackLabelPoint.y - 28);
    [damageIncButton setImage:[UIImage imageNamed:@"increment_button"] forState:UIControlStateNormal];
    [damageIncButton setImage:[UIImage imageNamed:@"increment_button_gray"] forState:UIControlStateDisabled];
    [damageIncButton addTarget:self action:@selector(damageIncButtonPressed)    forControlEvents:UIControlEventTouchDown];
    
    //[self.view addSubview:damageIncButton];
    
    damageDecButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    damageDecButton.center = CGPointMake(attackLabelPoint.x, attackLabelPoint.y + 32);
    [damageDecButton setImage:[UIImage imageNamed:@"decrement_button"] forState:UIControlStateNormal];
    [damageDecButton setImage:[UIImage imageNamed:@"decrement_button_gray"] forState:UIControlStateDisabled];
    [damageDecButton addTarget:self action:@selector(damageDecButtonPressed)    forControlEvents:UIControlEventTouchDown];
    
    //[self.view addSubview:damageDecButton];
    
    CGPoint lifeLabelPoint = [self.view convertPoint:self.currentCardView.lifeLabel.center fromView:self.currentCardView];
    lifeIncButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    lifeIncButton.center = CGPointMake(lifeLabelPoint.x, lifeLabelPoint.y - 28);
    [lifeIncButton setImage:[UIImage imageNamed:@"increment_button"] forState:UIControlStateNormal];
    [lifeIncButton setImage:[UIImage imageNamed:@"increment_button_gray"] forState:UIControlStateDisabled];
    [lifeIncButton addTarget:self action:@selector(lifeIncButtonPressed)    forControlEvents:UIControlEventTouchDown];
    
    //[self.view addSubview:lifeIncButton];
    
    lifeDecButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    lifeDecButton.center = CGPointMake(lifeLabelPoint.x, lifeLabelPoint.y + 32);
    [lifeDecButton setImage:[UIImage imageNamed:@"decrement_button"] forState:UIControlStateNormal];
    [lifeDecButton setImage:[UIImage imageNamed:@"decrement_button_gray"] forState:UIControlStateDisabled];
    [lifeDecButton addTarget:self action:@selector(lifeDecButtonPressed)    forControlEvents:UIControlEventTouchDown];
    
    //[self.view addSubview:lifeDecButton];
    
    CGPoint cdLabelPoint = [self.view convertPoint:self.currentCardView.cooldownLabel.center fromView:self.currentCardView];
    cdIncButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    cdIncButton.center = CGPointMake(cdLabelPoint.x, cdLabelPoint.y - 32);
    [cdIncButton setImage:[UIImage imageNamed:@"increment_button"] forState:UIControlStateNormal];
    [cdIncButton setImage:[UIImage imageNamed:@"increment_button_gray"] forState:UIControlStateDisabled];
    [cdIncButton addTarget:self action:@selector(cdIncButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //[self.view addSubview:cdIncButton];
    
    cdDecButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    cdDecButton.center = CGPointMake(cdLabelPoint.x, cdLabelPoint.y + 34);
    [cdDecButton setImage:[UIImage imageNamed:@"decrement_button"] forState:UIControlStateNormal];
    [cdDecButton setImage:[UIImage imageNamed:@"decrement_button_gray"] forState:UIControlStateDisabled];
    [cdDecButton addTarget:self action:@selector(cdDecButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //[self.view addSubview:cdDecButton];
    
    CGPoint costLabelPoint = [self.view convertPoint:self.currentCardView.costLabel.center fromView:self.currentCardView];
    costIncButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    costIncButton.center = CGPointMake(costLabelPoint.x, costLabelPoint.y - 36);
    [costIncButton setImage:[UIImage imageNamed:@"increment_button"] forState:UIControlStateNormal];
    [costIncButton setImage:[UIImage imageNamed:@"increment_button_gray"] forState:UIControlStateDisabled];
    [costIncButton addTarget:self action:@selector(costIncButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //[self.view addSubview:costIncButton];
    
    costDecButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 46, 32)];
    costDecButton.center = CGPointMake(costLabelPoint.x, costLabelPoint.y + 38);
    [costDecButton setImage:[UIImage imageNamed:@"decrement_button"] forState:UIControlStateNormal];
    [costDecButton setImage:[UIImage imageNamed:@"decrement_button_gray"] forState:UIControlStateDisabled];
    [costDecButton addTarget:self action:@selector(costDecButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    //[self.view addSubview:costDecButton];
    
    [self updateAllIncrementButtons];
    
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
    
    CGPoint elementLabelPoint = [self.view convertPoint:self.currentCardView.elementLabel.center fromView:self.currentCardView];
    elementEditArea = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 56, 28)];
    elementEditArea.center = CGPointMake(elementLabelPoint.x, elementLabelPoint.y);
    
    //elementEditArea.backgroundColor = [UIColor redColor];
    //elementEditArea.alpha = 0.5;
    
    [self.view addSubview:elementEditArea];
    
    abilityEditArea = [[UIView alloc] initWithFrame: CGRectMake(80, 242, 186, 90)];
    
    //abilityEditArea.backgroundColor = [UIColor redColor];
    //abilityEditArea.alpha = 0.5;
    
    [self.view addSubview:abilityEditArea];
    
    //-------------------------ability views------------------------//
    
    //existing
    abilityExistingTableView = [[AbilityTableView alloc] initWithFrame:CGRectMake(90, 242, 172, 90)  mode:abilityTableViewExisting];
    abilityExistingTableView.cevc = self;
    //[self.view addSubview:abilityExistingTableView];
    
    //new
    abilityNewTableView = [[AbilityTableView alloc] initWithFrame:CGRectMake(80, 345, 186, SCREEN_HEIGHT - 345 - 24) mode:abilityTableViewNew];
    abilityNewTableView.cevc = self;
    [self.view addSubview:abilityNewTableView];
    
    
    abilitySearchField =  [[UITextField alloc] initWithFrame:CGRectMake(80,SCREEN_HEIGHT- 22,186,20)];
    
    abilitySearchField.textColor = [UIColor blackColor];
    abilitySearchField.font = [UIFont fontWithName:cardMainFont size:12];
    abilitySearchField.returnKeyType = UIReturnKeySearch;
    [abilitySearchField setPlaceholder:@"Search for an ability"];
    [abilitySearchField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [abilitySearchField addTarget:self action:@selector(abilitySearchFieldBegan) forControlEvents:UIControlEventEditingDidBegin];
    [abilitySearchField addTarget:self action:@selector(abilitySearchFieldFinished) forControlEvents:UIControlEventEditingDidEnd];
    [abilitySearchField setDelegate:self];
    [abilitySearchField.layer setBorderColor:COLOUR_INTERFACE_BLUE.CGColor];
    [abilitySearchField.layer setBorderWidth:1];
    //[abilitySearchField setBackgroundColor:];
    abilitySearchField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    abilitySearchField.layer.cornerRadius = 4.0;
    
    [self.view addSubview:abilitySearchField];
    
    abilityIncButton = [[UIButton alloc] initWithFrame:CGRectMake(270, 222, 46, 32)];
    [abilityIncButton setImage:[UIImage imageNamed:@"increment_button"] forState:UIControlStateNormal];
    [abilityIncButton setImage:[UIImage imageNamed:@"increment_button_gray"] forState:UIControlStateDisabled];
    [abilityIncButton addTarget:self action:@selector(abilityIncButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [abilityIncButton setEnabled:NO];
    
    //[self.view addSubview:abilityIncButton];
    
    abilityDecButton = [[UIButton alloc] initWithFrame:CGRectMake(270, 258, 46, 32)];
    [abilityDecButton setImage:[UIImage imageNamed:@"decrement_button"] forState:UIControlStateNormal];
    [abilityDecButton setImage:[UIImage imageNamed:@"decrement_button_gray"] forState:UIControlStateDisabled];
    [abilityDecButton addTarget:self action:@selector(abilityDecButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [abilityDecButton setEnabled:NO];
    
    //[self.view addSubview:abilityDecButton];
    
    abilityRemoveButton = [[UIButton alloc] initWithFrame:CGRectMake(270, 314, 46, 32)];
    [abilityRemoveButton setImage:[UIImage imageNamed:@"remove_deck_button"] forState:UIControlStateNormal];
    [abilityRemoveButton setImage:[UIImage imageNamed:@"remove_deck_button_gray"] forState:UIControlStateDisabled];
    [abilityRemoveButton addTarget:self action:@selector(abilityRemoveButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [abilityRemoveButton setEnabled:NO];
    
    //[self.view addSubview:abilityRemoveButton];
    
    abilityAddButton = [[UIButton alloc] initWithFrame:CGRectMake(270, SCREEN_HEIGHT - 64, 46, 32)];
    [abilityAddButton setImage:[UIImage imageNamed:@"add_deck_button"] forState:UIControlStateNormal];
    [abilityAddButton setImage:[UIImage imageNamed:@"add_deck_button_gray"] forState:UIControlStateDisabled];
    [abilityAddButton addTarget:self action:@selector(abilityAddButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [abilityAddButton setEnabled:NO];
    
    [self.view addSubview:abilityAddButton];
    
    //, *lifeEditArea, *costEditArea, *cdEditArea, *imageEditArea;
    
    self.currentCardModel = self.currentCardModel; //send the model to views
    [self loadAllValidAbilities];
    
    monsterCardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
    [monsterCardButton setImage:[UIImage imageNamed:@"monster_button"] forState:UIControlStateNormal];
    [monsterCardButton setImage:[UIImage imageNamed:@"monster_button_gray"] forState:UIControlStateDisabled];
    monsterCardButton.center = CGPointMake(35, 50);
    [monsterCardButton addTarget:self action:@selector(monsterButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:monsterCardButton];
    
    spellCardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
    [spellCardButton setImage:[UIImage imageNamed:@"spell_button"] forState:UIControlStateNormal];
    [spellCardButton setImage:[UIImage imageNamed:@"spell_button_gray"] forState:UIControlStateDisabled];
    spellCardButton.center = CGPointMake(35, 105);
    [spellCardButton addTarget:self action:@selector(spellButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:spellCardButton];
    
    saveCardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [saveCardButton setImage:[UIImage imageNamed:@"save_card_button"] forState:UIControlStateNormal];
    [saveCardButton setImage:[UIImage imageNamed:@"save_card_button_gray"] forState:UIControlStateDisabled];
    saveCardButton.center = CGPointMake(35, SCREEN_HEIGHT - 25);
    [saveCardButton addTarget:self action:@selector(saveCardButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveCardButton];
    
    cancelCardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [cancelCardButton setImage:[UIImage imageNamed:@"cancel_card_button"] forState:UIControlStateNormal];
    cancelCardButton.center = CGPointMake(35, SCREEN_HEIGHT - 70);
    [cancelCardButton addTarget:self action:@selector(cancelCardButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelCardButton];
    
    randomizeCardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [randomizeCardButton setImage:[UIImage imageNamed:@"randomize_card_button"] forState:UIControlStateNormal];
    randomizeCardButton.center = CGPointMake(35, SCREEN_HEIGHT - 115);
    [randomizeCardButton addTarget:self action:@selector(randomizeCardButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:randomizeCardButton];
    
    
    //confirmation dialogs
    saveCardConfirmLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT)];
    saveCardConfirmLabel.textColor = [UIColor whiteColor];
    saveCardConfirmLabel.backgroundColor = [UIColor clearColor];
    saveCardConfirmLabel.font = [UIFont fontWithName:cardMainFont size:25];
    saveCardConfirmLabel.textAlignment = NSTextAlignmentCenter;
    saveCardConfirmLabel.lineBreakMode = NSLineBreakByWordWrapping;
    saveCardConfirmLabel.numberOfLines = 0;
    saveCardConfirmLabel.text = @"Are you sure you want to create this card? You will not be able to edit it again.";
    [saveCardConfirmLabel sizeToFit];
    
    saveCardConfirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    saveCardConfirmButton.center = CGPointMake(SCREEN_WIDTH/2 - 80, SCREEN_HEIGHT - 60);
    [saveCardConfirmButton setImage:[UIImage imageNamed:@"yes_button"] forState:UIControlStateNormal];
    [saveCardConfirmButton addTarget:self action:@selector(saveCardConfirmButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    confirmCancelButon = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    confirmCancelButon.center = CGPointMake(SCREEN_WIDTH/2 + 80, SCREEN_HEIGHT - 60);
    [confirmCancelButon setImage:[UIImage imageNamed:@"no_button"] forState:UIControlStateNormal];
    [confirmCancelButon addTarget:self action:@selector(confirmCancelButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    cancelCardConfirmLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*1/8, SCREEN_HEIGHT/4, SCREEN_WIDTH*6/8, SCREEN_HEIGHT)];
    cancelCardConfirmLabel.textColor = [UIColor whiteColor];
    cancelCardConfirmLabel.backgroundColor = [UIColor clearColor];
    cancelCardConfirmLabel.font = [UIFont fontWithName:cardMainFont size:25];
    cancelCardConfirmLabel.textAlignment = NSTextAlignmentCenter;
    cancelCardConfirmLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cancelCardConfirmLabel.numberOfLines = 0;
    cancelCardConfirmLabel.text = @"Are you sure you want to cancel? All progress will be lost.";
    [cancelCardConfirmLabel sizeToFit];
    
    cancelCardConfirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    cancelCardConfirmButton.center = CGPointMake(SCREEN_WIDTH/2 - 80, SCREEN_HEIGHT - 60);
    [cancelCardConfirmButton setImage:[UIImage imageNamed:@"yes_button"] forState:UIControlStateNormal];
    [cancelCardConfirmButton addTarget:self action:@selector(cancelCardConfirmButtonPressed)    forControlEvents:UIControlEventTouchUpInside];
    
    darkFilter = [[UILabel alloc] initWithFrame:self.view.bounds];
    darkFilter.backgroundColor = [[UIColor alloc]initWithHue:0 saturation:0 brightness:0 alpha:0.8];
    [darkFilter setUserInteractionEnabled:YES]; //blocks all interaction behind it
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    
    keyboardSize = CGSizeMake(0, 216);
    
    [self updateCardTypeButtons];
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(tapRegistered)];
    [tapGesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGesture];
}

-(void)tapRegistered
{
    [nameTextField resignFirstResponder];
    [abilitySearchField resignFirstResponder];
}

-(void)nameTextFieldEdited
{
    //NSLog(@"%d", nameTextField.adjustsFontSizeToFitWidth);
    //NSLog(@"%f", nameTextField.font.pointSize);
    
    //TODO SHOULD NOT BE DOING THIS MANUALLY BUT THE AUTOMATIC ONE DOESN'T WORK
    
    //ios 7 only
    //CGSize textSize = [[label text] sizeWithAttributes:@{NSFontAttributeName:[label font]}];
    
    BOOL maximumLengthReached = NO;
    
    CGSize textSize = [[nameTextField text] sizeWithFont:[nameTextField font]];
    
    if (textSize.width > nameTextField.bounds.size.width)
    {
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

-(void)keyboardOnScreen:(NSNotification *)notification
{
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
}

-(void)abilitySearchFieldBegan
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

-(void)abilitySearchFieldFinished
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
        //TODO update points
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
        //TODO update points
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
        //TOOD update points
    }
    
    [self updateIncrementButton:cdDecButton];
    [self updateIncrementButton:cdIncButton];
    
}

-(void)costIncButtonPressed
{
    [self modifyCost:COST_INCREMENT];
}

-(void)costDecButtonPressed
{
    [self modifyCost:-COST_INCREMENT];
}

-(void)modifyCost:(int)change
{
    //TODO there is rarity requirement for higher costs
    
    if ((change > 0 && self.currentCardModel.baseCost < [rarityMaxCosts[self.currentCardModel.rarity] integerValue])
        || (change < 0 && self.currentCardModel.baseCost > MIN_COST))
    {
        self.currentCardModel.cost = self.currentCardModel.baseCost + change;
        [self.currentCardView updateView];
        //TOOD update points
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
        if (self.currentCardModel.baseCost == [rarityMaxCosts[self.currentCardModel.rarity] integerValue])
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
    
    [self updateAbilityButtons:wrapper];
}

-(void)abilityAddButtonPressed
{
    NSIndexPath *selectedIndexPath = [abilityNewTableView.tableView indexPathForSelectedRow];
    
    if (selectedIndexPath!=nil)
    {
        AbilityWrapper *wrapper = abilityNewTableView.currentAbilities[selectedIndexPath.row];
        AbilityTableViewCell *cell = (AbilityTableViewCell*)[abilityNewTableView.tableView cellForRowAtIndexPath:selectedIndexPath];
        
        /*
         [abilityNewTableView setAbilityAt:selectedIndexPath toState:NO];
         [abilityNewTableView.tableView reloadData];
         [abilityNewTableView reloadInputViews];
         */
        
        [abilityAddButton setEnabled:NO];
        
        AbilityWrapper *dupWrapper = [[AbilityWrapper alloc] initWithAbilityWrapper:wrapper];
        if (dupWrapper.ability.otherValues.count > 0)
            dupWrapper.ability.value = dupWrapper.ability.otherValues[0];
        
        
        [abilityExistingTableView.currentAbilities addObject:dupWrapper];
        [abilityExistingTableView.tableView reloadData];
        [abilityExistingTableView reloadInputViews];
        [self abilityEditAreaSetEnabled:YES];
        
        
        //update new abilities
        [self.currentCardModel addBaseAbility:dupWrapper.ability];
        
        [self updateNewAbilityList];
    }
}

-(void)updateNewAbilityList
{
    //[self loadAllValidAbilities];
    
    for (AbilityWrapper*wrapper in abilityNewTableView.currentAbilities)
    {
        wrapper.enabled = YES;
        for (AbilityWrapper*existingWrapper in abilityExistingTableView.currentAbilities)
        {
            if ([existingWrapper.ability isEqualTypeTo:wrapper.ability])
            {
                wrapper.enabled = NO;
                break;
            }
        }
        
        if (wrapper.enabled == YES && ![self.currentCardModel isCompatible:wrapper.ability])
            wrapper.enabled = NO;
    }
    
    [abilityNewTableView.tableView reloadData];
    [abilityNewTableView reloadInputViews];
}


-(void)abilityRemoveButtonPressed
{
    NSIndexPath *selectedIndexPath = [abilityExistingTableView.tableView indexPathForSelectedRow];
    
    if (selectedIndexPath!=nil)
    {
        AbilityWrapper *wrapper = abilityExistingTableView.currentAbilities[selectedIndexPath.row];
        
        //remove from monster
        for (int i =0 ; i < self.currentCardModel.abilities.count; i++)
        {
            Ability *ability = self.currentCardModel.abilities[i];
            if (ability == wrapper.ability)
            {
                [self.currentCardModel.abilities removeObjectAtIndex:i];
                break;
            }
        }
        
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
        
        [abilityNewTableView.tableView reloadData];
        [abilityNewTableView reloadInputViews];
        [abilityExistingTableView.tableView reloadData];
        [abilityExistingTableView reloadInputViews];
        
        [abilityRemoveButton setEnabled:NO];
        [abilityIncButton setEnabled:NO];
        [abilityDecButton setEnabled:NO];
    }
}

-(void)monsterButtonPressed
{
    [self setupNewMonster];
    [self updateCardTypeButtons];
    
    [costDecButton removeFromSuperview];
    [costIncButton removeFromSuperview];
}

-(void)setupNewMonster
{
    MonsterCardModel*monster = [[MonsterCardModel alloc] initWithIdNumber:-1];
    
    monster.life = monster.maximumLife = 1000;
    monster.damage = 1000;
    monster.cost = 1;
    monster.cooldown = monster.maximumCooldown = 1;
    
    if (self.currentCardModel!=nil)
        monster.name = self.currentCardModel.name;
    else
        monster.name = @"";
    
    _currentCardModel = monster;
    
    int index = 0;
    if (_currentCardView!=nil)
    {
        index = [[self.view subviews] indexOfObject:_currentCardView];
        [_currentCardView removeFromSuperview];
    }
    
    _currentCardView = [[CardView alloc] initWithModel:monster cardImage:[[UIImageView alloc]initWithImage: [UIImage imageNamed:@"card_image_placeholder"]]viewMode:cardViewModeEditor];
    _currentCardView.cardViewState = cardViewStateCardViewer;
    _currentCardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_EDITOR_SCALE, CARD_EDITOR_SCALE);
    
    _currentCardView.center = CGPointMake(175, 185);
    
    [_currentCardView updateView];
    [self.view insertSubview:_currentCardView atIndex:index];
    
    self.currentCardModel = monster;
    
    [self resetAbilityViews];
}

-(void)spellButtonPressed
{
    [self setupNewSpell];
    [self updateCardTypeButtons];
    
    [self removeAllStatButtons];
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

-(void)setupNewSpell
{
    SpellCardModel*spell = [[SpellCardModel alloc] initWithIdNumber:-1];
    spell.cost = 1;
    
    if (self.currentCardModel!=nil)
        spell.name = self.currentCardModel.name;
    else
        spell.name = @"";
    
    _currentCardModel = spell;
    
    int index = 0;
    if (_currentCardView!=nil)
    {
        index = (int)[[self.view subviews] indexOfObject:_currentCardView];
        [_currentCardView removeFromSuperview];
    }
    
    _currentCardView = [[CardView alloc] initWithModel:spell cardImage:[[UIImageView alloc]initWithImage: [UIImage imageNamed:@"card_image_placeholder"]]viewMode:cardViewModeEditor];
    _currentCardView.cardViewState = cardViewStateCardViewer;
    _currentCardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_EDITOR_SCALE, CARD_EDITOR_SCALE);
    
    _currentCardView.center = CGPointMake(175, 185);
    
    [_currentCardView updateView];
    [self.view insertSubview:_currentCardView atIndex:index];
    
    self.currentCardModel = spell;
    
    [self resetAbilityViews];
}


-(void)resetAbilityViews
{
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

/** When OK is pressed and the card is sent to Parse database */
- (void) publishCurrentCard
{
    [UserModel publishCard:self.currentCardModel];
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

-(void)abilityEditAreaSetEnabled:(BOOL)state
{
    //enable
    if (state)
    {
        [abilityAddButton setEnabled:NO]; //turn off the other table's buttons/
        [abilityNewTableView.tableView deselectRowAtIndexPath:abilityNewTableView.tableView.indexPathForSelectedRow animated:YES];
        
        //enable editing buttons
        [self.view addSubview:abilityIncButton];
        [self.view addSubview:abilityDecButton];
        [self.view addSubview:abilityRemoveButton];
        [self.view addSubview:abilityExistingTableView];
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

-(void)rowSelected:(AbilityTableView*)tableView indexPath:(NSIndexPath *)indexPath
{
    if (tableView == abilityNewTableView)
    {
        if (indexPath.row < 0 || indexPath.row >= abilityNewTableView.currentAbilities.count) //being defensive
            return;
        
        [abilityAddButton setEnabled:[abilityNewTableView.currentAbilities[indexPath.row] enabled]];
        [self abilityEditAreaSetEnabled:NO]; //turn off the other table's buttons
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
    if (ability.value != nil)
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
    BOOL isSpellCard = [self.currentCardModel isKindOfClass:[SpellCardModel class]];
    
    for (AbilityWrapper*wrapper in allAbilities)
    {
        //must be valid element and rarity
        if (wrapper.element == self.currentCardModel.element && wrapper.rarity <= self.currentCardModel.rarity)
        {
            if (!isSpellCard || wrapper.ability.castType == castOnSummon)
                [abilityNewTableView.currentAbilities addObject:wrapper];
        }
    }
    
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

-(void)saveCardButtonPressed
{
    [self darkenScreen];
    
    saveCardConfirmLabel.alpha = 0;
    saveCardConfirmButton.alpha = 0;
    confirmCancelButon.alpha = 0;
    
    [self.view addSubview:saveCardConfirmLabel];
    [self.view addSubview:saveCardConfirmButton];
    [self.view addSubview:confirmCancelButon];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         saveCardConfirmLabel.alpha = 1;
                         saveCardConfirmButton.alpha = 1;
                         confirmCancelButon.alpha = 1;
                     }
                     completion:^(BOOL completed){
                     }];
}

-(void)cancelCardButtonPressed
{
    [self darkenScreen];
    
    cancelCardConfirmLabel.alpha = 0;
    cancelCardConfirmButton.alpha = 0;
    confirmCancelButon.alpha = 0;
    
    [self.view addSubview:cancelCardConfirmLabel];
    [self.view addSubview:cancelCardConfirmButton];
    [self.view addSubview:confirmCancelButon];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         cancelCardConfirmLabel.alpha = 1;
                         cancelCardConfirmButton.alpha = 1;
                         confirmCancelButon.alpha = 1;
                     }
                     completion:^(BOOL completed){
                     }];
}

-(void)randomizeCardButtonPressed
{
    NSLog(@"TODO"); //TODO
}

-(void)saveCardConfirmButtonPressed
{
    self.currentCardModel.name = nameTextField.text; //TODO not exactly the best place
    
    [userAllCards addObject:self.currentCardModel]; //TODO might not be needed once using parse
    [self publishCurrentCard];
    
    MainScreenViewController *viewController = [[MainScreenViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)cancelCardConfirmButtonPressed
{
    MainScreenViewController *viewController = [[MainScreenViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
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
                         confirmCancelButon.alpha = 0;
                     }
                     completion:^(BOOL completed){
                         [saveCardConfirmLabel removeFromSuperview];
                         [saveCardConfirmButton removeFromSuperview];
                         [cancelCardConfirmLabel removeFromSuperview];
                         [cancelCardConfirmButton removeFromSuperview];
                         [confirmCancelButon removeFromSuperview];
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
    if (abilityNewTableView != nil)
        abilityNewTableView.currentCard = currentCardModel;
    if (abilityExistingTableView != nil)
        abilityExistingTableView.currentCard = currentCardModel;
}

-(CardModel*)currentCardModel
{
    return _currentCardModel;
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


@end