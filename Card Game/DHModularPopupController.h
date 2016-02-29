//
//  DHPopupController.h
//  DHPopupController
//
//  Created, documented and heavily expanded by Daniel Holmes in Fall 2014.
//

#import <UIKit/UIKit.h>
#import "PMValidationManager.h"


@protocol DHPopupControllerDelegate, DHPopupDataProviderItemProtocol;
@class DHPopupTheme, DHPopupButtonItem, DHPopupBaseButtonItem, DHPopupBodyItem, DHPopupTitleItem, DHPopupDividerItem, DHPopupButtonWithViewItem, DHPopupFieldItem, DHPopupDisplayTextItem, DHPopupConfirmationItem, DHPopupSecondMenuItem, DHPopupBodyItem;

// ------------------------------------------------------------------------------------------------
#pragma mark - Constants / Enums
// ------------------------------------------------------------------------------------------------


/**
 *  The windowing style for the popup (ie. Fullscreen, Actionsheet, Centered)
 */
typedef NS_ENUM(NSUInteger, DHPopupStyle){
    /**
     *  Displays the popup similar to an action sheet from the bottom.
     */
    DHPopupStyleActionSheet = 0,
    /**
     *  Displays the popup in the center of the screen.
     */
    DHPopupStyleCentered,
    /**
     *  Displays the popup similar to a fullscreen viewcontroller.
     */
    DHPopupStyleFullscreen
};

/**
 *  Controls how the popup is presented
 */
typedef NS_ENUM(NSInteger, DHPopupPresentationStyle) {
    DHPopupPresentationStyleFadeIn = 0,
    DHPopupPresentationStyleSlideInFromTop,
    DHPopupPresentationStyleSlideInFromBottom,
    DHPopupPresentationStyleSlideInFromLeft,
    DHPopupPresentationStyleSlideInFromRight
};

/**
 *  The MaskType defines how the surrounding background around the popup window(s) and element(s)
 *  will look.
 */
typedef NS_ENUM(NSInteger, DHPopupMaskType){
    /**
     *  A default value that currently
     */
    DHPopupMaskTypeNone = 0,
    /**
     *  The background will be clear colored and the view showing prior to the popup being
     *  present will show clearly (ie. no dimming).
     */
    DHPopupMaskTypeClear,
    /**
     *  The background will be 'dimmed' slightly, that is, it will be shaded grey but will still
     *  show the view showing prior to the popup being presented.
     */
    DHPopupMaskTypeDimmed,
};


/**
 *  Defines how the Confirmation's Accept/Cancel buttons are aligned.
 */
typedef NS_ENUM(NSInteger, DHPopupConfirmationButtonStyle){
    /**
     *  Both on same line
     */
    DHPopupConfirmationButtonStyleInline = 0,
    /**
     *  On different lines
     */
    DHPopupConfirmationButtonStyleConsecutive
};

/**
 *  Defines the origin against which the popup is aligned to, plus-or-minus the given vertical offset.
 */
typedef NS_ENUM(NSInteger, DHVerticalAlignmentStyle){
    /**
     *  The popup will align to the center of the screen, plus-or-minus vertical offset.
     */
    DHVerticalAlignmentStyle_ToScreenCenter = 0,
    /**
     *  The popup will align to the top of the screen, plus-or-minus vertical offset.
     */
    DHVerticalAlignmentStyle_ToScreenTop
};


// ------------------------------------------------------------------------------------------------
#pragma mark - Function Typedefs
// ------------------------------------------------------------------------------------------------
typedef void(^ValidationWaitHandler) (DHPopupBaseButtonItem *item); // unused currently


typedef void(^SelectionHandler) (DHPopupBaseButtonItem *item,
                                 NSDictionary* requiredData);

typedef void(^RunOnCompletion)(BOOL             dismissPopup,
                               BOOL             dismissLoadingView,
                               NSDictionary*    errorsForDataIDs);

