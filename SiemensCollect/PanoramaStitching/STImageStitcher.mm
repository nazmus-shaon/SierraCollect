#import "STImageStitcher.h"
#import "UIImage+STOpenCV.h"
#import <opencv2/stitching/stitcher.hpp>


@implementation STImageStitcher

+ (UIImage *) panoramaFromImages:(NSArray *)images
{
    std::vector<cv::Mat> imgs(images.count);
    for (int i=0; i< images.count; i++) {
        UIImage * imageUI = images[i];
        //
        
        
        //cv::Mat imgMat = [ imageUI toGrayScaleCVMat];
        cv::Mat imgMat = [imageUI toRGBCVMat];
        imgs[i] = imgMat;
    }

    
    cv::Mat pano;
    cv::Stitcher stitcher = cv::Stitcher::createDefault(true);
    stitcher.setFeaturesFinder(new cv::detail::OrbFeaturesFinder());
    //stitcher.setWarper( new cv::PlaneWarper);
    //stitcher.setWarper( new cv::CylindricalWarper);
    cv::Stitcher::Status state = stitcher.stitch(imgs, pano);
    NSLog(@"Stitching finished");
    
    if (state != cv::Stitcher::OK)
    {
        return NULL;
    }
    else {
        return [[UIImage alloc] initWithCVMat:pano];
    }
}

@end