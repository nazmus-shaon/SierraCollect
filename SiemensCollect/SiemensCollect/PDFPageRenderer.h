//
//  SCMainViewController.h
//  SiemensCollect
//
//  Created by Andreas Seitz on 24.05.13.
//  Copyright (c) 2013 iOS13 Siemens CIT. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PDFPageRenderer : NSObject {

}

+ (void) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context;
+ (void) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context atPoint: (CGPoint) point;
+ (void) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context atPoint: (CGPoint) point withZoom: (float) zoom;
+ (void) renderPage: (CGPDFPageRef) page inContext: (CGContextRef) context inRectangle: (CGRect) rectangle;

@end
