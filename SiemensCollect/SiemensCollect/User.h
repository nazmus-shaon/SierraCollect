//
//  User.h
//  SiemensCollect
//
//  Created by RegMyUDiD on 6/13/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Gist;

@interface User : NSManagedObject

@property (nonatomic, retain) id avatarURL;
@property (nonatomic, retain) NSString * gravatarID;
@property (nonatomic, retain) id jsonURL;
@property (nonatomic, retain) NSString * login;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSSet *gists;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addGistsObject:(Gist *)value;
- (void)removeGistsObject:(Gist *)value;
- (void)addGists:(NSSet *)values;
- (void)removeGists:(NSSet *)values;

@end
