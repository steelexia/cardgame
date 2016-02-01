//
//  DHPopupController.m
//  DHPopupController
//
//  Created by Carson Perrotti on 2014-09-28.
//  Copyright (c) 2014 Carson Perrotti. All rights reserved.
//

#import "DHModularPopupController.h"
#import "DHConstraintUtility.h"
#import <QuartzCore/QuartzCore.h>

#import "PMValidationEmailType.h"
#import "PMValidationLengthType.h"
#import "PMValidationRegexType.h"
#import "PMValidationStringCompareType.h"
#import "PMValidationUITextCompareType.h"
#import <dispatch/dispatch.h>


#define CNP_SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define CNP_IS_IPAD   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

typedef struct {
    CGFloat top;
    CGFloat bottom;
} CNPTopBottomPadding;

extern CNPTopBottomPadding CNPTopBottomPaddingMake(CGFloat top, CGFloat bottom) {
    CNPTopBottomPadding padding;
    padding.top = top;
    padding.bottom = bottom;
    return padding;
};


#pragma mark - Popup Base Button Interface
// ------------------------------------------------------------------------------------------------
@interface DHPopupBaseButton : UIButton
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) DHPopupBaseButtonItem *item;
@property (nonatomic, strong) UIView                *encapsulatingView;
@end

#pragma mark - Popup Button Interface
// ------------------------------------------------------------------------------------------------
@interface DHPopupButton : DHPopupBaseButton
// ------------------------------------------------------------------------------------------------
@end

#pragma mark - Popup Button with View Interface
// ------------------------------------------------------------------------------------------------
@interface DHPopupButtonWithView : DHPopupBaseButton
// ------------------------------------------------------------------------------------------------
@end

#pragma mark - Popup Aesthetic View
// ------------------------------------------------------------------------------------------------
@interface DHPopupAestheticView : UIView
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) DHPopupAestheticViewItem *item;
@end

#pragma mark - Popup Title Button Interface
// ------------------------------------------------------------------------------------------------
@interface DHPopupTitle : UIButton
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) DHPopupTitleItem *item;
@end

#pragma mark - Popup Field Interface
// ------------------------------------------------------------------------------------------------
@interface DHPopupField : UIView <DHPopupDataProviderItemProtocol>
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) DHPopupFieldItem *item;
@property (nonatomic, strong) UIView                 *fieldView;
@property (nonatomic, strong) UITextField            *textField;
@end
// ------------------------------------------------------------------------------------------------
@interface DHPopupFieldWithDataValidation : UIView <DHPopupDataProviderItemProtocol, UITextFieldDelegate>
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) DHPopupFieldWithDataValidationItem *item;
@property (nonatomic, strong) UIView                             *fieldView;
@property (nonatomic, strong) UITextField                        *textField;
@property (nonatomic, strong) UIView                             *validDataStatusIcon;
@property (nonatomic, strong) UIView                             *invalidDataStatusIcon;
@property                     BOOL                                dataIsValid;
- (void) registerForUIUpdateOnTextFieldChange;
@end

#pragma mark - Popup Display Text Interface
// ------------------------------------------------------------------------------------------------
@interface DHPopupDisplayText : UIView
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) DHPopupDisplayTextItem *item;
@property (nonatomic, strong) UILabel                  *textField;
@end

#pragma mark - Popup Divider Interface
// ------------------------------------------------------------------------------------------------
@interface DHPopupDivider : UIView
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) DHPopupDividerItem *item;
@end

#pragma mark - Second Menu Interface
// ------------------------------------------------------------------------------------------------
@interface DHPopupSecondMenu : UIView
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) DHPopupSecondMenuItem * item;
@property (nonatomic, strong) SelectionHandler              selectionHandler;
@end

#pragma mark - Popup Confirmation Secondary Menu Interface
// ------------------------------------------------------------------------------------------------
@interface DHPopupConfirmation : UIView
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) DHPopupConfirmationItem *item;
@property (nonatomic, strong) UILabel                  *title;
@property (nonatomic, strong) DHPopupButton           *confirmationButton;
@property (nonatomic, strong) DHPopupButton           *cancelButton;
@property (nonatomic, strong) SelectionHandler         selectionHandler;
@end

#pragma mark - Popup Controller Interface
// ------------------------------------------------------------------------------------------------
@interface DHModularPopupController () <UIGestureRecognizerDelegate>
// ------------------------------------------------------------------------------------------------

@property (nonatomic, strong) UIView                 *contentView;
@property (nonatomic, strong) DHPopupConfirmation   *confirmationView;
@property (nonatomic, strong) DHPopupSecondMenu     *secondMenuView;
@property (nonatomic, strong) UIView                 *maskView;
@property (nonatomic, strong) UIScrollView           *scrollview;
@property (nonatomic, strong) UITapGestureRecognizer *backgroundDismissGesture;
@property (nonatomic)         CGFloat                 keyboardHeight;



@property (nonatomic, strong) NSLayoutConstraint *contentViewCenterXConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentViewCenterYConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentViewWidth;
@property (nonatomic, strong) NSLayoutConstraint *contentViewHeight;
@property (nonatomic, strong) NSLayoutConstraint *contentViewBottom;

@end






// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#pragma mark - Implementation
@implementation DHModularPopupController
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

@synthesize applicationKeyWindow;

#pragma mark - Initialization

// ------------------------------------------------------------------------------------------------
/**
 *  Use this initialization method to create a basic popup. You will need to make calls to
 *  'addBodyItem:' to customize it further.
 *
 *  @param popupTitle (OPTIONAL) A title item to be displayed at the top of the popup window
 *  @param keyWindow  (REQUIRED) A reference to the currently active window (ie. one which is
 *                               currently being displayed on the screen.
 *  @param aTheme     (REQUIRED) Theme item describing required UI properties for the popup.
 *
 *  @return An instance of the PopupController.
 */
- (instancetype) initWithTitleItem: (DHPopupTitleItem *)   popupTitle
                         keyWindow: (UIWindow*)             keyWindow
                             theme: (DHPopupTheme *)        aTheme
// ------------------------------------------------------------------------------------------------
{
    self = [super init];

    if (self)
    {
        _popupTitleItem = popupTitle;
        _theme          = aTheme;
        // Window setup
        if (!keyWindow)
        {
            NSLog(@"Key window not given");
            NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];

            for (UIWindow *window in frontToBackWindows)
            {
                if (window.windowLevel == UIWindowLevelNormal)
                {
                    self.applicationKeyWindow = window;
                    break;
                }
            }
        } else {
            self.applicationKeyWindow = keyWindow;
        }


        if (CNP_SYSTEM_VERSION_LESS_THAN(@"8.0"))
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(statusBarFrameOrOrientationChanged:)
                                                         name:UIApplicationDidChangeStatusBarOrientationNotification
                                                       object:nil];

            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(statusBarFrameOrOrientationChanged:)
                                                         name:UIApplicationDidChangeStatusBarFrameNotification
                                                       object:nil];
        }

        [self initializeMaskview];
        [self initializePrimaryWindow];
        [self initializeTitle];
    }
    return self;
}

#pragma mark - Customization
// ------------------------------------------------------------------------------------------------
/**
 *  Use this method on a freshly created popup *before presenting it* to consecutively add the
 *  UI items you want in the body of the popup (added in order below the title, if any).
 *
 *  - Determines item type, builds it from the given template item.
 *
 *  - Adds it to the main popup window's view, calculates and adds layout constraints.
 *
 *  @param bodyItem A UI item template.
 */
- (void) addBodyItem: (DHPopupBodyItem *) bodyItem
// ------------------------------------------------------------------------------------------------
{
    if ([bodyItem class] == [DHPopupDividerItem class])
    {
        DHPopupDivider* divider = [self dividerItem:((DHPopupDividerItem *)bodyItem)];
        [self addViewToPrimaryWindow:divider];
        [self.ordered_body_contents addObject:divider];
    }
    else if ([bodyItem class] == [DHPopupDisplayTextItem class])
    {
        DHPopupDisplayText* displayText = [self displayTextItem:((DHPopupDisplayTextItem *)bodyItem)];
        [self addViewToPrimaryWindow:displayText];
        [self.ordered_body_contents addObject:displayText];
    } else if ([bodyItem class] == [DHPopupFieldWithDataValidationItem class])
    {
        DHPopupFieldWithDataValidationItem * item = (DHPopupFieldWithDataValidationItem *) bodyItem;
        DHPopupFieldWithDataValidation *field = [self fieldWithDataValidationItem:item];
        [self addViewToPrimaryWindow:field];
        [self.ordered_body_contents addObject:field];
    }
    else if ([bodyItem class] == [DHPopupFieldItem class])
    {
        DHPopupField* field = [self fieldItem:((DHPopupFieldItem *) bodyItem)];
        [self addViewToPrimaryWindow:field];
        [self.ordered_body_contents addObject:field];
    }
    else if ([bodyItem class] == [DHPopupButtonItem class])
    {
        DHPopupButton* popButton = [self buttonItem:((DHPopupButtonItem *)bodyItem)];
        [self addViewToPrimaryWindow:popButton.encapsulatingView];
        [self.ordered_body_contents addObject:popButton.encapsulatingView];
    }
    else if ([bodyItem class] == [DHPopupButtonWithViewItem class])
    {
        DHPopupButtonWithView* popButtonWithView = [self buttonWithViewItem:((DHPopupButtonWithViewItem *) bodyItem)];
        [self addViewToPrimaryWindow:popButtonWithView.encapsulatingView];
        [self.ordered_body_contents addObject:popButtonWithView.encapsulatingView];
    } else if ([bodyItem class] == [DHPopupAestheticViewItem class])
    {
        DHPopupAestheticView* aestheticView = [self aestheticViewItem:((DHPopupAestheticViewItem *) bodyItem)];
        [self addViewToPrimaryWindow:aestheticView];
        [self.ordered_body_contents addObject:aestheticView];
    }
}


