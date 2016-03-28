//
//  CardView.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CardView.h"
#import "UIConstants.h"
#import "StoreCardCell.h"
#import "CustomCollectionView.h"

@implementation CardView

@synthesize cardModel = _cardModel;
@synthesize center = _center;
@synthesize cardViewState = _cardViewState;
@synthesize originalPosition = _originalPosition;
@synthesize nameLabel, costLabel, attackLabel, lifeLabel, cooldownLabel, baseAbilityLabel, elementLabel, reportedLabel;
@synthesize previousViewIndex;
@synthesize cardImage = _cardImage;
@synthesize cardHighlightType = _cardHighlightType;
@synthesize lifeViewNeedsUpdate = _lifeViewNeedsUpdate;
@synthesize damageViewNeedsUpdate = _damageViewNeedsUpdate;
@synthesize cooldownViewNeedsUpdate = _cooldownViewNeedsUpdate;
@synthesize cardViewMode = _cardViewMode;
@synthesize mask = _mask;
@synthesize frontFacing = _frontFacing;

 int CARD_WIDTH_RATIO = 5;
 int CARD_HEIGHT_RATIO = 8;
 float CARD_IMAGE_RATIO = 450.f/530;


 double CARD_VIEWER_SCALE = 0.8f;
 double CARD_VIEWER_MAXED_SCALE = 1.25;

//brian jul28
//original value 0.4f
 float CARD_DEFAULT_SCALE = 0.4f;
 float CARD_DRAGGING_SCALE = 1.0f;
float CARD_GAMEPLAY_SCALE = 0.5f;


int CARD_IMAGE_WIDTH;
int CARD_IMAGE_HEIGHT;

int CARD_NAME_SIZE;

int CARD_DETAIL_BUTTON_WIDTH;
int CARD_DETAIL_BUTTON_HEIGHT;

int CARD_LIKE_ICON_WIDTH;

/** Dummy initial values, will be changed in setup */
int CARD_WIDTH = 50, CARD_HEIGHT = 80;
int CARD_GAMEPLAY_WIDTH = 50, CARD_GAMEPLAY_HEIGHT= 80;
int CARD_NAME_SIZE_GAMEPLAY;

int CARD_FULL_WIDTH = 50, CARD_FULL_HEIGHT = 80;
int CARD_GAMEPLAY_FULL_WIDTH = 50, CARD_GAMEPLAY_FULL_HEIGHT = 80;

int PLAYER_HERO_WIDTH = 50, PLAYER_HERO_HEIGHT = 50;

UIImage *backgroundMonsterOverlayImage, *selectHighlightImage, *targetHighlightImage, *heroSelectHighlightImage, *heroTargetHighlightImage;

UIImage *cardBackImage;

UIImage *heroPlaceHolderImage, *loadingImage;

/** 2D array of images. First array contains elements, second array contains rarity */
NSArray*backgroundImages, *backgroundOverlayImages, *abilityIconImages;

NSMutableParagraphStyle *abilityTextParagrahStyle;
NSDictionary *abilityTextAttributtes, *flavourTextAttributes;

NSString *cardMainFont = @"EncodeSansCompressed-Bold";
NSString *cardMainFontBlack = @"EncodeSansCompressed-Black";
NSString *cardFlavourTextFont = @"LiberationSans-BoldItalic";

NSMutableDictionary *standardCardImages;
NSDictionary *singlePlayerCardImages;

