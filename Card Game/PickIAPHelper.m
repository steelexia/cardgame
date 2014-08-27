//
//  PickIAPHelper.m
//  funnyBusiness
//
//  Created by Macbook on 2013-11-19.
//  Copyright (c) 2013 bricorp. All rights reserved.
//

#import "PickIAPHelper.h"

@implementation PickIAPHelper

+(PickIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static PickIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
            @"com.contentgames.cardgame1999Gold",
             @"com.contentgames.cardgame1499Gold",
            @"com.contentgames.cardgame499Gold",
            @"com.contentgames.cardgame199Gold",
            nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}




@end
