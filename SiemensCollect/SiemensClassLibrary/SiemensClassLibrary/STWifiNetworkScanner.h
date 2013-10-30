//
//  STWifiNetworkScanner.h
//  SiemensClassLibrary
//
//  Created by Andreas Seitz on 26.06.13.
//  Copyright (c) 2013 Asish Biswas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class STWifiNetwork;

@interface STWifiNetworkScanner : NSManagedObject

@property (nonatomic, retain) NSString * iface;
@property (nonatomic, retain) NSSet *detectedWifiNetworkList;
@end

@interface STWifiNetworkScanner (CoreDataGeneratedAccessors)

- (void)addDetectedWifiNetworkListObject:(STWifiNetwork *)value;
- (void)removeDetectedWifiNetworkListObject:(STWifiNetwork *)value;
- (void)addDetectedWifiNetworkList:(NSSet *)values;
- (void)removeDetectedWifiNetworkList:(NSSet *)values;

@end