// ------------------------------------------------------------------------------------------------
-(void)dealloc
// ------------------------------------------------------------------------------------------------
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Constraints Setup

// ------------------------------------------------------------------------------------------------
/**
 *  Creates and sets up the popup background view within which all other views relating to the popup
 *  are contained, calculates constraints for this view and adds them, adds a gesture recognizer
 *  for background dismissal (if required).
 */
- (void)initializeMaskview
// ------------------------------------------------------------------------------------------------
{
//    self.scrollview = [[UIScrollView alloc] initWithFrame:self.applicationKeyWindow.frame];
//    PREPCONSTRAINTS(self.scrollview);
//    [self.applicationKeyWindow addSubview:self.scrollview];
//    ALIGN_VIEW_ALL_SIDES(self.applicationKeyWindow, self.scrollview);
//    CONSTRAIN_SIZE(self.scrollview,
//                   self.applicationKeyWindow.frame.size.height,
//                   self.applicationKeyWindow.frame.size.width);
//
//
    // Set up solid-color background overlay (maskview)
    self.maskView = [UIView new];
    PREPCONSTRAINTS(self.maskView);
    self.maskView.alpha = 0.0;

    if (self.theme.shouldDismissOnBackgroundTouch)
    {
        self.backgroundDismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(didTapOnMaskView)];
        self.backgroundDismissGesture.numberOfTapsRequired = 1;
        [self.backgroundDismissGesture setDelegate:self];
        [self.maskView addGestureRecognizer:self.backgroundDismissGesture];
    }

    // Align the maskview to the screen's edges for complete coverage:
    [self.applicationKeyWindow addSubview:self.maskView];
    ALIGN_VIEW_ALL_SIDES(self.applicationKeyWindow, self.maskView)
//    CONSTRAIN_SIZE(self.maskView,
//                   self.applicationKeyWindow.frame.size.height,
//                   self.applicationKeyWindow.frame.size.width);

    if (self.theme.popupStyle == DHPopupStyleFullscreen) {
        self.maskView.backgroundColor = [UIColor whiteColor];
    }
    else {
        if (self.theme.maskType == DHPopupMaskTypeDimmed) {
            self.maskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        } else {
            self.maskView.backgroundColor = [UIColor clearColor];
        }
    }
}

// ------------------------------------------------------------------------------------------------
/**
 *  Creates the primary popup window view, configures some UI settings based on the template,
 *  calculates and adds constraints for proper layout.
 */
- (void) initializePrimaryWindow
// ------------------------------------------------------------------------------------------------
{
    // Setup the primary popup window:
    self.contentView = [[UIView alloc] init];
    PREPCONSTRAINTS(self.contentView);
    self.contentView.clipsToBounds      = YES;
    self.contentView.backgroundColor    = self.theme.backgroundColor;
    self.contentView.layer.cornerRadius = self.theme.popupStyle == DHPopupStyleCentered ? self.theme.cornerRadius : 0.0f;
    [self.maskView addSubview:self.contentView];

    [self.maskView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationLessThanOrEqual
                                                                 toItem:self.maskView
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:0]];
    [self.maskView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationLessThanOrEqual
                                                                 toItem:self.maskView
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0]];

    if (self.theme.popupStyle == DHPopupStyleFullscreen) {
        self.contentViewWidth = [NSLayoutConstraint constraintWithItem:self.contentView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.maskView
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:CNP_IS_IPAD?0.5:1.0
                                                              constant:0];
        [self.maskView addConstraint:self.contentViewWidth];
        self.contentViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.maskView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:0];
        [self.maskView addConstraint:self.contentViewCenterYConstraint];
        self.contentViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.maskView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0];
        [self.maskView addConstraint:self.contentViewCenterXConstraint];
    }
    else if (self.theme.popupStyle == DHPopupStyleActionSheet) {
        self.contentViewHeight = [NSLayoutConstraint constraintWithItem:self.contentView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.maskView
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:CNP_IS_IPAD?0.5:1.0
                                                               constant:0];
        [self.maskView addConstraint:self.contentViewHeight];
        self.contentViewBottom = [NSLayoutConstraint constraintWithItem:self.contentView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.maskView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0];
        [self.maskView addConstraint:self.contentViewBottom];
        self.contentViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.maskView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0];
        [self.maskView addConstraint:self.contentViewCenterXConstraint];
    }
    else { // For free-floating popups (ie. not actionsheet or full-screen)
        if (self.theme.preferredWidth > 0)
        {
            self.contentViewWidth = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:self.theme.preferredWidth];


        } else {
            if (CNP_IS_IPAD) {
                self.contentViewWidth = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.maskView
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:0.4
                                                                      constant:0];
            }
            else {
                self.contentViewWidth = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.maskView
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.0
                                                                      constant:-40];
            }
        }
        [self.maskView addConstraint:self.contentViewWidth];

        // Setting the vertical alignment depending on given value for vertical alignment style:
        switch (self.theme.verticalAlignmentStyle)
        {
            case DHVerticalAlignmentStyle_ToScreenTop: // Align to top of screen
                self.contentViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                                 attribute:NSLayoutAttributeTop
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.maskView
                                                                                 attribute:NSLayoutAttributeTop
                                                                                multiplier:1.0
                                                                                  constant:(self.theme.centerYOffset < 0) ? -self.theme.centerYOffset : self.theme.centerYOffset];
                break;
            default:
            case DHVerticalAlignmentStyle_ToScreenCenter: // Align to center of screen
                self.contentViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                                 attribute:NSLayoutAttributeCenterY
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.maskView
                                                                                 attribute:NSLayoutAttributeCenterY
                                                                                multiplier:1.0
                                                                                  constant:self.theme.centerYOffset];
                break;
        }
        [self.maskView addConstraint:self.contentViewCenterYConstraint];
        // Add a constraint to the bottom of the main menu that it should not be below the bottom
        // of the screen.
//        [self.maskView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
//                                                                  attribute:NSLayoutAttributeBottom
//                                                                  relatedBy:NSLayoutRelationLessThanOrEqual
//                                                                     toItem:self.maskView
//                                                                  attribute:NSLayoutAttributeBottom
//                                                                 multiplier:1.0
                                                            //constant:0]];
        // Align popup to be centered horizontally:
        self.contentViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.maskView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0];
        [self.maskView addConstraint:self.contentViewCenterXConstraint];
    }
}

// ------------------------------------------------------------------------------------------------
/**
 *  If present, creates and adds the title view the primary popup view, creates and adds the required
 *  constraints and sets some UI priority settings.
 */
- (void) initializeTitle
// ------------------------------------------------------------------------------------------------
{
    // Create and add the title, if present:
    if (self.popupTitleItem) {
        DHPopupTitle *titleLabel = [self titleItem:self.popupTitleItem];
        [self addViewToPrimaryWindow:titleLabel];
    }
}

// ------------------------------------------------------------------------------------------------
/**
 *  Adds the given view to the primary popup view, creates and adds the required constraints for
 *  proper layout, sets some UI priority settings.
 *
 *  @param view Should be one of the defined body items.
 */
