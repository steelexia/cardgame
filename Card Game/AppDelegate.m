//
//  AppDelegate.m
//  Card Game
//
//  Created by Steele Xia
//  Copyright (c) 2014 Content Games. All rights reserved.
//

#import "AppDelegate.h"
#import "AbilityWrapper.h"
#import "Campaign.h"
#import "SSKeychain.h"
#import "PickIAPHelper.h"
#import "LoginViewController.h"
#import "CFPopupViewController.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

//TODO needs to move this probably to UserModel


const BOOL OFFLINE_DEBUGGING = NO;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    srand48(time(0));
    
    [Parse setApplicationId:@"yekARh373R6T7z42RzFD8R1ywZVYELpOS1gCVD5C"
                  clientKey:@"Y46eRRr2QOFIu9kJGmmJldxV0xbPdtdbC6DJ7Q53"];
    
    [UIConstants loadResources];
    [AbilityWrapper loadAllAbilities];
    [CardView loadResources];
    [Campaign loadResources];
    
    
    /* Instantiate PubNub */
    [PubNub setDelegate:self];
    
    userCDContext = [self managedObjectContext];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    if (OFFLINE_DEBUGGING)
    {
        //userInfoLoaded = YES;
    }
    else
    {
        /*
        //TODO should be in main screen
        
        
        NSError*error;
        NSString *account = [SSKeychain passwordForService:SERVICE_NAME account:ACCOUNT_NAME error:&error];
        
        //-25300 is when it's not found
        if (error && error.code != -25300)
        {
            
            NSLog(@"ERROR GETTING ACCOUNT: %@", [error localizedDescription]);
            return NO;
        }
        
        NSString *password = [SSKeychain passwordForService:SERVICE_NAME account:PASSWORD_NAME error:&error];
        
        if (error && error.code != -25300)
        {
            NSLog(@"ERROR GETTING PASSWORD: %@", [error localizedDescription]);
            return NO;
        }
        
        //password = @"123456";
        
        NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSLog(@"%@", idfv);
        
        NSString *defaultUsername = [idfv substringToIndex:7]; //TODO!!!
        
        //new account
        if (account == nil || password == nil)
        {
            NSError*error;
            [SSKeychain setPassword:idfv forService:SERVICE_NAME account:ACCOUNT_NAME error:&error];
            
            if (error)
            {
                NSLog(@"%@", [error localizedDescription]);
                return NO;
            }
            else
            {
                NSLog(@"account success: %@", idfv);
                password = idfv;
            }
            
            [SSKeychain setPassword:defaultUsername forService:SERVICE_NAME account:PASSWORD_NAME error:&error];
            
            if (error)
            {
                NSLog(@"%@", [error localizedDescription]);
                return NO;
            }
            else
            {
                NSLog(@"password success: %@", defaultUsername);
                account = defaultUsername;
            }
        }
        //already have account
        else{
            NSLog(@"already have account: %@", password);
        }
        
        BOOL accountExists = NO;
        PFQuery *accountQuery = [PFUser query];
        [accountQuery whereKey:@"username" equalTo:account];
        PFObject *user = [accountQuery getFirstObject:&error];
        
        if (error && error.code != kPFErrorObjectNotFound)
        {
            NSLog(@"failed to query for user %@", error);
            return NO;
        }
        
        if (user!=nil)
            accountExists = YES;
        
        //TODO, username is that for now, and password needs to be made working
        [PFUser logInWithUsernameInBackground:account password:password
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                [UserModel setupUser];
                                            } else {
                                                if(error)
                                                {
                                                    NSLog(@"%d", [error code]);
                                                    //no username, register one
                                                    if ([error code] == 101 && !accountExists) //101 is invalid login credentials
                                                    {
                                                        userPF = [PFUser user];
                                                        userPF.username = account;
                                                        userPF.password = password;
                                                        NSError*error;
                                                        [userPF signUp:&error];
                                                        
                                                        if (error)
                                                        {
                                                            NSLog(@"%@", [error localizedDescription]);
                                                        }
                                                        else
                                                        {
                                                            NSLog(@"signup succecss");
                                                            [UserModel setupUser];
                                                        }
                                                    }
                                                    else{
                                                        NSLog(@"FAILED TO LOG IN: %@", [error localizedDescription]);
                                                    }
                                                }
                                                else
                                                {
                                                    NSLog(@"no error but no user. not suppose to happen");
                                                }
                                            }
                                        }];
         */
    }
    //[PFUser enableAutomaticUser];
    
    /*
     [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
     
     //NSLog(@"%d", succeeded);
     
     //load resources
     [UserModel setupUser]; //also loads user data such as gold
     }];*/
    
    
    /*
     CDCardModel *card = [NSEntityDescription
     insertNewObjectForEntityForName:@"Card"
     inManagedObjectContext:context];
     card.name = @"Card name";
     card.cardId = @1;
     card.cardType = @1;
     
     NSError *error;
     if (![context save:&error]) {
     NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
     }
     */
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    [PickIAPHelper sharedInstance];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

