//
//  MessageModel.h
//  cardgame
//
//  Created by Steele on 2014-09-01.
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject

@property (strong) NSString*title, *body;

/** This just an identifier for special messages such as ones containing rewards etc. Generic messages would have -1 as ID */
@property int idNumber;

@end

extern const int MESSAGE_NO_ID;