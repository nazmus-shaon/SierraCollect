//
//  SCAppDelegate.m - Tryout
//  SiemensCollect
//
//  Created by Andreas Seitz on 06.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCAppDelegate.h"
#import "MFSideMenuContainerViewController.h"
#import "DSFingerTipWindow.h"
#import <SierraClassLib/STFloor.h>

@interface SCAppDelegate ()
    @property (strong, readwrite) CMMotionManager *sharedMotionManager;
@end

@implementation SCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    ///Setup HockeyApp
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:@"15f0c924a6e74fc794a2f04635dafa2a"
                                                         liveIdentifier:@"15f0c924a6e74fc794a2f04635dafa2a"
                                                               delegate:self];
    [[[BITHockeyManager sharedHockeyManager] crashManager] setCrashManagerStatus:BITCrashManagerStatusAutoSend];
    [[BITHockeyManager sharedHockeyManager] setDisableUpdateManager:YES];
    
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager] setDebugLogEnabled:YES];
    
    [self setupCoreDataStack];
    
    // Override point for customization after application launch.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    MFSideMenuContainerViewController *container = (MFSideMenuContainerViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"navigationController"];
    UINavigationController *leftSideMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"leftSideMenuViewController"];
    [(SCMenuViewController*)leftSideMenuViewController.topViewController setData:[[SCDataService shared] getCountries]];
    //[(SCMenuViewController*)leftSideMenuViewController setMenuKind:SCMenuViewControllerCountry];
    [container setLeftMenuViewController:leftSideMenuViewController];
    [container setCenterViewController:navigationController];
    
    //enable network indicator to know when uploads finished
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    
    return YES;
}

-(void)setupCoreDataStack
{
    NSError *error = nil;
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"SierraClassLibResoruces" withExtension:@"bundle"]];
    NSString *path = [bundle pathForResource:@"SiemensClassLibrary" ofType:@"mom"];
    NSURL *modelURL;
    
    if (path != NULL) {
        modelURL = [NSURL fileURLWithPath:[bundle pathForResource:@"SiemensClassLibrary" ofType:@"mom"]];
    } else {
        //FALLBACK SOLUTION NEEDED?
    }

    self.managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    self.managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    [self.managedObjectStore createPersistentStoreCoordinator];    // Initialize the Core Data stack
    
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"SierraDB.sqlite"];
    
    
//    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"selectedDB"]) {
//        //set selected DB;
//        storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults] stringForKey:@"selectedDB"]];
//    }

    
    NSPersistentStore *persistentStore = [self.managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store: %@", error);
    
    NSLog(@"storepath: %@", self.managedObjectStore.persistentStoreCoordinator.persistentStores);
    
    // creates a pair of managed object contexts arranged in a parent-child hierarchy
    [self.managedObjectStore createManagedObjectContexts];
    
    [RKManagedObjectStore setDefaultStore:self.managedObjectStore];
    self.managedObjectContext = self.managedObjectStore.mainQueueManagedObjectContext;
}


//Setup FingerTips
- (DSFingerTipWindow *)window {
    static DSFingerTipWindow *customWindow = nil;
    if (!customWindow) {
        customWindow = [[DSFingerTipWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    return customWindow;
}

- (CMMotionManager *)sharedMotionManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMotionManager = [[CMMotionManager alloc] init];
    });
    return _sharedMotionManager;
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return YES;
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

#pragma mark BITUpdateManagerDelegate

- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
    else
        return nil;
}

- (void)replaceDB:(NSURL *)url {
    NSLog(@"go to app delegate");
    // remove old store from coordinator
   
    NSError *error = nil;
    
    //NSLog(@"storepath: %@", self.managedObjectStore.persistentStoreCoordinator.persistentStores);
    
    
    if (![self.managedObjectStore.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:url    
                                                             options:nil
                                                               error:&error]) {
        NSLog(@"failed to add db file, error %@, %@", error, [error userInfo]);
    }
    
    NSPersistentStore *persistentStore = [[self.managedObjectStore.persistentStoreCoordinator persistentStores] objectAtIndex:0];
    
    [self.managedObjectStore.persistentStoreCoordinator removePersistentStore:persistentStore error:&error];
    if (error) {
        NSLog(@"error removing persistent store %@ %@", error, [error userInfo]);
    }
    
     NSLog(@"storepath after removing: %@", self.managedObjectStore.persistentStoreCoordinator.persistentStores);
    
    //SAVE TO USER DEFAULTS WHICH DB IS IN USE    
    [[NSUserDefaults standardUserDefaults] setObject:[url lastPathComponent] forKey:@"selectedDB"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSURL *)currentPersistentStore {
    return [[self.managedObjectStore.persistentStoreCoordinator.persistentStores objectAtIndex:0] presentedItemURL];
}

@end
