//
//  File.h
//  SiemensCollect
//
//  Created by RegMyUDiD on 6/13/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Gist;

@interface File : NSManagedObject

@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) id rawURL;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) Gist *gist;

@end
