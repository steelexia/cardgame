//
//  CGPointUtilities.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-28.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CGPointUtilities.h"

@implementation CGPointUtilities

CGPoint CGPointAdd(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}

CGPoint CGPointSubtract(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x - p2.x, p1.y - p2.y);
}

CGPoint CGPointMultiplyScalar(CGPoint p1, float s)
{
    return CGPointMake(p1.x * s, p1.y * s);
}
CGPoint CGPointDivideScalar(CGPoint p1, float s)
{
    return CGPointMake(p1.x / s, p1.y / s);
}

/** returns the absolute distance between p1 and p2 */
float CGPointDistance(CGPoint p1, CGPoint p2)
{
    return abs(sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2)));
}

/** returns the angle in radians between p1 and p2 */
float CGPointAngle(CGPoint p1, CGPoint p2)
{
    return atan2(p2.y-p1.y, p2.x - p1.x);
}

@end
