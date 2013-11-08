//
//  SCDetailViewController.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 17.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCDetailViewController.h"
#import <SierraClassLib/STSensorPoint.h>
#import "SCAppDelegate.h"
#import "STDHCPClient.h"

@interface SCDetailViewController () {
    
    int selectedMarkerType; // 0 = checkpoint, 1(a) = raspberry pi point, 1(b) = waspmote point, 2 = route polyline, 3 = continuous sensing point, 4 = routepoint
    NSMutableArray *stPoints;
    RMMapView *mapView;
    RMAnnotation *selectedPoint;
    
    //for loading sensor data from server
    BOOL saveCheckPoint;
    BOOL saveContinuousSensingPoint;

    NSMutableArray *wifiSensorArray;
    NSMutableArray *otherSensorArray;
    NSMutableArray *continuousSensorPointArray;
    
    RMAnnotation *currentAnnotation;
    RMAnnotation *currentCSAnnotation;
    BOOL isWifiSensorCollected;
    BOOL isOtherSensorCollected;
    
    NSMutableArray *macAddressArray;
    NSString *macAddress;
    
    //for route
    NSMutableArray *routes;
    NSMutableArray *polylineAnnotations;
    RMAnnotation *previousRoutepoint;
    CLLocation *routeStartPoint;
    CLLocation *routeEndPoint;
    BOOL willMergeRoute;
    int routepointCounter;
    
    //for different type of sensors
    NSString *currentSensor;
}
@end

