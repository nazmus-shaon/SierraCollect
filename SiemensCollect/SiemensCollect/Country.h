//
//  Country.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 06.06.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City;

@interface Country : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *relationship;
@end

@interface Country (CoreDataGeneratedAccessors)

- (void)addRelationshipObject:(City *)value;
- (void)removeRelationshipObject:(City *)value;
- (void)addRelationship:(NSSet *)values;
- (void)removeRelationship:(NSSet *)values;

@end