- (void) addViewToPrimaryWindow: (UIView*) view
// ------------------------------------------------------------------------------------------------
{
    if (self.contentView.subviews.count == 0)
    {
        [self.contentView addSubview:view];
        ALIGN_VIEW_TOP_CONSTANT(self.contentView, view, self.theme.popupContentInsets.top);
    } else {
        UIView *previousSubView = [self.contentView.subviews lastObject];
        [self.contentView addSubview:view];
        if (previousSubView) {
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:previousSubView
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1.0
                                                                          constant:self.theme.contentVerticalPadding]];
        }
    }

    [view setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    [view setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    ALIGN_VIEW_RIGHT_CONSTANT(self.contentView, view, self.theme.popupContentInsets.right);
    ALIGN_VIEW_LEFT_CONSTANT(self.contentView, view, -self.theme.popupContentInsets.left);
}

// ------------------------------------------------------------------------------------------------
/**
 *  Accepts a secondary menu item, builds it from this template, adds it to the base popup view
 *  and adds the neccessary constraints.
 *
 *  @param secondMenuItem The template for the second menu.
 */
- (void) addSecondaryWindow: (DHPopupSecondMenuItem *) secondMenuItem
// ------------------------------------------------------------------------------------------------
{
    self.popupSecondaryMenuItem = secondMenuItem;

    if (self.popupSecondaryMenuItem)
    {
        self.secondMenuView = [self secondMenuItem:self.popupSecondaryMenuItem];
        [self.maskView addSubview:self.secondMenuView];


        [self.maskView addConstraint:[NSLayoutConstraint constraintWithItem:self.secondMenuView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:self.popupSecondaryMenuItem.verticalOffset]];
        [self.maskView addConstraint:[NSLayoutConstraint constraintWithItem:self.secondMenuView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:0]];
        [self.maskView addConstraint:[NSLayoutConstraint constraintWithItem:self.secondMenuView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0
                                                                   constant:0]];
        // Add a constraint to the bottom of the second menu that it should not be below the bottom
        // of the screen.
        [self.maskView addConstraint:[NSLayoutConstraint constraintWithItem:self.secondMenuView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationLessThanOrEqual
                                                                     toItem:self.maskView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:0]];
    }
}



#pragma mark - User Data Handling
// ------------------------------------------------------------------------------------------------
/**
 *  Locates and returns the UI object which is responsible for returning the piece of data with
 *  the given unique data identifier string.
 *
 *  @param dataID The unique string identifier for the desired piece of data.
 *
 *  @return The UI object identified as the DataProvider for the dataID.
 */
- (NSObject<DHPopupDataProviderItemProtocol>*) getDataProviderForDataID: (NSString*) dataID
// ------------------------------------------------------------------------------------------------
{
    if (self.dataID_to_dataProvider &&
        [self.dataID_to_dataProvider objectForKey:dataID])
    {
        return  [self.dataID_to_dataProvider objectForKey:dataID];
    } else {
        return nil;
    }
}
// ------------------------------------------------------------------------------------------------
/**
 *  Locates the UI reponsible for returning the data with the given unique data identifier, then
 *  acquires this data object from the DataProvider and returns it.
 *
 *  @param dataID The unique string identifier for the desired piece of data.
 *
 *  @return The data object associated with the given dataID.
 */
- (NSObject*) getDataFromProviderWithDataID: (NSString*) dataID
// ------------------------------------------------------------------------------------------------
{
    NSObject<DHPopupDataProviderItemProtocol> *dataProvider = [self getDataProviderForDataID:dataID];

    if (!dataProvider) return nil;

    return [dataProvider getCurrentData];
}
// ------------------------------------------------------------------------------------------------
/**
 *  Takes an array of unique data identifier strings, locates and acquires the data from the associated
 *  DataProvider UI objects, puts each data object into a dictionary keyed to its dataID string and
 *  returns that dictionary.
 *
 *  @param idPackage an array of unique data identifier strings.
 *
 *  @return a dictionary contained the data objects keyed to each respective data identifier string.
 */
- (NSDictionary*) getOptionalDataPackageForIDs: (NSArray*) idPackage
// ------------------------------------------------------------------------------------------------
{
    NSMutableDictionary* returnDict = [NSMutableDictionary new];

    for (NSString* anID in idPackage)
    {
        NSObject* data_or_nil = [self getDataFromProviderWithDataID:anID];
        if (data_or_nil)
        {
            [returnDict setObject:data_or_nil forKey:anID];
        }
    }
    if (returnDict.count == 0)
    {
        return nil;
    } else {
        return returnDict;
    }
}

// ------------------------------------------------------------------------------------------------
/**
 *  This should be performed on a separate thread than the main thread.
 *
 *  Takes an array of unique data identifier strings, locates and acquires the data from the associated
 *  DataProvider UI objects, puts each data object into a dictionary keyed to its dataID string and
 *  returns that dictionary.
 *
 *  @param idPackage an array of unique data identifier strings.
 *
 *  @return a dictionary contained the data objects keyed to each respective data identifier string.
 */
- (NSDictionary*) getRequiredDataPackageForIDs: (NSArray*) idPackage
// ------------------------------------------------------------------------------------------------
{
    NSMutableDictionary* returnDict = [NSMutableDictionary new];
    BOOL allDataValid = YES;

    for (NSString* anID in idPackage)
    {
        NSObject<DHPopupDataProviderItemProtocol>* provider_or_nil = [self getDataProviderForDataID:anID];
        if (!provider_or_nil ||
            ![provider_or_nil checkIfDataIsValid])
        {
            allDataValid = NO;
        }
    }

    if (!allDataValid)
    {
        // FAILURE CONDITION MET: a data provider indicated its data is invalid
        return nil;
    }

    for (NSString* anID in idPackage)
    {
        NSObject<DHPopupDataProviderItemProtocol>* provider_or_nil = [self getDataProviderForDataID:anID];

        if (provider_or_nil)
        {
            [returnDict setObject:[provider_or_nil getCurrentData] forKey:anID];

        } else {
            // FAILURE CONDITION MET: a data provider for a required data does not exist
            return nil;
        }
    }

    if (returnDict.count > 0)
    {
        return returnDict;
    } else {
        return nil;
    }
}

// ------------------------------------------------------------------------------------------------
- (void) notifyDataProviderForID: (NSString*) aDataID
               ofErrorWithReason: (NSString*) aReason
// ------------------------------------------------------------------------------------------------
{
    NSObject<DHPopupDataProviderItemProtocol>* provider_or_nil = [self getDataProviderForDataID:aDataID];

    if (provider_or_nil)
    {
        [provider_or_nil notifyThatDataIsInvalidWithReason:aReason];
    }
}

// ------------------------------------------------------------------------------------------------
- (void) notifyDataProvidersOfInvalidData: (NSDictionary*) key_DataID_object_Reason
// ------------------------------------------------------------------------------------------------
{
    if (!key_DataID_object_Reason) return;


    NSArray* idPackage = [key_DataID_object_Reason allKeys];

    for (NSString* anID in idPackage)
    {
        [self notifyDataProviderForID:anID
                    ofErrorWithReason:[key_DataID_object_Reason objectForKey:idPackage]];
    }
}



#pragma mark - Touch Handling
// ------------------------------------------------------------------------------------------------
/**
 *  The method called when a button on the primary/secondary popup window is pressed.
 *
 *  IF a confirmation item is present on the button THEN any current confirmations being shown are hidden
 *  before the button-associated confirmation is presented.
 *
 *  ELSE if a selection handler is present, it is called and given a dictionary of any required
 *  data from the button's declared dataID's (if any).
 *
 *  @param sender The popup button that was pressed.
 */
- (void)actionButtonPressed:(DHPopupBaseButton *)sender
// ------------------------------------------------------------------------------------------------
{
    if (sender.item.confirmationItem)
    {// If there is a confirmation message to show:

        if (self.confirmationView)
        {// If there is already a confirmation message showing:
            [UIView animateWithDuration:0.3 animations:^{
                [self.confirmationView setAlpha:0];
            } completion:^(BOOL finished) {
                [self.confirmationView removeFromSuperview];
                self.confirmationView.item = nil;
                self.confirmationView = nil;
                [self presentPopupConfirmation:sender.item.confirmationItem
                                      animated:YES];
            }];
        } else {
            [self presentPopupConfirmation:sender.item.confirmationItem
                                  animated:YES];
        }
    }
    else
    {
        NSMutableDictionary* data_or_nil = [NSMutableDictionary new];

        // if we've only got optional data and a selection handler:
        if ( sender.item.selectionHandler &&
            (!sender.item.formValidationHandler || !sender.item.requiredValidatedDataWithIDs))
        {
            [data_or_nil addEntriesFromDictionary: [self getOptionalDataPackageForIDs:sender.item.includeDataWithIDs]];
            // (DHPopupBaseButtonItem *item, NSDictionary* requiredData);

            sender.item.selectionHandler(sender.item, data_or_nil);

            [self dismissPopupControllerAnimated:YES
                            withButtonIdentifier:sender.item.identifier];

        } else
            if ((!sender.item.formValidationHandler || !sender.item.requiredValidatedDataWithIDs))
        {
            [self dismissPopupControllerAnimated:YES
                            withButtonIdentifier:sender.item.identifier];
        } else
            // if we've got validation data and a validation handler (and maybe optional data):
        if (sender.item.requiredValidatedDataWithIDs && sender.item.formValidationHandler)
        {
            if (sender.item.includeDataWithIDs)
            {
                [data_or_nil addEntriesFromDictionary: [self getOptionalDataPackageForIDs:sender.item.includeDataWithIDs]];
            }

            NSDictionary* requiredData = [self getRequiredDataPackageForIDs:sender.item.requiredValidatedDataWithIDs];

            if (!requiredData)
            {
                return;
            }

            // create retain-loop-proof references:
            __weak DHModularPopupController * weakSelf = self;

            /* create form validation completion handler with ability to easily dismiss
             the popup and/or dismiss the loading view.

             typedef void(^RunOnCompletion)
             (BOOL             dismissPopup,
             BOOL             dismissLoadingView,
             NSDictionary*    errorsForDataIDs);

             */
            RunOnCompletion completion = ^(BOOL dismissPopup,
                                           BOOL dismissLoadingView,
                                           NSDictionary* errorsForDataIDs)
            {
                if (dismissPopup && weakSelf)
                {
                    [weakSelf dismissPopupControllerAnimated:YES
                                    withButtonIdentifier:sender.item.identifier];
                }
                if (errorsForDataIDs)
                {
                    [weakSelf notifyDataProvidersOfInvalidData:errorsForDataIDs];
                }
            };
            // call the form validation handler, selection handler is ignored if present
            sender.item.formValidationHandler(sender.item,  // DHPopupBaseButtonItem *item
                                              data_or_nil,  // NSDictionary* optionalData
                                              requiredData, // NSDictionary* requiredData
                                              completion);  // RunOnCompletion runOnCompletion

        }
    }
}

// ------------------------------------------------------------------------------------------------
/**
 *  Called when the 'accept' button on a confirmation item has been pressed. If a selection handler
 *  is present, it is called and given a dictionary of any required data from the button's
 *  declared dataID's (if any). Then, BOTH the confirmation item and the main popup are dismissed.
 *
 *  @param sender The pressed button.
 */
- (void) acceptButtonPressed:(DHPopupButton *)sender
// ------------------------------------------------------------------------------------------------
{
    if (sender.item.selectionHandler)
    {
        NSDictionary* data_or_nil = nil;
        if (sender.item.includeDataWithIDs)
        {
            data_or_nil = [self getOptionalDataPackageForIDs:sender.item.includeDataWithIDs];
        }
        sender.item.selectionHandler(sender.item, data_or_nil);
    }
    [self dismissPopupControllerAnimated:YES];
}
// ------------------------------------------------------------------------------------------------
/**
 *  Called when the 'cancel' button on a confirmation item has been pressed. This dismisses the
 *  confirmation window with an animation, but does NOT dismiss the main popup window(s).
 *
 *  @param sender The pressed button.
 */
- (void) cancelButtonPressed:(DHPopupButton *)sender
// ------------------------------------------------------------------------------------------------
{
    if (sender.item.selectionHandler)
    {
        NSDictionary* data_or_nil = nil;
        if (sender.item.includeDataWithIDs)
        {
            data_or_nil = [self getOptionalDataPackageForIDs:sender.item.includeDataWithIDs];
        }
        sender.item.selectionHandler(sender.item, data_or_nil);
    }
    [self dismissPopupConfirmationAnimated:YES];
}


#pragma mark - Background Gesture Recognizer Delegate Methods

// ------------------------------------------------------------------------------------------------
- (BOOL) gestureRecognizer: (UIGestureRecognizer *)gestureRecognizer
        shouldReceiveTouch: (UITouch *)touch
// ------------------------------------------------------------------------------------------------
{
    CGPoint touchPoint = [touch locationInView:self.maskView];
    return !CGRectContainsPoint(self.contentView.frame, touchPoint);
}

// ------------------------------------------------------------------------------------------------
/**
 *  Dismisses the popup if the user taps on the background (maskview)
 */
- (void)didTapOnMaskView
// ------------------------------------------------------------------------------------------------
{
    if (self.theme.shouldDismissOnBackgroundTouch)
    {
        [self dismissPopupControllerAnimated:YES withButtonIdentifier:nil];
    }
}


#pragma mark - Presentation
// ------------------------------------------------------------------------------------------------
/**
 *  Creates a confirmation view from the given template item, adds layout constraints so it will
 *  show below the primary popup window (or the second, if present), and shows/presents it.
 *
 *  @param aConfirmationItem A template for a confirmation view that appears below either the primary
 *                           popup window or the secondary popup window if present.
 *  @param shouldAnimate     Whether the popup's presentation should be animated or occur instantly.
 */
- (void)presentPopupConfirmation: (DHPopupConfirmationItem *) aConfirmationItem
                        animated: (BOOL)                      shouldAnimate
// ------------------------------------------------------------------------------------------------
{
    // Show confirmation view
    // Set confirmation view as active
    DHPopupConfirmation* confirmView = [self confirmationItem:aConfirmationItem];
    self.confirmationView = confirmView;
    [confirmView setAlpha:0];
    [self.maskView addSubview:confirmView];

    // CONSTRAINTS:
    UIView* firstView = confirmView;
    UIView* secondView = self.contentView;
    if (self.secondMenuView)
    {
        secondView = self.secondMenuView;
    }
    [self.maskView addConstraint:[NSLayoutConstraint constraintWithItem:firstView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:secondView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:aConfirmationItem.verticalOffset]];
    [self.maskView addConstraint:[NSLayoutConstraint constraintWithItem:firstView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:secondView
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0]];
    [self.maskView addConstraint:[NSLayoutConstraint constraintWithItem:firstView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:secondView
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0]];
    [self.maskView setNeedsUpdateConstraints];
    [self.maskView layoutIfNeeded];
    [UIView animateWithDuration:shouldAnimate ? 0.3f : 0.0f
                     animations:^{
                         [confirmView setAlpha:1];
                     }];

}
// ------------------------------------------------------------------------------------------------
/**
 *  Dismisses/hides the confirmation view from the screen, removes it from the screens view hiearchy
 *  and nils out all references to it.
 *
 *  @param shouldAnimate Whether the confirmation view's dismissal should be animated.
 */
- (void)dismissPopupConfirmationAnimated: (BOOL) shouldAnimate
// ------------------------------------------------------------------------------------------------
{
    [UIView animateWithDuration:shouldAnimate ? 0.3f : 0.0f
                     animations:^{
                         [self.confirmationView setAlpha:0];
                     } completion:^(BOOL finished) {
                         [self.confirmationView removeFromSuperview];
                         self.confirmationView.item = nil;
                         self.confirmationView = nil;
                     }];
}
// ------------------------------------------------------------------------------------------------
/**
 *  Call after creating and customizing your popup. This method will finalize the popup's creation
 *  and customization, and show the popup on the device screen.
 *
 *  @param flag Whether the presentation of the popup should be animated or occur instantly.
 */
- (void)presentPopupControllerAnimated:(BOOL)flag
// ------------------------------------------------------------------------------------------------
{
    // Safety Checks
    NSAssert(self.theme!=nil,@"You must set a theme. You can use [CNPTheme defaultTheme] as a starting place");

    if ([self.contentView.subviews lastObject])
    {
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:[self.contentView.subviews lastObject]
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:-(self.theme.popupContentInsets.bottom)]];
    }


