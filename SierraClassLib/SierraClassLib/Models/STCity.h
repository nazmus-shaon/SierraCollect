//
//  STCity.h
//  SierraClassLib
//
//  Created by Nazmus Shaon on 30/11/13.
//  Copyright (c) 2013 Lehrstuhl für Angewandte Softwaretechnik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STAddress, STArea, STCountry;

@interface STCity : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *addresses;
@property (nonatomic, retain) NSSet *areas;
@property (nonatomic, retain) STCountry *country;
@end

@interface STCity (CoreDataGeneratedAccessors)

- (void)addAddressesObject:(STAddress *)value;
- (void)removeAddressesObject:(STAddress *)value;
- (void)addAddresses:(NSSet *)values;
- (void)removeAddresses:(NSSet *)values;

- (void)addAreasObject:(STArea *)value;
- (void)removeAreasObject:(STArea *)value;
- (void)addAreas:(NSSet *)values;
- (void)removeAreas:(NSSet *)values;

@end
