//
//  SCGraphViewController.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 04.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCGraphViewController.h"

@interface SCGraphViewController (){
    NSString *currentThemeName;
    float comutativeSensorValue;
}

@end

@implementation SCGraphViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"--- GraphView got %d sensorPoints", [self.sensorPoints count]);

    if ([self.sensorPoints count] > 0) {
        self.plotItem = [[DatePlot alloc] init];
        self.plotItem.plotData = nil;
        
        [self setSensorName:SCSensorTemperature];
        [self sortSensorPoints];
        [self generateData:SCSensorTemperature];
        
        currentThemeName = @"Plain White";
        
        //NSLog(@"=== month: %d, day: %d, hour: %d, munite: %d", month, day, hour, munite);
	} else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"No data availavle to show\nPlease collect some data first" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
	
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.plotItem renderInView:self.mainGraphView withTheme:[self currentTheme] animated:YES];
}

- (IBAction)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)generateData:(SCSensorType)sensorID
{
    NSLog(@"=== Generaging Data");
    
    // Add some data
    NSMutableArray *newData = [NSMutableArray array];
    
    NSDate *startDate = [[self.sensorPoints objectAtIndex:0] time];
    NSDate *endDate = [[self.sensorPoints objectAtIndex:[self.sensorPoints count] - 1] time];    
    
    NSTimeInterval totalIntervalTime = [endDate timeIntervalSinceDate:startDate];
    
    self.plotItem.startDate = startDate;
    
    // setting x-axis interval of the graph
    self.plotItem.intervalX = hour;
    if (totalIntervalTime < month && totalIntervalTime > day) {
        self.plotItem.intervalX = day;
        self.plotItem.numberOfRecordsX = totalIntervalTime / day + 1;
        self.plotItem.xAxisTitle = @"Day";
    } else if (totalIntervalTime < day && totalIntervalTime > hour) {
        self.plotItem.intervalX = hour;
        self.plotItem.numberOfRecordsX = totalIntervalTime / hour + 1;
        self.plotItem.xAxisTitle = @"Hour";
    } else if (totalIntervalTime < hour && totalIntervalTime > munite) {
        self.plotItem.intervalX = munite;
        self.plotItem.numberOfRecordsX = totalIntervalTime / munite + 1 ;
        self.plotItem.xAxisTitle = @"Minute";
    }
    
//    self.plotItem.numberOfRecords = 30;
    comutativeSensorValue = 0;
    for (STSensorPoint *ssp in self.sensorPoints) {
        for (STMeasurement *measurement in [ssp.measurements allObjects]) {
            NSTimeInterval x = [ssp.time timeIntervalSinceDate:startDate];
            if ([measurement.sensor.type integerValue] == sensorID) {
                id y = [NSDecimalNumber numberWithFloat:[measurement.value floatValue]];
                
                [newData addObject:
                 [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSDecimalNumber numberWithFloat:x], [NSNumber numberWithInt:CPTScatterPlotFieldX],
                  y, [NSNumber numberWithInt:CPTScatterPlotFieldY], nil]];
                
                NSLog(@"=== value x: %f value y: %@", x, y);
                comutativeSensorValue += [measurement.value floatValue];
                
            }
        }
    }
    
    // setting y-axis interval of the graph    
    self.plotItem.intervalY = 100;
    self.plotItem.numberOfRecordsY = 10;
    self.plotItem.startingPositionY = 0;
    
    // TODO: set numberOfRecordsY based on maxY and minY
    if ([[self getSensorName:sensorID] isEqualToString:@"Air Pressure"]) {
        self.plotItem.intervalY = 50;
        self.plotItem.numberOfRecordsY = 5;
        self.plotItem.startingPositionY = 800;
        self.plotItem.yAxisTitle = @"mbar";
    } else if ([[self getSensorName:sensorID] isEqualToString:@"Ambient Light"]) {
        self.plotItem.intervalY = 100;
        self.plotItem.numberOfRecordsY = 15;
        self.plotItem.yAxisTitle = @"Lux";
    } else if ([[self getSensorName:sensorID] isEqualToString:@"Humidity"]) {
        self.plotItem.intervalY = 10;
        self.plotItem.numberOfRecordsY = 10;
        self.plotItem.yAxisTitle = @"%";
    } else if ([[self getSensorName:sensorID] isEqualToString:@"Temperature"]) {
        self.plotItem.intervalY = 5;
        self.plotItem.numberOfRecordsY = 12;
        //self.plotItem.startingPositionY = -20;
        self.plotItem.yAxisTitle = @"°C";
    }
    
    self.plotItem.plotData = newData;
}

- (void)sortSensorPoints{
    NSArray *sortedArray = [self.sensorPoints sortedArrayUsingComparator: ^(STSensorPoint *obj1, STSensorPoint *obj2) {
        return [obj1.time compare:obj2.time];
    }];
    self.sensorPoints = [NSMutableArray arrayWithArray:sortedArray];
}

-(CPTTheme *)currentTheme
{
    CPTTheme *theme = nil;
    
    if (currentThemeName == nil) {
        theme = nil;
    }
    else {
        theme = [CPTTheme themeNamed:currentThemeName];
    }
    
    return theme;
}

- (void)setSensorName:(SCSensorType)sensorID{
    self.plotItem.title = [[SCAppCore shared] wordingForSensorType:sensorID];
}

- (NSString *)getSensorName:(SCSensorType)sensorID{
    return [[SCAppCore shared] wordingForSensorType:sensorID];
}

#pragma mark - SCGraphPickerViewControllerDelegate

- (void)pickedSensor:(NSNumber *) sensorID{
    NSLog(@"Delegated: Picked Sensor: %@", sensorID);

    [self setSensorName:[sensorID integerValue]];
    [self.plotItem killGraph];    
    [self generateData:[sensorID integerValue]];
    [self.plotItem renderInView:self.mainGraphView withTheme:[self currentTheme] animated:YES];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {    
    
    if([segue.identifier isEqualToString:@"graphPickerSegue"]) {
        
        SCGraphPickerViewController *graphPickerViewController = segue.destinationViewController;        
        [graphPickerViewController setDelegate:self];
    }
}

@end
