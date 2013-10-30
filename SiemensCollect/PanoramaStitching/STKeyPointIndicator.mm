//
//  KeyPointIndicator.m
//  Panorama
//
//  Created by Andrea Catalucci on 25/05/13.
//  Copyright (c) 2013 Natalia Zarawska. All rights reserved.
//

#import "STKeyPointIndicator.h"
#import "UIImage+STOpenCV.h"

@implementation STKeyPointIndicator

+ (UIImage *)imageWithKeypoints:(UIImage *)image
{
    using namespace cv;
    Mat cvImage = image.toRGBCVMat;
    Ptr<FeatureDetector> detector = FeatureDetector::create("ORB");
    std::vector<KeyPoint> keypoints;
    detector->detect(cvImage, keypoints);
    Mat img_keypoints;
    drawKeypoints( cvImage, keypoints, img_keypoints, Scalar::all(-1), DrawMatchesFlags::DEFAULT );
    return [[UIImage alloc] initWithCVMat:img_keypoints];
}

+ (int) numberOfKeypointsInImage:(UIImage *) image
{
    return [image numberOfKeypoints];
}

@end
