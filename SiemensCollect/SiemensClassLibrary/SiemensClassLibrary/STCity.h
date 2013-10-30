//
//  STCity.h
//  SiemensClassLibrary
//
//  Created by Andreas Seitz on 26.06.13.
//  Copyright (c) 2013 Asish Biswas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STAddress, STBuilding;

@interface STCity : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *addresses;
@property (nonatomic, retain) NSSet *buildings;
@property (nonatomic, retain) NSSet *country;
@end

@interface STCity (CoreDataGeneratedAccessors)

- (void)addAddressesObject:(STAddress *)value;
- (void)removeAddressesObject:(STAddress *)value;
- (void)addAddresses:(NSSet *)values;
- (void)removeAddresses:(NSSet *)values;

- (void)addBuildingsObject:(STBuilding *)value;
- (void)removeBuildingsObject:(STBuilding *)value;
- (void)addBuildings:(NSSet *)values;
- (void)removeBuildings:(NSSet *)values;

- (void)addCountryObject:(STBuilding *)value;
- (void)removeCountryObject:(STBuilding *)value;
- (void)addCountry:(NSSet *)values;
- (void)removeCountry:(NSSet *)values;

@end