//Brian Jan30
//adding code to retrieve the currently active viewController so we can show a notification popup from anywhere in the app
- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

//Brian June 5
//update push here
//need to open a screen to edit the card that was liked

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    if ( application.applicationState == UIApplicationStateActive )
    {
        //show a popup on the current view controller telling the user the contents of the card Approval
        UIViewController *activeVC = [self topViewController];
        //show an alert in the activeVC
        
      
        UIAlertController *myAlertController = [[UIAlertController alloc] init];
        [myAlertController setTitle:@"Incoming Push"];
      
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [myAlertController addAction:defaultAction];
        
        CFPopupViewController *myCFPopup = [[CFPopupViewController alloc] init];
        myCFPopup.popupTitle = @"BrianTest";
        
        
        [activeVC presentViewController:myCFPopup animated:NO completion:nil];
        
        
        //[activeVC.view addSubview:messageAlertView];
        
        // app was already in the foreground
        NSString *messageType = [userInfo objectForKey:@"messageType"];
        
        if([messageType isEqualToString:@"newMatch"])
        {
            //show new match popup
        }
        if([messageType isEqualToString:@"message"])
        {
            //do nothing, pubnub already handling
        }
        application.applicationIconBadgeNumber = 0;
        
        if([messageType isEqualToString:@"cardApprovedNotification"])
        {
            //show a popup on the current view controller telling the user the contents of the card Approval
            UIViewController *activeVC = [self topViewController];
            //show an alert in the activeVC
            UIAlertView *messageAlertView = [[UIAlertView alloc] initWithTitle:@"cardApproved" message:@"Your Card Was Approved" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [activeVC.view addSubview:messageAlertView];
            
        }
    }
    
    else
    {
        // app was just brought from background to foreground
        [PFPush handlePush:userInfo];
        application.applicationIconBadgeNumber +=1;
        
    }

    
    
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CardGame" withExtension:@"momd"]; //TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CardGame.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        
        //TODO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! this is actually easy to solve, just load all data from parse again
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark pubnub delegate methods
//(In AppDelegate.m, define didReceiveMessage delegate method:)
- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    NSLog( @"%@", [NSString stringWithFormat:@"received: %@", message.message] );
    NSLog(@"this fired from the app delegate zoinks");
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"PNMessage" object:self userInfo:[pubMsgDict copy]];
    
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    NSLog(@"DELEGATE: Connected to  origin: %@", origin);
    NSLog(@"brianconnected");
    
}

- (void)pubnubClient:(PubNub *)client didReceiveParticipantsList:(NSArray *)participants forChannel:(PNChannel *)channel
{
    NSLog(@"DELEGATE: Here_Now %@: %@", participants, channel);
}

// #5 Add a delegate +didEnablePresenceObservationOnChannels+ to log a message when presence is enabled
- (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOnChannels:(NSArray *)channels {
    
    NSLog(@"DELEGATE: Presence observation enabled.");
}

// #4. Add the +didReceivePresenceEvent+ delegate to catch presence events
- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {
    NSLog(@"DELEGATE: Received Presence event: %@", event);
}

@end
