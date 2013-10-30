//
//  STStack.h
//  SiemensClassLibrary
//
//  Created by Andreas Seitz on 26.06.13.
//  Copyright (c) 2013 Asish Biswas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STPoint, STStackComponent;

@interface STStack : NSManagedObject

@property (nonatomic, retain) id connection;
@property (nonatomic, retain) NSString * ipAddress;
@property (nonatomic, retain) NSString * macAddress;
@property (nonatomic, retain) NSNumber * port;
@property (nonatomic, retain) NSSet *components;
@property (nonatomic, retain) STPoint *point;
@end

@interface STStack (CoreDataGeneratedAccessors)

- (void)addComponentsObject:(STStackComponent *)value;
- (void)removeComponentsObject:(STStackComponent *)value;
- (void)addComponents:(NSSet *)values;
- (void)removeComponents:(NSSet *)values;

@end
