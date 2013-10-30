//
//  STAddress.h
//  SiemensClassLibrary
//
//  Created by Andreas Seitz on 26.06.13.
//  Copyright (c) 2013 Asish Biswas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STCity;

@interface STAddress : NSManagedObject

@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * zipcode;
@property (nonatomic, retain) STCity *city;

@end
