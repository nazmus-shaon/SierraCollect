#import "UIImage+STOpenCV.h"

static void ProviderReleaseDataNOP(void *info, const void *data, size_t size)
{
    // Do not release memory
    return;
}

@implementation UIImage (STOpenCV)

- (id) initWithCVMat:(const cv::Mat &)cvMat
{
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        cv::cvtColor(cvMat, cvMat, CV_BGR2RGB);
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)CFBridgingRetain(data));
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    self = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return self;
}

- (cv::Mat) toBGRACVMat
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(self.CGImage);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

- (cv::Mat) toGrayScaleCVMat
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(self.CGImage);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;

}

- (cv::Mat) toRGBCVMat
{
    cv::Mat BGRMat = [self toBGRACVMat];
    cv::Mat RGBMat(BGRMat.rows,BGRMat.cols,CV_8UC3);
    cv::cvtColor(BGRMat, RGBMat, CV_BGRA2RGB);
    return RGBMat;
}

- (UIImage *)showKeypoints
{
    using namespace cv;
    std::vector<KeyPoint> keypoints = [self detectKeypoints];
    Mat img_keypoints;
    drawKeypoints( self.toRGBCVMat, keypoints, img_keypoints, Scalar::all(-1), DrawMatchesFlags::DEFAULT );
    return [[UIImage alloc] initWithCVMat:img_keypoints];
}

- (int)numberOfKeypoints
{
    
    using namespace cv;
    std::vector<KeyPoint> keypoints = [self detectKeypoints];
    return keypoints.size();
}

- (std::vector<cv::KeyPoint>) detectKeypoints
{
    using namespace cv;
    Mat cvImage = self.toRGBCVMat;
    Ptr<FeatureDetector> detector = FeatureDetector::create("GridFAST");
    std::vector<KeyPoint> keypoints;
    detector->detect(cvImage, keypoints);
    return keypoints;
}

@end
