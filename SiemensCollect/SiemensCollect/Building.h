//
//  Building.h
//  SiemensCollect
//
//  Created by Xue Meng on 6/12/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address, City, Floor;

@interface Building : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * miniature;
@property (nonatomic, retain) City *locatesInCity;
@property (nonatomic, retain) Address *hasAddress;
@property (nonatomic, retain) NSSet *hasFloors;
@end

@interface Building (CoreDataGeneratedAccessors)

- (void)addHasFloorsObject:(Floor *)value;
- (void)removeHasFloorsObject:(Floor *)value;
- (void)addHasFloors:(NSSet *)values;
- (void)removeHasFloors:(NSSet *)values;

@end
