//
//  Floor.h
//  SiemensCollect
//
//  Created by Xue Meng on 6/12/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Building, Point;

@interface Floor : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * floorNr;
@property (nonatomic, retain) NSString * pathToFloorPlan;
@property (nonatomic, retain) NSNumber * isGroundFloor;
@property (nonatomic, retain) NSNumber * scale;
@property (nonatomic, retain) Building *locatesInBuilding;
@property (nonatomic, retain) NSSet *hasPoints;
@end

@interface Floor (CoreDataGeneratedAccessors)

- (void)addHasPointsObject:(Point *)value;
- (void)removeHasPointsObject:(Point *)value;
- (void)addHasPoints:(NSSet *)values;
- (void)removeHasPoints:(NSSet *)values;

@end
