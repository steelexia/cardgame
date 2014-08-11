//
//  CGPointUtilities.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-28.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Some utilities functions for CGPoint operations because they don't exist in standard library */
@interface CGPointUtilities : NSObject

CGPoint CGPointAdd(CGPoint p1, CGPoint p2);

CGPoint CGPointSubtract(CGPoint p1, CGPoint p2);

CGPoint CGPointMultiplyScalar(CGPoint p1, float s);

CGPoint CGPointDivideScalar(CGPoint p1, float s);

/** returns the absolute distance between p1 and p2 */
float CGPointDistance(CGPoint p1, CGPoint p2);

/** returns the angle in radians between p1 and p2 */
float CGPointAngle(CGPoint p1, CGPoint p2);


@end