@implementation SCDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
	
    [self setTitle:[_floorPlan name]];
    wifiSensorArray = [NSMutableArray array];
    otherSensorArray = [NSMutableArray array];
    macAddressArray = [NSMutableArray array];
    isWifiSensorCollected = FALSE;
    isOtherSensorCollected = FALSE;

    //read dhcp clients and store it for continuous sensor selection
    [[SCDataService shared] getDHCPClientsAddTarget:self action:@selector(dhcpClientsLoaded:)];
    
    //Initializations
    self.managedObjectContext = [(SCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    routes = [[NSMutableArray alloc] init];
    polylineAnnotations = [[NSMutableArray alloc] init];
    routepointCounter = 0;
    stPoints = [[NSMutableArray alloc] init];
    [self.startRoute setEnabled:NO];
    
    [(UISegmentedControl *)[self.selectedMode customView] addTarget:self action:@selector(drawingModeChanged:) forControlEvents: UIControlEventValueChanged];
    self.statusLabel.text = @"Tap to set checkpoints on the map";
    selectedPoint = nil;
    selectedMarkerType = 0;
    
    //Create, configure and add the map
    RMMBTilesSource *tileSource = [[RMMBTilesSource alloc] initWithTileSetURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[[NSString stringWithFormat:@"%@", [_floorPlan relatedFile]] stringByReplacingOccurrencesOfString:@".pdf" withString:@""] ofType:@"mbtiles"]]];
    mapView = [[RMMapView alloc] initWithFrame:CGRectMake(0, 0, 1024, 724) andTilesource:tileSource centerCoordinate:CLLocationCoordinate2DMake(0, 0) zoomLevel:1 maxZoomLevel:10 minZoomLevel:0 backgroundImage:[[UIImage imageNamed:@"map_back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)]]; //660
    mapView.delegate = self;
    mapView.hideAttribution = YES;
    mapView.showLogoBug = NO;
    mapView.zoom = 0;
    //[mapView setDebugTiles:YES];
    //mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //mapView.adjustTilesForRetinaDisplay = YES;
    [self.mapContainerView addSubview:mapView];
    
    //load saved points from database
    [self loadSavedPoints];
    
    [_activityIndicator setHidden:YES];
    
    if ([[SCAppCore shared] appMode] == 3) { // Waspmote
        currentSensor = @"WM";
        [(UISegmentedControl *)[self.selectedMode customView] setTitle:@"Meshlium" forSegmentAtIndex:1];
        
    } else {
        currentSensor = @"RP";
        [(UISegmentedControl *)[self.selectedMode customView] setTitle:@"Rasp. Pi" forSegmentAtIndex:1];
    }
    
}

-(void)dhcpClientsLoaded:(NSMutableArray *)dhcpClients{
    NSLog(@"+++ found %d dhcp clients", [dhcpClients count]);
    macAddressArray = dhcpClients;
}

#pragma mark SCDataService reading
- (void)loadDataFromServerForCheckpoint:(BOOL)isCheckpoint {
    //NSLog(@"******** load data from server");

    [[SCDataService shared] getWifisensorsAddTarget:self action:@selector(wifiSensorsLoaded:)];
    [[SCDataService shared] getOtherSensorsAddTarget:self action:@selector(otherSensorsLoaded:)];
    
    saveCheckPoint = isCheckpoint;
    saveContinuousSensingPoint = NO;
    
}

- (void)loadDataFromServerForContinuousSensingPoint:(NSString *)macAddressParam {
    NSLog(@"+++ csMacAddress: %@", macAddressParam);
//    [[SCDataService shared] getWifisensorsAddTarget:self action:@selector(wifiSensorsLoaded:)];
//    [[SCDataService shared] getOtherSensorsAddTarget:self action:@selector(otherSensorsLoaded:)];
    
    macAddress = macAddressParam;
    saveContinuousSensingPoint = YES;
    
}

-(void)continuousMeasurementsLoaded:(NSMutableArray *)continuousMeasurements{
    NSLog(@"+++ DetailView has found %d continuous measurements", [continuousMeasurements count]);
    for (STMeasurement *m in continuousMeasurements) {
        NSLog(@"+++ time: %@", m.created);
    }

    NSMutableArray *sensorPointArray = [NSMutableArray array];
    NSMutableArray *measurementArray = [NSMutableArray array];
    
    NSDate *date = ((STMeasurement *)[continuousMeasurements objectAtIndex:0]).created;
    NSLog(@"--- first contMeas time: %@", date);
    for (STMeasurement *meas in continuousMeasurements) {
        //NSLog(@"+++ time: %@", m.created);
        if ([meas.created isEqualToDate:date]) {
            [measurementArray addObject:meas];
        } else{
            //STSensorPoint *stsp = [[STSensorPoint alloc] init];
            STSensorPoint *stsp = [NSEntityDescription insertNewObjectForEntityForName:@"STSensorPoint" inManagedObjectContext:self.managedObjectContext];
            stsp.time = date;
            NSSet *measSet = [[NSSet alloc] initWithArray:measurementArray];
            stsp.measurements = measSet;//WOODY NOW
            [sensorPointArray addObject:stsp];
            
            date = meas.created;
            [measurementArray removeAllObjects];
            [measurementArray addObject:meas];
        }
    }
    // at the end of the for loop, date doesn't change anymore... so no new stsp is created. so here i m creating that manually
    STSensorPoint *stsp = [NSEntityDescription insertNewObjectForEntityForName:@"STSensorPoint" inManagedObjectContext:self.managedObjectContext];
    stsp.time = date;
    NSSet *measSet = [[NSSet alloc] initWithArray:measurementArray];
    stsp.measurements = measSet;
    [sensorPointArray addObject:stsp];
        
    continuousSensorPointArray = sensorPointArray;
    NSLog(@"--- continuousSensorPointArray got %d items.", [continuousSensorPointArray count]);
    
    NSLog(@"+++ SaveCheckPoint is about to call");
    [self saveContinuousSensingPointForAnnotaton:currentCSAnnotation];

}

- (void)wifiSensorsLoaded:(NSMutableArray *)wifiSensors {
    isWifiSensorCollected = TRUE;
    wifiSensorArray = wifiSensors;
    NSLog(@"******** loading wifi data from server %d", [wifiSensorArray count]);
    if (isWifiSensorCollected && isOtherSensorCollected) {
        NSLog(@"******** SaveCheckPoint is about to call");
        if (saveContinuousSensingPoint) {
            [self saveContinuousSensingPointForAnnotaton:currentCSAnnotation];
        }
        else if (saveCheckPoint) {
            [self saveCheckPointForAnnotaton:currentAnnotation];
        } else {
            [self drawRouteToPoint:routeEndPoint
                         fromPoint:routeStartPoint
                             onMap:mapView
                         willMerge:willMergeRoute];
        }
        
        isOtherSensorCollected = FALSE;
        isWifiSensorCollected = FALSE;
    }    
}
- (void)otherSensorsLoaded:(NSMutableArray *)otherSensors {
    otherSensorArray = otherSensors;
    isOtherSensorCollected = TRUE;
    NSLog(@"******** loading other sensor data from server %d", [otherSensorArray count]);
    
    if (isWifiSensorCollected && isOtherSensorCollected) {
        NSLog(@"******** SaveCheckPoint is about to call");
        if (saveContinuousSensingPoint) {
            [self saveContinuousSensingPointForAnnotaton:currentCSAnnotation];
        }
        else if (saveCheckPoint) {
            [self saveCheckPointForAnnotaton:currentAnnotation];
        } else {
            [self drawRouteToPoint:routeEndPoint
                         fromPoint:routeStartPoint
                             onMap:mapView
                         willMerge:willMergeRoute];
        }
        
        isOtherSensorCollected = FALSE;
        isWifiSensorCollected = FALSE;
    }
}

#pragma mark RMMapViewDelegate
- (void)singleTapOnMap:(RMMapView *)map at:(CGPoint)point {
    //Checkpoint
    if ([(UISegmentedControl *)[self.selectedMode customView] selectedSegmentIndex] == 0) {
        selectedMarkerType = 0;
        RMAnnotation *annotation = [RMAnnotation annotationWithMapView:map coordinate:[map pixelToCoordinate:point] andTitle:[NSString stringWithFormat:@""]];
        annotation.userInfo = @"checkPoint";
        [map addAnnotation:annotation];
        annotation.title = [NSString stringWithFormat:@"Checkpoint"];
        annotation.subtitle = [NSString stringWithFormat:@"Coordinate %.3f %.3f", [annotation coordinate].latitude, [annotation coordinate].longitude];
        
        self.statusLabel.text = @"Gathering sensor data...";
        [_activityIndicator startAnimating];
        [_activityIndicator setHidden:NO];
        
        [self loadDataFromServerForCheckpoint:YES];//******** Woody
        currentAnnotation = annotation;
        //[self saveCheckPointForAnnotaton:annotation];
    }
    
    //Raspberry Pi Point
    else if ([(UISegmentedControl *)[self.selectedMode customView] selectedSegmentIndex] == 1 && [currentSensor isEqualToString:@"RP"]) {
        selectedMarkerType = 1;
        RMAnnotation *annotation = [RMAnnotation annotationWithMapView:map coordinate:[map pixelToCoordinate:point] andTitle:[NSString stringWithFormat:@""]];
        annotation.userInfo = @"raspberryPiPoint";
        [map addAnnotation:annotation];
        annotation.title = [NSString stringWithFormat:@"RaspberryPiPoint"];
        annotation.subtitle = [NSString stringWithFormat:@"Coordinate %.3f %.3f", [annotation coordinate].latitude, [annotation coordinate].longitude];
        
        self.statusLabel.text = @"Raspberry Pi placed";
        //[_activityIndicator startAnimating];
        //[_activityIndicator setHidden:NO];
        
        //[self loadDataFromServerForCheckpoint:YES];//******** Woody
        currentAnnotation = annotation;
        //[self saveCheckPointForAnnotaton:annotation];
    }
    
    //Waspmote Point
    else if ([(UISegmentedControl *)[self.selectedMode customView] selectedSegmentIndex] == 1 && [currentSensor isEqualToString:@"WM"]) {
        selectedMarkerType = 1;
        RMAnnotation *annotation = [RMAnnotation annotationWithMapView:map coordinate:[map pixelToCoordinate:point] andTitle:[NSString stringWithFormat:@""]];
        annotation.userInfo = @"waspmotePoint";
        [map addAnnotation:annotation];
        annotation.title = [NSString stringWithFormat:@"WaspmotePoint"];
        annotation.subtitle = [NSString stringWithFormat:@"Coordinate %.3f %.3f", [annotation coordinate].latitude, [annotation coordinate].longitude];
        
        self.statusLabel.text = @"Meshlium placed";
        //[_activityIndicator startAnimating];
        //[_activityIndicator setHidden:NO];
        
        //[self loadDataFromServerForCheckpoint:YES];//******** Woody
        currentAnnotation = annotation;
        //[self saveCheckPointForAnnotaton:annotation];
    }
    
    //Continuous sensing point
    else if ([(UISegmentedControl *)[self.selectedMode customView] selectedSegmentIndex] == 2) {
        selectedMarkerType = 3;
        RMAnnotation *annotation = [RMAnnotation annotationWithMapView:map coordinate:[map pixelToCoordinate:point] andTitle:[NSString stringWithFormat:@""]];
        annotation.userInfo = @"continuousSensingPoint";
        [map addAnnotation:annotation];
        annotation.title = [NSString stringWithFormat:@"ContinuousSensingPoint"];
        annotation.subtitle = [NSString stringWithFormat:@"Coordinate %.3f %.3f", [annotation coordinate].latitude, [annotation coordinate].longitude];
        
        self.statusLabel.text = @"Sensor data will be collected continuously...";
        //[_activityIndicator startAnimating];
        //[_activityIndicator setHidden:NO];
        currentCSAnnotation = annotation;

        UIActionSheet * actionsheet = [[UIActionSheet alloc] initWithTitle:@"Choose" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];

        for (STDHCPClient *client in macAddressArray) {
            [actionsheet addButtonWithTitle:client.macAddress];
        }

        [actionsheet showFromRect:CGRectMake(annotation.position.x, annotation.position.y, 0.1, 0.1) inView:self.view animated:YES];

        //[self saveCheckPointForAnnotaton:annotation];
    }
    
    //Routepoint
    else if ([(UISegmentedControl *)[self.selectedMode customView] selectedSegmentIndex] == 3) {
        CLLocation *tappedPoint = [[CLLocation alloc] initWithLatitude:[map pixelToCoordinate:point].latitude longitude:[map pixelToCoordinate:point].longitude];
        if (selectedPoint != nil && [selectedPoint.userInfo isEqual: @"routePoint"]) {
            // Not the first point of a route, already has a previous point from where line will be drawn
            routeStartPoint = [[CLLocation alloc] initWithLatitude:selectedPoint.coordinate.latitude longitude:selectedPoint.coordinate.longitude];
            routeEndPoint = tappedPoint;
            willMergeRoute = NO;
            /*[self drawRouteToPoint:tappedPoint
             fromPoint:[[CLLocation alloc] initWithLatitude:selectedPoint.coordinate.latitude longitude:selectedPoint.coordinate.longitude]
             onMap:map
             willMerge:NO];*/
            
            [self loadDataFromServerForCheckpoint:NO];
        } else {
            //First point in the route
            selectedPoint = [self createRoutePointAnnotationAtCoordinate:[map pixelToCoordinate:point] onMap:map];
            routeStartPoint = tappedPoint;
            routeEndPoint = nil;
            willMergeRoute = NO;
            /*[self drawRouteToPoint:nil
             fromPoint:tappedPoint
             onMap:map
             willMerge:NO];*/
            [self loadDataFromServerForCheckpoint:NO];//******** Woody
            //currentAnnotation = selectedPoint;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //NSLog(@"+++ %@", [macAddressArray objectAtIndex:buttonIndex]);
    if (buttonIndex == -1) {
        [mapView removeAnnotation:currentCSAnnotation];
    }else{
        // Read Continuous Measurements
        [[SCDataService shared] getContinuousMeasurementsAddTarget:self action:@selector(continuousMeasurementsLoaded:)];
        //[[SCDataService shared] getWifisensorsAddTarget:self action:@selector(wifiSensorsLoaded:)];
        //[[SCDataService shared] getOtherSensorsAddTarget:self action:@selector(otherSensorsLoaded:)];
        
        STDHCPClient *client = [macAddressArray objectAtIndex:buttonIndex];
        //[self loadDataFromServerForContinuousSensingPoint:client.macAddress];
        macAddress = client.macAddress;
        saveContinuousSensingPoint = YES;
    }

}

- (RMMapLayer *)mapView:(RMMapView *)map layerForAnnotation:(RMAnnotation *)annotation {
    //Actually draw checkpoint marker / continuousSensingPoint marker / Raspberry Pi Marker
    
    if (annotation.isUserLocationAnnotation)
        return nil;
    // Draw checkpoint marker
    if ([annotation.userInfo isEqual: @"checkPoint"]) {
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker_point"]];
        marker.anchorPoint = CGPointMake(0.5, 1.0);
        //marker.canShowCallout = YES;
        //marker.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img.jpg"]];
        //marker.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return marker;
    }
    // Draw Raspberry Pi marker
    else if ([annotation.userInfo isEqual: @"raspberryPiPoint"]) {
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker_raspberrypi"]];
        marker.anchorPoint = CGPointMake(0.5, 0.5);
        return marker;
    }
    // Draw Waspmote marker
    else if ([annotation.userInfo isEqual: @"waspmotePoint"]) {
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker_waspmote"]];
        marker.anchorPoint = CGPointMake(0.5, 0.5);
        return marker;
    }
    // Draw continuousSensingPoint marker
    else if ([annotation.userInfo isEqual: @"continuousSensingPoint"]) {
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker_continuous"]];
        marker.anchorPoint = CGPointMake(0.5, 1.0);
        return marker;
    }
    // Draw routepoint marker
    else if ([annotation.userInfo isEqual: @"routePoint"]) {
        RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker_route"]];
        marker.anchorPoint = CGPointMake(0.48, 0.9);
        return marker;
    }
    // Draw routeline
    else if ([annotation.title isEqual: @"routePolyline"]) {
        RMShape *shape = [[RMShape alloc] initWithView:map];
        shape.lineColor = [UIColor redColor];
        shape.lineWidth = 5.0;
        
        for (CLLocation *location in (NSArray *)annotation.userInfo) {
            [shape addLineToCoordinate:location.coordinate];
        }
        return shape;
    }
    return nil;
}
- (void)longPressOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map {
    selectedPoint = annotation;
    [self deleteCheckPointClicked];
}
- (void)mapView:(RMMapView *)map didSelectAnnotation:(RMAnnotation *)annotation {
    if (selectedPoint != nil && [selectedPoint.userInfo isEqual:@"routePoint"]) {
        previousRoutepoint = selectedPoint;
    } else{
        previousRoutepoint = nil;
    }
    selectedPoint = annotation;
    [map deselectAnnotation:annotation animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    SCPopOverNavigationViewController *poper = [storyboard instantiateViewControllerWithIdentifier:@"popovernavigationcont" ];
    self.detailViewPopover = [[UIPopoverController alloc] initWithContentViewController:poper];
	self.detailViewPopover.popoverContentSize = CGSizeMake(320.0, 500.0);
	self.detailViewPopover.delegate = self;
    
    //
    for (STPoint *sp in stPoints) {
        if ([sp.lattitude isEqualToNumber:[NSNumber numberWithDouble:[selectedPoint coordinate].latitude]]
            && [sp.longitude isEqualToNumber:[NSNumber numberWithDouble:[selectedPoint coordinate].longitude]]) {
            if ([poper.viewControllers objectAtIndex:0]) {
                [(SCPopOverOverviewViewController *)[poper.viewControllers objectAtIndex:0] setTitle:sp.name];
                //Set coordinate in the label of popover
                [[(SCPopOverOverviewViewController *)[poper.viewControllers objectAtIndex:0] coordinateLabel] setText:[NSString stringWithFormat:@"Coordinate %.3f %.3f ", [selectedPoint coordinate].latitude, [selectedPoint coordinate].longitude]];
                
                // Show/hide popover buttons
                if ([selectedPoint.userInfo isEqual: @"routePoint"]) {
                    [[(SCPopOverOverviewViewController *)[poper.viewControllers objectAtIndex:0] snrButton] setHidden:NO];
                    if (previousRoutepoint != nil) {
                        [[(SCPopOverOverviewViewController *)[poper.viewControllers objectAtIndex:0] mrButton] setHidden:NO];
                    } else {
                        [[(SCPopOverOverviewViewController *)[poper.viewControllers objectAtIndex:0] mrButton] setHidden:YES];
                    }
                } else {
                    [[(SCPopOverOverviewViewController *)[poper.viewControllers objectAtIndex:0] snrButton] setHidden:YES];
                    [[(SCPopOverOverviewViewController *)[poper.viewControllers objectAtIndex:0] mrButton] setHidden:YES];
                }
                
                [(SCPopOverOverviewViewController *)[poper.viewControllers objectAtIndex:0] setDelegate:self];
                [(SCPopOverOverviewViewController *)[poper.viewControllers objectAtIndex:0] setPoint:sp];//setting STPoint to the PopoverOverview
                NSLog(@"%d", sp.accessiblePoints.count);
            }
        }
    }
        
    [self.detailViewPopover setContentViewController:poper];
    [self.detailViewPopover presentPopoverFromRect:CGRectMake(annotation.position.x, annotation.position.y, 0.1, 0.1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
- (UIImage *)imageForTile:(RMTile)tile inCache:(RMTileCache *)tileCache {
    return nil;
}
- (BOOL)supportsInteractivity {
    return YES;
}
- (BOOL)tileSourceHasTile:(RMTile)tile {
    return YES;
}
- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map {
    return;
}
- (void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map {
    return;
}
- (void)tapOnLabelForAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map {
    return;
}

#pragma mark SCPopOverOverViewViewControllerDelegate
- (void)deleteCheckPointClicked {
    //First delete this point from accessiblePoint list of all the points (if any)
    if ([selectedPoint.userInfo isEqual: @"routePoint"]) {
        for (STPoint *sp in stPoints) {
            for (STPoint *spChild in sp.accessiblePoints.allObjects) {
                if ([spChild.lattitude isEqualToNumber:[NSNumber numberWithDouble:[selectedPoint coordinate].latitude]]
                    && [spChild.longitude isEqualToNumber:[NSNumber numberWithDouble:[selectedPoint coordinate].longitude]]) {
                    [sp removeAccessiblePointsObject:spChild];
                    //NSError *error = nil;
                    //[self.managedObjectContext saveToPersistentStore:&error];
                }
            }
        }
    }
    
    //Delete the point itself
    for (STPoint *sp in stPoints) {
        if ([sp.lattitude isEqualToNumber:[NSNumber numberWithDouble:[selectedPoint coordinate].latitude]]
            && [sp.longitude isEqualToNumber:[NSNumber numberWithDouble:[selectedPoint coordinate].longitude]]) {
            if ([sp.sensorPoints allObjects].count > 0) {
                NSArray *arr = [NSArray arrayWithArray:[sp.sensorPoints allObjects]];
                for (STSensorPoint *ssp in arr) {
                    [sp removeSensorPointsObject:ssp];
                }
            }

            [_floorPlan removePointsObject:sp];
            //[nextPoint setFloor:_floorPlan];
            NSError *error = nil;
            [self.managedObjectContext saveToPersistentStore:&error];
            //also delete all STSensorPoint s
            //also delete all connected STPoint s
            [stPoints removeObject:sp];
            break;
        }
    }
    
    [self.detailViewPopover dismissPopoverAnimated:YES];
    //Delete the point from the map
    [mapView removeAnnotation:selectedPoint];
    
    if ([selectedPoint.userInfo isEqual: @"routePoint"]) {
        //Delete the point from the routes array and also from all the arrays within the routes array
        for (int i = 0; i < routes.count; i++) {
            for (int j = 0; j < [[routes objectAtIndex:i] count]; j++) {
                if (selectedPoint.coordinate.latitude == ((RMAnnotation *)[[routes objectAtIndex:i] objectAtIndex:j]).coordinate.latitude && selectedPoint.coordinate.longitude == ((RMAnnotation *)[[routes objectAtIndex:i] objectAtIndex:j]).coordinate.longitude) {
                    [[routes objectAtIndex:i] removeObjectAtIndex:j];
                }
            }
        }
        [self drawAllroutes:mapView];
    }
    selectedPoint = nil;
}

#pragma mark Points' database related functions
- (void)loadSavedPoints {
    // Load all the points from database and draw checkpoint/route as necessary
    
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationSequence" ascending:YES];
    NSArray *sorted = [[[SCDataService shared] getPointsforFloor:_floorPlan] sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
    
    for (STPoint *point in sorted) {
        //draw checkpoints
        if ([point.pointType intValue] == 0) {
            selectedMarkerType = 0;
            RMAnnotation *annotation = [RMAnnotation annotationWithMapView:mapView coordinate:CLLocationCoordinate2DMake((CLLocationDegrees)[point.lattitude doubleValue],(CLLocationDegrees)[point.longitude doubleValue]) andTitle:[NSString stringWithFormat:@""]];
            annotation.userInfo = @"checkPoint";
            [mapView addAnnotation:annotation];
            annotation.title = [NSString stringWithFormat:@"Checkpoint"];
            annotation.subtitle = [NSString stringWithFormat:@"Coordinate %.3f %.3f", [annotation coordinate].latitude, [annotation coordinate].longitude];
        }
        
        //draw routepoints
        else if ([point.pointType intValue] == 1) {
            routepointCounter++;
            if (point.accessiblePoints.allObjects.count > 0) {
                NSArray *sortedChilds = [point.accessiblePoints.allObjects sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
                for (STPoint *childPoint in sortedChilds) {
                    [routes addObject:[[NSMutableArray alloc] init]];
                    [[routes lastObject] addObject:[[CLLocation alloc] initWithLatitude:(CLLocationDegrees)[point.lattitude doubleValue] longitude:(CLLocationDegrees)[point.longitude doubleValue]]];
                    [[routes lastObject] addObject:[[CLLocation alloc] initWithLatitude:(CLLocationDegrees)[childPoint.lattitude doubleValue] longitude:(CLLocationDegrees)[childPoint.longitude doubleValue]]];
                }
            }
            [self createRoutePointAnnotationAtCoordinate:CLLocationCoordinate2DMake((CLLocationDegrees)[point.lattitude doubleValue], (CLLocationDegrees)[point.longitude doubleValue]) onMap:mapView];
        }
        
        //draw continus sensingpoints
        else if ([point.pointType intValue] == 2) {
            selectedMarkerType = 3;
            RMAnnotation *annotation = [RMAnnotation annotationWithMapView:mapView coordinate:CLLocationCoordinate2DMake((CLLocationDegrees)[point.lattitude doubleValue],(CLLocationDegrees)[point.longitude doubleValue]) andTitle:[NSString stringWithFormat:@""]];
            annotation.userInfo = @"continuousSensingPoint";
            [mapView addAnnotation:annotation];
            annotation.title = [NSString stringWithFormat:@"ContinuousSensingPoint"];
            annotation.subtitle = [NSString stringWithFormat:@"Coordinate %.3f %.3f", [annotation coordinate].latitude, [annotation coordinate].longitude];
        }
        
        //draw raspberry pi points
        else if ([point.pointType intValue] == 3) {
            selectedMarkerType = 1;
            RMAnnotation *annotation = [RMAnnotation annotationWithMapView:mapView coordinate:CLLocationCoordinate2DMake((CLLocationDegrees)[point.lattitude doubleValue],(CLLocationDegrees)[point.longitude doubleValue]) andTitle:[NSString stringWithFormat:@""]];
            annotation.userInfo = @"raspberryPiPoint";
            [mapView addAnnotation:annotation];
            annotation.title = [NSString stringWithFormat:@"RaspberryPiPoint"];
            annotation.subtitle = [NSString stringWithFormat:@"Coordinate %.3f %.3f", [annotation coordinate].latitude, [annotation coordinate].longitude];
        }
        
        //draw waspmote points
        else if ([point.pointType intValue] == 4) {
            selectedMarkerType = 1;
            RMAnnotation *annotation = [RMAnnotation annotationWithMapView:mapView coordinate:CLLocationCoordinate2DMake((CLLocationDegrees)[point.lattitude doubleValue],(CLLocationDegrees)[point.longitude doubleValue]) andTitle:[NSString stringWithFormat:@""]];
            annotation.userInfo = @"waspmotePoint";
            [mapView addAnnotation:annotation];
            annotation.title = [NSString stringWithFormat:@"WaspmotePoint"];
            annotation.subtitle = [NSString stringWithFormat:@"Coordinate %.3f %.3f", [annotation coordinate].latitude, [annotation coordinate].longitude];
        }
        
        [stPoints addObject:point];
    }
    if (routes.count > 0) {
        [self drawAllroutes:mapView];
    }
}
- (void)saveCheckPointForAnnotaton:(RMAnnotation *)annotation {
    self.statusLabel.text = @"Sensor Data Fetched";
    [_activityIndicator stopAnimating];
    [_activityIndicator setHidden:YES];
    
    //Save checkpoint to database
    //Make db object for Point
    STPoint *point = [NSEntityDescription insertNewObjectForEntityForName:@"STPoint" inManagedObjectContext:self.managedObjectContext];
    point.lattitude = [NSNumber numberWithDouble:[annotation coordinate].latitude];
    point.longitude = [NSNumber numberWithDouble:[annotation coordinate].longitude];
    point.pointType = [NSNumber numberWithInt:0];
    
    //Also make db object for Sensor-point for this Point
    STSensorPoint *ssp = [NSEntityDescription insertNewObjectForEntityForName:@"STSensorPoint" inManagedObjectContext:self.managedObjectContext];
    [ssp setTime:[NSDate date]];
    
    // *********  Woody *********
    NSLog(@"******* saveCheckPointForAnnotaton has %d otherSensorArray objects and %d wifiSensor objects", [otherSensorArray count], [wifiSensorArray count]);
    [ssp setWifiNetworks:[NSSet setWithArray:wifiSensorArray]];
    [ssp setMeasurements:[NSSet setWithArray:otherSensorArray]];
    // *********  Woody *********
    
    [point addSensorPointsObject:ssp];
    [_floorPlan addPointsObject:point];
    [point setFloor:_floorPlan];
    [ssp setPoint:point];
    [stPoints addObject:point];
    
    NSError *error = nil;
    [self.managedObjectContext saveToPersistentStore:&error];
}
- (void)saveContinuousSensingPointForAnnotaton:(RMAnnotation *)annotation {
    //self.statusLabel.text = @"Sensor Data Fetched";
    //[_activityIndicator stopAnimating];
    //[_activityIndicator setHidden:YES];
    
    //Save checkpoint to database
    //Make db object for Point
    STPoint *point = [NSEntityDescription insertNewObjectForEntityForName:@"STPoint" inManagedObjectContext:self.managedObjectContext];
    point.lattitude = [NSNumber numberWithDouble:[annotation coordinate].latitude];
    point.longitude = [NSNumber numberWithDouble:[annotation coordinate].longitude];
    point.pointType = [NSNumber numberWithInt:2];
    point.csMacAddress = macAddress;
    
    //Also make db object for Sensor-point for this Point
//    STSensorPoint *ssp = [NSEntityDescription insertNewObjectForEntityForName:@"STSensorPoint" inManagedObjectContext:self.managedObjectContext];
//    [ssp setTime:[NSDate date]];
    
    // *********  Woody *********
    /*NSLog(@"******* saveCheckPointForAnnotaton has %d otherSensorArray objects and %d wifiSensor objects", [otherSensorArray count], [wifiSensorArray count]);
    [ssp setWifiNetworks:[NSSet setWithArray:wifiSensorArray]];
    [ssp setMeasurements:[NSSet setWithArray:otherSensorArray]];*/
    // *********  Woody *********

    for (STSensorPoint *sp in continuousSensorPointArray) {
        //NSLog(@"--- time: %@", sp.time);
        [point addSensorPointsObject:sp];
        [sp setPoint:point];
    }
    
    [_floorPlan addPointsObject:point];
    [point setFloor:_floorPlan];
    //[ssp setPoint:point];
    [stPoints addObject:point];
    
    NSError *error = nil;
    [self.managedObjectContext saveToPersistentStore:&error];
}

#pragma mark Route helper and outlet Functions
- (IBAction)startNewRouteClicked:(id)sender {
    selectedPoint = nil;
}
- (void)drawAllroutes:(RMMapView *)map {
    // Remove all route annotations in map
    [map removeAnnotations:polylineAnnotations];
    //Clean the route array
    for (int i = 0; i < routes.count; i++) {
        if ([[routes objectAtIndex:i] count] == 0) {
            [routes removeObjectAtIndex:i];
        }
    }
    //Set the marker type to draw line as polYline marker
    selectedMarkerType = 2;
    //Now draw line for all arrays within "routes" array
    for (int r = 0; r < routes.count; r++) {
        if ([[routes objectAtIndex:r] count] > 1) {
            RMAnnotation *polyline = [[RMAnnotation alloc] initWithMapView:map
                                                                coordinate:((CLLocation *)[[routes objectAtIndex:r] objectAtIndex:0]).coordinate
                                                                  andTitle:@"routePolyline"];
            polyline.userInfo = [routes objectAtIndex:r];
            [polyline setBoundingBoxFromLocations:[routes objectAtIndex:r]];
            [map addAnnotation:polyline];
            [polylineAnnotations addObject:(RMAnnotation *)polyline];
            
        }
    }
}
- (NSMutableArray *)getAllIntermediatePointsWithFirstpoint:(CLLocation *)firstPoint toLastPoint:(CLLocation *)lastPoint withIntermediateDistance:(double)intermediateDistance {
    NSMutableArray *returnPoints = [[NSMutableArray alloc] init];
    //Add the first point to return array
    [returnPoints addObject:[[CLLocation alloc] initWithLatitude:firstPoint.coordinate.latitude longitude:firstPoint.coordinate.longitude]];
    
    double toleranceDistance = 20000; //meter
    
    double distance;
    distance = [firstPoint distanceFromLocation:lastPoint];
    
    if(distance > intermediateDistance) {
        
        CLLocationCoordinate2D startPoint = firstPoint.coordinate;
        CLLocationCoordinate2D endPoint = lastPoint.coordinate;
        CLLocationCoordinate2D newPoint;   // A newly-created point along the line
        double latitudeModifier;    // Distance to add/subtract to each latitude point
        double longitudeModifier;   // Distance to add/subtract to each longitude point
        //int numberOfPoints = 0;
        int nopCheck = (int)distance/toleranceDistance;// The number of points you want between the two points
        double distanceFromNewPoint;
        
        //numberOfPoints = (int)(floor(distance / requiredDistance)); // integer floor value
        
        // Determine the distance between the lats and divide by numberOfPoints
        latitudeModifier = (startPoint.latitude - endPoint.latitude) / nopCheck;
        // Same with lons
        longitudeModifier = (startPoint.longitude - endPoint.longitude) / nopCheck;
        
        // Loop through hundreds of intermediary points
        for (int i = 0; i < nopCheck; i++) {
            newPoint.latitude = startPoint.latitude - (latitudeModifier * i); //originally was +
            newPoint.longitude = startPoint.longitude - (longitudeModifier * i);
            distanceFromNewPoint = [[returnPoints lastObject] distanceFromLocation:[[CLLocation alloc] initWithLatitude:newPoint.latitude longitude:newPoint.longitude]];
            
            if (abs(distanceFromNewPoint - intermediateDistance) <=  (int)toleranceDistance ) {
                [returnPoints addObject:[[CLLocation alloc] initWithLatitude:newPoint.latitude longitude:newPoint.longitude]];
            }
        }
    }
    //Add the last point to return array
    [returnPoints addObject:[[CLLocation alloc] initWithLatitude:lastPoint.coordinate.latitude longitude:lastPoint.coordinate.longitude]];
    
    return returnPoints;
}
- (void)saveRoutePointAtLat:(double)currentLat andLong:(double)currentLong andSequence:(int)sequence withNextPointAtLat:(double)nextLat andLong:(double)nextLong{
    STSensorPoint *nextSsp;
    STPoint *nextPoint;
    bool nextPointExists = NO; //for route merging
    
    //Save routepoint in database
    //First create the db object for the STPoint and Sensor point of the next accessible point
    for (STPoint *existedNextPoint in stPoints) {
        if ([existedNextPoint.lattitude isEqualToNumber:[NSNumber numberWithDouble:nextLat]] && [existedNextPoint.longitude isEqualToNumber:[NSNumber numberWithDouble:nextLong]]) {
            nextPoint = existedNextPoint;
            nextPointExists = YES;
            break;
        }
    }
    
    if ((isnan(nextLat)) || (isnan(nextLat))) {
        nextSsp = nil;
        nextPoint = nil;
    } else if (nextPointExists == YES) {
        //Do nothing, next point already exists
    } else {
        //if(currentPointExists == YES) { // If current point exists then create the next point here, otherwise create later
        nextPoint = [NSEntityDescription insertNewObjectForEntityForName:@"STPoint" inManagedObjectContext:self.managedObjectContext];
        nextPoint.lattitude = [NSNumber numberWithDouble:nextLat];
        nextPoint.longitude = [NSNumber numberWithDouble:nextLong];
        nextPoint.pointType = [NSNumber numberWithInt:1];
        nextPoint.creationSequence = [NSNumber numberWithInt:(sequence+1)];
        
        nextSsp = [NSEntityDescription insertNewObjectForEntityForName:@"STSensorPoint" inManagedObjectContext:self.managedObjectContext];
        [nextSsp setTime:[NSDate date]];
        
        // *********  Woody *********
        //NSLog(@"--- saveRoutePointForAnnotaton has %d otherSensorArray objects and %d wifiSensor objects", [otherSensorArray count], [wifiSensorArray count]);
        //[nextSsp setWifiNetworks:[NSSet setWithArray:wifiSensorArray]];
        //[nextSsp setMeasurements:[NSSet setWithArray:otherSensorArray]];
        // *********  Woody *********
        
        [nextPoint addSensorPointsObject:nextSsp];
        [nextSsp setPoint:nextPoint];
        //}
    }
    
    //If current point is already created, update: set nextPoint as its one of the accessible points
    for (STPoint *spSelected in stPoints) {
        if ([spSelected.lattitude isEqualToNumber:[NSNumber numberWithDouble:currentLat]] && [spSelected.longitude isEqualToNumber:[NSNumber numberWithDouble:currentLong]]) {
            
            if (nextPoint) {
                [spSelected addAccessiblePointsObject:nextPoint];
                
                [_floorPlan addPointsObject:nextPoint];
                [nextPoint setFloor:_floorPlan];
                
                [stPoints addObject:nextPoint];
                NSError *error = nil;
                [self.managedObjectContext saveToPersistentStore:&error];
            }
            return;
        }
    }
    
    //Else create new point
    STPoint *point = [NSEntityDescription insertNewObjectForEntityForName:@"STPoint" inManagedObjectContext:self.managedObjectContext];
    point.lattitude = [NSNumber numberWithDouble:currentLat];
    point.longitude = [NSNumber numberWithDouble:currentLong];
    point.pointType = [NSNumber numberWithInt:1];
    point.creationSequence = [NSNumber numberWithInt:sequence];
    
    STSensorPoint *ssp = [NSEntityDescription insertNewObjectForEntityForName:@"STSensorPoint" inManagedObjectContext:self.managedObjectContext];
    [ssp setTime:[NSDate date]];
    
    // *********  Woody *********
    NSLog(@"--- saveRoutePointForAnnotaton has %d otherSensorArray objects and %d wifiSensor objects", [otherSensorArray count], [wifiSensorArray count]);
    [ssp setWifiNetworks:[NSSet setWithArray:wifiSensorArray]];
    [ssp setMeasurements:[NSSet setWithArray:otherSensorArray]];
    // *********  Woody *********
    
    [point addSensorPointsObject:ssp];
    // woody: for continuous sensing... add all the sensor points to the point
    //    for (STSensorPoint *sp in continuousSensorPointArray) {
    //        [point addSensorPointsObject:sp];
    //    }
    
    [ssp setPoint:point];
    
    [_floorPlan addPointsObject:point];
    [point setFloor:_floorPlan];
    
    if (nextPoint != nil) {
        [point addAccessiblePointsObject:nextPoint];
        [_floorPlan addPointsObject:nextPoint];
        [nextPoint setFloor:_floorPlan];
        [stPoints addObject:nextPoint];
    }
    
    [stPoints addObject:point];
    
    NSError *error = nil;
    [self.managedObjectContext saveToPersistentStore:&error];
}
- (RMAnnotation *)createRoutePointAnnotationAtCoordinate:(CLLocationCoordinate2D)coordinate onMap:(RMMapView *)map {
    selectedMarkerType = 1;
    RMAnnotation *annotation = [RMAnnotation annotationWithMapView:map coordinate:coordinate andTitle:[NSString stringWithFormat:@""]];
    annotation.userInfo = @"routePoint";
    [map addAnnotation:annotation];
    annotation.title = [NSString stringWithFormat:@"%d", routepointCounter];
    annotation.subtitle = [NSString stringWithFormat:@"Coordinate %.3f %.3f", [annotation coordinate].latitude, [annotation coordinate].longitude];
    return annotation;
}
- (void)drawRouteToPoint:(CLLocation *)endPoint fromPoint:(CLLocation *)fromPoint onMap:(RMMapView *)map willMerge:(BOOL)willMerge {
    if (endPoint != nil) {
        NSMutableArray *allPoints = [self getAllIntermediatePointsWithFirstpoint:fromPoint toLastPoint:endPoint withIntermediateDistance:800000];
        int pointsInRoute = (allPoints.count - 1);
        for(int i = 0; i < pointsInRoute; i++) {
            routepointCounter++;
            [routes addObject:[[NSMutableArray alloc] init]];
            [[routes lastObject] addObject:[[CLLocation alloc] initWithLatitude:((CLLocation *)[allPoints objectAtIndex:i]).coordinate.latitude longitude:((CLLocation *)[allPoints objectAtIndex:i]).coordinate.longitude]];
            [[routes lastObject] addObject:[[CLLocation alloc] initWithLatitude:((CLLocation *)[allPoints objectAtIndex:i+1]).coordinate.latitude longitude:((CLLocation *)[allPoints objectAtIndex:i+1]).coordinate.longitude]];
            if (willMerge == YES && i == (pointsInRoute -1)) {
                selectedPoint = nil;
            } else {
                selectedPoint = [self createRoutePointAnnotationAtCoordinate:((CLLocation *)[allPoints objectAtIndex:i+1]).coordinate onMap:map];
            }
            
            //Save in database
            [self saveRoutePointAtLat:((CLLocation *)[allPoints objectAtIndex:i]).coordinate.latitude
                              andLong:((CLLocation *)[allPoints objectAtIndex:i]).coordinate.longitude
                          andSequence:routepointCounter
                   withNextPointAtLat:((CLLocation *)[allPoints objectAtIndex:i+1]).coordinate.latitude
                              andLong:((CLLocation *)[allPoints objectAtIndex:i+1]).coordinate.longitude];
            
            /*if (i == (allPoints.count - 2)) {
             [self saveRoutePointAtLat:((CLLocation *)[allPoints objectAtIndex:i+1]).coordinate.latitude
             andLong:((CLLocation *)[allPoints objectAtIndex:i+1]).coordinate.longitude
             andSequence:routepointCounter
             withNextPointAtLat:NAN
             andLong:NAN];
             }*/
            
        }
    } else {
        routepointCounter++;
        //selectedPoint = [self createRoutePointAnnotationAtCoordinate:fromPoint.coordinate onMap:map];
        [self saveRoutePointAtLat:fromPoint.coordinate.latitude
                          andLong:fromPoint.coordinate.longitude
                      andSequence:routepointCounter
               withNextPointAtLat:NAN
                          andLong:NAN];
    }
    
    [self drawAllroutes:map];
}
- (void)startSubRouteClicked {
    [self.detailViewPopover dismissPopoverAnimated:YES];
    //If the drawing mode is not set to "Route", set it to "Route"
    if ([(UISegmentedControl *)[self.selectedMode customView] selectedSegmentIndex] != 3) {
        [(UISegmentedControl *)[self.selectedMode customView] setSelectedSegmentIndex:3];
        [self drawingModeChanged:(UISegmentedControl *)[self.selectedMode customView]];
    }
}
- (void)mergeRouteClicked {
    [self.detailViewPopover dismissPopoverAnimated:YES];
    //If the drawing mode is not set to "Route", set it to "Route"
    if ([(UISegmentedControl *)[self.selectedMode customView] selectedSegmentIndex] != 3) {
        [(UISegmentedControl *)[self.selectedMode customView] setSelectedSegmentIndex:3];
        [self drawingModeChanged:(UISegmentedControl *)[self.selectedMode customView]];
    }
    //Now merge the selected point from the previous point
    if (previousRoutepoint != nil && [previousRoutepoint.userInfo isEqual:@"routePoint"]) {
        routeStartPoint = [[CLLocation alloc] initWithLatitude:previousRoutepoint.coordinate.latitude longitude:previousRoutepoint.coordinate.longitude];
        routeEndPoint = [[CLLocation alloc] initWithLatitude:selectedPoint.coordinate.latitude longitude:selectedPoint.coordinate.longitude];
        willMergeRoute = YES;
        /*[self drawRouteToPoint:[[CLLocation alloc] initWithLatitude:selectedPoint.coordinate.latitude longitude:selectedPoint.coordinate.longitude]
         fromPoint:[[CLLocation alloc] initWithLatitude:previousRoutepoint.coordinate.latitude longitude:previousRoutepoint.coordinate.longitude]
         onMap:mapView
         willMerge:YES];*/
        [self loadDataFromServerForCheckpoint:NO];
    }
}
- (void)editTitleClicked:(NSString *)title {
    NSLog(@"Title: %@", title);
    for (STPoint *sp in stPoints) {
        if ([sp.lattitude isEqualToNumber:[NSNumber numberWithDouble:[selectedPoint coordinate].latitude]]
            && [sp.longitude isEqualToNumber:[NSNumber numberWithDouble:[selectedPoint coordinate].longitude]]) {
            [sp setName:title];
        }
    }
    NSError *error = nil;
    [self.managedObjectContext saveToPersistentStore:&error];
}


#pragma mark Other Helper functions
- (void)drawingModeChanged:(id)sender {
    [self.startRoute setEnabled:NO];
    if ([(UISegmentedControl *)[self.selectedMode customView] selectedSegmentIndex] == 1) { // raspberry pi / waspmote
        self.statusLabel.text = @"Tap on the map to position the sensor";
    }
    else if ([(UISegmentedControl *)[self.selectedMode customView] selectedSegmentIndex] == 2) { // continuous sensing
        self.statusLabel.text = @"Tap to set continuous sensing points on the map";
    }
    else if ([(UISegmentedControl *)[self.selectedMode customView] selectedSegmentIndex] == 3) { // route
        self.statusLabel.text = @"Tap on the map to set corner points of route";
        [self.startRoute setEnabled:YES];
    }
    else {
        self.statusLabel.text = @"Tap to set checkpoints on the map"; // checkpoint
    }
    
}

#pragma mark Application flow
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"heatmap"]) {
        SCHeatMapViewController *controller = segue.destinationViewController;
        [controller setFloorPlan:self.floorPlan];
    }
}

@end
