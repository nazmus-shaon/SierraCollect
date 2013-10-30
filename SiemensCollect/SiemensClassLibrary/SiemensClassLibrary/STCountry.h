//
//  STCountry.h
//  SiemensClassLibrary
//
//  Created by Andreas Seitz on 26.06.13.
//  Copyright (c) 2013 Asish Biswas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STCity;

@interface STCountry : NSManagedObject

@property (nonatomic, retain) NSString * abb;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *cities;
@end

@interface STCountry (CoreDataGeneratedAccessors)

- (void)addCitiesObject:(STCity *)value;
- (void)removeCitiesObject:(STCity *)value;
- (void)addCities:(NSSet *)values;
- (void)removeCities:(NSSet *)values;

@end
