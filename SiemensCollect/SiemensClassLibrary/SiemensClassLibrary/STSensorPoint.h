//
//  STSensorPoint.h
//  SiemensClassLibrary
//
//  Created by Andreas Seitz on 26.06.13.
//  Copyright (c) 2013 Asish Biswas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STMeasurement, STSensorPoint, STStack, STWifiNetworkScanner;

@interface STSensorPoint : NSManagedObject

@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSString * imageType;
@property (nonatomic, retain) NSNumber * pitch;
@property (nonatomic, retain) NSNumber * roll;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * yaw;
@property (nonatomic, retain) NSSet *accessibleSensorPoints;
@property (nonatomic, retain) STWifiNetworkScanner *detectedWifiNetwork;
@property (nonatomic, retain) NSSet *measurements;
@property (nonatomic, retain) STStack *stack;
@end

@interface STSensorPoint (CoreDataGeneratedAccessors)

- (void)addAccessibleSensorPointsObject:(STSensorPoint *)value;
- (void)removeAccessibleSensorPointsObject:(STSensorPoint *)value;
- (void)addAccessibleSensorPoints:(NSSet *)values;
- (void)removeAccessibleSensorPoints:(NSSet *)values;

- (void)addMeasurementsObject:(STMeasurement *)value;
- (void)removeMeasurementsObject:(STMeasurement *)value;
- (void)addMeasurements:(NSSet *)values;
- (void)removeMeasurements:(NSSet *)values;

@end
