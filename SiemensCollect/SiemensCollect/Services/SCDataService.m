//
//  SCPDFService.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 15.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCDataService.h"
#import "STDHCPClient.h"

@implementation SCDataService{
    NSOperationQueue *operationQueue;
}

+ (SCDataService *)shared {
    static SCDataService *shared;
    @synchronized(self)
    {
        if (!shared) {
            shared = [[SCDataService alloc] init];
        }
        
        return shared;
    }
}

- (id)init {
    self = [super init];
    if (self) {
        self.wifiSensorArray = [NSMutableArray array];
        self.otherSensorArray = [NSMutableArray array];
        self.dhcpClientArray = [NSMutableArray array];
        self.continuousMeasurementArray = [NSMutableArray array];
        
        //SETUP OBJECT CONTEXT
        self.managedObjectContext = [(SCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        self.managedObjectStore = [(SCAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectStore];
        
        operationQueue = [NSOperationQueue new];
        
        //Seeding will be done when there are no floorplans available
        if ([[self getCountries] count] == 0) {
            [self generateBuildingsData];
        }
    }
    return self;
}

- (void)generateBuildingsData {
    
    NSLog(@"Generating Building Data");
    
    //SETUP THE COUNTRY
    STCountry *uk = [NSEntityDescription insertNewObjectForEntityForName:@"STCountry" inManagedObjectContext:self.managedObjectContext];
    [uk setAbb:@"GB"];
    [uk setName:@"United Kingdom"];
    
    STCountry *spain = [NSEntityDescription insertNewObjectForEntityForName:@"STCountry" inManagedObjectContext:self.managedObjectContext];
    [spain setAbb:@"ES"];
    [spain setName:@"Spain"];
    
    STCountry *portugal = [NSEntityDescription insertNewObjectForEntityForName:@"STCountry" inManagedObjectContext:self.managedObjectContext];
    [portugal setAbb:@"PT"];
    [portugal setName:@"Portugal"];
    
    STCountry *germany = [NSEntityDescription insertNewObjectForEntityForName:@"STCountry" inManagedObjectContext:self.managedObjectContext];
    [germany setAbb:@"DE"];
    [germany setName:@"Germany"];
    
    STCountry *russia = [NSEntityDescription insertNewObjectForEntityForName:@"STCountry" inManagedObjectContext:self.managedObjectContext];
    [russia setAbb:@"RU"];
    [russia setName:@"Russia"];
    
    
    //SETUP THE CITY
    STCity *munich = [NSEntityDescription insertNewObjectForEntityForName:@"STCity" inManagedObjectContext:self.managedObjectContext];
    [munich setName:@"Munich"];
    
    STCity *london = [NSEntityDescription insertNewObjectForEntityForName:@"STCity" inManagedObjectContext:self.managedObjectContext];
    [london setName:@"London"];
    
    STCity *lisbon = [NSEntityDescription insertNewObjectForEntityForName:@"STCity" inManagedObjectContext:self.managedObjectContext];
    [lisbon setName:@"Lisbon"];
    
    STCity *barcelona = [NSEntityDescription insertNewObjectForEntityForName:@"STCity" inManagedObjectContext:self.managedObjectContext];
    [barcelona setName:@"Barcelona"];
    
    STCity *moscow = [NSEntityDescription insertNewObjectForEntityForName:@"STCity" inManagedObjectContext:self.managedObjectContext];
    [moscow setName:@"Moscow"];
    
    
    //SETUP THE AREA
    STArea *mchp = [NSEntityDescription insertNewObjectForEntityForName:@"STArea" inManagedObjectContext:self.managedObjectContext];
    [mchp setName:@"MCH P"];
    
    
    //SETUP THE BUILDING
    STBuilding *building48 = [NSEntityDescription insertNewObjectForEntityForName:@"STBuilding" inManagedObjectContext:self.managedObjectContext];
    [building48 setName:@"Building 48"];
    building48.number = [[NSNumber alloc] initWithInt:48];
    
    STBuilding *building10 = [NSEntityDescription insertNewObjectForEntityForName:@"STBuilding" inManagedObjectContext:self.managedObjectContext];
    [building10 setName:@"Building 10"];
    building10.number = [[NSNumber alloc] initWithInt:10];

    
    /*STBuilding *buildingFmi = [NSEntityDescription insertNewObjectForEntityForName:@"STBuilding" inManagedObjectContext:self.managedObjectContext];
     [buildingFmi setName:@"TUM FMI"];
     buildingFmi.number = [[NSNumber alloc] initWithInt:0];
     
     [barcelona addBuildingsObject:buildingFmi];
     [buildingFmi setCity:barcelona];*/
    
    //Add City to Country
    [germany addCitiesObject:munich];
    [portugal addCitiesObject:lisbon];
    [spain addCitiesObject:barcelona];
    [uk addCitiesObject:london];
    [russia addCitiesObject:moscow];
    
    //Add Area to City
    [munich addAreasObject:mchp];
    [mchp setCity:munich];
    
    //Add Building to Area
    [mchp addBuildingsObject:building48];
    [building48 setArea:mchp];
    
    [mchp addBuildingsObject:building10];
    [building10 setArea:mchp];
    
    //STEP 1 -- Read Standard PDFs stored in the project
    NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    
    for (NSString *str in pdfs) {
        NSURL *url=[NSURL fileURLWithPath:str];
        NSArray *parts = [[url lastPathComponent] componentsSeparatedByString: @"_"];
        NSString *partCity = [parts objectAtIndex:0];
        NSString *partArea = [parts objectAtIndex:1];
        NSString *partBuilding = [parts objectAtIndex:2];
        NSString *partFloor = [parts objectAtIndex:3];
        NSString *partFloorName = [[parts objectAtIndex:4] substringToIndex:[[parts objectAtIndex:4] rangeOfString:@"."].location];
        
        STFloor *flr = [NSEntityDescription insertNewObjectForEntityForName:@"STFloor" inManagedObjectContext:self.managedObjectContext];
        
        flr.floorNr = [[NSNumber alloc] initWithInt:[partBuilding intValue]];
        
        if ([partFloor isEqualToString: @"2"]) {
            [flr setIsGroundFloor:[NSNumber numberWithBool:YES]];
        } else {
            [flr setIsGroundFloor:[NSNumber numberWithBool:NO]];
        }
        [flr setName: partFloorName];
        [flr setRelatedFile: [url lastPathComponent]];
        
        if ([partCity isEqualToString:@"MUN"] && [partArea isEqualToString:@"MCHP"] && [partBuilding isEqualToString:@"48"]) {
            [building48 addFloorsObject:flr];
            [flr setBuilding:building48];
        } else if ([partCity isEqualToString:@"MUN"] && [partArea isEqualToString:@"MCHP"] && [partBuilding isEqualToString:@"10"]) {
            [building10 addFloorsObject:flr];
            [flr setBuilding:building10];
        }/*else if ([partCity isEqualToString:@"BAR"] && [partBuilding isEqualToString:@"FMI"]) {
            [buildingFmi addFloorsObject:flr];
            [flr setBuilding:buildingFmi];
        }*/
    }
    
    //Add two mor buildings:
    /*STBuilding *buildingTUM2 = [NSEntityDescription insertNewObjectForEntityForName:@"STBuilding" inManagedObjectContext:self.managedObjectContext];
    [buildingTUM2 setName:@"TUM Chemie"];
    buildingTUM2.number = [[NSNumber alloc] initWithInt:0];
    
    [barcelona addBuildingsObject:buildingTUM2];
    [buildingTUM2 setCity:barcelona];
    
    STBuilding *buildingTUM3 = [NSEntityDescription insertNewObjectForEntityForName:@"STBuilding" inManagedObjectContext:self.managedObjectContext];
    [buildingTUM3 setName:@"TUM Maschinenwesen"];
    buildingTUM3.number = [[NSNumber alloc] initWithInt:0];
    
    [munich addBuildingsObject:buildingTUM3];
    [buildingTUM3 setCity:munich];
    */
    
    NSError *error;
    if (![self.managedObjectContext saveToPersistentStore:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
}

- (NSArray *)getLastUpdatedFloorplans {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STBuilding"];
    
    NSError *error;
    NSArray *retAry = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    for (STBuilding *building in retAry) {
        if ([[(STCity *)building name] isEqualToString:@"Building 48"]) {
            return [self getFloorplansForBuilding: building];
        }
    }
    return nil;
}

- (NSArray *)getFloorplansForBuilding:(STBuilding*)building {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STFloor"];
    NSError *error;
    NSArray *retAry = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSMutableArray *filteredArray = [NSMutableArray array];
    for (STFloor *floor in retAry) {
        if ((STBuilding *)[floor building] == building) {
            [filteredArray addObject:floor];
        }
    }
    
    NSArray *sortedArray = [(NSArray *)filteredArray sortedArrayUsingComparator: ^(STFloor *obj1, STFloor *obj2) {
        return [obj2.name compare:obj1.name];
    }];
    return sortedArray;
}

- (NSArray *)getCountries {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STCountry"];
    NSError *error;
    NSArray *retAry = [self.managedObjectContext executeFetchRequest:request error:&error];
    //    for (STCountry *country in retAry) {
    //        NSLog(@"fetched countries %@", [country name]);
    //    }
    return retAry;
}

- (NSArray*)getAreasForCity:(STCity*)city {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STArea"];
    
    NSError *error;
    NSArray *retAry = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSMutableArray *filteredArray = [NSMutableArray array];
    for (STArea *area in retAry) {
        if ((STCity *)[area city] == city) {
            [filteredArray addObject:area];
        }
    }
    
    return (NSArray *)filteredArray;
}

- (NSArray*)getBuildingsForArea:(STArea*)area {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STBuilding"];
    
    NSError *error;
    NSArray *retAry = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSMutableArray *filteredArray = [NSMutableArray array];
    for (STBuilding *building in retAry) {
        if ((STArea *)[building area] == area) {
            [filteredArray addObject:building];
        }
    }
    
    return (NSArray *)filteredArray;
}

- (NSArray*)getCitiesForCountry:(STCountry*)country {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STCity"];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"STCountry == %@", country];
    //[request setPredicate:predicate];
    
    NSError *error;
    NSArray *retAry = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSMutableArray *filteredArray = [NSMutableArray array];
    for (STCity *city in retAry) {
        if ([(STCountry *)[city country] abb] == [country abb]) {
            [filteredArray addObject:city];
        }
    }
    //[retAry filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY %K IN %@",country,[city country]]]
    return (NSArray *)filteredArray;
}

- (NSArray*)getPointsforFloor:(STFloor *)floor {
    NSArray *retArray = [NSArray array];
    if (floor != nil) {
        retArray = [floor.points allObjects];
    } else {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STPoint"];
        NSError *error;
        retArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    }
    return retArray;
}


-(void)setupObjectManager{
    self.objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:[[SCAppCore shared] baseURL]]];
}

- (void)getWifisensorsAddTarget:(id)target action:(SEL)action {
    [self setupObjectManager];
    
    //Map STWifiSensors
    RKEntityMapping *wifiMapping = [RKEntityMapping mappingForEntityForName:@"STWifiNetwork" inManagedObjectStore:self.managedObjectStore];
    [wifiMapping addAttributeMappingsFromDictionary:@{
                                                      @"ssid":               @"ssid",
                                                      @"protocol":           @"protocol",
                                                      @"mode":               @"mode",
                                                      @"frequency":          @"frequency",
                                                      @"encryptionKey":      @"encryptionKey",
                                                      @"bitRates":           @"bitRates",
                                                      @"extra":              @"extra",
                                                      @"ie":                 @"ie",
                                                      @"quality":            @"quality",
                                                      @"signalLevel":        @"signalLevel",
                                                      @"macAddress":         @"macAddress"}];
    //    wifiMapping.identificationAttributes = @[@"ssid"];
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
    
    //Configure Response Description
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:wifiMapping pathPattern:[[SCAppCore shared] wifiPathPattern] keyPath:nil statusCodes:statusCodes];
    
    [self.objectManager addResponseDescriptorsFromArray:@[responseDescriptor]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[SCAppCore shared] wifiURL]]];
    
    //Configure Fetching Operation
    RKManagedObjectRequestOperation *operationWifisensor = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    operationWifisensor.managedObjectContext = self.managedObjectStore.mainQueueManagedObjectContext;
    operationWifisensor.managedObjectCache = self.managedObjectStore.managedObjectCache;
    
    [operationWifisensor setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [self.wifiSensorArray removeAllObjects];
        
        //        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"ssid" ascending:YES];
        //        [self.wifiSensorArray addObjectsFromArray:[result.array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]]];
        [self.wifiSensorArray addObjectsFromArray:result.array];
        NSLog(@"******** SCDataService.getWifisensors found %d wifis", [self.wifiSensorArray count]);
        
        if ([target respondsToSelector:action]) {
            [target performSelector:action withObject:self.wifiSensorArray];
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"******** Failed with error: %@", [error localizedDescription]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Failure: %@ ", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
    // add the fetching operation in Operation Queue
    //NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operationWifisensor];
    [operationQueue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
    
    //NSLog(@"********** Returning Wifi Sensor Array %i", [self.wifiSensorArray count]);
}

- (void)getOtherSensorsAddTarget:(id)target action:(SEL)action{
    [self setupObjectManager];
    
    //Map STMeasurement and its relation with STSensor
    RKEntityMapping *measurementMapping = [RKEntityMapping mappingForEntityForName:@"STMeasurement" inManagedObjectStore:self.managedObjectStore];
    [measurementMapping addAttributeMappingsFromDictionary:@{
                                                             @"value":               @"value",
                                                             @"created":            @"created"
                                                             }];
    
    RKEntityMapping *sensorMapping = [RKEntityMapping mappingForEntityForName:@"STSensor" inManagedObjectStore:self.managedObjectStore];
    [sensorMapping addAttributeMappingsFromDictionary:@{
                                                        @"type":               @"type",
                                                        @"unit":               @"unit"}];
    
    [measurementMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"sensor"
                                                                                       toKeyPath:@"sensor"
                                                                                     withMapping:sensorMapping]];
    
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
    
    //Configure Response Description
    RKResponseDescriptor *responseDescriptorMeasurement = [RKResponseDescriptor responseDescriptorWithMapping:measurementMapping pathPattern:[[SCAppCore shared] measPathPattern] keyPath:nil statusCodes:statusCodes];
    
    [self.objectManager addResponseDescriptorsFromArray:@[ responseDescriptorMeasurement ]];
    
    NSURLRequest *requestMeasurement = [NSURLRequest requestWithURL:[NSURL URLWithString:[[SCAppCore shared] measURL]]];
    
    //Configure Fetching Operation
    RKManagedObjectRequestOperation *operationMeasurement = [[RKManagedObjectRequestOperation alloc] initWithRequest:requestMeasurement responseDescriptors:@[responseDescriptorMeasurement]];
    operationMeasurement.managedObjectContext = self.managedObjectStore.mainQueueManagedObjectContext;
    operationMeasurement.managedObjectCache = self.managedObjectStore.managedObjectCache;
    
    [operationMeasurement setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [self.otherSensorArray removeAllObjects];
        
        //        NSArray *sortedArray = [result.array sortedArrayUsingComparator: ^(STMeasurement *obj1, STMeasurement *obj2) {
        //            return [obj1.sensor.unit compare:obj2.sensor.unit];
        //        }];
        //        [self.otherSensorArray addObjectsFromArray:sortedArray];
        if ([[SCAppCore shared] appMode] == 3) { //Sakib - waspmote
            [self getOtherSensorsAddTargetForWaspmote];
        } else {
            [self.otherSensorArray addObjectsFromArray:result.array];
        }
        
        NSLog(@"******** SCDataService.getOtherSensors found %d sensors", [self.otherSensorArray count]);
        if ([target respondsToSelector:action]) {
            [target performSelector:action withObject:self.otherSensorArray];
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"******** Failed with error: %@", [error localizedDescription]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Failure: %@ ", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
    //Add the fetching operation in Operation Queue
    //NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operationMeasurement];
}

- (void)getOtherSensorsAddTargetForWaspmote{
    // Sakib added for dummy waspmote data
    
    //Lumosity - 231
    STSensor *stSensor = [NSEntityDescription insertNewObjectForEntityForName:@"STSensor" inManagedObjectContext:self.managedObjectContext];
    [stSensor setType:[NSNumber numberWithInteger: 231]];
    [stSensor setUnit:@"%"];
    STMeasurement *stm = [NSEntityDescription insertNewObjectForEntityForName:@"STMeasurement" inManagedObjectContext:self.managedObjectContext];
    [stm setValue:[NSNumber numberWithInteger: 0 + rand() % (100-0)]]; //min + rand() % (max-min);
    [stm setCreated:[NSDate date]];
    [stm setSensor:stSensor];
    
    [self.otherSensorArray addObject:stm];
    
    //Oxyzen - 232
    stSensor = [NSEntityDescription insertNewObjectForEntityForName:@"STSensor" inManagedObjectContext:self.managedObjectContext];
    [stSensor setType:[NSNumber numberWithInteger: 232]];
    [stSensor setUnit:@"%"];
    stm = [NSEntityDescription insertNewObjectForEntityForName:@"STMeasurement" inManagedObjectContext:self.managedObjectContext];
    [stm setValue:[NSNumber numberWithInteger: 17 + rand() % (22-17)]];
    [stm setCreated:[NSDate date]];
    [stm setSensor:stSensor];
    
    [self.otherSensorArray addObject:stm];
    
    //CO2 - 233
    stSensor = [NSEntityDescription insertNewObjectForEntityForName:@"STSensor" inManagedObjectContext:self.managedObjectContext];
    [stSensor setType:[NSNumber numberWithInteger: 233]];
    [stSensor setUnit:@"%"];
    stm = [NSEntityDescription insertNewObjectForEntityForName:@"STMeasurement" inManagedObjectContext:self.managedObjectContext];
    [stm setValue:[NSNumber numberWithFloat: arc4random() % 10 * 0.1]];
    [stm setCreated:[NSDate date]];
    [stm setSensor:stSensor];
    
    [self.otherSensorArray addObject:stm];
    
    //Temperature - 234
    stSensor = [NSEntityDescription insertNewObjectForEntityForName:@"STSensor" inManagedObjectContext:self.managedObjectContext];
    [stSensor setType:[NSNumber numberWithInteger: 234]];
    [stSensor setUnit:@"Â°C"];
    stm = [NSEntityDescription insertNewObjectForEntityForName:@"STMeasurement" inManagedObjectContext:self.managedObjectContext];
    [stm setValue:[NSNumber numberWithFloat: -20 + rand() % (40-(-20))]];
    [stm setCreated:[NSDate date]];
    [stm setSensor:stSensor];
    
    [self.otherSensorArray addObject:stm];
    
    //Humidity - 235
    stSensor = [NSEntityDescription insertNewObjectForEntityForName:@"STSensor" inManagedObjectContext:self.managedObjectContext];
    [stSensor setType:[NSNumber numberWithInteger: 235]];
    [stSensor setUnit:@"%"];
    stm = [NSEntityDescription insertNewObjectForEntityForName:@"STMeasurement" inManagedObjectContext:self.managedObjectContext];
    [stm setValue:[NSNumber numberWithFloat: 0 + rand() % (100-0)]];
    [stm setCreated:[NSDate date]];
    [stm setSensor:stSensor];
    
    [self.otherSensorArray addObject:stm];
}

- (void)getDHCPClientsAddTarget:(id)target action:(SEL)action {
    //[self setupObjectManager];
    
    //Map STDHCPClient
    //RKEntityMapping *dhcpClientMapping = [RKEntityMapping mappingForEntityForName:@"STDHCPClient" inManagedObjectStore:self.managedObjectStore];
    RKObjectMapping* dhcpClientMapping = [RKObjectMapping mappingForClass:[STDHCPClient class]];
    [dhcpClientMapping addAttributeMappingsFromDictionary:@{
                                                            @"leaseExpirationTime":    @"leaseExpirationTime",
                                                            @"macAddress":             @"macAddress",
                                                            @"ipAddress":              @"ipAddress",
                                                            @"clientName":             @"clientName",
                                                            @"tinkerforgeBrick":       @"tinkerforgeBrick"}];
    //    wifiMapping.identificationAttributes = @[@"ssid"];
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
    
    //Configure Response Description
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:dhcpClientMapping pathPattern:nil keyPath:nil statusCodes:statusCodes];
    
    //[self.objectManager addResponseDescriptorsFromArray:@[responseDescriptor]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[SCAppCore shared] dhcpURL]]];
    
    //Configure Fetching Operation
    RKObjectRequestOperation *operationDHCPClient = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    //operationDHCPClient.managedObjectContext = self.managedObjectStore.mainQueueManagedObjectContext;
    //operationDHCPClient.managedObjectCache = self.managedObjectStore.managedObjectCache;
    
    [operationDHCPClient setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [self.dhcpClientArray removeAllObjects];
        
        //        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"ssid" ascending:YES];
        //        [self.dhcpClientArray addObjectsFromArray:[result.array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]]];
        [self.dhcpClientArray addObjectsFromArray:result.array];
        NSLog(@"******** SCDataService.getDHCPClients found %d clients", [self.dhcpClientArray count]);
        
        if ([target respondsToSelector:action]) {
            [target performSelector:action withObject:self.dhcpClientArray];
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"******** Failed with error: %@", [error localizedDescription]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Failure: %@ ", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
    // add the fetching operation in Operation Queue
    //NSOperationQueue *operationQueue = [NSOperationQueue new];
    //[operationQueue addOperation:operationDHCPClient];
    //[operationQueue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
    [operationDHCPClient start];
    
    //NSLog(@"********** Returning Wifi Sensor Array %i", [self.dhcpClientArray count]);
}

- (void)getContinuousMeasurementsAddTarget:(id)target action:(SEL)action {
    [self setupObjectManager];
    
    //Map STMeasurement and its relation with STSensor
    RKEntityMapping *contMeasMapping = [RKEntityMapping mappingForEntityForName:@"STMeasurement" inManagedObjectStore:self.managedObjectStore];
    [contMeasMapping addAttributeMappingsFromDictionary:@{
                                                          @"value":              @"value",
                                                          @"created":            @"created"
                                                          }];
    
    RKEntityMapping *sensorMapping = [RKEntityMapping mappingForEntityForName:@"STSensor" inManagedObjectStore:self.managedObjectStore];
    [sensorMapping addAttributeMappingsFromDictionary:@{
                                                        @"type":               @"type",
                                                        @"unit":               @"unit"}];
    
    [contMeasMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"sensor"
                                                                                    toKeyPath:@"sensor"
                                                                                  withMapping:sensorMapping]];
    
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
    
    //Configure Response Description
    RKResponseDescriptor *responseDescriptorMeasurement = [RKResponseDescriptor responseDescriptorWithMapping:contMeasMapping pathPattern:[[SCAppCore shared] contMeasPathPattern] keyPath:nil statusCodes:statusCodes];
    
    [self.objectManager addResponseDescriptorsFromArray:@[ responseDescriptorMeasurement ]];
    
    NSURLRequest *requestMeasurement = [NSURLRequest requestWithURL:[NSURL URLWithString:[[SCAppCore shared] contMeasURL]]];
    
    //Configure Fetching Operation
    RKManagedObjectRequestOperation *operationMeasurement = [[RKManagedObjectRequestOperation alloc] initWithRequest:requestMeasurement responseDescriptors:@[responseDescriptorMeasurement]];
    operationMeasurement.managedObjectContext = self.managedObjectStore.mainQueueManagedObjectContext;
    operationMeasurement.managedObjectCache = self.managedObjectStore.managedObjectCache;
    
    [operationMeasurement setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        [self.continuousMeasurementArray removeAllObjects];
        
        NSArray *sortedArray = [result.array sortedArrayUsingComparator: ^(STMeasurement *obj1, STMeasurement *obj2) {
            return [obj2.created compare:obj1.created];
        }];
        [self.continuousMeasurementArray addObjectsFromArray:sortedArray];
        //        [self.continuousMeasurementArray addObjectsFromArray:result.array];
        NSLog(@"******** SCDataService.getContinuousMeasurement found %d sensors", [self.continuousMeasurementArray count]);
        
        if ([target respondsToSelector:action]) {
            [target performSelector:action withObject:self.continuousMeasurementArray];
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"******** Failed with error: %@", [error localizedDescription]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"Failure: %@ ", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
    //Add the fetching operation in Operation Queue
    //NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operationMeasurement];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (object == operationQueue && [keyPath isEqualToString:@"operations"]) {
        if ([operationQueue.operations count] == 0) {
            //NSLog(@"********** All Operation Queue Completed");
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
