//
//  SensorPoint.h
//  SiemensCollect
//
//  Created by Xue Meng on 6/12/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Measurement, PanoramaPointer, Point;

@interface SensorPoint : NSManagedObject

@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) Point *inheritsPoint;
@property (nonatomic, retain) PanoramaPointer *isAPanoramaPoint;
@property (nonatomic, retain) NSSet *measurements;
@end

@interface SensorPoint (CoreDataGeneratedAccessors)

- (void)addMeasurementsObject:(Measurement *)value;
- (void)removeMeasurementsObject:(Measurement *)value;
- (void)addMeasurements:(NSSet *)values;
- (void)removeMeasurements:(NSSet *)values;

@end