+(void) loadResources
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CARD_WIDTH = 57;
        CARD_HEIGHT = (CARD_WIDTH *  CARD_HEIGHT_RATIO / CARD_WIDTH_RATIO);
        CARD_NAME_SIZE = 15;
        CARD_LIKE_ICON_WIDTH = 28;
        CARD_DETAIL_BUTTON_WIDTH = 80;
        CARD_DETAIL_BUTTON_HEIGHT = 60;
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        CARD_GAMEPLAY_WIDTH = 140;
        CARD_GAMEPLAY_HEIGHT = CARD_GAMEPLAY_WIDTH * CARD_HEIGHT_RATIO/ CARD_WIDTH_RATIO;
        CARD_WIDTH = 262; //TODO ipad make this 2 times but also fix bunch of other stuff
        CARD_HEIGHT = (CARD_WIDTH *  CARD_HEIGHT_RATIO / CARD_WIDTH_RATIO);
        
        //CARD_DEFAULT_SCALE = 0.8f;
        CARD_GAMEPLAY_SCALE = 0.5f;
        
        CARD_DEFAULT_SCALE = 0.8f;
        CARD_DRAGGING_SCALE = 2.0f;
        CARD_NAME_SIZE = 30;
        CARD_NAME_SIZE_GAMEPLAY = 20;
        CARD_LIKE_ICON_WIDTH = 56;
        CARD_DETAIL_BUTTON_WIDTH = 160;
        CARD_DETAIL_BUTTON_HEIGHT = 120;
    }
    
    CARD_FULL_WIDTH = CARD_WIDTH/CARD_DEFAULT_SCALE;
    CARD_FULL_HEIGHT = CARD_HEIGHT/CARD_DEFAULT_SCALE;
    
    CARD_GAMEPLAY_FULL_HEIGHT = CARD_GAMEPLAY_HEIGHT/CARD_DEFAULT_SCALE;
    CARD_GAMEPLAY_FULL_WIDTH = CARD_GAMEPLAY_WIDTH/CARD_DEFAULT_SCALE;
    
    
    
    CARD_IMAGE_WIDTH = 265;
    CARD_IMAGE_HEIGHT = 225;
    
    PLAYER_HERO_WIDTH = PLAYER_HERO_HEIGHT = CARD_HEIGHT;
    
    //for checking fonts
    /*
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
    */
    backgroundImages = @[
                         @[[UIImage imageNamed:@"CardBase.png"],
                           //TODO replace with additional rarity here
                           //NOTE: actually different elements probably won't get different images for each rarity. however that's not to say it can't be added in the future
                           [UIImage imageNamed:@"CardBase.png"],
                           [UIImage imageNamed:@"CardBase.png"],
                           [UIImage imageNamed:@"CardBase.png"],
                           [UIImage imageNamed:@"CardBase.png"],
                           ],
                         @[[UIImage imageNamed:@"CardBackgroundFire.png"],
                           [UIImage imageNamed:@"CardBackgroundFire.png"],
                           [UIImage imageNamed:@"CardBackgroundFire.png"],
                           [UIImage imageNamed:@"CardBackgroundFire.png"],
                           [UIImage imageNamed:@"CardBackgroundFire.png"],
                           ],
                         @[[UIImage imageNamed:@"CardBackgroundIce.png"],
                           [UIImage imageNamed:@"CardBackgroundIce.png"],
                           [UIImage imageNamed:@"CardBackgroundIce.png"],
                           [UIImage imageNamed:@"CardBackgroundIce.png"],
                           [UIImage imageNamed:@"CardBackgroundIce.png"],
                           ],
                         @[[UIImage imageNamed:@"CardBackgroundLightning.png"],
                           [UIImage imageNamed:@"CardBackgroundLightning.png"],
                           [UIImage imageNamed:@"CardBackgroundLightning.png"],
                           [UIImage imageNamed:@"CardBackgroundLightning.png"],
                           [UIImage imageNamed:@"CardBackgroundLightning.png"],
                           ],
                         @[[UIImage imageNamed:@"CardBackgroundEarth.png"],
                           [UIImage imageNamed:@"CardBackgroundEarth.png"],
                           [UIImage imageNamed:@"CardBackgroundEarth.png"],
                           [UIImage imageNamed:@"CardBackgroundEarth.png"],
                           [UIImage imageNamed:@"CardBackgroundEarth.png"],
                           ],
                         @[[UIImage imageNamed:@"CardBackgroundLight.png"],
                           [UIImage imageNamed:@"CardBackgroundLight.png"],
                           [UIImage imageNamed:@"CardBackgroundLight.png"],
                           [UIImage imageNamed:@"CardBackgroundLight.png"],
                           [UIImage imageNamed:@"CardBackgroundLight.png"],
                           ],
                         @[[UIImage imageNamed:@"CardBackgroundDark.png"],
                           [UIImage imageNamed:@"CardBackgroundDark.png"],
                           [UIImage imageNamed:@"CardBackgroundDark.png"],
                           [UIImage imageNamed:@"CardBackgroundDark.png"],
                           [UIImage imageNamed:@"CardBackgroundDark.png"],
                           ],
                         ];
    
    //ensure order is same as enum order
    abilityIconImages = @[
                          [UIImage imageNamed:@"card_ability_icon_cast_on_move"],
                          [UIImage imageNamed:@"card_ability_icon_cast_on_death"],
                          [UIImage imageNamed:@"card_ability_icon_cast_on_hit"],
                          [UIImage imageNamed:@"card_ability_icon_cast_on_damaged"],
                          [UIImage imageNamed:@"card_ability_icon_taunt"],
                          [UIImage imageNamed:@"card_ability_icon_assassin"],
                          [UIImage imageNamed:@"card_ability_icon_pierce"],
                          [UIImage imageNamed:@"card_ability_icon_remove_ability"],
                          ];
    
    //brianjuly26
    //nolonger use these
    backgroundOverlayImages = @[
                                [UIImage imageNamed:@"card_background_front_overlay_common"],
                                //TODO other rarities
                                [UIImage imageNamed:@"card_background_front_overlay_uncommon"],
                                [UIImage imageNamed:@"card_background_front_overlay_rare"],
                                [UIImage imageNamed:@"card_background_front_overlay_exceptional"],
                                [UIImage imageNamed:@"card_background_front_overlay_legendary"],
                                ];
    
    
    singlePlayerCardImages = @{
                               //starting deck
                               @"1" : [UIImage imageNamed:@"card_0001"],
                               @"2" : [UIImage imageNamed:@"card_0002"],
                               @"3" : [UIImage imageNamed:@"card_0003"],
                               @"4" : [UIImage imageNamed:@"card_0004"],
                               @"5" : [UIImage imageNamed:@"card_0005"],
                               @"6" : [UIImage imageNamed:@"card_0006"],
                               @"7" : [UIImage imageNamed:@"card_0007"],
                               @"8" : [UIImage imageNamed:@"card_0008"],
                               @"9" : [UIImage imageNamed:@"card_0009"],
                               @"10" : [UIImage imageNamed:@"card_0010"],
                               @"11" : [UIImage imageNamed:@"card_0011"],
                               @"12" : [UIImage imageNamed:@"card_0012"],
                               @"13" : [UIImage imageNamed:@"card_0013"],
                               @"14" : [UIImage imageNamed:@"card_0014"],
                               @"15" : [UIImage imageNamed:@"card_0015"],
                               @"16" : [UIImage imageNamed:@"card_0016"],
                               @"17" : [UIImage imageNamed:@"card_0017"],
                               @"18" : [UIImage imageNamed:@"card_0018"],
                               @"19" : [UIImage imageNamed:@"card_0019"],
                               @"20" : [UIImage imageNamed:@"card_0020"],
                               
                               @"1000" : [UIImage imageNamed:@"card_1000"],
                               @"1001" : [UIImage imageNamed:@"card_1001"],
                               @"1002" : [UIImage imageNamed:@"card_1002"],
                               @"1003" : [UIImage imageNamed:@"card_1003"],
                               @"1004" : [UIImage imageNamed:@"card_1004"],
                               @"1005" : [UIImage imageNamed:@"card_1005"],
                               @"1006" : [UIImage imageNamed:@"card_1006"],
                               @"1100" : [UIImage imageNamed:@"card_1100"],
                               
                               @"2000" : [UIImage imageNamed:@"card_2000"],
                               @"2001" : [UIImage imageNamed:@"card_2001"],
                               @"2002" : [UIImage imageNamed:@"card_2002"],
                               @"2003" : [UIImage imageNamed:@"card_2003"],
                               @"2004" : [UIImage imageNamed:@"card_2004"],
                               @"2005" : [UIImage imageNamed:@"card_2005"],
                               @"2006" : [UIImage imageNamed:@"card_2006"],
                               @"2007" : [UIImage imageNamed:@"card_2007"],
                               @"2008" : [UIImage imageNamed:@"card_2008"],
                               @"2009" : [UIImage imageNamed:@"card_2009"],
                               @"2100" : [UIImage imageNamed:@"card_2100"],
                               @"2101" : [UIImage imageNamed:@"card_2101"],
                               @"2102" : [UIImage imageNamed:@"card_2102"],
                               @"2200" : [UIImage imageNamed:@"card_2200"],
                               @"2201" : [UIImage imageNamed:@"card_2201"],
                               @"2202" : [UIImage imageNamed:@"card_2202"],
                               @"2300" : [UIImage imageNamed:@"card_2300"],
                               @"2301" : [UIImage imageNamed:@"card_2301"],
                               @"2302" : [UIImage imageNamed:@"card_2302"],
                               @"2303" : [UIImage imageNamed:@"card_2303"],
                               @"2400" : [UIImage imageNamed:@"card_2400"],
                               
                               @"3000" : [UIImage imageNamed:@"card_3000"],
                               @"3001" : [UIImage imageNamed:@"card_3001"],
                               @"3002" : [UIImage imageNamed:@"card_3002"],
                               @"3003" : [UIImage imageNamed:@"card_3003"],
                               @"3004" : [UIImage imageNamed:@"card_3004"],
                               @"3005" : [UIImage imageNamed:@"card_3005"],
                               @"3006" : [UIImage imageNamed:@"card_3006"],
                               @"3007" : [UIImage imageNamed:@"card_3007"],
                               @"3008" : [UIImage imageNamed:@"card_3008"],
                               @"3009" : [UIImage imageNamed:@"card_3009"],
                               @"3100" : [UIImage imageNamed:@"card_3100"],
                               @"3101" : [UIImage imageNamed:@"card_3101"],
                               @"3102" : [UIImage imageNamed:@"card_3102"],
                               @"3103" : [UIImage imageNamed:@"card_3103"],
                               @"3200" : [UIImage imageNamed:@"card_3200"],
                               @"3201" : [UIImage imageNamed:@"card_3201"],
                               @"3202" : [UIImage imageNamed:@"card_3202"],

                               @"4001" : [UIImage imageNamed:@"card_4001.jpg"],
                               @"4002" : [UIImage imageNamed:@"card_4002.jpg"],
                               @"4003" : [UIImage imageNamed:@"card_4003.jpeg"],
                               @"4004" : [UIImage imageNamed:@"card_4004.jpg"],
                               @"4005" : [UIImage imageNamed:@"card_4005.jpg"],
                               @"4006" : [UIImage imageNamed:@"card_4006.jpg"],
                               @"4007" : [UIImage imageNamed:@"card_4007.jpg"],
                               @"4008" : [UIImage imageNamed:@"card_4008.jpg"],
                               @"4009" : [UIImage imageNamed:@"card_4009.jpg"],
                               @"4012" : [UIImage imageNamed:@"card_4012.jpg"],
                               @"4013" : [UIImage imageNamed:@"card_4013.jpeg"],
                               @"4014" : [UIImage imageNamed:@"card_4014.jpg"],
                               
                               @"hero_1" : [UIImage imageNamed:@"hero_1"],
                               @"hero_4" : [UIImage imageNamed:@"hero_4"],
                               @"hero_5" : [UIImage imageNamed:@"hero_5"],
                               @"hero_6" : [UIImage imageNamed:@"hero_6"],
                               };
    
    
    campaignHeroImages = @{
                           @"c_1_l_1" : [UIImage imageNamed:@"hero_c_1_l_1"],
                           @"c_2_l_1" : [UIImage imageNamed:@"hero_c_2_l_1"],
                           @"c_2_l_2" : [UIImage imageNamed:@"hero_c_2_l_2"],
                           @"c_2_l_3" : [UIImage imageNamed:@"hero_c_2_l_3"],
                           };
    
    
    backgroundMonsterOverlayImage = [UIImage imageNamed:@"HammerHeartHourglass.png"];
    
    selectHighlightImage = [UIImage imageNamed:@"card_glow_select"];
    heroSelectHighlightImage = [UIImage imageNamed:@"hero_glow_select"];
    targetHighlightImage = [UIImage imageNamed:@"card_glow_target"];
    heroTargetHighlightImage = [UIImage imageNamed:@"hero_glow_target"];
    
    placeHolderImage = [UIImage imageNamed:@"card_image_placeholder"];
    loadingImage =[UIImage imageNamed:@"card_image_empty"];
    heroPlaceHolderImage = [UIImage imageNamed:@"card_image_placeholder"];
    cardBackImage = [UIImage imageNamed:@"card_back_default"];
    
    abilityTextParagrahStyle = [[NSMutableParagraphStyle alloc] init];
    //[abilityTextParagrahStyle setLineSpacing:];
    [abilityTextParagrahStyle setMaximumLineHeight:CARD_NAME_SIZE-5];
    abilityTextAttributtes = @{NSParagraphStyleAttributeName : abilityTextParagrahStyle, NSFontAttributeName : [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE -5]};
    
    flavourTextAttributes = @{NSParagraphStyleAttributeName : abilityTextParagrahStyle, NSFontAttributeName : [UIFont fontWithName:cardFlavourTextFont size:CARD_NAME_SIZE -6]};
    
    standardCardImages = [[NSMutableDictionary alloc] init];
}

