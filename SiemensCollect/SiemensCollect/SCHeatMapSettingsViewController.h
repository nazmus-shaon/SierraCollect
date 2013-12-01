//
//  SCHeatMapSettingsViewController.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 09.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCAbstractTableViewController.h"
#import "SCWebDAVService.h"


#define SCHeatMapSettingsResolution     @"SCHeatMapSettingsResolution"
#define SCHeatMapSettingsType           @"SCHeatMapSettingsType"
#define SCHeatMapSettingsValue          @"SCHeatMapSettingsValue"
#define SCHeatMapSettingsTime           @"SCHeatMapSettingsTime"

typedef enum {
    SCHeatMapTypeSensor = 0,
    SCHeatMapTypeWifi = 1
} SCHeatMapType;

@class SCHeatMapSettingsViewController;
@protocol SCHeatMapSettingsViewControllerDelegate <NSObject>

- (void)closedController:(SCHeatMapSettingsViewController *)cont withSettings:(NSDictionary *)settings;
- (void)closedController:(SCHeatMapSettingsViewController *)cont withSettings:(NSDictionary *)settings andReadyHeatMap:(NSString *)_imageName;
- (void)dismissController:(SCHeatMapSettingsViewController *)cont;

@end



@interface SCHeatMapSettingsViewController : SCAbstractTableViewController


@property (strong, nonatomic) NSArray *availableSensors;
@property (strong, nonatomic) NSArray *availableWifis;
@property (strong, nonatomic) NSArray *storedHeatMaps;
@property (strong, nonatomic) NSMutableArray *storedHeatMapsNiceNaming;

@property (weak) id<SCHeatMapSettingsViewControllerDelegate>delegate;
@property (strong, nonatomic) IBOutlet UISlider *resoultionSlider;

- (IBAction)closeModal:(id)sender;
- (IBAction)goGenerateHeatMap:(id)sender;

- (void)setDataForWifis:(NSArray *)_wifi forSensors:(NSArray *)_sensors forStoredHeatMaps:(NSArray *)_heatMaps;

@end
