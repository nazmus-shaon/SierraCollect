//
//  Sensor.h
//  SiemensCollect
//
//  Created by Xue Meng on 6/12/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Measurement;

@interface Sensor : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSSet *sensorMeasurements;
@end

@interface Sensor (CoreDataGeneratedAccessors)

- (void)addSensorMeasurementsObject:(Measurement *)value;
- (void)removeSensorMeasurementsObject:(Measurement *)value;
- (void)addSensorMeasurements:(NSSet *)values;
- (void)removeSensorMeasurements:(NSSet *)values;

@end
