//
//  PlayerModel.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "PlayerModel.h"

@implementation PlayerModel

const int MAX_RESOURCE = 9;

@synthesize playerMonster = _playerMonster;
@synthesize resource = _resource;

-(instancetype)initWithPlayerMonster: (MonsterCardModel*) playerMonster
{
    self = [super init];
    
    if (self)
    {
        self.playerMonster = playerMonster;
        self.resource = 0;
    }
    
    return self;
}

/**
 resource must be between MAX_RESOURCE and 0
 */
-(void)setResource:(int)resource
{
    if (resource > MAX_RESOURCE)
        _resource = MAX_RESOURCE;
    else if (resource < 0)
        _resource = 0;
    else
        _resource = resource;
}

-(int)resource
{
    return _resource;
}

@end
