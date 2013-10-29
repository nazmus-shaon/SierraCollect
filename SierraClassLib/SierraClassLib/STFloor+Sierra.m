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
    return [UIImage imageWithPDFNamed:self.relatedFile atWidth:width atPage:1];
}

- (UIImage *)getImageforHeight:(float)height {
    return [UIImage imageWithPDFNamed:self.relatedFile atHeight:height atPage:1];
}


@end