//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];

    if (CNP_SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
    }
    [self setDismissedConstraints];
    [self.maskView needsUpdateConstraints];
    [self.maskView layoutIfNeeded];
    [self setPresentedConstraints];

    if ([self.delegate respondsToSelector:@selector(popupControllerWillPresent:)]) {
        [self.delegate popupControllerWillPresent:self];
    }

    [UIView animateWithDuration:flag ? 0.3f : 0.0f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.maskView.alpha = 1.0f;
                         [self.maskView needsUpdateConstraints];
                         [self.maskView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(popupControllerDidPresent:)]) {
                             [self.delegate popupControllerDidPresent:self];
                         }
                     }];
}
// ------------------------------------------------------------------------------------------------
- (void)dismissPopupControllerAnimated:(BOOL)flag
// ------------------------------------------------------------------------------------------------
{
    [self dismissPopupControllerAnimated:flag withButtonIdentifier:nil];
}
// ------------------------------------------------------------------------------------------------
/**
 *  Dismisses the popup and all associated window(s) and popup confirmation. Nils out all references
 *  for memory deallocation by ARC.
 *
 *  @param flag  Whether the popup's dismissal should be animated or occur instantly.
 *  @param title The title of the button whose activation incurred the dismissal.
 */
- (void)dismissPopupControllerAnimated: (BOOL)       flag
                  withButtonIdentifier: (NSString *) anIdentifier
// ------------------------------------------------------------------------------------------------
{

    if (self.theme.dismissesOppositeDirection) {
        [self setDismissedConstraints];
    } else {
        [self setOriginConstraints];
    }

    if ([self.delegate respondsToSelector:@selector(popupController:willDismissWithButtonIdentifier:)]) {
        [self.delegate popupController:self willDismissWithButtonIdentifier:anIdentifier];
    }

    [UIView animateWithDuration:flag ? 0.3f : 0.0f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.maskView.alpha = 0.0f;
                         [self.maskView needsUpdateConstraints];
                         [self.maskView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self.maskView removeFromSuperview];
                         self.maskView = nil;
                         self.contentView = nil;
                         if (self.secondMenuView)
                         {
                             self.secondMenuView = nil;
                         }
                         if (self.confirmationView)
                         {
                             self.confirmationView.item = nil;
                             self.confirmationView = nil;
                         }
                         if ([self.delegate respondsToSelector:@selector(popupController:didDismissWithButtonIdentifier:)]) {
                             [self.delegate popupController:self didDismissWithButtonIdentifier:anIdentifier];
                         }
                     }];
}

// ------------------------------------------------------------------------------------------------
- (void)setOriginConstraints
// ------------------------------------------------------------------------------------------------
{

    if (self.theme.popupStyle == DHPopupStyleCentered) {
        switch (self.theme.presentationStyle) {
            case DHPopupPresentationStyleFadeIn:
                self.contentViewCenterYConstraint.constant = 0;
                self.contentViewCenterXConstraint.constant = 0;
                break;
            case DHPopupPresentationStyleSlideInFromTop:
                self.contentViewCenterYConstraint.constant = -self.applicationKeyWindow.bounds.size.height;
                self.contentViewCenterXConstraint.constant = 0;
                break;
            case DHPopupPresentationStyleSlideInFromBottom:
                self.contentViewCenterYConstraint.constant = self.applicationKeyWindow.bounds.size.height;
                self.contentViewCenterXConstraint.constant = 0;
                break;
            case DHPopupPresentationStyleSlideInFromLeft:
                self.contentViewCenterYConstraint.constant = 0;
                self.contentViewCenterXConstraint.constant = -self.applicationKeyWindow.bounds.size.height;
                break;
            case DHPopupPresentationStyleSlideInFromRight:
                self.contentViewCenterYConstraint.constant = 0;
                self.contentViewCenterXConstraint.constant = self.applicationKeyWindow.bounds.size.height;
                break;
            default:
                self.contentViewCenterYConstraint.constant = 0;
                self.contentViewCenterXConstraint.constant = 0;
                break;
        }
    }
    else if (self.theme.popupStyle == DHPopupStyleActionSheet) {
        self.contentViewBottom.constant = self.applicationKeyWindow.bounds.size.height;
    }
}

// ------------------------------------------------------------------------------------------------
- (void)setDismissedConstraints
// ------------------------------------------------------------------------------------------------
{

    if (self.theme.popupStyle == DHPopupStyleCentered) {
        switch (self.theme.presentationStyle) {
            case DHPopupPresentationStyleFadeIn:
                self.contentViewCenterYConstraint.constant = 0;
                self.contentViewCenterXConstraint.constant = 0;
                break;
            case DHPopupPresentationStyleSlideInFromTop:
                self.contentViewCenterYConstraint.constant = self.applicationKeyWindow.bounds.size.height;
                self.contentViewCenterXConstraint.constant = 0;
                break;
            case DHPopupPresentationStyleSlideInFromBottom:
                self.contentViewCenterYConstraint.constant = -self.applicationKeyWindow.bounds.size.height;
                self.contentViewCenterXConstraint.constant = 0;
                break;
            case DHPopupPresentationStyleSlideInFromLeft:
                self.contentViewCenterYConstraint.constant = 0;
                self.contentViewCenterXConstraint.constant = self.applicationKeyWindow.bounds.size.height;
                break;
            case DHPopupPresentationStyleSlideInFromRight:
                self.contentViewCenterYConstraint.constant = 0;
                self.contentViewCenterXConstraint.constant = -self.applicationKeyWindow.bounds.size.height;
                break;
            default:
                self.contentViewCenterYConstraint.constant = 0;
                self.contentViewCenterXConstraint.constant = 0;
                break;
        }
    }
    else if (self.theme.popupStyle == DHPopupStyleActionSheet) {
        self.contentViewBottom.constant = self.applicationKeyWindow.bounds.size.height;
    }
}

