//
//  Address.h
//  SiemensCollect
//
//  Created by Xue Meng on 6/12/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Building, City;

@interface Address : NSManagedObject

@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * zipcode;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) City *locatesInCity;
@property (nonatomic, retain) NSSet *hasBuildings;
@end

@interface Address (CoreDataGeneratedAccessors)

- (void)addHasBuildingsObject:(Building *)value;
- (void)removeHasBuildingsObject:(Building *)value;
- (void)addHasBuildings:(NSSet *)values;
- (void)removeHasBuildings:(NSSet *)values;

@end
