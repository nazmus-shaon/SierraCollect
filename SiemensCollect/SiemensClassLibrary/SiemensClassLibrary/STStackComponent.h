//
//  STStackComponent.h
//  SiemensClassLibrary
//
//  Created by Andreas Seitz on 26.06.13.
//  Copyright (c) 2013 Asish Biswas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface STStackComponent : NSManagedObject

@property (nonatomic, retain) NSString * connectedUid;
@property (nonatomic, retain) NSNumber * deviceIdentifier;
@property (nonatomic, retain) NSNumber * enumerationType;
@property (nonatomic, retain) NSString * firmwareVersion;
@property (nonatomic, retain) NSString * hardwareVersion;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSString * uid;

@end