typedef void(^FormValidationHandler) (DHPopupBaseButtonItem *item,
                                      NSDictionary*         optionalData,
                                      NSDictionary*         requiredData,
                                      RunOnCompletion       runOnCompletion);



// ------------------------------------------------------------------------------------------------
/**
 *  The main popup controller. Holds references to all UI items contained therein and the logic
 *  necessary to create, customize, and provide functionality to the popup.
 */
@interface DHModularPopupController : UIViewController <UIGestureRecognizerDelegate>
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) DHPopupTitleItem        *popupTitleItem;
@property (nonatomic, strong) DHPopupConfirmationItem *confirmationMsgItem;
@property (nonatomic, strong) DHPopupSecondMenuItem   *popupSecondaryMenuItem;
@property (nonatomic, strong) NSMutableArray          *ordered_body_contents;
@property (nonatomic, strong) NSMutableDictionary     *dataID_to_dataProvider;
@property (nonatomic, strong) DHPopupTheme            *theme;
@property (nonatomic, strong) UIWindow                *applicationKeyWindow;

@property (nonatomic, weak) id <DHPopupControllerDelegate> delegate;

- (instancetype) initWithTitleItem:(DHPopupTitleItem *) popupTitle
                         keyWindow:(UIWindow*)          keyWindow
                             theme:(DHPopupTheme *)     aTheme;
- (void) addBodyItem: (DHPopupBodyItem *) bodyItem;
- (void) addSecondaryWindow: (DHPopupSecondMenuItem *) secondMenuItem;

- (void)presentPopupControllerAnimated:(BOOL)flag;
- (void)dismissPopupControllerAnimated:(BOOL)flag;

@end

#pragma mark - STYLE_SHEET: PopupTheme
// ------------------------------------------------------------------------------------------------
/**
 *  This is a theme definition that defines essential UI properties used throughout the popup and
 *  on the popup windows. It is required for creation of a popupController.
 */
@interface DHPopupTheme : NSObject
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) UIColor                   *backgroundColor;// Background color of the popup content view (Default white)
@property (nonatomic, assign) CGFloat                   cornerRadius;// Corner radius of the popup content view (Default 6.0)
@property (nonatomic, assign) UIEdgeInsets              popupContentInsets;// Inset of labels, images and buttons on the popup content view (Default 16.0 on all sides)
@property (nonatomic, assign) DHPopupStyle              popupStyle;// How the popup looks once presented (Default centered)
@property (nonatomic, assign) DHPopupPresentationStyle  presentationStyle;// How the popup is presented (Defauly slide in from bottom)
@property (nonatomic, assign) DHVerticalAlignmentStyle  verticalAlignmentStyle;
@property (nonatomic, assign) BOOL                      dismissesOppositeDirection;// If presented from a direction, should it dismiss in the opposite? (Defaults to NO. i.e. Goes back the way it came in)
@property (nonatomic, assign) DHPopupMaskType           maskType;// Backgound mask of the popup (Default dimmed)
@property (nonatomic, assign) BOOL                      shouldDismissOnBackgroundTouch;// Popup should dismiss on tapping on background mask (Default yes)
@property (nonatomic, assign) CGFloat                   contentVerticalPadding;// Spacing between each vertical element (Default 12.0)
@property (nonatomic, assign) CGFloat                   preferredWidth;// Preferred width for the popup
@property (nonatomic, assign) CGFloat                   centerYOffset;
// Factory method to help build a default theme
+ (DHPopupTheme *)defaultTheme;

@end

#pragma mark - PopupController Delegate
// ------------------------------------------------------------------------------------------------
/**
 *  This protocol defines the optional methods that a PopupControllerDelegate can define that will
 *  be called on event of the specified action for each method. Defining a PopupControllerDelegate
 *  is optional and is usually anticipated to be the viewController that originally created the popup.
 */
