//
//  SCGraphPickerViewController.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 10.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCGraphPickerViewController.h"

@interface SCGraphPickerViewController (){
    NSArray *sensorNames;
    NSArray *sensorIDs;
}

@end

@implementation SCGraphPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sensorPickerView.dataSource = self;
    self.sensorPickerView.delegate = self;
    [self.sensorPickerView reloadAllComponents];
    
    //216:Temperature
    //27:Humidity
    //21:Light
    //221:Air Pressure
    sensorNames = [[NSArray alloc] initWithObjects: @"Temperature", @"Humidity", @"Ambient Light", @"Air Pressure", nil];
    sensorIDs = [[NSArray alloc]
                     initWithObjects: [NSNumber numberWithInt:216],
                     [NSNumber numberWithInt:27],
                     [NSNumber numberWithInt:21],
                     [NSNumber numberWithInt:221], nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [sensorNames count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [sensorNames objectAtIndex:row];
}

#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Picked Object: %@", [sensorNames objectAtIndex:row]);
    [self.delegate pickedSensor:[sensorIDs objectAtIndex:row]];
}

@end
