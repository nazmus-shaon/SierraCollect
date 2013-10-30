//
//  KeyPointIndicator.h
//  Panorama
//
//  Created by Andrea Catalucci on 25/05/13.
//  Copyright (c) 2013 Natalia Zarawska. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STKeyPointIndicator : NSObject

/*
 shows the keypoints on the image
 
 @param image the image on which to show the waypoints
 @return the image with keypoints highlited in it
 */
+ (UIImage *)imageWithKeypoints: (UIImage *)image;

/*
 Finds out the number of keypoints an image has for stitching.
 
 @param image the image
 @return number of keypoints in the image
 */
+ (int) numberOfKeypointsInImage:(UIImage *) image;

@end
