//
//  UIConstants.m
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-27.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "UIConstants.h"

@implementation UIConstants

+(void)loadResources
{
    COLOUR_INTERFACE_BLUE = [[UIColor alloc] initWithRed:0 green:0.45 blue:1 alpha:1];
    COLOUR_INTERFACE_BLUE_DARK = [[UIColor alloc] initWithRed:51/255.f green:130/255.f blue:204/255.f alpha:1];
    COLOUR_INTERFACE_BLUE_PRESSED = [[UIColor alloc] initWithRed:21/255.f green:59/255.f blue:110/255.f alpha:1];
    COLOUR_INTERFACE_BLUE_TRANSPARENT = [[UIColor alloc] initWithRed:0 green:0.45 blue:1 alpha:0.5];
    COLOUR_INTERFACE_BLUE_TOGGLE = [[UIColor alloc] initWithRed:55/255.f green:100/255.f blue:160/255.f alpha:1];
    COLOUR_INTERFACE_BLUE_LIGHT = [[UIColor alloc] initWithRed:64/255.f green:163/255.f blue:255/255.f alpha:1];
    COLOUR_INTERFACE_GRAY_TRANSPARENT = [[UIColor alloc] initWithRed:0.35 green:0.35 blue:0.35 alpha:0.5];
    COLOUR_INTERFACE_GRAY = [[UIColor alloc] initWithRed:0.47 green:0.47 blue:0.47 alpha:1];
    COLOUR_BACKGROUND_GRAY = [[UIColor alloc] initWithRed:70/255.f green:70/255.f blue:70/255.f alpha:1];
    
    COLOUR_INTERFACE_RED = [[UIColor alloc] initWithRed:255/255.f green:36/255.f blue:0/255.f alpha:1];
    COLOUR_INTERFACE_RED_PRESSED = [[UIColor alloc] initWithRed:141/255.f green:71/255.f blue:59/255.f alpha:1];
    
    COLOUR_NEUTRAL = [[UIColor alloc] initWithRed:0.82 green:0.72 blue:0.52 alpha:1];
    COLOUR_FIRE = [[UIColor alloc] initWithRed:218/255.f green:67/255.f blue:32/255.f alpha:1];
    COLOUR_ICE = [[UIColor alloc] initWithRed:84/255.f green:171/255.f blue:216/255.f alpha:1];
    COLOUR_LIGHTNING = [[UIColor alloc] initWithRed:234/255.f green:236/255.f blue:101/255.f alpha:1];
    COLOUR_EARTH = [[UIColor alloc] initWithRed:25/255.f green:117/255.f blue:12/255.f alpha:1];
    COLOUR_LIGHT = [[UIColor alloc] initWithRed:226/255.f green:226/255.f blue:226/255.f alpha:1];
    COLOUR_DARK = [[UIColor alloc] initWithRed:20/255.f green:20/255.f blue:20/255.f alpha:1];
    
    COLOUR_NEUTRAL_DARK = [[UIColor alloc] initWithRed:144/255.f green:124/255.f blue:82/255.f alpha:1];
    COLOUR_NEUTRAL_OUTLINE = [[UIColor alloc] initWithRed:81/255.f green:75/255.f blue:63/255.f alpha:1];
    COLOUR_FIRE_OUTLINE = [[UIColor alloc] initWithRed:101/255.f green:35/255.f blue:20/255.f alpha:1];
    COLOUR_ICE_OUTLINE = [[UIColor alloc] initWithRed:31/255.f green:62/255.f blue:78/255.f alpha:1];
    COLOUR_LIGHTNING_OUTLINE = [[UIColor alloc] initWithRed:89/255.f green:90/255.f blue:38/255.f alpha:1];
    COLOUR_EARTH_OUTLINE = [[UIColor alloc] initWithRed:15/255.f green:57/255.f blue:10/255.f alpha:1];
    COLOUR_LIGHT_OUTLINE = [[UIColor alloc] initWithRed:100/255.f green:100/255.f blue:100/255.f alpha:1];
    COLOUR_DARK_OUTLINE = [[UIColor alloc] initWithRed:160/255.f green:160/255.f blue:160/255.f alpha:1];
    
    COLOUR_COMMON = [[UIColor alloc] initWithRed:208/255.f green:199/255.f blue:179/255.f alpha:1];
    COLOUR_UNCOMMON = [[UIColor alloc] initWithRed:237/255.f green:237/255.f blue:237/255.f alpha:1];
    COLOUR_RARE = [[UIColor alloc] initWithRed:35/255.f green:101/255.f blue:210/255.f alpha:1];
    COLOUR_EXCEPTIONAL = [[UIColor alloc] initWithRed:232/255.f green:204/255.f blue:19/255.f alpha:1];
    COLOUR_LEGENDARY = [[UIColor alloc] initWithRed:207/255.f green:111/255.f blue:34/255.f alpha:1];
    
    COLOUR_STAT_MODED = [[UIColor alloc] initWithRed:255/255.f green:191/255.f blue:191/255.f alpha:1];
    
    RESOURCE_ICON_IMAGE = [UIImage imageNamed:@"resource_icon"];
    POINTS_ICON_IMAGE = [UIImage imageNamed:@"points_icon"];
    GOLD_ICON_IMAGE = [UIImage imageNamed:@"gold_icon"];
    LIKE_ICON_IMAGE = [UIImage imageNamed:@"like_icon"];
    CARD_ICON_IMAGE = [UIImage imageNamed:@"card_icon"];
    CARD_ICON_GRAY_IMAGE = [UIImage imageNamed:@"card_icon_gray"];
    ADD_ICON_IMAGE = [UIImage imageNamed:@"add_icon"];
    OPTION_ICON_IMAGE = [UIImage imageNamed:@"gear_icon"];
    MESSAGE_ICON_IMAGE = [UIImage imageNamed:@"message_icon"];
    ARROW_LEFT_ICON_IMAGE = [UIImage imageNamed:@"arrow_left_icon"];
    ARROW_RIGHT_ICON_IMAGE = [UIImage imageNamed:@"arrow_right_icon"];
}

+(UIColor*)getElementColor:(enum CardElement)element
{
    if (element == elementNeutral)
        return COLOUR_NEUTRAL;
    else if (element == elementFire)
        return COLOUR_FIRE;
    else if (element == elementIce)
        return COLOUR_ICE;
    else if (element == elementLightning)
        return COLOUR_LIGHTNING;
    else if (element == elementEarth)
        return COLOUR_EARTH;
    else if (element == elementLight)
        return COLOUR_LIGHT;
    else if (element == elementDark)
        return COLOUR_DARK;
    
    return COLOUR_NEUTRAL;
}

+(UIColor*)getElementOutlineColor:(enum CardElement)element
{
    if (element == elementNeutral)
        return COLOUR_NEUTRAL_OUTLINE;
    else if (element == elementFire)
        return COLOUR_FIRE_OUTLINE;
    else if (element == elementIce)
        return COLOUR_ICE_OUTLINE;
    else if (element == elementLightning)
        return COLOUR_LIGHTNING_OUTLINE;
    else if (element == elementEarth)
        return COLOUR_EARTH_OUTLINE;
    else if (element == elementLight)
        return COLOUR_LIGHT_OUTLINE;
    else if (element == elementDark)
        return COLOUR_DARK_OUTLINE;
    
    return COLOUR_NEUTRAL_OUTLINE;
}

@end
