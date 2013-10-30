//
//  SCWebDAVService.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 11.06.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DZWebDAVClient.h"

@interface SCWebDAVService : NSObject {
    DZWebDAVClient *client;
}

+ (SCWebDAVService *)shared;

- (void)uploadImage:(UIImage *)_image withName:(NSString *)_name;
- (void)downloadImageWithName:(NSString *)_name;
- (void)fetchFileList;


- (void)uploadImage:(UIImage *)_image forPoint:(STSensorPoint *)_sensorPoint;
- (void)generatFolderforPoint:(STSensorPoint *)_sensorPoint andImage:(UIImage *)_image;

- (UIImage *)imageForSensorPoint:(STSensorPoint *)_sensorPoint;

- (void)saveHeatmapToWebDav:(UIImage *)_image forFloor:(STFloor *)_floor withInformation:(NSDictionary *)_informations;
- (void)saveHeatMapToDocuments:(UIImage *)_image forFloor:(STFloor *)_floor withInformation:(NSDictionary *)_informations;
- (NSArray *)fetchHeatMapImagesforFloor:(STFloor*)_floor;
- (UIImage *)fetchImageWithName:(NSString *)_name inFloor:(STFloor *)_floor;

- (void)uploadSQLFile;

@end