-(instancetype)initWithModel:(CardModel *)cardModel viewMode:(enum CardViewMode)cardViewMode viewState:(enum CardViewState)cardViewState
{
    return [self initWithModel:cardModel withImage:nil viewMode:cardViewMode viewState:cardViewState];
}

-(instancetype)initWithModel:(CardModel *)cardModel withImage:(UIImage*)cardImage viewMode:(enum CardViewMode)cardViewMode viewState:(enum CardViewState)cardViewState
{
    self = [self initWithModel:cardModel withImage:cardImage viewMode:cardViewMode];
    
    if (self)
    {
        _cardViewState = cardViewState;
        
        //do the changes without animation
        super.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_SCALE, CARD_VIEWER_SCALE);
        
        if (cardViewState == cardViewStateCardViewer)
            self.mask.alpha = 0.0;
        else if (cardViewState == cardViewStateCardViewerGray)
            self.mask.alpha = 0.8;
        else if (cardViewState == cardViewStateCardViewerTransparent)
        {
            self.mask.alpha = 0.4;
            self.alpha = 0.3;
        }
    }
    
    return self;
}

-(instancetype)initWithModel:(CardModel *)cardModel viewMode:(enum CardViewMode)cardViewMode
{
    return [self initWithModel:cardModel withImage:nil viewMode:cardViewMode];
}