// ------------------------------------------------------------------------------------------------
- (void)setPresentedConstraints
// ------------------------------------------------------------------------------------------------
{

    if (self.theme.popupStyle == DHPopupStyleCentered) {
        self.contentViewCenterYConstraint.constant = self.theme.centerYOffset;
        self.contentViewCenterXConstraint.constant = 0;
    }
    else if (self.theme.popupStyle == DHPopupStyleActionSheet) {
        self.contentViewBottom.constant = 0;
    }
}

#pragma mark - Window Handling
// ------------------------------------------------------------------------------------------------
- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification
// ------------------------------------------------------------------------------------------------
{
    [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
}
// ------------------------------------------------------------------------------------------------
- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations
// ------------------------------------------------------------------------------------------------
{
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat angle = CNP_UIInterfaceOrientationAngleOfOrientation(statusBarOrientation);
    CGFloat statusBarHeight = [self getStatusBarHeight];

    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    CGRect frame = [self rectInWindowBounds:self.applicationKeyWindow.bounds statusBarOrientation:statusBarOrientation statusBarHeight:statusBarHeight];

    [self setIfNotEqualTransform:transform frame:frame];
}
// ------------------------------------------------------------------------------------------------
- (void)setIfNotEqualTransform:(CGAffineTransform)transform frame:(CGRect)frame
// ------------------------------------------------------------------------------------------------
{
    if(!CGAffineTransformEqualToTransform(self.maskView.transform, transform))
    {
        self.maskView.transform = transform;
    }
    if(!CGRectEqualToRect(self.maskView.frame, frame))
    {
        self.maskView.frame = frame;
    }
}
// ------------------------------------------------------------------------------------------------
- (CGFloat)getStatusBarHeight
// ------------------------------------------------------------------------------------------------
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(UIInterfaceOrientationIsLandscape(orientation))
    {
        return [UIApplication sharedApplication].statusBarFrame.size.width;
    }
    else
    {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}
// ------------------------------------------------------------------------------------------------
- (CGRect)rectInWindowBounds: (CGRect)                  windowBounds
        statusBarOrientation: (UIInterfaceOrientation)  statusBarOrientation
             statusBarHeight: (CGFloat)                 statusBarHeight
// ------------------------------------------------------------------------------------------------
{
    CGRect frame = windowBounds;
    frame.origin.x += statusBarOrientation == UIInterfaceOrientationLandscapeLeft ? statusBarHeight : 0;
    frame.origin.y += statusBarOrientation == UIInterfaceOrientationPortrait ? statusBarHeight : 0;
    frame.size.width -= UIInterfaceOrientationIsLandscape(statusBarOrientation) ? statusBarHeight : 0;
    frame.size.height -= UIInterfaceOrientationIsPortrait(statusBarOrientation) ? statusBarHeight : 0;
    return frame;
}
// ------------------------------------------------------------------------------------------------
CGFloat CNP_UIInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation)
// ------------------------------------------------------------------------------------------------
{
    CGFloat angle;

    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            break;
        default:
            angle = 0.0;
            break;
    }

    return angle;
}
// ------------------------------------------------------------------------------------------------
UIInterfaceOrientationMask UIInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation)
// ------------------------------------------------------------------------------------------------
{
    return 1 << orientation;
}


#pragma mark - Factories
// ------------------------------------------------------------------------------------------------
- (UILabel *)multilineLabelWithAttributedString:(NSAttributedString *)attributedString
// ------------------------------------------------------------------------------------------------
{
    UILabel *label = [[UILabel alloc] init];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [label setAttributedText:attributedString];
    [label setNumberOfLines:0];
    return label;
}
// ------------------------------------------------------------------------------------------------
- (UIImageView *)centeredImageViewForImage:(UIImage *)image
// ------------------------------------------------------------------------------------------------
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    return imageView;
}
// ------------------------------------------------------------------------------------------------
- (DHPopupField*) fieldItem: (DHPopupFieldItem *) item
// ------------------------------------------------------------------------------------------------
{
    DHPopupField* fieldContainer = [DHPopupField new];
    PREPCONSTRAINTS(fieldContainer);
    [fieldContainer setClipsToBounds:YES];
    fieldContainer.item = item;


    fieldContainer.textField = [UITextField new];
    PREPCONSTRAINTS(fieldContainer.textField);
    [fieldContainer.textField setSecureTextEntry:item.secureTextEntry];
    [fieldContainer.textField setFont:item.fieldTextFont];
    [fieldContainer.textField setTextColor:item.fieldTextColor];
    [fieldContainer.textField setAttributedPlaceholder:item.placeholderText];
    [fieldContainer.textField setTextAlignment:NSTextAlignmentCenter];


    fieldContainer.fieldView = [UIView new];
    PREPCONSTRAINTS(fieldContainer.fieldView);
    [fieldContainer addSubview:fieldContainer.fieldView];
    [fieldContainer.fieldView.layer setCornerRadius:item.cornerRadius];
    [fieldContainer.fieldView addSubview:fieldContainer.textField];
    [fieldContainer.fieldView.layer setBorderColor:item.borderColor.CGColor];
    [fieldContainer.fieldView.layer setBorderWidth:item.borderWidth];

    // Centers the fieldview within the bounds of the enclosing field item's view using the item's
    // specified content insets:
    [DHConstraintUtility center:fieldContainer.fieldView
                         within:fieldContainer
                     withInsets:item.fieldInsets
         withInsetsRelationRule:NSLayoutRelationEqual];

    // Centers the textfield within the fieldview:
    [DHConstraintUtility center:fieldContainer.textField
                         within:fieldContainer.fieldView
                     withInsets:UIEdgeInsetsZero
         withInsetsRelationRule:NSLayoutRelationEqual];

    // Set height
    CGFloat totalHeight = item.height + item.fieldInsets.top + item.fieldInsets.bottom;
    CONSTRAIN_HEIGHT(fieldContainer, totalHeight);

    if (!self.dataID_to_dataProvider)
    {
        self.dataID_to_dataProvider = [NSMutableDictionary new];
    }
    [self.dataID_to_dataProvider setObject:fieldContainer forKey:item.uniqueDataIdentifier];

    return fieldContainer;
}
// ------------------------------------------------------------------------------------------------
- (DHPopupTitle *)titleItem:(DHPopupTitleItem *)item
// ------------------------------------------------------------------------------------------------
{
    DHPopupTitle *label = [[DHPopupTitle alloc] init];
    PREPCONSTRAINTS(label);
    CONSTRAIN_HEIGHT(label, item.height);
    [label setAttributedTitle:item.title forState:UIControlStateNormal];
    [label setBackgroundColor:item.backgroundColor];
    [label.layer setCornerRadius:item.cornerRadius];
    [label.layer setBorderColor:item.borderColor.CGColor];
    [label.layer setBorderWidth:item.borderWidth];
    [label setUserInteractionEnabled:NO];
    label.item = item;
    return label;
}

