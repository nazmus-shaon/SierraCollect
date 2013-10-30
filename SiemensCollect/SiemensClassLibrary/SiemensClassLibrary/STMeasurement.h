//
//  STMeasurement.h
//  SiemensClassLibrary
//
//  Created by Andreas Seitz on 26.06.13.
//  Copyright (c) 2013 Asish Biswas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STSensor;

@interface STMeasurement : NSManagedObject

@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) STSensor *sensor;

@end