-(instancetype)initWithModel:(CardModel *)cardModel withImage:(UIImage*)cardImage viewMode:(enum CardViewMode)cardViewMode
{
    self = [super init]; //does not actually make an image because highlight has to be behind it..
    
    if (self != nil)
    {
        //if ipad, make card size use CARD_GAMEPLAY_HEIGHT for metrics instead.
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            //brian March 26
            //if ipad && if gameplay, do scale differently
            if(cardViewMode ==cardViewModeIngame)
            {
                CARD_FULL_HEIGHT = CARD_GAMEPLAY_FULL_HEIGHT;
                CARD_FULL_WIDTH = CARD_GAMEPLAY_FULL_WIDTH;
                
                
                
                //brian--todoMarch27: investigate why this call resets things for the store as well as the gameplay.  Try to make it cause its effect in gameplay only.
                
                
                abilityTextParagrahStyle = [[NSMutableParagraphStyle alloc] init];
                //[abilityTextParagrahStyle setLineSpacing:];
                [abilityTextParagrahStyle setMaximumLineHeight:CARD_NAME_SIZE_GAMEPLAY-5];
                abilityTextAttributtes = @{NSParagraphStyleAttributeName : abilityTextParagrahStyle, NSFontAttributeName : [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE_GAMEPLAY -5]};
                
                flavourTextAttributes = @{NSParagraphStyleAttributeName : abilityTextParagrahStyle, NSFontAttributeName : [UIFont fontWithName:cardFlavourTextFont size:CARD_NAME_SIZE_GAMEPLAY -6]};
                
            }
            else
            {
                abilityTextParagrahStyle = [[NSMutableParagraphStyle alloc] init];
                //[abilityTextParagrahStyle setLineSpacing:];
                [abilityTextParagrahStyle setMaximumLineHeight:CARD_NAME_SIZE-5];
                abilityTextAttributtes = @{NSParagraphStyleAttributeName : abilityTextParagrahStyle, NSFontAttributeName : [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE -5]};
                
                flavourTextAttributes = @{NSParagraphStyleAttributeName : abilityTextParagrahStyle, NSFontAttributeName : [UIFont fontWithName:cardFlavourTextFont size:CARD_NAME_SIZE -6]};
            }
        }
        
        _cardModel = cardModel;
        cardModel.cardView = self; //point model's view back to itself
        
        self.cardViewMode = cardViewMode;
        
        NSArray*elementArray = backgroundImages[cardModel.element];
        
        self.abilityIcons = [NSMutableArray array];
        
        _transformView = [[UIView alloc] initWithFrame:self.bounds];
        //[_transformView setUserInteractionEnabled:YES];
        [self addSubview:_transformView];
        
        _backgroundImageView = [[UIImageView alloc] initWithImage:elementArray[0]];
        _backgroundImageView.bounds = CGRectMake(0, 0, CARD_FULL_WIDTH, CARD_FULL_HEIGHT);
        _backgroundImageView.center = CGPointMake(CARD_FULL_WIDTH/2, CARD_FULL_HEIGHT/2);
        [_transformView addSubview: _backgroundImageView];
        
        _frontViews = [[UIView alloc] initWithFrame:self.bounds];
        //[_frontViews setUserInteractionEnabled:YES];
        [_transformView addSubview:_frontViews];
        
        UIView*imageBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CARD_FULL_WIDTH - 16, (CARD_FULL_WIDTH-16) * CARD_IMAGE_RATIO)];
        [imageBackgroundView setBackgroundColor:[UIColor whiteColor]];
        imageBackgroundView.center = CGPointMake(CARD_FULL_WIDTH/2, 80);
        //[backgroundImageView addSubview:imageBackgroundView]; //for providing a view if card image has transparent areas, not using cardImage's background since it has problems when loading in store
        
        
        
        
        if (cardImage == nil && self.cardModel.reports < 5 && !self.cardModel.userReported)
        {
            if (cardModel.type == cardTypeSinglePlayer)
            {
                //special cases here
                if (cardModel.idNumber == PLAYER_FIRST_CARD_ID)
                {
                    if (PLAYER_FIRST_CARD_IMAGE!=nil)
                        self.cardImage = [[UIImageView alloc] initWithImage:PLAYER_FIRST_CARD_IMAGE];
                    else
                        self.cardImage = [[UIImageView alloc] initWithImage:placeHolderImage];
                }
                else
                {
                    UIImage* image = singlePlayerCardImages[[NSString stringWithFormat:@"%d", _cardModel.idNumber]];
                    if (image != nil)
                    {
                        self.cardImage = [[UIImageView alloc] initWithImage:image];
                    }
                    else
                        self.cardImage = [[UIImageView alloc] initWithImage:placeHolderImage];
                }
            }
            else if (cardModel.type == cardTypePlayer)
            {
                if (cardModel.idNumber != NO_ID)
                {
                    NSString *imageKey = [NSString stringWithFormat:@"hero_%d", cardModel.idNumber];
                    
                    UIImage *heroImage = singlePlayerCardImages[imageKey];
                    
                    
                    if (heroImage == nil)
                    {
                        self.cardImage = [[UIImageView alloc] initWithImage:heroPlaceHolderImage];
                    }
                    else
                    {
                        self.cardImage = [[UIImageView alloc] initWithImage:heroImage];
                    }
                }
                else
                    self.cardImage = [[UIImageView alloc] initWithImage:heroPlaceHolderImage];
                
                //self.cardImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"card_1000"]];
            }
            else
            {
                self.cardImage = [[UIImageView alloc]initWithImage:loadingImage];
            }
            
            
            float frameImageWidth = 330.0f/400.0f * CARD_FULL_WIDTH;
            
            float frameImageHeight = 270.0f/590.0f *CARD_FULL_HEIGHT;
            float frameImageX = 60.0f/400.0f/2 * CARD_FULL_WIDTH;
            float frameImageY = 170.0f/590.0f/2 * CARD_FULL_HEIGHT;

            self.cardImage.frame = CGRectMake(frameImageX, frameImageY, frameImageWidth, frameImageHeight);
           // self.cardImage.frame = CGRectMake(0, 0, CARD_FULL_WIDTH - 16, (CARD_FULL_WIDTH-16) * CARD_IMAGE_RATIO);
            //self.cardImage.center = CGPointMake(CARD_FULL_WIDTH/2, (CARD_FULL_WIDTH * CARD_IMAGE_RATIO)/2);
            self.cardImage.backgroundColor = [UIColor whiteColor];
            [_frontViews addSubview:self.cardImage];
            
            //special starting hand, these are stored on phone
            if (cardModel.type == cardTypeStandard && cardModel.idNumber < CARD_ID_START)
            {
                //same method as single player cards
                UIImage* image = singlePlayerCardImages[[NSString stringWithFormat:@"%d", _cardModel.idNumber]];
                if (image != nil)
                {
                    [self.cardImage setImage: image];
                }
                else
                    [self.cardImage setImage: placeHolderImage];
            }
            //TODO cardTypePlayer use a different algorithm
            else if (cardModel.type != cardTypeSinglePlayer && cardModel.type != cardTypePlayer)
            {
                _reloadAttempts = 0;
                _activityView = [[UIActivityIndicatorView alloc] initWithFrame:self.cardImage.bounds];
                [self.cardImage addSubview:_activityView];
                [_activityView startAnimating];
                /*if (cardViewMode != cardViewModeZoomedIngame ) {
                    [self performBlockInBackground:^(void){
                        [self loadImage];
                    }];
                }else{
                    [self.cardImage setImage:placeHolderImage];
                    [self.activityView stopAnimating];
                }*/
                if ([cardModel.cardPF[@"adminPhotoCheck"] intValue] == 1 || [self thisCardAreInMyDecks:[cardModel.cardPF objectForKey:@"idNumber"]] || cardViewMode == cardViewModeToValidate || [[cardModel.cardPF objectForKey:@"creator"] isEqualToString:userPF.objectId]) {
                    [self performBlockInBackground:^(void){
                        [self loadImage];
                    }];
                }else{
                    [self.cardImage setImage:placeHolderImage];
                    [self.activityView stopAnimating];
                }
                
                
            }
        }
        else
        {
            self.cardImage = [[UIImageView alloc]initWithImage:cardImage];
            
            self.cardImage.frame = CGRectMake(0, 0, CARD_FULL_WIDTH - 16, (CARD_FULL_WIDTH-16) * CARD_IMAGE_RATIO);
            self.cardImage.center = CGPointMake(CARD_FULL_WIDTH/2, 80);
            self.cardImage.backgroundColor = [UIColor whiteColor];
            [_frontViews addSubview:self.cardImage];
        }
        
        
        
        
        //brian Jul26
        //add subview for the frame of the image
        UIImageView *frameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PictureBorder2.png"]];
        //356W, 353H
        //approximately 10H, 5H
         //self.cardImage.frame = CGRectMake(0, 0, CARD_FULL_WIDTH - 16, (CARD_FULL_WIDTH-16) * CARD_IMAGE_RATIO);
        
        if (cardModel.type == cardTypePlayer)
        {
            frameImageView.alpha = 0;
            
        }
        float frameImageWidth = 376.0f/400.0f * CARD_FULL_WIDTH;
        
        float frameImageHeight = 353.0f/590.0f *CARD_FULL_HEIGHT;
        float frameImageX = 24.0f/400.0f/2 * CARD_FULL_WIDTH;
        float frameImageY = 55.0f/590.0f/2 * CARD_FULL_HEIGHT;
        frameImageView.frame = CGRectMake(frameImageX,frameImageY,frameImageWidth,frameImageHeight);
        
        [_frontViews addSubview:frameImageView];
        
        UIImageView *cardOverlay = [[UIImageView alloc] initWithImage:backgroundOverlayImages[cardModel.rarity]];
        cardOverlay.bounds = CGRectMake(0, 0, CARD_FULL_WIDTH, CARD_FULL_HEIGHT);
        cardOverlay.center = CGPointMake(CARD_FULL_WIDTH/2, CARD_FULL_HEIGHT/2);
        //brian july 26 remove cardOverlay
        
        //[_frontViews addSubview:cardOverlay];
        UIImageView *descriptionBGView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CardTitleBacking.png"]];
        //modify width and height relative to cardview ratio
        float descriptionWidthRatio = 200/400.0f;
        float descriptionHeightRatio = 99.0f/590.0f;
        
        if (cardModel.type == cardTypePlayer)
        {
            descriptionBGView.alpha = 0;
            
        }
        descriptionBGView.frame = CGRectMake(0,0,CARD_FULL_WIDTH,descriptionHeightRatio*CARD_FULL_HEIGHT);
        [_frontViews addSubview:descriptionBGView];
        
        //brianJuly27
        //add abilitydescriptionBGFrame
        //355 × 221 pixels
        float descriptionBGWidth = 365.0f/400.0f*CARD_FULL_WIDTH;
        float descriptionBGHeight = 216.0f/590.0f*CARD_FULL_HEIGHT;
        float descriptionBGX = 29.0f/2/400.0f*CARD_FULL_WIDTH;
        float descriptionBGY = 368.0f/590.0f*CARD_FULL_HEIGHT;
        
        
        UIImageView *descriptionBGFrame = [[UIImageView alloc] initWithFrame:CGRectMake(descriptionBGX,descriptionBGY,descriptionBGWidth,descriptionBGHeight)];
        if (cardModel.type == cardTypePlayer)
        {
            descriptionBGFrame.alpha = 0;
        }
        descriptionBGFrame.image = [UIImage imageNamed:@"CardDescription.png"];
        [_frontViews addSubview:descriptionBGFrame];
        
        
        
        self.userInteractionEnabled = true; //allows interaction
        
        self.frame = CGRectMake(0,0,CARD_FULL_WIDTH,CARD_FULL_HEIGHT);
        
        CGRect highlightBounds = CGRectMake(0,0,self.frame.size.width+28,self.frame.size.height+28);
        self.highlight = [[UIImageView alloc] initWithImage:selectHighlightImage];
        self.highlight.bounds = highlightBounds;
        self.highlight.center = CGPointMake(CARD_FULL_WIDTH/2, CARD_FULL_HEIGHT/2);
        self.highlight.alpha = 0.5;
        
        [_transformView insertSubview:self.highlight atIndex:0];
        
        //draws common card elements such as name and cost
        self.nameLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0,(CARD_FULL_WIDTH/4)*3,30)];
        self.nameLabel.center = CGPointMake(CARD_FULL_WIDTH/2 + CARD_FULL_WIDTH/10 + 2, (descriptionHeightRatio*CARD_FULL_HEIGHT)/2 );
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE];
        [self.nameLabel setMinimumScaleFactor:6.f/CARD_NAME_SIZE];
        self.nameLabel.strokeOn = YES;
        self.nameLabel.strokeThickness = 2;
        
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        
        [_frontViews addSubview: nameLabel];
        
        self.costLabel = [[StrokedLabel alloc] initWithFrame:self.bounds];
        self.costLabel.center = CGPointMake(CARD_FULL_WIDTH/8, (descriptionHeightRatio*CARD_FULL_HEIGHT)/2);
        self.costLabel.textAlignment = NSTextAlignmentCenter;
        self.costLabel.textColor = [UIColor whiteColor];
        self.costLabel.backgroundColor = [UIColor clearColor];
        self.costLabel.font = [UIFont fontWithName:cardMainFontBlack size:CARD_NAME_SIZE +9];
        self.costLabel.strokeOn = YES;
        self.costLabel.strokeColour = [UIColor blackColor];
        self.costLabel.strokeThickness = 3;
        
        [_frontViews addSubview: costLabel];
        
        self.reportedLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0,96,60)];
        self.reportedLabel.center = CGPointMake(CARD_FULL_WIDTH/2, 75);
        self.reportedLabel.textAlignment = NSTextAlignmentCenter;
        self.reportedLabel.textColor = [UIColor redColor];
        self.reportedLabel.backgroundColor = [UIColor clearColor];
        self.reportedLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE + 7];
        [self.reportedLabel setMinimumScaleFactor:6.f/CARD_NAME_SIZE];
        self.reportedLabel.adjustsFontSizeToFitWidth = YES;
        
        [_frontViews addSubview: reportedLabel];
        
        //NSLog(@"DescriptionBGHeight = %f",descriptionBGHeight);
        //NSLog(@"DescriptionBGY = %f",descriptionBGY);
        
        self.elementLabel = [[StrokedLabel alloc] initWithFrame:self.bounds];
        self.elementLabel.center = CGPointMake(CARD_FULL_WIDTH/2, descriptionBGY+ (descriptionBGHeight/10));
        self.elementLabel.textAlignment = NSTextAlignmentCenter;
        self.elementLabel.textColor = [UIColor whiteColor];
        self.elementLabel.backgroundColor = [UIColor clearColor];
        self.elementLabel.strokeOn = YES;
        self.elementLabel.strokeColour = [UIColor blackColor];
        self.elementLabel.strokeThickness = 2.5;
        //brian mar27 make this conditional on ipad gameplay or not ipad gameplay
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && cardViewMode == cardViewModeIngame)
        {
              self.elementLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE_GAMEPLAY -5];
        }
        else
        {
             self.elementLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE -5];
        }
        
      
        self.elementLabel.text = [CardModel elementToString:cardModel.element];
        //NOTE added above other stuff
        
        //original value -10 for width
        
        //brianmar27
        //need to add additional margins for the width for iPad values.
        //should calculate left margin as a ratio of the cardWidth (can use description width here for value
        //default xMargin, 12/baseWidth (129, 83)
        
        float xMarginRatio = 12.0f/129.0f;
        float xRightMarginRatio = 15.0f/129.0f;
        
        self.baseAbilityLabel = [[UITextView alloc] initWithFrame:CGRectMake(xMarginRatio*descriptionBGWidth, descriptionBGY+ (descriptionBGHeight/6), descriptionBGWidth - xRightMarginRatio*descriptionBGWidth, (descriptionBGHeight/8)*5)]; //NOTE changing this is useless, do it down below
        [self.baseAbilityLabel  setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        self.baseAbilityLabel.textColor = [UIColor whiteColor];
        self.baseAbilityLabel.backgroundColor = [UIColor clearColor];
        self.baseAbilityLabel.editable = NO;
        self.baseAbilityLabel.selectable = NO;
        
        [self.baseAbilityLabel setTextAlignment:NSTextAlignmentLeft]; //note that this is set again in the update function
        
        //[self.baseAbilityLabel sizeToFit];
        [self addSubview: baseAbilityLabel];
        
        //draws specific card elements for monster card
        if ([cardModel isKindOfClass:[MonsterCardModel class]])
        {
            MonsterCardModel*monsterCard = (MonsterCardModel*)cardModel;
            
            //player hero's card only has life (TODO maybe damage or spells in future)
            if (cardModel.type == cardTypePlayer)
            {
                self.nameLabel.center = CGPointMake(PLAYER_HERO_WIDTH/2, 10);
                
                self.lifeLabel = [[StrokedLabel alloc] initWithFrame:self.bounds];
                self.lifeLabel.center = CGPointMake(PLAYER_HERO_WIDTH/2, PLAYER_HERO_HEIGHT - 10);
                self.lifeLabel.textAlignment = NSTextAlignmentCenter;
                self.lifeLabel.textColor = [UIColor whiteColor];
                self.lifeLabel.backgroundColor = [UIColor clearColor];
                self.lifeLabel.strokeOn = YES;
                self.lifeLabel.strokeColour = [UIColor blackColor];
                self.lifeLabel.strokeThickness = 2.5;
                self.lifeLabel.font = [UIFont fontWithName:cardMainFont size:20];
                
                self.lifeLabel.text = [NSString stringWithFormat:@"%d", monsterCard.life];
                
                [_frontViews addSubview: lifeLabel];
                
                //change the background and size
                //change the main image size
                self.cardImage.bounds = CGRectMake(5, 20, PLAYER_HERO_WIDTH - 20, (PLAYER_HERO_WIDTH-20) * CARD_IMAGE_RATIO);
                self.cardImage.center = CGPointMake(PLAYER_HERO_WIDTH/2, self.cardImage.bounds.size.height/2 + self.cardImage.bounds.origin.y);
                
                [self.costLabel removeFromSuperview];
                
                self.frame = CGRectMake(0,0,PLAYER_HERO_WIDTH,PLAYER_HERO_WIDTH);
                _backgroundImageView.frame = CGRectMake(0,0,PLAYER_HERO_WIDTH,PLAYER_HERO_WIDTH);
                
                self.highlight.image = heroSelectHighlightImage;
                //change the highlight size
                CGRect highlightBounds = CGRectMake(0,0,self.frame.size.width+15,self.frame.size.height+15);
                self.highlight.bounds = highlightBounds;
                self.highlight.center = CGPointMake(PLAYER_HERO_WIDTH/2, PLAYER_HERO_HEIGHT/2);
                
                //removing this for now
                [cardOverlay removeFromSuperview];
                [elementLabel removeFromSuperview];
            }
            //other cards
            else
            {
                
                //brian july 26
                //442 width
                //274 height
                //approximately -20 x, 100y
                //monster overlay
                //total card dimensions (400 w, 590 height)
                float monsterOverlayWidth = 442.0f/400.0f * CARD_FULL_WIDTH;
                float monsterOverlayHeight = 274.0f/590.0f * CARD_FULL_HEIGHT;
                float monsterOverlayX = -28.0f/400.0f * CARD_FULL_WIDTH;
                float monsterOverlayY = 115.0f/590.0f * CARD_FULL_HEIGHT;
                UIImageView *monsterOverlay = [[UIImageView alloc] initWithImage:backgroundMonsterOverlayImage];
                monsterOverlay.frame = CGRectMake(monsterOverlayX,monsterOverlayY,monsterOverlayWidth,monsterOverlayHeight);
                
                [_frontViews addSubview:monsterOverlay];
                
                float attackLabelX = 57.0f/400.0f*CARD_FULL_WIDTH;
                float attackLabelY = 330.0f/590.0f*CARD_FULL_HEIGHT;
                
                //original size 18
                self.attackLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0,CARD_FULL_WIDTH/2,30)];
                self.attackLabel.center = CGPointMake(attackLabelX, attackLabelY);
                self.attackLabel.textAlignment = NSTextAlignmentCenter;
                self.attackLabel.textColor = [UIColor whiteColor];
                self.attackLabel.backgroundColor = [UIColor clearColor];
                self.attackLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE +9]; //originally -3
                self.attackLabel.strokeOn = YES;
                self.attackLabel.strokeColour = [UIColor blackColor];
                self.attackLabel.strokeThickness = 2.5;
                
                self.attackLabel.text = [NSString stringWithFormat:@"%d", monsterCard.damage];
                
                [_frontViews addSubview: attackLabel];
                
                float lifeLabelX = 355.0f/400.0f*CARD_FULL_WIDTH;
                float lifeLabelY = 330.0f/590.0f*CARD_FULL_HEIGHT;
                self.lifeLabel = [[StrokedLabel alloc] initWithFrame:CGRectMake(0,0,CARD_FULL_WIDTH/2,30)];
                self.lifeLabel.center = CGPointMake(lifeLabelX, lifeLabelY);
                self.lifeLabel.textAlignment = NSTextAlignmentCenter;
                self.lifeLabel.textColor = [UIColor whiteColor];
                self.lifeLabel.backgroundColor = [UIColor clearColor];
                self.lifeLabel.strokeOn = YES;
                self.lifeLabel.strokeColour = [UIColor blackColor];
                self.lifeLabel.strokeThickness = 2.5;
                self.lifeLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE + 9]; //originally -3
                self.lifeLabel.text = [NSString stringWithFormat:@"%d", monsterCard.life];

                [_frontViews addSubview: lifeLabel];
                
                float cooldownLabelX = 204.0f/400.0f*CARD_FULL_WIDTH;
                float cooldownLabelY = 327.0f/590.0f*CARD_FULL_HEIGHT;
                self.cooldownLabel = [[StrokedLabel alloc] initWithFrame:self.bounds];
                self.cooldownLabel.center = CGPointMake(cooldownLabelX, cooldownLabelY);
                self.cooldownLabel.textAlignment = NSTextAlignmentCenter;
                self.cooldownLabel.textColor = [UIColor whiteColor];
                self.cooldownLabel.backgroundColor = [UIColor clearColor];
                self.cooldownLabel.strokeOn = YES;
                self.cooldownLabel.strokeColour = [UIColor blackColor];
                self.cooldownLabel.strokeThickness = 2.5;
                self.cooldownLabel.font = [UIFont fontWithName:cardMainFont size:CARD_NAME_SIZE + 7];
                self.cooldownLabel.text = [NSString stringWithFormat:@"%d", monsterCard.cooldown];
                
                [_frontViews addSubview: cooldownLabel];
                
                [_frontViews addSubview: elementLabel];
            }
        }
        //draws specific card elements for spell card
        else if ([cardModel isKindOfClass:[SpellCardModel class]])
        {
            //element is a little higher
            //self.elementLabel.center = CGPointMake(CARD_FULL_WIDTH/2, 144);
            [_frontViews addSubview: elementLabel];
        }
        
        self.damagePopup = [[StrokedLabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
        self.damagePopup.center = self.center;
        self.damagePopup.textAlignment = NSTextAlignmentCenter;
        self.damagePopup.textColor = [UIColor redColor];
        self.damagePopup.backgroundColor = [UIColor clearColor];
        self.damagePopup.font = [UIFont fontWithName:cardMainFontBlack size:CARD_NAME_SIZE + 13];
        //self.damagePopup.strokeOn = YES;
        //self.damagePopup.strokeColour = [UIColor blackColor];
        //self.damagePopup.strokeThickness = 2.5;
        self.damagePopup.text = @"";
        self.damagePopup.alpha = 0;
        [self addSubview:self.damagePopup];
        
        //adds correct text to all of the labels
        [self updateView];
        
        self.mask = [[UIView alloc] initWithFrame:self.bounds];
        [self.mask setUserInteractionEnabled:NO];
        [self.mask setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.7]];
        self.mask.alpha = 0;
        [self addSubview:self.mask];
        self.frontFacing = NO; //default to backfacing
        
        self.cardHighlightType = cardHighlightNone;
        self.cardViewState = cardViewStateNone;
    }
    
    
   
    
    return self;
}

