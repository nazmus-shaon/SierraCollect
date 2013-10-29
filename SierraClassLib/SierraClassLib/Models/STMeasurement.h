//
//  STMeasurement.h
//  SierraClassLib
//
//  Created by RegMyUDiD on 7/14/13.
//  Copyright (c) 2013 Lehrstuhl für Angewandte Softwaretechnik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STSensor;

@interface STMeasurement : NSManagedObject

@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) STSensor *sensor;

@end
