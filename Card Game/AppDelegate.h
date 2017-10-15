//
//  AppDelegate.h
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@class DeckEditorViewController;


//#import "UIConstants.h"
//@class UIConstants.h;
@class CardView;


@class UserModel;
//#import "UserModel.h"
#import "CDCardModel.h"
#import <CoreData/CoreData.h>
#import "PNImports.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate,PNDelegate>

{
   AVAudioPlayer *gameMusicPlayer;
}
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) AVAudioPlayer *gameMusicPlayer;

@end