@protocol DHPopupControllerDelegate <NSObject>
// ------------------------------------------------------------------------------------------------
@optional
- (void)popupControllerWillPresent:(DHModularPopupController *)controller;
- (void)popupControllerDidPresent:(DHModularPopupController *)controller;
- (void)popupController:(DHModularPopupController *)controller willDismissWithButtonIdentifier:(NSString *)anIdentifier;
- (void)popupController:(DHModularPopupController *)controller didDismissWithButtonIdentifier:(NSString *)anIdentifier;

@end



#pragma mark - Body Item Abstract
// ------------------------------------------------------------------------------------------------
/**
 *  The generic ancestor of all UI items that can be added to the popup inherit from. An 'item'
 *  is a template with filled-in values that define the neccessary variables to make the
 *  corresponding UI item. Essentially, its a 'recipe' for a UI item, which the PopupController
 *  uses to create that item.
 */
@interface DHPopupBodyItem : NSObject
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat height;
@end


#pragma mark - Data Provider Abstract and Protocol
// ------------------------------------------------------------------------------------------------
/**
 *  A DataProvider is a UI item that can be added to the body of a popup window that allows for user
 *  interaction and thus creation of user-inputted-data. Some possible examples are textfields,
 *  checkboxes, sliders, etc. This protocol defines the method that all DataProviders must implement
 *  that returns a data object containing the user-inputted data. This method on a DataProvider is
 *  called when a button that has 'required' the data from that specific DataProvider has been pressed.
 *  For further information please see the full documentation detailing how User-Inputted Data is
 *  handled in Popups.
 */
@protocol DHPopupDataProviderItemProtocol <NSObject>
// ------------------------------------------------------------------------------------------------
@required
- (NSObject*) getCurrentData;
- (BOOL) checkIfDataIsValid;
- (void) notifyThatDataIsInvalidWithReason: (NSString*) aReason;
@end

typedef BOOL(^ValidationHandler)(NSObject* data);
// ------------------------------------------------------------------------------------------------
@interface DHPopupDataProviderItem : DHPopupBodyItem
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) NSString                   *uniqueDataIdentifier;
@property (nonatomic, strong) ValidationHandler          validationHandler;
@end

#pragma mark - Aesthetic Item Abstract
// ------------------------------------------------------------------------------------------------
@interface DHPopupAestheticItem : DHPopupBodyItem
// ------------------------------------------------------------------------------------------------

@end



#pragma mark - Action Item Abstract
// ------------------------------------------------------------------------------------------------
@interface DHPopupActionItem : DHPopupBodyItem
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) SelectionHandler           selectionHandler;
@property (nonatomic, strong) FormValidationHandler      formValidationHandler;
@property (nonatomic, strong) NSString                   *identifier;
@property (nonatomic, strong) NSArray                    *includeDataWithIDs;
@property (nonatomic, strong) NSArray                    *requiredValidatedDataWithIDs;
@end




#pragma mark - AESTHETIC_ITEM:TitleItem
// ------------------------------------------------------------------------------------------------
/**
 *  A popup item intended to be the title of a individual popup window. One per popup window,
 *  located at the very top of the window.
 *
 *  An 'item'
 *  is a template with filled-in values that define the neccessary variables to make the
 *  corresponding UI item. Essentially, its a 'recipe' for a UI item, which the PopupController
 *  uses to create that item.
 */
@interface DHPopupTitleItem : DHPopupAestheticItem
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) NSAttributedString *title;
@property (nonatomic, assign) UIEdgeInsets       titleInsets;
@end


#pragma mark - AESTHETIC_ITEM:AestheticViewItem
// ------------------------------------------------------------------------------------------------
/**
 *  A popup item intended to be for aesthetic purposes only. For example, something you want to show
 *  within the popup that is more specific than the aesthetic popup items allow - like a view that
 *  contains a custom mix of subviews.
 *
 *  An 'item'
 *  is a template with filled-in values that define the neccessary variables to make the
 *  corresponding UI item. Essentially, its a 'recipe' for a UI item, which the PopupController
 *  uses to create that item.
 */
@interface DHPopupAestheticViewItem : DHPopupBodyItem
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) UIView             *containedView;
@property (nonatomic, assign) UIEdgeInsets       viewInsets;
@end