// ------------------------------------------------------------------------------------------------
- (DHPopupFieldWithDataValidation*) fieldWithDataValidationItem: (DHPopupFieldWithDataValidationItem *) item
// ------------------------------------------------------------------------------------------------
{
    DHPopupFieldWithDataValidation* fieldContainer = [DHPopupFieldWithDataValidation new];
    PREPCONSTRAINTS(fieldContainer);
    [fieldContainer setClipsToBounds:YES];
    fieldContainer.item = item;


    fieldContainer.textField = [UITextField new];
    PREPCONSTRAINTS(fieldContainer.textField);
    [fieldContainer.textField setSecureTextEntry:item.secureTextEntry];
    [fieldContainer.textField setFont:item.fieldTextFont];
    [fieldContainer.textField setTextColor:item.fieldTextColor];
    [fieldContainer.textField setAttributedPlaceholder:item.placeholderText];
    [fieldContainer.textField setTextAlignment:item.textAlignment];


    fieldContainer.fieldView = [UIView new];
    PREPCONSTRAINTS(fieldContainer.fieldView);
    [fieldContainer addSubview:fieldContainer.fieldView];
    [fieldContainer.fieldView.layer setCornerRadius:item.cornerRadius];
    [fieldContainer.fieldView addSubview:fieldContainer.textField];
    [fieldContainer.fieldView.layer setBorderColor:item.borderColor.CGColor];
    [fieldContainer.fieldView.layer setBorderWidth:item.borderWidth];

    NSMutableArray* statusIcons = [NSMutableArray new];
    if (item.statusIconForValidData)
    {
        fieldContainer.validDataStatusIcon = item.statusIconForValidData;
        [statusIcons addObject:item.statusIconForValidData];
    }
    if (item.statusIconForInvalidData)
    {
        fieldContainer.invalidDataStatusIcon = item.statusIconForInvalidData;
        [statusIcons addObject:item.statusIconForInvalidData];
    }

    for (UIView* aStatusIcon in statusIcons)
    {
        PREPCONSTRAINTS(aStatusIcon);
        [fieldContainer.fieldView addSubview:aStatusIcon];
        aStatusIcon.hidden = YES;

        [DHConstraintUtility glue:NSLayoutAttributeTop of:aStatusIcon
                               to:NSLayoutAttributeTop of:fieldContainer.fieldView
                          withGap:item.statusIconInsets.top
                withEnclosingView:fieldContainer.fieldView];

        [DHConstraintUtility glue:NSLayoutAttributeBottom of:aStatusIcon
                               to:NSLayoutAttributeBottom of:fieldContainer.fieldView
                          withGap:item.statusIconInsets.bottom
                withEnclosingView:fieldContainer.fieldView];

        [DHConstraintUtility glue:NSLayoutAttributeRight of:aStatusIcon
                               to:NSLayoutAttributeRight of:fieldContainer.fieldView
                          withGap:item.statusIconInsets.right
                withEnclosingView:fieldContainer.fieldView];
        if (!item.textfieldRightIsConstrainedToStatusIcon)
        {
            [DHConstraintUtility glue:NSLayoutAttributeLeft of:aStatusIcon
                                   to:NSLayoutAttributeRight of:fieldContainer.textField
                              withGap:item.statusIconInsets.left
                    withEnclosingView:fieldContainer.fieldView];
        }
        CGFloat height = item.height - fabsf(item.statusIconInsets.top)  - fabsf(item.statusIconInsets.bottom);
        CGFloat width = height;
        CONSTRAIN_SIZE(aStatusIcon, height, width);
    }


    // Centers the fieldview within the bounds of the enclosing field item's view using the item's
    // specified content insets:
    [DHConstraintUtility center:fieldContainer.fieldView
                         within:fieldContainer
                     withInsets:item.fieldInsets
         withInsetsRelationRule:NSLayoutRelationEqual];

    if (statusIcons.count > 0 &&
        item.textfieldRightIsConstrainedToStatusIcon)
    {
        [DHConstraintUtility glue:NSLayoutAttributeLeft of:fieldContainer.textField
                               to:NSLayoutAttributeLeft of:fieldContainer.fieldView
                withEnclosingView:fieldContainer.fieldView];
        [DHConstraintUtility glue:NSLayoutAttributeTop of:fieldContainer.textField
                               to:NSLayoutAttributeTop of:fieldContainer.fieldView
                withEnclosingView:fieldContainer.fieldView];
        [DHConstraintUtility glue:NSLayoutAttributeBottom of:fieldContainer.textField
                               to:NSLayoutAttributeBottom of:fieldContainer.fieldView
                withEnclosingView:fieldContainer.fieldView];
    } else {
        // Centers the textfield within the fieldview:
        [DHConstraintUtility center:fieldContainer.textField
                             within:fieldContainer.fieldView
                         withInsets:item.textFieldInsets
             withInsetsRelationRule:NSLayoutRelationEqual];

    }

    // Set height
    CGFloat totalHeight = item.height + item.fieldInsets.top + item.fieldInsets.bottom;
    CONSTRAIN_HEIGHT(fieldContainer, totalHeight);

    if (!self.dataID_to_dataProvider)
    {
        self.dataID_to_dataProvider = [NSMutableDictionary new];
    }
    [self.dataID_to_dataProvider setObject:fieldContainer forKey:item.uniqueDataIdentifier];


    if (item.textValidatorForUIUpdateOnDefocus &&
        item.edgeColorForInvalidData)
    {
        [fieldContainer registerForUIUpdateOnTextFieldChange];
    }
    return fieldContainer;
}

// ------------------------------------------------------------------------------------------------
- (DHPopupDivider *)dividerItem:(DHPopupDividerItem *)item
// ------------------------------------------------------------------------------------------------
{
    DHPopupDivider *divider = [[DHPopupDivider alloc] init];
    UIView* dividerColor = [UIView new];

    dividerColor.backgroundColor = item.backgroundColor;

    [divider addSubview:dividerColor];
    [DHConstraintUtility center:dividerColor
                         within:divider
                     withInsets:item.colorInsets
         withInsetsRelationRule:NSLayoutRelationEqual];
    [dividerColor addConstraint:[NSLayoutConstraint constraintWithItem:dividerColor
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:item.height]];
    return divider;
}

// ------------------------------------------------------------------------------------------------
- (DHPopupAestheticView*) aestheticViewItem: (DHPopupAestheticViewItem *) item
// ------------------------------------------------------------------------------------------------
{
    DHPopupAestheticView* aesthetic = [DHPopupAestheticView new];
    PREPCONSTRAINTS(aesthetic);
    CONSTRAIN_HEIGHT(aesthetic, item.height);
    aesthetic.item = item;
    [aesthetic setBackgroundColor:item.backgroundColor];
    [aesthetic.layer setCornerRadius:item.cornerRadius];
    [aesthetic.layer setBorderColor:item.borderColor.CGColor];
    [aesthetic.layer setBorderWidth:item.borderWidth];

    [aesthetic addSubview:item.containedView];
    [DHConstraintUtility center:item.containedView
                         within:aesthetic
                     withInsets:item.viewInsets
         withInsetsRelationRule:NSLayoutRelationEqual];


    return aesthetic;
}

