//
//  STWifiNetworkScanner.h
//  SierraClassLib
//
//  Created by Andreas Seitz on 08.07.13.
//  Copyright (c) 2013 Lehrstuhl für Angewandte Softwaretechnik. All rights reserved.
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
