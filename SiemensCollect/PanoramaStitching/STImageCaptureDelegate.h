//
//  STImageCaptureDelegate.h
//  Panorama
//
//  Created by Christian Flasche on 04.07.13.
//  Copyright (c) 2013 Natalia Zarawska. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STImageCaptureDelegate <NSObject>

- (void)imageChosen:(NSDictionary *)imageDictionary;

@end
