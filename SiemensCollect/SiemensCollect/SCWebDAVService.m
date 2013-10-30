//
//  SCWebDAVService.m
//  SiemensCollect
//
//  Created by Andreas Seitz on 11.06.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import "SCWebDAVService.h"

@implementation SCWebDAVService

+ (SCWebDAVService *)shared {
    static SCWebDAVService *shared;
    @synchronized(self)
    {
        if (!shared) {
            shared = [[SCWebDAVService alloc] init];
        }
        return shared;
    }
}

- (id)init {
    self = [super init];
    if (self) {
       //SETUP WEBDAV CREDENTIALS
        client = [[DZWebDAVClient alloc] initWithBaseURL:[NSURL URLWithString:[[SCAppCore shared] webDavURL]]];
        [client setAuthorizationHeaderWithUsername:scWebDAVUser password:scWebDAVPassword];
    }
    return self;
}

- (void)uploadImage:(UIImage *)_image withName:(NSString *)_name {
    NSString *path;
    if (_name != nil) {
        path = [NSString stringWithFormat:@"%@%@%@", [[SCAppCore shared] webDavURL], _name, @".png"];
    } else {
        NSString *str = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        path = [NSString stringWithFormat:@"%@%@%@", [[SCAppCore shared] webDavURL], str, @".png"];
    }
    [client put:UIImagePNGRepresentation(_image) path:path success:^{
        NSLog(@"success");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)uploadImage:(UIImage *)_image forPoint:(STSensorPoint *)_sensorPoint {
//    NSString *path;
//    if (_sensorPoint != nil) {
//        path = [NSString stringWithFormat:@"%@/%i/points/%f_%f/sensorpoints/%f/image.jpg", scWebDAVURL, _sensorPoint.point.floor.floorNr.intValue, _sensorPoint.point.lattitude.floatValue, _sensorPoint.point.longitude.floatValue, _sensorPoint.time.timeIntervalSince1970];
//
//    }
//    NSLog(@"Path: %@", path);
//    
//    [client put:UIImageJPEGRepresentation(_image, 0.8) path:path success:^{
//        NSLog(@"success");
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@", error);
//    }];
    
    NSLog(@"Store it to documents");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent: [NSString stringWithFormat:@"%i_points_%f_%f_sensorpoints_%f_image.png", _sensorPoint.point.floor.floorNr.intValue, _sensorPoint.point.lattitude.floatValue, _sensorPoint.point.longitude.floatValue, _sensorPoint.time.timeIntervalSince1970]]; //Add the file name
    [UIImageJPEGRepresentation(_image, 0.8) writeToFile:filePath atomically:YES];
    //NSLog(@"save path: %@", path);
    NSLog(@"saved");
}


- (void)downloadImageWithName:(NSString *)_name {
    [client getPath:[NSString stringWithFormat:@"%@%@", [[SCAppCore shared] webDavURL], _name] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

-(NSString *)folder
{
    NSString *countryCode = @"DE";
    NSString *city = @"munich";
    city = [city lowercaseString];
    NSString *buildingName = @"mchp";
    buildingName = [buildingName lowercaseString];
    NSString *buildingNumber = @"48";
    NSString *buildingRepr = [@[countryCode, @"_", city, @"_", buildingName, @"_", buildingNumber,@"/"] componentsJoinedByString:@""];
    return [@"buildings/" stringByAppendingString: buildingRepr];
}

- (void)saveHeatmapToWebDav:(UIImage *)_image forFloor:(STFloor *)_floor withInformation:(NSDictionary *)_informations {
    
    
    NSLog(@"informations dict: %@", _informations);
    NSString *path = [NSString stringWithFormat:@"%@/%i/", [[SCAppCore shared] webDavURL], _floor.floorNr.intValue];
    [client getPath:path success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Path Exists! %@", path);
        NSString *imagePath = [[[path stringByAppendingString:[NSString stringWithFormat:@"heatmap_%@_%f.png", [_informations objectForKey:@"SCHeatMapSettingsValue"], [[NSDate date] timeIntervalSince1970]]] stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        [client put:UIImagePNGRepresentation(_image) path:imagePath success:^{
            NSLog(@"success uploading heatMap");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Heatmap upload Error: %@", error);
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"path error: %@", path);
    }];
}

- (void)saveHeatMapToDocuments:(UIImage *)_image forFloor:(STFloor *)_floor withInformation:(NSDictionary *)_informations {
    NSURL * baseURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSLog(@"baseURL: %@", baseURL.absoluteString);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *buildingTargetURL = [[baseURL.absoluteString stringByAppendingString:[self folder]] stringByAppendingString:[NSString stringWithFormat:@"%i/", _floor.floorNr.intValue]];
    
    NSError*    theError = nil; //error setting
    if (![fileManager createDirectoryAtURL:[NSURL URLWithString:buildingTargetURL] withIntermediateDirectories:YES attributes:nil error:&theError])
    {
        NSLog(@"not created: error: %@", theError.localizedDescription);
    } else {
        buildingTargetURL = [[[buildingTargetURL stringByAppendingString:[NSString stringWithFormat:@"heatmap_%@_%f.png", [_informations objectForKey:@"SCHeatMapSettingsValue"], [[NSDate date] timeIntervalSince1970]]] stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSLog(@"building target URL: %@", buildingTargetURL);
        [UIImagePNGRepresentation(_image) writeToURL:[NSURL URLWithString:buildingTargetURL] atomically:YES];
        NSLog(@"stored image");
    }
}

- (NSArray *)fetchHeatMapImagesforFloor:(STFloor*)_floor {
    NSURL * baseURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *directory = [[baseURL.absoluteString stringByAppendingString:[self folder]] stringByAppendingString:[NSString stringWithFormat:@"%i/", _floor.floorNr.intValue]];
    NSArray *heatMaps = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL URLWithString:directory] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    NSLog(@"heatMaps :%@", heatMaps);
    NSMutableArray *retArry = [NSMutableArray array];
    for (NSURL *url in heatMaps) {
        if ([url.absoluteString.lastPathComponent isEqualToString:@"points"]) {
            //Don't add the Points folder!
        } else {
            [retArry addObject:[url.absoluteString lastPathComponent]];
        }
    }
    NSLog(@"ret arry: %@", retArry);
    return retArry;
}

- (UIImage *)fetchImageWithName:(NSString *)_name inFloor:(STFloor *)_floor {
    NSURL * baseURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *fileURL = [[baseURL.absoluteString stringByAppendingString:[self folder]] stringByAppendingString:[NSString stringWithFormat:@"%i/", _floor.floorNr.intValue]];
    fileURL = [fileURL stringByAppendingString:_name];
    NSLog(@"FETCH file from: %@", fileURL);
    NSData *pngData = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    UIImage *image = [UIImage imageWithData:pngData];
    
    if (pngData != nil) {
        return image;
    } else {
        return nil;
    }
}

- (void)generatFolderforPoint:(STSensorPoint *)_sensorPoint andImage:(UIImage *)_image {
    [self saveImageToDocuments:_image andSensorPoint:_sensorPoint];
    
//     NSString *basePath = [[[NSString stringWithFormat:@"%@/DE_munich_%@_%i/floors", [[SCAppCore shared] webDavURL], _sensorPoint.point.floor.building.name, _sensorPoint.point.floor.building.number.intValue] lowercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *basePath = [NSString stringWithFormat:@"%@/DE_munich_%@_%i/floors", [[SCAppCore shared] webDavURL], [[_sensorPoint.point.floor.building.name lowercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], _sensorPoint.point.floor.building.number.intValue] ;
    
    NSString *path;
    
    //DE_munich_mchp_48/floors
    
    //FIRST CHECK IF POINT EXISTS
    path = [NSString stringWithFormat:@"%@/%i/points/%f_%f/", basePath, _sensorPoint.point.floor.floorNr.intValue, _sensorPoint.point.lattitude.floatValue, _sensorPoint.point.longitude.floatValue];
    
    [client getPath:path success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Path Exists! %@", path);
        [self createTimeStampFolder:_image andSensorpoint:_sensorPoint];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Path did Not Exist then create it!");
        [client makeCollection:path success:^{
            NSLog(@"Path successfully Created");
            NSString *sensorPointsPath = [NSString stringWithFormat:@"%@/%i/points/%f_%f/sensorpoints/", basePath, _sensorPoint.point.floor.floorNr.intValue, _sensorPoint.point.lattitude.floatValue, _sensorPoint.point.longitude.floatValue];
            [client makeCollection:sensorPointsPath success:^{
                NSLog(@"Created Path: %@", sensorPointsPath);
                [self createTimeStampFolder:_image andSensorpoint:_sensorPoint];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"error creating sensorpointspath");
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"could not creat path: %@", path);
        }];
    }];
}

- (void)createTimeStampFolder:(UIImage *)_image andSensorpoint:(STSensorPoint *)_sensorPoint {
    NSString *basePath = [NSString stringWithFormat:@"%@/DE_munich_%@_%i/floors", [[SCAppCore shared] webDavURL], [[_sensorPoint.point.floor.building.name lowercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], _sensorPoint.point.floor.building.number.intValue];
    
    NSString *timestampPath = [NSString stringWithFormat:@"%@/%i/points/%f_%f/sensorpoints/%f/", basePath, _sensorPoint.point.floor.floorNr.intValue, _sensorPoint.point.lattitude.floatValue, _sensorPoint.point.longitude.floatValue, _sensorPoint.time.timeIntervalSince1970];
    
    [client getPath:timestampPath success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"timstamp path exists");
        NSString *imagepath = [NSString stringWithFormat:@"%@/%i/points/%f_%f/sensorpoints/%f/image.jpg", basePath, _sensorPoint.point.floor.floorNr.intValue, _sensorPoint.point.lattitude.floatValue, _sensorPoint.point.longitude.floatValue, _sensorPoint.time.timeIntervalSince1970];
        [client put:UIImageJPEGRepresentation(_image, 1) path:imagepath success:^{
            NSLog(@"success uploading");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [client makeCollection:timestampPath success:^{
            NSLog(@"Created Path: %@", timestampPath);
            //Save Image
            NSString *imagepath = [NSString stringWithFormat:@"%@/%i/points/%f_%f/sensorpoints/%f/image.jpg", basePath, _sensorPoint.point.floor.floorNr.intValue, _sensorPoint.point.lattitude.floatValue, _sensorPoint.point.longitude.floatValue, _sensorPoint.time.timeIntervalSince1970];
            [client put:UIImageJPEGRepresentation(_image, 1) path:imagepath success:^{
                NSLog(@"success uploading");
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@", error);
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Could Not Create Path: %@", timestampPath);
        }];
    }];
    
    
    
    
}

- (void)saveImageToDocuments:(UIImage *)_image andSensorPoint:(STSensorPoint*)_sensorPoint {
    NSURL * baseURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSLog(@"baseURL: %@", baseURL.absoluteString);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *buildingTargetURL = [[baseURL.absoluteString stringByAppendingString:[self folder]] stringByAppendingString:[NSString stringWithFormat:@"%i/points/%f_%f/sensorpoints/%f/", _sensorPoint.point.floor.floorNr.intValue, _sensorPoint.point.lattitude.floatValue, _sensorPoint.point.longitude.floatValue, _sensorPoint.time.timeIntervalSince1970]];
    
    NSLog(@"building target URL: %@", buildingTargetURL);
    
    NSError*    theError = nil; //error setting
    if (![fileManager createDirectoryAtURL:[NSURL URLWithString:buildingTargetURL] withIntermediateDirectories:YES attributes:nil error:&theError])
    {
        NSLog(@"not created: error: %@", theError.localizedDescription);
    } else {
        buildingTargetURL = [buildingTargetURL stringByAppendingString:@"image.png"];
        [UIImagePNGRepresentation(_image) writeToURL:[NSURL URLWithString:buildingTargetURL] atomically:YES];
        NSLog(@"stored image");
    }
}

- (UIImage *)imageForSensorPoint:(STSensorPoint *)_sensorPoint {
    NSURL * baseURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSString *fileURL = [[baseURL.absoluteString stringByAppendingString:[self folder]] stringByAppendingString:[NSString stringWithFormat:@"%i/points/%f_%f/sensorpoints/%f/", _sensorPoint.point.floor.floorNr.intValue, _sensorPoint.point.lattitude.floatValue, _sensorPoint.point.longitude.floatValue, _sensorPoint.time.timeIntervalSince1970]];
    fileURL = [fileURL stringByAppendingString:@"image.png"];
    
    NSLog(@"FETCH file from: %@", fileURL);
    
    NSData *pngData = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    UIImage *image = [UIImage imageWithData:pngData];
    
    if (pngData != nil) {
        return image;
    } else {
        return nil;
    }  
}

- (void)uploadSQLFile {
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"SierraDB.sqlite"];
    NSLog(@"storepath: %@", storePath);
    NSData *data = [NSData dataWithContentsOfFile:storePath];
    
     NSString *imagepath = [NSString stringWithFormat:@"%@SierraDB.sqlite", [[SCAppCore shared] webDavBaseURL]];
    
    [client put:data path:imagepath success:^{
        NSLog(@"uploaded");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Database was uploaded to repository server" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Unable to upload database to Repository Server. Please try again." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }];

}

- (void)fetchFileList {
    //------------------- Got Problems with Parsing the Data!
//    curl -i --user 'myipad:test1' -X PROPFIND http://192.168.178.105/webdav/ --upload-file - -H "Depth: 1" <<end
//    <?xml version="1.0"?>
//    <a:propfind xmlns:a="DAV:">
//    <a:prop><a:resourcetype/></a:prop>
//    </a:propfind>
//    end
    
    
//    [client propertiesOfPath:@"http://192.168.178.105/webdav/" success:^(AFHTTPRequestOperation *operation, id responseObject) {
//       // NSLog(@"response: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@", error);
//    }];

}



@end