-(BOOL)frontFacing
{
    return _frontFacing;
}

-(void)setFrontFacing:(BOOL)frontFacing
{
    _frontFacing = frontFacing;
    
    if (YES) //TODO debugging, shows all cards
    //if (frontFacing)
    {
        if (_cardModel.element < backgroundImages.count)
        {
            NSArray*elementArray = backgroundImages[_cardModel.element];
            //brianedit Jul9
            _backgroundImageView.image = elementArray[0]; //TODO change if has rarity difference per element
        }
        else
            _backgroundImageView.image = backgroundImages[elementNeutral][0];
        
        _frontViews.alpha = 1;
        self.baseAbilityLabel.alpha = 1;
    }
    else
    {
        _backgroundImageView.image = cardBackImage;
        _frontViews.alpha = 0;
        self.baseAbilityLabel.alpha = 0;
    }
    
    [self updateView];
}

-(void)flipCard
{
    CGAffineTransform originalTransform = _transformView.transform;
    self.baseAbilityLabel.alpha = 0;
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         _transformView.transform = CGAffineTransformScale(originalTransform, 0.1, 1);
                     }
                     completion:^(BOOL finished) {
                         self.frontFacing = !_frontFacing;
                         self.baseAbilityLabel.alpha = 0;
                         [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              _transformView.transform = originalTransform;
                                          }
                                          completion:^(BOOL finished) {
                                              if (self.frontFacing)
                                                  self.baseAbilityLabel.alpha = 1;
                                              else
                                                  self.baseAbilityLabel.alpha = 0;
                                          }];
                     }];
}

