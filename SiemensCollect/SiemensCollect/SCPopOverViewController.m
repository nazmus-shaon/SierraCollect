//
//  SCPopOverViewController.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 13.06.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCPopOverViewController.h"
#import <SBJson/SBJson.h>
#import "SCAppDelegate.h"

@interface SCPopOverViewController (){ //<SBJsonStreamParserAdapterDelegate>

}

@end

@implementation SCPopOverViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.managedObjectContext = [(SCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    wifiSensorArray = [NSMutableArray array];
    otherSensorArray = [NSMutableArray array];
    self.managedObjectStore = [(SCAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectStore];
    
//    [self loadDataFromServer];//Now it should read data from database
    
    //get the wifi sensor data, sort it and assign it agian
    wifiSensorArray = [NSMutableArray arrayWithArray:[[self.sensorPoint wifiNetworks] allObjects]];
    NSArray *sortedArray = [wifiSensorArray sortedArrayUsingComparator: ^(STWifiNetwork *obj1, STWifiNetwork *obj2) {
        return [obj1.ssid compare:obj2.ssid];
    }];
    wifiSensorArray = [NSMutableArray arrayWithArray:sortedArray];
    
    //get the measurement sensor data, sort it and assign it agian
    otherSensorArray = [NSMutableArray arrayWithArray:[[self.sensorPoint measurements] allObjects]];
    sortedArray = [otherSensorArray sortedArrayUsingComparator: ^(STMeasurement *obj1, STMeasurement *obj2) {
        return [obj1.sensor.unit compare:obj2.sensor.unit];
    }];
    otherSensorArray = [NSMutableArray arrayWithArray:sortedArray];
    
//    NSLog(@"******** wifisensor array: %@", wifiSensorArray);
//    NSLog(@"******** STPoint: %@", [self.point.sensorPoints anyObject]);
    NSLog(@"******** STSensorPoint: %@", self.sensorPoint);
    
    
    
    [self addImageToView:[[SCWebDAVService shared] imageForSensorPoint:self.sensorPoint]];
}

- (void)addImageToView:(UIImage *)_image {

    if (_image == nil) {
        NSLog(@"no image file founde");
        [self.pictureScrollView setUserInteractionEnabled:NO];
    } else {
        UIImageView *view = [[UIImageView alloc] initWithImage:_image];
        [view setUserInteractionEnabled:NO];
        //NSLog(@"frame: %@", self.pictureScrollView.frame.size);
        [view setFrame:CGRectMake(0, 0, 320, 180)];
        [self.pictureScrollView setUserInteractionEnabled:NO];
        [self.pictureScrollView addSubview:view];
        //[self.pictureScrollView setUserInteractionEnabled:YES];
        
        UIControl *control = [[UIControl alloc] initWithFrame:view.frame];
        [control addTarget:self action:@selector(retakePicture) forControlEvents:UIControlEventTouchUpInside];
        [control setBackgroundColor:[UIColor clearColor]];
        [view addSubview:control];
    }

}

- (void)retakePicture {
    [self callImageStitcher];
}

- (void)loadDataFromServer {
    NSLog(@"load data from server");
    [[SCDataService shared] getWifisensorsAddTarget:self action:@selector(wifiSensorsLoaded:)];
    [[SCDataService shared] getOtherSensorsAddTarget:self action:@selector(otherSensorsLoaded:)];    
}

#pragma mark button functions

- (IBAction)photoButtonClicked:(id)sender {
//    NSLog(@"Photo Button Clicked");
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Take Panorama" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Library", nil];
//    [actionSheet showInView:self.view];
    [self callImageStitcher];
}


- (IBAction)refetchData:(id)sender {
    NSLog(@"Refetch Data");
    [self loadDataFromServer];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"ActionSheetButton %i clicked", buttonIndex);
    //TODO GO TO PANORAMA CAPTURE FUNCTION HERE
    if (buttonIndex == 0) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        [controller setSourceType:UIImagePickerControllerSourceTypeCamera];
        [controller setDelegate:self];
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        //[self callImageStitcher]
    }
}

- (void)callImageStitcher {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_stitching" bundle:[NSBundle mainBundle]];
    imageCont = [storyboard instantiateViewControllerWithIdentifier:@"stitcher"];
    [imageCont setDelegate:self];
    [self presentViewController:imageCont animated:YES completion:nil];
}

