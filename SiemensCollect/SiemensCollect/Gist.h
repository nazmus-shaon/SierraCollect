//
//  Gist.h
//  SiemensCollect
//
//  Created by RegMyUDiD on 6/13/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class File, User;

@interface Gist : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * descriptionText;
@property (nonatomic, retain) NSNumber * gistID;
@property (nonatomic, retain) id htmlURL;
@property (nonatomic, retain) id jsonURL;
@property (nonatomic, retain) NSNumber * public;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSSet *files;
@property (nonatomic, retain) User *user;

@property (nonatomic, readonly) NSString *titleText;
@property (nonatomic, readonly) NSString *subtitleText;
@end

@interface Gist (CoreDataGeneratedAccessors)

- (void)addFilesObject:(File *)value;
- (void)removeFilesObject:(File *)value;
- (void)addFiles:(NSSet *)values;
- (void)removeFiles:(NSSet *)values;

@end
