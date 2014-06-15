//
//  PlayerModel.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "PlayerModel.h"

@implementation PlayerModel

const int MAX_RESOURCE = 10;

@synthesize playerMonster = _playerMonster;
@synthesize resource = _resource;
@synthesize maxResource = _maxResource;

-(instancetype)initWithPlayerMonster: (MonsterCardModel*) playerMonster
{
    self = [super init];
    
    if (self)
    {
        self.playerMonster = playerMonster;
        self.resource = 0;
        self.maxResource = 0;
    }
    
    return self;
}

/**
 Resource must be between MAX_RESOURCE and 0. TODO maybe allow negative
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

/**
 resource must be between MAX_RESOURCE and 0
 */
-(void)setMaxResource:(int)maxResource
{
    if (maxResource > MAX_RESOURCE)
        _maxResource = MAX_RESOURCE;
    else if (maxResource < 0)
        _maxResource = 0;
    else
        _maxResource = maxResource;
}

-(int)maxResource
{
    return _maxResource;
}


@end
