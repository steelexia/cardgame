//
//  SpellCardModel.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "SpellCardModel.h"

@implementation SpellCardModel

/** constructor with id number, all other fields will be defaut values */
-(instancetype)initWithIdNumber: (long)idNumber
{
    self = [super initWithIdNumber:idNumber];
    
    if (self)
    {
        
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

@end
