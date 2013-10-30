//
//  STDHCPClient.h
//  SiemensCollect
//
//  Created by Asish Biswas on 7/14/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STDHCPClient : NSObject

@property (strong, nonatomic) NSDate *leaseExpirationTime;
@property (strong, nonatomic) NSString *macAddress;
@property (strong, nonatomic) NSString *ipAddress;
@property (strong, nonatomic) NSString *clientName;
@property (strong, nonatomic) NSNumber *tinkerforgeBrick;

@end
