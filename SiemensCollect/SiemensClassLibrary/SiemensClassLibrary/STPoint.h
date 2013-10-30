//
//  STPoint.h
//  SiemensClassLibrary
//
//  Created by Andreas Seitz on 26.06.13.
//  Copyright (c) 2013 Asish Biswas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STFloor;

@interface STPoint : NSManagedObject

@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) STFloor *floor;

@end