-(void)updateView{
    //DEBUG 2
    if (YES)
    //if (_frontFacing)
    {
        self.nameLabel.text = self.cardModel.name;
        self.costLabel.text = [NSString stringWithFormat:@"%d", self.cardModel.cost];
        
        if (self.cardModel.reports > 4 || self.cardModel.userReported) {
            self.reportedLabel.text = @"REPORTED";
        }
        
        if ([self.cardModel isKindOfClass:[MonsterCardModel class]])
        {
            MonsterCardModel* monsterCard = (MonsterCardModel*) self.cardModel;
            
            //update damage label
            UIColor *newDamageColour;
            if (monsterCard.damage != monsterCard.baseDamage)
                newDamageColour = COLOUR_STAT_MODED;
            else
                newDamageColour = [UIColor whiteColor];
            
            NSString *newDamageString = [NSString stringWithFormat:@"%d", monsterCard.damage];
            
            if ((self.damageViewNeedsUpdate || ![newDamageString isEqualToString:self.attackLabel.text]) && self.cardViewMode == cardViewModeIngame)
            {
                self.damageViewNeedsUpdate = NO;
                [CardView animateUILabelChange:self.attackLabel newColour:newDamageColour forCardView:self];
            }
            else
            {
                self.attackLabel.text = newDamageString;
                self.attackLabel.textColor = newDamageColour;
            }
            
            //update life label
            UIColor *newLifeColour;
            if (monsterCard.life > monsterCard.maximumLife || monsterCard.maximumLife > [monsterCard baseMaxLife])
                newLifeColour = COLOUR_STAT_MODED;
            else
                newLifeColour = [UIColor whiteColor];
            
            NSString *newLifeString = [NSString stringWithFormat:@"%d", monsterCard.life];
            
            if (self.lifeViewNeedsUpdate && self.cardViewMode == cardViewModeIngame)
            {
                self.lifeViewNeedsUpdate = NO;
                [CardView animateUILabelChange:self.lifeLabel newColour:newLifeColour forCardView:self];
            }
            else
            {
                self.lifeLabel.text = newLifeString;
                self.lifeLabel.textColor = newLifeColour;
            }
            
            //update cooldown label
            UIColor *newCooldownColour;
            if (monsterCard.cooldown == 0)
                newCooldownColour = [UIColor greenColor]; //green when at 0 cooldown
            else if (monsterCard.cooldown > monsterCard.maximumCooldown || monsterCard.cooldown > monsterCard.baseMaxCooldown || monsterCard.maximumCooldown > monsterCard.baseMaxCooldown)
                newCooldownColour = COLOUR_STAT_MODED;
            else
                newCooldownColour = [UIColor whiteColor];
            
            NSString* newCooldownString = [NSString stringWithFormat:@"%d", monsterCard.cooldown];
            
            if (self.cooldownViewNeedsUpdate && self.cardViewMode == cardViewModeIngame)
            {
                self.cooldownViewNeedsUpdate = NO;
                [CardView animateUILabelChange:self.cooldownLabel  newColour:newCooldownColour forCardView:self];
            }
            else
            {
                self.cooldownLabel.text = newCooldownString;
                self.cooldownLabel.textColor = newCooldownColour;
            }
            
            if (self.cardViewMode == cardViewModeIngame || self.cardViewMode == cardViewModeZoomedIngame)
            {
                NSMutableArray *currentAbilityIconImages = [NSMutableArray array];
                
                for (Ability *ability in monsterCard.abilities)
                {
                    if (ability.expired)
                        continue;
                    
                    UIImage *iconImage;
                    if (ability.castType == castOnMove || ability.castType == castOnEndOfTurn)
                        iconImage = abilityIconImages[abilityIconCastOnMove];
                    else if (ability.castType == castOnDeath)
                        iconImage = abilityIconImages[abilityIconCastOnDeath];
                    else if (ability.castType == castOnHit)
                        iconImage = abilityIconImages[abilityIconCastOnHit];
                    else if (ability.castType == castOnDamaged)
                        iconImage = abilityIconImages[abilityIconCastOnDamaged];
                    else if (ability.targetType == targetSelf)
                    {
                        if (ability.abilityType == abilityTaunt)
                            iconImage = abilityIconImages[abilityIconTaunt];
                        else if (ability.abilityType == abilityAssassin)
                            iconImage = abilityIconImages[abilityIconAssassin];
                        else if (ability.abilityType == abilityPierce)
                            iconImage = abilityIconImages[abilityIconPierce];
                        else if (ability.abilityType == abilityRemoveAbility)
                            iconImage = abilityIconImages[abilityIconRemoveAbility];
                    }
                    
                    if (iconImage != nil && ![currentAbilityIconImages containsObject:iconImage])
                        [currentAbilityIconImages addObject:iconImage];
                }
                
                NSMutableArray*abilityIcons = [NSMutableArray array];
                
                //first step, remove all icons that no longer exists
                //loop backwards to prevent con cur mod
                for (int i = self.abilityIcons.count-1; i >= 0 ; i--)
                {
                    UIImageView*iconImageView = self.abilityIcons[i];
                    
                    //remove if doesn't exist
                    if (![currentAbilityIconImages containsObject:iconImageView.image])
                    {
                        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                                         animations:^{
                                             iconImageView.alpha = 0;
                                         }
                                         completion:^(BOOL finished){
                                             [iconImageView removeFromSuperview];
                                         }];
                        [self.abilityIcons removeObjectAtIndex:i];
                    }
                }
                
                
                float iconCenterIndex = currentAbilityIconImages.count/2; //for positioning the cards
                if (currentAbilityIconImages.count % 2 == 0)
                    iconCenterIndex -= 0.5;
                
                int index = 0;
                
                //go through every new iconImage
                for (UIImage *iconImage in currentAbilityIconImages)
                {
                    UIImageView*icon;
                    //go through existing images and update them
                    for (UIImageView*iconImageView in self.abilityIcons)
                    {
                        //already exist, move it here
                        if (iconImageView.image == iconImage)
                        {
                            icon = iconImageView;
                            break;
                        }
                    }
                    
                    int x = (index-iconCenterIndex) * 15 + ((currentAbilityIconImages.count+1)%2 * 3) + self.bounds.size.width/2;
                    
                    //this is a new icon, create it
                    if (icon==nil)
                    {
                        icon = [[UIImageView alloc] initWithImage:iconImage];
                        icon.frame = CGRectMake(0, 0, 20, 20);
                        icon.center = CGPointMake(x, self.bounds.size.height - 4);
                        icon.alpha = 0;
                        
                        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                                         animations:^{
                                             icon.alpha = 1;
                                         }
                                         completion:nil];
                        
                        [_frontViews addSubview:icon];
                    }
                    else
                    {
                        //already exist, simply animate to new position
                        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                                         animations:^{
                                             icon.center = CGPointMake(x, self.bounds.size.height - 4);
                                         }
                                         completion:nil];
                    }
                    
                    [abilityIcons addObject:icon]; //add to new array
                    index++;
                }
                
                //point to new array
                self.abilityIcons = abilityIcons;
            }
            
            //TODO: maybe put a special view to show both current and max values
            
        }
        else if ([self.cardModel isKindOfClass:[SpellCardModel class]])
        {
            SpellCardModel* spellCard = (SpellCardModel*) self.cardModel;
            
            //TODO
        }
        
        //text area for ability & flavour text
        NSString *abilityDescription = [Ability getDescriptionForBaseAbilities:self.cardModel];
        
        //add a new line if has text
        if (abilityDescription.length > 0)
        {
            abilityDescription = [NSString stringWithFormat:@"%@", abilityDescription];
        }
        NSAttributedString *abilityDescriptionAS = [[NSAttributedString alloc] initWithString:abilityDescription
                                                                                   attributes:abilityTextAttributtes];
        
        
        
        NSString*flavourText;
        
        //new line if has ability
        if (abilityDescription.length > 0)
            flavourText = [NSString stringWithFormat:@"\n\n%@", _cardModel.flavourText];
        else
            flavourText = [NSString stringWithFormat:@"%@", _cardModel.flavourText];
        
        NSAttributedString *flavourStringAS = [[NSAttributedString alloc] initWithString:flavourText
                                                                                   attributes:flavourTextAttributes];
        
        NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] initWithAttributedString:abilityDescriptionAS] ;
        [finalString appendAttributedString:flavourStringAS];
       
        
        self.baseAbilityLabel.attributedText = finalString;
        self.baseAbilityLabel.textColor = [UIColor whiteColor];
        self.baseAbilityLabel.textAlignment = NSTextAlignmentLeft;
    }
    //back facing
    else
    {
        
    }
    //self.baseAbilityLabel.frame = CGRectMake(10, 157, CARD_FULL_WIDTH - 20, 140);
    //[self.baseAbilityLabel sizeToFit];
}

