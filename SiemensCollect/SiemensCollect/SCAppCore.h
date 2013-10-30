//
//  SCAppCore.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 13.06.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SCSensorTemperature = 216,
    SCSensorHumidity = 27,
    SCSensorAmbient = 21,
    SCSensorPressure = 221,
    SCSensorUnknown = 999
} SCSensorType;

typedef enum {
    SCAppTypeNormal = 0,
    SCAppTypeDummy = 1,
    SCAppTypePresent = 2
} SCAppType;

@interface SCAppCore : NSObject {
    SCAppType currentType;
}

+ (SCAppCore *)shared;

//@property (nonatomic, readwrite) BOOL demoMode;

- (SCAppType)appMode;
- (void)setAppMode:(SCAppType)apptype;

- (NSString *)webDavURL;
- (NSString *)webDavBaseURL;

- (NSString *)baseURL;
- (NSString *)measURL;
- (NSString *)wifiURL;
- (NSString *)dhcpURL;
- (NSString *)contMeasURL;
- (NSString *)wifiPathPattern;
- (NSString *)measPathPattern;
- (NSString *)dhcpClientPathPattern;
- (NSString *)contMeasPathPattern;

- (NSString *)wordingForSensorType:(SCSensorType)_sensorType;
- (SCSensorType)sensorTypeforWording:(NSString*)_wording;
- (NSString *)unityForSensorType:(SCSensorType)_sensorType;

@end
