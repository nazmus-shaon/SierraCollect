//
//  STSensorPoint.h
//  SierraClassLib
//
//  Created by Andreas Seitz on 08.07.13.
//  Copyright (c) 2013 Lehrstuhl für Angewandte Softwaretechnik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STMeasurement, STPoint, STStack, STWifiNetwork;

@interface STSensorPoint : NSManagedObject

@property (nonatomic, retain) NSString * imageType;
@property (nonatomic, retain) NSNumber * pitch;
@property (nonatomic, retain) NSNumber * roll;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * yaw;
@property (nonatomic, retain) NSSet *measurements;
@property (nonatomic, retain) STPoint *point;
@property (nonatomic, retain) STStack *stack;
@property (nonatomic, retain) NSSet *wifiNetworks;

@end

@interface STSensorPoint (CoreDataGeneratedAccessors)

- (void)addMeasurementsObject:(STMeasurement *)value;
- (void)removeMeasurementsObject:(STMeasurement *)value;
- (void)addMeasurements:(NSSet *)values;
- (void)removeMeasurements:(NSSet *)values;

- (void)addWifiNetworksObject:(STWifiNetwork *)value;
- (void)removeWifiNetworksObject:(STWifiNetwork *)value;
- (void)addWifiNetworks:(NSSet *)values;
- (void)removeWifiNetworks:(NSSet *)values;

@end
