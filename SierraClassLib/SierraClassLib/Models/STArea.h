//
//  STArea.h
//  SierraClassLib
//
//  Created by Nazmus Shaon on 30/11/13.
//  Copyright (c) 2013 Lehrstuhl für Angewandte Softwaretechnik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STBuilding, STCity;

@interface STArea : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) STCity *city;
@property (nonatomic, retain) NSSet *buildings;
@end

@interface STArea (CoreDataGeneratedAccessors)

- (void)addBuildingsObject:(STBuilding *)value;
- (void)removeBuildingsObject:(STBuilding *)value;
- (void)addBuildings:(NSSet *)values;
- (void)removeBuildings:(NSSet *)values;

@end