/** Overwritten center getter. Returns the position based on the card's state */
-(CGPoint)center
{
    /*
     if (self.cardViewState == cardViewStateHighlighted)
     {
     CGPoint newPoint = super.center;
     newPoint.y -= 30;
     return newPoint;
     }
     else if (self.cardViewState == cardViewStateSelected)
     {
     CGPoint newPoint = super.center;
     newPoint.y -= 50;
     return newPoint;
     }*/
    return super.center;
}

/** overwritten center */
-(void)setCenter: (CGPoint)center
{
    self.originalPosition = center;
    super.center = center;
}

-(enum CardViewState) cardViewState
{
    return _cardViewState;
}

-(void)setCardViewState:(enum CardViewState)cardViewState
{
    if (cardViewState == cardViewStateHighlighted)
    {
        //set super position higher
        CGPoint newPoint = self.originalPosition;
        newPoint.y -= 20;
        
        super.center = newPoint;
    }
    else if (cardViewState == cardViewStateSelected)
    {
        //set super position higher
        CGPoint newPoint = self.originalPosition;
        newPoint.y -= 50;
        
        super.center = newPoint;
    }
    else if (cardViewState == cardViewStateDragging)
    {
        super.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_DRAGGING_SCALE, CARD_DRAGGING_SCALE);
        //self.transform = CGAffineTransformScale(CGAffineTransformIdentity, DRAGGING_SCALE, DRAGGING_SCALE);
        
        //set super position higher
        super.center = self.originalPosition;
    }
    else if (cardViewState == cardViewStateMaximize)
    {
        super.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    }
    else if (cardViewState == cardViewStateCardViewer)
    {
        super.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_SCALE, CARD_VIEWER_SCALE);
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.mask.alpha = 0.0;
                             self.alpha = 1;
                         }
                         completion:nil];
    }
    else if (cardViewState == cardViewStateCardViewerGray)
    {
        //TODO eventually should change this to an image
        super.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_SCALE, CARD_VIEWER_SCALE);
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.mask.alpha = 0.8;
                             self.alpha = 1;
                         }
                         completion:nil];
    }
    else if (cardViewState == cardViewStateCardViewerTransparent)
    {
        super.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_VIEWER_SCALE, CARD_VIEWER_SCALE);
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.mask.alpha = 0.4;
                             self.alpha = 0.3;
                         }
                         completion:nil];
    }
    else{
        if (self.cardModel.type != cardTypePlayer)
        {
            super.transform = CGAffineTransformScale(CGAffineTransformIdentity, CARD_DEFAULT_SCALE, CARD_DEFAULT_SCALE);
        }
        
        //revert super's position
        super.center = self.originalPosition;
    }
    
    _cardViewState = cardViewState;
}

-(void)setPopupDamage:(int)damage
{
    //assuming this will always be animated in this scale
    
    //new damage
    if ([self.damagePopup.text isEqualToString:@""])
    {
        self.damagePopup.text = [NSString stringWithFormat:@"%d", damage];
    }
    //recently been damaged, update the label
    else
    {
        int totalDamage = [self.damagePopup.text intValue] + damage;
        self.damagePopup.text = [NSString stringWithFormat:@"%d", totalDamage];
        return;
    }
    
    self.damagePopup.alpha = 1;
    self.damagePopup.transform = CGAffineTransformMakeScale(0, 0);
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (self.cardModel.type != cardTypePlayer)
                             self.damagePopup.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.f/CARD_DEFAULT_SCALE, 1.f/CARD_DEFAULT_SCALE);
                         else
                             self.damagePopup.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1,1);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5 delay:1.3 options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.damagePopup.alpha = 0;
                                          }
                                          completion:^(BOOL finished){
                                              self.damagePopup.text = @"";
                                          }];
                     }];
    
    
    
}

-(enum CardHighlightType) cardHighlightType
{
    return _cardHighlightType;
}

-(void)setCardHighlightType:(enum CardHighlightType)cardHighlightType
{
    if(cardHighlightType == cardHighlightNone)
    {
        self.highlight.alpha = 0;
        //[self stopCardHighlightAnimation:self.highlight];
        [self.highlight.layer removeAllAnimations];
    }
    else if (cardHighlightType == cardHighlightSelect)
    {
        if (self.cardModel.type == cardTypePlayer)
            self.highlight.image = heroSelectHighlightImage;
        else
            self.highlight.image = selectHighlightImage;
        
        self.highlight.alpha = 0.5;
        [self animateCardHighlightBrighten:self.highlight];
    }
    else if (cardHighlightType == cardHighlightTarget)
    {
        if (self.cardModel.type == cardTypePlayer)
            self.highlight.image = heroTargetHighlightImage;
        else
            self.highlight.image = targetHighlightImage;
        
        self.highlight.alpha = 0.5;
        [self animateCardHighlightBrighten:self.highlight];
    }
    
    _cardHighlightType = cardHighlightType;
}

-(void)resetTransformations
{
    self.cardViewState = self.cardViewState; //this causes the setCardViewState to be called again
}

