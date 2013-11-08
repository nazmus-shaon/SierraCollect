//
//  SCPopOverOverviewViewController.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 04.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCDataService.h"
#import "SCPopOverOverviewViewControllerDelegate.h"
#import "SCAbstractTableViewController.h"
#import "SCGraphViewController.h"

typedef enum{
    SingleCheckPoint,
    RoutePoint,
    ContinuosSensingPoint
} CheckPointType;

@interface SCPopOverOverviewViewController : SCAbstractTableViewController<UIAlertViewDelegate> {
    NSMutableArray *wifiSensorArray;
    NSMutableArray *otherSensorArray;
}

@property (nonatomic, weak) NSObject <SCPopOverOverviewViewControllerDelegate> *delegate;

@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *airPressureLabel;
@property (weak, nonatomic) IBOutlet UILabel *ambientLightLabel;
@property (weak, nonatomic) IBOutlet UILabel *co2Label;
@property (weak, nonatomic) IBOutlet UILabel *coordinateLabel;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
@property (weak, nonatomic) IBOutlet UIButton *collectNewDataButton;
@property (weak, nonatomic) IBOutlet UIButton *snrButton;
@property (weak, nonatomic) IBOutlet UIButton *mrButton;
@property (weak, nonatomic) IBOutlet UIButton *editTitleButton;

- (IBAction)collectNewData:(id)sender;
- (IBAction)deletePoint:(id)sender;
- (IBAction)startSubRoute:(id)sender;
- (IBAction)mergeRoute:(id)sender;
- (IBAction)editTitle:(id)sender;

@property (strong, nonatomic) STPoint *point;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSMutableArray *sensorPoints;

@end