// ------------------------------------------------------------------------------------------------
- (DHPopupDisplayText*) displayTextItem: (DHPopupDisplayTextItem *) item
// ------------------------------------------------------------------------------------------------
{
    DHPopupDisplayText* displayTextContainer = [DHPopupDisplayText new];
    PREPCONSTRAINTS(displayTextContainer);
    CONSTRAIN_HEIGHT(displayTextContainer, item.height);


    displayTextContainer.textField = [UILabel new];
    PREPCONSTRAINTS(displayTextContainer.textField);
    displayTextContainer.textField.textAlignment = NSTextAlignmentCenter;
    [displayTextContainer.textField setUserInteractionEnabled:NO];
    [displayTextContainer.textField setAttributedText:item.text];
    [displayTextContainer addSubview:displayTextContainer.textField];
    [DHConstraintUtility center:displayTextContainer.textField
                         within:displayTextContainer
                     withInsets:item.displayTextInsets
         withInsetsRelationRule:NSLayoutRelationEqual];
    [displayTextContainer updateConstraints];
    [displayTextContainer layoutSubviews];
    return displayTextContainer;
}
// ------------------------------------------------------------------------------------------------
//@property (nonatomic, strong) NSAttributedString         *buttonTitle;
//@property (nonatomic, strong) UIColor                    *backgroundColor;
//@property (nonatomic, strong) UIColor                    *borderColor;
//@property (nonatomic, assign) UIEdgeInsets               subviewInsets;
//@property (nonatomic, assign) CGFloat                    borderWidth;
//@property (nonatomic, assign) CGFloat                    cornerRadius;
//@property (nonatomic, assign) CGFloat                    buttonHeight;
//@property (nonatomic, strong) NSArray                    *requiredFieldIDs;
//@property (nonatomic, strong) NSArray                    *optionalFieldIDs;
//@property (nonatomic, strong) DHPopupConfirmationItem   *confirmationItem;
//@property (nonatomic, strong) SelectionHandler           selectionHandler;
// ------------------------------------------------------------------------------------------------
- (DHPopupButton *)buttonItem:(DHPopupButtonItem *)item
// ------------------------------------------------------------------------------------------------
{
    DHPopupButton *viewButton = [DHPopupButton new];
    PREPCONSTRAINTS(viewButton);
    [viewButton setAttributedTitle:item.buttonTitle forState:UIControlStateNormal];
    [viewButton setBackgroundColor:item.buttonBackgroundColor];
    [viewButton.layer setCornerRadius:item.cornerRadius];
    [viewButton.layer setBorderColor:item.borderColor.CGColor];
    [viewButton.layer setBorderWidth:item.borderWidth];
    viewButton.item = item;


    viewButton.encapsulatingView = [UIView new];
    [viewButton.encapsulatingView setBackgroundColor:item.backgroundColor];
    PREPCONSTRAINTS(viewButton.encapsulatingView);

    [viewButton.encapsulatingView addSubview:viewButton];
    [viewButton.encapsulatingView bringSubviewToFront:viewButton];
    [DHConstraintUtility center:viewButton
                         within:viewButton.encapsulatingView
                     withInsets:item.buttonInsets
         withInsetsRelationRule:NSLayoutRelationEqual];
    CGFloat totalHeight = item.buttonHeight + item.buttonInsets.top + item.buttonInsets.bottom;
    CONSTRAIN_HEIGHT(viewButton.encapsulatingView, totalHeight);

    [viewButton addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return viewButton;
}


// ------------------------------------------------------------------------------------------------
//@property (nonatomic, strong) UIView                     *containedView;
//@property (nonatomic, assign) CGFloat                    borderWidth;
//@property (nonatomic, strong) UIColor                    *buttonBorderColor;
//@property (nonatomic, assign) CGFloat                    cornerRadius;
//@property (nonatomic, assign) CGFloat                    buttonHeight;
//@property (nonatomic, assign) UIEdgeInsets               buttonInsets;
//@property (nonatomic, assign) UIEdgeInsets               subviewInsets;
//@property (nonatomic, strong) UIColor                    *buttonBackgroundColor;
//@property (nonatomic, strong) NSArray                    *requiredFieldIDs;
//@property (nonatomic, strong) NSArray                    *optionalFieldIDs;
//@property (nonatomic, strong) SelectionHandler           selectionHandler;
// ------------------------------------------------------------------------------------------------
- (DHPopupButtonWithView*) buttonWithViewItem: (DHPopupButtonWithViewItem *) item
// ------------------------------------------------------------------------------------------------
{
    DHPopupButtonWithView* viewButton = [DHPopupButtonWithView new];
    PREPCONSTRAINTS(viewButton);
    viewButton.item = item;
    [viewButton setBackgroundColor:item.buttonBackgroundColor];
    [viewButton.layer setCornerRadius:item.cornerRadius];
    [viewButton.layer setBorderColor:item.borderColor.CGColor];
    [viewButton.layer setBorderWidth:item.borderWidth];

    // Add and center the view to be contained within the button, to the buttons view
    PREPCONSTRAINTS(item.containedView);
    [viewButton addSubview:item.containedView];
    CENTER_VIEW(viewButton, item.containedView);

    [item.containedView setUserInteractionEnabled:NO];

    UIView* encapView = [UIView new];
    viewButton.encapsulatingView = encapView;
    PREPCONSTRAINTS(viewButton.encapsulatingView);

    [encapView setBackgroundColor:item.backgroundColor];

    [viewButton.encapsulatingView addSubview:viewButton];
    [DHConstraintUtility center:viewButton
                         within:viewButton.encapsulatingView
                     withInsets:item.buttonInsets
         withInsetsRelationRule:NSLayoutRelationEqual];


    CONSTRAIN_HEIGHT(viewButton.encapsulatingView, item.buttonHeight);

    [viewButton addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    return viewButton;
}

/*
 @property (nonatomic, strong) NSAttributedString *confirmationTitle;
 @property (nonatomic, strong) NSAttributedString *confirmButtonTitle;
 @property (nonatomic, strong) NSAttributedString *cancelButtonTitle;
 @property (nonatomic, strong) UIColor            *backgroundColor;
 @property (nonatomic, strong) UIColor            *borderColor;
 @property (nonatomic, assign) CGFloat            borderWidth;
 @property (nonatomic, assign) CGFloat            cornerRadius;
 @property (nonatomic, assign) CGFloat            buttonHeight;
 @property (nonatomic, assign) CNPPopupConfirmationButtonStyle buttonAlignmentStyle;
 */
// ------------------------------------------------------------------------------------------------
- (DHPopupConfirmation*)confirmationItem:(DHPopupConfirmationItem *) item
// ------------------------------------------------------------------------------------------------
{
    DHPopupConfirmation* confirmation = [DHPopupConfirmation new];

    [confirmation setTranslatesAutoresizingMaskIntoConstraints:NO];
    confirmation.clipsToBounds = YES;

    UILabel* title = [self multilineLabelWithAttributedString:item.confirmationTitle];
    [title setTextAlignment:NSTextAlignmentCenter];
    [confirmation addSubview:title];

    // Create the accept button design from the given confirmation-view-design-theme:
    DHPopupButtonItem * acceptItem = [DHPopupButtonItem new];
    acceptItem.buttonTitle         = item.confirmButtonTitle;
    acceptItem.backgroundColor     = item.backgroundColor;
    acceptItem.borderColor         = item.borderColor;
    acceptItem.cornerRadius        = item.cornerRadius;
    acceptItem.buttonHeight        = item.buttonHeight;
    acceptItem.selectionHandler    = item.selectionHandler;
    // Call the factory method to use the above-made design to make the accept button:
    DHPopupButton* acceptButton = [self buttonItem:acceptItem];
    // Add the accept button to our confirmation view:
    [confirmation addSubview:acceptButton];
    // Set the responding method for accept-button-presses:
    [acceptButton addTarget:self action:@selector(acceptButtonPressed:) forControlEvents:UIControlEventTouchUpInside];


    // Create the accept button design from the given confirmation-view-design-theme:
    DHPopupButtonItem * cancelItem = [DHPopupButtonItem new];
    cancelItem.buttonTitle         = item.cancelButtonTitle;
    cancelItem.backgroundColor     = item.backgroundColor;
    cancelItem.borderColor         = item.borderColor;
    cancelItem.cornerRadius        = item.cornerRadius;
    cancelItem.buttonHeight        = item.buttonHeight;
    // Call the factory method to use the above-made design to make the cancel button:
    DHPopupButton* cancelButton = [self buttonItem:cancelItem];
    // Add the cancel button to our confirmation view:
    [confirmation addSubview:cancelButton];
    // Set the responding method for accept-button-presses:
    [cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];


    //  CONSTRAINTS:
    // Align title top to enclosing view top.
    [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:title
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:confirmation
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:0]];
    // Align the title's left edge to the enclosing view's left edge.
    [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:title
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:confirmation
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.0
                                                              constant:0]];
    // Align the title's center x to the enclosing view's center x.
    [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:title
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:confirmation
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:0]];
    // set the accept button height.
    [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:acceptButton
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:item.buttonHeight]];
    // set the cancel button height.
    [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:item.buttonHeight]];

    switch (item.buttonAlignmentStyle)
    {
            // For buttons beside eachother (horizontally)
        case DHPopupConfirmationButtonStyleInline:
            // Align accept button top to title bottom.
            [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:acceptButton
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:title
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:item.titleToButtonSpacer]];
            // Align cancel button top to title bottom.
            [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:title
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:item.titleToButtonSpacer]];
            // Set the horizontal alignment of the buttons.
            [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:acceptButton
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:confirmation
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:(item.interButtonSpacer/2)]];
            // Set the horizontal alignment of the buttons.
            [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:confirmation
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:(item.interButtonSpacer/2)]];
            // Align the bottom of the accept button to the enclosing view's bottom.
            [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:acceptButton
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:confirmation
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:0]];
            // Align the bottom of the accept button to the enclosing view's bottom.
            [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:acceptButton
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:confirmation
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:0]];

            // Align the bottom of the accept button to the enclosing view's bottom.
            [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:confirmation
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:0]];

            // Align the bottom of the accept button to the enclosing view's bottom.
            [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:acceptButton
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:cancelButton
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.0
                                                                      constant:0]];

            for (UIView* view in @[title, acceptButton, cancelButton])
            { // Set the content hugging/compression priorities for the buttons and title.
                [view setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
                [view setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
                [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
                [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
            }
            break;

            // For buttons above/below eachother (vertically consecutive).
        case DHPopupConfirmationButtonStyleConsecutive:
        default:

            // Align accept button top to title bottom.
            [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:acceptButton
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:title
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:item.titleToButtonSpacer]];
            // Align cancel button top to title bottom.
            [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:acceptButton
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:item.interButtonSpacer]];
            // Set the horizontal alignment of the buttons.
            [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:acceptButton
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:confirmation
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:0]];
            // Set the horizontal alignment of the buttons.
            [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:confirmation
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:0]];

            // Align the bottom of the accept button to the enclosing view's bottom.
            [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:confirmation
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:0]];

            [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:acceptButton
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:confirmation
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.0
                                                                      constant:0]];
            [confirmation addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:confirmation
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.0
                                                                      constant:0]];

            for (UIView* view in @[title, acceptButton, cancelButton])
            { // Set the content hugging/compression priorities for the buttons and title.
                [view setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
                [view setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
                [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
                [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
            }
            break;
    }
    return confirmation;
}

// ------------------------------------------------------------------------------------------------
- (DHPopupSecondMenu*)secondMenuItem: (DHPopupSecondMenuItem *) item
// ------------------------------------------------------------------------------------------------
{
    // Safety checks
    if (item.buttonItems) {
        for (id object in item.buttonItems) {
            NSAssert([object class] == [DHPopupButtonItem class],@"Button items can only be of DHPopupButtonItem.");
        }
    }

    DHPopupSecondMenu* secondMenu = [DHPopupSecondMenu new];
    [secondMenu setTranslatesAutoresizingMaskIntoConstraints:NO];
    secondMenu.clipsToBounds      = YES;
    secondMenu.item               = item;
    secondMenu.backgroundColor    = item.backgroundColor;
    secondMenu.layer.cornerRadius = item.cornerRadius;

    // Create the buttons from the template items and add them to our second menu view.
    if (item.buttonItems) {
        for (DHPopupButtonItem *buttonItem in item.buttonItems) {
            DHPopupButton *button = [self buttonItem:buttonItem];
            [secondMenu addSubview:button];
        }
    }


    [secondMenu.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [secondMenu addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:secondMenu
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:item.popupContentInsets.top]];
        }
        else {
            UIView *previousSubView = [secondMenu.subviews objectAtIndex:idx - 1];
            if (previousSubView) {
                [secondMenu addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:previousSubView
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0
                                                                        constant:item.contentVerticalPadding]];
            }
        }

        if (idx == secondMenu.subviews.count - 1) {

            [secondMenu addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:secondMenu
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:-(item.popupContentInsets.bottom)]];
        }

        if ([view isKindOfClass:[UIButton class]]) {
            DHPopupButton *button = (DHPopupButton *)view;
            [secondMenu addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:button.item.buttonHeight]];
            [button addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }

        [view setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
        [view setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

        if ([view isKindOfClass:[UIImageView class]]) {
            [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
            [view setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        }
        else {
            [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
            [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
        }
        [secondMenu addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:secondMenu
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1.0
                                                                constant:item.popupContentInsets.left]];
        [secondMenu addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeRight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:secondMenu
                                                               attribute:NSLayoutAttributeRight
                                                              multiplier:1.0
                                                                constant:-item.popupContentInsets.right]];
    }];
    return secondMenu;
}
// ------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------
@end
// ------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------


#pragma mark - CNPPopupAestheticViewItem
@implementation DHPopupAestheticViewItem

@end

#pragma mark - CNPPopupAestheticView
@implementation DHPopupAestheticView

@end


#pragma mark - CNPPopupConfirmation Methods

@implementation DHPopupConfirmation

@end

#pragma mark - DHPopupConfirmationItem Methods

@implementation DHPopupConfirmationItem

@end



#pragma mark - CNPPopupSecondMenu Methods

@implementation DHPopupSecondMenu

@end

#pragma mark - CNPPopupSecondMenuItem Methods

@implementation DHPopupSecondMenuItem

@end




#pragma mark - CNPPopupTitle Methods

@implementation DHPopupTitle

@end

#pragma mark - CNPPopupTitleItem Methods

@implementation DHPopupTitleItem

@end




#pragma mark - CNPPopupDividerItem Methods

@implementation DHPopupDividerItem

@end

#pragma mark - CNPPopupDivider Methods

@implementation DHPopupDivider

@end




#pragma mark - CNPPopupFieldItem Methods

@implementation DHPopupFieldItem

@end

#pragma mark - CNPPopupField Methods

@implementation DHPopupField
// ------------------------------------------------------------------------------------------------
- (NSObject*) getCurrentData
// ------------------------------------------------------------------------------------------------
{
    NSString* currentText = self.textField.text;
    return currentText;
}

// ------------------------------------------------------------------------------------------------
- (BOOL) checkIfDataIsValid
// ------------------------------------------------------------------------------------------------
{
    if (self.item.validationHandler)
    {
        return self.item.validationHandler([self getCurrentData]);
    } else
    { // If this field is being asked to validate itself and there is no handler to do so,
      // return NO as we can't validate our data.
        return NO;
    }
}

// ------------------------------------------------------------------------------------------------
- (void) notifyThatDataIsInvalidWithReason:(NSString *)aReason
// ------------------------------------------------------------------------------------------------
{
    // doesn't matter
}
@end

#pragma mark - DHPopupFieldWithDataValidationItem
@implementation DHPopupFieldWithDataValidationItem
@end

#pragma mark - DHPopupFieldWithDataValidation
@implementation DHPopupFieldWithDataValidation
// ------------------------------------------------------------------------------------------------
- (NSObject*) getCurrentData
// ------------------------------------------------------------------------------------------------
{
    NSString* currentText = self.textField.text;
    return currentText;
}

// ------------------------------------------------------------------------------------------------
- (BOOL) checkIfDataIsValid
// ------------------------------------------------------------------------------------------------
{
    if (self.item.validationHandler)
    {
        return self.item.validationHandler([self getCurrentData]);
    } else
    { // If this field is being asked to validate itself and there is no handler to do so,
        // its valid by default.
        return NO;
    }
}

// ------------------------------------------------------------------------------------------------
- (void) notifyThatDataIsInvalidWithReason:(NSString *)aReason
// ------------------------------------------------------------------------------------------------
{
    [self setUIForDataValidityStatus:NO];
}

// ------------------------------------------------------------------------------------------------
- (void) registerForUIUpdateOnTextFieldChange
// ------------------------------------------------------------------------------------------------
{
    [self.textField setDelegate:self];
}

// ------------------------------------------------------------------------------------------------
- (void) setUIForDataValidityStatus: (BOOL) isValid
// ------------------------------------------------------------------------------------------------
{
    if (!isValid)
    {
        // Border color
        if (self.item.edgeColorForInvalidData && self.item.animateDataValidityUIUpdates)
        {
            if (!self.dataIsValid)
            { // if border color is already invalid color
                [UIView animateWithDuration:2
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     [self.fieldView.layer setBorderColor:self.item.edgeColorForValidData.CGColor];
                                 }
                                 completion:^(BOOL finished) {
                                     [UIView animateWithDuration:2
                                                           delay:0
                                                         options:UIViewAnimationOptionCurveLinear
                                                      animations:^{
                                                          [self.fieldView.layer setBorderColor:self.item.edgeColorForInvalidData.CGColor];
                                                      }
                                                      completion:nil];
                                 }];
            } else
            {
                [UIView animateWithDuration:10
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     [self.fieldView.layer setBorderColor:self.item.edgeColorForInvalidData.CGColor];
                                 }
                                 completion:nil];
            }

        } else if (self.item.edgeColorForInvalidData) {
            [self.fieldView.layer setBorderColor:self.item.edgeColorForInvalidData.CGColor];
        }

        // Status Icons
        if (self.validDataStatusIcon && self.validDataStatusIcon.hidden == NO)
        {
            self.validDataStatusIcon.hidden = YES;
        }
        if (self.invalidDataStatusIcon && self.invalidDataStatusIcon.hidden == YES)
        {
            self.invalidDataStatusIcon.hidden = NO;
        }

    } else {
        // Border color
        if (self.item.edgeColorForValidData && self.item.animateDataValidityUIUpdates)
        {
            if (self.dataIsValid)
            { // if border color is already  valid color
                [UIView animateWithDuration:2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{

                                     [self.fieldView.layer setBorderColor:self.item.edgeColorForInvalidData.CGColor];
                                 }
                                 completion:^(BOOL finished) {
                                     [UIView animateWithDuration:2
                                                           delay:0
                                                         options:UIViewAnimationOptionCurveEaseInOut
                                                      animations:^{
                                                          [self.fieldView.layer setBorderColor:self.item.edgeColorForValidData.CGColor];
                                                      }
                                                      completion:nil];
                                 }];
            } else
            {
                [UIView animateWithDuration:2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     [self.fieldView.layer setBorderColor:self.item.edgeColorForValidData.CGColor];
                                 }
                                 completion:nil];
            }

        } else if (self.item.edgeColorForInvalidData) {
            [self.fieldView.layer setBorderColor:self.item.edgeColorForValidData.CGColor];
        }

        // Status Icons
        if (self.validDataStatusIcon && self.validDataStatusIcon.hidden == YES)
        {
            self.validDataStatusIcon.hidden = NO;
        }
        if (self.invalidDataStatusIcon && self.invalidDataStatusIcon.hidden == NO)
        {
            self.invalidDataStatusIcon.hidden = YES;
        }
    }
}