-(void)castedAbility:(Ability*)ability
{
    //TODO could add a cast on summon, would be nice
    if (ability.castType == castOnDeath)
    {
        for (UIImageView*abilityIcon in self.abilityIcons)
        {
            if (abilityIcon.image == abilityIconImages[abilityIconCastOnDeath])
            {
                [CardView animateIconCast:abilityIcon];
                break;
            }
        }
    }
    else if (ability.castType == castOnHit)
    {
        for (UIImageView*abilityIcon in self.abilityIcons)
        {
            if (abilityIcon.image == abilityIconImages[abilityIconCastOnHit])
            {
                [CardView animateIconCast:abilityIcon];
                break;
            }
        }
    }
    else if (ability.castType == castOnDamaged)
    {
        for (UIImageView*abilityIcon in self.abilityIcons)
        {
            if (abilityIcon.image == abilityIconImages[abilityIconCastOnDamaged])
            {
                [CardView animateIconCast:abilityIcon];
                break;
            }
        }
    }
    else if (ability.castType == castOnMove || ability.castType == castOnEndOfTurn)
    {
        for (UIImageView*abilityIcon in self.abilityIcons)
        {
            if (abilityIcon.image == abilityIconImages[abilityIconCastOnMove])
            {
                [CardView animateIconCast:abilityIcon];
                break;
            }
        }
    }
}

-(void)loadImage
{
    //fetch an image and load it
    BOOL errorLoading = NO;
    UIImage*image = [CardView getImageForCard:self.cardModel errorLoading:&errorLoading];
    
    if (!errorLoading)
    {
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            [self.cardImage setImage:image];
            [_activityView stopAnimating];
            [_activityView removeFromSuperview];
            _activityView = nil;
        });
    }
    else //TODO!!!!!! assuming that when the cardView is destroyed, this block will also be
    {
        if (_reloadAttempts++ < 15) //stop retrying after some time
        {
            //try again
            [self performBlock:^{
                [self loadImage];
            } afterDelay:10];
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                [_activityView stopAnimating];
                [_activityView removeFromSuperview];
                _activityView = nil;
                [self.cardImage setImage:placeHolderImage];
                NSLog(@"MAX RETRY REACHED");
            });
        }
    }
}

+(UIImage*)getImageForCard:(CardModel*)card errorLoading:(BOOL*)errorLoading
{
    if (card.type == cardTypeStandard /*&& card.adminPhotoCheck*/)
    {
        if (card.idNumber == NO_ID)
            return placeHolderImage;
        
        UIImage* image = standardCardImages[@(card.idNumber)];
        
        //already loaded
        if (image!=nil)
        {
            //NSLog(@"%d image in database", card.idNumber);
            return image;
        }
        //load from parse
        else
        {
            //NSLog(@"%d loading from parse", card.idNumber);
            PFObject *cardPF;
            if (card.cardPF == nil)
            {
                PFQuery *cardQuery = [PFQuery queryWithClassName:@"Card"];
                cardQuery.limit = 1;
                [cardQuery whereKey:@"idNumber" equalTo:@(card.idNumber)];
                //[cardQuery whereKey:@"adminPhotoCheck" equalTo:@(YES)];
                NSError*error;
                NSArray*cardArray = [cardQuery findObjects:&error];
                if (cardArray.count == 0 || error)
                {
                    *errorLoading = YES;
                    return placeHolderImage;
                }
                else
                    cardPF = cardArray[0];
            }
            else
                cardPF = card.cardPF;
            
            NSError*error;
            [cardPF[@"image"] fetchIfNeeded:&error];
            if (error)
                return placeHolderImage;
            
            PFObject *imagePF = cardPF[@"image"];
            
            if (imagePF != nil)
            {
                PFFile *file = imagePF[@"image"];
                if (file != nil)
                {
                   
                    NSData *data = [file getData];
                    if (data != nil)
                    {
                        UIImage *image = [UIImage imageWithData:data];
                        if (image != nil)
                        {
                            //TODO EXC_BAD_ACCESS on this line (rather rare)
                            [standardCardImages setObject:image  forKey:@(card.idNumber)];
                            return image;
                        }
                        else{
                            NSLog(@"%d image nil", card.idNumber);
                        }
                    }
                    else{
                        NSLog(@"%d data nil", card.idNumber);
                    }
                }
                else
                    *errorLoading = YES;
            }
            else
            {
                //NSLog(@"%d imagePF nil", card.idNumber);
            }
            
        }
    }
    else if (card.type == cardTypePlayer)
    {
        return heroPlaceHolderImage;
    }
    else
    {
        //TODO
    }
    
    return placeHolderImage;
}


-(void)animateCardHighlightBrighten: (UIImageView*)highlight
{
    [UIView animateWithDuration:3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{highlight.alpha = 1;}
                     completion:^(BOOL finished){
                         if (!finished)return; //stops the animation on removal
                         [self animateCardHighlightDim:highlight];
                     }];
}

-(void)animateCardHighlightDim: (UIImageView*)highlight
{
    [UIView animateWithDuration:3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{highlight.alpha = 0.5;}
                     completion:^(BOOL finished){
                         if (!finished)return; //stops the animation on removal
                         [self animateCardHighlightBrighten:highlight];
                     }];
}

+(void)animateUILabelChange: (UILabel*)label newColour:(UIColor*)newColour forCardView:(CardView*)cardView
{
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         label.transform = CGAffineTransformMakeScale(2, 2);
                     }
                     completion:^(BOOL finished){
                         NSString*newString;
                         
                         if (label == cardView.attackLabel)
                         {
                             MonsterCardModel*monsterCard = (MonsterCardModel*)cardView.cardModel;
                             newString = [NSString stringWithFormat:@"%d", monsterCard.damage];
                         }
                         else if (label == cardView.lifeLabel)
                         {
                             MonsterCardModel*monsterCard = (MonsterCardModel*)cardView.cardModel;
                             newString = [NSString stringWithFormat:@"%d", monsterCard.life];
                         }
                         else if (label == cardView.cooldownLabel)
                         {
                             MonsterCardModel*monsterCard = (MonsterCardModel*)cardView.cardModel;
                             newString = [NSString stringWithFormat:@"%d", monsterCard.cooldown];
                         }
                         else if (label == cardView.costLabel)
                         {
                             newString = [NSString stringWithFormat:@"%d", cardView.cardModel.cost];
                         }
                         
                         if (newString != nil)
                             label.text = newString;
                         label.textColor = newColour;
                         [UIView animateWithDuration:0.25 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              label.transform = CGAffineTransformMakeScale(1, 1);
                                          }
                                          completion:nil];
                     }];
}

+(void)animateIconCast: (UIView*)view
{
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(4, 4);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.25 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              view.transform = CGAffineTransformMakeScale(1, 1);
                                          }
                                          completion:nil];
                     }];
}

- (void)performBlockInBackground:(void (^)())block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        block();
    });
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


-(UIColor*)getRarityColor
{
    if (_cardModel.rarity == cardRarityCommon)
        return COLOUR_COMMON;
    else if (_cardModel.rarity == cardRarityUncommon)
        return COLOUR_UNCOMMON;
    else if (_cardModel.rarity == cardRarityRare)
        return COLOUR_RARE;
    else if (_cardModel.rarity == cardRarityExceptional)
        return COLOUR_EXCEPTIONAL;
    else if (_cardModel.rarity == cardRarityLegendary)
        return COLOUR_LEGENDARY;
    
    return COLOUR_COMMON;
}

/*
 -(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
 {
 [super touchesBegan:touches withEvent:event];
 [self.baseAbilityLabel touchesBegan:touches withEvent:event];
 }
 
 -(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
 {
 [super touchesCancelled:touches withEvent:event];
 [self.baseAbilityLabel touchesCancelled:touches withEvent:event];
 }
 
 -(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
 {
 [super touchesEnded:touches withEvent:event];
 [self.baseAbilityLabel touchesEnded:touches withEvent:event];
 }
 
 -(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
 {
 [super touchesMoved:touches withEvent:event];
 [self.baseAbilityLabel touchesMoved:touches withEvent:event];
 }
 */

- (BOOL)thisCardAreInMyDecks:(NSNumber *)cardID{
    
    if ([cardID isEqual:[NSNumber numberWithInt:1419]]) {
        NSLog(@"1419");
    }
    
    for (PFObject *deck in [userPF objectForKey:@"decks"]) {
        NSArray *cards = [deck objectForKey:@"cards"];
        if ([cards containsObject:cardID]) {
            return true;
        }
    }
    
    
    return false;
}

@end
