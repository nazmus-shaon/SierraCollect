//
//  PanoramaPointer.h
//  SiemensCollect
//
//  Created by Xue Meng on 6/12/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PanoramaPointer;

@interface PanoramaPointer : NSManagedObject

@property (nonatomic, retain) NSString * panoramaType;
@property (nonatomic, retain) NSNumber * yaw;
@property (nonatomic, retain) NSNumber * row;
@property (nonatomic, retain) NSNumber * pitch;
@property (nonatomic, retain) NSManagedObject *inheritesSensorPoint;
@property (nonatomic, retain) NSSet *canNavigateTo;
@end

@interface PanoramaPointer (CoreDataGeneratedAccessors)

- (void)addCanNavigateToObject:(PanoramaPointer *)value;
- (void)removeCanNavigateToObject:(PanoramaPointer *)value;
- (void)addCanNavigateTo:(NSSet *)values;
- (void)removeCanNavigateTo:(NSSet *)values;

@end
