//
//  Measurement.h
//  SiemensCollect
//
//  Created by Xue Meng on 6/12/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Measurement : NSManagedObject

@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSManagedObject *belongToASensorPoint;
@property (nonatomic, retain) NSManagedObject *belongToASensor;

@end
