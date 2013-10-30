//
//  SCDummyWifiNetwork.h
//  SiemensCollect
//
//  Created by RegMyUDiD on 6/16/13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCDummyWifiNetwork : NSObject

@property (nonatomic, retain) NSString * bitRates;
@property (nonatomic, retain) NSString * encryptionKey;
@property (nonatomic, retain) NSString * extra;
@property (nonatomic, retain) NSString * frequency;
@property (nonatomic, retain) NSString * ie;
@property (nonatomic, retain) NSString * macAddress;
@property (nonatomic, retain) NSString * mode;
@property (nonatomic, retain) NSString * protocol;
@property (nonatomic, retain) NSString * quality;
@property (nonatomic, retain) NSString * signalLevel;
@property (nonatomic, retain) NSString * ssid;

@end
