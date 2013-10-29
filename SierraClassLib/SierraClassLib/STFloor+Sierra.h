//
//  STFloor+Sierra.h
//  SierraClassLib
//
//  Created by Andreas Seitz on 08.07.13.
//  Copyright (c) 2013 Lehrstuhl für Angewandte Softwaretechnik. All rights reserved.
//

#import "STFloor.h"

@interface STFloor (Sierra)

//New Methods & properties

- (UIImage *)getSmallPreviewImage;
- (UIImage *)getImageforWidth:(float)width;
- (UIImage *)getImageforHeight:(float)height;

@end
