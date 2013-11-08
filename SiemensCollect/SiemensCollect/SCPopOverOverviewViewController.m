//
//  SCPopOverOverviewViewController.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 04.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCPopOverOverviewViewController.h"

@interface SCPopOverOverviewViewController () {
    BOOL isWifiSensorCollected;
    BOOL isOtherSensorCollected;
    
    double avgTemperature;
    double avgHumidity;
    double avgAmbientLight;
    double avgAirPressure;
    
    double avgLumosity;
    double avgO2;
    double avgCo2;
    double avgTempWasp;
    double avgHumidityWasp;
    
    int count;
    #define ChangeTitleAlert 1
}

@end

@implementation SCPopOverOverviewViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //NSLog(@"******** PopoverOverviewVC.viewWillAppear : point in overview: %@", self.point);
    
    [self sortSensorPoints];
    self.sensorPoints = [NSMutableArray arrayWithArray: [self.point.sensorPoints allObjects]];
    [self sortSensorPoints];
    
    if ([self.point.pointType integerValue] == ContinuosSensingPoint) {
        [self hideCollectNewButton];
        [self addButtonsForContinuosSensing];
        
        NSLog(@"--- PopoverOverviewVC.viewWillAppear : point.sensorPoints coung: %d", [self.point.sensorPoints count]);
        // Read Continuous Measurements
        //[[SCDataService shared] getContinuousMeasurementsAddTarget:self action:@selector(continuousMeasurementsLoaded:)];
        //[self continuousMeasurementsLoaded:[self.point.sensorPoints allObjects]];
    }
    
    [self refreshUI];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.managedObjectContext = [(SCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

-(void)hideCollectNewButton{
    self.collectNewDataButton.hidden = YES;
}

- (void)addButtonsForContinuosSensing{
    //enable button
    UIButton *enableButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    enableButton.frame = CGRectMake(20, -1, 136, 32);
    [enableButton setTitle:@"Enable" forState:UIControlStateNormal];
    [self.buttonContainerView addSubview:enableButton];
    [enableButton addTarget:self action:@selector(enableButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //disable button
    UIButton *disableButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    disableButton.frame = CGRectMake(164, -1, 136, 32);
    [disableButton setTitle:@"Disable" forState:UIControlStateNormal];
    [self.buttonContainerView addSubview:disableButton];
    [disableButton addTarget:self action:@selector(disableButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)enableButtonPressed:(UIButton *)sender{
    NSLog(@"Enable Button Pressed");
    //[[SCDataService shared] getContinuousMeasurementsAddTarget:self action:@selector(continuousMeasurementsLoaded:)];
}

- (void)disableButtonPressed:(UIButton *)sender{
    NSLog(@"Disable Button Pressed");
}

- (void)refreshUI {
    [self.tableView reloadData];
    [self calculateAverageSensorValues];
    if ([[SCAppCore shared] appMode] == 3) { // Waspmote
        self.airPressureLabel.text = [NSString stringWithFormat:@"Oxygen: %.1f", avgO2];
        self.humidityLabel.text = [NSString stringWithFormat:@"Humidity: %.1f", avgHumidityWasp];
        self.temperatureLabel.text = [NSString stringWithFormat:@"Temperature: %.1f", avgTempWasp];
        self.ambientLightLabel.text = [NSString stringWithFormat:@"Light: %.1f", avgLumosity];
        self.co2Label.text = [NSString stringWithFormat:@"Carbon-di-Oxide: %.1f", avgCo2];
        [self.co2Label setHidden:NO];
    } else {
        self.airPressureLabel.text = [NSString stringWithFormat:@"Air Pressure: %.1f", avgAirPressure];
        self.humidityLabel.text = [NSString stringWithFormat:@"Humidity: %.1f", avgHumidity];
        self.temperatureLabel.text = [NSString stringWithFormat:@"Temperature: %.1f", avgTemperature];
        self.ambientLightLabel.text = [NSString stringWithFormat:@"Light: %.1f", avgAmbientLight];
        [self.co2Label setHidden:YES];
    }
    
}

- (void)calculateAverageSensorValues{
    count = 0;
    avgTemperature = 0;
    avgHumidity = 0;
    avgAmbientLight = 0;
    avgAirPressure = 0;
    
    avgLumosity = 0;
    avgO2 = 0;
    avgCo2 = 0;
    avgTempWasp = 0;
    avgHumidityWasp = 0;
    
    for (STSensorPoint *ssp in [self.point.sensorPoints allObjects]) {
        for (STMeasurement *measurement in [ssp.measurements allObjects]) {
            switch ([measurement.sensor.type integerValue]) {
                case 216://SensorType.Temperature:// asish made 216 as temperature in localhose
                    avgTemperature += [measurement.value floatValue];
                    break;
                case 27://SensorType.Humidity:// asish made 27 as humidity
                    avgHumidity += [measurement.value floatValue];
                    break;
                case 21://SensorType.AmbientLight:// asish made 21 as ambiant light
                    avgAmbientLight += [measurement.value floatValue];
                    break;
                case 221://SensorType.Airpressure:// asish made 221 as airpressure
                    avgAirPressure += [measurement.value floatValue];
                    break;
                case 231://Lumosity - Sakib, added for waspmote
                    avgLumosity += [measurement.value floatValue];
                    break;
                case 232://O2 - Sakib, added for waspmote
                    avgO2 += [measurement.value floatValue];
                    break;
                case 233://CO2 - Sakib, added for waspmote
                    avgCo2 += [measurement.value floatValue];
                    break;
                case 234://Temperature - Sakib, added for waspmote
                    avgTempWasp += [measurement.value floatValue];
                    break;
                case 235://Humidity - Sakib, added for waspmote
                    avgHumidityWasp += [measurement.value floatValue];
                    break;
                default:
                    break;
            }
        }
        count++;
    }
    
    avgTemperature /= count;
    avgHumidity /= count;
    avgAmbientLight /= count;
    avgAirPressure /= count;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Measurements";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.sensorPoints count] > 0){
//        STSensorPoint *stsp = [self.sensorPoints objectAtIndex:[self.sensorPoints count] - 1];
//        if ([stsp.measurements count] == 0) {
//            return [self.sensorPoints count] - 1;
//        } else {
//            return [self.sensorPoints count];
//        }
        
        int counter = 0;
        for (STSensorPoint *sensorPoint in self.sensorPoints) {
            if ([sensorPoint.measurements count] > 0) {
                counter ++;
            }
        }
        return counter;
    } else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"popoverviewcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:CellIdentifier];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"E - dd.MM.yyyy:hh:mm:ss"];
    
    STSensorPoint *stsp = [self.sensorPoints objectAtIndex:indexPath.row];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@", [formatter stringFromDate:stsp.time]]];
    
    //NSLog(@"--- time: %@", stsp.time);
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    SCPopOverViewController *popoverVC = [storyboard instantiateViewControllerWithIdentifier:@"popoverContentCont"];
    
    popoverVC.sensorPoint = [self.sensorPoints objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:popoverVC animated:YES];
}

- (IBAction)collectNewData:(id)sender {
    NSLog(@"******** Collect New Data");
    [self showLoadingScreen];

    [[SCDataService shared] getWifisensorsAddTarget:self action:@selector(wifiSensorsLoaded:)];
    [[SCDataService shared] getOtherSensorsAddTarget:self action:@selector(otherSensorsLoaded:)];

}

-(void)wifiSensorsLoaded:(NSMutableArray *)wifiSensors{
    isWifiSensorCollected = TRUE;
    wifiSensorArray = wifiSensors;
   // NSLog(@"******** loading wifi data from server %d", [wifiSensorArray count]);
    if (isWifiSensorCollected && isOtherSensorCollected) {
        NSLog(@"******** SaveCheckPoint is about to call");
        [self saveSensorPoint];
        isOtherSensorCollected = FALSE;
        isWifiSensorCollected = FALSE;
    }
}

-(void)otherSensorsLoaded:(NSMutableArray *)otherSensors{
    otherSensorArray = otherSensors;
    isOtherSensorCollected = TRUE;
    //NSLog(@"******** loading other sensor data from server %d", [otherSensorArray count]);
    if (isWifiSensorCollected && isOtherSensorCollected) {
        NSLog(@"******** SaveCheckPoint is about to call ***");
        [self saveSensorPoint];
        isOtherSensorCollected = FALSE;
        isWifiSensorCollected = FALSE;
    }
}

- (void)saveSensorPoint {
    NSLog(@"save now");
    [self hideLoadingScreen];
    STSensorPoint *ssp = [NSEntityDescription insertNewObjectForEntityForName:@"STSensorPoint" inManagedObjectContext:self.managedObjectContext];
    
    [ssp setTime:[NSDate date]];
    
    // *********  Woody *********
    NSLog(@"******* PopoverOverviewVC.saveCheckPointForAnnotaton has %d otherSensorArray objects and %d wifiSensor objects", [otherSensorArray count], [wifiSensorArray count]);
    
    [ssp setWifiNetworks:[NSSet setWithArray:wifiSensorArray]];
    [ssp setMeasurements:[NSSet setWithArray:otherSensorArray]];
    // *********  Woody *********
    
    [self.point addSensorPointsObject:ssp];
    [self.sensorPoints addObject:ssp];
    NSLog(@"******** PopoverOverviewVC.saveSensorPoint : count of sensorPoints: %d", [self.sensorPoints count]);
    [self sortSensorPoints];
    
    NSError *error = nil;
    [self.managedObjectContext saveToPersistentStore:&error];
    [self refreshUI];
}

- (void) sortSensorPoints{
    NSArray *sortedArray = [self.sensorPoints sortedArrayUsingComparator: ^(STSensorPoint *obj1, STSensorPoint *obj2) {
        return [obj2.time compare:obj1.time];
    }];
    self.sensorPoints = [NSMutableArray arrayWithArray:sortedArray];
}

- (void)deletePoint:(id)sender {
    NSLog(@"Delete Point");
    [self.delegate deleteCheckPointClicked];
}

- (void)startSubRoute:(id)sender {
    NSLog(@"Start Sub Route");
    [self.delegate startSubRouteClicked];
}

- (void)mergeRoute:(id)sender {
    NSLog(@"Merge Route");
    [self.delegate mergeRouteClicked];
}

- (void)editTitle:(id)sender {
    NSLog(@"Edit Checkpoint Title");
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Edit checkpoint name" message:@"Please enter a name for this checkpoint" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = ChangeTitleAlert;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    //alertTextField.keyboardType = UIKeyboardTypeNumberPad;
    alertTextField.placeholder = @"";
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Entered: %@ %d",[[alertView textFieldAtIndex:0] text], buttonIndex);
    switch (alertView.tag) {
        case ChangeTitleAlert:
            
            switch (buttonIndex) {
                case 1: //Done
                    
                    if( [[[alertView textFieldAtIndex:0] text] length] > 0 )
                    {
                        [self.delegate editTitleClicked:[[alertView textFieldAtIndex:0] text]];
                        [self setTitle:[[alertView textFieldAtIndex:0] text]];
                    }
                    else
                    {
                        //Do nothing
                    }
                    
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"--- GraphView Segue Clicked with %d sensorPoints", [self.sensorPoints count]);

    if([segue.identifier isEqualToString:@"graphViewSegue"]) {
        SCGraphViewController *graphViewController = segue.destinationViewController;
        NSMutableArray *sensorData = [NSMutableArray array];
        for (STSensorPoint *sensorPoint in self.sensorPoints) {
            if ([sensorPoint.measurements count] > 0) {
                [sensorData addObject:sensorPoint];
            }
        }
        graphViewController.sensorPoints = sensorData;
    }
}

@end
