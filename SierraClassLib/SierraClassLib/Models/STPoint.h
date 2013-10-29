//
//  STPoint.h
//  SierraClassLib
//
//  Created by Nazmus Shaon on 29/10/13.
//  Copyright (c) 2013 Lehrstuhl für Angewandte Softwaretechnik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STFloor, STPoint, STSensorPoint;

@interface STPoint : NSManagedObject

@property (nonatomic, retain) NSNumber * creationSequence;
@property (nonatomic, retain) NSString * csMacAddress;
@property (nonatomic, retain) NSNumber * lattitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * pointType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *accessiblePoints;
@property (nonatomic, retain) STFloor *floor;
@property (nonatomic, retain) NSSet *sensorPoints;
@end

@interface STPoint (CoreDataGeneratedAccessors)

- (void)addAccessiblePointsObject:(STPoint *)value;
- (void)removeAccessiblePointsObject:(STPoint *)value;
- (void)addAccessiblePoints:(NSSet *)values;
- (void)removeAccessiblePoints:(NSSet *)values;

- (void)addSensorPointsObject:(STSensorPoint *)value;
- (void)removeSensorPointsObject:(STSensorPoint *)value;
- (void)addSensorPoints:(NSSet *)values;
- (void)removeSensorPoints:(NSSet *)values;

@end