#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0) {
    [picker dismissViewControllerAnimated:YES completion:^{
        //
    }];
    NSLog(@"to delegate");
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:_headerView.frame];
    [imgView setImage:image];
    [_headerView addSubview:imgView];
    
    //Upload Image
    
    [[SCWebDAVService shared] uploadImage:image withName:@"test"];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return [[self.fetchedResultsController sections] count];
    return 2;//number of section(s) of the TableView
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    switch (section) {
        case 0: //meas
            title = @"Measurement";
            break;
        case 1: {
            title = @"Wifis";
            break;
        }
        default:
            title = @"21:32";
            break;
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int inti;
    switch (section) {
        case 0: //meas
            inti = [otherSensorArray count];
            break;
        case 1: {
            inti = [wifiSensorArray count];
            break;
        }
        default:
            inti = 0;
            break;
    }
    return inti;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"WifiCell"];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}



- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    int otherSensorType;
    switch (indexPath.section) {
        case 0: //meas
            otherSensorType = [[[otherSensorArray objectAtIndex:indexPath.row] sensor].type integerValue];
            NSLog(@"****** Sensor Types: %d: for Unit: %@", otherSensorType, [[otherSensorArray objectAtIndex:indexPath.row] sensor].unit);

            cell.textLabel.text = [NSString stringWithFormat:@"%.1f", [[(STMeasurement *)[otherSensorArray objectAtIndex:indexPath.row] value] doubleValue]];
            
            cell.detailTextLabel.text = [[[(STMeasurement *)[otherSensorArray objectAtIndex:indexPath.row] sensor].unit stringByReplacingOccurrencesOfString:@"Ã" withString:@""] stringByReplacingOccurrencesOfString:@"Â" withString:@""];
            switch (otherSensorType) {
                case 216://Temperature
                    cell.imageView.image = [UIImage imageNamed:@"icon_temp"];
                    break;
                case 27://Humidity
                    cell.imageView.image = [UIImage imageNamed:@"icon_humidity"];
                    break;
                case 21://Light
                    cell.imageView.image = [UIImage imageNamed:@"icon_bright"];
                    break;
                case 221://Air Pressure
                    cell.imageView.image = [UIImage imageNamed:@"icon_pressure"];
                    break;
                    
                default:
                    cell.imageView.image = [UIImage imageNamed:@"icon_wifi"];
                    break;
            }
            break;
        case 1: {
            //[cell.detailTextLabel setText:[[wifiSensorArray objectAtIndex:indexPath.row] macAddress]];
            cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", [[[wifiSensorArray objectAtIndex:indexPath.row] ssid] stringByReplacingOccurrencesOfString:@"\"" withString:@""],[[wifiSensorArray objectAtIndex:indexPath.row] macAddress]];

            cell.detailTextLabel.text = [NSString stringWithFormat:@"Quality:%@, Signal:%@", [[wifiSensorArray objectAtIndex:indexPath.row] quality], [[wifiSensorArray objectAtIndex:indexPath.row] signalLevel]];
            
            cell.imageView.image = [UIImage imageNamed:@"icon_wifi"];
            break;
        }
        default:
            break;
    }
}


-(void)wifiSensorsLoaded:(NSMutableArray *)wifiSensors{
    wifiSensorArray = wifiSensors;
    [self.tableView reloadData];
}

-(void)otherSensorsLoaded:(NSMutableArray *)otherSensors{
    otherSensorArray = otherSensors;
    [self.tableView reloadData];
}

#pragma mark STImageCaptureDelegate

- (void)imageChosen:(NSDictionary *)imageDictionary {
    NSLog(@"image chosen with dict: %@", imageDictionary);
    [imageCont dismissViewControllerAnimated:YES completion:^{
        //Upload PICTURE
        NSLog(@"dismissed");
        
        [[SCWebDAVService shared] generatFolderforPoint:self.sensorPoint andImage:[imageDictionary objectForKey:@"image"]];
        
        
        [self addImageToView:[imageDictionary objectForKey:@"image"]];
        
        //update sensor point
        [self.sensorPoint setPitch:[imageDictionary objectForKey:@"pitch"]];
        [self.sensorPoint setRoll:[imageDictionary objectForKey:@"roll"]];
        [self.sensorPoint setImageType:[imageDictionary objectForKey:@"type"]];
        [self.sensorPoint setYaw:[imageDictionary objectForKey:@"yaw"]];
        
        NSError *error;
        [self.managedObjectContext saveToPersistentStore:&error];
        
        
    }];
}


@end
