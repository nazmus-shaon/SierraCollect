//
//  SCMainViewController.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 24.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCMainViewController.h"

@interface SCMainViewController (){
    UIView  *loadingView;
    UIActivityIndicatorView *activityIndicator;
}

@end

@implementation SCMainViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self buildUI];
}

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //Setup latest Floorplans
    //[(UISegmentedControl *)[self.demoSegment customView] setMomentary:YES];
    [(UISegmentedControl *)[self.demoSegment customView] addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    [self setUpSegemented];
    [self readSensorData];
    
}

- (void)setUpSegemented {
    [(UISegmentedControl *)[self.demoSegment customView] setSelectedSegmentIndex:[[SCAppCore shared] appMode]];
}

- (void)valueChanged {
    int selectedMode = [(UISegmentedControl *)[self.demoSegment customView] selectedSegmentIndex];
    
    if (selectedMode == 0) {
        //[[SCAppCore shared] setAppMode:[(UISegmentedControl *)[self.demoSegment customView] selectedSegmentIndex]];
        
        UIActionSheet * actionsheet = [[UIActionSheet alloc] initWithTitle:@"Choose" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
        [actionsheet addButtonWithTitle:@"Raspberry Pi"];
        [actionsheet addButtonWithTitle:@"Waspmote"];
        CGFloat segX = [[self.demoSegment customView] layer].position.x - ([[self.demoSegment customView] frame].size.width / 4); // manually change this
        CGFloat segY = [[self.demoSegment customView] layer].position.y + [[self.demoSegment customView] frame].size.height;
        [actionsheet showFromRect:CGRectMake(segX, segY, 0.1, 0.1) inView:self.view animated:YES];
        [(UISegmentedControl *)[self.demoSegment customView] setSelectedSegmentIndex:UISegmentedControlNoSegment];
        
        
    } else {
        [[SCAppCore shared] setAppMode:[(UISegmentedControl *)[self.demoSegment customView] selectedSegmentIndex]];
        [(UISegmentedControl *)[self.demoSegment customView] setTitle:@"Sensors" forSegmentAtIndex:0];
    }
}

- (void)buildUI {
    
    float width = 340;
    float height = 586;
    
    for (int i = 0; i < [[[SCDataService shared] getLastUpdatedFloorplans] count]; i++) {
        SCLatestRecordView *view = [[SCLatestRecordView alloc] initWithFrame:CGRectMake(i*width, 0, width, height) andFloorplan:[[[SCDataService shared] getLastUpdatedFloorplans] objectAtIndex:i]];
        [view setDelegate:self];
        [_latesRecordSrollView addSubview:view];
    }
    [_latesRecordSrollView setContentSize:CGSizeMake([[[SCDataService shared] getLastUpdatedFloorplans] count]*width, height-10)];
    
    
    [_bottomContainer.layer setCornerRadius:8];
    [_bottomContainer.layer setMasksToBounds:YES];
    _bottomContainer.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _bottomContainer.layer.borderWidth = 1.0f;
}

#pragma mark - SCLatestRecordViewDelegate

- (void)didClickOnFloorplan:(STFloor *)floorplan {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    SCDetailViewController *cont = [storyboard instantiateViewControllerWithIdentifier:@"detailController" ];
    cont.floorPlan = floorplan;
    [self.navigationController pushViewController:cont animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showLeftMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

- (IBAction)demoSegment:(id)sender {
}

- (IBAction)refreshInformation:(id)sender {
    [self showLoadingScreen];
    [self readSensorData];
}

- (void)showLoadingScreen {
    if (loadingView == nil) {
        loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [loadingView setBackgroundColor:[UIColor darkGrayColor]];
        [loadingView setAlpha:0];
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator setCenter:CGPointMake((self.view.frame.size.width/2) - 80, self.view.frame.size.height/2)];
        //[activityIndicator setFrame:CGRectMake(20, (self.view.frame.size.height-activityIndicator.frame.size.height)/2, activityIndicator.frame.size.width, activityIndicator.frame.size.height)];
        
        [loadingView addSubview:activityIndicator];
        
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [loadingLabel setBackgroundColor:[UIColor clearColor]];
        [loadingLabel setText:@"Loading..."];
        [loadingLabel setTextAlignment:NSTextAlignmentCenter];
        [loadingLabel setTextColor:[UIColor whiteColor]];
        [loadingLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]];
        [loadingView addSubview:loadingLabel];
    }
    
    [activityIndicator startAnimating];
    [self.view addSubview:loadingView];
    [UIView animateWithDuration:0.5 animations:^{
        [loadingView setAlpha:0.9];
    }];
}

- (void)hideLoadingScreen {
    [UIView animateWithDuration:0.5 animations:^{
        [loadingView setAlpha:0];
    } completion:^(BOOL finished) {
        [loadingView removeFromSuperview];
        [activityIndicator stopAnimating];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"modalSync"]) {
        NSLog(@"sync modal");
        SCSyncViewController *controller = segue.destinationViewController;
        [controller setDelegate:self];
    }
}

#pragma mark SCSyncViewControllerDelegate

- (void)removeModalController {
    //NSLog(@"dekllllele");
    [self.parentViewController dismissViewControllerAnimated:YES completion:^{
        [self buildUI];
    }];
}

#pragma mark ReadingSensors

- (void)readSensorData{
    [[SCDataService shared] getOtherSensorsAddTarget:self action:@selector(otherSensorsLoaded:)];
    [[SCDataService shared] getWifisensorsAddTarget:self action:@selector(wifiSensorsLoaded:)];
}

- (void)otherSensorsLoaded:(NSMutableArray *)otherSensors {
    NSLog(@"*** SCMainView found %d sensors ", [otherSensors count]);
    
    for (STMeasurement *measurement in otherSensors) {
        NSLog(@"*** objects: %@", measurement.value);
        
        if ([[self getSensorName:[measurement.sensor.type integerValue]] isEqualToString:@"Air Pressure"]) {
            
        } else if ([[self getSensorName:[measurement.sensor.type integerValue]] isEqualToString:@"Ambient Light"]) {
            self.brightnessLabel.text = [NSString stringWithFormat:@"%d Lux", [measurement.value integerValue]];
        } else if ([[self getSensorName:[measurement.sensor.type integerValue]] isEqualToString:@"Humidity"]) {
            self.humidityLabel.text = [NSString stringWithFormat:@"%d%% Humidity", [measurement.value integerValue]];
        } else if ([[self getSensorName:[measurement.sensor.type integerValue]] isEqualToString:@"Temperature"]) {
            self.temperatureLabel.text = [NSString stringWithFormat:@"%d Degrees", [measurement.value integerValue]];
        }
    }
    
    [self hideLoadingScreen];
}

-(void)wifiSensorsLoaded:(NSMutableArray *)wifiSensors{
    if ([wifiSensors count] > 0) {
        self.wifiLabel.text = [NSString stringWithFormat:@" %d Wifis", [wifiSensors count]];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //0 = Raspberry, 1 = Demo, 2 = Presentation, 3 = Waspmote
    if (buttonIndex == -1) {
        if ([[SCAppCore shared] appMode] == 1) { // If the previous mode was demo mode, go back to select that index
            [(UISegmentedControl *)[self.demoSegment customView] setSelectedSegmentIndex:1];
        }
    }
    else {
        if (buttonIndex == 0) {
            [[SCAppCore shared] setAppMode:0];
        } else if (buttonIndex == 1){
            [[SCAppCore shared] setAppMode:3];
        }
        [(UISegmentedControl *)[self.demoSegment customView] setTitle:[NSString stringWithFormat:@"%@", [actionSheet buttonTitleAtIndex:buttonIndex]] forSegmentAtIndex:0];
    }
    
}

#pragma mark 

- (NSString *)getSensorName:(SCSensorType)sensorID{
    return [[SCAppCore shared] wordingForSensorType:sensorID];
}

- (IBAction)uploadToWebDAV:(id)sender {
    NSLog(@"upload to WebDAV");
    [[SCWebDAVService shared] uploadSQLFile];
}
@end
