//
//  SCAppDelegate.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 06.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCDataService.h"
#import "SCMenuViewController.h"
#import <RestKit/RestKit.h>
#import <HockeySDK/HockeySDK.h>
#import <CoreMotion/CoreMotion.h>

@interface SCAppDelegate : UIResponder <UIApplicationDelegate, BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) RKManagedObjectStore *managedObjectStore;

@property (strong, readonly) CMMotionManager *sharedMotionManager;

- (void)replaceDB:(NSURL *)url;
- (NSURL *)currentPersistentStore;

@end
