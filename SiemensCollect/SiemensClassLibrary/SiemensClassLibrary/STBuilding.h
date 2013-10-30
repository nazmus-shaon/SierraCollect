//
//  STBuilding.h
//  SiemensClassLibrary
//
//  Created by Andreas Seitz on 26.06.13.
//  Copyright (c) 2013 Asish Biswas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STCity, STFloor;

@interface STBuilding : NSManagedObject

@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) id miniatureImage;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) STCity *city;
@property (nonatomic, retain) NSSet *floors;
@end

@interface STBuilding (CoreDataGeneratedAccessors)

- (void)addFloorsObject:(STFloor *)value;
- (void)removeFloorsObject:(STFloor *)value;
- (void)addFloors:(NSSet *)values;
- (void)removeFloors:(NSSet *)values;

@end
