//
//  SCHeatMapViewController.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 02.07.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCHeatMapViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SCHeatMapViewController () {
    float imageWidth;
    float imageHeigth;
    
    double avgValue;
    int count;
    
    float resolution;
}

@end

@implementation SCHeatMapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Heatmap"];
    
    //NSLog(@"floor plan: %@", self.floorPlan.relatedFile);
    //NSLog(@"frame width: %f height: %f", self.view.frame.size.width, self.view.frame.size.height);
    
    //SET CORRECT IMAGE
    //UIImage *testImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_square", [self.floorPlan.relatedFile stringByReplacingOccurrencesOfString:@".pdf" withString:@""]]];
    UIImage *testImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@", [self.floorPlan.relatedFile stringByReplacingOccurrencesOfString:@".pdf" withString:@""]]];
    mapImageView = [[UIImageView alloc] initWithImage:testImage];
    [mapImageView setFrame:CGRectMake(0, 0, 2000, 2000)];
    
    //SET UP SCROLL VIEW
    [self.scrollView setMinimumZoomScale:660/mapImageView.frame.size.width];
    [self.scrollView setMaximumZoomScale:1];
    [self.scrollView addSubview:mapImageView];
    [self.scrollView setDelegate:self];
    [self.scrollView setContentSize:mapImageView.frame.size];
    
    //NSLog(@"test image width = %f image height: %f", testImage.size.width, testImage.size.height);
    
    //PREPARE FOR XY - LATLNG ALLOCATION
    imageWidth = mapImageView.frame.size.width;
    imageHeigth = mapImageView.frame.size.height;
    
    
    //HIDE THE LOADING SCREEN
    [loadingView setAlpha:0];
    [loadingView setHidden:YES];
    
    heatmap = [[STHeatmap alloc] initWithSize:mapImageView.frame.size];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scrollView setZoomScale:660/mapImageView.frame.size.width animated:YES];
    [self viewSettings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)viewSettings {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    UINavigationController *navHeatVC = [storyboard instantiateViewControllerWithIdentifier:@"heatMapSettingsNav"];
    
    if ( [navHeatVC.viewControllers objectAtIndex:0]) {
        [(SCHeatMapSettingsViewController*)[navHeatVC.viewControllers objectAtIndex:0] setDelegate:self];
        [(SCHeatMapSettingsViewController*)[navHeatVC.viewControllers objectAtIndex:0] setDataForWifis:[self filterAvailableWifis] forSensors:[self filterAvailableSensors] forStoredHeatMaps:[[SCWebDAVService shared] fetchHeatMapImagesforFloor:self.floorPlan]];
    }
    [navHeatVC setModalPresentationStyle:UIModalPresentationFormSheet];
    [self.navigationController presentViewController:navHeatVC animated:YES completion:nil];
}

- (NSArray *)filterAvailableSensors {
    NSMutableArray *availableSensors = [NSMutableArray array];
    for (STPoint *point in self.floorPlan.points) {
        for (STSensorPoint *sensorPoint in [point.sensorPoints allObjects]) {
            for (STMeasurement *meas in [sensorPoint.measurements allObjects]) {
                if (![availableSensors containsObject:[[SCAppCore shared] wordingForSensorType:meas.sensor.type.intValue]]) {
                    [availableSensors addObject:[[SCAppCore shared] wordingForSensorType:meas.sensor.type.intValue]];
                }                
            }
        }
    }
    availableSensors = (NSMutableArray*)[availableSensors sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj2 compare:obj1];
    }];
    return availableSensors;
}

- (NSArray *)filterAvailableWifis {
    NSMutableArray *availableWifis = [NSMutableArray array];
    for (STPoint *point in self.floorPlan.points) {
        for (STSensorPoint *sensorPoint in [point.sensorPoints allObjects]) {
            for (STWifiNetwork *wifi in [sensorPoint.wifiNetworks allObjects]) {
                if (![availableWifis containsObject:wifi.ssid]) {
                    [availableWifis addObject:wifi.ssid];
                }
            }
        }
    }
    availableWifis = (NSMutableArray*)[availableWifis sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj2 compare:obj1];
    }];
    return availableWifis;
}

- (void)showLoadingScreen {
    [heatMapLegend setHidden:YES];
    [heatMapDateOption setHidden:YES];
    [loadingActivity startAnimating];
    [loadingView setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^{
        [loadingView setAlpha:0.9];
        [heatMapLegend setAlpha:0];
        [heatMapDateOption setAlpha:0];
    } completion:^(BOOL finished) {
        //[heatMapLegend setHidden:YES];
    }];
    [self.settingsBtn setEnabled:NO];
    [self.exportBtn setEnabled:NO];
}

