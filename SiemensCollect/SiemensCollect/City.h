//
//  City.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 06.06.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Country;

@interface City : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Country *belongs_to;

@end
