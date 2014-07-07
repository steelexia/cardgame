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
-(instancetype)initWithIdNumber: (int)idNumber
{
    self = [super initWithIdNumber:idNumber];
    
    if (self)
    {
        
    }
    
    return self;
}

-(instancetype)initWithIdNumber:(int)idNumber type:(enum CardType) type
{
    self = [self initWithIdNumber:idNumber];
    
    if (self)
    {
        self.type = type;
    }
    
    return self;
}

-(instancetype)initWithCardModel:(CardModel*)card
{
    self = [self initWithIdNumber:card.idNumber];
    
    if (self)
    {
        
    }
    return self;
}

@end
