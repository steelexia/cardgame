//
//  MessageModel.m
//  cardgame
//
//  Created by Steele on 2014-09-01.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "MessageModel.h"

const int MESSAGE_NO_ID = -1;

@implementation MessageModel

- (id)init
{
    self = [super init];
    if (self) {
        _title = @"";
        _body = @"";
        _idNumber = MESSAGE_NO_ID;
    }
    return self;
}

@end