#pragma mark - AESTHETIC_ITEM:DividerItem
// ------------------------------------------------------------------------------------------------
/**
 *  A popup item intended to be a simple horizontal divider, typically one or two pixels thick.
 *
 *  An 'item'
 *  is a template with filled-in values that define the neccessary variables to make the
 *  corresponding UI item. Essentially, its a 'recipe' for a UI item, which the PopupController
 *  uses to create that item.
 */
@interface DHPopupDividerItem : DHPopupBodyItem
// ------------------------------------------------------------------------------------------------
@property (nonatomic, assign) UIEdgeInsets       colorInsets;
@end


#pragma mark - AESTHETIC_ITEM: DisplayTextItem
// ------------------------------------------------------------------------------------------------
/**
 *  A popup item intended for some formatted, non-interactive text to display like a header,
 *  description or explanation.
 */
@interface DHPopupDisplayTextItem : DHPopupBodyItem
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) NSAttributedString         *text;
@property (nonatomic, assign) UIEdgeInsets                displayTextInsets;
@end

#pragma mark - DATA_ITEM: FieldItem
// ------------------------------------------------------------------------------------------------
/**
 *  A popup item intended for some data input, like for creating an account registration
 *  popup. Must have a unique string identifier for the data/field that will be used to identify
 *  it as required/optional data for a specified buttonitem, and to identify the data within the
 *  dictionary passed to said buttonitem's designated responder method.
 */
@interface DHPopupFieldItem : DHPopupDataProviderItem
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) NSAttributedString         *placeholderText;
@property (nonatomic, assign) BOOL                        secureTextEntry;
@property (nonatomic, assign) UIEdgeInsets                fieldInsets;
@property (nonatomic, strong) UIColor                    *fieldTextColor;
@property (nonatomic, strong) UIFont                     *fieldTextFont;
@end

#pragma mark - DATA_ITEM: FieldItem With Validation
typedef BOOL(^StringValidationHandler)(NSString* data);
// ------------------------------------------------------------------------------------------------
@interface DHPopupFieldWithDataValidationItem : DHPopupFieldItem
// ------------------------------------------------------------------------------------------------
@property (nonatomic)         NSTextAlignment            textAlignment;        // default is NSCenterTextAlignment
@property (nonatomic, strong) UIColor                    *edgeColorForValidData;
@property (nonatomic, strong) UIColor                    *edgeColorForInvalidData;
@property (nonatomic, strong) UIView                     *statusIconForValidData;
@property (nonatomic, strong) UIView                     *statusIconForInvalidData;
@property (nonatomic, assign) UIEdgeInsets                textFieldInsets;
@property (nonatomic, assign) UIEdgeInsets                statusIconInsets;
@property (nonatomic, strong) StringValidationHandler     textValidatorForUIUpdateOnDefocus;
@property (nonatomic, assign) BOOL                        textfieldRightIsConstrainedToStatusIcon;
@property (nonatomic, assign) BOOL                        animateDataValidityUIUpdates;
@end



#pragma mark - ACTION_ITEM: Button Item Base Template
// ------------------------------------------------------------------------------------------------
/**
 *  The generic abstraction of a popup button from which all popup buttons inherit from. It holds
 *  the common properties with which all buttons are constructed using.
 *
 *  An 'item' is a template with filled-in values that define the neccessary variables to make the
 *  corresponding UI item. Essentially, its a 'recipe' for a UI item, which the PopupController
 *  uses to create that item.
 */
@interface DHPopupBaseButtonItem : DHPopupActionItem
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) DHPopupConfirmationItem *confirmationItem;
@property (nonatomic, assign) CGFloat                    buttonHeight;
@property (nonatomic, strong) UIColor                    *buttonBackgroundColor;
@property (nonatomic, assign) UIEdgeInsets               buttonInsets;
@property (nonatomic, assign) UIEdgeInsets               subviewInsets;
@end


