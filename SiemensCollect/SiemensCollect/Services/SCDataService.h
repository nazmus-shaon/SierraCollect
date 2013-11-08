//
//  SCPDFService.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 15.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>
#import "SCAppDelegate.h"

typedef enum{
    Temperature = 216,
    Humidity = 27,
    AmbientLight = 21,
    AirPressure = 221,
    WifiSensor = 200
} SensorType;

@interface SCDataService : NSObject <UIAlertViewDelegate> {
    
}

+ (SCDataService *)shared;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) RKManagedObjectStore *managedObjectStore;
@property (strong, nonatomic) RKObjectManager *objectManager;

@property (strong, nonatomic) NSMutableArray *wifiSensorArray;
@property (strong, nonatomic) NSMutableArray *otherSensorArray;
@property (strong, nonatomic) NSMutableArray *dhcpClientArray;
@property (strong, nonatomic) NSMutableArray *continuousMeasurementArray;

- (NSArray *)getFloorplansForBuilding:(STBuilding *)building;
- (NSArray *)getCountries;
- (NSArray *)getCitiesForCountry:(STCountry *)country;
- (NSArray *)getBuildingsForCity:(STCity*)city;
- (NSArray *)getPointsforFloor:(STFloor *)floor;
- (NSArray *)getLastUpdatedFloorplans;

- (void)getWifisensorsAddTarget:(id)target action:(SEL)action;
- (void)getOtherSensorsAddTarget:(id)target action:(SEL)action;
- (void)getOtherSensorsAddTargetForWaspmote;
- (void)getDHCPClientsAddTarget:(id)target action:(SEL)action;
- (void)getContinuousMeasurementsAddTarget:(id)target action:(SEL)action;

//- (void)handlePDFImport:(NSURL*)url;
//
//- (NSArray *)getDummyData;
//- (NSArray *)dummyCities;
//- (NSArray *)dummyCountries;

@end
