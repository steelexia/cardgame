//
//  UIConstants.h
//  cardgame
//
//  Created by Art & Technology Learning Lab Faculty of Fine Arts on 2014-06-27.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>

/** For storing some constant values used throughout the game UI */
@interface UIConstants : NSObject

+(void)loadResources;

@end

UIColor* COLOUR_INTERFACE_BLUE, *COLOUR_INTERFACE_BLUE_TRANSPARENT, *COLOUR_INTERFACE_GRAY;

UIColor* COLOUR_NEUTRAL, *COLOUR_FIRE, *COLOUR_ICE, *COLOUR_LIGHTNING, *COLOUR_EARTH, *COLOUR_LIGHT, *COLOUR_DARK;
UIColor* COLOUR_NEUTRAL_OUTLINE, *COLOUR_FIRE_OUTLINE, *COLOUR_ICE_OUTLINE, *COLOUR_LIGHTNING_OUTLINE, *COLOUR_EARTH_OUTLINE, *COLOUR_LIGHT_OUTLINE, *COLOUR_DARK_OUTLINE;
UIColor* COLOUR_COMMON, * COLOUR_UNCOMMON, * COLOUR_RARE, * COLOUR_EXCEPTIONAL, * COLOUR_LEGENDARY;

UIImage*RESOURCE_ICON_IMAGE, *POINTS_ICON_IMAGE, *GOLD_ICON_IMAGE, *LIKE_ICON_IMAGE;