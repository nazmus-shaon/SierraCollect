//
//  SCAppCore.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 13.06.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCAppCore.h"

@implementation SCAppCore

+ (SCAppCore *)shared {
    static SCAppCore *shared;
    @synchronized(self)
    {
        if (!shared) {
            shared = [[SCAppCore alloc] init];
        }
        return shared;
    }
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setAppMode:(SCAppType)apptype {
    NSLog(@"Set Apptype: %i", apptype);
    [[NSUserDefaults standardUserDefaults] setInteger:apptype forKey:scDemoMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (SCAppType)appMode {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:scDemoMode]) {
        
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:SCAppTypeNormal forKey:scDemoMode];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return [[NSUserDefaults standardUserDefaults] integerForKey:scDemoMode];
}

- (NSString *)webDavBaseURL {
    switch ([self appMode]) {
        case SCAppTypeNormal: {
            return scWebDAVBaseURL;
            break;
        } case SCAppTypeDummy: {
            return scWebDAVBaseURLPresent;
            break;
        } case SCAppTypePresent: {
            return scWebDAVBaseURLPresent;
            break;
        }
        default:
            break;
    }
}

- (NSString *)webDavURL {
    switch ([self appMode]) {
        case SCAppTypeNormal: {
            return scWebDAVURL;
            break;
        } case SCAppTypeDummy: {
            return scWebDAVURLPresent;
            break;
        } case SCAppTypePresent: {
            return scWebDAVURLPresent;
            break;
        }
        default:
            break;
    }
}

- (NSString *)baseURL {
    switch ([self appMode]) {
        case SCAppTypeNormal: {
            return scRaspBaseURL;
            break;
        } case SCAppTypeDummy: {
            return scRaspBaseURLDemo;
            break;
        } case SCAppTypePresent: {
            return scRaspBaseURLPresent;
            break;
        }
        default:
            break;
    }
}

- (NSString *)measURL {
    switch ([self appMode]) {
        case SCAppTypeNormal: {
            return scRaspPIMeasURL;
            break;
        } case SCAppTypeDummy: {
            return scRaspPIMeasURLDemo;
            break;
        } case SCAppTypePresent: {
            return scRaspPIMeasURLPresent;
            break;
        }
        default:
            break;
    }
}

- (NSString *)wifiURL {
    switch ([self appMode]) {
        case SCAppTypeNormal: {
            return scRaspPIWifiURL;
            break;
        } case SCAppTypeDummy: {
            return scRaspPIWifiURLDemo;
            break;
        } case SCAppTypePresent: {
            return scRaspPIWifiURLPresent;
            break;
        }
        default:
            break;
    }
}

- (NSString *)wifiPathPattern {
    switch ([self appMode]) {
        case SCAppTypeNormal: {
            return scRaspWifiPattern;
            break;
        } case SCAppTypeDummy: {
            return scRaspWifiPatternDemo;
            break;
        } case SCAppTypePresent: {
            return scRaspWifiPatternPresent;
            break;
        }
        default:
            break;
    }
}

- (NSString *)measPathPattern {
    switch ([self appMode]) {
        case SCAppTypeNormal: {
            return scRaspMeasPattern;
            break;
        } case SCAppTypeDummy: {
            return scRaspMeasPatternDemo;
            break;
        } case SCAppTypePresent: {
            return scRaspMeasPatternPresent;
            break;
        }
        default:
            break;
    }
}
//woody july-14
- (NSString *)dhcpURL {
    switch ([self appMode]) {
        case SCAppTypeNormal: {
            return scRaspPIDHCPURL;
            break;
        } case SCAppTypeDummy: {
            return scRaspPIDHCPURLDemo;
            break;
        } case SCAppTypePresent: {
            return scRaspPIDHCPURLPresent;
            break;
        }
        default:
            break;
    }
}

- (NSString *)dhcpClientPathPattern {
    switch ([self appMode]) {
        case SCAppTypeNormal: {
            return scRaspDHCPPattern;
            break;
        } case SCAppTypeDummy: {
            return scRaspDHCPPatternDemo;
            break;
        } case SCAppTypePresent: {
            return scRaspDHCPPatternPresent;
            break;
        }
        default:
            break;
    }
}

- (NSString *)contMeasURL {
    switch ([self appMode]) {
        case SCAppTypeNormal: {
            return scRaspPIContinuousURL;
            break;
        } case SCAppTypeDummy: {
            return scRaspPIContinuousURLDemo;
            break;
        } case SCAppTypePresent: {
            return scRaspPIContinuousURLPresent;
            break;
        }
        default:
            break;
    }
}

- (NSString *)contMeasPathPattern {
    switch ([self appMode]) {
        case SCAppTypeNormal: {
            return scRaspContinuousPattern;
            break;
        } case SCAppTypeDummy: {
            return scRaspContinuousPatternDemo;
            break;
        } case SCAppTypePresent: {
            return scRaspContinuousPatternPresent;
            break;
        }
        default:
            break;
    }
}
//woody july-14
- (NSString *)wordingForSensorType:(SCSensorType)_sensorType {
    NSString *returnString;
    
    switch (_sensorType) {
        case SCSensorTemperature: {
            returnString = @"Temperature";
            break;
        } case SCSensorPressure: {
            returnString = @"Air Pressure";
            break;
        } case SCSensorHumidity: {
            returnString =@"Humidity";
            break;
        } case SCSensorAmbient: {
            returnString = @"Ambient Light";
            break;
        } default:
            returnString = @"Unknown Sensor";
            break;
    }
    return returnString;
}

- (SCSensorType)sensorTypeforWording:(NSString*)_wording {
    SCSensorType type;
    if ([_wording isEqualToString:@"Temperature"]) {
        type = SCSensorTemperature;
    } else if ([_wording isEqualToString:@"Air Pressure"]) {
        type = SCSensorPressure;
    } else if ([_wording isEqualToString:@"Humidity"]) {
        type = SCSensorHumidity;
    } else if ([_wording isEqualToString:@"Ambient Light"] ) {
        type = SCSensorAmbient;
    } else {
        type = SCSensorUnknown;
    }
    return type;
}

- (NSString *)unityForSensorType:(SCSensorType)_sensorType {
    NSString *returnString;
    
    switch (_sensorType) {
        case SCSensorTemperature: {
            returnString = @"°C";
            break;
        } case SCSensorPressure: {
            returnString = @"mbar";
            break;
        } case SCSensorHumidity: {
            returnString =@"%RH";
            break;
        } case SCSensorAmbient: {
            returnString = @"Lux";
            break;
        } default:
            returnString = @"/ 100 ";
            break;
    }
    return returnString;
}


@end
