

#import "DHConstraintUtility.h"

#pragma mark - Implementation
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
@implementation DHConstraintUtility
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#pragma mark - UI Utility Classes
// ------------------------------------------------------------------------------------------------
+ (void) center: (UIView*) appliedView  within: (UIView*) enclosingView
// ------------------------------------------------------------------------------------------------
{
    [DHConstraintUtility center:appliedView
                         within:enclosingView
                     withInsets:UIEdgeInsetsMake(0, 0, 0, 0)
         withInsetsRelationRule:NSLayoutRelationLessThanOrEqual];
}

// ------------------------------------------------------------------------------------------------
+ (void) center: (UIView*) appliedView
         within: (UIView*) enclosingView
     withInsets: (UIEdgeInsets) insets
withInsetsRelationRule: (NSLayoutRelation) layoutRelation
// ------------------------------------------------------------------------------------------------
{

    [enclosingView addConstraint:[NSLayoutConstraint constraintWithItem:appliedView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:layoutRelation
                                                                 toItem:enclosingView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:insets.top]];
    [enclosingView addConstraint:[NSLayoutConstraint constraintWithItem:appliedView
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:layoutRelation
                                                                 toItem:enclosingView
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1
                                                               constant:insets.left]];
    [enclosingView addConstraint:[NSLayoutConstraint constraintWithItem:appliedView
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:layoutRelation
                                                                 toItem:enclosingView
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1
                                                               constant:-insets.right]];
    [enclosingView addConstraint:[NSLayoutConstraint constraintWithItem:appliedView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:layoutRelation
                                                                 toItem:enclosingView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:-insets.bottom]];
    CENTER_VIEW(enclosingView, appliedView);
}

// ------------------------------------------------------------------------------------------------
+ (void) glueRightSideOf: (UIView *)    firstView
            toLeftSideOf: (UIView *)    secondView
                 withGap: (CGFloat)     gapWidth
       withEnclosingView: (UIView *)    enclosingView
// ------------------------------------------------------------------------------------------------
{
    [enclosingView addConstraint:[NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:secondView attribute:NSLayoutAttributeLeft
                                                             multiplier:1
                                                               constant:gapWidth]];
}

// ------------------------------------------------------------------------------------------------
+ (void) glue: (NSLayoutAttribute) firstViewSide
           of: (UIView*) firstView
           to: (NSLayoutAttribute) secondViewSide
           of: (UIView*) secondView
withEnclosingView: (UIView*) enclosingView
// ------------------------------------------------------------------------------------------------
{
    [enclosingView addConstraint:[NSLayoutConstraint constraintWithItem:firstView attribute:firstViewSide
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:secondView attribute:secondViewSide
                                                             multiplier:1
                                                               constant:0]];
}
// ------------------------------------------------------------------------------------------------
+ (void) glue: (NSLayoutAttribute) firstViewSide
           of: (UIView*) firstView
           to: (NSLayoutAttribute) secondViewSide
           of: (UIView*) secondView
      withGap: (CGFloat) gapPixels
withEnclosingView: (UIView*) enclosingView
// ------------------------------------------------------------------------------------------------
{
    [enclosingView addConstraint:[NSLayoutConstraint constraintWithItem:firstView attribute:firstViewSide
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:secondView attribute:secondViewSide
                                                             multiplier:1
                                                               constant:gapPixels]];
}

// ------------------------------------------------------------------------------------------------
+ (void) withView: (UIView*) targetView
        glueTopTo: (UIView*) viewAbove
      glueRightTo: (UIView*) viewToRight
     glueBottomTo: (UIView*) viewBelow
       glueLeftTo: (UIView*) viewToLeft
withEnclosingView: (UIView*) enclosingView
// ------------------------------------------------------------------------------------------------
{
    [self glue:NSLayoutAttributeTop of:targetView
            to:NSLayoutAttributeBottom  of:viewAbove  withEnclosingView:enclosingView];

    [self glue:NSLayoutAttributeRight of:targetView
            to:NSLayoutAttributeLeft  of:viewToRight  withEnclosingView:enclosingView];

    [self glue:NSLayoutAttributeBottom of:targetView
            to:NSLayoutAttributeTop  of:viewBelow  withEnclosingView:enclosingView];

    [self glue:NSLayoutAttributeLeft of:targetView
            to:NSLayoutAttributeRight  of:viewToLeft  withEnclosingView:enclosingView];
}


@end
