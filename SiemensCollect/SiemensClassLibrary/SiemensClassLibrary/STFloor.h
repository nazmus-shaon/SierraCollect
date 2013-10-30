//
//  STFloor.h
//  SiemensClassLibrary
//
//  Created by Andreas Seitz on 26.06.13.
//  Copyright (c) 2013 Asish Biswas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STBuilding, STPoint;

@interface STFloor : NSManagedObject

@property (nonatomic, retain) NSNumber * floorNr;
@property (nonatomic, retain) NSNumber * isGroundFloor;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id pathToFloorPlan;
@property (nonatomic, retain) NSNumber * scale;
@property (nonatomic, retain) STBuilding *building;
@property (nonatomic, retain) NSSet *points;
@end

@interface STFloor (CoreDataGeneratedAccessors)

- (void)addPointsObject:(STPoint *)value;
- (void)removePointsObject:(STPoint *)value;
- (void)addPoints:(NSSet *)values;
- (void)removePoints:(NSSet *)values;

@end
