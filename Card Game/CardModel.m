//
//  CardModel.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "CardModel.h"

@implementation CardModel

@synthesize idNumber = _idNumber;
@synthesize name = _name;
@synthesize cost = _cost;
@synthesize rarity = _rarity;
@synthesize abilities = _abilities;
@synthesize type = _type;

/** constructor with id number, all other fields will be defaut values */
-(instancetype)initWithIdNumber: (long)idNumber
{
    self = [super init];
    
    if (self)
    {
        _idNumber = idNumber;
        
        //default values
        self.name = [NSString stringWithFormat:@"Card %ld", idNumber]; //TODO temp
        self.cost = 0;
        
        self.abilities = [NSMutableArray array]; //default no ability
        self.type = cardTypeStandard;
    }
    
    return self;
}

-(instancetype)initWithIdNumber:(long)idNumber type:(enum CardType) type
{
    self = [self initWithIdNumber:idNumber];
    
    if (self)
    {
        self.type = type;
    }
    
    return self;
}

/* must be 0 or higher */
-(void)setCost:(int)cost{
    _cost = cost < 0 ? 0 : cost;
}

-(int)cost{
    return _cost;
}

@end

