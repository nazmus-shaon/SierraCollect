//
//  STFloor+Sierra.m
//  SierraClassLib
//
//  Created by Andreas Seitz on 08.07.13.
//  Copyright (c) 2013 Lehrstuhl für Angewandte Softwaretechnik. All rights reserved.
//

#import "STFloor+Sierra.h"
#import "UIImage+PDF.h"

@implementation STFloor (Sierra)

- (UIImage *)getSmallPreviewImage {
    return [UIImage imageWithPDFNamed:self.relatedFile atHeight:160 atPage:1];
}

- (UIImage *)getImageforWidth:(float)width {
    //NSLog(@"PATH: %@ URL TO FILE: %@", self.pathToFloorPlan, [[NSURL URLWithString:[NSString stringWithFormat:@"%@", self.pathToFloorPlan]] absoluteString]);
    //return [UIImage imageWithPDFURL:[NSURL URLWithString:self.pathToFloorPlan] atWidth:width atPage:1];
    #warning PDF Name not unique
    UIImage *returnImg = [UIImage imageWithPDFNamed:self.relatedFile atWidth:width atPage:1]; //memory leak here
    
    return returnImg;
}

- (UIImage *)getImageforHeight:(float)height {
    return [UIImage imageWithPDFNamed:self.relatedFile atHeight:height atPage:1];
}

- (UIImage *)imageWithImage:(UIImage *)image withWidth:(CGFloat)width { //Unused
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    CGFloat height = image.size.height * (width / image.size.width);
    CGSize newSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
