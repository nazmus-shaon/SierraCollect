//
//  STSensor.h
//  SierraClassLib
//
//  Created by Andreas Seitz on 08.07.13.
//  Copyright (c) 2013 Lehrstuhl für Angewandte Softwaretechnik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STMeasurement;

@interface STSensor : NSManagedObject

@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * unit;
@property (nonatomic, retain) NSSet *measurements;
@end

@interface STSensor (CoreDataGeneratedAccessors)

- (void)addMeasurementsObject:(STMeasurement *)value;
- (void)removeMeasurementsObject:(STMeasurement *)value;
- (void)addMeasurements:(NSSet *)values;
- (void)removeMeasurements:(NSSet *)values;

@end