#pragma mark - ACTION_ITEM: ButtonWithViewItem
// ------------------------------------------------------------------------------------------------
/**
 *  A popup button that uses a predefined, specified view to display instead of generating a view
 *  from strings, colors and values. Useful for button designs that aren't able to be made with the
 *  normal buttonItem (ex. very specific, custom designs).
 *
 *  An 'item' is a template with filled-in values that define the neccessary variables to make the
 *  corresponding UI item. Essentially, its a 'recipe' for a UI item, which the PopupController
 *  uses to create that item.
 */
@interface DHPopupButtonWithViewItem : DHPopupBaseButtonItem
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) UIView                     *containedView;
@end


#pragma mark - ACTION_ITEM: ButtonItem
// ------------------------------------------------------------------------------------------------
/**
 *  A popup item intended to be used as a simple button by passing in values for the various UI
 *  parameters.
 *
 *  An 'item' is a template with filled-in values that define the neccessary variables to make the
 *  corresponding UI item. Essentially, its a 'recipe' for a UI item, which the PopupController
 *  uses to create that item.
 */
@interface DHPopupButtonItem : DHPopupBaseButtonItem
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) NSAttributedString         *buttonTitle;

+ (DHPopupButtonItem *)defaultButtonItemWithTitle:(NSAttributedString *)title backgroundColor:(UIColor *)color;

@end




#pragma mark - ConfirmationItem
// ------------------------------------------------------------------------------------------------
/**
 *  This is an item attached to a button that defines a view that will be shown upon press of that
 *  button. It is intended to act as a confirmation that the user indeed wants to perform the action
 *  that the button will cause. For example, a button to delete something important might need
 *  a confirmation before deletion.
 *
 *  An 'item' is a template with filled-in values that define the neccessary variables to make the
 *  corresponding UI item. Essentially, its a 'recipe' for a UI item, which the PopupController
 *  uses to create that item.
 */
@interface DHPopupConfirmationItem : DHPopupBodyItem
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) NSAttributedString *confirmationTitle;
@property (nonatomic, strong) NSAttributedString *confirmButtonTitle;
@property (nonatomic, strong) NSAttributedString *cancelButtonTitle;
@property (nonatomic, strong) UIColor            *backgroundColor;
@property (nonatomic, strong) UIColor            *borderColor;
@property (nonatomic, assign) CGFloat            verticalOffset;
@property (nonatomic, assign) CGFloat            borderWidth;
@property (nonatomic, assign) CGFloat            cornerRadius;
@property (nonatomic, assign) CGFloat            buttonHeight;
@property (nonatomic, assign) CGFloat            interButtonSpacer;
@property (nonatomic, assign) CGFloat            titleToButtonSpacer;
@property (nonatomic, strong) SelectionHandler   selectionHandler;
@property (nonatomic, assign) DHPopupConfirmationButtonStyle buttonAlignmentStyle;

@end




#pragma mark - SecondMenuItem
// ------------------------------------------------------------------------------------------------
/**
 *  This is a second popup window shown below the main popup window. This is useful for having two
 *  distinct popup windows showing at the same time. Currently it does not have the full customization
 *  capabilities that the main popup window does, instead allowing for only some buttons.
 */
@interface DHPopupSecondMenuItem : DHPopupBodyItem
// ------------------------------------------------------------------------------------------------
@property (nonatomic, strong) NSArray          * buttonItems;
@property (nonatomic, strong) SelectionHandler selectionHandler;
@property (nonatomic, strong) UIColor          *backgroundColor;// Background color of the popup content view (Default white)
@property (nonatomic, assign) CGFloat          cornerRadius;// Corner radius of the popup content view (Default 6.0)
@property (nonatomic, assign) UIEdgeInsets     popupContentInsets;// Inset of labels, images and buttons on the popup content view (Default 16.0 on all sides)
@property (nonatomic, assign) CGFloat          contentVerticalPadding;// Spacing between each vertical element (Default 12.0)
@property (nonatomic, assign) CGFloat          verticalOffset;
@end