- (void)hideLoadingScreen {
    [UIView animateWithDuration:0.3 animations:^{
        [loadingView setAlpha:0];
        [heatMapLegend setAlpha:1];
        [heatMapDateOption setAlpha:1];
    } completion:^(BOOL finished) {
        [loadingActivity stopAnimating];
        [self.settingsBtn setEnabled:YES];
        [self.exportBtn setEnabled:newGeneratedHeatMap];
    }];
}


#pragma mark UIScrollViewDelegate

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return mapImageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)pScrollView {
    CGRect innerFrame = mapImageView.frame;
    CGRect scrollerBounds = pScrollView.bounds;
    
    if ( ( innerFrame.size.width < scrollerBounds.size.width ) || ( innerFrame.size.height < scrollerBounds.size.height ) ) {
        CGFloat tempx = mapImageView.center.x - ( scrollerBounds.size.width / 2 );
        CGFloat tempy = mapImageView.center.y - ( scrollerBounds.size.height / 2 );
        CGPoint myScrollViewOffset = CGPointMake( tempx, tempy);
        
        pScrollView.contentOffset = myScrollViewOffset;
    }
    
    UIEdgeInsets anEdgeInset = { 0, 0, 0, 0};
    if ( scrollerBounds.size.width > innerFrame.size.width ) {
        anEdgeInset.left = (scrollerBounds.size.width - innerFrame.size.width) / 2;
        anEdgeInset.right = -anEdgeInset.left;  // I don't know why this needs to be negative, but that's what works
    }
    if ( scrollerBounds.size.height > innerFrame.size.height ) {
        anEdgeInset.top = (scrollerBounds.size.height - innerFrame.size.height) / 2;
        anEdgeInset.bottom = -anEdgeInset.top;  // I don't know why this needs to be negative, but that's what works
    }
    pScrollView.contentInset = anEdgeInset;
}