// ------------------------------------------------------------------------------------------------
- (void) textFieldDidBeginEditing:(UITextField *)textField
// ------------------------------------------------------------------------------------------------
{
    [self.fieldView.layer setBorderColor:self.item.borderColor.CGColor];
    self.dataIsValid = NO;
    if (self.validDataStatusIcon && self.validDataStatusIcon.hidden == NO)
    {
        self.validDataStatusIcon.hidden = YES;
    }
    if (self.invalidDataStatusIcon && self.invalidDataStatusIcon.hidden == NO)
    {
        self.invalidDataStatusIcon.hidden = YES;
    }
}
// ------------------------------------------------------------------------------------------------
- (void) textFieldDidEndEditing:(UITextField *)textField
// ------------------------------------------------------------------------------------------------
{
    if (textField.text &&
        !self.item.textValidatorForUIUpdateOnDefocus(textField.text))
    {
        [self setUIForDataValidityStatus:NO];
        self.dataIsValid = NO;
    }
    else if (textField.text &&
             self.item.textValidatorForUIUpdateOnDefocus(textField.text))
    {
        [self setUIForDataValidityStatus:YES];
        self.dataIsValid = YES;
    }
}

@end


#pragma mark - CNPPopupBaseButtonItem Methods

@implementation DHPopupBaseButtonItem
@end

#pragma mark - CNPPopupBaseButton Methods

@implementation DHPopupBaseButton
@end




#pragma mark - CNPPopupBodyItem Methods

@implementation DHPopupBodyItem
@end




#pragma mark - CNPPopupDisplayTextItem Methods

@implementation DHPopupDisplayTextItem

@end

#pragma mark - CNPPopupDisplayText Methods

@implementation DHPopupDisplayText

@end

#pragma mark - DHPopupDataProviderItem
@implementation DHPopupDataProviderItem
@end

#pragma mark - DHPopupAestheticItem
@implementation DHPopupAestheticItem

@end

#pragma mark - DHPopupActionItem
@implementation DHPopupActionItem

@end


#pragma mark - CNPPopupButtonWithViewItem Methods

@implementation DHPopupButtonWithViewItem

@end



#pragma mark - CNPPopupButtonWithView Methods

@implementation DHPopupButtonWithView

@end


#pragma mark - CNPPopupButton Methods

@implementation DHPopupButton

@end

#pragma mark - CNPPopupButtonItem Methods

@implementation DHPopupButtonItem
// ------------------------------------------------------------------------------------------------
+ (DHPopupButtonItem *)defaultButtonItemWithTitle:(NSAttributedString *)title
                                   backgroundColor:(UIColor *)color
// ------------------------------------------------------------------------------------------------
{
    DHPopupButtonItem *item = [[DHPopupButtonItem alloc] init];
    item.buttonTitle         = title;
    item.cornerRadius        = 3;
    item.backgroundColor     = color;
    item.buttonHeight        = 50;
    return item;
}

@end

@implementation DHPopupTheme
// ------------------------------------------------------------------------------------------------
+ (DHPopupTheme *)defaultTheme
// ------------------------------------------------------------------------------------------------
{
    DHPopupTheme *defaultTheme                 = [[DHPopupTheme alloc] init];
    defaultTheme.backgroundColor                = [UIColor whiteColor];
    defaultTheme.cornerRadius                   = 6.0f;
    defaultTheme.popupContentInsets             = UIEdgeInsetsMake(16.0f, 16.0f, 16.0f, 16.0f);
    defaultTheme.popupStyle                     = DHPopupStyleCentered;
    defaultTheme.presentationStyle              = DHPopupPresentationStyleSlideInFromBottom;
    defaultTheme.dismissesOppositeDirection     = NO;
    defaultTheme.maskType                       = DHPopupMaskTypeDimmed;
    defaultTheme.shouldDismissOnBackgroundTouch = YES;
    defaultTheme.contentVerticalPadding         = 12.0f;
    return defaultTheme;
}

@end
