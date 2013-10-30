//
//  STImageCaptureViewController.h
//  Panorama
//
//  Created by Christian Flasche on 24.06.13.
//  Copyright (c) 2013 Natalia Zarawska. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STImageCaptureDelegate.h"
#import <CoreMotion/CoreMotion.h>

@interface STImageCaptureViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) id<STImageCaptureDelegate> delegate;
@property (nonatomic, strong) UIImage *image;

FOUNDATION_EXPORT NSString *const STImageCaptureViewControllerImage;
FOUNDATION_EXPORT NSString *const STImageCaptureViewControllerPitch;
FOUNDATION_EXPORT NSString *const STImageCaptureViewControllerRoll;
FOUNDATION_EXPORT NSString *const STImageCaptureViewControllerYaw;
FOUNDATION_EXPORT NSString *const STImageCaptureViewControllerImageType;

FOUNDATION_EXPORT NSString *const kSTPanoramaImageType;
FOUNDATION_EXPORT NSString *const kSTSingleImageType;

@end