- (IBAction)exportHeatMap:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        mailCont = [[MFMailComposeViewController alloc] init];
        [mailCont setSubject:[NSString stringWithFormat:@"Sierra Collect - Heatmap - %@", [infoDict objectForKey:SCHeatMapSettingsValue]]];
        [mailCont setMessageBody:@"" isHTML:NO];
        [mailCont addAttachmentData:UIImagePNGRepresentation(generatedHeatImage) mimeType:@"image/png" fileName:@"heatmap.png"];
        UIGraphicsBeginImageContext(heatMapLegend.frame.size);
        [heatMapLegend.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [mailCont addAttachmentData:UIImagePNGRepresentation(viewImage) mimeType:@"image/png" fileName:@"heatmap_legend.png"];
        [mailCont setMailComposeDelegate:self];
        [self.navigationController presentViewController:mailCont animated:YES completion:^{
            
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Your device cannot send mail" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)goToSettings:(id)sender {
    [self viewSettings];
}

- (IBAction)saveHeatMap:(id)sender {
    NSMutableDictionary *settingsDict = [NSMutableDictionary dictionaryWithDictionary:infoDict];
    [[SCWebDAVService shared] saveHeatMapToDocuments:generatedHeatImage forFloor:self.floorPlan withInformation:settingsDict];
    [[SCWebDAVService shared] saveHeatmapToWebDav:generatedHeatImage forFloor:self.floorPlan withInformation:settingsDict];
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    NSLog(@"done");
    [mailCont dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark SCHeatMapSettingsViewControllerDelegate

- (void)closedController:(SCHeatMapSettingsViewController *)cont withSettings:(NSDictionary *)settings {
    newGeneratedHeatMap = YES;
    infoDict = settings;
    NSLog(@"Close With Dict: %@", settings);
    [cont dismissViewControllerAnimated:YES completion:^{
        [self setTitle:[NSString stringWithFormat:@"Heatmap - %@", [settings objectForKey:SCHeatMapSettingsValue]]];
        resolution = floorf(20-[[settings objectForKey:SCHeatMapSettingsResolution] floatValue]);
        switch ([[settings objectForKey:SCHeatMapSettingsType] intValue]) {
            case SCHeatMapTypeSensor: {
                [self generateHeatMapforSensorType:[[SCAppCore shared] sensorTypeforWording:[settings objectForKey:SCHeatMapSettingsValue]]];
                break;
            } case SCHeatMapTypeWifi: {
                [self generateHeatMapforWifi:[settings objectForKey:SCHeatMapSettingsValue]];
                break;
            } default:
                break;
        }
    }];
}

- (void)dismissController:(SCHeatMapSettingsViewController *)cont {
    [cont dismissViewControllerAnimated:YES completion:nil];
}

- (void)closedController:(SCHeatMapSettingsViewController *)cont withSettings:(NSDictionary *)settings andReadyHeatMap:(NSString *)_imageName {
    newGeneratedHeatMap = NO;
    NSLog(@"set the image with setting: %@ ", settings);
    infoDict = settings;
    UIImage *image = [[SCWebDAVService shared] fetchImageWithName:_imageName inFloor:self.floorPlan];
    [self setTitle:[NSString stringWithFormat:@"Heatmap - %@", [settings objectForKey:SCHeatMapSettingsValue]]];
    if (image != nil) {
        [self setHeatMapImageOverlay:image];
        [cont dismissViewControllerAnimated:YES completion:nil];
        [self.exportBtn setEnabled:NO];
    } else {
        NSLog(@"Error: Heatmap Image is Null");
    }
}

#pragma mark HeatMapPreparation 

- (void)generateHeatMapforWifi:(NSString *)_wifiName {
    NSLog(@"Generate HeatMap for Wifi: %@", _wifiName);
    avgValue = 0;
    count = 0;
    heatpoints = [NSMutableArray array];
    for (STPoint *point in self.floorPlan.points) {
        avgValue = 0;
        count = 0;
        for (STSensorPoint *sensorPoint in [point.sensorPoints allObjects]) {
            for (STWifiNetwork *wifi in [sensorPoint.wifiNetworks allObjects]) {
                if ([wifi.ssid isEqualToString:_wifiName]) {
                    int level = [wifi.signalLevel substringToIndex:(wifi.signalLevel.length -4)].floatValue;
                    avgValue += level;
                }
            }
            count++;
        }
        avgValue = avgValue/count;
//        NSLog(@"\nMapped Lng %f to x: %f\nMapped Lat %f to y: %f\nwith avg Level Value: %f for wifi: %@",
//               point.longitude.floatValue,
//               [self getXforPoint:point],
//               point.lattitude.floatValue,
//               [self getYforPoint:point],
//               avgValue,
//              _wifiName);
        [heatpoints addObject:[[STHeatmapPoint alloc] initWithPosition:CGPointMake([self getXforPoint:point], [self getYforPoint:point]) value:avgValue]];
    }
    [self generateHeatmap];
}

- (void)generateHeatMapforSensorType:(SCSensorType)_type {
    NSLog(@"Generate Heatmap for Sensor: %@", [[SCAppCore shared] wordingForSensorType:_type]);
    avgValue = 0;
    count = 0;
    heatpoints = [NSMutableArray array];
    for (STPoint *point in self.floorPlan.points) {
        avgValue = 0;
        count = 0;
        for (STSensorPoint *sensorPoint in [point.sensorPoints allObjects]) {
            for (STMeasurement *meas in [sensorPoint.measurements allObjects]) {
                if (meas.sensor.type.intValue == _type) {
                    avgValue += meas.value.floatValue;
                }
            }
            count++;
        }
        avgValue = avgValue/count;
//        NSLog(@"\nMapped Lng %f to x: %f\nMapped Lat %f to y: %f\nwith avg Value: %f",
//                                point.longitude.floatValue,
//                                [self getXforPoint:point],
//                                point.lattitude.floatValue,
//                                [self getYforPoint:point],
//                                avgValue);
        [heatpoints addObject:[[STHeatmapPoint alloc] initWithPosition:CGPointMake([self getXforPoint:point], [self getYforPoint:point]) value:avgValue]];
    }
    [self generateHeatmap];
}

- (float)getXforPoint:(STPoint*)point {
    double x_factor = imageWidth / 360;
    double x_coord;
    if (point.longitude.floatValue > 0) {
        x_coord = imageWidth/2 + point.longitude.doubleValue * x_factor;
    } else  {
        x_coord = imageWidth/2 - (fabsf(point.longitude.doubleValue) * x_factor);
    }
    return x_coord;
}

- (float)getYforPoint:(STPoint*)point {
    double y_factor = imageHeigth / 180;
    double y_coord;
    if (point.lattitude.floatValue > 0) {
        y_coord = imageHeigth/2 - point.lattitude.doubleValue * y_factor;
    } else  {
        y_coord = imageHeigth/2 + (fabsf(point.lattitude.doubleValue) * y_factor);
    }
    return y_coord;
}

- (void)generateHeatmap {
    [self showLoadingScreen];
    NSLog(@"generate heatmap");
    heatmap.points = heatpoints;
    heatmap.delegate = self;
    heatmap.resolution = resolution;
    [heatmap generateHeatmapImage];

}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
	CGImageRef maskRef = maskImage.CGImage;
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
	return [UIImage imageWithCGImage:masked];
}

#pragma mark STHeatMapDelegate 

- (void)heatmap:(STHeatmap*)actHeatmap didGenerateImage:(UIImage*)image {
    NSLog(@"generated heatmap image");
    generatedHeatImage = [self maskImage:image withMask:[UIImage imageNamed:[NSString stringWithFormat:@"%@", [self.floorPlan.relatedFile stringByReplacingOccurrencesOfString:@".pdf" withString:@""]]]];
    [self setHeatMapImageOverlay:generatedHeatImage];
 
}

- (void)setHeatMapImageOverlay:(UIImage *)_overlayImage {
    generatedHeatImage = _overlayImage;
    if (heatMapImageView == nil) {
        heatMapImageView = [[UIImageView alloc] initWithImage:generatedHeatImage];
        [mapImageView addSubview:heatMapImageView];
    }
    [heatMapImageView setImage:generatedHeatImage];
    
    //NSLog(@"color dict: %@", heatmap.colors);
    //NSLog(@"minvalue: %f, maxvlaue %f", heatmap.minValue, heatmap.maxValue);
    
    if (newGeneratedHeatMap) {
        NSMutableDictionary *settingsDict = [NSMutableDictionary dictionaryWithDictionary:infoDict];
        //GENERATE VALUE DICT
        NSString *unity = [[SCAppCore shared] unityForSensorType:[[SCAppCore shared] sensorTypeforWording:[settingsDict objectForKey:SCHeatMapSettingsValue]]];
        NSMutableDictionary *valueDict = [NSMutableDictionary dictionary];
        valueDict[@(0)] = [NSString stringWithFormat:@"%.0f %@", heatmap.maxValue*0, unity];
        valueDict[@(0.25)] = [NSString stringWithFormat:@"%.0f %@", heatmap.maxValue*0.25, unity];
        valueDict[@(0.5)] = [NSString stringWithFormat:@"%.0f %@", heatmap.maxValue*0.5, unity];
        valueDict[@(0.75)] = [NSString stringWithFormat:@"%.0f %@", heatmap.maxValue*0.75, unity];
        valueDict[@(1)] = [NSString stringWithFormat:@"%.0f %@", heatmap.maxValue, unity];
        
        [heatMapLegend setHidden:YES];
        heatMapLegend = [[SCHeatMapLegendView alloc] initWithFrame:CGRectMake(50, 100, 0, 0) andColorDict:heatmap.colors andValueDict:valueDict];
        [self.view addSubview:heatMapLegend];
        
        //Sakib - Generate buttons for dates
        NSMutableArray *arrDate = [[NSMutableArray alloc] init];
        NSDate *currDate = [NSDate date];
        [arrDate addObject:currDate];
        [arrDate addObject:(NSDate *)[currDate dateByAddingTimeInterval:-86400]];
        [arrDate addObject:(NSDate *)[currDate dateByAddingTimeInterval:-172800]];
        [arrDate addObject:(NSDate *)[currDate dateByAddingTimeInterval:-86400]];
        [arrDate addObject:(NSDate *)[currDate dateByAddingTimeInterval:-172800]];
        [arrDate addObject:(NSDate *)[currDate dateByAddingTimeInterval:-86400]];
        [arrDate addObject:(NSDate *)[currDate dateByAddingTimeInterval:-172800]];
        [arrDate addObject:(NSDate *)[currDate dateByAddingTimeInterval:-86400]];
        [arrDate addObject:(NSDate *)[currDate dateByAddingTimeInterval:-172800]];
        [arrDate addObject:(NSDate *)[currDate dateByAddingTimeInterval:-86400]];
        [arrDate addObject:(NSDate *)[currDate dateByAddingTimeInterval:-172800]];
        [heatMapDateOption setHidden:YES];
        heatMapDateOption = [[SCHeatMapDateOptionView alloc] initWithFrame:CGRectMake(870, 400, 0, 0) dateList:arrDate selectedDate:currDate];
        [self.view addSubview:heatMapDateOption];
    } else {
        [heatMapLegend setHidden:YES];
        [heatMapDateOption setHidden:YES];
    }
    
    
    
    
    [self hideLoadingScreen];
}

@end
